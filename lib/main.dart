import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/obd_providers.dart';
import 'views/home_screen.dart'; // Importando a nossa nova casca visual!

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
  bool _isConnecting = false; // Controla o indicador de carregamento

  @override
  void initState() {
    super.initState();
    ref.read(obdManagerProvider).logStream.listen((log) {
      if (mounted) setState(() => _logs.insert(0, log));
    });

    // Tenta conectar automaticamente assim que a tela abre!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connect();
    });
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _logs.insert(0, "Iniciando conexão automática...");
    });

    final manager = ref.read(obdManagerProvider);
    bool success = await manager.connection.connect(_macController.text.trim());

    if (success) {
      manager.initializeScanner();
      manager.discoverSupportedSensors();

      // Dá um pequeno respiro de 1.5 segundos para a auto-descoberta acontecer
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        // Redireciona para a HomeScreen e remove a tela de conexão do histórico!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Se falhar (Bluetooth desligado, fora de alcance), volta para a tela manual
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _logs.insert(
            0,
            "Falha na conexão. Verifique o adaptador e tente novamente.",
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12151C), // Mantendo a identidade visual
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo ou Título do App
              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                "Montana OBD",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // ÁREA DE ESTADO (Carregando ou Botão Manual)
              if (_isConnecting)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 24),
                    Text(
                      "Sincronizando com a injeção eletrônica...",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _macController,
                      decoration: InputDecoration(
                        labelText: 'Endereço MAC do Scanner',
                        labelStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _connect,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Tentar Conectar Novamente",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
