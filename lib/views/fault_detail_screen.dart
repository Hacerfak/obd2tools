import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';

class FaultDetailScreen extends ConsumerStatefulWidget {
  final String faultCode;
  const FaultDetailScreen({super.key, required this.faultCode});

  @override
  ConsumerState<FaultDetailScreen> createState() => _FaultDetailScreenState();
}

class _FaultDetailScreenState extends ConsumerState<FaultDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Dispara a leitura do Freeze Frame ao abrir a tela
      ref.read(obdManagerProvider).readFreezeFrame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final freezeState = ref.watch(freezeFrameProvider);

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.build_rounded, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              widget.faultCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Monospace',
              ),
            ),
            const SizedBox(height: 24),

            // SEÇÃO DO FREEZE FRAME
            const Text(
              "Dados Congelados no Momento da Falha:",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),

            Expanded(
              child: freezeState.isLoading && freezeState.data.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    )
                  : freezeState.data.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum dado congelado (Freeze Frame) disponível para este erro.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: freezeState.data.length,
                      itemBuilder: (context, index) {
                        String sensorName = freezeState.data.keys.elementAt(
                          index,
                        );
                        final result = freezeState.data[sensorName]!;

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
              label: const Text("APAGAR FALHA (ECU)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.redAccent.withOpacity(0.2),
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
