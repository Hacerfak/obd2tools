import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import 'sensors_dashboard_screen.dart';
import 'hud_screen.dart';
import 'connection_screen.dart';
import 'faults_screen.dart';
import 'vehicle_info_screen.dart';
import 'test_results_screen.dart';
import 'settings_screen.dart';
import 'debug_console_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _moreTabKey = GlobalKey<NavigatorState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const SensorsDashboardScreen(), // 0: Sensores
      const HudScreen(), // 1: HUD
      const TestResultsScreen(), // 2: Testes
      const FaultsScreen(), // 3: Falhas
      MoreMenuScreen(
        navigatorKey: _moreTabKey,
      ), // 4: Passando a chave com segurança!
    ];
  }

  void _onTabTapped(int index) {
    if (index == 4 && _selectedIndex == 4) {
      // Se já estamos no "Mais" e o usuário tocou de novo, volta pro início!
      _moreTabKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

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
    final isFullscreen = ref.watch(hudFullscreenProvider);

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
                if (isDesktop && !isFullscreen)
                  Container(
                    width: 85,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: Column(
                      children: [
                        Expanded(
                          child: NavigationRail(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: _onTabTapped,
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
                                icon: Icon(Icons.fact_check_outlined),
                                label: Text('Testes'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.warning_amber),
                                label: Text('Falhas'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.menu),
                                label: Text('Mais'),
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
                      if (!isDesktop && !isFullscreen)
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
          bottomNavigationBar: (isDesktop || isFullscreen)
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onTabTapped,
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
                      icon: Icon(Icons.fact_check_outlined),
                      label: 'Testes',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.warning_amber),
                      label: 'Falhas',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu),
                      label: 'Mais',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class MoreMenuScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey; // Recebe a chave
  const MoreMenuScreen({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    // A MÁGICA: Este Navigator isolado impede que as telas cubram a barra lateral do Desktop!
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MoreMenuListView(),
        );
      },
    );
  }
}

class MoreMenuListView extends StatelessWidget {
  const MoreMenuListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mais Opções")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "DIAGNÓSTICO AVANÇADO",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text("Informações do Veículo"),
            subtitle: const Text("Chassi, CVN, Monitores Modo 09"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Agora o Navigator.of() usa o Navegador Aninhado!
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VehicleInfoScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.terminal),
            title: const Text("Terminal OBD2 (Debug)"),
            subtitle: const Text("Envio de PIDs e Comandos AT manuais"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DebugConsoleScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "APLICATIVO",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Ajustes"),
            subtitle: const Text("Conexão, Protocolos e Preferências"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
