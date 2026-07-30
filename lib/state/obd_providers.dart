import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../connection/obd_connection.dart';
import '../connection/obd_manager.dart';

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
  connected, // Tudo pronto, lendo dados!
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
