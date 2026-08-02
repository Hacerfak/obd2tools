import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';

class VehicleInfoScreen extends ConsumerStatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  ConsumerState<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends ConsumerState<VehicleInfoScreen> {
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    // Pede os dados automaticamente ao abrir a tela pela primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestData();
    });
  }

  void _requestData() {
    setState(() => _isRequesting = true);
    ref.read(obdManagerProvider).requestVehicleInfo();

    // Simula um loading rápido
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isRequesting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicleInfo = ref.watch(vehicleInfoStateProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Identificação do Veículo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                if (!_isRequesting)
                  IconButton.filledTonal(
                    onPressed: _requestData,
                    icon: const Icon(Icons.refresh),
                    color: primaryColor,
                    tooltip: "Atualizar Dados",
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isRequesting && vehicleInfo.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            "Lendo módulos da rede CAN...",
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.54),
                            ),
                          ),
                        ],
                      ),
                    )
                  : vehicleInfo.isEmpty
                  ? Center(
                      child: Text(
                        "Nenhuma informação encontrada.\nO veículo pode não suportar o Modo 09.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: vehicleInfo.length,
                      itemBuilder: (context, index) {
                        String key = vehicleInfo.keys.elementAt(index);
                        String value = vehicleInfo[key]!;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              key.contains("VIN")
                                  ? Icons.directions_car
                                  : Icons.memory,
                              color: primaryColor,
                            ),
                            title: Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: onSurface,
                                fontFamily: 'Monospace',
                              ),
                            ),
                            subtitle: Text(
                              key,
                              style: TextStyle(color: primaryColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.copy,
                                size: 20,
                                color: onSurface.withValues(alpha: 0.3),
                              ),
                              onPressed: () {
                                // Futuramente podemos adicionar o clipboard aqui
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("$key copiado!")),
                                );
                              },
                            ),
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
