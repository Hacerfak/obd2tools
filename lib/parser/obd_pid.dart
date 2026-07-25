class ObdPid {
  final int id;
  final String name;
  final String unit;
  final int expectedBytes;
  final double Function(List<int> bytes) calculate;

  // NOVO: Função opcional que traduz um valor matemático para um texto (ex: 2.0 -> "Malha Fechada")
  final String Function(double value)? formatValue;

  const ObdPid({
    required this.id,
    required this.name,
    required this.unit,
    required this.expectedBytes,
    required this.calculate,
    this.formatValue, // Pode ser nulo
  });
}
