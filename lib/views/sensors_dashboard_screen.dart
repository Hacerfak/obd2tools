import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/sensor_tile.dart';
import '../views/sensor_detail_screen.dart';

class SensorsDashboardScreen extends ConsumerStatefulWidget {
  const SensorsDashboardScreen({super.key});

  @override
  ConsumerState<SensorsDashboardScreen> createState() =>
      _SensorsDashboardScreenState();
}

class _SensorsDashboardScreenState
    extends ConsumerState<SensorsDashboardScreen> {
  Timer? _backgroundTimer;

  @override
  void initState() {
    super.initState();
    // Começa a varrer os dados logo após a tela terminar de montar a primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBackgroundPolling();
    });
  }

  void _startBackgroundPolling() {
    // A cada 1 segundo (1000ms), varre a lista inteira de sensores mapeados
    _backgroundTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) {
      final supportedPids = ref.read(supportedPidsProvider);
      if (supportedPids.isEmpty) return;

      final availablePids = pidRegistry.values
          .where((pid) => supportedPids.contains(pid.id))
          .toList();

      // Divide a lista em grupos de até 6 sensores (Multi-PID)
      for (int i = 0; i < availablePids.length; i += 6) {
        final chunk = availablePids.skip(i).take(6);

        String multiCommand = "01"; // Modo 01
        for (var pid in chunk) {
          multiCommand += pid.id
              .toRadixString(16)
              .padLeft(2, '0')
              .toUpperCase();
        }

        // Envia o comando agrupado (ex: "010C050D110F04")
        ref.read(obdManagerProvider).queueCommand(multiCommand);
      }
    });
  }

  @override
  void dispose() {
    _backgroundTimer
        ?.cancel(); // Mata o loop se trocar de aba para não travar o scanner
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
                                // 1. PAUSA A VARREDURA GERAL
                                _backgroundTimer?.cancel();

                                // 2. NAVEGA PARA OS DETALHES E ESPERA
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SensorDetailScreen(pid: pid),
                                  ),
                                );

                                // 3. O USUÁRIO APERTOU "VOLTAR"! RETOMA A VARREDURA GERAL
                                if (mounted) {
                                  _startBackgroundPolling();
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
