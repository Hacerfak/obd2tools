import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/sensor_tile.dart';
import '../views/sensor_detail_screen.dart';
import '../connection/obd_manager.dart';

class SensorsDashboardScreen extends ConsumerStatefulWidget {
  const SensorsDashboardScreen({super.key});

  @override
  ConsumerState<SensorsDashboardScreen> createState() =>
      _SensorsDashboardScreenState();
}

class _SensorsDashboardScreenState
    extends ConsumerState<SensorsDashboardScreen> {
  late final ObdManager _obdManager;

  @override
  void initState() {
    super.initState();

    _obdManager = ref.read(obdManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDashboardPolling();
    });
  }

  void _startDashboardPolling() {
    final supportedPids = ref.read(supportedPidsProvider);

    final pidsReais = pidRegistry.values
        .where((pid) => supportedPids.contains(pid.id))
        .map((pid) => pid.id)
        .toList();

    // CHAMA COM COOLDOWN DE 3 SEGUNDOS ENTRE OS LOTES
    ref
        .read(obdManagerProvider)
        .setPollingPids(
          pidsReais,
          cooldown: const Duration(seconds: 3), // Pausa entre os tiros
          fastInitialPass: true, // Liga o turbo na primeira volta
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportedPids = ref.watch(supportedPidsProvider);
    final availablePids = pidRegistry.values
        .where((pid) => supportedPids.contains(pid.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sensores Mapeados (${availablePids.length})",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: availablePids.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum sensor encontrado.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900
                            ? 4
                            : (constraints.maxWidth > 600 ? 3 : 2);

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: availablePids.length,
                          itemBuilder: (context, index) {
                            final pid = availablePids[index];

                            return SensorTile(
                              pid: pid,
                              onTap: () async {
                                // 1. PAUSA A VARREDURA GERAL DA TELA
                                _obdManager.setPollingPids([]);

                                // 2. NAVEGA PARA OS DETALHES
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SensorDetailScreen(pid: pid),
                                  ),
                                );

                                // 3. RETORNOU DA TELA! RETOMA A VARREDURA
                                if (mounted) {
                                  _startDashboardPolling();
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
