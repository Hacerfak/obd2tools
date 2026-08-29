enum BusType { canBus, kLine, j1850, heavyDuty, swCan }

class ProtocolProfile {
  final String protocolNumber;
  final String protocolName;
  final BusType busType;
  final Duration minPollingInterval;
  final bool supportsCanHeaders;
  final bool strictBitmaskOnly;

  const ProtocolProfile({
    required this.protocolNumber,
    required this.protocolName,
    required this.busType,
    required this.minPollingInterval,
    required this.supportsCanHeaders,
    required this.strictBitmaskOnly,
  });

  factory ProtocolProfile.fromElmNumber(String elmNum) {
    // Limpa a resposta (ex: de "A6" ou "AUTO, 6" extrai apenas "6")
    final num = elmNum.replaceAll(RegExp(r'[^0-9A-C]'), '').trim();
    final protocolCode = num.isNotEmpty ? num[num.length - 1] : '0';

    switch (protocolCode) {
      // --- PROTOCOLOS SAE J1850 ---
      case '1':
        return const ProtocolProfile(
          protocolNumber: "1",
          protocolName: "SAE J1850 PWM (41.6 kbaud)",
          busType: BusType.j1850,
          minPollingInterval: Duration(milliseconds: 100),
          supportsCanHeaders: false,
          strictBitmaskOnly: true,
        );
      case '2':
        return const ProtocolProfile(
          protocolNumber: "2",
          protocolName: "SAE J1850 VPW (10.4 kbaud)",
          busType: BusType.j1850,
          minPollingInterval: Duration(milliseconds: 100),
          supportsCanHeaders: false,
          strictBitmaskOnly: true,
        );

      // --- PROTOCOLOS K-LINE (ISO 9141 / ISO 14230) ---
      case '3':
        return const ProtocolProfile(
          protocolNumber: "3",
          protocolName: "ISO 9141-2 (5 baud init)",
          busType: BusType.kLine,
          minPollingInterval: Duration(milliseconds: 150),
          supportsCanHeaders: false,
          strictBitmaskOnly: true,
        );
      case '4':
        return const ProtocolProfile(
          protocolNumber: "4",
          protocolName: "ISO 14230-4 KWP (5 baud init)",
          busType: BusType.kLine,
          minPollingInterval: Duration(milliseconds: 150),
          supportsCanHeaders: false,
          strictBitmaskOnly: true,
        );
      case '5':
        return const ProtocolProfile(
          protocolNumber: "5",
          protocolName: "ISO 14230-4 KWP (fast init)",
          busType: BusType.kLine,
          minPollingInterval: Duration(milliseconds: 150),
          supportsCanHeaders: false,
          strictBitmaskOnly: true,
        );

      // --- PROTOCOLOS CAN BUS (ISO 15765-4) ---
      case '6':
        return const ProtocolProfile(
          protocolNumber: "6",
          protocolName: "ISO 15765-4 CAN (11 bit, 500 kbaud)",
          busType: BusType.canBus,
          minPollingInterval: Duration(milliseconds: 10),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );
      case '7':
        return const ProtocolProfile(
          protocolNumber: "7",
          protocolName: "ISO 15765-4 CAN (29 bit, 500 kbaud)",
          busType: BusType.canBus,
          minPollingInterval: Duration(milliseconds: 10),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );
      case '8':
        return const ProtocolProfile(
          protocolNumber: "8",
          protocolName: "ISO 15765-4 CAN (11 bit, 250 kbaud)",
          busType: BusType.canBus,
          minPollingInterval: Duration(milliseconds: 25),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );
      case '9':
        return const ProtocolProfile(
          protocolNumber: "9",
          protocolName: "ISO 15765-4 CAN (29 bit, 250 kbaud)",
          busType: BusType.canBus,
          minPollingInterval: Duration(milliseconds: 25),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );

      // --- PROTOCOLOS PESADOS E CUSTOMIZADOS ---
      case 'A':
        return const ProtocolProfile(
          protocolNumber: "A",
          protocolName: "SAE J1939 CAN (29 bit, 250 kbaud)",
          busType: BusType.heavyDuty,
          minPollingInterval: Duration(milliseconds: 40),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );
      case 'B':
        return const ProtocolProfile(
          protocolNumber: "B",
          protocolName: "USER1 CAN (11 bit, 125 kbaud)",
          busType: BusType.canBus,
          minPollingInterval: Duration(milliseconds: 40),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );
      case 'C':
        return const ProtocolProfile(
          protocolNumber: "C",
          protocolName: "USER2 CAN / SAE J2411 SWCAN (11 bit, 50 kbaud)",
          busType: BusType.swCan,
          minPollingInterval: Duration(milliseconds: 50),
          supportsCanHeaders: true,
          strictBitmaskOnly: false,
        );

      default:
        return ProtocolProfile.fallback();
    }
  }

  factory ProtocolProfile.fallback() => const ProtocolProfile(
    protocolNumber: "0",
    protocolName: "Unknown / Auto",
    busType: BusType.kLine,
    minPollingInterval: Duration(milliseconds: 150),
    supportsCanHeaders: false,
    strictBitmaskOnly: true,
  );

  int get headerLength {
    if (busType == BusType.canBus ||
        busType == BusType.swCan ||
        busType == BusType.heavyDuty) {
      // 29-bit CAN usa 8 caracteres. 11-bit CAN usa 3.
      return protocolNumber == "7" ||
              protocolNumber == "9" ||
              protocolNumber == "A"
          ? 8
          : 3;
    }
    return 0; // Linha K não possui cabeçalho explícito de ID
  }
}
