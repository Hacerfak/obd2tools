import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../parser/obd_pid.dart';
import '../parser/parsers/monitor_status_parser.dart';
import '../parser/parsers/egt_parser.dart';
import '../state/obd_providers.dart';
import '../connection/obd_manager.dart';
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

  String _getMonitorTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'misfire':
        return l10n.monMisfire;
      case 'fuelSystem':
        return l10n.monFuelSystem;
      case 'components':
        return l10n.monComponents;
      case 'catalyst':
        return l10n.monCatalyst;
      case 'heatedCatalyst':
        return l10n.monHeatedCatalyst;
      case 'evaporativeSystem':
        return l10n.monEvaporativeSystem;
      case 'secondaryAir':
        return l10n.monSecondaryAir;
      case 'gpfFilter':
        return l10n.monGpfFilter;
      case 'oxygenSensor':
        return l10n.monOxygenSensor;
      case 'oxygenHeater':
        return l10n.monOxygenHeater;
      case 'egrVvt':
        return l10n.monEgrVvt;
      case 'nmhcCatalyst':
        return l10n.monNmhcCatalyst;
      case 'noxScr':
        return l10n.monNoxScr;
      case 'boostPressure':
        return l10n.monBoostPressure;
      case 'exhaustGasSensor':
        return l10n.monExhaustGasSensor;
      case 'pmFilter':
        return l10n.monPmFilter;
      default:
        return key;
    }
  }

  bool _isChartable(String unit, bool hasValueMap) {
    if (hasValueMap) return false;
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
      "°",
      "Lambda",
      "mA",
      "bar",
      "λ",
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
    final techService = ref.watch(technicalDataProvider);

    final bool isMonitorStatusPid =
        widget.pid.id == 0x01 || widget.pid.id == 0x41;
    final bool isEgtPid = widget.pid.id == 0x78 || widget.pid.id == 0x79;

    final String hexId = widget.pid.id
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final techData = techService.getSensorData(hexId);
    final hasValueMap = techData?.valueMap != null;
    final String displayName = techData?.name.isNotEmpty == true
        ? techData!.name
        : widget.pid.name;

    final bool showStats = _isChartable(widget.pid.unit, hasValueMap);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          displayName,
          style: TextStyle(fontSize: 18, color: onSurface),
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
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

                  // RENDERIZAÇÃO ESPECÍFICA POR TIPO DE PID
                  if (isMonitorStatusPid)
                    _buildMonitorView(context, ref, onSurface, l10n, appColors)
                  else if (isEgtPid)
                    _buildEgtView(context, ref, onSurface)
                  else
                    _buildStandardView(
                      context,
                      ref,
                      onSurface,
                      l10n,
                      appColors,
                      techService,
                      hexId,
                      hasValueMap,
                      showStats,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- VISUALIZAÇÃO DOS MONITORES DE PRONTIDÃO (PIDs 01 e 41) ---
  Widget _buildMonitorView(
    BuildContext context,
    WidgetRef ref,
    Color onSurface,
    AppLocalizations l10n,
    AppColors appColors,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final sensorData = ref.watch(
          realTimeStateProvider.select((data) => data[widget.pid.name]),
        );

        if (sensorData == null || sensorData.rawBytes == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final monitorStatus = ObdMonitorStatus.fromBytes(
          sensorData.rawBytes!,
          isPid41: widget.pid.id == 0x41,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.pid.id == 0x01) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: "Luz de Injeção (MIL)",
                      value: monitorStatus.isMilOn ? "ACESA" : "APAGADA",
                      color: monitorStatus.isMilOn
                          ? appColors.critical
                          : appColors.normal,
                      icon: monitorStatus.isMilOn
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      onSurface: onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: "Erros Confirmados",
                      value: "${monitorStatus.dtcCount} DTC(s)",
                      color: monitorStatus.dtcCount > 0
                          ? appColors.warning
                          : appColors.normal,
                      icon: Icons.error_outline,
                      onSurface: onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    monitorStatus.isDiesel
                        ? Icons.local_shipping_outlined
                        : Icons.directions_car_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Tipo de Ignição: ${monitorStatus.isDiesel ? 'Compressão (Diesel)' : 'Ciclo Otto (Gasolina / Flex)'}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Monitores de Prontidão (Readiness Checks)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monitorStatus.monitors.length,
              itemBuilder: (context, index) {
                final item = monitorStatus.monitors[index];
                final String title = _getMonitorTitle(item.key, l10n);

                return Card(
                  elevation: 0,
                  color: onSurface.withValues(alpha: 0.04),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      item.isComplete
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      color: item.isComplete
                          ? appColors.normal
                          : appColors.warning,
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: onSurface,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (item.isComplete
                                    ? appColors.normal
                                    : appColors.warning)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.isComplete
                            ? l10n.statusComplete
                            : l10n.statusIncomplete,
                        style: TextStyle(
                          color: item.isComplete
                              ? appColors.normal
                              : appColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- VISUALIZAÇÃO DOS SENSORES MULTI-EGT (PIDs 78 e 79) ---
  Widget _buildEgtView(BuildContext context, WidgetRef ref, Color onSurface) {
    return Consumer(
      builder: (context, ref, _) {
        final sensorData = ref.watch(
          realTimeStateProvider.select((data) => data[widget.pid.name]),
        );

        if (sensorData == null || sensorData.rawBytes == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final egtStatus = EgtStatus.fromBytes(
          sensorData.rawBytes!,
          bank: widget.pid.id == 0x78 ? 1 : 2,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sensores EGT Suportados (Banco ${egtStatus.bank})",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: egtStatus.sensors.length,
              itemBuilder: (context, index) {
                final sensor = egtStatus.sensors[index];

                return Card(
                  elevation: 0,
                  color: sensor.isSupported
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08)
                      : onSurface.withValues(alpha: 0.03),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: sensor.isSupported
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sensor ${sensor.index}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: sensor.isSupported
                                    ? onSurface
                                    : onSurface.withValues(alpha: 0.38),
                              ),
                            ),
                            Icon(
                              sensor.isSupported
                                  ? Icons.sensors_rounded
                                  : Icons.sensors_off_rounded,
                              size: 16,
                              color: sensor.isSupported
                                  ? Theme.of(context).colorScheme.primary
                                  : onSurface.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                        Text(
                          sensor.isSupported
                              ? "${sensor.temperature.toStringAsFixed(1)} °C"
                              : "N/A",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Monospace',
                            color: sensor.isSupported
                                ? onSurface
                                : onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- VISUALIZAÇÃO PADRÃO (VALOR INSTANTÂNEO E ESTATÍSTICAS) ---
  Widget _buildStandardView(
    BuildContext context,
    WidgetRef ref,
    Color onSurface,
    AppLocalizations l10n,
    AppColors appColors,
    TechnicalDataService techService,
    String hexId,
    bool hasValueMap,
    bool showStats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              realTimeStateProvider.select((data) => data[widget.pid.name]),
            );
            final health =
                sensorData != null && widget.pid.evaluateHealth != null
                ? widget.pid.evaluateHealth!(sensorData.value)
                : null;
            final activeColor = _getActiveColor(health, appColors);

            final displayValue = sensorData != null
                ? techService.getSensorValueDescription(
                    hexId,
                    sensorData.value,
                    rawBytes: sensorData.rawBytes,
                  )
                : "--";

            if (hasValueMap) {
              return Text(
                displayValue,
                style: TextStyle(
                  fontSize: 28,
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
                    displayValue,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  if (widget.pid.unit.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.pid.unit,
                      style: TextStyle(
                        fontSize: 24,
                        color: onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
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
                realTimeStateProvider.select((data) => data[widget.pid.name]),
              );
              double currentMin = 0.0;
              double currentMax = 0.0;
              if (sensorData != null && sensorData.history.isNotEmpty) {
                currentMin = sensorData.history.reduce((a, b) => a < b ? a : b);
                currentMax = sensorData.history.reduce((a, b) => a > b ? a : b);
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
                  "Grandeza Cumulativa / Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onSurface.withValues(alpha: 0.54),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sensores de contagem contínua ou estado em texto não suportam estatísticas de oscilação.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onSurface.withValues(alpha: 0.38)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required Color onSurface,
  }) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
