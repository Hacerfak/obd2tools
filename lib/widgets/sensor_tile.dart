import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';

class SensorTile extends ConsumerWidget {
  final ObdPid pid;
  final VoidCallback onTap;

  const SensorTile({super.key, required this.pid, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[pid.name];
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pid.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
                style: TextStyle(
                  fontSize: 12,
                  color: onSurfaceColor.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
