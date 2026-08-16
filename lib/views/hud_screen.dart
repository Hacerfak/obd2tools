import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '/l10n/app_localizations.dart'; // IMPORT DA TRADUÇÃO
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/obd_gauge.dart';
import '../connection/obd_manager.dart';
import '../widgets/hud_sensor_selector.dart';
import '../widgets/admob_banner.dart';

class HudScreen extends ConsumerStatefulWidget {
  const HudScreen({super.key});

  @override
  ConsumerState<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends ConsumerState<HudScreen> {
  late final ObdManager _obdManager;
  final List<int> _activeGaugesPids = [];
  GaugeStyle _currentStyle = GaugeStyle.digital;

  // Controles do tutorial e teclado
  bool _showTutorial = false;
  final FocusNode _focusNode = FocusNode();

  // Função auxiliar segura para detectar mobile
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _obdManager = ref.read(obdManagerProvider);
    _loadPreferences();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _focusNode.dispose(); // Limpamos o nó de foco do teclado
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPids = prefs.getStringList('hud_pids');
    final savedStyleIndex = prefs.getInt('hud_style') ?? 0;

    // Verifica se já mostramos o tutorial no Mobile
    final tutorialShown = prefs.getBool('hud_tutorial_shown') ?? false;

    setState(() {
      _currentStyle = GaugeStyle.values[savedStyleIndex];
      _activeGaugesPids.clear();

      if (savedPids != null && savedPids.isNotEmpty) {
        final uniquePids = savedPids.map(int.parse).toSet().toList();
        _activeGaugesPids.addAll(uniquePids);
      } else {
        _activeGaugesPids.addAll([0x0C, 0x0D, 0x05, 0x04, 0x0F, 0x11]);
      }

      // Se for mobile e o tutorial nunca foi visto, ativa o overlay
      if (_isMobile && !tutorialShown) {
        _showTutorial = true;
      }
    });

    _obdManager.setPollingPids(_activeGaugesPids);
  }

  Future<void> _savePreferences(List<int> newSelection) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'hud_pids',
      newSelection.map((e) => e.toString()).toList(),
    );
  }

  void _dismissTutorial() async {
    setState(() => _showTutorial = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hud_tutorial_shown', true);
  }

  int _getCrossAxisCount(int totalItems, bool isDesktop) {
    if (isDesktop) return totalItems > 6 ? 4 : (totalItems > 3 ? 3 : 2);
    if (totalItems <= 2) return 1;
    if (totalItems <= 6) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isFullscreen = ref.watch(hudFullscreenProvider);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final l10n = AppLocalizations.of(context)!; // Instância de traduções

    return Scaffold(
      // FOCUS ESCUTA EVENTOS DO TECLADO NO DESKTOP (EX: TECLA ESC)
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            // Se apertar ESC e estiver em tela cheia, sai da tela cheia
            if (ref.read(hudFullscreenProvider)) {
              ref.read(hudFullscreenProvider.notifier).toggle();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // CONTEÚDO PRINCIPAL (GESTURE PARA DUPLO TOQUE NO FUNDO)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                ref.read(hudFullscreenProvider.notifier).toggle();
                // O foco precisa ser requisitado novamente após o clique para o ESC continuar funcionando
                if (!isDesktop) _focusNode.requestFocus();
              },
              child: Column(
                children: [
                  // CABEÇALHO (SOME NO FULLSCREEN)
                  if (!isFullscreen)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${l10n.tabHud} (${_activeGaugesPids.length}/12)", // Texto Traduzido + Contador
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: HudSensorSelector(
                                        initialSelection: _activeGaugesPids,
                                        onSave: (newSelection) {
                                          setState(() {
                                            _activeGaugesPids.clear();
                                            _activeGaugesPids.addAll(
                                              newSelection,
                                            );
                                          });
                                          _savePreferences(newSelection);
                                          _obdManager.setPollingPids(
                                            _activeGaugesPids,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_rounded),
                                color: Theme.of(context).colorScheme.primary,
                                tooltip: l10n.hudManage, // Tooltip Traduzido
                              ),
                              const SizedBox(width: 8),
                              SegmentedButton<GaugeStyle>(
                                segments: const [
                                  ButtonSegment(
                                    value: GaugeStyle.digital,
                                    icon: Icon(Icons.speed, size: 18),
                                  ),
                                  ButtonSegment(
                                    value: GaugeStyle.analog,
                                    icon: Icon(Icons.av_timer, size: 18),
                                  ),
                                  ButtonSegment(
                                    value: GaugeStyle.lineChart,
                                    icon: Icon(Icons.show_chart, size: 18),
                                  ),
                                ],
                                selected: {_currentStyle},
                                onSelectionChanged:
                                    (Set<GaugeStyle> newSelection) {
                                      final style = newSelection.first;
                                      setState(() => _currentStyle = style);
                                      SharedPreferences.getInstance().then((
                                        prefs,
                                      ) {
                                        prefs.setInt('hud_style', style.index);
                                      });
                                    },
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                  selectedForegroundColor: Colors.white,
                                  selectedBackgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ),
                              // BOTÃO DE TELA CHEIA (APENAS PARA DESKTOP)
                              if (isDesktop) ...[
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: () => ref
                                      .read(hudFullscreenProvider.notifier)
                                      .toggle(),
                                  icon: const Icon(Icons.fullscreen),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip:
                                      l10n.hudFullscreen, // Tooltip Traduzido
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  // GAUGES
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = _getCrossAxisCount(
                            _activeGaugesPids.length,
                            isDesktop,
                          );
                          int rowCount =
                              (_activeGaugesPids.length / crossAxisCount)
                                  .ceil();
                          if (rowCount == 0) rowCount = 1;

                          double totalSpacingWidth =
                              (crossAxisCount - 1) * 12.0;
                          double totalSpacingHeight = (rowCount - 1) * 12.0;
                          if (isFullscreen) totalSpacingHeight += 16.0;

                          double itemWidth =
                              (constraints.maxWidth - totalSpacingWidth) /
                              crossAxisCount;
                          double itemHeight =
                              (constraints.maxHeight - totalSpacingHeight) /
                              rowCount;
                          double childAspectRatio = itemWidth / itemHeight;

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemCount: _activeGaugesPids.length,
                            itemBuilder: (context, index) {
                              final pidCode = _activeGaugesPids[index];
                              final pid = pidRegistry[pidCode]!;
                              return ObdGauge(pid: pid, style: _currentStyle);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // OVERLAY TRANSLÚCIDO DE TUTORIAL (APARECE APENAS NA 1ª VEZ NO MOBILE)
            if (_showTutorial)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _dismissTutorial,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.hudImmersive, // Título do Tutorial
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.hudImmersiveDesc, // Descrição do Tutorial
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton(
                            onPressed: _dismissTutorial,
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: Text(l10n.hudGotIt), // Botão Entendi
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
