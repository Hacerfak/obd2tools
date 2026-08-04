import 'dart:async';
import 'dart:collection';
import 'obd_connection.dart';
import '/parser/obd_parser.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../parser/parsers/mode_06_parser.dart';
import '../parser/parsers/mode_09_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import '../parser/parsers/dtc_parser.dart';
import '../parser/parsers/mode_02_parser.dart';
import '../models/dtc_fault.dart';
import 'package:flutter/foundation.dart';

class ObdManager {
  final ObdConnection connection;
  final Ref ref;

  final Queue<String> _commandQueue = Queue<String>();
  String _buffer = "";

  bool _isWaitingForResponse = false;
  bool _isClearingDTCs = false;

  final _logStreamController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logStreamController.stream;

  // CONTROLES DE VARREDURA E COOLDOWN
  bool _isPollingEnabled = false;
  List<int> _activePollingPids = [];
  int _pollingIndex = 0;

  Duration _pollingCooldown = Duration.zero;
  bool _isFastInitialPass = false;
  Timer? _cooldownTimer;

  // CONTROLES DE HIBERNAÇÃO DA ECU
  int _consecutiveErrors = 0;
  Timer? _ecuPingTimer;

  ObdManager({required this.connection, required this.ref}) {
    connection.dataStream.listen(_onDataReceived);
  }

  void _addLog(String message) {
    _logStreamController.add(message);
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  void queueCommand(String command) {
    _commandQueue.add(command);
    _processQueue();
  }

  // --- DIAGNÓSTICO ---
  void scanAllFaults() {
    _isPollingEnabled = false; // Desliga o dashboard
    _commandQueue.clear(); // Limpa lixo na fila

    ref.read(dtcStateProvider.notifier).clearCodes();
    ref.read(dtcStateProvider.notifier).setLoading(true);

    queueCommand("03");
    queueCommand("07");
    queueCommand("0A");
    queueCommand("020000");
  }

  void clearDTCs() {
    _isClearingDTCs = true;
    queueCommand("04");
  }

  // --- INFORMAÇÕES DO VEÍCULO (MODO 09) ---
  void requestVehicleInfo() {
    _addLog("Solicitando mapeamento do Modo 09 (PIDs Suportados)...");
    _isPollingEnabled = false;
    queueCommand("0900"); // A mágica começa aqui!
  }

  // --- TESTES DE MONITORES (MODO 06) ---
  void scanTestResults() {
    _addLog("Solicitando Modo 06: Mapeamento + Busca Cega...");
    _isPollingEnabled = false;
    ref.read(testResultsProvider.notifier).clear();
    ref.read(testResultsProvider.notifier).setLoading(true);

    // 1. Tática de Força Bruta (Mapeamento Padrão)
    queueCommand("0600");
    queueCommand("0620");
    queueCommand("0640");
    queueCommand("0660");
    queueCommand("0680");
    queueCommand("06A0");
    queueCommand("06C0");
    queueCommand("06E0");

    // 2. Tática de Busca Cega (Ignoramos se a GM diz não suportar, pedimos à força!)

    // Sondas Lambdas (Banco 1 - Sensores 1 e 2)
    queueCommand("0601");
    queueCommand("0602");

    // Catalisador (Banco 1 e 2)
    queueCommand("0621");
    queueCommand("0622");

    // VVT / Comando de Válvulas
    queueCommand("0635");

    Future.delayed(const Duration(seconds: 15), () {
      if (ref.read(testResultsProvider.notifier).isLoading) {
        ref.read(testResultsProvider.notifier).setLoading(false);
        _addLog("Varredura de Modo 06 abortada por Timeout de 15s.");
      }
    });
  }

  // --- VARREDURA E CARROSSEL ---
  void setPollingPids(
    List<int> pids, {
    Duration cooldown = Duration.zero,
    bool fastInitialPass = false,
  }) {
    _activePollingPids = pids;
    _isPollingEnabled = pids.isNotEmpty;
    _pollingIndex = 0;

    _pollingCooldown = cooldown;
    _isFastInitialPass = fastInitialPass;
    _cooldownTimer?.cancel();
    _commandQueue.clear();

    if (_isPollingEnabled && !_isWaitingForResponse) {
      _triggerNextPollingRequest();
    }
  }

  void _triggerNextPollingRequest() {
    if (!_isPollingEnabled || _activePollingPids.isEmpty) return;

    List<int> pidsToRequest = [];
    int count = 0;

    while (count < 6 && count < _activePollingPids.length) {
      if (_pollingIndex >= _activePollingPids.length) {
        _pollingIndex = 0;
        _isFastInitialPass = false; // Acabou o turbo inicial
      }
      pidsToRequest.add(_activePollingPids[_pollingIndex]);
      _pollingIndex++;
      count++;
    }

    String multiCommand = "01";
    for (var pid in pidsToRequest) {
      multiCommand += pid.toRadixString(16).padLeft(2, '0').toUpperCase();
    }
    queueCommand(multiCommand);
  }

  // --- CONFIGURAÇÃO INICIAL AT ---
  void initializeScanner() {
    queueCommand("AT Z");
    queueCommand("AT E0");
    queueCommand("AT L0");
    queueCommand("AT S0");
    queueCommand("AT H0");
    queueCommand("AT AT2");
    queueCommand("AT SP 0");
    queueCommand("AT RV");
    queueCommand("AT DP");
  }

  void discoverSupportedSensors() {
    ref.read(supportedPidsProvider.notifier).clear();
    queueCommand("0100");
  }

  void forceDisconnect() {
    _addLog("Desconectando Bluetooth por falha crítica.");
    reset();
    connection.disconnect();
    ref
        .read(connectionStateProvider.notifier)
        .updateState(AppConnectionState.disconnected);
  }

  void reset() {
    _commandQueue.clear();
    _buffer = "";
    _isWaitingForResponse = false;
    _isPollingEnabled = false;
    _isClearingDTCs = false;
    _consecutiveErrors = 0;
    _cooldownTimer?.cancel();
    _ecuPingTimer?.cancel();
    ref.read(realTimeStateProvider.notifier).clearData();
  }

  void _processQueue() {
    if (_isWaitingForResponse || _commandQueue.isEmpty) return;
    _isWaitingForResponse = true;
    String nextCommand = _commandQueue.removeFirst();
    connection.sendCommand(nextCommand);
  }

  void _onDataReceived(String data) {
    _buffer += data;
    if (_buffer.contains(">")) {
      String fullResponse = _buffer
          .replaceAll(">", "")
          .replaceAll(RegExp(r'[\r\n]+'), " ")
          .trim();
      _handleCompleteResponse(fullResponse);
      _buffer = "";
      _isWaitingForResponse = false;
      _processQueue();
    }
  }

  void _handleCompleteResponse(String response) {
    try {
      // 1. TRATAMENTO DE ERROS E HIBERNAÇÃO DA ECU
      if (response.contains("NO DATA") ||
          response.contains("ERROR") ||
          response.contains("UNABLE TO CONNECT")) {
        if (_isPollingEnabled || response.contains("UNABLE TO CONNECT")) {
          _consecutiveErrors++;
          _addLog("ALERTA: Erro de comunicação. (Falha $_consecutiveErrors/5)");

          if (_consecutiveErrors >= 5) {
            _addLog("ECU não responde. Entrando em modo de espera...");
            _consecutiveErrors = 0;
            _isPollingEnabled = false;
            _commandQueue.clear();

            ref
                .read(connectionStateProvider.notifier)
                .updateState(AppConnectionState.waitingForEcu);

            _ecuPingTimer?.cancel();
            _ecuPingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
              queueCommand("0100"); // Ping leve
            });
            return;
          }
        } else {
          _addLog("Aviso: Dado não encontrado (Normal em DTC/Freeze Frame).");
        }
        return;
      }

      String rawResponse = response.replaceAll("SEARCHING...", "").trim();
      String cleanHex = ObdParser.cleanRawResponse(rawResponse);

      // 2. A ECU ACORDOU!
      if (cleanHex.startsWith("41") ||
          cleanHex.startsWith("42") ||
          cleanHex.startsWith("43") ||
          cleanHex.startsWith("44") ||
          cleanHex.startsWith("49")) {
        _consecutiveErrors = 0;

        final currentState = ref.read(connectionStateProvider);
        if (currentState == AppConnectionState.waitingForEcu) {
          _ecuPingTimer?.cancel();
          _addLog("ECU Acordou! Retomando...");
          ref
              .read(connectionStateProvider.notifier)
              .updateState(AppConnectionState.ready);
        } else if (currentState == AppConnectionState.connectingBluetooth) {
          ref
              .read(connectionStateProvider.notifier)
              .updateState(AppConnectionState.discoveringSensors);
        }
      }

      // 3. ROTEAMENTO MODO 01 (Sensores e Paginação)
      if (cleanHex.startsWith("41")) {
        // Agora aceita a descoberta dinâmica de 00 até C0!
        if (RegExp(r'^41(00|20|40|60|80|A0|C0)').hasMatch(cleanHex)) {
          final RegExp supportRegex = RegExp(
            r'41(00|20|40|60|80|A0|C0)([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);
          for (final match in matches) {
            String pidHex = match.group(1)!;
            String dataHex = match.group(2)!;
            int basePid = int.parse(pidHex, radix: 16);
            List<int> supported = Mode01Parser.parseSupportedPids(
              dataHex,
              basePid,
            );

            ref.read(supportedPidsProvider.notifier).addPids(supported);

            if (supported.contains(basePid + 0x20)) {
              String nextHex = (basePid + 0x20)
                  .toRadixString(16)
                  .padLeft(2, '0')
                  .toUpperCase();
              queueCommand("01$nextHex");
            } else {
              final currentState = ref.read(connectionStateProvider);
              if (currentState == AppConnectionState.discoveringSensors) {
                ref
                    .read(connectionStateProvider.notifier)
                    .updateState(AppConnectionState.ready);
              }
            }
          }
        } else {
          Map<String, ObdReadResult> parsedData = Mode01Parser.parse(cleanHex);
          if (parsedData.isNotEmpty) {
            ref.read(realTimeStateProvider.notifier).updateData(parsedData);
          }
        }
      }
      // LÊ TESTES DE MONITORES (Modo 06)
      else if (cleanHex.startsWith("46")) {
        // Se for a resposta do mapeamento usando nossa tática de Força Bruta
        if (RegExp(r'46(00|20|40|60|80|A0|C0|E0)').hasMatch(cleanHex)) {
          final RegExp supportRegex = RegExp(
            r'46(00|20|40|60|80|A0|C0|E0)([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);

          for (final match in matches) {
            int basePid = int.parse(match.group(1)!, radix: 16);
            String dataHex = match.group(2)!;

            List<int> supported = Mode01Parser.parseSupportedPids(
              dataHex,
              basePid,
            );

            for (int mid in supported) {
              if (mid % 0x20 != 0) {
                // Aqui nós pedimos diretamente o teste aprovado pela máscara!
                String hexReq = mid
                    .toRadixString(16)
                    .padLeft(2, '0')
                    .toUpperCase();
                queueCommand("06$hexReq");
              }
            }
          }
        }
        // Se for a resposta de um teste específico (ex: 4601, 46A2...)
        else {
          List<Mode06Result> parsedData = Mode06Parser.parse(cleanHex);
          for (var result in parsedData) {
            ref.read(testResultsProvider.notifier).addResult(result);
          }
        }
      }
      // MODO 09 - Info do Veículo
      else if (cleanHex.startsWith("49")) {
        // Se for a resposta do mapeamento (0900 -> 4900)
        if (cleanHex.startsWith("4900")) {
          final RegExp supportRegex = RegExp(r'4900([0-9A-F]{8})');
          final match = supportRegex.firstMatch(cleanHex);
          if (match != null) {
            String dataHex = match.group(1)!;
            // Reutiliza o nosso decodificador de bits do Modo 01!
            List<int> supported = Mode01Parser.parseSupportedPids(dataHex, 0);

            _addLog("Mapeamento 09 concluído. PIDs suportados: $supported");
            // Dispara automaticamente a fila pedindo os dados que o carro suporta
            for (int pid in supported) {
              if (pid != 0) {
                String hexReq = pid
                    .toRadixString(16)
                    .padLeft(2, '0')
                    .toUpperCase();
                queueCommand("09$hexReq");
              }
            }
          }
        }
        // Se for a resposta com os dados em si (ex: 4902...)
        else {
          Map<String, String> parsedInfo = Mode09Parser.parse(cleanHex);
          if (parsedInfo.isNotEmpty) {
            ref.read(vehicleInfoStateProvider.notifier).updateInfo(parsedInfo);
          }
        }
      }
      // LÊ FALHAS CONFIRMADAS (Modo 03)
      else if (cleanHex.startsWith("43")) {
        List<String> dtcs = DtcParser.parse(cleanHex, "43");
        ref.read(dtcStateProvider.notifier).addCodes(dtcs, DtcStatus.confirmed);
      }
      // LÊ FALHAS PENDENTES (Modo 07)
      else if (cleanHex.startsWith("47")) {
        List<String> dtcs = DtcParser.parse(cleanHex, "47");
        ref.read(dtcStateProvider.notifier).addCodes(dtcs, DtcStatus.pending);
      }
      // LÊ FALHAS PERMANENTES (Modo 0A)
      else if (cleanHex.startsWith("4A")) {
        List<String> dtcs = DtcParser.parse(cleanHex, "4A");
        ref.read(dtcStateProvider.notifier).addCodes(dtcs, DtcStatus.permanent);
      }
      // FREEZE FRAME (Modo 02)
      else if (cleanHex.startsWith("42")) {
        // Libera a passagem para mapeamento de todos os Freeze Frames
        if (RegExp(r'42(00|20|40|60|80|A0|C0)00').hasMatch(cleanHex)) {
          final RegExp supportRegex = RegExp(
            r'42(00|20|40|60|80|A0|C0)00([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);
          for (final match in matches) {
            String pidHex = match.group(1)!;
            String dataHex = match.group(2)!;
            int basePid = int.parse(pidHex, radix: 16);
            List<int> supported = Mode01Parser.parseSupportedPids(
              dataHex,
              basePid,
            );

            for (int pid in supported) {
              if (pid % 0x20 != 0 && pid != 0x02) {
                String hexReq = pid
                    .toRadixString(16)
                    .padLeft(2, '0')
                    .toUpperCase();
                queueCommand("02${hexReq}00");
              }
            }
            if (supported.contains(basePid + 0x20)) {
              String nextGroupHex = (basePid + 0x20)
                  .toRadixString(16)
                  .padLeft(2, '0')
                  .toUpperCase();
              queueCommand("02${nextGroupHex}00");
            }
          }
        } else {
          Map<String, ObdReadResult> parsedData = Mode02Parser.parse(cleanHex);
          if (parsedData.isNotEmpty) {
            ref.read(dtcStateProvider.notifier).attachFreezeFrame(parsedData);
          }
        }
      }
      // APAGA FALHAS (Modo 04)
      else if (cleanHex.startsWith("44") ||
          (_isClearingDTCs && rawResponse == "OK")) {
        _isClearingDTCs = false;
        _addLog("Memória da ECU apagada com sucesso!");
        ref.read(dtcStateProvider.notifier).clearCodes();
        Timer(const Duration(seconds: 2), () => scanAllFaults());
      }
    } finally {
      if (_isPollingEnabled && _commandQueue.isEmpty) {
        // Puxa o intervalo escolhido pelo usuário nas Configurações
        int userInterval = ref.read(pollingIntervalProvider);
        Duration delay = Duration(milliseconds: userInterval);

        // Se a tela de dashboard pediu um resfriamento maior (ex: 3s), respeitamos o maior
        if (_pollingCooldown > delay) delay = _pollingCooldown;

        _cooldownTimer?.cancel();

        if (_isFastInitialPass || delay == Duration.zero) {
          // Mesmo no modo "Tempo Real", damos 15ms de respiro para o Flutter desenhar a tela e o celular não fritar
          _cooldownTimer = Timer(const Duration(milliseconds: 15), () {
            if (_isPollingEnabled && _commandQueue.isEmpty) {
              _triggerNextPollingRequest();
            }
          });
        } else {
          _cooldownTimer = Timer(delay, () {
            if (_isPollingEnabled && _commandQueue.isEmpty) {
              _triggerNextPollingRequest();
            }
          });
        }
      } else if (!_isPollingEnabled && _commandQueue.isEmpty) {
        // Encerra apenas o carregamento de DTCs se ele estiver rodando
        if (ref.read(dtcStateProvider).isLoading) {
          ref.read(dtcStateProvider.notifier).setLoading(false);
          _addLog("Diagnóstico concluído com sucesso.");
        }
        // Encerra Loading do Modo 06 de forma natural (quando não há mais comandos pendentes)
        if (ref.read(testResultsProvider.notifier).isLoading) {
          ref.read(testResultsProvider.notifier).setLoading(false);
          _addLog("Varredura de Modo 06 concluída naturalmente.");
        }
      }
    }
  }
}
