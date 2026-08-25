import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';
import '../parser/parsers/mode_06_parser.dart';
import '../state/technical_data_service.dart';

class TestDetailScreen extends ConsumerWidget {
  final Mode06Result test;

  const TestDetailScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final appColors = ref.watch(appColorsProvider).current(context);
    final l10n = AppLocalizations.of(context)!;

    final midHex = test.mid.toRadixString(16).padLeft(2, '0').toUpperCase();
    final tidHex = test.tid.toRadixString(16).padLeft(2, '0').toUpperCase();

    final techData = ref
        .read(technicalDataProvider)
        .getMode06Data(midHex, tidHex);
    final unit = Mode06Parser.getUasUnit(test.cid, l10n);

    final title = techData?.title.isNotEmpty == true
        ? techData!.title
        : "Monitor 0x$midHex (Teste 0x$tidHex)";

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!test.hasData) {
      statusColor = onSurface.withValues(alpha: 0.3);
      statusIcon = Icons.pending_actions;
      statusText = l10n.testWaiting;
    } else if (test.isPass) {
      statusColor = appColors.normal;
      statusIcon = Icons.check_circle;
      statusText = l10n.testPassed;
    } else {
      statusColor = appColors.critical;
      statusIcon = Icons.cancel;
      statusText = l10n.testFailed;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Icon(statusIcon, size: 72, color: statusColor),
          const SizedBox(height: 12),
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "MID: 0x$midHex | TID: 0x$tidHex",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: onSurface.withValues(alpha: 0.6),
              fontFamily: 'Monospace',
            ),
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: onSurface.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricColumn(
                    l10n.testMin,
                    "${test.min} $unit".trim(),
                    onSurface,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: onSurface.withValues(alpha: 0.1),
                  ),
                  _buildMetricColumn(
                    l10n.testValue,
                    "${test.value} $unit".trim(),
                    primary,
                    isHighlighted: true,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: onSurface.withValues(alpha: 0.1),
                  ),
                  _buildMetricColumn(
                    l10n.testMax,
                    "${test.max} $unit".trim(),
                    onSurface,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          if (techData != null) ...[
            Text(
              l10n.techLibTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 16),

            if (techData.purpose.isNotEmpty)
              _buildTechCard(
                context: context,
                title: "Finalidade do Teste",
                icon: Icons.flag_outlined,
                iconColor: primary,
                content: techData.purpose,
                onSurface: onSurface,
              ),
            const SizedBox(height: 12),

            if (techData.sensorsUsed.isNotEmpty) ...[
              _buildSensorsCard(
                context: context,
                title: "Sensores Utilizados",
                icon: Icons.sensors_rounded,
                iconColor: Colors.orangeAccent,
                sensors: techData.sensorsUsed,
                onSurface: onSurface,
              ),
              const SizedBox(height: 12),
            ],

            if (techData.howItIsMeasured.isNotEmpty)
              _buildTechCard(
                context: context,
                title: "Como é Aferido pela ECU",
                icon: Icons.query_stats_rounded,
                iconColor: Colors.blueAccent,
                content: techData.howItIsMeasured,
                onSurface: onSurface,
              ),
          ] else ...[
            Center(
              child: Text(
                "Nenhuma explicação técnica cadastrada para este teste.",
                style: TextStyle(color: onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    String label,
    String value,
    Color color, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildTechCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    required Color onSurface,
  }) {
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
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> sensors,
    required Color onSurface,
  }) {
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
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sensors.map((s) {
                return Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: onSurface.withValues(alpha: 0.08),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
