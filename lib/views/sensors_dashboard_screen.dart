import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/l10n/app_localizations.dart';
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
    final availableSensors = ref.read(supportedPidsProvider);

    ref
        .read(obdManagerProvider)
        .setPollingPids(
          availableSensors,
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
    final availableSensors = ref.watch(supportedPidsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "${l10n.sensTitle} (${availableSensors.length})",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
          ),
          Expanded(
            child: availableSensors.isEmpty
                ? Center(
                    child: Text(
                      l10n.sensNone,
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
                          itemCount: availableSensors.length,
                          itemBuilder: (context, index) {
                            final sensor = availableSensors[index];
                            return SensorTile(
                              sensor: sensor,
                              onTap: () async {
                                _obdManager.setPollingPids([]);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SensorDetailScreen(sensor: sensor),
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
    );
  }
}
