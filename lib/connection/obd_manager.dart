import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'obd_connection.dart';
import '../parser/obd_parser.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../parser/parsers/mode_06_parser.dart';
import '../parser/parsers/mode_09_parser.dart';
import '../parser/parsers/dtc_parser.dart';
import '../parser/parsers/mode_02_parser.dart';
import '../parser/registries/mode_01_registry.dart';

import '../state/obd_providers.dart';
import '../state/technical_data_service.dart';

import '../models/dtc_fault.dart';
import '../models/protocol_profile.dart';
import '../models/ecu_module.dart';
import '../models/mapped_sensor.dart';

class ObdManager {
  final ObdConnection connection;
  final Ref ref;

  final Queue<String> _commandQueue = Queue<String>();
  String _buffer = "";
  String _lastCommandSent = "";

  bool _isWaitingForResponse = false;
  bool _isClearingDTCs = false;

  final _logStreamController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logStreamController.stream;

  // CONTROLES DE VARREDURA E COOLDOWN
  bool _isPollingEnabled = false;
  int _pollingIndex = 0;
  Duration _pollingCooldown = Duration.zero;
  bool _isFastInitialPass = false;
  Timer? _cooldownTimer;

  // CONTROLES DE HIBERNAÇÃO DA ECU
  int _consecutiveErrors = 0;
  Timer? _ecuPingTimer;

  // NOVAS VARIÁVEIS DE GERENCIAMENTO DE MÓDULO (MULTIPLEXAÇÃO)
  List<EcuModule> _discoveredEcus = [];
  EcuModule _currentActiveEcu = EcuModule.defaultEcu();

  Map<String, List<MappedSensor>> _activeSensorsByEcu = {};
  List<String> _ecuCycle = [];
  int _ecuCycleIndex = 0;

  ObdManager({required this.connection, required this.ref}) {
    connection.dataStream.listen(_onDataReceived);

    connection.onDisconnected = () {
      if (ref.read(connectionStateProvider) !=
          AppConnectionState.disconnected) {
        forceDisconnect();
      }
    };
  }

  // --- COMANDOS CUSTOMIZADOS (TERMINAL) ---
  void sendCustomCommand(String command) {
    _isPollingEnabled = false;
    _commandQueue.clear();
    queueCommand(command);
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
    _isPollingEnabled = false;
    _commandQueue.clear();

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
    queueCommand("0900");
  }

  // --- TESTES DE MONITORES (MODO 06) ---
  void scanTestResults() {
    _addLog("Solicitando Modo 06: Mapeamento + Busca Cega...");
    _isPollingEnabled = false;
    ref.read(testResultsProvider.notifier).clear();
    ref.read(testResultsProvider.notifier).setLoading(true);

    queueCommand("0600");
    queueCommand("0620");
    queueCommand("0640");
    queueCommand("0660");
    queueCommand("0680");
    queueCommand("06A0");
    queueCommand("06C0");
    queueCommand("06E0");

    queueCommand("0601");
    queueCommand("0602");
    queueCommand("0621");
    queueCommand("0622");
    queueCommand("0635");

    Future.delayed(const Duration(seconds: 15), () {
      if (ref.read(testResultsProvider.notifier).isLoading) {
        ref.read(testResultsProvider.notifier).setLoading(false);
        _addLog("Varredura de Modo 06 abortada por Timeout de 15s.");
      }
    });
  }

  // --- VARREDURA E CARROSSEL (MULTIPLEXADO) ---
  void setPollingPids(
    List<MappedSensor> sensors, {
    Duration cooldown = Duration.zero,
    bool fastInitialPass = false,
  }) {
    _isPollingEnabled = sensors.isNotEmpty;
    _pollingCooldown = cooldown;
    _isFastInitialPass = fastInitialPass;

    // SALVA COMANDOS DE CONFIGURAÇÃO ANTES DE LIMPAR A FILA
    // Isso impede que os resets (AT S0, AT H0) sejam apagados
    // pela troca rápida de tela!
    final pendingAtCommands = _commandQueue
        .where((cmd) => cmd.startsWith("AT"))
        .toList();

    _commandQueue.clear();
    _commandQueue.addAll(pendingAtCommands); // Devolve os comandos protegidos

    _cooldownTimer?.cancel();

    // Agrupa os sensores solicitados por ECU
    _activeSensorsByEcu.clear();
    for (var s in sensors) {
      _activeSensorsByEcu.putIfAbsent(s.module.txHeader, () => []).add(s);
    }

    _ecuCycle = _activeSensorsByEcu.keys.toList();
    _ecuCycleIndex = 0;
    _pollingIndex = 0;

    if (_isPollingEnabled && !_isWaitingForResponse) {
      _triggerNextPollingRequest();
    }
  }

  void _triggerNextPollingRequest() {
    if (!_isPollingEnabled || _ecuCycle.isEmpty) return;

    // Pega a ECU da rodada
    String targetTxHeader = _ecuCycle[_ecuCycleIndex];
    List<MappedSensor> ecuSensors = _activeSensorsByEcu[targetTxHeader]!;

    List<int> pidsToRequest = [];
    int count = 0;

    // Coleta até 6 PIDs da ECU atual
    while (count < 6 && count < ecuSensors.length) {
      if (_pollingIndex >= ecuSensors.length) {
        _pollingIndex = 0;
        _isFastInitialPass = false;

        // Passa a vez para o próximo módulo
        _ecuCycleIndex = (_ecuCycleIndex + 1) % _ecuCycle.length;
        break;
      }
      pidsToRequest.add(ecuSensors[_pollingIndex].pid.id);
      _pollingIndex++;
      count++;
    }

    if (pidsToRequest.isNotEmpty) {
      // APONTA O ELM327 PARA O MÓDULO ALVO ANTES DE PEDIR OS DADOS
      queueCommand("AT SH $targetTxHeader");

      String multiCommand = "01";
      for (var pid in pidsToRequest) {
        multiCommand += pid.toRadixString(16).padLeft(2, '0').toUpperCase();
      }
      queueCommand(multiCommand);
    } else {
      _triggerNextPollingRequest();
    }
  }

  // --- RESTAURAÇÃO DE FORMATAÇÃO ---
  void resetElmToDefaults() {
    _addLog("Restaurando parâmetros base do ELM327...");
    _isPollingEnabled = false;
    _commandQueue.clear(); // Limpa resquícios do que o usuário digitou
    queueCommand("AT Z");
    queueCommand("AT E0");
    queueCommand("AT L0");
    queueCommand("AT S0");
    queueCommand("AT H0");
    queueCommand("AT AT2");
    queueCommand("AT SP 0");
  }

  // --- CONFIGURAÇÃO INICIAL (HANDSHAKE) ---
  void initializeScanner() {
    _addLog("Inicializando o ELM327");
    ref
        .read(connectionStateProvider.notifier)
        .updateState(AppConnectionState.connectingBluetooth);

    queueCommand("AT Z");
    queueCommand("AT E0");
    queueCommand("AT L0");
    queueCommand("AT S0");
    queueCommand("AT H0");
    queueCommand("AT AT2");
    queueCommand("AT SP 0");

    queueCommand("0100"); // Acorda a ECU
    queueCommand("AT DPN"); // Pergunta qual protocolo pegou
  }

  void discoverSupportedSensors() {
    // Esse método agora é chamado internamente após o DPN ou H1
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
    _addLog("Executando reset completo do ObdManager...");

    // 1. Cancela timers ativos
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _ecuPingTimer?.cancel();
    _ecuPingTimer = null;

    // 2. Limpa filas de comandos e buffers de resposta
    _commandQueue.clear();
    _buffer = "";
    _lastCommandSent = "";
    _isWaitingForResponse = false;
    _isPollingEnabled = false;
    _isClearingDTCs = false;
    _consecutiveErrors = 0;

    // 3. Reseta estados da busca de ECUs e Multiplexação
    _discoveredEcus.clear();
    _currentActiveEcu = EcuModule.defaultEcu();
    _activeSensorsByEcu.clear();
    _ecuCycle.clear();
    _ecuCycleIndex = 0;
    _pollingIndex = 0;

    // 4. Reseta todos os Providers de estado do Riverpod (purgando o perfil antigo)
    ref.invalidate(protocolProfileProvider);
    ref.read(realTimeStateProvider.notifier).clearData();
    ref.read(supportedPidsProvider.notifier).clear();
    ref.read(vehicleInfoStateProvider.notifier).updateInfo({});
    ref.read(dtcStateProvider.notifier).clearCodes();
    ref.read(testResultsProvider.notifier).clear();
  }

  void _processQueue() {
    if (_isWaitingForResponse || _commandQueue.isEmpty) return;
    _isWaitingForResponse = true;
    _lastCommandSent = _commandQueue.removeFirst();
    connection.sendCommand(_lastCommandSent);
  }

  void _onDataReceived(String data) {
    _buffer += data;
    if (_buffer.contains(">")) {
      String fullResponse = _buffer
          .replaceAll(">", "")
          .replaceAll(RegExp(r'[\r\n]+'), " ")
          .trim();
      _logStreamController.add(fullResponse);
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
          response.contains("UNABLE TO CONNECT") ||
          response.contains("BUS INIT")) {
        final currentState = ref.read(connectionStateProvider);

        if (currentState == AppConnectionState.connectingBluetooth ||
            currentState == AppConnectionState.discoveringSensors) {
          _addLog("ECU não respondeu à inicialização. Solicitando ignição...");
          _commandQueue.clear();
          ref
              .read(connectionStateProvider.notifier)
              .updateState(AppConnectionState.waitingForEcu);

          _ecuPingTimer?.cancel();
          _ecuPingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
            queueCommand("0100");
          });
          return;
        }

        if (_isPollingEnabled) {
          _consecutiveErrors++;
          _addLog("ALERTA: Erro de comunicação. (Falha $_consecutiveErrors/5)");

          if (_consecutiveErrors >= 5) {
            _addLog("ECU parou de responder. Entrando em modo de espera...");
            _consecutiveErrors = 0;
            _isPollingEnabled = false;
            _commandQueue.clear();

            ref
                .read(connectionStateProvider.notifier)
                .updateState(AppConnectionState.waitingForEcu);

            _ecuPingTimer?.cancel();
            _ecuPingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
              queueCommand("0100");
            });
          }
        }
        return;
      }

      String rawResponse = response.replaceAll("SEARCHING...", "").trim();

      // === 2. INTERCEPTA O HANDSHAKE DO PROTOCOLO ===
      if (_lastCommandSent == "AT DPN") {
        final profile = ProtocolProfile.fromElmNumber(rawResponse);
        ref.read(protocolProfileProvider.notifier).setProfile(profile);
        _addLog(
          "Protocolo detectado: ${profile.protocolName} (Raw: $rawResponse)",
        );

        if (profile.supportsCanHeaders) {
          _addLog(
            "Bus CAN detectado. Lendo Headers para identificar ECUs presentes...",
          );
          queueCommand("AT H1"); // Liga Headers
          queueCommand("0100"); // Pergunta PIDs base com os Headers aparecendo
        } else {
          _addLog("Barramento K-Line. Módulo Único.");
          _discoveredEcus = [EcuModule.defaultEcu()];
          ref
              .read(connectionStateProvider.notifier)
              .updateState(AppConnectionState.discoveringSensors);
          queueCommand("0100"); // Segue padrão
        }
        return;
      }

      // === 3. RECEBEU A LISTA DE MÓDULOS (FASE AT H1) ===
      if (_lastCommandSent == "0100" &&
          ref.read(protocolProfileProvider).supportsCanHeaders &&
          rawResponse.contains("4100")) {
        if (_discoveredEcus.isEmpty) {
          _discoveredEcus = ObdParser.discoverEcusFromH1(
            rawResponse,
            ref.read(protocolProfileProvider),
          );
          _addLog(
            "Módulos encontrados: ${_discoveredEcus.map((e) => e.name).join(', ')}",
          );

          queueCommand("AT H0"); // Desliga os headers para limpar a formatação

          ref
              .read(connectionStateProvider.notifier)
              .updateState(AppConnectionState.discoveringSensors);
          ref.read(supportedPidsProvider.notifier).clear();

          // Pagina módulo por módulo isoladamente
          for (var ecu in _discoveredEcus) {
            queueCommand("AT SH ${ecu.txHeader}");
            queueCommand("0100");
          }
          return;
        }
      }

      // === 4. RASTREADOR DE FOCO DE MÓDULO ===
      if (_lastCommandSent.startsWith("AT SH ")) {
        String tx = _lastCommandSent.substring(6).trim();
        _currentActiveEcu = _discoveredEcus.firstWhere(
          (e) => e.txHeader == tx,
          orElse: () => EcuModule.defaultEcu(),
        );
        return; // AT SH retorna apenas "OK", não precisa de parser
      }

      // Limpeza pelo Perfil
      final profile = ref.read(protocolProfileProvider);
      String cleanHex = ObdParser.cleanRawResponse(rawResponse, profile);

      if (cleanHex.isEmpty) return;

      // === 5. A ECU ACORDOU! ===
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

      // === 6. ROTEAMENTO MODO 01 (Sensores e Paginação por ECU) ===
      if (cleanHex.startsWith("41")) {
        // Mapeamento e Paginação
        if (RegExp(r'^41(00|20|40|60|80|A0|C0)').hasMatch(cleanHex)) {
          final RegExp supportRegex = RegExp(
            r'41(00|20|40|60|80|A0|C0)([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);

          for (final match in matches) {
            int basePid = int.parse(match.group(1)!, radix: 16);
            List<int> supported = Mode01Parser.parseSupportedPids(
              match.group(2)!,
              basePid,
            );

            // Transforma o número do PID em um MappedSensor amarrado ao módulo ativo
            List<MappedSensor> mapped = supported
                .where((id) => pidRegistry.containsKey(id))
                .map(
                  (id) => MappedSensor(
                    pid: pidRegistry[id]!,
                    module: _currentActiveEcu,
                  ),
                )
                .toList();

            ref.read(supportedPidsProvider.notifier).addSensors(mapped);

            if (supported.contains(basePid + 0x20)) {
              String nextHex = (basePid + 0x20)
                  .toRadixString(16)
                  .padLeft(2, '0')
                  .toUpperCase();
              queueCommand(
                "AT SH ${_currentActiveEcu.txHeader}",
              ); // Garante foco
              queueCommand("01$nextHex");
            } else {
              if (ref.read(connectionStateProvider) ==
                  AppConnectionState.discoveringSensors) {
                ref
                    .read(connectionStateProvider.notifier)
                    .updateState(AppConnectionState.ready);
              }
            }
          }
        }
        // Leitura em Tempo Real (Dashboard)
        else {
          Map<int, ObdReadResult> parsedData = Mode01Parser.parseAsIntKeys(
            cleanHex,
          );
          Map<String, ObdReadResult> finalData = {};

          parsedData.forEach((pidId, result) {
            String uniqueId =
                "${pidId.toRadixString(16).padLeft(2, '0').toUpperCase()}_${_currentActiveEcu.txHeader}";
            finalData[uniqueId] = result;
          });

          if (finalData.isNotEmpty) {
            ref.read(realTimeStateProvider.notifier).updateData(finalData);
          }
        }
      }
      // === LÊ TESTES DE MONITORES (Modo 06) ===
      else if (cleanHex.startsWith("46")) {
        if (RegExp(r'46(00|20|40|60|80|A0|C0|E0)').hasMatch(cleanHex)) {
          final RegExp supportRegex = RegExp(
            r'46(00|20|40|60|80|A0|C0|E0)([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);

          for (final match in matches) {
            int basePid = int.parse(match.group(1)!, radix: 16);
            List<int> supported = Mode01Parser.parseSupportedPids(
              match.group(2)!,
              basePid,
            );

            for (int mid in supported) {
              if (mid % 0x20 != 0) {
                String hexReq = mid
                    .toRadixString(16)
                    .padLeft(2, '0')
                    .toUpperCase();
                queueCommand("06$hexReq");
              }
            }
          }
        } else {
          List<Mode06Result> parsedData = Mode06Parser.parse(cleanHex);
          for (var result in parsedData) {
            ref.read(testResultsProvider.notifier).addResult(result);
          }
        }
      }
      // === MODO 09 - Info do Veículo ===
      else if (cleanHex.startsWith("49")) {
        if (cleanHex.startsWith("4900")) {
          final RegExp supportRegex = RegExp(r'4900([0-9A-F]{8})');
          final match = supportRegex.firstMatch(cleanHex);
          if (match != null) {
            List<int> supported = Mode01Parser.parseSupportedPids(
              match.group(1)!,
              0,
            );
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
        } else {
          final mode09Json = ref.read(technicalDataProvider).mode09Data;
          Map<String, String> parsedInfo = Mode09Parser.parse(
            cleanHex,
            mode09Json,
          );
          if (parsedInfo.isNotEmpty) {
            ref.read(vehicleInfoStateProvider.notifier).updateInfo(parsedInfo);
          }
        }
      }
      // === LÊ FALHAS CONFIRMADAS (Modo 03) ===
      else if (cleanHex.startsWith("43")) {
        List<String> dtcs = DtcParser.parse(cleanHex, "43");
        ref.read(dtcStateProvider.notifier).addCodes(dtcs, DtcStatus.confirmed);
      }
      // === LÊ FALHAS PENDENTES (Modo 07) ===
      else if (cleanHex.startsWith("47")) {
        List<String> dtcs = DtcParser.parse(cleanHex, "47");
        ref.read(dtcStateProvider.notifier).addCodes(dtcs, DtcStatus.pending);
      }
      // === LÊ FALHAS PERMANENTES (Modo 0A) ===
      else if (cleanHex.startsWith("4A")) {
        List<String> dtcs = DtcParser.parse(cleanHex, "4A");
        ref.read(dtcStateProvider.notifier).addCodes(dtcs, DtcStatus.permanent);
      }
      // === FREEZE FRAME (Modo 02) ===
      else if (cleanHex.startsWith("42")) {
        if (RegExp(r'42(00|20|40|60|80|A0|C0)00').hasMatch(cleanHex)) {
          final RegExp supportRegex = RegExp(
            r'42(00|20|40|60|80|A0|C0)00([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);
          for (final match in matches) {
            int basePid = int.parse(match.group(1)!, radix: 16);
            List<int> supported = Mode01Parser.parseSupportedPids(
              match.group(2)!,
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
      // === APAGA FALHAS (Modo 04) ===
      else if (cleanHex.startsWith("44") ||
          (_isClearingDTCs && rawResponse == "OK")) {
        _isClearingDTCs = false;
        _addLog("Memória da ECU apagada com sucesso!");
        ref.read(dtcStateProvider.notifier).clearCodes();
        Timer(const Duration(seconds: 2), () => scanAllFaults());
      }
    } finally {
      if (_isPollingEnabled && _commandQueue.isEmpty) {
        int userInterval = ref.read(pollingIntervalProvider);
        Duration delay = Duration(milliseconds: userInterval);

        final profile = ref.read(protocolProfileProvider);

        // PROTEÇÃO DE BARRAMENTO LENTO
        if (delay < profile.minPollingInterval) {
          delay = profile.minPollingInterval;
        }

        if (_pollingCooldown > delay) delay = _pollingCooldown;

        _cooldownTimer?.cancel();

        if (_isFastInitialPass) {
          _cooldownTimer = Timer(profile.minPollingInterval, () {
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
        if (ref.read(dtcStateProvider).isLoading) {
          ref.read(dtcStateProvider.notifier).setLoading(false);
          _addLog("Diagnóstico concluído com sucesso.");
        }
        if (ref.read(testResultsProvider.notifier).isLoading) {
          ref.read(testResultsProvider.notifier).setLoading(false);
          _addLog("Varredura de Modo 06 concluída naturalmente.");
        }
      }
    }
  }
}
