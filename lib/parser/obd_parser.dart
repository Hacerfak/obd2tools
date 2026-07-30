class ObdParser {
  static String cleanRawResponse(String rawData) {
    String clean = rawData.replaceAll("SEARCHING...", "").trim();

    // 1. RECONSTRUTOR DE PACOTES CAN MULTI-FRAME
    // Se o texto tiver pacotes enumerados (ex: "0:410C... 1:0D... 2:05...")
    if (clean.contains("0:")) {
      // Remove o prefixo de tamanho total (ex: o "00E " no começo)
      clean = clean.replaceAll(RegExp(r'^[0-9A-F]{3}\s'), '');

      // Remove os cabeçalhos de frame (ex: "0:", " 1:", " 2:")
      clean = clean.replaceAll(RegExp(r'\s?[0-9A-F]:'), '');
    }

    // 2. Limpeza brutal: tira espaços, \n, e qualquer lixo não-hexadecimal
    clean = clean.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

    // 3. Remove os 'AA' ou '00' do final (Padding da rede CAN)
    while (clean.endsWith("AA") && clean.length > 2) {
      clean = clean.substring(0, clean.length - 2);
    }

    return clean;
  }
}
