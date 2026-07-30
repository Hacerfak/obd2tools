import 'dart:async';
import 'dart:math'; // NOVO: Para usar as funções min() e max()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';

class SensorDetailScreen extends ConsumerStatefulWidget {
  final ObdPid pid;

  const SensorDetailScreen({super.key, required this.pid});

  @override
  ConsumerState<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends ConsumerState<SensorDetailScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _requestData();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _requestData();
    });
  }

  void _requestData() {
    String hexPid = widget.pid.id
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    ref.read(obdManagerProvider).queueCommand("01$hexPid");
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[widget.pid.name];

    // --- LÓGICA DE ESTABILIZAÇÃO DO GRÁFICO ---
    double minY = 0;
    double maxY = 100;

    if (sensorData != null && sensorData.history.isNotEmpty) {
      double minVal = sensorData.history.reduce(min);
      double maxVal = sensorData.history.reduce(max);
      double range = maxVal - minVal;

      // Se a variação for muito pequena (menos de 20 unidades),
      // forçamos uma margem para a linha não estourar na tela.
      if (range < 20) {
        minY = minVal - 10;
        maxY = maxVal + 10;
      } else {
        // Se a variação for grande (ex: RPM de 800 a 3000), damos 15% de margem no topo e fundo
        minY = minVal - (range * 0.15);
        maxY = maxVal + (range * 0.15);
      }

      // Previne que gráficos como velocidade ou RPM fiquem com Y negativo no visual
      if (minY < 0 && minVal >= 0) {
        minY = 0;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.pid.name,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- VALOR EM DESTAQUE ---
            const Text(
              "Valor Instantâneo",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // SE O SENSOR TIVER TRADUTOR (Ex: Malha Fechada)
            if (sensorData != null && widget.pid.formatValue != null)
              Text(
                widget.pid.formatValue!(sensorData.value),
                style: const TextStyle(
                  fontSize: 32, // Fonte um pouco menor para caber o texto
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              )
            // SE FOR UM SENSOR NUMÉRICO NORMAL (Ex: RPM, Temp)
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
                    style: const TextStyle(fontSize: 24, color: Colors.white70),
                  ),
                ],
              ),
            const SizedBox(height: 48),
            const Text(
              "Comportamento Recente",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: (sensorData == null || sensorData.history.length < 2)
                  ? const Center(
                      child: Text(
                        "Lendo dados do CAN Bus...\n(Aguarde o preenchimento do gráfico)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        // NOVO: Aplica os limites dinâmicos calculados acima
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: Colors.white10,
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
                            preventCurveOverShooting:
                                true, // NOVO: Impede a curva de ultrapassar os pontos reais
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
