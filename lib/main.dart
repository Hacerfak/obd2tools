import 'package:flutter/material.dart';
import 'dart:async'; // Necessário para usar o Timer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connection/obd_connection.dart';
import 'connection/obd_manager.dart';
import 'state/obd_providers.dart';
import 'parser/registries/mode_01_registry.dart';
import 'parser/registries/mode_09_registry.dart';

void main() {
  runApp(const ProviderScope(child: MontanaObdApp()));
}

class MontanaObdApp extends StatelessWidget {
  const MontanaObdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Montana OBD',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ConnectionScreen(),
    );
  }
}

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final TextEditingController _macController = TextEditingController(
    text: "00:10:CC:4F:36:03",
  );
  final List<String> _logs = [];

  late ObdConnection _connection;
  late ObdManager _manager;
  bool _isConnected = false;

  // Variáveis para os seletores
  String _selectedMode = "01";
  int _selectedPid = 0x0C; // Padrão RPM
  int _selectedPidMode09 = 0x02;

  Timer? _pollingTimer;
  bool _isPolling = false;

  final Set<int> _activePids = {};

  @override
  void initState() {
    super.initState();
    _connection = ObdConnection();
    _manager = ObdManager(connection: _connection, ref: ref);
    _manager.logStream.listen((log) => setState(() => _logs.insert(0, log)));
  }

  Future<void> _connect() async {
    setState(() => _logs.insert(0, "Conectando..."));
    bool success = await _connection.connect(_macController.text.trim());
    if (success) {
      setState(() => _isConnected = true);
      _manager.initializeScanner(); // Envia os AT Z, etc.
    }
  }

  Future<void> _disconnect() async {
    await _connection.disconnect();
    setState(() => _isConnected = false);
  }

  // Função disparada pelo botão "Enviar Comando"
  void _sendCommand() {
    if (_selectedMode == "01") {
      // 1. Adiciona o sensor selecionado no Dropdown à nossa lista ativa
      _activePids.add(_selectedPid);

      // 2. O OBD2 só aceita até 6 PIDs por vez. Vamos garantir esse limite.
      List<int> pidsToRequest = _activePids.take(6).toList();

      // 3. Monta a string gigante do Multi-PID!
      String comandoMultiplo = "01";
      for (var pid in pidsToRequest) {
        comandoMultiplo += pid.toRadixString(16).padLeft(2, '0').toUpperCase();
      }

      // Envia de uma vez (Ex: "010F0C42100B")
      _manager.queueCommand(comandoMultiplo);
    } else if (_selectedMode == "09") {
      String hexPid = _selectedPidMode09
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase();
      _manager.queueCommand("09$hexPid");
    }
  }

  void _togglePolling() {
    if (_isPolling) {
      // Desliga o loop
      _pollingTimer?.cancel();
      setState(() => _isPolling = false);
    } else {
      // Liga o loop
      setState(() => _isPolling = true);

      // Executa a nossa função _sendCommand a cada 500 milissegundos
      _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (
        timer,
      ) {
        if (!_isConnected) {
          _togglePolling(); // Para por segurança se desconectar
          return;
        }
        _sendCommand();
      });
    }
  }

  void _clearList() {
    setState(() {
      _activePids.clear();
    });
    // Agora sim ele apaga tudo da tela!
    ref.read(realTimeStateProvider.notifier).clearData();
  }

  // Lembre-se de cancelar o timer se a tela for fechada para economizar bateria
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Montana OBD - Painel de Testes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _macController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço MAC',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isConnected,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isConnected ? _disconnect : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.green,
                  ),
                  child: Text(_isConnected ? 'Desconectar' : 'Conectar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // O Painel de Seleção que só aparece quando conectado
            if (_isConnected)
              Card(
                color: Colors.grey[850],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Seletor de Modo
                      DropdownButton<String>(
                        value: _selectedMode,
                        items: const [
                          DropdownMenuItem(
                            value: "01",
                            child: Text("Tempo Real (01)"),
                          ),
                          DropdownMenuItem(
                            value: "09",
                            child: Text("Info Veículo (09)"),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedMode = val!),
                      ),
                      const SizedBox(width: 16),

                      // Seletor de PID Dinâmico!
                      Expanded(
                        child: _selectedMode == "01"
                            ? DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedPid,
                                items: pidRegistry.entries
                                    .map(
                                      (entry) => DropdownMenuItem(
                                        value: entry.key,
                                        child: Text(entry.value.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedPid = val!),
                              )
                            : DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedPidMode09,
                                items: mode09Registry.entries
                                    .map(
                                      (entry) => DropdownMenuItem(
                                        value: entry.key,
                                        child: Text(entry.value.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedPidMode09 = val!),
                              ),
                      ),

                      const SizedBox(width: 16),
                      // BOTAO DE LEITURA ÚNICA
                      ElevatedButton(
                        onPressed: _isPolling
                            ? null
                            : _sendCommand, // Desabilita se estiver em loop
                        child: const Text("Ler 1x"),
                      ),
                      const SizedBox(width: 8),

                      // NOVO BOTAO DE LEITURA CONTÍNUA
                      ElevatedButton(
                        onPressed: _togglePolling,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPolling
                              ? Colors.redAccent
                              : Colors.blueAccent,
                        ),
                        child: Text(_isPolling ? "Parar" : "Monitorar"),
                      ),
                      ElevatedButton(
                        onPressed: _isPolling
                            ? null
                            : _clearList, // Desabilita se estiver em loop
                        child: const Text("Limpar"),
                      ),
                    ],
                  ),
                ),
              ),

            // NOVO: Painel de Dados em Tempo Real (Escutando o Riverpod)
            Consumer(
              builder: (context, ref, child) {
                // Escuta o túnel de tempo real
                final liveData = ref.watch(realTimeStateProvider);

                if (liveData.isEmpty) return const SizedBox.shrink();

                return Card(
                  color: Colors.blueGrey.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Métricas Atuais:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const Divider(),
                        ...liveData.entries.map((sensor) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  sensor.key,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${sensor.value.value.toStringAsFixed(1)} ${sensor.value.unit}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            const Text(
              "Terminal de Logs",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  reverse: true,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        _logs[index],
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
