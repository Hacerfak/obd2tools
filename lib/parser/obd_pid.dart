class ObdPid {
  final int id; // O código Hex do PID (ex: 0x0C)
  final String name; // Nome amigável para a interface
  final String unit; // Unidade de medida (RPM, °C, %, kPa)
  final int expectedBytes; // Quantos bytes a ECU devolve para este sensor

  // A função matemática injetada que transforma bytes brutos no valor real
  final double Function(List<int> bytes) calculate;

  const ObdPid({
    required this.id,
    required this.name,
    required this.unit,
    required this.expectedBytes,
    required this.calculate,
  });
}
