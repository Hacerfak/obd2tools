import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';

class HudSensorChart extends ConsumerStatefulWidget {
  final double currentValue;
  final Color color;
  final String unit;
  final String shortName;
  final double durationSeconds;

  const HudSensorChart({
    super.key,
    required this.currentValue,
    required this.color,
    required this.unit,
    required this.shortName,
    this.durationSeconds = 6.0,
  });

  @override
  ConsumerState<HudSensorChart> createState() => _HudSensorChartState();
}

class _HudSensorChartState extends ConsumerState<HudSensorChart> {
  Timer? _sampleTimer;
  final List<double> _samples = [];
  int _currentFps = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer(ref.read(graphFpsProvider));
    });
  }

  void _startTimer(int fps) {
    if (_currentFps == fps && _sampleTimer != null) return;
    _currentFps = fps;
    _sampleTimer?.cancel();

    final intervalMs = (1000 / fps).round();
    final maxSamples = (widget.durationSeconds * fps).round();

    if (_samples.isEmpty) {
      _samples.addAll(List.filled(maxSamples, widget.currentValue));
    }

    _sampleTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!mounted) return;
      setState(() {
        _samples.add(widget.currentValue);
        if (_samples.length > maxSamples) {
          _samples.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _sampleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fps = ref.watch(graphFpsProvider);
    _startTimer(fps);

    final onSurface = Theme.of(context).colorScheme.onSurface;

    double minY = _samples.isNotEmpty
        ? _samples.reduce((a, b) => a < b ? a : b)
        : 0.0;
    double maxY = _samples.isNotEmpty
        ? _samples.reduce((a, b) => a > b ? a : b)
        : 100.0;

    if ((maxY - minY).abs() < 0.01) {
      minY -= 1.0;
      maxY += 1.0;
    }

    return Column(
      children: [
        Expanded(
          flex: 58,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: CustomPaint(
              size: Size.infinite,
              painter: _HudChartPainter(
                samples: _samples,
                minY: minY,
                maxY: maxY,
                color: widget.color,
                gridColor: onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 28,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.currentValue.toStringAsFixed(
                        widget.unit == "RPM" ? 0 : 1,
                      ),
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        color: widget.color,
                        fontFamily: 'Monospace',
                      ),
                    ),
                    if (widget.unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        widget.unit,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: widget.color.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
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
                widget.shortName.toUpperCase(),
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
}

class _HudChartPainter extends CustomPainter {
  final List<double> samples;
  final double minY;
  final double maxY;
  final Color color;
  final Color gridColor;

  _HudChartPainter({
    required this.samples,
    required this.minY,
    required this.maxY,
    required this.color,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    final double rangeY = maxY - minY;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );

    final double stepX = size.width / (samples.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < samples.length; i++) {
      double x = i * stepX;
      double normalizedY = (samples[i] - minY) / rangeY;
      double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _HudChartPainter oldDelegate) => true;
}
