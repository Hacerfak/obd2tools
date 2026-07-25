import '../registries/mode_01_registry.dart';

// Classe que empacota o valor e a unidade
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

  static Map<String, ObdReadResult> parse(String cleanHex) {
    Map<String, ObdReadResult> results = {};

    // Confirma se é Modo 01 (Sempre começa com 41)
    if (!cleanHex.startsWith("41") || cleanHex.length < 6) return results;

    int cursor = 2; // Pula o "41"

    while (cursor < cleanHex.length) {
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      int pidCode = int.parse(pidHex, radix: 16);
      cursor += 2;

      if (pidRegistry.containsKey(pidCode)) {
        final pidConfig = pidRegistry[pidCode]!;
        int charsToRead = pidConfig.expectedBytes * 2;

        if (cursor + charsToRead <= cleanHex.length) {
          String dataHex = cleanHex.substring(cursor, cursor + charsToRead);

          List<int> bytes = [];
          for (int i = 0; i < dataHex.length; i += 2) {
            bytes.add(int.parse(dataHex.substring(i, i + 2), radix: 16));
          }

          double finalValue = pidConfig.calculate(bytes);
          results[pidConfig.name] = ObdReadResult(finalValue, pidConfig.unit);

          cursor += charsToRead;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return results;
  }
}
