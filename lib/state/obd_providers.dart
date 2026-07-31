import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../connection/obd_connection.dart';
import '../models/dtc_fault.dart';
import '../connection/obd_manager.dart';
import 'package:flutter/material.dart';

// ============================================================================
// CONTROLE DE TEMA (CLARO/ESCURO/SISTEMA)
// ============================================================================
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// ============================================================================
// TÚNEL 1: DADOS EM TEMPO REAL COM HISTÓRICO (Modo 01)
// ============================================================================

// Nova classe que guarda o valor atual e a linha do tempo para o gráfico
class SensorData {
  final double value;
  final String unit;
  final List<double> history; // Guarda os últimos valores

  SensorData(this.value, this.unit, this.history);
}

class RealTimeDataNotifier extends Notifier<Map<String, SensorData>> {
  final int maxHistoryPoints = 30; // Quantos pontos o gráfico vai mostrar

  @override
  Map<String, SensorData> build() {
    return {};
  }

  void updateData(Map<String, ObdReadResult> newData) {
    // Cria uma cópia do estado atual para podermos editar
    final newState = Map<String, SensorData>.from(state);

    newData.forEach((nome, resultado) {
      final existingData = newState[nome];

      // Pega o histórico antigo ou cria um novo se for a primeira vez
      List<double> history = existingData != null
          ? List<double>.from(existingData.history)
          : [];

      history.add(resultado.value);

      // Remove o ponto mais antigo se passar do limite (faz o gráfico andar para frente)
      if (history.length > maxHistoryPoints) {
        history.removeAt(0);
      }

      newState[nome] = SensorData(resultado.value, resultado.unit, history);
    });

    state = newState; // Atualiza a tela
  }

  void clearData() {
    state = {};
  }
}

final realTimeStateProvider =
    NotifierProvider<RealTimeDataNotifier, Map<String, SensorData>>(() {
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

// ============================================================================
// TÚNEL 4: O GERENTE DE COMANDOS (ObdManager Global)
// ============================================================================

final obdManagerProvider = Provider<ObdManager>((ref) {
  // Cria a conexão e o manager, passando o 'ref' para que o manager
  // consiga injetar dados nos outros túneis automaticamente!
  final connection = ObdConnection();
  return ObdManager(connection: connection, ref: ref);
});

// ============================================================================
// TÚNEL 5: ESTADO DA CONEXÃO E ECU
// ============================================================================

enum AppConnectionState {
  disconnected,
  connectingBluetooth,
  waitingForEcu, // Bluetooth conectou, mas a chave está desligada!
  discoveringSensors, // NOVO: ECU respondeu, mapeando PIDs...
  ready, // NOVO: Tudo pronto, partiu Dashboard!
}

class ConnectionStateNotifier extends Notifier<AppConnectionState> {
  @override
  AppConnectionState build() => AppConnectionState.disconnected;

  void updateState(AppConnectionState newState) {
    state = newState;
  }
}

final connectionStateProvider =
    NotifierProvider<ConnectionStateNotifier, AppConnectionState>(() {
      return ConnectionStateNotifier();
    });

// ============================================================================
// TÚNEL 6: DIAGNÓSTICO DE FALHAS AVANÇADO (DTC)
// ============================================================================
class DtcState {
  final bool isLoading;
  final Map<String, DtcFault> faults; // Chave é o código (ex: P0118)

  DtcState({required this.isLoading, required this.faults});
}

class DtcNotifier extends Notifier<DtcState> {
  @override
  DtcState build() => DtcState(isLoading: false, faults: {});

  void setLoading(bool loading) {
    state = DtcState(isLoading: loading, faults: state.faults);
  }

  // Adiciona códigos vindos de um modo específico
  void addCodes(List<String> codes, DtcStatus status) {
    final updatedFaults = Map<String, DtcFault>.from(state.faults);

    for (String code in codes) {
      if (updatedFaults.containsKey(code)) {
        updatedFaults[code]!.addStatus(status);
      } else {
        updatedFaults[code] = DtcFault(code: code, statuses: {status});
      }
    }

    // CORREÇÃO: Usa o 'state.isLoading' atual em vez de cravar 'false'.
    // O carregamento só vai terminar quando o Manager mandar!
    state = DtcState(isLoading: state.isLoading, faults: updatedFaults);
  }

  // Anexa o Freeze Frame ao primeiro erro Confirmado que encontrar
  // (Pois o Frame 00 pertence à falha principal que acendeu a luz)
  void attachFreezeFrame(Map<String, ObdReadResult> data) {
    final updatedFaults = Map<String, DtcFault>.from(state.faults);

    for (var fault in updatedFaults.values) {
      if (fault.statuses.contains(DtcStatus.confirmed)) {
        fault.freezeFrame = data;
        break; // O Frame 00 geralmente se aplica ao principal
      }
    }

    state = DtcState(isLoading: state.isLoading, faults: updatedFaults);
  }

  void clearCodes() {
    state = DtcState(isLoading: false, faults: {});
  }
}

final dtcStateProvider = NotifierProvider<DtcNotifier, DtcState>(() {
  return DtcNotifier();
});

// ============================================================================
// TÚNEL 7: FREEZE FRAME (MODO 02)
// ============================================================================
class FreezeFrameState {
  final bool isLoading;
  final Map<String, ObdReadResult> data;

  FreezeFrameState({required this.isLoading, required this.data});
}

class FreezeFrameNotifier extends Notifier<FreezeFrameState> {
  @override
  FreezeFrameState build() => FreezeFrameState(isLoading: false, data: {});

  void setLoading(bool loading) {
    state = FreezeFrameState(isLoading: loading, data: state.data);
  }

  void addData(Map<String, ObdReadResult> newData) {
    final updatedData = Map<String, ObdReadResult>.from(state.data)
      ..addAll(newData);
    state = FreezeFrameState(isLoading: false, data: updatedData);
  }

  void clear() {
    state = FreezeFrameState(isLoading: false, data: {});
  }
}

final freezeFrameProvider =
    NotifierProvider<FreezeFrameNotifier, FreezeFrameState>(() {
      return FreezeFrameNotifier();
    });
