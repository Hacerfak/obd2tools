import 'dart:async';
import 'dart:collection';
import 'obd_connection.dart';
import '/parser/obd_parser.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../parser/parsers/mode_09_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';

class ObdManager {
  final ObdConnection connection;
  final WidgetRef ref;

  // Fila de comandos aguardando para serem enviados
  final Queue<String> _commandQueue = Queue<String>();

  // Buffer para juntar os pedaços de texto que chegam do scanner
  String _buffer = "";

  // Controle de estado para saber se o scanner está ocupado processando algo
  bool _isWaitingForResponse = false;

  // Novo Stream para a interface escutar os logs
  final _logStreamController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logStreamController.stream;

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

  // Dicionário com os nomes dos sensores mais comuns em português
  /* final Map<int, String> _pidNames = {
    // Grupo 01 a 20
    0x01: "Status dos Monitores de Emissão",
    0x03: "Status do Sistema de Combustível",
    0x04: "Carga Calculada do Motor",
    0x05: "Temperatura do Líquido de Arrefecimento",
    0x06: "Ajuste de Combustível a Curto Prazo (Banco 1)",
    0x07: "Ajuste de Combustível a Longo Prazo (Banco 1)",
    0x0B: "Pressão Absoluta do Coletor (MAP)",
    0x0C: "Rotação do Motor (RPM)",
    0x0D: "Velocidade do Veículo",
    0x0E: "Avanço do Ponto de Ignição",
    0x0F: "Temperatura do Ar de Admissão",
    0x10: "Taxa de Fluxo de Ar (MAF)",
    0x11: "Posição do Acelerador (TPS)",
    0x13: "Sensores de Oxigênio Presentes (Sonda Lambda)",
    0x1C: "Padrão OBD suportado",
    0x1F: "Tempo de Funcionamento do Motor",

    // Grupo 21 a 40
    0x21: "Distância Percorrida com Luz de Injeção Acesa",
    0x2E: "Purga Evaporativa Comandada",
    0x2F: "Nível do Tanque de Combustível",
    0x30: "Aquecimentos desde que os erros foram limpos",
    0x31: "Distância percorrida desde a limpeza de erros",
    0x32: "Pressão de Vapor do Sistema Evaporativo",
    0x33: "Pressão Atmosférica Absoluta",

    // Grupo 41 a 60
    0x41: "Status do Monitor no Ciclo de Direção Atual",
    0x42: "Tensão do Módulo de Controle (ECU)",
    0x43: "Valor Absoluto da Carga do Motor",
    0x44: "Relação Ar/Combustível Comandada",
    0x45: "Posição Relativa do Acelerador",
    0x46: "Temperatura do Ar Ambiente",
    0x47: "Posição Absoluta do Acelerador B",
    0x49: "Posição do Pedal do Acelerador D",
    0x4A: "Posição do Pedal do Acelerador E",
    0x4C: "Atuador do Acelerador Comandado",
    0x51: "Tipo de Combustível do Veículo",
    0x5C: "Temperatura do Óleo do Motor",
  }; */

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

    // Pergunta pelos sensores de 01 a 20
    //queueCommand("0100");
    // Pergunta pelos sensores de 21 a 40
    //queueCommand("0120");
    // Pergunta pelos sensores de 41 a 60
    //queueCommand("0140");

    // Vamos direto para o teste do Multi-PID com o carro ligado!
    // Enviamos o Modo 01, seguido dos 4 PIDs separados por espaço
    //queueCommand("01 04 05 0B 0C");
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

  /// Onde faremos a limpeza de erros e cálculos de PIDs
  /* void _handleCompleteResponse(String response) {
    if (response.contains("NO DATA") || response.contains("ERROR")) {
      _addLog("ALERTA: Erro ou sensor inexistente.");
      return;
    }

    // CORREÇÃO: Remove a palavra SEARCHING... e espaços em branco excedentes
    String cleanResponse = response.replaceAll("SEARCHING...", "").trim();

    // Intercepta a resposta dos mapas de bits para fazer a tradução humana
    if (cleanResponse.startsWith("41 00")) {
      _addLog(">>> Lendo Mapa de Sensores (01 a 20) <<<");
      _decodeBitmask(cleanResponse.replaceFirst("41 00", "").trim(), 0x00);
    } else if (cleanResponse.startsWith("41 20")) {
      _addLog(">>> Lendo Mapa de Sensores (21 a 40) <<<");
      _decodeBitmask(cleanResponse.replaceFirst("41 20", "").trim(), 0x20);
    } else if (cleanResponse.startsWith("41 40")) {
      _addLog(">>> Lendo Mapa de Sensores (41 a 60) <<<");
      _decodeBitmask(cleanResponse.replaceFirst("41 40", "").trim(), 0x40);
    } else {
      // Mantém imprimindo qualquer outra resposta normalmente
      _addLog("Recebido: $cleanResponse");
    }
  }

  /// Converte a resposta Hexadecimal da ECU em uma lista humana de sensores
  void _decodeBitmask(String hexData, int basePid) {
    // Remove os espaços do Hex (ex: "B8 3F A0 13" vira "B83FA013")
    String cleanHex = hexData.replaceAll(" ", "");

    if (cleanHex.length != 8) {
      _addLog("Aviso: Mapa de bits inválido ($cleanHex)");
      return;
    }

    // Converte os 4 bytes para um número inteiro longo
    int bitmask = int.parse(cleanHex, radix: 16);
    List<String> supportedSensors = [];

    // O mapa de bits tem 32 bits (4 bytes * 8 bits)
    for (int i = 0; i < 32; i++) {
      // Verifica da esquerda (maior bit) para a direita
      if ((bitmask & (1 << (31 - i))) != 0) {
        int pidVal = basePid + i + 1; // Qual é o número real do PID
        supportedPids.add(pidVal);
        String pidHex = pidVal
            .toRadixString(16)
            .padLeft(2, '0')
            .toUpperCase(); // Ex: 0C

        // Pega o nome do nosso dicionário ou exibe genérico
        String sensorName = _pidNames[pidVal] ?? "Sensor Específico ($pidHex)";
        supportedSensors.add("- $sensorName");
      }
    }

    // Joga a lista limpa e bonita na tela do app
    _addLog(supportedSensors.join('\n'));
  } */
  void discoverSupportedSensors() {
    ref.read(supportedPidsProvider.notifier).clear();
    queueCommand("0100"); // A faísca que inicia a auto-descoberta
  }

  void _handleCompleteResponse(String response) {
    if (response.contains("NO DATA") || response.contains("ERROR")) {
      _addLog("ALERTA: Erro ou dado inexistente.");
      return;
    }

    String rawResponse = response.replaceAll("SEARCHING...", "").trim();

    // Log para debug com o retorno bruto do ELM327
    //_addLog("ELM327: $rawResponse");

    if (rawResponse.startsWith("0") ||
        rawResponse.startsWith("41") ||
        rawResponse.startsWith("49")) {
      String cleanHex = ObdParser.cleanRawResponse(rawResponse);

      _addLog("=====================================");

      if (cleanHex.startsWith("41")) {
        String pidHex = cleanHex.substring(2, 4);

        // 1. Verifica se é uma resposta de Auto-Descoberta
        if (["00", "20", "40", "60", "80", "A0", "C0"].contains(pidHex)) {
          int basePid = int.parse(pidHex, radix: 16);
          // Pega apenas os 4 bytes da resposta
          String dataHex = cleanHex.length >= 12
              ? cleanHex.substring(4, 12)
              : cleanHex.substring(4);

          List<int> supported = Mode01Parser.parseSupportedPids(
            dataHex,
            basePid,
          );

          // Salva os sensores descobertos no Riverpod
          ref.read(supportedPidsProvider.notifier).addPids(supported);
          _addLog("=> Sensores Suportados Encontrados: $supported");

          // 2. O Dominó: Se o último sensor (ex: 0x20) estiver suportado, pede o próximo bloco!
          if (supported.contains(basePid + 0x20)) {
            String nextHex = (basePid + 0x20)
                .toRadixString(16)
                .padLeft(2, '0')
                .toUpperCase();
            queueCommand("01$nextHex"); // Pede o próximo (0120, 0140, etc)
          }
        } else {
          // 3. Se não for descoberta, é leitura normal de dados (RPM, Temp, etc)
          Map<String, ObdReadResult> parsedData = Mode01Parser.parse(cleanHex);

          if (parsedData.isEmpty) {
            _addLog("Aguardando pacote completo...");
          } else {
            ref.read(realTimeStateProvider.notifier).updateData(parsedData);
            parsedData.forEach((nome, resultado) {
              _addLog(
                "=> $nome: ${resultado.value.toStringAsFixed(1)} ${resultado.unit}",
              );
            });
          }
        }
      } else if (cleanHex.startsWith("49")) {
        Map<String, String> parsedInfo = Mode09Parser.parse(cleanHex);

        if (parsedInfo.isEmpty) {
          _addLog("Aguardando dados do veículo...");
        } else {
          // A MÁGICA AQUI: Injeta os dados no túnel do Modo 09!
          ref.read(vehicleInfoStateProvider.notifier).updateInfo(parsedInfo);

          parsedInfo.forEach((nome, valor) {
            _addLog("=> $nome: $valor");
          });
        }
      }

      _addLog("=====================================");
    } else {
      _addLog("Sistema: $rawResponse");
    }
  }
}
