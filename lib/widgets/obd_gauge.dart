import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';
import '../state/technical_data_service.dart';

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
    if (pid.unit == "°" || pid.unit == "Lambda") return 2.0;
    if (pid.unit == "Pa") return 8192;
    return 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorData = ref.watch(
      realTimeStateProvider.select((data) => data[pid.name]),
    );
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);
    final techService = ref.watch(technicalDataProvider);

    final hexId = pid.id.toRadixString(16).padLeft(2, '0').toUpperCase();
    final techData = techService.getSensorData(hexId);
    final hasValueMap = techData?.valueMap != null;
    final String shortName = techData?.shortName.isNotEmpty == true
        ? techData!.shortName
        : pid.name;

    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    double currentValue = sensorData?.value ?? 0.0;
    List<double> history = sensorData?.history ?? [];
    double maxValue = _getMaxValue();
    double percent = (currentValue / maxValue).clamp(0.0, 1.0);

    SensorHealth? currentHealth = pid.evaluateHealth != null
        ? pid.evaluateHealth!(currentValue)
        : null;

    Color activeColor = getColorForHealth(currentHealth, appColors.primary);

    final displayValue = sensorData != null
        ? techService.getSensorValueDescription(hexId, currentValue)
        : "--";

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
        child: style == GaugeStyle.stats
            ? _buildStatsPanel(
                displayValue,
                currentValue,
                history,
                onSurface,
                activeColor,
                shortName,
                hasValueMap,
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
                                  painter: DigitalGaugePainter(
                                    percent: percent,
                                    baseColor: onSurface,
                                    zones: ZoneGradient(
                                      [appColors.primary, appColors.primary],
                                      [0.0, 1.0],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: style == GaugeStyle.analog
                                          ? size * 0.12
                                          : 0,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        hasValueMap
                                            ? ""
                                            : (pid.unit.isEmpty
                                                  ? "--"
                                                  : pid.unit),
                                        style: TextStyle(
                                          fontSize: size * 0.14,
                                          fontWeight: FontWeight.bold,
                                          color: activeColor.withValues(
                                            alpha: 0.75,
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
                  Expanded(
                    flex: 28,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            displayValue,
                            style: TextStyle(
                              fontSize: hasValueMap ? 18 : 100,
                              fontWeight: FontWeight.w900,
                              color: activeColor,
                              fontFamily: hasValueMap ? null : 'Monospace',
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
              ),
      ),
    );
  }

  Widget _buildStatsPanel(
    String displayValue,
    double currentValue,
    List<double> history,
    Color onSurface,
    Color activeColor,
    String shortName,
    bool hasValueMap,
  ) {
    double currentMin = currentValue;
    double currentMax = currentValue;
    if (history.isNotEmpty) {
      currentMin = history.reduce((a, b) => a < b ? a : b);
      currentMax = history.reduce((a, b) => a > b ? a : b);
    }
    String formatVal(double v) => v.toStringAsFixed(pid.unit == "RPM" ? 0 : 1);

    return Column(
      children: [
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: hasValueMap ? 18 : 120,
                    fontWeight: FontWeight.w900,
                    color: activeColor,
                    fontFamily: hasValueMap ? null : 'Monospace',
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
                hasValueMap ? "" : (pid.unit.isEmpty ? "--" : pid.unit),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: activeColor.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ),
        if (!hasValueMap)
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

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = baseColor.withValues(alpha: 0.15)
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
        ..color = zones.colors.first
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(covariant DigitalGaugePainter oldDelegate) =>
      oldDelegate.percent != percent;
}
