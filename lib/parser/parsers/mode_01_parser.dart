import '../registries/mode_01_registry.dart';

// Classe que empacota o valor, a unidade e os bytes brutos
class ObdReadResult {
  final double value;
  final String unit;
  final List<int>? rawBytes;

  ObdReadResult(this.value, this.unit, {this.rawBytes});
}

class Mode01Parser {
  static List<int> parseSupportedPids(String dataHex, int basePid) {
    List<int> supported = [];
    if (dataHex.length < 8) return supported;
    int bitmask = int.parse(dataHex.substring(0, 8), radix: 16);
    int mask = 0x80000000;
    for (int i = 1; i <= 32; i++) {
      if ((bitmask & mask) != 0) {
        supported.add(basePid + i);
      }
      mask = mask >> 1;
    }
    return supported;
  }

  static Map<String, ObdReadResult> parse(String cleanHex) {
    Map<String, ObdReadResult> results = {};
    int cursor = cleanHex.indexOf("41");
    if (cursor == -1) return results;
    cursor += 2;

    while (cursor + 2 <= cleanHex.length) {
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      int pidId = int.parse(pidHex, radix: 16);
      cursor += 2;

      if (pidRegistry.containsKey(pidId)) {
        final pid = pidRegistry[pidId]!;
        int dataChars = pid.expectedBytes * 2;
        if (cursor + dataChars <= cleanHex.length) {
          String dataHex = cleanHex.substring(cursor, cursor + dataChars);
          List<int> bytes = [];
          for (int j = 0; j < dataChars; j += 2) {
            bytes.add(int.parse(dataHex.substring(j, j + 2), radix: 16));
          }
          results[pid.name] = ObdReadResult(
            pid.calculate(bytes),
            pid.unit,
            rawBytes: bytes,
          );
          cursor += dataChars;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    return results;
  }

  static Map<int, ObdReadResult> parseAsIntKeys(String cleanHex) {
    Map<int, ObdReadResult> results = {};
    int cursor = cleanHex.indexOf("41");
    if (cursor == -1) return results;
    cursor += 2;
    while (cursor + 2 <= cleanHex.length) {
      String pidHex = cleanHex.substring(cursor, cursor + 2);
      int pidId = int.parse(pidHex, radix: 16);
      cursor += 2;
      if (pidRegistry.containsKey(pidId)) {
        final pid = pidRegistry[pidId]!;
        int dataChars = pid.expectedBytes * 2;
        if (cursor + dataChars <= cleanHex.length) {
          String dataHex = cleanHex.substring(cursor, cursor + dataChars);
          List<int> bytes = [];
          for (int j = 0; j < dataChars; j += 2) {
            bytes.add(int.parse(dataHex.substring(j, j + 2), radix: 16));
          }
          results[pidId] = ObdReadResult(
            pid.calculate(bytes),
            pid.unit,
            rawBytes: bytes,
          );
          cursor += dataChars;
        } else
          break;
      } else
        break;
    }
    return results;
  }
}
