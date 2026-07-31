import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/obd_gauge.dart';
import '../connection/obd_manager.dart';
import '../widgets/hud_sensor_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HudScreen extends ConsumerStatefulWidget {
  const HudScreen({super.key});

  @override
  ConsumerState<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends ConsumerState<HudScreen> {
  late final ObdManager _obdManager;
  final List<int> _activeGaugesPids = [0x0C, 0x0D, 0x05, 0x04, 0x0F, 0x11];
  GaugeStyle _currentStyle = GaugeStyle.digital;

  @override
  void initState() {
    super.initState();
    _obdManager = ref.read(obdManagerProvider);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPids = prefs.getStringList('hud_pids');
    setState(() {
      _activeGaugesPids.clear();
      if (savedPids != null && savedPids.isNotEmpty) {
        final uniquePids = savedPids.map(int.parse).toSet().toList();
        _activeGaugesPids.addAll(uniquePids);
      } else {
        _activeGaugesPids.addAll([0x0C, 0x0D, 0x05, 0x04, 0x0F, 0x11]);
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

  int _getCrossAxisCount(int totalItems, bool isDesktop) {
    if (isDesktop) return totalItems > 6 ? 4 : (totalItems > 3 ? 3 : 2);
    if (totalItems <= 2) return 1;
    if (totalItems <= 6) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "HUD (${_activeGaugesPids.length}/12)",
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
                      color: Colors.blueAccent,
                      tooltip: 'Gerenciar Sensores',
                    ),
                    const SizedBox(width: 12),
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
                      onSelectionChanged: (Set<GaugeStyle> newSelection) {
                        setState(() => _currentStyle = newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: onSurface.withValues(alpha: 0.1),
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 600;
                  int crossAxisCount = _getCrossAxisCount(
                    _activeGaugesPids.length,
                    isDesktop,
                  );
                  int rowCount = (_activeGaugesPids.length / crossAxisCount)
                      .ceil();
                  if (rowCount == 0) rowCount = 1;

                  double totalSpacingWidth = (crossAxisCount - 1) * 12.0;
                  double totalSpacingHeight = (rowCount - 1) * 12.0;
                  double itemWidth =
                      (constraints.maxWidth - totalSpacingWidth) /
                      crossAxisCount;
                  double itemHeight =
                      (constraints.maxHeight - totalSpacingHeight) / rowCount;
                  double childAspectRatio = itemWidth / itemHeight;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.only(top: 8),
            color: Theme.of(context).colorScheme.inverseSurface,
            child: Center(
              child: Text(
                "ESPAÇO RESERVADO PARA ADMOB",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onInverseSurface.withValues(alpha: 0.38),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
