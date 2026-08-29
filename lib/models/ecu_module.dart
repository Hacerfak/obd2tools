enum EcuType { engine, transmission, abs, unknown }

class EcuModule {
  final String rxHeader; // O que a ECU responde (Ex: 7E8)
  final String txHeader; // O que enviamos para focar nela (Ex: 7E0)
  final EcuType type;
  final String name;

  const EcuModule(this.rxHeader, this.txHeader, this.type, this.name);

  factory EcuModule.fromRxHeader(String rx) {
    final header = rx.trim().toUpperCase();

    // IDs Padrão CAN 11-bit
    if (header == "7E8") {
      return const EcuModule("7E8", "7E0", EcuType.engine, "Motor");
    }
    if (header == "7E9") {
      return const EcuModule("7E9", "7E1", EcuType.transmission, "Transmissão");
    }
    if (header == "7EA") {
      return const EcuModule("7EA", "7E2", EcuType.abs, "Freios/ABS");
    }

    // IDs Padrão CAN 29-bit
    if (header.contains("18DAF110") || header.endsWith("00")) {
      return EcuModule(header, header, EcuType.engine, "Motor (29b)");
    }
    if (header.contains("18DAF118") || header.endsWith("01")) {
      return EcuModule(
        header,
        header,
        EcuType.transmission,
        "Transmissão (29b)",
      );
    }

    return EcuModule(header, header, EcuType.unknown, "Módulo Desconhecido");
  }

  factory EcuModule.defaultEcu() =>
      const EcuModule("7E8", "7E0", EcuType.engine, "Motor");
}
