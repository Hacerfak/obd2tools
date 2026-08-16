import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';

enum GaugeStyle { digital, analog, lineChart }

class ZoneGradient {
  final List<Color> colors;
  final List<double> stops;
  ZoneGradient(this.colors, this.stops);
}

class ObdGauge extends ConsumerWidget {
  final ObdPid pid;
  final GaugeStyle style;

  const ObdGauge({super.key, required this.pid, required this.style});

  double _getMaxValue() {
    if (pid.unit == "RPM") return 8000;
    if (pid.unit == "km/h") return 220;
    if (pid.unit == "°C" || pid.unit == "C") return 130;
    if (pid.unit == "%") return 100;
    if (pid.unit == "V") return 16;
    if (pid.unit == "kPa") return 255;
    if (pid.unit == "λ" || pid.unit == "Lambda") return 2.0;
    if (pid.unit == "Pa") return 8192;
    return 100;
  }

  // ENCURTA NOMES LONGOS NO HUD
  String _getShortName(String fullName) {
    if (fullName.contains("Arrefecimento")) return "Temp. Motor";
    if (fullName.contains("Velocidade")) return "Velocidade";
    if (fullName.contains("Rotação")) return "RPM Motor";
    if (fullName.contains("Pressão Admissão")) return "Pressão MAP";
    if (fullName.contains("Fluxo de Ar")) return "Fluxo MAF";
    if (fullName.contains("Posição do Acelerador")) return "Acelerador";
    if (fullName.contains("Temp. Ar Admissão")) return "Temp. Ar";
    if (fullName.contains("Carga Calculada")) return "Carga Motor";
    if (fullName.contains("Tensão")) return "Bateria";
    if (fullName.contains("Barométrica")) return "Pressão Atm.";
    if (fullName.contains("Razão Equivalência")) return "Mistura (AF)";
    if (fullName.contains("Ar Ambiente")) return "Temp. Ext.";
    return fullName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[pid.name];
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);

    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    ZoneGradient buildZoneGradient(
      double minY,
      double maxY,
      Color defaultColor,
    ) {
      if (pid.evaluateHealth == null) {
        return ZoneGradient([defaultColor, defaultColor], [0.0, 1.0]);
      }

      List<Color> colors = [];
      List<double> stops = [];
      SensorHealth? lastHealth;
      int steps = 100;

      for (int i = 0; i <= steps; i++) {
        double percent = i / steps;
        double val = minY + (percent * (maxY - minY));
        SensorHealth health = pid.evaluateHealth!(val);
        Color healthColor = getColorForHealth(health, defaultColor);

        if (lastHealth != null && health != lastHealth) {
          colors.add(getColorForHealth(lastHealth, defaultColor));
          stops.add(percent);
          colors.add(healthColor);
          stops.add(percent);
        } else if (i == 0 || i == steps) {
          colors.add(healthColor);
          stops.add(percent);
        }
        lastHealth = health;
      }
      return ZoneGradient(colors, stops);
    }

    double currentValue = sensorData?.value ?? 0.0;
    double maxValue = _getMaxValue();
    double percent = (currentValue / maxValue).clamp(0.0, 1.0);

    SensorHealth? currentHealth = pid.evaluateHealth != null
        ? pid.evaluateHealth!(currentValue)
        : null;
    Color activeColor = getColorForHealth(currentHealth, appColors.primary);
    ZoneGradient zones = buildZoneGradient(0, maxValue, appColors.primary);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // REMOVIDA A BORDA DAQUI!
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // Sombra suavizada
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
                left: 12.0,
                right: 12.0,
              ),
              child: style == GaugeStyle.lineChart
                  ? _buildLineChart(
                      context,
                      sensorData?.history ?? [],
                      maxValue,
                      onSurface,
                      activeColor,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Calcula o quadrado perfeito exato disponível para o gauge
                        double size = min(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );

                        return Center(
                          child: SizedBox(
                            width: size,
                            height: size,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: Size(size, size),
                                  painter: style == GaugeStyle.digital
                                      ? DigitalGaugePainter(
                                          percent: percent,
                                          baseColor: onSurface,
                                          zones: zones,
                                        )
                                      : AnalogGaugePainter(
                                          percent: percent,
                                          baseColor: onSurface,
                                          activeColor: activeColor,
                                          zones: zones,
                                        ),
                                ),
                                // TEXTO ALINHADO DE FORMA RELATIVA AO TAMANHO
                                Positioned(
                                  bottom: size * 0.12, // 12% da base do círculo
                                  child: SizedBox(
                                    width:
                                        size *
                                        0.7, // Evita vazar pelas laterais
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currentValue.toStringAsFixed(
                                              pid.unit == "RPM" ? 0 : 1,
                                            ),
                                            style: TextStyle(
                                              fontSize:
                                                  size *
                                                  0.25, // Tamanho dinâmico
                                              fontWeight: FontWeight.w900,
                                              color: activeColor,
                                              fontFamily: 'Monospace',
                                            ),
                                          ),
                                          Text(
                                            pid.unit,
                                            style: TextStyle(
                                              color: activeColor.withValues(
                                                alpha: 0.7,
                                              ),
                                              fontSize:
                                                  size *
                                                  0.1, // Tamanho dinâmico
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12.0,
              left: 8.0,
              right: 8.0,
              top: 8.0,
            ),
            child: Text(
              _getShortName(pid.name).toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.54),
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

  Widget _buildLineChart(
    BuildContext context,
    List<double> history,
    double maxValue,
    Color onSurface,
    Color activeColor,
  ) {
    if (history.length < 2) {
      return Center(
        child: Text(
          "Coletando...",
          style: TextStyle(color: onSurface.withValues(alpha: 0.24)),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxValue,
              minX: 0,
              maxX: 29,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: history
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  curveSmoothness: 0.2,
                  preventCurveOverShooting: true,
                  color: activeColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: activeColor.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${history.last.toStringAsFixed(pid.unit == "RPM" ? 0 : 1)} ${pid.unit}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: activeColor,
          ),
        ),
      ],
    );
  }
}

Shader _createSmartSweepShader(
  List<Color> colors,
  List<double> stops,
  Rect rect,
  double startAngle,
  double sweepAngle,
) {
  final double sweepFraction = sweepAngle / (2 * pi);

  List<Color> mappedColors = [];
  List<double> mappedStops = [];

  for (int i = 0; i < colors.length; i++) {
    mappedColors.add(colors[i]);
    mappedStops.add(stops[i] * sweepFraction);
  }

  Color firstColor = colors.first;
  Color lastColor = colors.last;
  mappedColors.add(lastColor);
  mappedStops.add(sweepFraction + 0.05);
  mappedColors.add(firstColor);
  mappedStops.add(1.0 - 0.05);
  mappedColors.add(firstColor);
  mappedStops.add(1.0);

  return SweepGradient(
    startAngle: 0.0,
    endAngle: 2 * pi,
    colors: mappedColors,
    stops: mappedStops,
    transform: GradientRotation(startAngle),
  ).createShader(rect);
}

// OS PINTORES AGORA USAM O CENTRO EXATO (sem margens fixas)
class DigitalGaugePainter extends CustomPainter {
  final double percent;
  final Color baseColor;
  final ZoneGradient zones;

  DigitalGaugePainter({
    required this.percent,
    required this.baseColor,
    required this.zones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 0.8 * pi;
    const sweepAngle = 1.4 * pi;

    final trackShader = _createSmartSweepShader(
      zones.colors.map((c) => c.withValues(alpha: 0.15)).toList(),
      zones.stops,
      rect,
      startAngle,
      sweepAngle,
    );

    final fillShader = _createSmartSweepShader(
      zones.colors,
      zones.stops,
      rect,
      startAngle,
      sweepAngle,
    );

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = trackShader
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * percent,
      false,
      Paint()
        ..shader = fillShader
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  @override
  bool shouldRepaint(covariant DigitalGaugePainter oldDelegate) =>
      oldDelegate.percent != percent;
}

class AnalogGaugePainter extends CustomPainter {
  final double percent;
  final Color baseColor;
  final Color activeColor;
  final ZoneGradient zones;

  AnalogGaugePainter({
    required this.percent,
    required this.baseColor,
    required this.activeColor,
    required this.zones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 0.8 * pi;
    const sweepAngle = 1.4 * pi;

    final trackShader = _createSmartSweepShader(
      zones.colors.map((c) => c.withValues(alpha: 0.4)).toList(),
      zones.stops,
      rect,
      startAngle,
      sweepAngle,
    );

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = trackShader
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    final tickPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.54)
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

    final pointerAngle = startAngle + (sweepAngle * percent);
    final pointerLength = radius - 14;

    final pointerPaint = Paint()
      ..color = activeColor
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

    canvas.drawCircle(center, 8, Paint()..color = baseColor);
    canvas.drawCircle(center, 4, Paint()..color = activeColor);
  }

  @override
  bool shouldRepaint(covariant AnalogGaugePainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.activeColor != activeColor;
}
