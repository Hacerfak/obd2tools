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

    // Removemos a pre-carga viciada aqui, o gráfico vai nascer da direita para a esquerda.

    _sampleTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!mounted) return;
      setState(() {
        // Aplicamos a suavização comparando a ponta atual do buffer, se houver
        double newValue = widget.currentValue;
        if (_samples.isNotEmpty) {
          newValue =
              _samples.last + (widget.currentValue - _samples.last) * 0.25;
        }

        _samples.add(newValue);
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
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 320,
          child: CustomPaint(
            painter: _SmoothChartPainter(
              samples: _samples,
              minY: minY,
              maxY: maxY,
              color: widget.lineTileColor,
              unit: widget.unit,
              textColor: onSurface.withValues(alpha: 0.4),
              gridColor: onSurface.withValues(alpha: 0.06),
              nowLabel: l10n.chartNow,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmoothChartPainter extends CustomPainter {
  final List<double> samples;
  final double minY;
  final double maxY;
  final Color color;
  final String unit;
  final Color textColor;
  final Color gridColor;
  final String nowLabel;

  _SmoothChartPainter({
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

    // MARGENS MÍNIMAS PARA APROVEITAMENTO MÁXIMO DA TELA
    const double marginLeft = 0.0;
    const double marginRight = 0.0;
    const double marginTop = 12.0;
    const double marginBottom = 20.0;

    final double chartWidth = size.width - marginLeft - marginRight;
    final double chartHeight = size.height - marginTop - marginBottom;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final double rangeY = maxY - minY;

    // 1. LINHAS DE GRELHA E EIXOS
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

    canvas.drawLine(Offset(x5s, marginTop), Offset(x5s, yBottom), gridPaint);

    // 2. RÓTULOS DO EIXO Y (SOBREPOSTOS DISCRETAMENTE NO CANTO DIREITO DO GRÁFICO)
    final String maxText = "${maxY.toStringAsFixed(1)} $unit".trim();
    final String midText = "${((maxY + minY) / 2).toStringAsFixed(1)} $unit"
        .trim();
    final String minText = "${minY.toStringAsFixed(1)} $unit".trim();

    _drawTextRightAligned(canvas, maxText, Offset(chartWidth - 4, yTop + 2));
    _drawTextRightAligned(canvas, midText, Offset(chartWidth - 4, yMid + 2));
    _drawTextRightAligned(
      canvas,
      minText,
      Offset(chartWidth - 4, yBottom - 14),
    );

    // 3. RÓTULOS DO EIXO X (TEMPO NO RODAPÉ)
    _drawText(canvas, "-10s", Offset(x10s + 4, yBottom + 4));
    _drawTextCentered(canvas, "-5s", Offset(x5s, yBottom + 4));
    _drawTextRightAligned(canvas, nowLabel, Offset(x0s - 4, yBottom + 4));

    // 4. CONVERTE OS PONTOS EM OFFSETS (Renderizando da direita para a esquerda)
    final double stepX = chartWidth / (samples.length - 1);
    List<Offset> points = [];

    // Calcula o offset inicial para alinhar o gráfico pela direita se ele ainda não preencheu a tela toda
    final double offsetX = chartWidth - ((samples.length - 1) * stepX);

    for (int i = 0; i < samples.length; i++) {
      double x = offsetX + (i * stepX);
      double normalizedY = (samples[i] - minY) / rangeY;
      double y = yBottom - (normalizedY * chartHeight);
      points.add(Offset(x, y));
    }

    // 5. TRAÇADO BÉZIER SUAVE
    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, yBottom);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

      if (i == 0) {
        path.lineTo(midPoint.dx, midPoint.dy);
        fillPath.lineTo(midPoint.dx, midPoint.dy);
      } else {
        path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
        fillPath.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
      }
    }

    final lastPoint = points.last;
    path.lineTo(lastPoint.dx, lastPoint.dy);
    fillPath.lineTo(lastPoint.dx, lastPoint.dy);

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
      ..strokeWidth = 2.0
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
          fontWeight: FontWeight.w600,
          fontFamily: 'Monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  void _drawTextRightAligned(Canvas canvas, String text, Offset rightOffset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rightOffset.dx - textPainter.width, rightOffset.dy),
    );
  }

  void _drawTextCentered(Canvas canvas, String text, Offset centerOffset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerOffset.dx - (textPainter.width / 2), centerOffset.dy),
    );
  }

  @override
  bool shouldRepaint(covariant _SmoothChartPainter oldDelegate) => true;
}
