import 'package:flutter/material.dart';
import 'sensors_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de Painéis dos Serviços
  final List<Widget> _pages = [
    const SensorsDashboardScreen(), // Painel 1: Lista/Tiles de Sensores
    const Center(
      child: Text(
        "HUD / Gauges em breve",
        style: TextStyle(color: Colors.white),
      ),
    ), // Painel 2
    const Center(
      child: Text(
        "Diagnóstico DTC (Luz Injeção) em breve",
        style: TextStyle(color: Colors.white),
      ),
    ), // Modo 03
    const Center(
      child: Text(
        "Informações do Veículo em breve",
        style: TextStyle(color: Colors.white),
      ),
    ), // Modo 09
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
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
