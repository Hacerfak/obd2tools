import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';

class HudSensorSelector extends ConsumerStatefulWidget {
  final List<int> initialSelection;
  final Function(List<int>) onSave;

  const HudSensorSelector({
    super.key,
    required this.initialSelection,
    required this.onSave,
  });

  @override
  ConsumerState<HudSensorSelector> createState() => _HudSensorSelectorState();
}

class _HudSensorSelectorState extends ConsumerState<HudSensorSelector> {
  late List<int> _selectedPids;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedPids = List.from(widget.initialSelection);
  }

  void _toggleSelection(int pidId) {
    setState(() {
      if (_selectedPids.contains(pidId)) {
        _selectedPids.remove(pidId);
      } else {
        if (_selectedPids.length < 12) {
          _selectedPids.add(pidId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportedPids = ref.watch(supportedPidsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final selectedPidsFull = _selectedPids
        .where((id) => pidRegistry.containsKey(id))
        .map((id) => pidRegistry[id]!)
        .toList();

    final unselectedPidsFull = pidRegistry.values.where((pid) {
      bool isSupported = supportedPids.contains(pid.id);
      bool isNotSelected = !_selectedPids.contains(pid.id);
      bool matchesSearch = pid.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return isSupported && isNotSelected && matchesSearch;
    }).toList();

    bool isMaxReached = _selectedPids.length >= 12;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor, // Agora segue o tema!
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Configurar HUD",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      "${_selectedPids.length}/12 Sensores Selecionados",
                      style: TextStyle(
                        color: isMaxReached
                            ? Colors.redAccent
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () {
                    widget.onSave(_selectedPids);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    "Salvar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: onSurface),
              decoration: InputDecoration(
                hintText: "Pesquisar sensor...",
                hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.38)),
                prefixIcon: Icon(
                  Icons.search,
                  color: onSurface.withValues(alpha: 0.38),
                ),
                filled: true,
                fillColor: onSurface.withValues(
                  alpha: 0.05,
                ), // Input field amigável ao tema
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedPidsFull.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "SELECIONADOS (Arraste para reordenar)",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      itemCount: selectedPidsFull.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _selectedPids.removeAt(oldIndex);
                          _selectedPids.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final pid = selectedPidsFull[index];
                        return ListTile(
                          key: ValueKey("sel_${pid.id}"),
                          leading: Icon(
                            Icons.drag_handle,
                            color: onSurface.withValues(alpha: 0.54),
                          ),
                          title: Text(
                            pid.name,
                            style: TextStyle(color: onSurface),
                          ),
                          subtitle: Text(
                            pid.unit.isEmpty ? "Status" : pid.unit,
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.38),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _toggleSelection(pid.id),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(color: onSurface.withValues(alpha: 0.1)),
                ],
                if (unselectedPidsFull.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "DISPONÍVEIS",
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: unselectedPidsFull.length,
                      itemBuilder: (context, index) {
                        final pid = unselectedPidsFull[index];
                        final isDisabled = isMaxReached;
                        return ListTile(
                          key: ValueKey("avail_${pid.id}"),
                          enabled: !isDisabled,
                          leading: Icon(
                            pid.isFast ? Icons.speed : Icons.thermostat,
                            color: isDisabled
                                ? onSurface.withValues(alpha: 0.12)
                                : onSurface.withValues(alpha: 0.54),
                          ),
                          title: Text(
                            pid.name,
                            style: TextStyle(
                              color: isDisabled
                                  ? onSurface.withValues(alpha: 0.24)
                                  : onSurface,
                            ),
                          ),
                          subtitle: Text(
                            pid.unit.isEmpty ? "Status" : pid.unit,
                            style: TextStyle(
                              color: isDisabled
                                  ? onSurface.withValues(alpha: 0.12)
                                  : onSurface.withValues(alpha: 0.38),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: isDisabled
                                  ? onSurface.withValues(alpha: 0.12)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: isDisabled
                                ? null
                                : () => _toggleSelection(pid.id),
                          ),
                          onTap: isDisabled
                              ? null
                              : () => _toggleSelection(pid.id),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
