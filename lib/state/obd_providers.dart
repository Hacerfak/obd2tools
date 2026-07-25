import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/parsers/mode_01_parser.dart';

// ============================================================================
// TÚNEL 1: DADOS EM TEMPO REAL (Modo 01)
// ============================================================================

class RealTimeDataNotifier extends Notifier<Map<String, ObdReadResult>> {
  @override
  Map<String, ObdReadResult> build() {
    return {}; // O estado inicial é um mapa vazio
  }

  // O ObdManager vai chamar esta função para injetar novos dados!
  void updateData(Map<String, ObdReadResult> newData) {
    // Mesclamos os dados antigos com os novos.
    // Isso garante que se o RPM atualizar, a Temperatura não some da tela.
    state = {...state, ...newData};
  }

  void clearData() {
    state = {};
  }
}

// O provedor (túnel) que o Flutter vai escutar
final realTimeStateProvider =
    NotifierProvider<RealTimeDataNotifier, Map<String, ObdReadResult>>(() {
      return RealTimeDataNotifier();
    });

// ============================================================================
// TÚNEL 2: INFORMAÇÕES DO VEÍCULO (Modo 09)
// ============================================================================

class VehicleInfoNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    return {};
  }

  void updateInfo(Map<String, String> newInfo) {
    state = {...state, ...newInfo};
  }
}

final vehicleInfoStateProvider =
    NotifierProvider<VehicleInfoNotifier, Map<String, String>>(() {
      return VehicleInfoNotifier();
    });

// ============================================================================
// TÚNEL 3: AUTO-DESCOBERTA DE SENSORES (PIDs Suportados)
// ============================================================================

class SupportedPidsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return {}; // Começa vazio
  }

  void addPids(List<int> pids) {
    state = {...state, ...pids};
  }

  void clear() {
    state = {};
  }
}

final supportedPidsProvider = NotifierProvider<SupportedPidsNotifier, Set<int>>(
  () {
    return SupportedPidsNotifier();
  },
);
