import '../obd_pid.dart';

final Map<int, ObdPid> pidRegistry = {
  // --- BLOCO 1 (0x01 a 0x20) ---
  0x01: ObdPid(
    id: 0x01,
    name: "Status dos Monitores DTC",
    unit: "",
    expectedBytes: 4,
    calculate: (bytes) => bytes[0].toDouble(), // Status de flags
  ),
  0x03: ObdPid(
    id: 0x03,
    name: "Status do Sistema de Combustível",
    unit: "",
    expectedBytes: 2,
    calculate: (bytes) => bytes[0].toDouble(), // Analisa apenas o sistema 1
    // NOVO: O tradutor humano
    formatValue: (value) {
      int val = value.toInt();
      if (val == 0) return "Motor Desligado / Iniciando";
      if (val == 1) return "Malha Aberta (Frio)";
      if (val == 2) return "Malha Fechada (Lambda)";
      if (val == 4) return "Malha Aberta (Carga/Falha)";
      if (val == 8) return "Malha Fechada (Erro Lambda)";
      if (val == 16) return "Malha Aberta (Defeito)";
      return "Status: $val";
    },
  ),
  0x04: ObdPid(
    id: 0x04,
    name: "Carga Calculada do Motor",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x05: ObdPid(
    id: 0x05,
    name: "Temp. Arrefecimento (Motor)",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
  ),
  0x0B: ObdPid(
    id: 0x0B,
    name: "Pressão Admissão (MAP)",
    unit: "kPa",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
  ),
  0x0C: ObdPid(
    id: 0x0C,
    name: "Rotação do Motor (RPM)",
    unit: "RPM",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 4.0,
  ),
  0x0D: ObdPid(
    id: 0x0D,
    name: "Velocidade do Veículo",
    unit: "km/h",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
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
  ),
  0x10: ObdPid(
    id: 0x10,
    name: "Fluxo de Ar (MAF)",
    unit: "g/s",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 100.0,
  ),
  0x11: ObdPid(
    id: 0x11,
    name: "Posição do Acelerador (TPS)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
  0x13: ObdPid(
    id: 0x13,
    name: "Sensores de Oxigênio Presentes",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
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
  ),
  0x43: ObdPid(
    id: 0x43,
    name: "Carga Absoluta",
    unit: "%",
    expectedBytes: 2,
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 255.0) * 100.0,
  ),
  0x44: ObdPid(
    id: 0x44,
    name: "Razão Equivalência Ar/Combustível",
    unit: "λ",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 32768.0,
  ),
  0x45: ObdPid(
    id: 0x45,
    name: "Posição Relativa da Borboleta",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
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
  0x4C: ObdPid(
    id: 0x4C,
    name: "Atuação do Atuador da Borboleta",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
  ),
};

  // Siga exatamente esse padrão de 5 linhas para inserir os outros sensores da Wikipédia
  // Dicionário com os nomes dos sensores mais comuns em português
  /* final Map<int, String> _pidNames = {
    // Grupo 01 a 20
    0x01: "Status dos Monitores de Emissão",
    0x03: "Status do Sistema de Combustível",
    0x04: "Carga Calculada do Motor",
    0x05: "Temperatura do Líquido de Arrefecimento",
    0x06: "Ajuste de Combustível a Curto Prazo (Banco 1)",
    0x07: "Ajuste de Combustível a Longo Prazo (Banco 1)",
    0x0B: "Pressão Absoluta do Coletor (MAP)",
    0x0C: "Rotação do Motor (RPM)",
    0x0D: "Velocidade do Veículo",
    0x0E: "Avanço do Ponto de Ignição",
    0x0F: "Temperatura do Ar de Admissão",
    0x10: "Taxa de Fluxo de Ar (MAF)",
    0x11: "Posição do Acelerador (TPS)",
    0x13: "Sensores de Oxigênio Presentes (Sonda Lambda)",
    0x1C: "Padrão OBD suportado",
    0x1F: "Tempo de Funcionamento do Motor",

    // Grupo 21 a 40
    0x21: "Distância Percorrida com Luz de Injeção Acesa",
    0x2E: "Purga Evaporativa Comandada",
    0x2F: "Nível do Tanque de Combustível",
    0x30: "Aquecimentos desde que os erros foram limpos",
    0x31: "Distância percorrida desde a limpeza de erros",
    0x32: "Pressão de Vapor do Sistema Evaporativo",
    0x33: "Pressão Atmosférica Absoluta",

    // Grupo 41 a 60
    0x41: "Status do Monitor no Ciclo de Direção Atual",
    0x42: "Tensão do Módulo de Controle (ECU)",
    0x43: "Valor Absoluto da Carga do Motor",
    0x44: "Relação Ar/Combustível Comandada",
    0x45: "Posição Relativa do Acelerador",
    0x46: "Temperatura do Ar Ambiente",
    0x47: "Posição Absoluta do Acelerador B",
    0x49: "Posição do Pedal do Acelerador D",
    0x4A: "Posição do Pedal do Acelerador E",
    0x4C: "Atuador do Acelerador Comandado",
    0x51: "Tipo de Combustível do Veículo",
    0x5C: "Temperatura do Óleo do Motor",
  }; */
