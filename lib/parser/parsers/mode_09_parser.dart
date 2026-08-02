import '../registries/mode_09_registry.dart';

class Mode09Parser {
  /// Lê qualquer informação do Modo 09 com base no Dicionário
  static Map<String, String> parse(String cleanHex) {
    Map<String, String> results = {};

    // Localiza o início da resposta do Modo 09
    int cursor = cleanHex.indexOf("49");
    if (cursor == -1) return results;
    cursor += 2; // Pula o "49"

    // Captura o PID (ex: 02, 04, 0A)
    if (cursor + 2 > cleanHex.length) return results;
    String pidHex = cleanHex.substring(cursor, cursor + 2);
    int pidId = int.parse(pidHex, radix: 16);
    cursor += 2;

    // Se o PID estiver mapeado no nosso dicionário, mandamos ele decodificar
    if (mode09Registry.containsKey(pidId)) {
      String dataHex = cleanHex.substring(cursor);
      String decodedValue = mode09Registry[pidId]!.decode(dataHex);

      if (decodedValue.isNotEmpty) {
        results[mode09Registry[pidId]!.name] = decodedValue;
      }
    }

    return results;
  }
}
