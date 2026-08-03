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

    // CAPTURA AS CORES ESCOLHIDAS
    final appColors = ref.watch(appColorsProvider).current(context);

    // FUNÇÃO DINÂMICA INTERNA
    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    // Calcula a saúde para pintar o texto (usando a função nova)
    SensorHealth? currentHealth =
        sensorData != null && pid.evaluateHealth != null
        ? pid.evaluateHealth!(sensorData.value)
        : null;

    Color activeColor = getColorForHealth(
      currentHealth,
      appColors.primary,
    ); // Usa a primary como default

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
              // NOME DO SENSOR
              Text(
                pid.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // VALOR E UNIDADE
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: (sensorData != null && pid.formatValue != null)
                        // Texto traduzido com FittedBox para não estourar a tela!
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              pid.formatValue!(sensorData.value),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: activeColor,
                              ),
                            ),
                          )
                        // Valor numérico
                        : Text(
                            sensorData != null
                                ? sensorData.value.toStringAsFixed(
                                    pid.unit == "RPM" ? 0 : 1,
                                  )
                                : "--",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: activeColor,
                              fontFamily: 'Monospace',
                            ),
                          ),
                  ),
                  if (pid.unit.isNotEmpty && pid.formatValue == null)
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
