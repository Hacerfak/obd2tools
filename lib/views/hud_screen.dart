import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '/l10n/app_localizations.dart';
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/obd_gauge.dart';
import '../connection/obd_manager.dart';
import '../widgets/hud_sensor_selector.dart';

class HudScreen extends ConsumerStatefulWidget {
  const HudScreen({super.key});

  @override
  ConsumerState<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends ConsumerState<HudScreen> {
  late final ObdManager _obdManager;
  final List<int> _activeGaugesPids = [];
  GaugeStyle _currentStyle = GaugeStyle.digital;
  bool _showTutorial = false;
  final FocusNode _focusNode = FocusNode();

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
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPids = prefs.getStringList('hud_pids');
    final savedStyleIndex = prefs.getInt('hud_style') ?? 0;
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

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isFullscreen = ref.watch(hudFullscreenProvider);
    final l10n = AppLocalizations.of(context)!;

    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    List<int> displayPids = _activeGaugesPids;
    if (isPhone && isLandscape && displayPids.length > 6) {
      displayPids = displayPids.take(6).toList();
    }

    // BOTÃO DE AÇÕES (EDITAR / FULLSCREEN)
    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
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
                      _activeGaugesPids.addAll(newSelection);
                    });
                    _savePreferences(newSelection);
                    _obdManager.setPollingPids(_activeGaugesPids);
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.edit_rounded),
          color: Theme.of(context).colorScheme.primary,
          tooltip: l10n.hudManage,
        ),
        if (!isPhone || isLandscape) ...[
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => ref.read(hudFullscreenProvider.notifier).toggle(),
            icon: const Icon(Icons.fullscreen),
            color: Theme.of(context).colorScheme.primary,
            tooltip: l10n.hudFullscreen,
          ),
        ],
      ],
    );

    // SELETOR RESPONSIVO DE ESTILOS
    final styleSelector = SegmentedButton<GaugeStyle>(
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
          value: GaugeStyle.stats,
          icon: Icon(Icons.query_stats, size: 18),
        ),
        ButtonSegment(
          value: GaugeStyle.chart,
          icon: Icon(Icons.show_chart_rounded, size: 18),
        ),
      ],
      selected: {_currentStyle},
      onSelectionChanged: (Set<GaugeStyle> newSelection) {
        final style = newSelection.first;
        setState(() => _currentStyle = style);
        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt('hud_style', style.index);
        });
      },
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        backgroundColor: onSurface.withValues(alpha: 0.1),
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            if (ref.read(hudFullscreenProvider)) {
              ref.read(hudFullscreenProvider.notifier).toggle();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                ref.read(hudFullscreenProvider.notifier).toggle();
                if (!isPhone) _focusNode.requestFocus();
              },
              child: Column(
                children: [
                  if (!isFullscreen)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: isPhone && !isLandscape
                          // LAYOUT VERTICAL NO CELULAR: 2 Linhas
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${l10n.tabHud} (${displayPids.length}/${_activeGaugesPids.length})",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: onSurface,
                                      ),
                                    ),
                                    actionButtons,
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: styleSelector,
                                ),
                              ],
                            )
                          // LAYOUT HORIZONTAL OU TABLET/DESKTOP: 1 Linha
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${l10n.tabHud} (${displayPids.length}/${_activeGaugesPids.length})",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: onSurface,
                                  ),
                                ),
                                Row(
                                  children: [
                                    actionButtons,
                                    const SizedBox(width: 8),
                                    styleSelector,
                                  ],
                                ),
                              ],
                            ),
                    ),

                  // GRID DE SENSORES ESTÁTICO E RESPONSIVO
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int totalItems = displayPids.length;
                          if (totalItems == 0) return const SizedBox();
                          int crossAxisCount;

                          if (!isPhone) {
                            crossAxisCount = totalItems > 6
                                ? 4
                                : (totalItems > 3 ? 3 : 2);
                          } else if (isLandscape) {
                            if (totalItems <= 2) {
                              crossAxisCount = totalItems;
                            } else if (totalItems <= 4) {
                              crossAxisCount = 2;
                            } else {
                              crossAxisCount = 3;
                            }
                          } else {
                            if (totalItems <= 2) {
                              crossAxisCount = 1;
                            } else if (totalItems <= 6) {
                              crossAxisCount = 2;
                            } else {
                              crossAxisCount = 3;
                            }
                          }

                          int rowCount = (totalItems / crossAxisCount).ceil();
                          double totalSpacingWidth =
                              (crossAxisCount - 1) * 12.0;
                          double extraBottomPadding = isFullscreen ? 16.0 : 0.0;
                          double totalSpacingHeight =
                              (rowCount - 1) * 12.0 + extraBottomPadding;
                          double itemWidth =
                              (constraints.maxWidth - totalSpacingWidth) /
                              crossAxisCount;
                          double itemHeight =
                              (constraints.maxHeight - totalSpacingHeight) /
                              rowCount;

                          if (itemWidth <= 0 || itemHeight <= 0) {
                            return const SizedBox();
                          }
                          double childAspectRatio = itemWidth / itemHeight;

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: extraBottomPadding,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemCount: totalItems,
                            itemBuilder: (context, index) {
                              final pidCode = displayPids[index];
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

            // OVERLAY TRANSLÚCIDO DE TUTORIAL
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
                            l10n.hudImmersive,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.hudImmersiveDesc,
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
                            child: Text(l10n.hudGotIt),
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
    );
  }
}
