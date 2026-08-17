import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/parsers/mode_01_parser.dart';
import '../connection/obd_connection.dart';
import '../models/dtc_fault.dart';
import '../connection/obd_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// CONTROLE DE TEMA (CLARO/ESCURO/SISTEMA)
// ============================================================================
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system; // Retorna sistema enquanto carrega da memória
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode');
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// ============================================================================
// CONTROLE DE CORES CUSTOMIZADAS (CLARO E ESCURO)
// ============================================================================
class AppColors {
  final Color primary;
  final Color normal;
  final Color warning;
  final Color critical;

  AppColors({
    required this.primary,
    required this.normal,
    required this.warning,
    required this.critical,
  });

  AppColors copyWith({
    Color? primary,
    Color? normal,
    Color? warning,
    Color? critical,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      normal: normal ?? this.normal,
      warning: warning ?? this.warning,
      critical: critical ?? this.critical,
    );
  }
}

class AppThemePalette {
  final AppColors light;
  final AppColors dark;
  AppThemePalette({required this.light, required this.dark});
}

// Extensão mágica para as telas pegarem a cor certa automaticamente!
extension AppThemePaletteExtension on AppThemePalette {
  AppColors current(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }
}

class AppColorsNotifier extends Notifier<AppThemePalette> {
  @override
  AppThemePalette build() {
    _loadColors();
    // PADRÃO: Preto para o Claro, Branco para o Escuro
    return AppThemePalette(
      light: AppColors(
        primary: Colors.black,
        normal: Colors.green,
        warning: Colors.amber,
        critical: Colors.red,
      ),
      dark: AppColors(
        primary: Colors.white,
        normal: Colors.green,
        warning: Colors.amber,
        critical: Colors.red,
      ),
    );
  }

  Future<void> _loadColors() async {
    final prefs = await SharedPreferences.getInstance();

    Color getColor(String key, Color defaultColor) {
      final val = prefs.getInt(key);
      return val != null ? Color(val) : defaultColor;
    }

    state = AppThemePalette(
      light: AppColors(
        primary: getColor('light_primary', Colors.black),
        normal: getColor('light_normal', Colors.green),
        warning: getColor('light_warning', Colors.amber),
        critical: getColor('light_critical', Colors.red),
      ),
      dark: AppColors(
        primary: getColor('dark_primary', Colors.white),
        normal: getColor('dark_normal', Colors.green),
        warning: getColor('dark_warning', Colors.amber),
        critical: getColor('dark_critical', Colors.red),
      ),
    );
  }

  Future<void> updateColor(bool isLight, String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = isLight ? 'light' : 'dark';
    await prefs.setInt('${prefix}_$key', color.toARGB32());

    if (isLight) {
      AppColors updatedLight = state.light;
      if (key == 'primary') {
        updatedLight = updatedLight.copyWith(primary: color);
      }
      if (key == 'normal') updatedLight = updatedLight.copyWith(normal: color);
      if (key == 'warning') {
        updatedLight = updatedLight.copyWith(warning: color);
      }
      if (key == 'critical') {
        updatedLight = updatedLight.copyWith(critical: color);
      }
      state = AppThemePalette(light: updatedLight, dark: state.dark);
    } else {
      AppColors updatedDark = state.dark;
      if (key == 'primary') updatedDark = updatedDark.copyWith(primary: color);
      if (key == 'normal') updatedDark = updatedDark.copyWith(normal: color);
      if (key == 'warning') updatedDark = updatedDark.copyWith(warning: color);
      if (key == 'critical') {
        updatedDark = updatedDark.copyWith(critical: color);
      }
      state = AppThemePalette(light: state.light, dark: updatedDark);
    }
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = ['primary', 'normal', 'warning', 'critical'];
    for (var k in keys) {
      await prefs.remove('light_$k');
      await prefs.remove('dark_$k');
    }
    state = AppThemePalette(
      light: AppColors(
        primary: Colors.black,
        normal: Colors.green,
        warning: Colors.amber,
        critical: Colors.red,
      ),
      dark: AppColors(
        primary: Colors.white,
        normal: Colors.green,
        warning: Colors.amber,
        critical: Colors.red,
      ),
    );
  }
}

final appColorsProvider = NotifierProvider<AppColorsNotifier, AppThemePalette>(
  () {
    return AppColorsNotifier();
  },
);

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

// ============================================================================
// TÚNEL 8: RESULTADOS DE TESTES (MODO 06)
// ============================================================================
class Mode06Result {
  final int mid; // Monitor ID
  final int tid; // Test ID
  final int cid; // Component ID
  final int value;
  final int min;
  final int max;

  Mode06Result({
    required this.mid,
    required this.tid,
    required this.cid,
    required this.value,
    required this.min,
    required this.max,
  });

  // Verifica se o teste já foi executado pela ECU (se tem dados reais)
  bool get hasData => value != 0 || min != 0 || max != 0;

  // Um teste passa se o valor estiver entre o Mínimo e o Máximo
  bool get isPass => value >= min && value <= max;
}

class TestResultsNotifier extends Notifier<List<Mode06Result>> {
  bool isLoading = false;

  @override
  List<Mode06Result> build() => [];

  void setLoading(bool loading) {
    isLoading = loading;
    // Força a atualização da tela
    state = List.from(state);
  }

  void addResult(Mode06Result result) {
    // Evita duplicatas do mesmo monitor e teste
    final currentList = List<Mode06Result>.from(state);
    currentList.removeWhere(
      (r) => r.mid == result.mid && r.tid == result.tid && r.cid == result.cid,
    );
    currentList.add(result);
    state = currentList;
  }

  void clear() {
    state = [];
  }
}

final testResultsProvider =
    NotifierProvider<TestResultsNotifier, List<Mode06Result>>(() {
      return TestResultsNotifier();
    });

// ============================================================================
// CONTROLE DE TAXA DE ATUALIZAÇÃO (POLLING RATE)
// ============================================================================
class PollingIntervalNotifier extends Notifier<int> {
  @override
  int build() {
    _loadInterval();
    return 0; // Retorna 0 (Máxima) como padrão enquanto carrega
  }

  // Busca a configuração salva ao abrir o app
  Future<void> _loadInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final savedInterval = prefs.getInt('polling_interval');
    if (savedInterval != null) {
      state = savedInterval;
    }
  }

  // Atualiza o estado na tela e salva no disco simultaneamente
  Future<void> updateInterval(int value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('polling_interval', value);
  }
}

final pollingIntervalProvider = NotifierProvider<PollingIntervalNotifier, int>(
  () {
    return PollingIntervalNotifier();
  },
);

// ============================================================================
// CONTROLE DE TELA CHEIA (FULLSCREEN) DO HUD
// ============================================================================
class HudFullscreenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final hudFullscreenProvider = NotifierProvider<HudFullscreenNotifier, bool>(() {
  return HudFullscreenNotifier();
});
