import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/obd_providers.dart';
import 'sensors_dashboard_screen.dart';
import 'hud_screen.dart';
import 'connection_screen.dart';
import 'faults_screen.dart';

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
    const Center(
      child: Text(
        "Informações do Veículo em breve",
        style: TextStyle(color: Colors.white),
      ),
    ),
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

  // --- WIDGET DO LED DE STATUS + BOTÃO DE DESCONECTAR ---
  Widget _buildStatusAndDisconnect(AppConnectionState state, bool isDesktop) {
    Color dotColor = Colors.grey;
    String tooltipText = "Desconectado";

    // Lógica das Cores do LED
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
      color: Colors.white54,
      hoverColor: Colors.redAccent.withValues(alpha: 0.2),
      tooltip: 'Desconectar',
      onPressed: _disconnectAndExit,
    );

    if (isDesktop) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ledDot,
          const SizedBox(height: 16),
          powerButton,
          const SizedBox(height: 16),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [ledDot, const SizedBox(width: 16), powerButton],
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
          backgroundColor: const Color(0xFF12151C),

          // REMOVEMOS O APPBAR TOTALMENTE!
          body: SafeArea(
            child: Row(
              children: [
                // --- BARRA LATERAL CUSTOMIZADA (DESKTOP) ---
                if (isDesktop)
                  Container(
                    width: 80, // Largura padrão do NavigationRail
                    color: const Color(0xFF1A1D24),
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
                        // O NOSSO NOVO RODAPÉ DA BARRA LATERAL
                        _buildStatusAndDisconnect(connState, true),
                      ],
                    ),
                  ),

                // --- ÁREA PRINCIPAL ---
                Expanded(
                  child: Column(
                    children: [
                      // --- CABEÇALHO MINIMALISTA (MOBILE) ---
                      if (!isDesktop)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: const Color(0xFF1A1D24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Montana OBD",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              _buildStatusAndDisconnect(connState, false),
                            ],
                          ),
                        ),

                      // AS PÁGINAS DO APP
                      Expanded(child: _pages[_selectedIndex]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- BARRA INFERIOR (MOBILE) ---
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  backgroundColor: const Color(0xFF1A1D24),
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
