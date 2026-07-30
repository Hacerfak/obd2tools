class ObdParser {
  /// Limpa a string bruta retornada pelo ELM327 usando Tokenização
  static String cleanRawResponse(String rawData) {
    String normalized = rawData.replaceAll(RegExp(r'\s+'), ' ');
    List<String> tokens = normalized.split(' ');
    List<String> hexBytes = [];

    bool foundStart = false;

    for (String token in tokens) {
      token = token.trim();
      if (token.isEmpty) continue;

      if (RegExp(r'^[0-9A-Fa-f]:$').hasMatch(token)) continue;
      if (token.length == 3 && RegExp(r'^[0-9A-Fa-f]{3}$').hasMatch(token)) {
        continue;
      }

      if (!foundStart) {
        if (token == "41" || token == "49" || token == "43") {
          foundStart = true;
          hexBytes.add(token);
        }
      } else {
        if (token.length == 2) {
          hexBytes.add(token);
        }
      }
    }

    String cleanHex = hexBytes.join("");

    while (cleanHex.endsWith("AA") && cleanHex.length > 2) {
      cleanHex = cleanHex.substring(0, cleanHex.length - 2);
    }

    return cleanHex;
  }
}
