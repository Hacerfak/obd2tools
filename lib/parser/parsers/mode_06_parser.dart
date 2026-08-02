import '../../state/obd_providers.dart';

class Mode06Parser {
  static List<Mode06Result> parse(String cleanHex) {
    List<Mode06Result> results = [];
    int cursor = 0;

    while (cursor < cleanHex.length) {
      // Localiza o início de uma resposta do Modo 06
      cursor = cleanHex.indexOf("46", cursor);
      if (cursor == -1) break;

      cursor += 2; // Pula o "46"

      // Cada bloco de teste no CAN tem exatos 18 caracteres (9 bytes):
      // [MID](2) [TID](2) [CID](2) [VAL](4) [MIN](4) [MAX](4)
      while (cursor + 18 <= cleanHex.length) {
        // Se encontrar um novo cabeçalho '46', interrompe este bloco e vai pro próximo pacote
        if (cleanHex.startsWith("46", cursor)) {
          break;
        }

        String block = cleanHex.substring(cursor, cursor + 18);

        // Pula lixo de preenchimento da rede CAN (000000... ou AAAAAA...)
        if (block.startsWith("0000000000000000") ||
            block.contains("AAAAAAAA")) {
          cursor += 18;
          continue;
        }

        try {
          int mid = int.parse(block.substring(0, 2), radix: 16);
          int tid = int.parse(block.substring(2, 4), radix: 16);
          int cid = int.parse(block.substring(4, 6), radix: 16);
          int value = int.parse(block.substring(6, 10), radix: 16);
          int min = int.parse(block.substring(10, 14), radix: 16);
          int max = int.parse(block.substring(14, 18), radix: 16);

          // AGORA ELE ADICIONA TODOS OS TESTES, MESMO OS ZERADOS!
          results.add(
            Mode06Result(
              mid: mid,
              tid: tid,
              cid: cid,
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
