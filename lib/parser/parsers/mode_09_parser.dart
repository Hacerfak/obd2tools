class Mode09Parser {
  /// Lê informações do veículo (como o Chassi - VIN)
  static Map<String, String> parse(String cleanHex) {
    Map<String, String> results = {};

    // Localiza o início da resposta do Modo 09
    int cursor = cleanHex.indexOf("49");
    if (cursor == -1) return results;

    cursor += 2; // Pula o "49"

    while (cursor + 2 <= cleanHex.length) {
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      cursor += 2; // Pula o byte do PID

      // PID 02 = Número do Chassi (VIN)
      if (pidHex == "02") {
        // A ECU envia 1 byte informando o "índice de mensagens" (geralmente 01), pulamos ele.
        if (cursor + 2 <= cleanHex.length) cursor += 2;

        // O Chassi tem exatamente 17 caracteres. Em Hex, isso dá 34 caracteres.
        if (cursor + 34 <= cleanHex.length) {
          String vinHex = cleanHex.substring(cursor, cursor + 34);
          String vinAscii = _hexToAscii(vinHex);

          results["VIN (Chassi)"] = vinAscii;
          cursor += 34;
        } else {
          break; // Dados cortados
        }
      } else {
        // Se for outro PID de info do veículo (ex: calibração), abortamos a leitura por enquanto.
        break;
      }
    }

    return results;
  }

  /// Converte a string Hexadecimal em Texto (ASCII) ignorando lixo
  static String _hexToAscii(String hexString) {
    String asciiStr = "";
    for (int i = 0; i < hexString.length; i += 2) {
      String byteHex = hexString.substring(i, i + 2);
      int charCode = int.parse(byteHex, radix: 16);

      // Garante que só vamos converter letras e números válidos (Tabela ASCII)
      if (charCode >= 32 && charCode <= 126) {
        asciiStr += String.fromCharCode(charCode);
      }
    }
    return asciiStr.trim();
  }
}
