import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';
import '../connection/obd_manager.dart';

class SensorDetailScreen extends ConsumerStatefulWidget {
  final ObdPid pid;

  const SensorDetailScreen({super.key, required this.pid});

  @override
  ConsumerState<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends ConsumerState<SensorDetailScreen> {
  late final ObdManager _obdManager;

  @override
  void initState() {
    super.initState();
    _obdManager = ref.read(obdManagerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obdManager.setPollingPids([widget.pid.id]);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<double> _getFixedBounds(String unit) {
    if (unit == "RPM") return [0, 8000];
    if (unit == "km/h") return [0, 220];
    if (unit == "°C" || unit == "C") return [-10, 130];
    if (unit == "%") return [0, 100];
    if (unit == "V") return [9, 16];
    if (unit == "kPa") return [0, 255];
    if (unit == "g/s") return [0, 200];
    if (unit == "°") return [-20, 60];
    if (unit == "λ" || unit == "Lambda") return [0, 2];
    if (unit == "Pa") return [-8192, 8192];
    return [0, 100];
  }

  @override
  Widget build(BuildContext context) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[widget.pid.name];
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // CAPTURA AS CORES ESCOLHIDAS
    final appColors = ref.watch(appColorsProvider);

    // FUNÇÃO DINÂMICA INTERNA
    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    double minY = 0;
    double maxY = 100;

    if (widget.pid.unit.isNotEmpty &&
        sensorData != null &&
        sensorData.history.isNotEmpty) {
      final bounds = _getFixedBounds(widget.pid.unit);
      minY = bounds[0];
      maxY = bounds[1];
    }

    SensorHealth? currentHealth =
        sensorData != null && widget.pid.evaluateHealth != null
        ? widget.pid.evaluateHealth!(sensorData.value)
        : null;

    Color activeColor = getColorForHealth(currentHealth, appColors.primary);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.pid.name,
          style: TextStyle(fontSize: 18, color: onSurface),
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Valor Instantâneo",
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.54),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (sensorData != null && widget.pid.formatValue != null)
              Text(
                widget.pid.formatValue!(sensorData.value),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    sensorData != null
                        ? sensorData.value.toStringAsFixed(
                            widget.pid.unit == "RPM" ? 0 : 1,
                          )
                        : "--",
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.pid.unit,
                    style: TextStyle(
                      fontSize: 24,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 48),

            if (widget.pid.unit.isNotEmpty) ...[
              Text(
                "Comportamento Recente",
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.54),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: (sensorData == null || sensorData.history.length < 2)
                    ? Center(
                        child: Text(
                          "Lendo dados do CAN Bus...\n(Aguarde o preenchimento do gráfico)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: minY,
                          maxY: maxY,
                          minX: 0,
                          maxX: 29,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: onSurface.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),

                          lineTouchData: LineTouchData(
                            getTouchedSpotIndicator:
                                (
                                  LineChartBarData barData,
                                  List<int> spotIndexes,
                                ) {
                                  return spotIndexes.map((spotIndex) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                        color: onSurface.withValues(alpha: 0.3),
                                        strokeWidth: 2,
                                      ),
                                      FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) {
                                              return FlDotCirclePainter(
                                                radius: 4,
                                                color: onSurface,
                                                strokeWidth: 2,
                                                strokeColor: Theme.of(
                                                  context,
                                                ).cardColor,
                                              );
                                            },
                                      ),
                                    );
                                  }).toList();
                                },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) =>
                                  Theme.of(context).colorScheme.inverseSurface,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((touchedSpot) {
                                  return LineTooltipItem(
                                    touchedSpot.y.toStringAsFixed(1),
                                    TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onInverseSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),

                          lineBarsData: [
                            LineChartBarData(
                              spots: sensorData.history
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: false,
                              color: activeColor, // LINHA SÓLIDA!
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: activeColor.withValues(
                                  alpha: 0.15,
                                ), // FUNDO SÓLIDO
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: onSurface.withValues(alpha: 0.05),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Histórico não aplicável para status em texto.",
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
