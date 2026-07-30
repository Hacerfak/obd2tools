import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import 'fault_detail_screen.dart';

class FaultsScreen extends ConsumerStatefulWidget {
  const FaultsScreen({super.key});

  @override
  ConsumerState<FaultsScreen> createState() => _FaultsScreenState();
}

class _FaultsScreenState extends ConsumerState<FaultsScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia a leitura automaticamente assim que a tela abre!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(obdManagerProvider).readDTCs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dtcState = ref.watch(dtcStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Diagnóstico de Falhas (DTC)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => ref.read(obdManagerProvider).readDTCs(),
                  icon: const Icon(Icons.refresh),
                  color: Colors.blueAccent,
                  tooltip: 'Escanear Novamente',
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: dtcState.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.blueAccent),
                          SizedBox(height: 16),
                          Text(
                            "Comunicando com a Injeção Eletrônica...",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : dtcState.codes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.greenAccent,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Nenhuma falha encontrada!",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Seu carro está em perfeitas condições.",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dtcState.codes.length,
                      itemBuilder: (context, index) {
                        String code = dtcState.codes[index];
                        return Card(
                          color: const Color(0xFF1A1D24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.redAccent,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.warning_amber,
                              color: Colors.redAccent,
                              size: 32,
                            ),
                            title: Text(
                              code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: const Text(
                              "Toque para ver os detalhes e apagar",
                              style: TextStyle(color: Colors.white54),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FaultDetailScreen(faultCode: code),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
