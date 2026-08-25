import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/parsers/egt_parser.dart';

class SensorTechData {
  final String name;
  final String shortName;
  final String whatIsIt;
  final String function;
  final String impact;
  final Map<String, String>? valueMap;

  SensorTechData({
    required this.name,
    required this.shortName,
    required this.whatIsIt,
    required this.function,
    required this.impact,
    this.valueMap,
  });

  factory SensorTechData.fromJson(Map<String, dynamic> json) {
    return SensorTechData(
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? json['name'] ?? '',
      whatIsIt: json['whatIsIt'] ?? '',
      function: json['function'] ?? '',
      impact: json['impact'] ?? '',
      valueMap: json['valueMap'] != null
          ? Map<String, String>.from(json['valueMap'])
          : null,
    );
  }
}

class DtcTechData {
  final String title;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> howToTestAndFix;

  DtcTechData({
    required this.title,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.howToTestAndFix,
  });

  factory DtcTechData.fromJson(Map<String, dynamic> json) {
    return DtcTechData(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      howToTestAndFix: List<String>.from(json['howToTestAndFix'] ?? []),
    );
  }
}

class Mode06TechData {
  final String title;
  final String purpose;
  final List<String> sensorsUsed;
  final String howItIsMeasured;

  Mode06TechData({
    required this.title,
    required this.purpose,
    required this.sensorsUsed,
    required this.howItIsMeasured,
  });

  factory Mode06TechData.fromJson(Map<String, dynamic> json) {
    return Mode06TechData(
      title: json['title'] ?? '',
      purpose: json['purpose'] ?? '',
      sensorsUsed: List<String>.from(json['sensorsUsed'] ?? []),
      howItIsMeasured: json['howItIsMeasured'] ?? '',
    );
  }
}

class TechnicalDataService {
  Map<String, SensorTechData> _sensorMap = {};
  Map<String, DtcTechData> _dtcMap = {};
  Map<String, Mode06TechData> _mode06Map = {};
  Map<String, dynamic> _mode09RawMap = {};

  Future<void> loadData(String languageCode) async {
    String lang =
        [
          'pt',
          'en',
          'es',
          'de',
          'fr',
          'hi',
          'ja',
          'ru',
          'zh',
          'ar',
        ].contains(languageCode)
        ? languageCode
        : 'en';

    // 1. Carrega Sensores com fallback para Inglês
    final sensorMapRaw = await _loadJsonWithFallback(
      'sensors',
      'sensors',
      lang,
    );
    _sensorMap = sensorMapRaw.map(
      (key, value) => MapEntry(key, SensorTechData.fromJson(value)),
    );

    // 2. Carrega DTCs com fallback para Inglês
    final dtcMapRaw = await _loadJsonWithFallback('dtcs', 'dtcs', lang);
    _dtcMap = dtcMapRaw.map(
      (key, value) => MapEntry(key, DtcTechData.fromJson(value)),
    );

    // 3. Carrega Modo 06 com fallback para Inglês
    final mode06MapRaw = await _loadJsonWithFallback('mode06', 'mode06', lang);
    _mode06Map = mode06MapRaw.map(
      (key, value) => MapEntry(key, Mode06TechData.fromJson(value)),
    );

    // 4. Carrega Modo 09 com fallback para Inglês
    _mode09RawMap = await _loadJsonWithFallback('mode09', 'mode09', lang);
  }

  Future<Map<String, dynamic>> _loadJsonWithFallback(
    String folder,
    String prefix,
    String lang,
  ) async {
    final enMap = await _readJson('assets/data/$folder/${prefix}_en.json');

    if (lang == 'en' || enMap.isEmpty) {
      return enMap;
    }

    final langMap = await _readJson('assets/data/$folder/${prefix}_$lang.json');
    if (langMap.isEmpty) {
      return enMap;
    }

    final merged = Map<String, dynamic>.from(enMap);
    langMap.forEach((key, value) {
      if (merged.containsKey(key) && merged[key] is Map && value is Map) {
        merged[key] = {
          ...Map<String, dynamic>.from(merged[key] as Map),
          ...Map<String, dynamic>.from(value),
        };
      } else {
        merged[key] = value;
      }
    });

    return merged;
  }

  Future<Map<String, dynamic>> _readJson(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  SensorTechData? getSensorData(String hexId) => _sensorMap[hexId];
  DtcTechData? getDtcData(String code) => _dtcMap[code];

  Mode06TechData? getMode06Data(String midHex, String tidHex) {
    final fullKey = "${midHex}_$tidHex";
    if (_mode06Map.containsKey(fullKey)) return _mode06Map[fullKey];
    if (_mode06Map.containsKey(midHex)) return _mode06Map[midHex];
    return null;
  }

  Map<String, dynamic> get mode09Data => _mode09RawMap;

  String getSensorValueDescription(
    String pidHex,
    dynamic rawValue, {
    List<int>? rawBytes,
  }) {
    final upperPid = pidHex.toUpperCase();
    final sensor = _sensorMap[upperPid];
    final valueMap = sensor?.valueMap;

    // --- PID 01: Status dos Monitores DTC (MIL + Quantidade de DTCs) ---
    if (upperPid == "01") {
      int byteA = 0;
      if (rawBytes != null && rawBytes.isNotEmpty) {
        byteA = rawBytes[0];
      } else if (rawValue is num) {
        byteA = rawValue.toInt();
      }
      final bool isMilOn = (byteA & 0x80) != 0;
      final int dtcCount = byteA & 0x7F;

      final milOnText = valueMap?['milOn'] ?? "MIL ON";
      final milOffText = valueMap?['milOff'] ?? "MIL OFF";
      final milText = isMilOn ? milOnText : milOffText;
      final format = valueMap?['format'] ?? "{mil} ({count} Errors)";

      return format
          .replaceAll("{mil}", milText)
          .replaceAll("{count}", dtcCount.toString());
    }

    // --- PID 41: Status dos Monitores no Ciclo de Condução Atual ---
    if (upperPid == "41") {
      int byteA = 0;
      if (rawBytes != null && rawBytes.isNotEmpty) {
        byteA = rawBytes[0];
      } else if (rawValue is num) {
        byteA = rawValue.toInt();
      }
      final int dtcCount = byteA & 0x7F;
      if (dtcCount == 0) {
        return valueMap?['noFaults'] ?? "No Faults in Drive Cycle";
      }
      final faultsFormat =
          valueMap?['faultsFormat'] ?? "{count} Fault(s) in Drive Cycle";
      return faultsFormat.replaceAll("{count}", dtcCount.toString());
    }

    // --- PID 13: Sensores de Oxigênio Presentes (Contagem de bits 1) ---
    if (upperPid == "13") {
      int val = 0;
      if (rawBytes != null && rawBytes.isNotEmpty) {
        val = rawBytes[0];
      } else if (rawValue is num) {
        val = rawValue.toInt();
      }
      int count = 0;
      for (int i = 0; i < 8; i++) {
        if ((val & (1 << i)) != 0) count++;
      }
      final format = valueMap?['format'] ?? "{count} Sensor(s) Detected";
      return format.replaceAll("{count}", count.toString());
    }

    // --- PIDs 78 e 79: EGT Bancos 1 e 2 (Multi-sensores 1 a 4) ---
    if (upperPid == "78" || upperPid == "79") {
      if (rawBytes != null && rawBytes.length >= 9) {
        final bank = upperPid == "78" ? 1 : 2;
        final egt = EgtStatus.fromBytes(rawBytes, bank: bank);
        final activeSensors = egt.sensors.where((s) => s.isSupported).toList();

        if (activeSensors.isEmpty) {
          return valueMap?['noSensors'] ?? "Nenhum Sensor Ativo";
        }

        final label = valueMap?['sensorLabel'] ?? "S";
        return activeSensors
            .map(
              (s) => "$label${s.index}: ${s.temperature.toStringAsFixed(0)}°C",
            )
            .join(" | ");
      }
    }

    // --- DEMAIS PIDs MAPEADOS VIA CHAVE NUMÉRICA (03, 1C, 51, 5F, DF...) ---
    if (valueMap != null) {
      final String key = (rawValue is num)
          ? rawValue.toInt().toString()
          : rawValue.toString();

      if (valueMap.containsKey(key)) {
        return valueMap[key]!;
      }
    }

    // --- FORMATO NUMÉRICO PADRÃO ---
    if (rawValue is double) {
      return rawValue.toStringAsFixed(1);
    }
    return rawValue.toString();
  }
}

final technicalDataProvider = Provider<TechnicalDataService>((ref) {
  return TechnicalDataService();
});
