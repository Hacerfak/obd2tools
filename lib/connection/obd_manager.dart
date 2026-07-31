import 'dart:async';
import 'dart:collection';
import 'obd_connection.dart';
import '/parser/obd_parser.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../parser/parsers/mode_09_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import '../parser/parsers/dtc_parser.dart';
import '../parser/parsers/mode_02_parser.dart';
import '../models/dtc_fault.dart';

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
    print(message);
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
        if (cleanHex.startsWith("4100") ||
            cleanHex.startsWith("4120") ||
            cleanHex.startsWith("4140")) {
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
      // MODO 09 - Info do Veículo
      else if (cleanHex.startsWith("49")) {
        Map<String, String> parsedInfo = Mode09Parser.parse(cleanHex);
        if (parsedInfo.isNotEmpty) {
          ref.read(vehicleInfoStateProvider.notifier).updateInfo(parsedInfo);
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
        if (cleanHex.contains("420000") ||
            cleanHex.contains("422000") ||
            cleanHex.contains("424000")) {
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
        if (_isFastInitialPass || _pollingCooldown == Duration.zero) {
          _triggerNextPollingRequest();
        } else {
          _cooldownTimer?.cancel();
          _cooldownTimer = Timer(_pollingCooldown, () {
            if (_isPollingEnabled && _commandQueue.isEmpty) {
              _triggerNextPollingRequest();
            }
          });
        }
      } else if (!_isPollingEnabled &&
          _commandQueue.isEmpty &&
          ref.read(dtcStateProvider).isLoading) {
        // Fila esvaziou durante o diagnóstico de falhas
        ref.read(dtcStateProvider.notifier).setLoading(false);
        _addLog("Diagnóstico concluído com sucesso.");
      }
    }
  }
}
