import 'dart:math';
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

  @override
  Widget build(BuildContext context) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[widget.pid.name];
    final onSurface = Theme.of(context).colorScheme.onSurface;

    double minY = 0;
    double maxY = 100;
    if (sensorData != null && sensorData.history.isNotEmpty) {
      double minVal = sensorData.history.reduce(min);
      double maxVal = sensorData.history.reduce(max);
      double range = maxVal - minVal;

      if (range < 20) {
        minY = minVal - 10;
        maxY = maxVal + 10;
      } else {
        minY = minVal - (range * 0.15);
        maxY = maxVal + (range * 0.15);
      }

      if (minY < 0 && minVal >= 0) {
        minY = 0;
      }
    }

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
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
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
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: sensorData.history.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            preventCurveOverShooting: true,
                            color: Colors.blueAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blueAccent.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
