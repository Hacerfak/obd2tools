import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../models/dtc_fault.dart';
import '../state/technical_data_service.dart';

class FaultDetailScreen extends ConsumerWidget {
  final DtcFault fault;
  const FaultDetailScreen({super.key, required this.fault});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final hasFreezeFrame = fault.freezeFrame.isNotEmpty;

    // --- BUSCANDO OS DADOS TÉCNICOS DO JSON ---
    final techData = ref.read(technicalDataProvider).getDtcData(fault.code);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        title: Text(l10n.faultDetailsTitle, style: TextStyle(color: onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Icon(
            fault.statuses.contains(DtcStatus.confirmed)
                ? Icons.warning_rounded
                : Icons.build_circle,
            size: 80,
            color: fault.statuses.contains(DtcStatus.confirmed)
                ? Colors.redAccent
                : Colors.orangeAccent,
          ),
          const SizedBox(height: 16),
          Text(
            fault.code,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: onSurface,
              fontFamily: 'Monospace',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: fault.statuses
                .map((s) => _buildExplanatoryBadge(s, l10n))
                .toList(),
          ),
          const SizedBox(height: 32),

          // --- SE ENCONTROU OS DADOS DA FALHA NO JSON ---
          if (techData != null) ...[
            Text(
              techData.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              techData.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // SINTOMAS
            if (techData.symptoms.isNotEmpty) ...[
              _buildExpansionCard(
                context,
                title: l10n.dtcSymptoms,
                icon: Icons.coronavirus_outlined,
                iconColor: Colors.orangeAccent,
                items: techData.symptoms,
                onSurface: onSurface,
              ),
              const SizedBox(height: 12),
            ],

            // CAUSAS
            if (techData.causes.isNotEmpty) ...[
              _buildExpansionCard(
                context,
                title: l10n.dtcCauses,
                icon: Icons.search_rounded,
                iconColor: Colors.blueAccent,
                items: techData.causes,
                onSurface: onSurface,
              ),
              const SizedBox(height: 12),
            ],

            // SOLUÇÃO
            if (techData.howToTestAndFix.isNotEmpty) ...[
              _buildExpansionCard(
                context,
                title: l10n.dtcResolution,
                icon: Icons.build_circle_outlined,
                iconColor: Colors.green,
                items: techData.howToTestAndFix,
                onSurface: onSurface,
              ),
            ],
          ] else ...[
            // FALLBACK: Caso não haja dados cadastrados para essa falha ainda
            Center(
              child: Text(
                "Nenhum detalhe técnico cadastrado para esta falha.",
                style: TextStyle(color: onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ],

          // --- FREEZE FRAME ---
          if (hasFreezeFrame) ...[
            const SizedBox(height: 32),
            Divider(color: onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              l10n.faultFreezeFrameTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 16),
            ...fault.freezeFrame.entries.map((entry) {
              final sensorName = entry.key;
              final result = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sensorName,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      "${result.value.toStringAsFixed(result.value == result.value.toInt() ? 0 : 1)} ${result.unit}",
                      style: TextStyle(
                        color: onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildExpansionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    required Color onSurface,
  }) {
    return Card(
      elevation: 0,
      color: onSurface.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                  child: Icon(Icons.circle, size: 6, color: iconColor),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExplanatoryBadge(DtcStatus status, AppLocalizations l10n) {
    Color color;
    String text;
    String description;

    switch (status) {
      case DtcStatus.confirmed:
        color = Colors.redAccent;
        text = l10n.faultConfirmed;
        description = l10n.faultDescConfirmed;
        break;
      case DtcStatus.pending:
        color = Colors.orangeAccent;
        text = l10n.faultPending;
        description = l10n.faultDescPending;
        break;
      case DtcStatus.permanent:
        color = Colors.purpleAccent;
        text = l10n.faultPermanent;
        description = l10n.faultDescPermanent;
        break;
    }

    return Tooltip(
      message: description,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
