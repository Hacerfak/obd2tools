import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';

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
    AppLocalizations l10n, // Recebendo as traduções aqui
  ) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.setChooseColor(title), // Usa a string com placeholder
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
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(appColorsProvider.notifier)
                  .updateColor(_isEditingLight, key, pickerColor);
              Navigator.pop(context);
            },
            child: Text(l10n.btnApply),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!; // Instância de tradução

    // Captura as paletas e filtra baseada no segmento escolhido
    final palette = ref.watch(appColorsProvider);
    final appColors = _isEditingLight ? palette.light : palette.dark;

    // VERIFICA SE ESTÁ DEITADO E CALCULA AS MARGENS
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double vPadding = isLandscape ? 8.0 : 16.0;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, vPadding, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.setTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            SizedBox(height: vPadding),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    l10n.setColor,
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
                      segments: [
                        ButtonSegment(
                          value: true,
                          icon: const Icon(Icons.light_mode),
                          label: Text(l10n.setThemeLight),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: const Icon(Icons.dark_mode),
                          label: Text(l10n.setThemeDark),
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
                    l10n.setMainColor,
                    appColors.primary,
                    'primary',
                    onSurface,
                    l10n,
                  ),
                  _buildColorTile(
                    l10n.setNormalColor,
                    appColors.normal,
                    'normal',
                    onSurface,
                    l10n,
                  ),
                  _buildColorTile(
                    l10n.setWarningColor,
                    appColors.warning,
                    'warning',
                    onSurface,
                    l10n,
                  ),
                  _buildColorTile(
                    l10n.setCriticalColor,
                    appColors.critical,
                    'critical',
                    onSurface,
                    l10n,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(appColorsProvider.notifier).resetToDefaults(),
                    icon: const Icon(Icons.restore),
                    label: Text(l10n.setRestoreColors),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.redAccent,
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.setPerf,
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
                      title: Text(l10n.setRate),
                      subtitle: Text(l10n.setRateDesc),
                      trailing: DropdownButton<int>(
                        value: ref.watch(pollingIntervalProvider),
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.setRateMax),
                          ),
                          DropdownMenuItem(
                            value: 25,
                            child: Text(l10n.setRateFast),
                          ),
                          DropdownMenuItem(
                            value: 100,
                            child: Text(l10n.setRateNormal),
                          ),
                          DropdownMenuItem(
                            value: 500,
                            child: Text(l10n.setRateEco),
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
    );
  }

  Widget _buildColorTile(
    String title,
    Color color,
    String stateKey,
    Color onSurface,
    AppLocalizations l10n,
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
        onTap: () =>
            _showColorPicker(context, ref, stateKey, color, title, l10n),
      ),
    );
  }
}
