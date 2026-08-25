import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';

class LiveSensorChart extends ConsumerStatefulWidget {
  final double currentValue;
  final Color lineTileColor;
  final String unit;
  final double durationSeconds;

  const LiveSensorChart({
    super.key,
    required this.currentValue,
    required this.lineTileColor,
    required this.unit,
    this.durationSeconds = 10.0,
  });

  @override
  ConsumerState<LiveSensorChart> createState() => _LiveSensorChartState();
}

class _LiveSensorChartState extends ConsumerState<LiveSensorChart> {
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

    if (_samples.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    double minY = _samples.reduce((a, b) => a < b ? a : b);
    double maxY = _samples.reduce((a, b) => a > b ? a : b);

    if ((maxY - minY).abs() < 0.01) {
      minY -= 1.0;
      maxY += 1.0;
    }

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      elevation: 0,
      color: onSurface.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.lineTileColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 16.0, 12.0),
        child: SizedBox(
          width: double.infinity,
          height: 320,
          child: CustomPaint(
            painter: _ChartPainter(
              samples: _samples,
              minY: minY,
              maxY: maxY,
              color: widget.lineTileColor,
              unit: widget.unit,
              textColor: onSurface.withValues(alpha: 0.54),
              gridColor: onSurface.withValues(alpha: 0.08),
              nowLabel: l10n.chartNow,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> samples;
  final double minY;
  final double maxY;
  final Color color;
  final String unit;
  final Color textColor;
  final Color gridColor;
  final String nowLabel;

  _ChartPainter({
    required this.samples,
    required this.minY,
    required this.maxY,
    required this.color,
    required this.unit,
    required this.textColor,
    required this.gridColor,
    required this.nowLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    const double marginLeft = 8.0;
    const double marginRight = 56.0;
    const double marginBottom = 24.0;
    const double marginTop = 12.0;

    final double chartWidth = size.width - marginLeft - marginRight;
    final double chartHeight = size.height - marginTop - marginBottom;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final double rangeY = maxY - minY;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    final double yTop = marginTop;
    final double yMid = marginTop + (chartHeight / 2);
    final double yBottom = marginTop + chartHeight;

    canvas.drawLine(
      Offset(marginLeft, yTop),
      Offset(marginLeft + chartWidth, yTop),
      gridPaint,
    );
    canvas.drawLine(
      Offset(marginLeft, yMid),
      Offset(marginLeft + chartWidth, yMid),
      gridPaint,
    );
    canvas.drawLine(
      Offset(marginLeft, yBottom),
      Offset(marginLeft + chartWidth, yBottom),
      gridPaint,
    );

    final double x10s = marginLeft;
    final double x5s = marginLeft + (chartWidth / 2);
    final double x0s = marginLeft + chartWidth;

    canvas.drawLine(Offset(x10s, marginTop), Offset(x10s, yBottom), gridPaint);
    canvas.drawLine(Offset(x5s, marginTop), Offset(x5s, yBottom), gridPaint);
    canvas.drawLine(Offset(x0s, marginTop), Offset(x0s, yBottom), gridPaint);

    _drawText(
      canvas,
      "${maxY.toStringAsFixed(1)} $unit".trim(),
      Offset(marginLeft + chartWidth + 6, yTop - 6),
    );
    _drawText(
      canvas,
      "${((maxY + minY) / 2).toStringAsFixed(1)} $unit".trim(),
      Offset(marginLeft + chartWidth + 6, yMid - 6),
    );
    _drawText(
      canvas,
      "${minY.toStringAsFixed(1)} $unit".trim(),
      Offset(marginLeft + chartWidth + 6, yBottom - 6),
    );

    _drawText(canvas, "-10s", Offset(x10s, yBottom + 6));
    _drawText(canvas, "-5s", Offset(x5s - 10, yBottom + 6));
    _drawText(canvas, nowLabel, Offset(x0s - 18, yBottom + 6));

    final double stepX = chartWidth / (samples.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < samples.length; i++) {
      double x = marginLeft + (i * stepX);
      double normalizedY = (samples[i] - minY) / rangeY;
      double y = yBottom - (normalizedY * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, yBottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(marginLeft + chartWidth, yBottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromLTWH(marginLeft, marginTop, chartWidth, chartHeight),
          )
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
