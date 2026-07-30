class DtcParser {
  // Agora recebe qual cabeçalho (header) procurar!
  static List<String> parse(String cleanHex, String expectedHeader) {
    List<String> dtcs = [];

    int cursor = cleanHex.indexOf(expectedHeader);
    if (cursor == -1) return dtcs;

    String data = cleanHex.substring(cursor + 2);

    if (data == "00" || data.isEmpty) return dtcs;

    if (data.length % 4 == 2) {
      data = data.substring(2);
    }

    // Lê os códigos de falha de 2 em 2 bytes (4 caracteres hexadecimais)
    for (int i = 0; i < data.length; i += 4) {
      if (i + 4 > data.length) break;

      String codeHex = data.substring(i, i + 4);

      if (codeHex == "0000" || codeHex.contains("AA")) continue;

      String firstChar = codeHex[0].toUpperCase();
      String remaining = codeHex.substring(1);

      String prefix = "";

      switch (firstChar) {
        case '0':
          prefix = "P0";
          break;
        case '1':
          prefix = "P1";
          break;
        case '2':
          prefix = "P2";
          break;
        case '3':
          prefix = "P3";
          break;
        case '4':
          prefix = "C0";
          break;
        case '5':
          prefix = "C1";
          break;
        case '6':
          prefix = "C2";
          break;
        case '7':
          prefix = "C3";
          break;
        case '8':
          prefix = "B0";
          break;
        case '9':
          prefix = "B1";
          break;
        case 'A':
          prefix = "B2";
          break;
        case 'B':
          prefix = "B3";
          break;
        case 'C':
          prefix = "U0";
          break;
        case 'D':
          prefix = "U1";
          break;
        case 'E':
          prefix = "U2";
          break;
        case 'F':
          prefix = "U3";
          break;
        default:
          prefix = "P0";
      }

      dtcs.add("$prefix$remaining");
    }

    return dtcs;
  }
}
