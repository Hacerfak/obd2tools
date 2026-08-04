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
  // --- COMPLEMENTOS DO BLOCO 1 (Fuel Trims e Pressão) ---
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
  0x34: ObdPid(
    id: 0x34,
    name: "Sonda Lambda 1 (B1S1) - Relação Equivalência",
    unit: "λ",
    expectedBytes: 4,
    // Sensores de banda larga (Wideband) usam os Bytes A e B para Lambda, C e D para Tensão
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
  // --- COMPLEMENTOS DO BLOCO 3 (0x41 a 0x60) ---
  0x48: ObdPid(
    id: 0x48,
    name: "Posição Absoluta Borboleta C",
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
    formatValue: (value) {
      int val = value.toInt();
      switch (val) {
        case 0:
          return "Não Disponível";
        case 1:
          return "Gasolina";
        case 2:
          return "Metanol";
        case 3:
          return "Etanol";
        case 4:
          return "Diesel";
        case 5:
          return "GPL (Gás Liquefeito de Petróleo)";
        case 6:
          return "GNV (Gás Natural Veicular)";
        case 7:
          return "Propano";
        case 8:
          return "Elétrico";
        case 9:
          return "Bifuel (Mistura Flex)";
        case 10:
          return "Híbrido (Gasolina/Elétrico)";
        case 11:
          return "Híbrido (Etanol/Elétrico)";
        case 12:
          return "Híbrido (Diesel/Elétrico)";
        case 23:
          return "E85 (85% Etanol)";
        default:
          return "Outro/Desconhecido ($val)";
      }
    },
  ),
  0x52: ObdPid(
    id: 0x52,
    name: "Percentual de Etanol no Combustível",
    unit: "%",
    expectedBytes: 1,
    calculate: (bytes) => (bytes[0] / 255.0) * 100.0,
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
      if (value < 70) return SensorHealth.warning; // Óleo frio
      if (value >= 70 && value <= 110) return SensorHealth.normal; // Ideal
      if (value > 110 && value <= 125) {
        return SensorHealth.warning;
      } // Esquentando bem
      return SensorHealth.critical; // Passando do limite de viscosidade segura
    },
  ),
  0x5D: ObdPid(
    id: 0x5D,
    name: "Ponto de Injeção de Combustível",
    unit: "°",
    expectedBytes: 2,
    // (A * 256 + B) / 128 - 210
    calculate: (bytes) => (((bytes[0] * 256) + bytes[1]) / 128.0) - 210.0,
  ),
  0x5E: ObdPid(
    id: 0x5E,
    name: "Consumo de Combustível (Vazão)",
    unit: "L/h",
    expectedBytes: 2,
    // (A * 256 + B) / 20
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 20.0,
    isFast: true,
  ),
  // --- COMPLEMENTOS FINAIS DO BLOCO 3 ---
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
  0x5F: ObdPid(
    id: 0x5F,
    name: "Norma de Emissões Projetada",
    unit: "",
    expectedBytes: 1,
    calculate: (bytes) => bytes[0].toDouble(),
    formatValue: (value) {
      int val = value.toInt();
      // Retornos simplificados baseados na tabela de emissões da SAE
      if (val == 1 || val == 2 || val == 3) return "Padrão OBD/OBD-II";
      if (val >= 4 && val <= 8) return "Padrão Europeu (EOBD)";
      if (val >= 9 && val <= 13) return "Padrão Japonês (JOBD)";
      if (val == 14 || val == 15) return "Padrão Euro IV / V";
      if (val >= 31 && val <= 37) return "Padrão Brasileiro (OBDBr)";
      return "Padrão Regional ($val)";
    },
  ),

  // --- BLOCO 4 (0x61 a 0x80) - TORQUE E EXAUSTÃO ---
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
    expectedBytes: 4, // Sensores MAF avançados usam mais bytes
    // (A * 256 + B) / 32
    calculate: (bytes) => ((bytes[0] * 256) + bytes[1]) / 32.0,
    isFast: true,
  ),
  0x67: ObdPid(
    id: 0x67,
    name: "Temp. Arrefecimento (Sensores Múltiplos)",
    unit: "°C",
    expectedBytes: 3,
    // Byte A é a máscara, Byte B é o Sensor 1, Byte C é o Sensor 2
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
    expectedBytes: 4,
    // (B * 256 + C) / 10 - 40 (Ignoramos o Byte A que é máscara)
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0,
  ),
  0x79: ObdPid(
    id: 0x79,
    name: "Temp. Gases de Escape (EGT) - Banco 2",
    unit: "°C",
    expectedBytes: 4,
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0,
  ),
  // --- BLOCO 5 (0x81 a 0xA0) - EMISSÕES AVANÇADAS E HÍBRIDOS ---
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
  // --- BLOCO 6 (0xA1 a 0xC0) - DADOS AVANÇADOS, TURBO E HODÔMETRO ---
  0xA1: ObdPid(
    id: 0xA1,
    name: "Dados de Injeção (Taxa e Tempo)",
    unit: "",
    expectedBytes: 4,
    // (A * 256 + B) para a taxa, C e D para o tempo. Retornando a Taxa.
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
    // Byte A é máscara. B e C formam a temperatura.
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0,
  ),
  0xA6: ObdPid(
    id: 0xA6,
    name: "Hodômetro (Quilometragem da ECU)",
    unit: "km",
    expectedBytes: 4,
    // A mágica de 4 bytes para distâncias gigantes: (A*2^24 + B*2^16 + C*2^8 + D) / 10
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
    calculate: (bytes) =>
        (((bytes[1] * 256) + bytes[2]) / 10.0), // Ignora máscara no A
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
    // Byte A é máscara. Lendo o Banco 1 (Byte B).
    calculate: (bytes) => bytes[1] - 40.0,
    evaluateHealth: (value) {
      if (value < 60) return SensorHealth.normal;
      if (value >= 60 && value < 90) return SensorHealth.warning;
      return SensorHealth
          .critical; // Intercooler muito quente, perdendo eficiência do turbo!
    },
  ),
  0xAB: ObdPid(
    id: 0xAB,
    name: "Pressão do Sistema de Injeção",
    unit: "kPa",
    expectedBytes: 4,
    calculate: (bytes) =>
        ((bytes[1] * 256) + bytes[2]) * 10.0, // Ignora máscara no A
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
    // Byte A (máscara). B e C (Banco 1, Sensor 1)
    calculate: (bytes) => (((bytes[1] * 256) + bytes[2]) / 10.0) - 40.0,
  ),
  // --- BLOCOS 7 e 8 (0xC1 a 0xFF) - DIESEL, DPF E ELETRÓGENOS ---
  0xC4: ObdPid(
    id: 0xC4,
    name: "Controle da Válvula EGR (Avançado)",
    unit: "%",
    expectedBytes: 4,
    // Byte A (máscara). B e C formam a porcentagem
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
    formatValue: (value) {
      int val = value.toInt();
      // Verificação simples por bitmask (se > 0, há regeneração ou controle ativo)
      return val > 0 ? "Regeneração Ativa / Aquecimento" : "Modo Normal";
    },
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
