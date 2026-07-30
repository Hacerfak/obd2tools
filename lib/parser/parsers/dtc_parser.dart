class DtcParser {
  static List<String> parse(String cleanHex) {
    List<String> dtcs = [];

    int cursor = cleanHex.indexOf("43");
    if (cursor == -1) return dtcs;

    String data = cleanHex.substring(cursor + 2);

    if (data == "00" || data.isEmpty) return dtcs;

    // --- O PULO DO GATO PARA A MONTANA (E OUTROS ISO/KWP) ---
    // Se a quantidade de caracteres que sobrou na string dividida por 4
    // tiver resto 2 (ex: 6 caracteres -> 4 de erro + 2 de contador),
    // nós pulamos o primeiro byte (2 caracteres) que é a contagem!
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
