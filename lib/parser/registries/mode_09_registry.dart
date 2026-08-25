class Mode09Pid {
  final int id;
  final String Function(String hexData, Map<String, dynamic> labels) decode;

  const Mode09Pid({required this.id, required this.decode});
}

final Map<int, Mode09Pid> mode09Registry = {
  0x01: Mode09Pid(id: 0x01, decode: _decodeCount),
  0x02: Mode09Pid(id: 0x02, decode: _decodeAscii),
  0x03: Mode09Pid(id: 0x03, decode: _decodeCount),
  0x04: Mode09Pid(id: 0x04, decode: _decodeAscii),
  0x05: Mode09Pid(id: 0x05, decode: _decodeCount),
  0x06: Mode09Pid(id: 0x06, decode: _decodeCVN),
  0x07: Mode09Pid(id: 0x07, decode: _decodeCount),
  0x08: Mode09Pid(id: 0x08, decode: _decodeIUPR),
  0x09: Mode09Pid(id: 0x09, decode: _decodeCount),
  0x0A: Mode09Pid(id: 0x0A, decode: _decodeAscii),
  0x0B: Mode09Pid(id: 0x0B, decode: _decodeIUPR),
};

String _decodeAscii(String hexData, Map<String, dynamic> labels) {
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

String _decodeCount(String hexData, Map<String, dynamic> labels) {
  if (hexData.length >= 4) {
    int count = int.parse(hexData.substring(2, 4), radix: 16);
    final packetLabel = labels['packets'] ?? 'packet(s)';
    return "$count $packetLabel";
  }
  return hexData;
}

String _decodeCVN(String hexData, Map<String, dynamic> labels) {
  int startIndex = 0;
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

String _decodeIUPR(String hexData, Map<String, dynamic> labels) {
  int startIndex = 0;
  if (hexData.length % 4 != 0 && (hexData.length - 2) % 4 == 0) {
    startIndex = 2;
  }

  List<int> values = [];
  for (int i = startIndex; i < hexData.length; i += 4) {
    if (i + 4 <= hexData.length) {
      values.add(int.parse(hexData.substring(i, i + 4), radix: 16));
    }
  }

  if (values.length >= 2) {
    final globalCond = labels['globalConditions'] ?? 'Global Conditions';
    final ignCycles = labels['ignitionCycles'] ?? 'Ignition Cycles';
    final testsComp = labels['testsCompleted'] ?? 'Tests Completed';
    final condMet = labels['conditionsMet'] ?? 'Conditions Met';
    final extraMon = labels['extraMonitor'] ?? 'Extra Monitor';

    final monitorsMap = (labels['monitors'] as Map<String, dynamic>?) ?? {};
    final monitorNames = [
      monitorsMap['catalyst'] ?? 'Catalyst',
      monitorsMap['catalystB2'] ?? 'Catalyst (B2)',
      monitorsMap['primaryO2'] ?? 'Primary O2 Sensor',
      monitorsMap['primaryO2B2'] ?? 'Primary O2 Sensor (B2)',
      monitorsMap['evap'] ?? 'EVAP System',
      monitorsMap['egrVvt'] ?? 'EGR / VVT System',
      monitorsMap['secondaryO2'] ?? 'Secondary O2 Sensor',
      monitorsMap['secondaryO2B2'] ?? 'Secondary O2 Sensor (B2)',
      monitorsMap['secondaryAir'] ?? 'Secondary Air System',
    ];

    String result = "$globalCond: ${values[0]}\n$ignCycles: ${values[1]}";

    int monitorIndex = 0;
    for (int i = 2; i < values.length; i += 2) {
      if (i + 1 < values.length) {
        String name = monitorIndex < monitorNames.length
            ? monitorNames[monitorIndex]
            : "$extraMon ${monitorIndex + 1}";

        result +=
            "\n\n$name:\n$testsComp: ${values[i]}\n$condMet: ${values[i + 1]}";
        monitorIndex++;
      }
    }
    return result;
  }
  return labels['insufficientData'] ?? "Insufficient data";
}
