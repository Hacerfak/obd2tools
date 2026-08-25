class EgtSensorItem {
  final int index;
  final bool isSupported;
  final double temperature;

  EgtSensorItem({
    required this.index,
    required this.isSupported,
    required this.temperature,
  });
}

class EgtStatus {
  final int bank;
  final List<EgtSensorItem> sensors;

  EgtStatus({required this.bank, required this.sensors});

  factory EgtStatus.fromBytes(List<int> bytes, {required int bank}) {
    List<EgtSensorItem> sensorList = [];

    if (bytes.length < 9) {
      return EgtStatus(bank: bank, sensors: sensorList);
    }

    final int mask = bytes[0];

    for (int i = 0; i < 4; i++) {
      final bool isSupported = (mask & (1 << i)) != 0;
      final int msbIndex = 1 + (i * 2);
      final int lsbIndex = msbIndex + 1;

      double temp = -40.0;
      if (isSupported && lsbIndex < bytes.length) {
        final int msb = bytes[msbIndex];
        final int lsb = bytes[lsbIndex];
        temp = (((msb * 256) + lsb) / 10.0) - 40.0;
      }

      sensorList.add(
        EgtSensorItem(
          index: i + 1,
          isSupported: isSupported,
          temperature: temp,
        ),
      );
    }

    return EgtStatus(bank: bank, sensors: sensorList);
  }
}
