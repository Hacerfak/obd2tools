import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart'; // IMPORT DA TRADUÇÃO
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
    final l10n = AppLocalizations.of(context)!;

    // VERIFICA SE ESTÁ DEITADO E CALCULA AS MARGENS
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double vPadding = isLandscape ? 8.0 : 16.0;

    return Scaffold(
      body: Center(
        // TRAVA A LARGURA MÁXIMA EM 800px PARA FICAR CENTRALIZADO EM TELAS LARGAS
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, vPadding, 16.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.infoTitle,
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
                        tooltip: l10n.btnRefresh,
                        // ENCOLHE O BOTÃO NA HORIZONTAL PARA GANHAR ESPAÇO DE TELA
                        visualDensity: isLandscape
                            ? VisualDensity.compact
                            : null,
                      ),
                  ],
                ),
                SizedBox(height: vPadding),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: primaryColor),
                              const SizedBox(height: 16),
                              Text(
                                l10n.infoConsulting,
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
                            l10n.infoNone,
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
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
