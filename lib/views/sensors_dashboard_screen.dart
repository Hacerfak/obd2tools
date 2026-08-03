import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/sensor_tile.dart';
import '../views/sensor_detail_screen.dart';
import '../connection/obd_manager.dart';
import '../widgets/admob_banner.dart';

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

    ref
        .read(obdManagerProvider)
        .setPollingPids(
          pidsReais,
          cooldown: const Duration(seconds: 3),
          fastInitialPass: true,
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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Sensores Mapeados (${availablePids.length})",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
          ),

          Expanded(
            child: availablePids.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum sensor encontrado.",
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900
                            ? 4
                            : (constraints.maxWidth > 600 ? 3 : 2);
                        // No mobile (<= 600), deixamos o bloco mais alto (1.6) para caber o texto
                        double aspectRatio = constraints.maxWidth > 600
                            ? 2.2
                            : 1.6;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: aspectRatio,
                              ),
                          itemCount: availablePids.length,
                          itemBuilder: (context, index) {
                            final pid = availablePids[index];
                            return SensorTile(
                              pid: pid,
                              onTap: () async {
                                _obdManager.setPollingPids([]);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SensorDetailScreen(pid: pid),
                                  ),
                                );
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
          ),
        ],
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
