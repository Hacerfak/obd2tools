class Mode09Pid {
  final int id;
  final String name;
  final String Function(String hexData) decode;

  const Mode09Pid({required this.id, required this.name, required this.decode});
}

// Dicionário dos principais dados do Modo 09
final Map<int, Mode09Pid> mode09Registry = {
  0x02: Mode09Pid(id: 0x02, name: "Chassi (VIN)", decode: _decodeAscii),
  0x04: Mode09Pid(
    id: 0x04,
    name: "ID de Calibração da ECU",
    decode: _decodeAscii,
  ),
  0x06: Mode09Pid(
    id: 0x06,
    name: "Número de Verificação de Calibração (CVN)",
    decode: (hex) => hex, // CVN é exibido como Hex puro
  ),
  0x0A: Mode09Pid(id: 0x0A, name: "Nome da ECU", decode: _decodeAscii),
};

// Função auxiliar que converte Hexadecimal em Texto legível
String _decodeAscii(String asciiHex) {
  String text = "";
  for (int i = 0; i < asciiHex.length - 1; i += 2) {
    int charCode = int.parse(asciiHex.substring(i, i + 2), radix: 16);
    // Filtra apenas letras e números válidos da tabela ASCII
    if (charCode >= 32 && charCode <= 126) {
      text += String.fromCharCode(charCode);
    }
  }
  return text.trim();
}
