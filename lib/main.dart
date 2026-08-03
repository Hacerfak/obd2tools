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
    final appThemePalette = ref.watch(appColorsProvider);

    // Captura as configurações de forma independente
    final lightColors = appThemePalette.light;
    final darkColors = appThemePalette.dark;

    return MaterialApp(
      title: 'OBD2 Tools',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // --- TEMA CLARO ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: lightColors.primary,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE9ECEF),
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          surfaceTintColor: Colors.transparent,
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
        colorSchemeSeed: darkColors.primary,
        scaffoldBackgroundColor: const Color(0xFF12151C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1D24),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E222D),
          elevation: 2,
          surfaceTintColor: Colors.transparent,
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
      home: const ConnectionScreen(attemptAutoConnect: true),
    );
  }
}
