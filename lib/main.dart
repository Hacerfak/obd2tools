import 'package:flutter/material.dart';
import 'connection/obd_connection.dart';
import 'connection/obd_manager.dart';
import 'parser/pid_registry.dart';
import 'parser/mode_09_registry.dart';

void main() {
  runApp(const MontanaObdApp());
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

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
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

  @override
  void initState() {
    super.initState();
    _connection = ObdConnection();
    _manager = ObdManager(connection: _connection);
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
      String hexPid = _selectedPid
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase();
      _manager.queueCommand("01$hexPid");
    } else if (_selectedMode == "09") {
      String hexPid = _selectedPidMode09
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase();
      _manager.queueCommand("09$hexPid"); // Agora ele pede 0902, 0904, 090A...
    }
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
                      ElevatedButton(
                        onPressed: _sendCommand,
                        child: const Text("Ler Dado"),
                      ),
                    ],
                  ),
                ),
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
