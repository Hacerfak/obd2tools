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

  @override
  Widget build(BuildContext context) {
    // MANTIDA A CHAMADA OTIMIZADA COM .select()
    final sensorData = ref.watch(
      realTimeStateProvider.select((data) => data[widget.pid.name]),
    );

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider).current(context);

    // --- BUSCANDO OS DADOS TÉCNICOS DO JSON ---
    final String hexId = widget.pid.id
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final techData = ref.read(technicalDataProvider).getSensorData(hexId);

    SensorHealth? currentHealth =
        sensorData != null && widget.pid.evaluateHealth != null
        ? widget.pid.evaluateHealth!(sensorData.value)
        : null;

    Color activeColor = appColors.primary;
    if (currentHealth == SensorHealth.normal) activeColor = appColors.normal;
    if (currentHealth == SensorHealth.warning) activeColor = appColors.warning;
    if (currentHealth == SensorHealth.critical)
      activeColor = appColors.critical;

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
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
            ],
          ),
        ),
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
