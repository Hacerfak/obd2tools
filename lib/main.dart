import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/connection_screen.dart'; // Importando do lugar certo!

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
      // Ao abrir o app, chama a tela nova. O attemptAutoConnect já é true por padrão!
      home: const ConnectionScreen(),
    );
  }
}
