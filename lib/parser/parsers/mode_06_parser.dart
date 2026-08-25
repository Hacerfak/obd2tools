import '/l10n/app_localizations.dart';
import '../../state/obd_providers.dart';

class Mode06Parser {
  static List<Mode06Result> parse(String rawHex) {
    List<Mode06Result> results = [];

    String cleanHex = rawHex
        .replaceAll(RegExp(r'^[0-9A-Fa-f]{3}\s+'), '')
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'\d+:'), '')
        .toUpperCase();

    int cursor = cleanHex.indexOf("46");
    while (cursor != -1) {
      int dataStart = cursor + 2;

      String remaining = cleanHex.substring(dataStart);
      if (remaining.length >= 10 &&
          remaining.length <= 12 &&
          RegExp(r'^(00|20|40|60|80|A0|C0|E0)').hasMatch(remaining)) {
        cursor = cleanHex.indexOf("46", dataStart);
        continue;
      }

      int blockCursor = dataStart;
      while (blockCursor + 18 <= cleanHex.length) {
        String block = cleanHex.substring(blockCursor, blockCursor + 18);

        if (block.startsWith("46") ||
            block.contains("AAAAAAAA") ||
            block == "000000000000000000") {
          break;
        }

        try {
          int mid = int.parse(block.substring(0, 2), radix: 16);
          int tid = int.parse(block.substring(2, 4), radix: 16);
          int uas = int.parse(block.substring(4, 6), radix: 16);

          if (mid != 0x00 && mid != 0xFF && tid != 0x00 && tid != 0xFF) {
            int rawVal = int.parse(block.substring(6, 10), radix: 16);
            int rawMin = int.parse(block.substring(10, 14), radix: 16);
            int rawMax = int.parse(block.substring(14, 18), radix: 16);

            int baseUas = uas & 0x7F;
            bool isSigned = (baseUas == 0x0B || baseUas == 0x33);

            int value = (isSigned && rawVal > 0x7FFF)
                ? rawVal - 0x10000
                : rawVal;
            int min = (isSigned && rawMin > 0x7FFF) ? rawMin - 0x10000 : rawMin;
            int max = (isSigned && rawMax > 0x7FFF) ? rawMax - 0x10000 : rawMax;

            if (min < 0) min = 0;
            if (max < 0 || rawMax == 0xFFFF) max = 0;

            if (min > max && max != 0) {
              int temp = min;
              min = max;
              max = temp;
            }

            results.add(
              Mode06Result(
                mid: mid,
                tid: tid,
                cid: uas,
                value: value,
                min: min,
                max: max,
              ),
            );
          }
        } catch (_) {}

        blockCursor += 18;
      }

      cursor = cleanHex.indexOf("46", dataStart);
    }

    if (results.isEmpty) {
      int legacyCursor = cleanHex.indexOf("46");
      if (legacyCursor != -1) {
        int blockCursor = legacyCursor + 2;
        while (blockCursor + 14 <= cleanHex.length) {
          String block = cleanHex.substring(blockCursor, blockCursor + 14);
          if (block.startsWith("46") || block.contains("AAAA")) break;

          try {
            int tid = int.parse(block.substring(0, 2), radix: 16);
            int cid = int.parse(block.substring(2, 4), radix: 16);
            if (tid > 0x00 && tid < 0xFF && cid > 0x00 && cid < 0xFF) {
              int rawVal = int.parse(block.substring(4, 8), radix: 16);
              int rawLimit = int.parse(block.substring(8, 12), radix: 16);

              results.add(
                Mode06Result(
                  mid: 0x00,
                  tid: tid,
                  cid: cid,
                  value: rawVal,
                  min: 0,
                  max: rawLimit == 0xFFFF ? 0 : rawLimit,
                ),
              );
            }
          } catch (_) {}
          blockCursor += 14;
        }
      }
    }

    return results;
  }

  /// Tradutor de CIDs/UAS para Unidades de Medida
  static String getUasUnit(int uas, AppLocalizations l10n) {
    int baseUas = uas & 0x7F;
    switch (baseUas) {
      case 0x01:
        return "mV";
      case 0x02:
        return "V";
      case 0x07:
        return "ms";
      case 0x0A:
        return "kPa";
      case 0x0B:
        return "Pa";
      case 0x10:
        return "RPM";
      case 0x20:
        return "%";
      case 0x30:
        return l10n.unitCounts;
      default:
        return "";
    }
  }
}
