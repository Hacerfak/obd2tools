import '../obd_pid.dart';

final Map<int, ObdPid> pidRegistry = {
  // --- BLOCO 1 (0x01 a 0x20) ---
  0x01: ObdPid(
    id: 0x01,
    name: "Status dos Monitores DTC",
    unit: "",
    expectedBytes: 4,
    calculate: (bytes) => bytes[0].toDouble(), // Analisamos o Byte A
    formatValue: (value) {
      int val = value.toInt();
      // O 8º bit (128) indica se a Luz de Injeção (MIL) está acesa
      bool isMilOn = (val & 0x80) != 0;
      // Os 7 bits restantes (0 a 127) indicam a quantidade de falhas gravadas
      int dtcCount = val & 0x7F;
      return "Luz ${isMilOn ? 'Acesa' : 'Apagada'} ($dtcCount Erros)";
    },
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
    isFast: true, // NOVO
  ),
  0x05: ObdPid(
    id: 0x05,
    name: "Temp. Arrefecimento (Motor)",
    unit: "°C",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0] - 40.0,
    evaluateHealth: (value) {
      if (value < 75) return SensorHealth.warning; // Motor frio
      if (value >= 75 && value <= 105) {
        return SensorHealth.normal;
      } // Temperatura ideal de trabalho
      if (value > 105 && value <= 115) {
        return SensorHealth.warning;
      } // Esquentar um pouco na subida
      return SensorHealth.critical; // Ferveu!
    },
  ),
  0x0B: ObdPid(
    id: 0x0B,
    name: "Pressão Admissão (MAP)",
    unit: "kPa",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    isFast: true, // NOVO
  ),
  0x0C: ObdPid(
    id: 0x0C,
    name: "Rotação do Motor (RPM)",
    unit: "RPM",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 4.0,
    isFast: true, // NOVO
  ),
  0x0D: ObdPid(
    id: 0x0D,
    name: "Velocidade do Veículo",
    unit: "km/h",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    isFast: true, // NOVO
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
      if ((value > 50.0 && value <= 70.0)) {
        return SensorHealth.warning;
      }
      return SensorHealth.critical; // Ar de admissão muito quente!
    },
  ),
  0x10: ObdPid(
    id: 0x10,
    name: "Fluxo de Ar (MAF)",
    unit: "g/s",
    expectedBytes: 2,
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 100.0,
    isFast: true, // NOVO
  ),
  0x11: ObdPid(
    id: 0x11,
    name: "Posição do Acelerador (TPS)",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    isFast: true, // NOVO
  ),
  0x13: ObdPid(
    id: 0x13,
    name: "Sensores de Oxigênio Presentes",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    formatValue: (value) {
      // Cada bit '1' representa uma Sonda Lambda presente no escapamento.
      // Convertendo para binário e contando os '1's:
      int count = value
          .toInt()
          .toRadixString(2)
          .split('')
          .where((e) => e == '1')
          .length;
      return "$count Sensor(es) Detectado(s)";
    },
  ),
  0x1C: ObdPid(
    id: 0x1C,
    name: "Padrão OBD Suportado",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    formatValue: (value) {
      int val = value.toInt();
      switch (val) {
        case 1:
          return "OBD-II (EUA)";
        case 2:
          return "OBD (Federal EPA - EUA)";
        case 3:
          return "OBD e OBD-II";
        case 4:
          return "OBD-I";
        case 5:
          return "Não Projetado para OBD";
        case 6:
          return "EOBD (Europa)";
        case 7:
          return "EOBD e OBD-II";
        case 8:
          return "EOBD e OBD";
        case 9:
          return "EOBD, OBD e OBD-II";
        case 10:
          return "JOBD (Japão)";
        case 11:
          return "JOBD e OBD-II";
        case 12:
          return "JOBD e EOBD";
        case 13:
          return "JOBD, EOBD e OBD-II";
        case 14:
          return "Heavy Duty (Euro IV B1)";
        case 15:
          return "Heavy Duty (Euro V B2)";
        case 16:
          return "Heavy Duty (Euro EEV C)";
        case 17:
          return "EMD (Diagnóstico do Fabricante)";
        case 18:
          return "EMD+ (Diagnóstico Avançado)";
        case 19:
          return "HD OBD-C (Heavy Duty Parcial)";
        case 20:
          return "HD OBD (Heavy Duty EUA)";
        case 21:
          return "WWH OBD (Padrão Mundial Harmonizado)";
        // O valor 22 é historicamente reservado/sem uso na tabela
        case 23:
          return "HD EOBD-I (Heavy Duty Euro I)";
        case 24:
          return "HD EOBD-I N (Com Controle de NOx)";
        case 25:
          return "HD EOBD-II";
        case 26:
          return "HD EOBD-II N (Com Controle de NOx)";
        case 27:
          return "HD EOBD-III";
        case 28:
          return "HD EOBD-IV";
        case 29:
          return "HD EOBD-V";
        // O valor 30 também é reservado
        case 31:
          return "OBDBr-1 (Brasil)";
        case 32:
          return "OBDBr-2 (Brasil)";
        case 33:
          return "KOBD (Coreia do Sul)";
        case 34:
          return "India OBD I";
        case 35:
          return "India OBD II";
        case 36:
          return "HD EOBD-VI";
        case 37:
          return "OBDBr-3 (Brasil)";
        case 38:
          return "India OBD III";
        case 39:
          return "India OBD IV";
        default:
          return "Reservado/Desconhecido ($val)";
      }
    },
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
    evaluateHealth: (value) {
      if (value >= 15.0) return SensorHealth.normal;
      if ((value >= 5.0 && value < 15.0)) {
        return SensorHealth.warning; //Tanque na reserva
      }
      return SensorHealth.critical; // Muito abaixo da reserva
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

  // --- BLOCO 3 (0x41 a 0x60) ---
  0x41: ObdPid(
    id: 0x41,
    name: "Status Monitores (Ciclo Atual)",
    unit: "",
    expectedBytes: 4,
    calculate: (bytes) => bytes[0].toDouble(),
    formatValue: (value) {
      int val = value.toInt();
      // Similar ao 0x01, mas focado no ciclo de direção atual
      int dtcCount = val & 0x7F;
      if (dtcCount == 0) return "Limpos (Sem Falhas)";
      return "$dtcCount Falha(s) neste ciclo";
    },
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
    isFast: true, // NOVO
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
      return SensorHealth.critical; // Mistura perigosamente rica ou pobre
    },
  ),
  0x45: ObdPid(
    id: 0x45,
    name: "Posição Relativa da Borboleta",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
    isFast: true, // NOVO
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
