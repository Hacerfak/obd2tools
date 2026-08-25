import '../obd_pid.dart';

final Map<int, ObdPid> pidRegistry = {
  // --- BLOCO 1 (0x01 a 0x20) ---
  0x01: ObdPid(
    id: 0x01,
    name: "Status dos Monitores DTC",
    unit: "",
    expectedBytes: 4,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x03: ObdPid(
    id: 0x03,
    name: "Status do Sistema de Combustível",
    unit: "",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x04: ObdPid(
    id: 0x04,
    name: "Carga Calculada do Motor",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    isFast: true,
  ),
  0x05: ObdPid(
    id: 0x05,
    name: "Temp. Arrefecimento (Motor)",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
    evaluateHealth: (value) {
      if (value < 75) return SensorHealth.warning;
      if (value >= 75 && value <= 105) return SensorHealth.normal;
      if (value > 105 && value <= 115) return SensorHealth.warning;
      return SensorHealth.critical;
    },
  ),
  0x06: ObdPid(
    id: 0x06,
    name: "Ajuste de Combustível a Curto Prazo (Banco 1)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 1.28) - 100.0,
    isFast: true,
  ),
  0x07: ObdPid(
    id: 0x07,
    name: "Ajuste de Combustível a Longo Prazo (Banco 1)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 1.28) - 100.0,
  ),
  0x08: ObdPid(
    id: 0x08,
    name: "Ajuste de Combustível a Curto Prazo (Banco 2)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 1.28) - 100.0,
    isFast: true,
  ),
  0x09: ObdPid(
    id: 0x09,
    name: "Ajuste de Combustível a Longo Prazo (Banco 2)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 1.28) - 100.0,
  ),
  0x0A: ObdPid(
    id: 0x0A,
    name: "Pressão do Combustível (Bomba)",
    unit: "kPa",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] * 3.0,
  ),
  0x0B: ObdPid(
    id: 0x0B,
    name: "Pressão Admissão (MAP)",
    unit: "kPa",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    isFast: true,
  ),
  0x0C: ObdPid(
    id: 0x0C,
    name: "Rotação do Motor (RPM)",
    unit: "RPM",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 4.0,
    isFast: true,
  ),
  0x0D: ObdPid(
    id: 0x0D,
    name: "Velocidade do Veículo",
    unit: "km/h",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    isFast: true,
  ),
  0x0E: ObdPid(
    id: 0x0E,
    name: "Avanço de Ignição (Avanço)",
    unit: "°",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 2.0) - 64.0,
  ),
  0x0F: ObdPid(
    id: 0x0F,
    name: "Temp. Ar Admissão (IAT)",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
    evaluateHealth: (value) {
      if (value <= 50.0) return SensorHealth.normal;
      if (value > 50.0 && value <= 70.0) return SensorHealth.warning;
      return SensorHealth.critical;
    },
  ),
  0x10: ObdPid(
    id: 0x10,
    name: "Fluxo de Ar (MAF)",
    unit: "g/s",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 100.0,
    isFast: true,
  ),
  0x11: ObdPid(
    id: 0x11,
    name: "Posição do Acelerador (TPS)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    isFast: true,
  ),
  0x13: ObdPid(
    id: 0x13,
    name: "Sensores de Oxigênio Presentes",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x14: ObdPid(
    id: 0x14,
    name: "Tensão da Sonda Lambda (B1S1)",
    unit: "V",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0] / 200.0,
    isFast: true,
  ),
  0x15: ObdPid(
    id: 0x15,
    name: "Tensão da Sonda Lambda (B1S2)",
    unit: "V",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0] / 200.0,
    isFast: true,
  ),
  0x16: ObdPid(
    id: 0x16,
    name: "Tensão da Sonda Lambda (B2S1)",
    unit: "V",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0] / 200.0,
    isFast: true,
  ),
  0x17: ObdPid(
    id: 0x17,
    name: "Tensão da Sonda Lambda (B2S2)",
    unit: "V",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0] / 200.0,
    isFast: true,
  ),
  0x1C: ObdPid(
    id: 0x1C,
    name: "Padrão OBD Suportado",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x1F: ObdPid(
    id: 0x1F,
    name: "Tempo com Motor Ligado",
    unit: "seg",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),

  // --- BLOCO 2 (0x21 a 0x40) ---
  0x21: ObdPid(
    id: 0x21,
    name: "Distância Percorrida com Luz Injeção Acesa",
    unit: "km",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x22: ObdPid(
    id: 0x22,
    name: "Pressão no Tubo Distribuidor (Fuel Rail) - Relativa",
    unit: "kPa",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) * 0.079,
  ),
  0x23: ObdPid(
    id: 0x23,
    name: "Pressão no Tubo Distribuidor (Fuel Rail) - Absoluta",
    unit: "kPa",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) * 10.0,
  ),
  0x2C: ObdPid(
    id: 0x2C,
    name: "Comando EGR",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x2D: ObdPid(
    id: 0x2D,
    name: "Erro do Sistema EGR",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 1.28) - 100.0,
  ),
  0x2E: ObdPid(
    id: 0x2E,
    name: "Comando Purga Canister",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x2F: ObdPid(
    id: 0x2F,
    name: "Nível de Combustível",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    evaluateHealth: (value) {
      if (value >= 15.0) return SensorHealth.normal;
      if (value >= 5.0 && value < 15.0) return SensorHealth.warning;
      return SensorHealth.critical;
    },
  ),
  0x30: ObdPid(
    id: 0x30,
    name: "Nº de Limpezas de Código desde Reset",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x31: ObdPid(
    id: 0x31,
    name: "Distância Percorrida desde Reset",
    unit: "km",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x32: ObdPid(
    id: 0x32,
    name: "Pressão de Vapor do Sistema Evaporativo",
    unit: "Pa",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 4.0) - 8192.0,
  ),
  0x33: ObdPid(
    id: 0x33,
    name: "Pressão Barométrica (Ambiente)",
    unit: "kPa",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x34: ObdPid(
    id: 0x34,
    name: "Sonda Lambda 1 (B1S1) - Relação Equivalência",
    unit: "λ",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 32768.0,
    isFast: true,
  ),
  0x35: ObdPid(
    id: 0x35,
    name: "Sonda Lambda 2 (B1S2) - Relação Equivalência",
    unit: "λ",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 32768.0,
    isFast: true,
  ),
  0x3C: ObdPid(
    id: 0x3C,
    name: "Temp. Catalisador (Banco 1, Sensor 1)",
    unit: "°C",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 10.0) - 40.0,
  ),
  0x3D: ObdPid(
    id: 0x3D,
    name: "Temp. Catalisador (Banco 2, Sensor 1)",
    unit: "°C",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 10.0) - 40.0,
  ),
  0x3E: ObdPid(
    id: 0x3E,
    name: "Temp. Catalisador (Banco 1, Sensor 2)",
    unit: "°C",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 10.0) - 40.0,
  ),
  0x3F: ObdPid(
    id: 0x3F,
    name: "Temp. Catalisador (Banco 2, Sensor 2)",
    unit: "°C",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 10.0) - 40.0,
  ),

  // --- BLOCO 3 (0x41 a 0x60) ---
  0x41: ObdPid(
    id: 0x41,
    name: "Status Monitores (Ciclo Atual)",
    unit: "",
    expectedBytes: 4,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x42: ObdPid(
    id: 0x42,
    name: "Tensão Módulo Controle (ECU / Bateria)",
    unit: "V",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 1000.0,
    evaluateHealth: (value) {
      if (value >= 13.5 && value <= 14.7) return SensorHealth.normal;
      if ((value >= 12.0 && value < 13.5) || (value > 14.7 && value <= 15.0)) {
        return SensorHealth.warning;
      }
      return SensorHealth.critical;
    },
  ),
  0x43: ObdPid(
    id: 0x43,
    name: "Carga Absoluta",
    unit: "%",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 255.0) * 100.0,
    isFast: true,
  ),
  0x44: ObdPid(
    id: 0x44,
    name: "Razão Equivalência Ar/Combustível",
    unit: "λ",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 32768.0,
    evaluateHealth: (value) {
      if (value >= 0.95 && value <= 1.05) return SensorHealth.normal;
      if ((value >= 0.90 && value < 0.95) || (value > 1.05 && value <= 1.10)) {
        return SensorHealth.warning;
      }
      return SensorHealth.critical;
    },
  ),
  0x45: ObdPid(
    id: 0x45,
    name: "Posição Relativa da Borboleta",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    isFast: true,
  ),
  0x46: ObdPid(
    id: 0x46,
    name: "Temperatura do Ar Ambiente",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
  ),
  0x47: ObdPid(
    id: 0x47,
    name: "Posição Absoluta Borboleta B",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x48: ObdPid(
    id: 0x48,
    name: "Posição Absoluta Borboleta C",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x49: ObdPid(
    id: 0x49,
    name: "Posição do Pedal Acelerador D",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x4A: ObdPid(
    id: 0x4A,
    name: "Posição do Pedal Acelerador E",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x4B: ObdPid(
    id: 0x4B,
    name: "Posição do Pedal Acelerador F",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x4C: ObdPid(
    id: 0x4C,
    name: "Atuação do Atuador da Borboleta",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x4D: ObdPid(
    id: 0x4D,
    name: "Tempo de Motor com Luz de Injeção Acesa",
    unit: "min",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x4E: ObdPid(
    id: 0x4E,
    name: "Tempo de Motor desde Limpeza de Erros",
    unit: "min",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x51: ObdPid(
    id: 0x51,
    name: "Tipo de Combustível do Veículo",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x52: ObdPid(
    id: 0x52,
    name: "Percentual de Etanol no Combustível",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x53: ObdPid(
    id: 0x53,
    name: "Pressão Absoluta de Vapor (EVAP)",
    unit: "kPa",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 200.0,
  ),
  0x59: ObdPid(
    id: 0x59,
    name: "Pressão Absoluta no Tubo Distribuidor (Fuel Rail)",
    unit: "kPa",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) * 10.0,
  ),
  0x5A: ObdPid(
    id: 0x5A,
    name: "Posição Relativa do Pedal do Acelerador",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    isFast: true,
  ),
  0x5B: ObdPid(
    id: 0x5B,
    name: "Vida Útil da Bateria (Híbridos)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x5C: ObdPid(
    id: 0x5C,
    name: "Temperatura do Óleo do Motor",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
    evaluateHealth: (value) {
      if (value < 70) return SensorHealth.warning;
      if (value >= 70 && value <= 110) return SensorHealth.normal;
      if (value > 110 && value <= 125) return SensorHealth.warning;
      return SensorHealth.critical;
    },
  ),
  0x5D: ObdPid(
    id: 0x5D,
    name: "Ponto de Injeção de Combustível",
    unit: "°",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 128.0) - 210.0,
  ),
  0x5E: ObdPid(
    id: 0x5E,
    name: "Consumo de Combustível (Vazão)",
    unit: "L/h",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 20.0,
    isFast: true,
  ),
  0x5F: ObdPid(
    id: 0x5F,
    name: "Norma de Emissões Projetada",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),

  // --- BLOCO 4 (0x61 a 0x80) ---
  0x61: ObdPid(
    id: 0x61,
    name: "Torque Demandado pelo Motorista",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 125.0,
    isFast: true,
  ),
  0x62: ObdPid(
    id: 0x62,
    name: "Torque Real do Motor",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 125.0,
    isFast: true,
  ),
  0x63: ObdPid(
    id: 0x63,
    name: "Torque de Referência do Motor",
    unit: "Nm",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x66: ObdPid(
    id: 0x66,
    name: "Fluxo de Massa de Ar (Sensor A)",
    unit: "g/s",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 32.0,
    isFast: true,
  ),
  0x67: ObdPid(
    id: 0x67,
    name: "Temp. Arrefecimento (Sensores Múltiplos)",
    unit: "°C",
    expectedBytes: 3,
    calculate: (bytes) => bytes[1] - 40.0,
  ),
  0x68: ObdPid(
    id: 0x68,
    name: "Temp. Ar Admissão (Sensores Múltiplos)",
    unit: "°C",
    expectedBytes: 3,
    calculate: (bytes) => bytes[1] - 40.0,
  ),
  0x6F: ObdPid(
    id: 0x6F,
    name: "Pressão de Entrada do Turbo",
    unit: "kPa",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    isFast: true,
  ),
  0x78: ObdPid(
    id: 0x78,
    name: "Temp. Gases de Escape (EGT) - Banco 1",
    unit: "°C",
    expectedBytes: 9,
    calculate: (bytes) => bytes.length >= 3
        ? (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0
        : -40.0,
  ),
  0x79: ObdPid(
    id: 0x79,
    name: "Temp. Gases de Escape (EGT) - Banco 2",
    unit: "°C",
    expectedBytes: 9,
    calculate: (bytes) => bytes.length >= 3
        ? (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0
        : -40.0,
  ),

  // --- BLOCO 5 (0x81 a 0xA0) ---
  0x81: ObdPid(
    id: 0x81,
    name: "Tempo de Motor com Controle de Emissão Ativo",
    unit: "min",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x82: ObdPid(
    id: 0x82,
    name: "Tempo de Motor desde Início do Controle de Emissão",
    unit: "min",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x83: ObdPid(
    id: 0x83,
    name: "Pressão de Vapor do Sistema Evaporativo (Alt)",
    unit: "Pa",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) - 32768.0,
  ),
  0x84: ObdPid(
    id: 0x84,
    name: "Avanço/Tempo de Injeção de Combustível",
    unit: "°",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 128.0) - 210.0,
  ),
  0x85: ObdPid(
    id: 0x85,
    name: "Taxa de Consumo de Combustível do Motor (Alt)",
    unit: "L/h",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 20.0,
    isFast: true,
  ),
  0x91: ObdPid(
    id: 0x91,
    name: "Temperatura do Óleo do Motor (Alt)",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
    evaluateHealth: (value) {
      if (value < 70) return SensorHealth.warning;
      if (value >= 70 && value <= 110) return SensorHealth.normal;
      return SensorHealth.critical;
    },
  ),
  0x92: ObdPid(
    id: 0x92,
    name: "Correção de Tempo de Injeção",
    unit: "µs",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0x98: ObdPid(
    id: 0x98,
    name: "Concentração do Sensor NOx",
    unit: "ppm",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 10.0,
  ),

  // --- BLOCO 6 (0xA1 a 0xC0) ---
  0xA1: ObdPid(
    id: 0xA1,
    name: "Dados de Injeção (Taxa e Tempo)",
    unit: "",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]).toDouble(),
  ),
  0xA2: ObdPid(
    id: 0xA2,
    name: "Taxa de Combustível por Cilindro",
    unit: "mg/ciclo",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 256.0,
    isFast: true,
  ),
  0xA3: ObdPid(
    id: 0xA3,
    name: "Torque de Atrito do Motor",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 125.0,
  ),
  0xA4: ObdPid(
    id: 0xA4,
    name: "Temperatura de Roteamento dos Gases de Escape",
    unit: "°C",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0,
  ),
  0xA6: ObdPid(
    id: 0xA6,
    name: "Hodômetro (Quilometragem da ECU)",
    unit: "km",
    expectedBytes: 4,
    calculate: (bytes) =>
        ((bytes[0] * 16777216) +
            (bytes[1] * 65536) +
            (bytes[2] * 256) +
            bytes[3]) /
        10.0,
  ),
  0xA7: ObdPid(
    id: 0xA7,
    name: "Sensor de NOx (Banco 1)",
    unit: "ppm",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0),
  ),
  0xA8: ObdPid(
    id: 0xA8,
    name: "Sensor de NOx (Banco 2)",
    unit: "ppm",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0),
  ),
  0xAA: ObdPid(
    id: 0xAA,
    name: "Temp. Intercooler (Charge Air Cooler)",
    unit: "°C",
    expectedBytes: 4,
    calculate: (bytes) => bytes[1] - 40.0,
    evaluateHealth: (value) {
      if (value < 60) return SensorHealth.normal;
      if (value >= 60 && value < 90) return SensorHealth.warning;
      return SensorHealth.critical;
    },
  ),
  0xAB: ObdPid(
    id: 0xAB,
    name: "Pressão do Sistema de Injeção",
    unit: "kPa",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[1] * 256) + bytes[2]) * 10.0,
  ),
  0xAF: ObdPid(
    id: 0xAF,
    name: "Sistema de Controle do Ar Secundário",
    unit: "%",
    expectedBytes: 2,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0xB4: ObdPid(
    id: 0xB4,
    name: "Temperatura Sonda Lambda (B1, B2)",
    unit: "°C",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0,
  ),

  // --- BLOCOS 7 e 8 (0xC1 a 0xFF) ---
  0xC4: ObdPid(
    id: 0xC4,
    name: "Controle da Válvula EGR (Avançado)",
    unit: "%",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 2.55) - 100.0,
  ),
  0xC5: ObdPid(
    id: 0xC5,
    name: "Controle do Turbo de Geometria Variável (VGT)",
    unit: "%",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 2.55) - 100.0,
    isFast: true,
  ),
  0xC6: ObdPid(
    id: 0xC6,
    name: "Pressão do Filtro de Partículas Diesel (DPF)",
    unit: "kPa",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[1] * 256) + bytes[2]) / 100.0,
  ),
  0xC8: ObdPid(
    id: 0xC8,
    name: "Tempo de Aprendizado do Injetor",
    unit: "ms",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[1] * 256) + bytes[2]) / 100.0,
  ),
  0xCB: ObdPid(
    id: 0xCB,
    name: "Sensor de NOx (Pós-Catalisador)",
    unit: "ppm",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[1] * 256) + bytes[2]) / 10.0,
  ),
  0xCD: ObdPid(
    id: 0xCD,
    name: "Sensor de Material Particulado (PM)",
    unit: "mg/m³",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[1] * 256) + bytes[2]) / 10.0,
  ),
  0xCE: ObdPid(
    id: 0xCE,
    name: "Aquecedor de Ar de Admissão",
    unit: "%",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 2.55) - 100.0,
  ),
  0xD0: ObdPid(
    id: 0xD0,
    name: "Pressão do Sistema de Combustível (Alta Pressão)",
    unit: "kPa",
    expectedBytes: 4,
    calculate: (bytes) => ((bytes[1] * 256) + bytes[2]) * 10.0,
  ),
  0xD2: ObdPid(
    id: 0xD2,
    name: "Controle da Bomba de Água Elétrica",
    unit: "%",
    expectedBytes: 2,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0xDF: ObdPid(
    id: 0xDF,
    name: "Status do Controle de Exaustão (DPF/NOx)",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0xE3: ObdPid(
    id: 0xE3,
    name: "Temperatura do Motor do Compressor do A/C",
    unit: "°C",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0] - 40.0,
  ),
  0xEA: ObdPid(
    id: 0xEA,
    name: "Temperatura do Inversor (Híbridos)",
    unit: "°C",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0] - 40.0,
  ),
};
