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

  // Lista de Painéis dos Serviços
  final List<Widget> _pages = [
    const SensorsDashboardScreen(), // Painel 1: Lista/Tiles de Sensores
    const HudScreen(), // Painel 2
    const FaultsScreen(), // Modo 03 e 04
    const Center(
      child: Text(
        "Informações do Veículo em breve",
        style: TextStyle(color: Colors.white),
      ),
    ), // Modo 09
  ];

  // Função para limpar tudo e voltar
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          // NOVO APPBAR COM BOTÃO DE DESCONECTAR
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1D24),
            title: const Text(
              "Montana OBD",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.bluetooth_disabled,
                  color: Colors.redAccent,
                ),
                tooltip: 'Desconectar',
                onPressed: _disconnectAndExit,
              ),
            ],
          ),
          body: Row(
            children: [
              // Se for Desktop/PC, coloca a barra lateral
              if (isDesktop)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: const Color(0xFF1A1D24),
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

              // O Painel Selecionado
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),

          // Se for Mobile, coloca a BottomNavigationBar no rodapé
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
