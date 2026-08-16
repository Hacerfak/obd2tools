import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../models/dtc_fault.dart';
import '../parser/registries/dtc_dictionary.dart';
import '../widgets/admob_banner.dart';

class FaultDetailScreen extends ConsumerWidget {
  final DtcFault fault;
  const FaultDetailScreen({super.key, required this.fault});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!; // Instância de traduções

    // Busca as informações do Dicionário (Isso será migrado pro JSON depois!)
    final dtcInfo = getDtcExplanation(fault.code);
    final hasFreezeFrame = fault.freezeFrame.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        title: Text(l10n.faultDetailsTitle, style: TextStyle(color: onSurface)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
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

                // --- INFORMAÇÕES DO DICIONÁRIO ---
                Text(
                  dtcInfo.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dtcInfo.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ),

                // --- FREEZE FRAME (SÓ APARECE SE EXISTIR DADOS CONGELADOS!) ---
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
          ),
        ],
      ),
      bottomNavigationBar: const AdMobBanner(),
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
