import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MODELOS ---

class TechnicalSensorData {
  final String name;
  final String whatIsIt;
  final String function;
  final String impact;

  TechnicalSensorData({
    required this.name,
    required this.whatIsIt,
    required this.function,
    required this.impact,
  });

  factory TechnicalSensorData.fromJson(Map<String, dynamic> json) {
    return TechnicalSensorData(
      name: json['name'] ?? '',
      whatIsIt: json['whatIsIt'] ?? '',
      function: json['function'] ?? '',
      impact: json['impact'] ?? '',
    );
  }
}

class TechnicalDtcData {
  final String title;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> howToTestAndFix;

  TechnicalDtcData({
    required this.title,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.howToTestAndFix,
  });

  factory TechnicalDtcData.fromJson(Map<String, dynamic> json) {
    return TechnicalDtcData(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      howToTestAndFix: List<String>.from(json['howToTestAndFix'] ?? []),
    );
  }
}

// --- SERVIÇO E PROVIDER ---

class TechnicalDataService {
  Map<String, TechnicalSensorData> _sensors = {};
  Map<String, TechnicalDtcData> _dtcs = {};

  Future<void> loadData(String languageCode) async {
    // Tenta carregar o idioma selecionado. Se o arquivo não existir (ex: não traduzimos pro Russo ainda),
    // ele cai no bloco catch e carrega o Inglês (en) como fallback (padrão de segurança).

    // 1. Carregar Sensores
    try {
      final String sensorJson = await rootBundle.loadString(
        'assets/data/sensors/sensors_$languageCode.json',
      );
      final Map<String, dynamic> sensorMap = json.decode(sensorJson);
      _sensors = sensorMap.map(
        (key, value) => MapEntry(key, TechnicalSensorData.fromJson(value)),
      );
    } catch (e) {
      final String fallback = await rootBundle.loadString(
        'assets/data/sensors/sensors_en.json',
      );
      final Map<String, dynamic> sensorMap = json.decode(fallback);
      _sensors = sensorMap.map(
        (key, value) => MapEntry(key, TechnicalSensorData.fromJson(value)),
      );
    }

    // 2. Carregar DTCs
    try {
      final String dtcJson = await rootBundle.loadString(
        'assets/data/dtcs/dtcs_$languageCode.json',
      );
      final Map<String, dynamic> dtcMap = json.decode(dtcJson);
      _dtcs = dtcMap.map(
        (key, value) => MapEntry(key, TechnicalDtcData.fromJson(value)),
      );
    } catch (e) {
      final String fallback = await rootBundle.loadString(
        'assets/data/dtcs/dtcs_en.json',
      );
      final Map<String, dynamic> dtcMap = json.decode(fallback);
      _dtcs = dtcMap.map(
        (key, value) => MapEntry(key, TechnicalDtcData.fromJson(value)),
      );
    }
  }

  TechnicalSensorData? getSensorData(String hexId) {
    return _sensors[hexId.toUpperCase()];
  }

  TechnicalDtcData? getDtcData(String dtcCode) {
    return _dtcs[dtcCode.toUpperCase()];
  }
}

// Provider Global do Riverpod para acessarmos os dados em qualquer tela
final technicalDataProvider = Provider<TechnicalDataService>((ref) {
  return TechnicalDataService();
});
