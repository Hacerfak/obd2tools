import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import 'sensors_dashboard_screen.dart';
import 'hud_screen.dart';
import 'connection_screen.dart';
import 'faults_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SensorsDashboardScreen(),
    const HudScreen(),
    const FaultsScreen(),
    const Center(child: Text("Informações do Veículo em breve")),
  ];

  void _disconnectAndExit() async {
    final manager = ref.read(obdManagerProvider);
    manager.reset();
    await manager.connection.disconnect();

    ref
        .read(connectionStateProvider.notifier)
        .updateState(AppConnectionState.disconnected);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ConnectionScreen(attemptAutoConnect: false),
        ),
        (route) => false,
      );
    }
  }

  // --- BOTÃO DE CONFIGURAÇÕES ---
  Widget _buildConfigButton() {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Configurações',
      color: Theme.of(context).iconTheme.color,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
    );
  }

  Widget _buildThemeToggle() {
    final currentTheme = ref.watch(themeModeProvider);
    IconData icon;
    String tooltip;

    if (currentTheme == ThemeMode.system) {
      icon = Icons.brightness_auto;
      tooltip = "Tema: Sistema";
    } else if (currentTheme == ThemeMode.light) {
      icon = Icons.light_mode;
      tooltip = "Tema: Claro";
    } else {
      icon = Icons.dark_mode;
      tooltip = "Tema: Escuro";
    }

    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      color: Theme.of(context).iconTheme.color,
      onPressed: () {
        final newTheme = currentTheme == ThemeMode.system
            ? ThemeMode.light
            : currentTheme == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.system;
        ref.read(themeModeProvider.notifier).setTheme(newTheme);
      },
    );
  }

  Widget _buildStatusAndDisconnect(AppConnectionState state, bool isDesktop) {
    Color dotColor = Colors.grey;
    String tooltipText = "Desconectado";

    if (state == AppConnectionState.ready) {
      dotColor = Colors.greenAccent;
      tooltipText = "ECU Online";
    } else if (state == AppConnectionState.waitingForEcu) {
      dotColor = Colors.amberAccent;
      tooltipText = "ECU Hibernando (Chave Desligada)";
    }

    final ledDot = Tooltip(
      message: tooltipText,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dotColor.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );

    final powerButton = IconButton(
      icon: const Icon(Icons.power_settings_new_rounded),
      color: Theme.of(context).iconTheme.color,
      hoverColor: Colors.redAccent.withValues(alpha: 0.2),
      tooltip: 'Desconectar',
      onPressed: _disconnectAndExit,
    );

    if (isDesktop) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildConfigButton(), // INSERIDO ACIMA DO TEMA NA VERTICAL
          const SizedBox(height: 8),
          _buildThemeToggle(),
          const SizedBox(height: 8),
          ledDot,
          const SizedBox(height: 16),
          powerButton,
          const SizedBox(height: 16),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildConfigButton(), // INSERIDO ANTES DO TEMA NA HORIZONTAL
          const SizedBox(width: 8),
          _buildThemeToggle(),
          const SizedBox(width: 8),
          ledDot,
          const SizedBox(width: 16),
          powerButton,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connState = ref.watch(connectionStateProvider);

    ref.listen(connectionStateProvider, (previous, next) {
      if (next == AppConnectionState.waitingForEcu ||
          next == AppConnectionState.disconnected) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ConnectionScreen(attemptAutoConnect: false),
            ),
            (route) => false,
          );
        }
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  Container(
                    width: 80,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: Column(
                      children: [
                        Expanded(
                          child: NavigationRail(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: (int index) {
                              setState(() => _selectedIndex = index);
                            },
                            labelType: NavigationRailLabelType.all,
                            backgroundColor: Colors.transparent,
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.grid_view),
                                label: Text('Sensores'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.speed),
                                label: Text('HUD'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.warning_amber),
                                label: Text('Falhas'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.directions_car),
                                label: Text('Veículo'),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusAndDisconnect(connState, true),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (!isDesktop)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "OBD2 Tools",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              _buildStatusAndDisconnect(connState, false),
                            ],
                          ),
                        ),
                      Expanded(child: _pages[_selectedIndex]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  backgroundColor: Theme.of(
                    context,
                  ).appBarTheme.backgroundColor,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view),
                      label: 'Sensores',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.speed),
                      label: 'HUD',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.warning_amber),
                      label: 'Falhas',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.directions_car),
                      label: 'Veículo',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
