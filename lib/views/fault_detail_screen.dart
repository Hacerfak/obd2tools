import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtc_fault.dart';
import '../state/obd_providers.dart';

class FaultDetailScreen extends ConsumerWidget {
  final DtcFault fault;

  const FaultDetailScreen({super.key, required this.fault});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        title: Text("Detalhes da Falha", style: TextStyle(color: onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.build, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              fault.code,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: onSurface,
                fontFamily: 'Monospace',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: fault.statuses
                  .map((s) => _buildExplanatoryBadge(s))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              "Dados Congelados (Freeze Frame):",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: onSurface.withValues(alpha: 0.2)),
            Expanded(
              child: fault.freezeFrame.isEmpty
                  ? Center(
                      child: Text(
                        "Nenhum dado congelado disponível para este erro.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: fault.freezeFrame.length,
                      itemBuilder: (context, index) {
                        String sensorName = fault.freezeFrame.keys.elementAt(
                          index,
                        );
                        final result = fault.freezeFrame[sensorName]!;
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
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showClearConfirmation(context, ref, onSurface),
              icon: const Icon(Icons.delete_forever),
              label: const Text("APAGAR FALHAS DA ECU"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 2),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanatoryBadge(DtcStatus status) {
    Color color;
    String text;
    String description;
    switch (status) {
      case DtcStatus.confirmed:
        color = Colors.redAccent;
        text = "Confirmada";
        description =
            "Acende a luz. O problema está ocorrendo ou ocorreu agora.";
        break;
      case DtcStatus.pending:
        color = Colors.orangeAccent;
        text = "Em avaliação";
        description =
            "ECU detectou anomalia, mas precisa de mais ciclos para confirmar.";
        break;
      case DtcStatus.permanent:
        color = Colors.purpleAccent;
        text = "Monitorada pela ECU";
        description =
            "Falha grave. Só apaga após o conserto e rodagem do veículo.";
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

  void _showClearConfirmation(
    BuildContext context,
    WidgetRef ref,
    Color onSurface,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Apagar Luz de Injeção?",
          style: TextStyle(color: onSurface),
        ),
        content: Text(
          "Esta ação vai resetar a memória de falhas e o Freeze Frame da injeção eletrônica. Certifique-se de estar com a CHAVE LIGADA e o MOTOR DESLIGADO.",
          style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(color: onSurface.withValues(alpha: 0.54)),
            ),
          ),
          FilledButton(
            onPressed: () {
              ref.read(obdManagerProvider).clearDTCs();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              "Sim, Apagar!",
              style: TextStyle(color: Colors.white),
            ), // Texto sempre branco no botão vermelho
          ),
        ],
      ),
    );
  }
}
