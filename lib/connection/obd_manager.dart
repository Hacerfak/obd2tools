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

  // Fila de comandos aguardando para serem enviados
  final Queue<String> _commandQueue = Queue<String>();

  // Buffer para juntar os pedaços de texto que chegam do scanner
  String _buffer = "";

  Timer? _ecuRetryTimer;

  // Controle de estado para saber se o scanner está ocupado processando algo
  bool _isWaitingForResponse = false;

  bool _isClearingDTCs = false;

  // Novo Stream para a interface escutar os logs
  final _logStreamController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logStreamController.stream;

  bool _isPollingEnabled = false;
  List<int> _activePollingPids = [];

  int _pollingIndex = 0;

  // --- CONTROLES DE COOLDOWN ---
  Duration _pollingCooldown = Duration.zero;
  bool _isFastInitialPass = false;
  Timer? _cooldownTimer;

  ObdManager({required this.connection, required this.ref}) {
    // Fica escutando os dados puros que vêm do Bluetooth
    connection.dataStream.listen(_onDataReceived);
  }

  // --- NOVA VARREDURA COMPLETA ---
  void scanAllFaults() {
    _isPollingEnabled = false;
    _commandQueue.clear();
    ref.read(dtcStateProvider.notifier).clearCodes();
    ref.read(dtcStateProvider.notifier).setLoading(true);

    queueCommand("03"); // Pede Confirmadas
    queueCommand("07"); // Pede Pendentes
    queueCommand("0A"); // Pede Permanentes
    queueCommand("020000"); // Pede Freeze Frame
  }

  // Dispara a caçada completa do Freeze Frame (Frame 00)
  void readFreezeFrame() {
    ref.read(freezeFrameProvider.notifier).clear();
    ref.read(freezeFrameProvider.notifier).setLoading(true);
    queueCommand("020000"); // 02 (Modo) 00 (PIDs Suportados) 00 (Frame 00)
  }

  // Comandos fáceis para a interface chamar
  void readDTCs() {
    ref.read(dtcStateProvider.notifier).setLoading(true);
    queueCommand("03");
  }

  void clearDTCs() {
    _isClearingDTCs = true; // Avisa que o próximo "OK" é nosso!
    queueCommand("04");
  }

  void _addLog(String message) {
    _logStreamController.add(message);
    print(message); // Mantém no console também
  }

  /// Adiciona um comando na fila (ex: "010C" para RPM)
  void queueCommand(String command) {
    _commandQueue.add(command);
    _processQueue(); // Tenta processar a fila assim que um comando entra
  }

  // Nova lista para guardar o que o carro suporta
  final List<int> supportedPids = [];

  // --- INTELIGÊNCIA DE VARREDURA (POLLING) CENTRALIZADA ---
  void setPollingPids(
    List<int> pids, {
    Duration cooldown = Duration.zero,
    bool fastInitialPass = false,
  }) {
    _activePollingPids = pids;
    _isPollingEnabled = pids.isNotEmpty;
    _pollingIndex = 0;

    // Atualiza as regras de tempo e cancela timers antigos
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
        _pollingIndex = 0; // Volta pro início
        _isFastInitialPass = false; // FIM DA VOLTA RÁPIDA! Desliga o turbo.
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

  /// Rotina de inicialização baseada nos comandos AT
  void initializeScanner() {
    // 1. Reseta o chip (Zera tudo)
    queueCommand("AT Z");

    // 2. Desliga o eco (O ELM para de repetir o que nós digitamos)
    queueCommand("AT E0");

    // 3. Desliga quebras de linha inúteis
    queueCommand("AT L0");

    // --- O PACOTE DE OTIMIZAÇÃO EXTREMA ---
    // 4. Desliga os espaços em branco (Economiza ~30% de banda Bluetooth)
    queueCommand("AT S0");

    // 5. Desliga os cabeçalhos de rede CAN (Remove lixo inútil da ECU)
    queueCommand("AT H0");

    // 6. Adaptive Timing Nível 2 (Para de esperar atoa pelas outras ECUs)
    queueCommand("AT AT2");
    // --------------------------------------

    // 7. Protocolo OBD automático (descobre a Montana sozinho)
    queueCommand("AT SP 0");

    // 8. Verificar a voltagem da bateria do carro
    queueCommand("AT RV");

    // 9. Descrição do protocolo selecionado automaticamente
    queueCommand("AT DP");
  }

  /// Verifica se pode enviar o próximo comando da fila
  void _processQueue() {
    if (_isWaitingForResponse || _commandQueue.isEmpty) {
      return; // O scanner está ocupado ou não há nada para enviar
    }

    _isWaitingForResponse = true;
    String nextCommand = _commandQueue.removeFirst();

    // Envia o comando para o scanner via Bluetooth
    print("=== Command: '$nextCommand' ===");
    connection.sendCommand(nextCommand);
  }

  /// Lida com a chegada de dados em tempo real
  void _onDataReceived(String data) {
    _buffer += data;
    if (_buffer.contains(">")) {
      // Limpa o sinal de pronto, espaços extras e os "quadradinhos" (Quebras de linha)
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

  void reset() {
    _commandQueue.clear(); // Limpa comandos velhos presos na fila
    _buffer = ""; // Limpa lixos de texto recebidos pela metade
    _isWaitingForResponse = false; // Destrava o envio de novos comandos!
    _ecuRetryTimer?.cancel(); // Para qualquer tentativa de reconexão zumbi
    _isPollingEnabled = false;
    _cooldownTimer?.cancel();
    // Opcional, mas recomendado: limpa os dados antigos da tela
    ref.read(realTimeStateProvider.notifier).clearData();
  }

  void discoverSupportedSensors() {
    ref.read(supportedPidsProvider.notifier).clear();
    queueCommand("0100"); // A faísca que inicia a auto-descoberta
  }

  void _handleCompleteResponse(String response) {
    print("=== RAW DO ELM: '$response' ===");

    try {
      if (response.contains("NO DATA") || response.contains("ERROR")) {
        _addLog("ALERTA: Erro ou dado inexistente.");
        return;
      }

      String rawResponse = response.replaceAll("SEARCHING...", "").trim();

      // --- 1. RESTAURADO: DETECÇÃO DE CHAVE DESLIGADA / ECU OFFLINE ---
      if (rawResponse.contains("UNABLE TO CONNECT") ||
          rawResponse.contains("CAN ERROR")) {
        _addLog("ECU não responde. A chave está na ignição?");
        ref
            .read(connectionStateProvider.notifier)
            .updateState(AppConnectionState.waitingForEcu);

        _ecuRetryTimer?.cancel();
        _ecuRetryTimer = Timer(const Duration(seconds: 3), () {
          _addLog("Tentando reconectar à ECU...");
          // Aqui re-enviamos o comando inicial para tentar acordar a injeção
          queueCommand("0100");
        });
        return;
      }

      String cleanHex = ObdParser.cleanRawResponse(rawResponse);
      print("=== CLEAN HEX: '$cleanHex' ===");

      // --- 2. RESTAURADO: AVISA A TELA QUE O CARRO ESTÁ ONLINE ---
      // Se a ECU respondeu com 41, 43, 44 ou 49, é porque o carro está 100% conectado!
      if (cleanHex.startsWith("41") ||
          cleanHex.startsWith("43") ||
          cleanHex.startsWith("49") ||
          cleanHex.startsWith("44")) {
        final currentState = ref.read(connectionStateProvider);
        // Se estava esperando, muda para descobrindo sensores!
        if (currentState == AppConnectionState.waitingForEcu ||
            currentState == AppConnectionState.connectingBluetooth) {
          _ecuRetryTimer?.cancel();
          ref
              .read(connectionStateProvider.notifier)
              .updateState(AppConnectionState.discoveringSensors);
          _addLog("Conexão estabelecida! Mapeando sensores...");
        }
      }

      // 3. ROTEAMENTO DE DADOS (Modo 01, 03, 04, 09)
      if (cleanHex.startsWith("41")) {
        // CORREÇÃO: Usar startsWith no lugar de contains para evitar falsos positivos!
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
              // Mapeamento Acabou!
              final currentState = ref.read(connectionStateProvider);
              if (currentState == AppConnectionState.discoveringSensors) {
                ref
                    .read(connectionStateProvider.notifier)
                    .updateState(AppConnectionState.ready);
              }
            }
          }
        } else {
          // SE NÃO É MAPEAMENTO, ENTÃO É DADO REAL PARA OS GRÁFICOS!
          Map<String, ObdReadResult> parsedData = Mode01Parser.parse(cleanHex);

          if (parsedData.isNotEmpty) {
            // Se quiser ver no console os sensores atualizando, descomente a linha abaixo:
            // print("ATUALIZANDO TELA: ${parsedData.keys}");
            ref.read(realTimeStateProvider.notifier).updateData(parsedData);
          }
        }
      }
      // MODO 02 - FREEZE FRAME (DADOS CONGELADOS)
      else if (cleanHex.startsWith("42")) {
        // Se a resposta for o mapeamento de PIDs suportados (00, 20, 40...)
        if (cleanHex.contains("420000") ||
            cleanHex.contains("422000") ||
            cleanHex.contains("424000")) {
          // O Regex procura: 42 + PID (00, 20...) + Frame (00) + 8 chars de dados
          final RegExp supportRegex = RegExp(
            r'42(00|20|40|60|80|A0|C0)00([0-9A-F]{8})',
          );
          final matches = supportRegex.allMatches(cleanHex);

          for (final match in matches) {
            String pidHex = match.group(1)!;
            String dataHex = match.group(2)!;

            int basePid = int.parse(pidHex, radix: 16);

            // Reutilizamos a genialidade matemática do Modo 01!
            List<int> supported = Mode01Parser.parseSupportedPids(
              dataHex,
              basePid,
            );

            // Coloca os pedidos de dados na fila de comandos
            for (int pid in supported) {
              // Pulamos os PIDs de paginação (0x20, 0x40) e o PID 02 (que é apenas o código da falha repetido)
              if (pid % 0x20 != 0 && pid != 0x02) {
                String hexReq = pid
                    .toRadixString(16)
                    .padLeft(2, '0')
                    .toUpperCase();
                queueCommand(
                  "02${hexReq}00",
                ); // Pede PID específico do Frame 00
              }
            }

            // Tem mais páginas para descobrir?
            if (supported.contains(basePid + 0x20)) {
              String nextGroupHex = (basePid + 0x20)
                  .toRadixString(16)
                  .padLeft(2, '0')
                  .toUpperCase();
              queueCommand("02${nextGroupHex}00");
            }
          }
        }
        // Se for resposta de um sensor do Freeze Frame
        else {
          Map<String, ObdReadResult> parsedData = Mode02Parser.parse(cleanHex);
          if (parsedData.isNotEmpty) {
            ref.read(freezeFrameProvider.notifier).addData(parsedData);
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
        // A lógica de PIDs suportados do Modo 02 que criamos antes continua aqui
        if (cleanHex.contains("420000") ||
            cleanHex.contains("422000") ||
            cleanHex.contains("424000")) {
          // ... (mantém a rotina do supportRegex que você já tem)
        } else {
          Map<String, ObdReadResult> parsedData = Mode02Parser.parse(cleanHex);
          if (parsedData.isNotEmpty) {
            // Agora salvamos direto dentro do DTC Confirmado!
            ref.read(dtcStateProvider.notifier).attachFreezeFrame(parsedData);
          }
        }
      }
      // APAGA FALHAS (Modo 04)
      else if (cleanHex.startsWith("44") ||
          (_isClearingDTCs && rawResponse == "OK")) {
        _isClearingDTCs = false; // Desliga a flag
        _addLog("Memória da ECU apagada com sucesso!");
        ref.read(dtcStateProvider.notifier).clearCodes();
        Timer(const Duration(seconds: 2), () => scanAllFaults());
      }
    } finally {
      if (_isPollingEnabled && _commandQueue.isEmpty) {
        // Se estamos no turbo inicial OU não há cooldown (HUD/Detalhes), pede já!
        if (_isFastInitialPass || _pollingCooldown == Duration.zero) {
          _triggerNextPollingRequest();
        } else {
          // Senão, dá um respiro para a CPU e pro carro
          _cooldownTimer?.cancel();
          _cooldownTimer = Timer(_pollingCooldown, () {
            if (_isPollingEnabled && _commandQueue.isEmpty) {
              _triggerNextPollingRequest();
            }
          });
        }
      }
      // CORREÇÃO: Se não estamos em polling (estamos lendo falhas) e a fila esvaziou, o diagnóstico ACABOU!
      else if (!_isPollingEnabled && _commandQueue.isEmpty) {
        ref.read(dtcStateProvider.notifier).setLoading(false);
        _addLog("Diagnóstico concluído com sucesso.");
      }
    }
  }
}
