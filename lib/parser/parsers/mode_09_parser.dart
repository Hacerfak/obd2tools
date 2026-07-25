import '../mode_09_registry.dart';

class Mode09Parser {
  static Map<String, String> parse(String cleanHex) {
    Map<String, String> results = {};

    // Confirma se é Modo 09 (Sempre começa com 49)
    if (!cleanHex.startsWith("49") || cleanHex.length < 6) return results;

    String pidHex = cleanHex.substring(2, 4);
    int pidCode = int.parse(pidHex, radix: 16);

    if (mode09Registry.containsKey(pidCode)) {
      final pidConfig = mode09Registry[pidCode]!;

      // Respostas do modo 09 geralmente têm 1 byte extra indicando a contagem
      // de mensagens (ex: 49 02 01...). Portanto, os dados reais começam no índice 6.
      String dataHex = cleanHex.length > 6 ? cleanHex.substring(6) : "";

      String decodedValue = pidConfig.decode(dataHex);
      results[pidConfig.name] = decodedValue.isNotEmpty
          ? decodedValue
          : "Sem dados";
    }

    return results;
  }
}
