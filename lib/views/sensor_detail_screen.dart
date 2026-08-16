import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '/l10n/app_localizations.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';
import '../connection/obd_manager.dart';
import '../widgets/admob_banner.dart';
import '../state/technical_data_service.dart';

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

  List<double> _getFixedBounds(String unit) {
    if (unit == "RPM") return [0, 8000];
    if (unit == "km/h") return [0, 220];
    if (unit == "°C" || unit == "C") return [-10, 130];
    if (unit == "%") return [0, 100];
    if (unit == "V") return [9, 16];
    if (unit == "kPa") return [0, 255];
    if (unit == "g/s") return [0, 200];
    if (unit == "°") return [-20, 60];
    if (unit == "λ" || unit == "Lambda") return [0, 2];
    if (unit == "Pa") return [-8192, 8192];
    return [0, 100];
  }

  @override
  Widget build(BuildContext context) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[widget.pid.name];
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider).current(context);

    // --- BUSCANDO OS DADOS TÉCNICOS DO JSON ---
    final String hexId = widget.pid.id
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final techData = ref.read(technicalDataProvider).getSensorData(hexId);

    Color getColorForHealth(SensorHealth? health, Color defaultColor) {
      if (health == SensorHealth.normal) return appColors.normal;
      if (health == SensorHealth.warning) return appColors.warning;
      if (health == SensorHealth.critical) return appColors.critical;
      return defaultColor;
    }

    double minY = 0;
    double maxY = 100;

    if (widget.pid.unit.isNotEmpty &&
        sensorData != null &&
        sensorData.history.isNotEmpty) {
      final bounds = _getFixedBounds(widget.pid.unit);
      minY = bounds[0];
      maxY = bounds[1];
    }

    SensorHealth? currentHealth =
        sensorData != null && widget.pid.evaluateHealth != null
        ? widget.pid.evaluateHealth!(sensorData.value)
        : null;

    Color activeColor = getColorForHealth(currentHealth, appColors.primary);

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
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // SÓ EXIBE A BIBLIOTECA TÉCNICA SE HOUVER DADOS NO JSON PARA ESTE SENSOR
          if (techData != null) ...[
            Text(
              l10n.techLibTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onSurface.withValues(alpha: 0.54),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: onSurface.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: Icon(
                  Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.techHowItWorks,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                childrenPadding: const EdgeInsets.all(16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechSection(
                    l10n.techWhatIsIt,
                    techData.whatIsIt,
                    onSurface,
                  ),
                  const SizedBox(height: 12),
                  _buildTechSection(
                    l10n.techFunction,
                    techData.function,
                    onSurface,
                  ),
                  const SizedBox(height: 12),
                  _buildTechSection(
                    l10n.techImpact,
                    techData.impact,
                    onSurface,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // VALOR INSTANTÂNEO
          Text(
            l10n.sensInstant,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.54),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (sensorData != null && widget.pid.formatValue != null)
            Text(
              widget.pid.formatValue!(sensorData.value),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: activeColor,
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
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
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
          const SizedBox(height: 32),

          // GRÁFICO
          if (widget.pid.unit.isNotEmpty) ...[
            Text(
              l10n.sensRecent,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.54),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.4,
              child: (sensorData == null || sensorData.history.length < 2)
                  ? Center(
                      child: Text(
                        "${l10n.sensReading}\n${l10n.sensWaitGraph}",
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
                        minX: 0,
                        maxX: 29,
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
                            spots: sensorData.history
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            curveSmoothness: 0.2,
                            preventCurveOverShooting: true,
                            isStrokeCapRound: true,
                            color: activeColor,
                            barWidth: 3,
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
          ] else ...[
            AspectRatio(
              aspectRatio: 2.0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 60,
                      color: onSurface.withValues(alpha: 0.05),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.sensNoHistory,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }

  Widget _buildTechSection(String title, String description, Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.8),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
