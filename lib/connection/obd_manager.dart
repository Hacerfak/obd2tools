import 'dart:async';
import 'dart:collection';
import 'obd_connection.dart';
import '/parser/obd_parser.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../parser/registries/mode_01_registry.dart';
import '../parser/parsers/mode_09_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';

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

  // Novo Stream para a interface escutar os logs
  final _logStreamController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logStreamController.stream;

  bool _hudModeEnabled = false;
  List<int> _hudActivePids = [];
  int _slowPidIndex = 0;

  ObdManager({required this.connection, required this.ref}) {
    // Fica escutando os dados puros que vêm do Bluetooth
    connection.dataStream.listen(_onDataReceived);
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

  // --- INTELIGÊNCIA DO HUD ---
  void setHudMode(List<int> pids) {
    _hudActivePids = pids;
    _hudModeEnabled = pids.isNotEmpty;

    // Se ativou e a fila está livre, dá o primeiro tiro!
    if (_hudModeEnabled && _commandQueue.isEmpty && !_isWaitingForResponse) {
      _triggerNextHudRequest();
    }
  }

  void _triggerNextHudRequest() {
    if (!_hudModeEnabled || _hudActivePids.isEmpty) return;

    // NOVO: Busca dinamicamente no registro quem é rápido e quem é lento!
    List<int> currentFast = _hudActivePids
        .where((pid) => pidRegistry[pid]?.isFast == true)
        .toList();
    List<int> currentSlow = _hudActivePids
        .where((pid) => pidRegistry[pid]?.isFast != true)
        .toList();

    // Sempre pede os valores rápidos!
    List<int> pidsToRequest = List.from(currentFast);

    // Revezamento: Pede APENAS 1 valor lento por ciclo
    if (currentSlow.isNotEmpty) {
      pidsToRequest.add(currentSlow[_slowPidIndex]);
      _slowPidIndex = (_slowPidIndex + 1) % currentSlow.length;
    }

    if (pidsToRequest.length > 6) {
      pidsToRequest = pidsToRequest.sublist(0, 6);
    }

    String multiCommand = "01";
    for (var pid in pidsToRequest) {
      multiCommand += pid.toRadixString(16).padLeft(2, '0').toUpperCase();
    }

    queueCommand(multiCommand);
  }

  /// Rotina de inicialização baseada nos comandos AT
  void initializeScanner() {
    // 1. Reseta o chip
    queueCommand("AT Z");
    // 2. Desliga o eco (para economizar banda)
    queueCommand("AT E0");
    // 3. Desliga quebras de linha
    queueCommand("AT L0");
    // 4. Protocolo OBD automático (descobre a Montana sozinho)
    queueCommand("AT SP 0");
    // 5. Verificar a voltagem da bateria do carro
    queueCommand("AT RV");
    // 6. Descrição do protocolo selecionado automaticamente
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
    _hudModeEnabled = false;
    // Opcional, mas recomendado: limpa os dados antigos da tela
    ref.read(realTimeStateProvider.notifier).clearData();
  }

  void discoverSupportedSensors() {
    ref.read(supportedPidsProvider.notifier).clear();
    queueCommand("0100"); // A faísca que inicia a auto-descoberta
  }

  void _handleCompleteResponse(String response) {
    try {
      if (response.contains("NO DATA") || response.contains("ERROR")) {
        _addLog("ALERTA: Erro ou dado inexistente.");
        return; // Retorna cedo, mas o "finally" vai garantir o próximo tiro!
      }

      String rawResponse = response.replaceAll("SEARCHING...", "").trim();

      // 1. DETECÇÃO DE CHAVE DESLIGADA / ECU OFFLINE
      if (rawResponse.contains("UNABLE TO CONNECT") ||
          rawResponse.contains("CAN ERROR")) {
        _addLog("ECU não responde. A chave está na ignição?");
        ref
            .read(connectionStateProvider.notifier)
            .updateState(AppConnectionState.waitingForEcu);

        _ecuRetryTimer?.cancel();
        _ecuRetryTimer = Timer(const Duration(seconds: 3), () {
          _addLog("Tentando reconectar à ECU...");
          discoverSupportedSensors();
        });
        return;
      }

      // 2. SE SUCESSO E AINDA NÃO ESTÁ MARCADO COMO CONECTADO
      if (rawResponse.startsWith("41 00") || rawResponse.startsWith("4100")) {
        _ecuRetryTimer?.cancel();
        ref
            .read(connectionStateProvider.notifier)
            .updateState(AppConnectionState.connected);
      }

      // 3. PARSER DOS DADOS
      if (rawResponse.startsWith("0") ||
          rawResponse.startsWith("41") ||
          rawResponse.startsWith("49")) {
        String cleanHex = ObdParser.cleanRawResponse(rawResponse);

        if (cleanHex.startsWith("41")) {
          String pidHex = cleanHex.substring(2, 4);

          if (["00", "20", "40", "60", "80", "A0", "C0"].contains(pidHex)) {
            int basePid = int.parse(pidHex, radix: 16);
            String dataHex = cleanHex.length >= 12
                ? cleanHex.substring(4, 12)
                : cleanHex.substring(4);
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
            }
          } else {
            Map<String, ObdReadResult> parsedData = Mode01Parser.parse(
              cleanHex,
            );
            if (parsedData.isNotEmpty) {
              ref.read(realTimeStateProvider.notifier).updateData(parsedData);
            }
          }
        } else if (cleanHex.startsWith("49")) {
          Map<String, String> parsedInfo = Mode09Parser.parse(cleanHex);
          if (parsedInfo.isNotEmpty) {
            ref.read(vehicleInfoStateProvider.notifier).updateInfo(parsedInfo);
          }
        }
      }
    } finally {
      // O SEGREDO MÁXIMO: Aconteça o que acontecer (erro, sucesso, dados falsos),
      // se o usuário estiver na tela do HUD e a fila zerar, nós atiramos de novo imediatamente!
      if (_hudModeEnabled && _commandQueue.isEmpty) {
        _triggerNextHudRequest();
      }
    }
  }
}
