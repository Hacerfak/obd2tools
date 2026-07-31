import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/connection_screen.dart';
import 'state/obd_providers.dart';

void main() {
  runApp(const ProviderScope(child: Obd2ToolsApp()));
}

// 1. TROQUE StatelessWidget POR ConsumerWidget
class Obd2ToolsApp extends ConsumerWidget {
  const Obd2ToolsApp({super.key});

  // 2. ADICIONE O WidgetRef ref NO BUILD
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. OBSERVE A ESCOLHA DO USUÁRIO
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'OBD2 Tools',
      debugShowCheckedModeBanner: false,

      // 4. APLIQUE O TEMA AQUI!
      themeMode: themeMode,

      // --- TEMA CLARO ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE9ECEF),
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // --- TEMA ESCURO ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF12151C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1D24),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E222D),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      home: const ConnectionScreen(),
    );
  }
}
