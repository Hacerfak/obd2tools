import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';

class SensorTile extends ConsumerWidget {
  final ObdPid pid;
  final VoidCallback onTap; // NOVO: Ação passada pelo painel pai

  const SensorTile({super.key, required this.pid, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[pid.name];

    return Card(
      elevation: 2,
      color: const Color(0xFF1E222D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            onTap, // NOVO: Chama a função externa ao invés de usar o Navigator aqui
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pid.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Exibe o tradutor (se existir) ou o número
              if (sensorData != null && pid.formatValue != null)
                Text(
                  pid.formatValue!(sensorData.value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  sensorData != null
                      ? sensorData.value.toStringAsFixed(
                          pid.unit == "RPM" ? 0 : 1,
                        )
                      : "--",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    fontFamily: 'Monospace',
                  ),
                ),

              Text(
                pid.unit.isEmpty && pid.formatValue == null
                    ? "Status"
                    : pid.unit,
                style: const TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
