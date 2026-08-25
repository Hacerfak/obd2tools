import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';
import '../state/technical_data_service.dart';

class SensorTile extends ConsumerWidget {
  final ObdPid pid;
  final VoidCallback onTap;

  const SensorTile({super.key, required this.pid, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorData = ref.watch(
      realTimeStateProvider.select((data) => data[pid.name]),
    );
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);
    final techService = ref.watch(technicalDataProvider);

    final hexId = pid.id.toRadixString(16).padLeft(2, '0').toUpperCase();
    final sensorTechData = techService.getSensorData(hexId);

    // Usa o nome traduzido do JSON ou cai de volta para o nome padrão do PID
    final String displayName = sensorTechData?.name.isNotEmpty == true
        ? sensorTechData!.name
        : pid.name;

    final hasValueMap = sensorTechData?.valueMap != null;

    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    SensorHealth? currentHealth =
        sensorData != null && pid.evaluateHealth != null
        ? pid.evaluateHealth!(sensorData.value)
        : null;

    Color activeColor = getColorForHealth(currentHealth, appColors.primary);

    // Obtém a representação formatada/traduzida do valor
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
              // NOME DO SENSOR TRADUZIDO
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
              // VALOR FORMATADO E UNIDADE
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
                  if (pid.unit.isNotEmpty && !hasValueMap)
                    Text(
                      pid.unit,
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
