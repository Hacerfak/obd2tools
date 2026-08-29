import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parser/obd_pid.dart';
import '../models/mapped_sensor.dart';
import '../state/obd_providers.dart';
import '../state/technical_data_service.dart';

class SensorTile extends ConsumerWidget {
  final MappedSensor sensor;
  final VoidCallback onTap;

  const SensorTile({super.key, required this.sensor, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Busca os dados usando o uniqueId (ex: "0C_7E0")
    final sensorData = ref.watch(
      realTimeStateProvider.select((data) => data[sensor.uniqueId]),
    );

    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);
    final techService = ref.watch(technicalDataProvider);

    final hexId = sensor.pid.id.toRadixString(16).padLeft(2, '0').toUpperCase();
    final sensorTechData = techService.getSensorData(hexId);

    final String displayName = sensorTechData?.name.isNotEmpty == true
        ? "${sensorTechData!.name} (${sensor.module.name})"
        : sensor.displayName;

    final hasValueMap = sensorTechData?.valueMap != null;

    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    SensorHealth? currentHealth =
        sensorData != null && sensor.pid.evaluateHealth != null
        ? sensor.pid.evaluateHealth!(sensorData.value)
        : null;

    Color activeColor = getColorForHealth(currentHealth, appColors.primary);

    final displayValue = sensorData != null
        ? techService.getSensorValueDescription(
            hexId,
            sensorData.value,
            rawBytes: sensorData.rawBytes,
          )
        : "--";

    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: hasValueMap
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              displayValue,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: activeColor,
                              ),
                            ),
                          )
                        : Text(
                            displayValue,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: activeColor,
                              fontFamily: 'Monospace',
                            ),
                          ),
                  ),
                  if (sensor.pid.unit.isNotEmpty && !hasValueMap)
                    Text(
                      sensor.pid.unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activeColor.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
