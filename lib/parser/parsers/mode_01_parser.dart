import '../registries/mode_01_registry.dart';

// Classe que empacota o valor e a unidade original mantida intacta
class ObdReadResult {
  final double value;
  final String unit;

  ObdReadResult(this.value, this.unit);
}

class Mode01Parser {
  /// Lê o mapa de bits de auto-descoberta (PIDs 00, 20, 40, 60...)
  static List<int> parseSupportedPids(String dataHex, int basePid) {
    List<int> supported = [];

    // Precisamos de exatos 4 bytes (8 caracteres hexadecimais)
    if (dataHex.length < 8) return supported;

    // Converte os 8 caracteres em um número inteiro de 32 bits
    int bitmask = int.parse(dataHex.substring(0, 8), radix: 16);

    // O primeiro bit da esquerda (maior valor) representa o basePid + 1.
    int mask = 0x80000000;

    for (int i = 1; i <= 32; i++) {
      // Se o bit estiver ligado (1), o sensor existe no carro!
      if ((bitmask & mask) != 0) {
        supported.add(basePid + i);
      }
      // Empurra a máscara de leitura para o próximo bit à direita
      mask = mask >> 1;
    }

    return supported;
  }

  /// Lê uma string hexadecimal contínua sem espaços (ex: "410C1AF8410D00")
  static Map<String, ObdReadResult> parse(String cleanHex) {
    Map<String, ObdReadResult> results = {};

    // Acha onde a resposta de dados (41) realmente começa
    int cursor = cleanHex.indexOf("41");
    if (cursor == -1) return results; // Não é uma resposta válida

    cursor += 2; // Pula o "41" inicial

    // Continua lendo os sensores engatados um no outro até o texto acabar
    while (cursor + 2 <= cleanHex.length) {
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      int pidId = int.parse(pidHex, radix: 16);
      cursor += 2; // Pula o byte do PID

      // Conhecemos esse sensor?
      if (pidRegistry.containsKey(pidId)) {
        final pid = pidRegistry[pidId]!;
        int dataChars =
            pid.expectedBytes *
            2; // Quantos caracteres hexadecimais tem a resposta?

        if (cursor + dataChars <= cleanHex.length) {
          String dataHex = cleanHex.substring(cursor, cursor + dataChars);

          List<int> bytes = [];
          for (int j = 0; j < dataChars; j += 2) {
            bytes.add(int.parse(dataHex.substring(j, j + 2), radix: 16));
          }

          results[pid.name] = ObdReadResult(pid.calculate(bytes), pid.unit);
          cursor += dataChars; // Avança o cursor pulando os dados lidos
        } else {
          break; // Os dados foram cortados pelo Bluetooth, encerra a leitura.
        }
      } else {
        // Se batermos de frente com um PID desconhecido ou lixo/padding da ECU (00, AA)
        // abortamos para não ler as coisas fora de sincronia.
        break;
      }
    }

    return results;
  }
}
