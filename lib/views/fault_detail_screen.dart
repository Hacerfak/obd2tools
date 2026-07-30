import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';

class FaultDetailScreen extends ConsumerWidget {
  final String faultCode;
  const FaultDetailScreen({super.key, required this.faultCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.build, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              faultCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Monospace',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pesquise este código na internet para descobrir o problema específico do seu carro. Falhas na injeção eletrônica podem afetar o desempenho e o consumo de combustível.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(),

            // O TÃO SONHADO BOTÃO DE APAGAR A LUZ
            ElevatedButton.icon(
              onPressed: () {
                _showClearConfirmation(context, ref);
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text("APAGAR FALHAS DA ECU"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 2),
                textStyle: const TextStyle(
                  fontSize: 18,
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
          "Esta ação vai resetar a memória de falhas da injeção eletrônica. Certifique-se de estar com a CHAVE LIGADA e o MOTOR DESLIGADO.",
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
