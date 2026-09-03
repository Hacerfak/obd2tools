import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/obd_pid.dart';
import '../models/mapped_sensor.dart';
import '../state/obd_providers.dart';
import '../state/technical_data_service.dart';
import 'hud_sensor_chart.dart';

enum GaugeStyle { digital, analog, stats, chart }

class ZoneGradient {
  final List<Color> colors;
  final List<double> stops;
  ZoneGradient(this.colors, this.stops);
}

class ObdGauge extends ConsumerWidget {
  final MappedSensor sensor;
  final GaugeStyle style;

  const ObdGauge({super.key, required this.sensor, required this.style});

  /// Retorna os limites (Mínimo, Máximo) baseados no PID ou na Unidade
  (double, double) _getMinMaxValues() {
    if (sensor.pid.id == 0x0E) return (-64.0, 64.0); // Avanço de Ignição (°)
    if (sensor.pid.id == 0x06 ||
        sensor.pid.id == 0x07 ||
        sensor.pid.id == 0x08 ||
        sensor.pid.id == 0x09 ||
        sensor.pid.id == 0x2D) {
      return (-100.0, 100.0); // Trim de Combustível / Erro EGR (%)
    }
    if (sensor.pid.id == 0x32) return (-8192.0, 8192.0); // Pressão EVAP (Pa)
    if (sensor.pid.id == 0x5D || sensor.pid.id == 0x84) {
      return (-210.0, 300.0);
    } // Ponto de Injeção (°)
    if (sensor.pid.id == 0x61 ||
        sensor.pid.id == 0x62 ||
        sensor.pid.id == 0xA3) {
      return (-125.0, 125.0); // Torque (%)
    }

    if (sensor.pid.unit == "RPM") return (0.0, 8000.0);
    if (sensor.pid.unit == "km/h") return (0.0, 220.0);
    if (sensor.pid.unit == "°C" || sensor.pid.unit == "C") {
      return (-40.0, 150.0);
    }
    if (sensor.pid.unit == "%") return (0.0, 100.0);
    if (sensor.pid.unit == "V") return (0.0, 16.0);
    if (sensor.pid.unit == "kPa") return (0.0, 255.0);
    if (sensor.pid.unit == "°") return (-64.0, 64.0);
    if (sensor.pid.unit == "λ" || sensor.pid.unit == "Lambda") {
      return (0.0, 2.0);
    }
    if (sensor.pid.unit == "Pa") return (-8192.0, 8192.0);

    return (0.0, 100.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorData = ref.watch(
      realTimeStateProvider.select((data) => data[sensor.uniqueId]),
    );
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);

    final hexId = sensor.pid.id.toRadixString(16).padLeft(2, '0').toUpperCase();
    final techData = ref.watch(technicalDataProvider).getSensorData(hexId);

    final String baseShortName = techData?.shortName.isNotEmpty == true
        ? techData!.shortName
        : (techData?.name.isNotEmpty == true
              ? techData!.name
              : sensor.pid.name);

    // Substituímos o sensor.module.txHeader pelo sensor.module.name para ficar legível
    final String displayShortName = "$baseShortName (${sensor.module.name})";

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
      if (sensor.pid.evaluateHealth == null) {
        return ZoneGradient([defaultColor, defaultColor], [0.0, 1.0]);
      }
      List<Color> colors = [];
      List<double> stops = [];
      SensorHealth? lastHealth;
      int steps = 100;
      for (int i = 0; i <= steps; i++) {
        double percent = i / steps;
        double val = minY + (percent * (maxY - minY));
        SensorHealth health = sensor.pid.evaluateHealth!(val);
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
    List<double> history = sensorData?.history ?? [];

    final (minValue, maxValue) = _getMinMaxValues();

    double range = maxValue - minValue;
    double percent = range == 0
        ? 0.0
        : ((currentValue - minValue) / range).clamp(0.0, 1.0);

    SensorHealth? currentHealth = sensor.pid.evaluateHealth != null
        ? sensor.pid.evaluateHealth!(currentValue)
        : null;

    Color activeColor = getColorForHealth(currentHealth, appColors.primary);
    ZoneGradient zones = buildZoneGradient(
      minValue,
      maxValue,
      appColors.primary,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: style == GaugeStyle.chart
            ? HudSensorChart(
                currentValue: currentValue,
                color: activeColor,
                unit: sensor.pid.unit,
                shortName: displayShortName,
              )
            : style == GaugeStyle.stats
            ? _buildStatsPanel(
                currentValue,
                history,
                onSurface,
                activeColor,
                displayShortName,
              )
            : Column(
                children: [
                  Expanded(
                    flex: 58,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
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
                                Positioned(
                                  bottom: size * 0.10,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      sensor.pid.unit.isEmpty
                                          ? "--"
                                          : sensor.pid.unit,
                                      style: TextStyle(
                                        fontSize: size * 0.13,
                                        fontWeight: FontWeight.bold,
                                        color: activeColor.withValues(
                                          alpha: 0.75,
                                        ),
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
                  Expanded(
                    flex: 28,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            currentValue.toStringAsFixed(
                              sensor.pid.unit == "RPM" ? 0 : 1,
                            ),
                            style: TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.w900,
                              color: activeColor,
                              fontFamily: 'Monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 14,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          displayShortName.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.54),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsPanel(
    double currentValue,
    List<double> history,
    Color onSurface,
    Color activeColor,
    String shortName,
  ) {
    double currentMin = currentValue;
    double currentMax = currentValue;
    if (history.isNotEmpty) {
      currentMin = history.reduce((a, b) => a < b ? a : b);
      currentMax = history.reduce((a, b) => a > b ? a : b);
    }
    String formatVal(double v) =>
        v.toStringAsFixed(sensor.pid.unit == "RPM" ? 0 : 1);

    return Column(
      children: [
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  formatVal(currentValue),
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: activeColor,
                    fontFamily: 'Monospace',
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 14,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sensor.pid.unit.isEmpty ? "--" : sensor.pid.unit,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: activeColor.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 24,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniStat(
                    "MIN",
                    formatVal(currentMin),
                    onSurface,
                    Colors.blueAccent,
                  ),
                  const SizedBox(height: 2),
                  _buildMiniStat(
                    "MAX",
                    formatVal(currentMax),
                    onSurface,
                    Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 14,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                shortName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.54),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    Color onSurface,
    Color iconColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          label == "MIN"
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
          color: iconColor,
          size: 13,
        ),
        const SizedBox(width: 3),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: onSurface.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: onSurface,
            fontFamily: 'Monospace',
          ),
        ),
      ],
    );
  }
}

// --- UTILITÁRIO DE GRADIENTE DE SWEEP PARA PAINTERS ---
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

// --- PAINTER DIGITAL ---
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
        ..strokeWidth = 10,
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
        ..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(covariant DigitalGaugePainter oldDelegate) =>
      oldDelegate.percent != percent;
}

// --- PAINTER ANALÓGICO COM PONTEIRO E MARCADORES ---
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
        ..strokeWidth = 5,
    );

    final tickPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.54)
      ..strokeWidth = 2;

    for (int i = 0; i <= 10; i++) {
      double angle = startAngle + (sweepAngle * (i / 10));
      Offset inner = Offset(
        center.dx + (radius - 7) * cos(angle),
        center.dy + (radius - 7) * sin(angle),
      );
      Offset outer = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    final pointerAngle = startAngle + (sweepAngle * percent);
    final pointerLength = radius - 12;
    final pointerPaint = Paint()
      ..color = activeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    canvas.drawLine(
      center,
      Offset(
        center.dx + pointerLength * cos(pointerAngle),
        center.dy + pointerLength * sin(pointerAngle),
      ),
      pointerPaint,
    );

    canvas.drawCircle(center, 7, Paint()..color = baseColor);
    canvas.drawCircle(center, 3.5, Paint()..color = activeColor);
  }

  @override
  bool shouldRepaint(covariant AnalogGaugePainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.activeColor != activeColor;
}
