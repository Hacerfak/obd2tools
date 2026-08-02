import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import '../widgets/admob_banner.dart';

class VehicleInfoScreen extends ConsumerStatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  ConsumerState<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends ConsumerState<VehicleInfoScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestData();
    });
  }

  void _requestData() async {
    setState(() => _isLoading = true);
    ref.read(obdManagerProvider).requestVehicleInfo();

    // Delay artificial de 2.5s para garantir que todos os PIDs 09 respondam
    // e o usuário perceba a leitura da ECU
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
                  "Informações do Veículo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                if (!_isLoading)
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
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            "Consultando módulos e calibrações da ECU...\nPor favor, aguarde.",
                            textAlign: TextAlign.center,
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
                              key.contains("VIN") || key.contains("Chassi")
                                  ? Icons.directions_car
                                  : Icons.memory,
                              color: primaryColor,
                            ),
                            title: Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: onSurface,
                                fontFamily: 'Monospace',
                              ),
                            ),
                            subtitle: Text(
                              key,
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
