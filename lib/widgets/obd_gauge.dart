import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Para o Gráfico de Linha
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';

enum GaugeStyle { digital, analog, lineChart }

class ObdGauge extends ConsumerWidget {
  final ObdPid pid;
  final GaugeStyle style;

  const ObdGauge({super.key, required this.pid, required this.style});

  double _getMaxValue() {
    if (pid.unit == "RPM") return 8000;
    if (pid.unit == "km/h") return 220;
    if (pid.unit == "°C") return 130;
    if (pid.unit == "%") return 100;
    if (pid.unit == "V") return 16;
    if (pid.unit == "kPa") return 255;
    return 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[pid.name];

    double currentValue = sensorData?.value ?? 0.0;
    double maxValue = _getMaxValue();
    double percent = (currentValue / maxValue).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ÁREA DO GRÁFICO E VALORES NÚMERICOS
          Expanded(
            child: Stack(
              children: [
                // O DESENHO DO RELÓGIO OU GRÁFICO
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: style == GaugeStyle.lineChart
                      ? _buildLineChart(sensorData?.history ?? [], maxValue)
                      : CustomPaint(
                          size: const Size.square(double.infinity),
                          painter: style == GaugeStyle.digital
                              ? DigitalGaugePainter(
                                  percent: percent,
                                  maxValue: maxValue,
                                )
                              : AnalogGaugePainter(
                                  percent: percent,
                                  maxValue: maxValue,
                                ),
                        ),
                ),

                // O VALOR SUBIU PARA O CENTRO DO ARCO COM ESCALA DINÂMICA
                if (style != GaugeStyle.lineChart)
                  Positioned(
                    bottom: 12, // Subimos um pouco mais
                    left:
                        40, // Margens maiores para forçar o FittedBox a espremer os números
                    right: 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentValue.toStringAsFixed(
                              pid.unit == "RPM" ? 0 : 1,
                            ),
                            style: const TextStyle(
                              fontSize: 24, // Reduzimos de 32 para 24
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Monospace',
                            ),
                          ),
                          Text(
                            pid.unit,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // NOME DO SENSOR NO RODAPÉ
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12.0,
              left: 8.0,
              right: 8.0,
              top: 8.0,
            ),
            child: Text(
              pid.name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- O NOVO GRÁFICO DE LINHAS (SPARKLINE) ---
  Widget _buildLineChart(List<double> history, double maxValue) {
    if (history.length < 2) {
      return const Center(
        child: Text("Coletando...", style: TextStyle(color: Colors.white24)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxValue,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: history
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  color: Colors.greenAccent,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Valor atual no rodapé do gráfico
        Text(
          "${history.last.toStringAsFixed(pid.unit == "RPM" ? 0 : 1)} ${pid.unit}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PINTOR 1: DIGITAL / RACING (Com mais detalhes)
// ============================================================================
class DigitalGaugePainter extends CustomPainter {
  final double percent;
  final double maxValue;
  DigitalGaugePainter({required this.percent, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2 - 10,
    ); // Sobe o arco um pouco
    final radius = min(size.width / 2, size.height / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 0.8 * pi;
    const sweepAngle = 1.4 * pi;

    // Fundo
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = Colors.white10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );

    // Arco Colorido
    final gradient = const SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [Colors.greenAccent, Colors.yellowAccent, Colors.redAccent],
      stops: [0.0, 0.6, 1.0],
      transform: GradientRotation(startAngle),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * percent,
      false,
      Paint()
        ..shader = gradient
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  @override
  bool shouldRepaint(covariant DigitalGaugePainter oldDelegate) =>
      oldDelegate.percent != percent;
}

// ============================================================================
// PINTOR 2: ANALÓGICO / CLÁSSICO (Com marcações)
// ============================================================================
class AnalogGaugePainter extends CustomPainter {
  final double percent;
  final double maxValue;
  AnalogGaugePainter({required this.percent, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 10);
    final radius = min(size.width / 2, size.height / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 0.8 * pi;
    const sweepAngle = 1.4 * pi;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = Colors.white24
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawArc(
      rect,
      startAngle + (sweepAngle * 0.8),
      sweepAngle * 0.2,
      false,
      Paint()
        ..color = Colors.redAccent
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Desenha pequenos "Ticks" (Traces)
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;
    for (int i = 0; i <= 10; i++) {
      double angle = startAngle + (sweepAngle * (i / 10));
      Offset inner = Offset(
        center.dx + (radius - 8) * cos(angle),
        center.dy + (radius - 8) * sin(angle),
      );
      Offset outer = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // PONTEIRO
    final pointerAngle = startAngle + (sweepAngle * percent);
    final pointerLength = radius - 14;

    final pointerPaint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    canvas.drawLine(
      center,
      Offset(
        center.dx + pointerLength * cos(pointerAngle),
        center.dy + pointerLength * sin(pointerAngle),
      ),
      pointerPaint,
    );

    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
    canvas.drawCircle(center, 4, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant AnalogGaugePainter oldDelegate) =>
      oldDelegate.percent != percent;
}
