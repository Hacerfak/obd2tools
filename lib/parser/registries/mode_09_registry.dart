class Mode09Pid {
  final int id;
  final String name;
  final String Function(String hexData) decode;

  const Mode09Pid({required this.id, required this.name, required this.decode});
}

// Dicionário dos dados do Modo 09 (Informações do Veículo)
final Map<int, Mode09Pid> mode09Registry = {
  0x01: Mode09Pid(
    id: 0x01,
    name: "Contagem de Msg (Chassi)",
    decode: _decodeCount,
  ),
  0x02: Mode09Pid(id: 0x02, name: "Chassi (VIN)", decode: _decodeAscii),
  0x03: Mode09Pid(
    id: 0x03,
    name: "Contagem de Msg (Calibração)",
    decode: _decodeCount,
  ),
  0x04: Mode09Pid(
    id: 0x04,
    name: "ID de Calibração da ECU",
    decode: _decodeAscii,
  ),
  0x05: Mode09Pid(
    id: 0x05,
    name: "Contagem de Msg (CVN)",
    decode: _decodeCount,
  ),
  0x06: Mode09Pid(
    id: 0x06,
    name: "Núm. de Verificação de Calibração (CVN)",
    decode: _decodeCVN,
  ),
  0x07: Mode09Pid(
    id: 0x07,
    name: "Contagem de Msg (Rastreamento Otto)",
    decode: _decodeCount,
  ),
  0x08: Mode09Pid(
    id: 0x08,
    name: "Rastreamento de Desempenho (Otto)",
    decode: _decodeIUPR,
  ),
  0x09: Mode09Pid(
    id: 0x09,
    name: "Contagem de Msg (Nome ECU)",
    decode: _decodeCount,
  ),
  0x0A: Mode09Pid(id: 0x0A, name: "Nome da ECU", decode: _decodeAscii),
  0x0B: Mode09Pid(
    id: 0x0B,
    name: "Rastreamento de Desempenho (Diesel)",
    decode: _decodeIUPR,
  ),
};

// --- FUNÇÕES DE DECODIFICAÇÃO ---

// PIDs como o 02 e 04 enviam texto.
String _decodeAscii(String hexData) {
  if (hexData.length >= 2) hexData = hexData.substring(2);
  String text = "";
  for (int i = 0; i < hexData.length - 1; i += 2) {
    int charCode = int.parse(hexData.substring(i, i + 2), radix: 16);
    if (charCode >= 32 && charCode <= 126) {
      text += String.fromCharCode(charCode);
    }
  }
  return text.trim();
}

// PIDs de contagem
String _decodeCount(String hexData) {
  if (hexData.length >= 4) {
    int count = int.parse(hexData.substring(2, 4), radix: 16);
    return "$count pacote(s)";
  }
  return hexData;
}

// ---------------------------------------------------------
// TRATAMENTO ESPECÍFICO PARA O CVN (Hashes de 4 Bytes)
// ---------------------------------------------------------
String _decodeCVN(String hexData) {
  int startIndex = 0;
  // Se veio com um byte sobrando na frente, é o contador, pulamos ele
  if (hexData.length % 8 != 0 && (hexData.length - 2) % 8 == 0) {
    startIndex = 2;
  }

  List<String> cvns = [];
  for (int i = startIndex; i < hexData.length; i += 8) {
    if (i + 8 <= hexData.length) {
      cvns.add("• ${hexData.substring(i, i + 8)}");
    }
  }
  return cvns.join("\n");
}

// ---------------------------------------------------------
// TRATAMENTO ESPECÍFICO PARA O RASTREAMENTO (IUPR)
// ---------------------------------------------------------
String _decodeIUPR(String hexData) {
  int startIndex = 0;
  // Pula o contador inicial se ele existir
  if (hexData.length % 4 != 0 && (hexData.length - 2) % 4 == 0) {
    startIndex = 2;
  }

  // Extrai blocos de 2 bytes (4 caracteres) e converte para número decimal
  List<int> values = [];
  for (int i = startIndex; i < hexData.length; i += 4) {
    if (i + 4 <= hexData.length) {
      values.add(int.parse(hexData.substring(i, i + 4), radix: 16));
    }
  }

  if (values.length >= 2) {
    // A SAE J1979 define que os dois primeiros valores são as métricas globais
    String result =
        "Condições Globais (Monitoradas): ${values[0]}\nCiclos de Ignição: ${values[1]}";

    // Do índice 2 em diante, os valores vêm em pares: Numerador (Completou) / Denominador (Teve Chance)
    List<String> monitorNames = [
      "Catalisador",
      "Catalisador (B2)",
      "Sonda Lambda Primária",
      "Sonda Lambda Primária (B2)",
      "Sistema Evaporativo",
      "Sistema EGR / VVT",
      "Sonda Lambda Secundária",
      "Sonda Lambda Secundária (B2)",
      "Ar Secundário",
    ];

    int monitorIndex = 0;
    for (int i = 2; i < values.length; i += 2) {
      if (i + 1 < values.length) {
        String name = monitorIndex < monitorNames.length
            ? monitorNames[monitorIndex]
            : "Monitor Extra ${monitorIndex + 1}";

        result +=
            "\n\n$name:\nTestes Concluídos: ${values[i]}\nCondições Atingidas: ${values[i + 1]}";
        monitorIndex++;
      }
    }
    return result;
  }
  return "Dados insuficientes";
}
