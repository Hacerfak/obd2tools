import '../../state/obd_providers.dart';

class Mode06Parser {
  static List<Mode06Result> parse(String cleanHex) {
    List<Mode06Result> results = [];

    // Acha onde começa a resposta
    int cursor = cleanHex.indexOf("46");
    if (cursor == -1) return results;

    cursor += 2; // Pula os 2 caracteres do "46" para alinhar a leitura!

    // Em redes CAN, os dados vêm em blocos contínuos de exatos 18 caracteres (9 bytes):
    // [MID](2) [TID](2) [UAS](2) [VAL](4) [MIN](4) [MAX](4)
    while (cursor + 18 <= cleanHex.length) {
      String block = cleanHex.substring(cursor, cursor + 18);

      // Pula lixo de preenchimento da rede CAN (ex: AAAAAA ou 0000000000000000)
      if (block.startsWith("0000000000000000") || block.contains("AAAAAAAA")) {
        cursor += 18;
        continue;
      }

      try {
        int mid = int.parse(block.substring(0, 2), radix: 16);
        int tid = int.parse(block.substring(2, 4), radix: 16);
        int uas = int.parse(
          block.substring(4, 6),
          radix: 16,
        ); // UAS (Unidade/Escala)
        int value = int.parse(block.substring(6, 10), radix: 16);
        int min = int.parse(block.substring(10, 14), radix: 16);
        int max = int.parse(block.substring(14, 18), radix: 16);

        results.add(
          Mode06Result(
            mid: mid,
            tid: tid,
            cid: uas, // Usamos a propriedade CID para guardar o UAS
            value: value,
            min: min,
            max: max,
          ),
        );
      } catch (e) {
        // Ignora blocos corrompidos
      }

      // Avança exatamente os 18 caracteres para o próximo teste!
      cursor += 18;
    }

    return results;
  }

  // Tradutor Oficial de MIDs da Norma SAE J1979
  static String getMonitorName(int mid) {
    if (mid >= 0x01 && mid <= 0x10) {
      return "Sonda Lambda (O2) - Sensor 0x${mid.toRadixString(16).toUpperCase()}";
    }
    if (mid >= 0x21 && mid <= 0x24) return "Catalisador - Banco ${mid - 0x20}";
    if (mid >= 0x31 && mid <= 0x34) return "Sistema EGR - Banco ${mid - 0x30}";
    if (mid >= 0x35 && mid <= 0x38) {
      return "Comando de Válvulas (VVT) - Banco ${mid - 0x34}";
    }
    if (mid >= 0x39 && mid <= 0x3F) {
      return "Sistema Evaporativo (EVAP) - Teste 0x${mid.toRadixString(16).toUpperCase()}";
    }
    if (mid >= 0x41 && mid <= 0x50) {
      return "Aquecedor da Sonda Lambda - Sensor 0x${mid.toRadixString(16).toUpperCase()}";
    }
    if (mid >= 0x71 && mid <= 0x74) {
      return "Sistema de Ar Secundário - Banco ${mid - 0x70}";
    }
    if (mid >= 0x81 && mid <= 0x84) {
      return "Sistema de Combustível - Banco ${mid - 0x80}";
    }
    if (mid >= 0xA1 && mid <= 0xAF) {
      return "Misfire (Falha de Ignição) - Cilindro ${mid - 0xA0}";
    }
    if (mid == 0xB0) return "Misfire (Falha de Ignição) - Todos os Cilindros";
    if (mid >= 0xE1 && mid <= 0xFF) {
      return "Monitoramento Proprietário GM (0x${mid.toRadixString(16).toUpperCase()})";
    }

    return "Monitor OBD (0x${mid.toRadixString(16).padLeft(2, '0').toUpperCase()})";
  }
}
