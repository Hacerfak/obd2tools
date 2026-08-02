import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/connection_screen.dart';
import 'state/obd_providers.dart';

void main() {
  runApp(const ProviderScope(child: Obd2ToolsApp()));
}

class Obd2ToolsApp extends ConsumerWidget {
  const Obd2ToolsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appColors = ref.watch(appColorsProvider);

    return MaterialApp(
      title: 'OBD2 Tools',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // --- TEMA CLARO ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: appColors.primary,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE9ECEF),
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor:
              Colors.transparent, // Tira o tingimento só da AppBar
        ),

        // CORREÇÃO AQUI: A classe correta é CardTheme
        cardTheme: CardThemeData(
          color: Colors.white, // Força o branco puro
          elevation: 2,
          surfaceTintColor: Colors.transparent, // Tira o tingimento do Card
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
        colorSchemeSeed: appColors.primary,
        scaffoldBackgroundColor: const Color(0xFF12151C),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1D24),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent, // Tira o tingimento da AppBar
        ),

        // CORREÇÃO AQUI
        cardTheme: CardThemeData(
          color: const Color(0xFF1E222D), // Força o cinza puro
          elevation: 2,
          surfaceTintColor: Colors.transparent, // Tira o tingimento do Card
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
