import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtc_fault.dart';
import '../state/obd_providers.dart';

class FaultDetailScreen extends ConsumerWidget {
  final DtcFault fault;
  const FaultDetailScreen({super.key, required this.fault});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Detalhes da Falha",
          style: TextStyle(color: Colors.white),
        ),
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
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Monospace',
              ),
            ),
            const SizedBox(height: 8),

            // STATUS EXPLICATIVOS
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: fault.statuses
                  .map((s) => _buildExplanatoryBadge(s))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // SESSÃO DO FREEZE FRAME
            const Text(
              "Dados Congelados (Freeze Frame):",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),

            Expanded(
              child: fault.freezeFrame.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum dado congelado disponível para este erro.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
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
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "${result.value.toStringAsFixed(result.value == result.value.toInt() ? 0 : 1)} ${result.unit}",
                                style: const TextStyle(
                                  color: Colors.white,
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

            // BOTÃO DE APAGAR
            ElevatedButton.icon(
              onPressed: () => _showClearConfirmation(context, ref),
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
        description = "Acende a luz. O problema está ocorrendo agora.";
        break;
      case DtcStatus.pending:
        color = Colors.orangeAccent;
        text = "Pendente";
        description =
            "ECU detectou anomalia, mas precisa de mais ciclos para confirmar.";
        break;
      case DtcStatus.permanent:
        color = Colors.purpleAccent;
        text = "Permanente";
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

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text(
          "Apagar Luz de Injeção?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Esta ação vai resetar a memória de falhas e o Freeze Frame da injeção eletrônica. Certifique-se de estar com a CHAVE LIGADA e o MOTOR DESLIGADO.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            onPressed: () {
              ref.read(obdManagerProvider).clearDTCs();
              Navigator.pop(context); // Fecha Dialog
              Navigator.pop(context); // Volta pra tela de falhas
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Sim, Apagar!"),
          ),
        ],
      ),
    );
  }
}
