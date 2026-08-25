import '../registries/mode_09_registry.dart';

class Mode09Parser {
  /// Lê qualquer informação do Modo 09 utilizando o JSON do Modo 09 localizado
  static Map<String, String> parse(
    String cleanHex,
    Map<String, dynamic> mode09Json,
  ) {
    Map<String, String> results = {};

    int cursor = cleanHex.indexOf("49");
    if (cursor == -1) return results;
    cursor += 2; // Pula o "49"

    if (cursor + 2 > cleanHex.length) return results;
    String pidHex = cleanHex.substring(cursor, cursor + 2);
    int pidId = int.parse(pidHex, radix: 16);
    cursor += 2;

    if (mode09Registry.containsKey(pidId)) {
      String dataHex = cleanHex.substring(cursor);

      final pidsData = (mode09Json['pids'] as Map<String, dynamic>?) ?? {};
      final pidKey = pidHex.toUpperCase();
      final pidInfo = pidsData[pidKey] as Map<String, dynamic>?;

      final pidName = pidInfo?['name'] ?? "PID 0x$pidHex";
      final labels = (mode09Json['labels'] as Map<String, dynamic>?) ?? {};

      String decodedValue = mode09Registry[pidId]!.decode(dataHex, labels);

      if (decodedValue.isNotEmpty) {
        results[pidName] = decodedValue;
      }
    }

    return results;
  }
}
