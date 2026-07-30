import '../registries/mode_01_registry.dart';
import 'mode_01_parser.dart'; // Para reutilizar a classe ObdReadResult

class Mode02Parser {
  /// Lê a string contínua do Freeze Frame (ex: 42 0C 00 1A F8)
  static Map<String, ObdReadResult> parse(String cleanHex) {
    Map<String, ObdReadResult> results = {};

    int cursor = cleanHex.indexOf("42");
    if (cursor == -1) return results;

    cursor += 2; // Pula o cabeçalho "42"

    // Continua lendo até a string acabar
    while (cursor + 4 <= cleanHex.length) {
      // +4 porque precisa ter o PID(2) e o Frame(2)
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      int pidId = int.parse(pidHex, radix: 16);
      cursor += 2; // Pula o byte do PID

      // Pula o byte do Frame (ex: 00)
      cursor += 2;

      if (pidRegistry.containsKey(pidId)) {
        final pid = pidRegistry[pidId]!;
        int dataChars = pid.expectedBytes * 2;

        if (cursor + dataChars <= cleanHex.length) {
          String dataHex = cleanHex.substring(cursor, cursor + dataChars);

          List<int> bytes = [];
          for (int j = 0; j < dataChars; j += 2) {
            bytes.add(int.parse(dataHex.substring(j, j + 2), radix: 16));
          }

          results[pid.name] = ObdReadResult(pid.calculate(bytes), pid.unit);
          cursor += dataChars; // Avança o cursor
        } else {
          break; // Fim inesperado da string
        }
      } else {
        break; // PID Desconhecido, aborta a janela deslizante
      }
    }

    return results;
  }
}
