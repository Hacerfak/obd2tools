import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';

enum GaugeStyle { digital, analog, stats }

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

  /// Sistema abrangente de abreviações técnicas em linha única
  String _getShortName(String fullName) {
    if (fullName.contains("Arrefecimento")) return "Temp. Motor";
    if (fullName.contains("Velocidade")) return "Velocidade";
    if (fullName.contains("Rotação")) return "RPM Motor";
    if (fullName.contains("Pressão Admissão") || fullName.contains("MAP"))
      return "Pressão MAP";
    if (fullName.contains("Fluxo de Ar") || fullName.contains("MAF"))
      return "Fluxo MAF";
    if (fullName.contains("Acelerador") || fullName.contains("TPS"))
      return "Acelerador";
    if (fullName.contains("Temp. Ar Admissão") || fullName.contains("IAT"))
      return "Temp. Ar IAT";
    if (fullName.contains("Carga Calculada") ||
        fullName.contains("Carga Absoluta"))
      return "Carga Motor";
    if (fullName.contains("Tensão Módulo") || fullName.contains("Bateria"))
      return "Bateria ECU";
    if (fullName.contains("Tensão da Sonda") ||
        fullName.contains("Sonda Lambda"))
      return "Sonda Lambda";
    if (fullName.contains("Barométrica")) return "Pressão Atm.";
    if (fullName.contains("Razão Equivalência") || fullName.contains("Mistura"))
      return "Mistura (A/F)";
    if (fullName.contains("Ar Ambiente")) return "Temp. Ext.";
    if (fullName.contains("Óleo do Motor")) return "Temp. Óleo";
    if (fullName.contains("Curto Prazo")) return "STFT (Curto)";
    if (fullName.contains("Longo Prazo")) return "LTFT (Longo)";
    if (fullName.contains("Pressão do Combustível")) return "Pressão Comb.";
    if (fullName.contains("Nível de Combustível")) return "Nível Comb.";
    if (fullName.contains("Purga Canister") || fullName.contains("Purga"))
      return "Purga Canister";
    if (fullName.contains("Pressão de Vapor") || fullName.contains("EVAP"))
      return "Pressão EVAP";
    if (fullName.contains("Catalisador")) return "Temp. Catalisador";
    if (fullName.contains("Consumo")) return "Consumo L/h";
    if (fullName.contains("Torque")) return "Torque Real";
    if (fullName.contains("Hodômetro")) return "Hodômetro ECU";
    if (fullName.contains("Intercooler")) return "Intercooler";
    if (fullName.contains("Avanço")) return "Avanço Ignição";
    if (fullName.contains("Etanol")) return "Etanol %";

    if (fullName.length > 14) {
      return "${fullName.substring(0, 12)}..";
    }
    return fullName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorData = ref.watch(
      realTimeStateProvider.select((data) => data[pid.name]),
    );

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
    List<double> history = sensorData?.history ?? [];
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Column(
          children: [
            // 1. ÁREA DO ARCO GRÁFICO (UNIDADE NA BASE DO ARCO)
            Expanded(
              child: style == GaugeStyle.stats
                  ? _buildStatsPanel(
                      currentValue,
                      history,
                      onSurface,
                      activeColor,
                    )
                  : LayoutBuilder(
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

                                // UNIDADE ALINHADA NA BASE ABERTA DO ARCO
                                Positioned(
                                  top: style == GaugeStyle.analog
                                      ? size * 0.60
                                      : size * 0.60,
                                  child: SizedBox(
                                    width: size * 0.65,
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          pid.unit.isEmpty ? "--" : pid.unit,
                                          style: TextStyle(
                                            fontSize: size * 0.22,
                                            fontWeight: FontWeight.w900,
                                            color: activeColor.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
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

            // 2. VALOR ATUAL (Abaixo do arco, bem maior no espaço disponível)
            if (style != GaugeStyle.stats) ...[
              const SizedBox(height: 2),
              SizedBox(
                height: 26,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currentValue.toStringAsFixed(pid.unit == "RPM" ? 0 : 1),
                    style: TextStyle(
                      fontSize: 26, // BEM MAIOR E DESTACADO!
                      fontWeight: FontWeight.w900,
                      color: activeColor,
                      fontFamily: 'Monospace',
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 2),

            // 3. NOME ABREVIADO DO SENSOR
            Text(
              _getShortName(pid.name).toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.54),
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
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
  ) {
    double currentMin = currentValue;
    double currentMax = currentValue;

    if (history.isNotEmpty) {
      currentMin = history.reduce((a, b) => a < b ? a : b);
      currentMax = history.reduce((a, b) => a > b ? a : b);
    }

    String formatVal(double v) => v.toStringAsFixed(pid.unit == "RPM" ? 0 : 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatVal(currentValue),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: activeColor,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  Text(
                    pid.unit,
                    style: TextStyle(
                      color: activeColor.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniStat(
                "MIN",
                formatVal(currentMin),
                onSurface,
                Colors.blueAccent,
              ),
              const SizedBox(height: 1),
              _buildMiniStat(
                "MAX",
                formatVal(currentMax),
                onSurface,
                Colors.redAccent,
              ),
            ],
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
          size: 12,
        ),
        const SizedBox(width: 2),
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: onSurface,
            fontFamily: 'Monospace',
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
