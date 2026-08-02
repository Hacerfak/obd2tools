import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../state/obd_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    String key,
    Color currentColor,
    String title,
  ) {
    // Variável local para segurar a cor enquanto o usuário mexe no seletor
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Escolher cor: $title",
          style: const TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (Color color) {
              pickerColor = color;
            },
            enableAlpha:
                false, // Desativamos a transparência para evitar bugs visuais nos relógios
            displayThumbColor: true,
            hexInputBar: true, // A MÁGICA: Habilita o campo de digitação HEX!
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              // Salva a cor definitiva no cofre do Riverpod
              ref
                  .read(appColorsProvider.notifier)
                  .updateColor(key, pickerColor);
              Navigator.pop(context);
            },
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Paleta de Cores do Sistema",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorTile(
            context,
            ref,
            "Cor Principal (Tema/Neutros)",
            appColors.primary,
            'primary',
            onSurface,
          ),
          _buildColorTile(
            context,
            ref,
            "Status Normal (Saudável)",
            appColors.normal,
            'normal',
            onSurface,
          ),
          _buildColorTile(
            context,
            ref,
            "Status Atenção (Alerta)",
            appColors.warning,
            'warning',
            onSurface,
          ),
          _buildColorTile(
            context,
            ref,
            "Status Crítico (Perigo)",
            appColors.critical,
            'critical',
            onSurface,
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(appColorsProvider.notifier).resetToDefaults(),
            icon: const Icon(Icons.restore),
            label: const Text("Restaurar Cores Padrão"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.redAccent,
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    Color color,
    String stateKey,
    Color onSurface,
  ) {
    return Card(
      elevation: 0,
      color: onSurface.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: onSurface.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        onTap: () => _showColorPicker(context, ref, stateKey, color, title),
      ),
    );
  }
}
