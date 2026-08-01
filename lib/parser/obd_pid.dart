enum SensorHealth { normal, warning, critical, none }

class ObdPid {
  final int id;
  final String name;
  final String unit;
  final int expectedBytes;
  final double Function(List<int> bytes) calculate;

  // NOVO: Função opcional que traduz um valor matemático para um texto (ex: 2.0 -> "Malha Fechada")
  final String Function(double value)? formatValue;

  // NOVO: Define se o sensor exige atualização em tempo real (RPM, Vel)
  final bool isFast;

  // NOVO: Função que avalia se o número está bom ou ruim
  final SensorHealth Function(double value)? evaluateHealth;

  const ObdPid({
    required this.id,
    required this.name,
    required this.unit,
    required this.expectedBytes,
    required this.calculate,
    this.formatValue, // Pode ser nulo
    this.isFast =
        false, // Por padrão, os sensores são lentos (Temperatura, etc)
    this.evaluateHealth,
  });
}
