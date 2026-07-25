import 'pid_registry.dart';

class ObdReadResult {
  final double value;
  final String unit;

  ObdReadResult(this.value, this.unit);
}

class ObdParser {
  /// Passo 1: Limpa a string bruta retornada pelo ELM327
  static String cleanRawResponse(String rawData) {
    // 1. Troca qualquer tipo de espaço bizarro do Bluetooth por um espaço simples
    String normalized = rawData.replaceAll(RegExp(r'\s+'), ' ');

    // 2. Separa a string inteira em "bloquinhos" (tokens) usando os espaços
    List<String> tokens = normalized.split(' ');
    List<String> hexBytes = [];

    bool foundStart = false;

    // 3. Avalia cada bloquinho individualmente
    for (String token in tokens) {
      token = token.trim();
      if (token.isEmpty) continue;

      // Ignora os marcadores de linha do CAN Bus (ex: "0:", "1:", "A:")
      if (RegExp(r'^[0-9A-Fa-f]:$').hasMatch(token)) continue;

      // Ignora o tamanho total do pacote (ex: "014", "083" - sempre 3 caracteres)
      if (token.length == 3 && RegExp(r'^[0-9A-Fa-f]{3}$').hasMatch(token))
        continue;

      // Procura o INÍCIO VERDADEIRO (O primeiro 41, 43 ou 49 que aparecer)
      if (!foundStart) {
        if (token == "41" || token == "49" || token == "43") {
          foundStart = true;
          hexBytes.add(token);
        }
      } else {
        // Depois que achou o início, adiciona apenas os bytes úteis (pares hexadecimais)
        if (token.length == 2) {
          hexBytes.add(token);
        }
      }
    }

    // 4. Junta tudo em uma string limpa
    String cleanHex = hexBytes.join("");

    // 5. Remove os bytes nulos ("AA") que o CAN adiciona no final
    while (cleanHex.endsWith("AA") && cleanHex.length > 2) {
      cleanHex = cleanHex.substring(0, cleanHex.length - 2);
    }

    return cleanHex;
  }

  /// Analisa as respostas do Modo 09 (Informações do Veículo)
  static String parseVehicleInfo(String cleanHex) {
    // Respostas do Modo 09 sempre começam com 49
    if (!cleanHex.startsWith("49") || cleanHex.length < 6) return "";

    String pidHex = cleanHex.substring(2, 4);

    // PID 02 = VIN (Número do Chassi)
    if (pidHex == "02") {
      // O cabeçalho geralmente é "49 02 01" (01 indica o número de mensagens)
      // O restante da string são os caracteres do Chassi em formato Hex.
      String asciiHex = cleanHex.length > 6 ? cleanHex.substring(6) : "";
      String vin = "";

      // Converte cada par de Hexadecimal de volta para texto (ASCII)
      for (int i = 0; i < asciiHex.length - 1; i += 2) {
        int charCode = int.parse(asciiHex.substring(i, i + 2), radix: 16);
        // Filtra apenas caracteres imprimíveis válidos
        if (charCode >= 32 && charCode <= 126) {
          vin += String.fromCharCode(charCode);
        }
      }
      return vin.isNotEmpty ? vin : "Falha ao decodificar VIN";
    }

    return "PID do Modo 09 não suportado ainda.";
  }

  /// Passo 2: Analisa a string limpa e retorna um mapa com os valores já calculados
  static Map<String, ObdReadResult> parseRealTimeData(String cleanHex) {
    Map<String, ObdReadResult> results = {};

    // A string deve começar com "41" e ter pelo menos 6 caracteres (Modo + PID + 1 Byte)
    if (!cleanHex.startsWith("41") || cleanHex.length < 6) return results;

    int cursor = 2; // Pula o "41" inicial

    while (cursor < cleanHex.length) {
      // Lê os próximos 2 caracteres como o código do PID (Ex: "0C" para RPM)
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      int pidCode = int.parse(pidHex, radix: 16);
      cursor += 2; // Avança o cursor

      // Verifica se o carro enviou um PID que está no nosso dicionário
      if (pidRegistry.containsKey(pidCode)) {
        final pidConfig = pidRegistry[pidCode]!;

        // 1 byte hexadecimal = 2 caracteres na string (Ex: "F8")
        int charsToRead = pidConfig.expectedBytes * 2;

        // Previne travamentos caso a resposta da ECU venha cortada pela metade
        if (cursor + charsToRead <= cleanHex.length) {
          String dataHex = cleanHex.substring(cursor, cursor + charsToRead);

          // Transforma a string recortada (Ex: "0EA0") em uma lista de bytes inteiros
          List<int> bytes = [];
          for (int i = 0; i < dataHex.length; i += 2) {
            bytes.add(int.parse(dataHex.substring(i, i + 2), radix: 16));
          }

          // A MÁGICA: Executa a fórmula matemática injetada lá no nosso dicionário!
          double finalValue = pidConfig.calculate(bytes);

          // Salva o resultado final amigável
          results[pidConfig.name] = ObdReadResult(finalValue, pidConfig.unit);

          cursor += charsToRead; // Avança o cursor para o próximo sensor
        } else {
          break; // O pacote acabou inesperadamente
        }
      } else {
        // Se a ECU enviou um PID desconhecido, não sabemos quantos bytes pular.
        // Interrompemos a leitura para não ler o "Byte B" como se fosse outro PID.
        break;
      }
    }

    return results;
  }
}
