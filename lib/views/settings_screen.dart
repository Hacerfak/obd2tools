import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../state/obd_providers.dart';
import '../widgets/admob_banner.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isEditingLight = true;

  @override
  void initState() {
    super.initState();
    // Inicia a tela editando o tema atual do usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isEditingLight = Theme.of(context).brightness == Brightness.light;
        });
      }
    });
  }

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    String key,
    Color currentColor,
    String title,
  ) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Escolher cor: $title",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (Color color) {
              pickerColor = color;
            },
            enableAlpha: false,
            displayThumbColor: true,
            hexInputBar: true,
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
              ref
                  .read(appColorsProvider.notifier)
                  .updateColor(_isEditingLight, key, pickerColor);
              Navigator.pop(context);
            },
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Captura as paletas e filtra baseada no segmento escolhido
    final palette = ref.watch(appColorsProvider);
    final appColors = _isEditingLight ? palette.light : palette.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Configurações do Sistema",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Paleta de Cores",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // SELETOR DE TEMA PARA EDIÇÃO
                  Center(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.light_mode),
                          label: Text("Tema Claro"),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.dark_mode),
                          label: Text("Tema Escuro"),
                        ),
                      ],
                      selected: {_isEditingLight},
                      onSelectionChanged: (newSelection) {
                        setState(() => _isEditingLight = newSelection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildColorTile(
                    "Cor Principal (Tema/Neutros)",
                    appColors.primary,
                    'primary',
                    onSurface,
                  ),
                  _buildColorTile(
                    "Status Normal (Saudável)",
                    appColors.normal,
                    'normal',
                    onSurface,
                  ),
                  _buildColorTile(
                    "Status Atenção (Alerta)",
                    appColors.warning,
                    'warning',
                    onSurface,
                  ),
                  _buildColorTile(
                    "Status Crítico (Perigo)",
                    appColors.critical,
                    'critical',
                    onSurface,
                  ),

                  const SizedBox(height: 16),
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

                  const SizedBox(height: 32),
                  Text(
                    "Performance e Economia",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: onSurface.withValues(alpha: 0.05),
                    child: ListTile(
                      title: const Text("Taxa de Atualização dos Sensores"),
                      subtitle: const Text(
                        "Aumente o tempo se o celular estiver aquecendo",
                      ),
                      trailing: DropdownButton<int>(
                        value: ref.watch(pollingIntervalProvider),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text("Máxima")),
                          DropdownMenuItem(
                            value: 250,
                            child: Text("Rápido (250ms)"),
                          ),
                          DropdownMenuItem(
                            value: 500,
                            child: Text("Normal (0.5s)"),
                          ),
                          DropdownMenuItem(
                            value: 1000,
                            child: Text("Econômico (1s)"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(pollingIntervalProvider.notifier)
                                .updateInterval(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }

  Widget _buildColorTile(
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
