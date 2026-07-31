import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NOVO IMPORT
import '../state/obd_providers.dart';
import 'home_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  // NOVO: Flag para saber se devemos tentar conectar sozinho ao abrir
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
    // A inteligência de inicialização
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

  // --- NOVA FUNÇÃO: TENTA RECONECTAR AO ÚLTIMO APARELHO ---
  Future<void> _tryAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMac = prefs.getString('last_mac_address');

    if (lastMac != null && lastMac.isNotEmpty) {
      // Tem histórico! Tenta conectar em background
      _startConnection(lastMac, isAutoConnect: true);
    } else {
      // É o primeiro acesso, carrega a lista normalmente
      _loadPairedDevices();
    }
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _isLoadingPaired = true);
    final manager = ref.read(obdManagerProvider);
    final devices = await manager.connection.getPairedDevices();

    if (mounted) {
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
        if (mounted) {
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
        if (mounted) setState(() => _isDiscovering = false);
      },
      onError: (error) {
        if (mounted) setState(() => _isDiscovering = false);
      },
    );
  }

  // NOVO: Adicionado o parâmetro isAutoConnect para lidar com os erros visuais
  void _startConnection(String macAddress, {bool isAutoConnect = false}) async {
    // 1. Cancela a escuta da interface (Flutter)
    _discoverySubscription?.cancel();
    setState(() => _isDiscovering = false);

    // 2. Atualiza a tela para o Spinner "Conectando..."
    ref
        .read(connectionStateProvider.notifier)
        .updateState(AppConnectionState.connectingBluetooth);

    final manager = ref.read(obdManagerProvider);

    // 3. O ANTÍDOTO DO DEADLOCK:
    // Manda o comando para o SO parar o rádio de busca IMEDIATAMENTE!
    await manager.connection.stopScan();

    // 4. Dá 1.5 segundos absolutos para o BlueZ fechar as threads internas de scan.
    // Sem esse delay, o Linux embola o comando de Stop com o comando de Connect.
    await Future.delayed(const Duration(milliseconds: 50));

    bool success = false;

    try {
      // 5. Agora sim, com o rádio livre, mandamos conectar!
      success = await manager.connection
          .connect(macAddress.trim())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print("Erro ou tempo esgotado na conexão: $e");
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
    if (devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Nenhum aparelho encontrado.",
          style: TextStyle(color: Colors.white38),
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
          color: const Color(0xFF1E222D),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(icon, color: Colors.white70),
            title: Text(
              device["name"]!,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              device["mac"]!,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
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

    // ATUALIZAÇÃO 1: Só muda de tela quando estiver READY
    ref.listen(connectionStateProvider, (previous, next) {
      if (next == AppConnectionState.ready) {
        // Dá 1.5 segundos para o usuário ver o "check" verde antes de ir pro Dash
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
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
              const Text(
                "Conectar ao Scanner",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // FASE 1: DESCONECTADO (MOSTRA AS LISTAS)
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
                          const Divider(color: Colors.white10, height: 32),

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
              ]
              // FASE 2: CONECTANDO BLUETOOTH
              else if (connState == AppConnectionState.connectingBluetooth) ...[
                const Spacer(),
                const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Conectando com o adaptador bluetooth...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
              ]
              // FASE 3: BLUETOOTH OK, MAS ECU DESLIGADA
              else if (connState == AppConnectionState.waitingForEcu) ...[
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
              ]
              // FASE 4: DESCOBRINDO SENSORES
              else if (connState == AppConnectionState.discoveringSensors) ...[
                const Spacer(),
                const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Mapeando sensores suportados pela ECU...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
              ]
              // FASE 5: SUCESSO!
              else if (connState == AppConnectionState.ready) ...[
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
                Text(
                  "${ref.read(supportedPidsProvider).length} sensores mapeados",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54),
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
