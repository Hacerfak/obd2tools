import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/obd_providers.dart';
import 'home_screen.dart';
import 'package:flutter/foundation.dart';
import '../parser/registries/mode_01_registry.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  final bool attemptAutoConnect;

  const ConnectionScreen({super.key, this.attemptAutoConnect = true});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  List<Map<String, String>> _pairedDevices = [];
  final List<Map<String, String>> _discoveredDevices = [];
  bool _isLoadingPaired = true;
  bool _isDiscovering = false;
  StreamSubscription? _discoverySubscription;

  @override
  void initState() {
    super.initState();
    if (widget.attemptAutoConnect) {
      _tryAutoConnect();
    } else {
      _loadPairedDevices();
    }
  }

  @override
  void dispose() {
    _discoverySubscription?.cancel();
    super.dispose();
  }

  Future<void> _tryAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMac = prefs.getString('last_mac_address');

    if (lastMac != null && lastMac.isNotEmpty) {
      _startConnection(lastMac, isAutoConnect: true);
    } else {
      _loadPairedDevices();
    }
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _isLoadingPaired = true);
    final manager = ref.read(obdManagerProvider);
    final devices = await manager.connection.getPairedDevices();

    if (context.mounted) {
      setState(() {
        _pairedDevices = devices;
        _isLoadingPaired = false;
      });
    }
  }

  void _startDiscovery() {
    setState(() {
      _isDiscovering = true;
      _discoveredDevices.clear();
    });

    final manager = ref.read(obdManagerProvider);
    _discoverySubscription?.cancel();
    _discoverySubscription = manager.connection.startDiscovery().listen(
      (device) {
        if (context.mounted) {
          setState(() {
            bool isAlreadyPaired = _pairedDevices.any(
              (d) => d["mac"] == device["mac"],
            );
            bool isAlreadyDiscovered = _discoveredDevices.any(
              (d) => d["mac"] == device["mac"],
            );

            if (!isAlreadyPaired && !isAlreadyDiscovered) {
              _discoveredDevices.add(device);
            }
          });
        }
      },
      onDone: () {
        if (context.mounted) setState(() => _isDiscovering = false);
      },
      onError: (error) {
        if (context.mounted) setState(() => _isDiscovering = false);
      },
    );
  }

  void _startConnection(String macAddress, {bool isAutoConnect = false}) async {
    _discoverySubscription?.cancel();
    setState(() => _isDiscovering = false);

    ref
        .read(connectionStateProvider.notifier)
        .updateState(AppConnectionState.connectingBluetooth);
    final manager = ref.read(obdManagerProvider);
    await manager.connection.stopScan();
    await Future.delayed(const Duration(milliseconds: 50));

    bool success = false;
    try {
      success = await manager.connection
          .connect(macAddress.trim())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (kDebugMode) debugPrint("Erro ou tempo esgotado na conexão: $e");
      success = false;
    }

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_mac_address', macAddress.trim());
      manager.initializeScanner();
      manager.discoverSupportedSensors();
    } else {
      ref
          .read(connectionStateProvider.notifier)
          .updateState(AppConnectionState.disconnected);
      if (mounted) {
        if (isAutoConnect) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "O scanner salvo não foi encontrado. Selecione na lista.",
              ),
            ),
          );
          _loadPairedDevices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Falha ao conectar. Tente reiniciar o Bluetooth do PC.",
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildDeviceList(List<Map<String, String>> devices, IconData icon) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (devices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Nenhum aparelho encontrado.",
          style: TextStyle(color: onSurface.withValues(alpha: 0.54)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(icon, color: onSurface.withValues(alpha: 0.7)),
            title: Text(device["name"]!, style: TextStyle(color: onSurface)),
            subtitle: Text(
              device["mac"]!,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.54),
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.bluetooth_connected,
              color: Colors.blueAccent,
            ),
            onTap: () => _startConnection(device["mac"]!),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connState = ref.watch(connectionStateProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    ref.listen(connectionStateProvider, (previous, next) {
      if (next == AppConnectionState.ready) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.bluetooth_searching,
                size: 56,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              Text(
                "Conectar ao Scanner",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 24),

              if (connState == AppConnectionState.disconnected) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Dispositivos Pareados",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isLoadingPaired)
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDeviceList(_pairedDevices, Icons.save),
                        if (Platform.isAndroid || Platform.isIOS) ...[
                          Divider(
                            color: onSurface.withValues(alpha: 0.1),
                            height: 32,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Dispositivos Próximos",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_isDiscovering)
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildDeviceList(_discoveredDevices, Icons.bluetooth),
                        ],
                      ],
                    ),
                  ),
                ),
                if (Platform.isAndroid || Platform.isIOS) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isDiscovering ? null : _startDiscovery,
                    icon: _isDiscovering
                        ? const Icon(Icons.hourglass_bottom)
                        : const Icon(Icons.search),
                    label: Text(
                      _isDiscovering
                          ? "Buscando..."
                          : "Buscar Novos Dispositivos",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ] else if (connState ==
                  AppConnectionState.connectingBluetooth) ...[
                const Spacer(),
                const Center(
                  child: Icon(
                    Icons.bluetooth_audio_rounded,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Estabelecendo conexão segura...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Isso pode levar alguns segundos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onSurface.withValues(alpha: 0.54)),
                ),
                const Spacer(),
              ] else if (connState == AppConnectionState.waitingForEcu) ...[
                const Spacer(),
                const Center(
                  child: Icon(Icons.key, size: 80, color: Colors.amberAccent),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Gire a chave na ignição para ligar o painel.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(color: Colors.amberAccent),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref
                      .read(connectionStateProvider.notifier)
                      .updateState(AppConnectionState.disconnected),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ] else if (connState ==
                  AppConnectionState.discoveringSensors) ...[
                const Spacer(),
                const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                const SizedBox(height: 24),
                Text(
                  "Mapeando sensores suportados pela ECU...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
              ] else if (connState == AppConnectionState.ready) ...[
                const Spacer(),
                const Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Conexão Bem-Sucedida!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final supported = ref.read(supportedPidsProvider);
                    // Importe o '../parser/registries/mode_01_registry.dart' no topo se precisar!
                    final realCount = pidRegistry.values
                        .where((pid) => supported.contains(pid.id))
                        .length;

                    return Text(
                      "$realCount sensores mapeados",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.54),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
