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

  /// Tradutor de MIDs internacionalizado
  static String getMonitorName(int mid, AppLocalizations l10n) {
    String hexStr = mid.toRadixString(16).toUpperCase();

    if (mid >= 0x01 && mid <= 0x10) return l10n.midO2Sensor(hexStr);
    if (mid >= 0x21 && mid <= 0x24) return l10n.midCatalyst("${mid - 0x20}");
    if (mid >= 0x31 && mid <= 0x34) return l10n.midEgr("${mid - 0x30}");
    if (mid >= 0x35 && mid <= 0x38) return l10n.midVvt("${mid - 0x34}");

    if (mid == 0x39) return l10n.midEvapGeneral;
    if (mid == 0x3A) return l10n.midEvapVacuumInit;
    if (mid == 0x3B) return l10n.midEvapGrossLeak;
    if (mid == 0x3C) return l10n.midEvapMedLeak;
    if (mid == 0x3D) return l10n.midEvapSmallLeak;
    if (mid == 0x3E) return l10n.midEvapPurgeValve;
    if (mid == 0x3F) return l10n.midEvapVentValve;

    if (mid >= 0x41 && mid <= 0x50) return l10n.midO2Heater(hexStr);
    if (mid >= 0x71 && mid <= 0x74) return l10n.midSecAir("${mid - 0x70}");
    if (mid >= 0x81 && mid <= 0x84) return l10n.midFuelSystem("${mid - 0x80}");
    if (mid >= 0xA2 && mid <= 0xAF)
      return l10n.midMisfireCylinder("${mid - 0xA1}");
    if (mid == 0xB0) return l10n.midMisfireAll;
    if (mid >= 0xE1 && mid <= 0xFF) return l10n.midProprietary(hexStr);

    return l10n.midObd(hexStr.padLeft(2, '0'));
  }

  /// Tradutor de TIDs internacionalizado
  static String getTidDescription(int tid, AppLocalizations l10n) {
    switch (tid) {
      case 0x01:
        return l10n.tidO2RichToLean;
      case 0x02:
        return l10n.tidO2LeanToRich;
      case 0x03:
        return l10n.tidO2MinVoltage;
      case 0x04:
        return l10n.tidO2MaxVoltage;
      case 0x0B:
        return l10n.tidMisfireEwma;
      case 0x0C:
        return l10n.tidMisfireCurrent;
      case 0x31:
        return l10n.tidEvapPurgeRate;
      case 0x32:
        return l10n.tidEvapInitGrad;
      case 0x33:
        return l10n.tidEvapTankDelta;
      case 0x34:
        return l10n.tidEvapVacDecay;
      case 0xC0:
        return l10n.tidEvapInitStab;
      case 0xC1:
        return l10n.tidEvapCanisterVac;
      case 0xC4:
        return l10n.tidEvapVentFlow;
      case 0xC5:
        return l10n.tidEvapSolResponse;
      case 0xC6:
        return l10n.tidEvapLinePress;
      case 0xC7:
        return l10n.tidEvapSensorResp;
      case 0xC8:
        return l10n.tidEvapSmallDecay;
      case 0xC9:
        return l10n.tidEvapMedDecay;
      case 0xCA:
        return l10n.tidEvapGrossHold;
      case 0xCB:
        return l10n.tidEvapMinPurgePress;
      default:
        return l10n.tidGeneric(
          tid.toRadixString(16).padLeft(2, '0').toUpperCase(),
        );
    }
  }

  /// Tradutor de CIDs/UAS internacionalizado
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
