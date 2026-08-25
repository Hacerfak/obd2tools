class MonitorItem {
  final String key;
  final bool isAvailable;
  final bool isComplete;

  MonitorItem({
    required this.key,
    required this.isAvailable,
    required this.isComplete,
  });
}

class ObdMonitorStatus {
  final bool isMilOn;
  final int dtcCount;
  final bool isDiesel;
  final List<MonitorItem> monitors;

  ObdMonitorStatus({
    required this.isMilOn,
    required this.dtcCount,
    required this.isDiesel,
    required this.monitors,
  });

  factory ObdMonitorStatus.fromBytes(List<int> bytes, {bool isPid41 = false}) {
    if (bytes.length < 4) {
      return ObdMonitorStatus(
        isMilOn: false,
        dtcCount: 0,
        isDiesel: false,
        monitors: [],
      );
    }

    final byteA = bytes[0];
    final byteB = bytes[1];
    final byteC = bytes[2];
    final byteD = bytes[3];

    // Byte A: PID 01 contém MIL e contagem de DTCs. No PID 41 o Byte A é 0x00.
    final bool milOn = !isPid41 && (byteA & 0x80) != 0;
    final int dtcCount = !isPid41 ? (byteA & 0x7F) : 0;

    // Byte B: Bit 3 indica tipo de motor (0 = Spark/Otto, 1 = Compression/Diesel)
    final bool isDiesel = (byteB & 0x08) != 0;

    List<MonitorItem> list = [];

    // Helper para extrair bit (1 = true, 0 = false)
    bool getBit(int byteVal, int bitIndex) =>
        ((byteVal >> bitIndex) & 0x01) == 1;

    // --- MONITORES COMUNS (Byte B) ---
    // Disponibilidade: B0, B1, B2 (1 = Disponível)
    // Conclusão: B4, B5, B6 (0 = Concluído, 1 = Incompleto)
    _addMonitor(list, 'misfire', getBit(byteB, 0), !getBit(byteB, 4));
    _addMonitor(list, 'fuelSystem', getBit(byteB, 1), !getBit(byteB, 5));
    _addMonitor(list, 'components', getBit(byteB, 2), !getBit(byteB, 6));

    // --- MONITORES ESPECÍFICOS (Bytes C e D) ---
    // Disponibilidade = Byte C | Conclusão (0 = Concluído) = Byte D
    if (!isDiesel) {
      // Ciclo Otto (Gasolina / Etanol / Flex)
      _addMonitor(list, 'catalyst', getBit(byteC, 0), !getBit(byteD, 0));
      _addMonitor(list, 'heatedCatalyst', getBit(byteC, 1), !getBit(byteD, 1));
      _addMonitor(
        list,
        'evaporativeSystem',
        getBit(byteC, 2),
        !getBit(byteD, 2),
      );
      _addMonitor(list, 'secondaryAir', getBit(byteC, 3), !getBit(byteD, 3));
      _addMonitor(list, 'gpfFilter', getBit(byteC, 4), !getBit(byteD, 4));
      _addMonitor(list, 'oxygenSensor', getBit(byteC, 5), !getBit(byteD, 5));
      _addMonitor(list, 'oxygenHeater', getBit(byteC, 6), !getBit(byteD, 6));
      _addMonitor(list, 'egrVvt', getBit(byteC, 7), !getBit(byteD, 7));
    } else {
      // Ciclo Diesel (Compressão)
      _addMonitor(list, 'nmhcCatalyst', getBit(byteC, 0), !getBit(byteD, 0));
      _addMonitor(list, 'noxScr', getBit(byteC, 1), !getBit(byteD, 1));
      _addMonitor(list, 'boostPressure', getBit(byteC, 3), !getBit(byteD, 3));
      _addMonitor(
        list,
        'exhaustGasSensor',
        getBit(byteC, 5),
        !getBit(byteD, 5),
      );
      _addMonitor(list, 'pmFilter', getBit(byteC, 6), !getBit(byteD, 6));
      _addMonitor(list, 'egrVvt', getBit(byteC, 7), !getBit(byteD, 7));
    }

    return ObdMonitorStatus(
      isMilOn: milOn,
      dtcCount: dtcCount,
      isDiesel: isDiesel,
      monitors: list,
    );
  }

  static void _addMonitor(
    List<MonitorItem> list,
    String key,
    bool available,
    bool complete,
  ) {
    if (available) {
      list.add(
        MonitorItem(key: key, isAvailable: available, isComplete: complete),
      );
    }
  }
}
