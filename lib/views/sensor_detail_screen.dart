import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  bool _isChartable(String unit) {
    const validChartUnits = [
      "%",
      "°C",
      "C",
      "RPM",
      "km/h",
      "V",
      "kPa",
      "g/s",
      "Pa",
      "λ",
      "Lambda",
      "mA",
      "bar",
      "°",
    ];
    return validChartUnits.contains(unit);
  }

  Color _getActiveColor(SensorHealth? health, AppColors appColors) {
    if (health == SensorHealth.normal) return appColors.normal;
    if (health == SensorHealth.warning) return appColors.warning;
    if (health == SensorHealth.critical) return appColors.critical;
    return appColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider).current(context);

    final String hexId = widget.pid.id
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final techData = ref.read(technicalDataProvider).getSensorData(hexId);

    final bool showStats = _isChartable(widget.pid.unit);

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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BIBLIOTECA TÉCNICA
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

                  Text(
                    l10n.sensInstant,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.54),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // VALOR INSTANTÂNEO
                  Consumer(
                    builder: (context, ref, _) {
                      final sensorData = ref.watch(
                        realTimeStateProvider.select(
                          (data) => data[widget.pid.name],
                        ),
                      );
                      final health =
                          sensorData != null &&
                              widget.pid.evaluateHealth != null
                          ? widget.pid.evaluateHealth!(sensorData.value)
                          : null;
                      final activeColor = _getActiveColor(health, appColors);

                      if (sensorData != null &&
                          widget.pid.formatValue != null) {
                        return Text(
                          widget.pid.formatValue!(sensorData.value),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        );
                      } else {
                        return Row(
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
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 48),

                  // ESTATÍSTICAS DA SESSÃO OU AVISO DE ACUMULATIVO
                  if (showStats) ...[
                    Text(
                      "Estatísticas da Sessão",
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.54),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, _) {
                        final sensorData = ref.watch(
                          realTimeStateProvider.select(
                            (data) => data[widget.pid.name],
                          ),
                        );

                        double currentMin = 0.0;
                        double currentMax = 0.0;

                        if (sensorData != null &&
                            sensorData.history.isNotEmpty) {
                          currentMin = sensorData.history.reduce(
                            (a, b) => a < b ? a : b,
                          );
                          currentMax = sensorData.history.reduce(
                            (a, b) => a > b ? a : b,
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Mínimo",
                                currentMin,
                                widget.pid.unit,
                                onSurface,
                                Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                "Máximo",
                                currentMax,
                                widget.pid.unit,
                                onSurface,
                                Colors.redAccent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stacked_line_chart,
                            size: 60,
                            color: onSurface.withValues(alpha: 0.05),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Grandeza Cumulativa",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: onSurface.withValues(alpha: 0.54),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sensores de contagem contínua não suportam estatísticas de oscilação.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }

  Widget _buildStatCard(
    String title,
    double value,
    String unit,
    Color onSurface,
    Color iconColor,
  ) {
    return Card(
      elevation: 0,
      color: onSurface.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title == "Mínimo"
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: iconColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toStringAsFixed(unit == "RPM" ? 0 : 1),
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'Monospace',
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
