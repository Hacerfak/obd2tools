import '../registries/mode_01_registry.dart';

// Classe que empacota o valor e a unidade
class ObdReadResult {
  final double value;
  final String unit;

  ObdReadResult(this.value, this.unit);
}

class Mode01Parser {
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
