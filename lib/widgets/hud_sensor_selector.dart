import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mapped_sensor.dart';
import '../state/obd_providers.dart';
import '../state/technical_data_service.dart';

class HudSensorSelector extends ConsumerStatefulWidget {
  final List<MappedSensor> initialSelection;
  final Function(List<MappedSensor>) onSave;

  const HudSensorSelector({
    super.key,
    required this.initialSelection,
    required this.onSave,
  });

  @override
  ConsumerState<HudSensorSelector> createState() => _HudSensorSelectorState();
}

class _HudSensorSelectorState extends ConsumerState<HudSensorSelector> {
  late List<MappedSensor> _selectedSensors;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedSensors = List.from(widget.initialSelection);
  }

  void _toggleSelection(MappedSensor sensor) {
    setState(() {
      if (_selectedSensors.any((s) => s.uniqueId == sensor.uniqueId)) {
        _selectedSensors.removeWhere((s) => s.uniqueId == sensor.uniqueId);
      } else {
        if (_selectedSensors.length < 12) {
          _selectedSensors.add(sensor);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportedSensors = ref.watch(supportedPidsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final techService = ref.watch(technicalDataProvider);

    // Helper para buscar o nome traduzido do JSON
    String getLocalizedDisplayName(MappedSensor sensor) {
      final hexId = sensor.pid.id
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase();
      final techData = techService.getSensorData(hexId);
      final translatedName = techData?.name.isNotEmpty == true
          ? techData!.name
          : sensor.pid.name;
      return "$translatedName (${sensor.module.name})";
    }

    final unselectedSensors = supportedSensors.where((s) {
      bool isNotSelected = !_selectedSensors.any(
        (sel) => sel.uniqueId == s.uniqueId,
      );
      String localizedName = getLocalizedDisplayName(s);
      bool matchesSearch = localizedName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return isNotSelected && matchesSearch;
    }).toList();

    bool isMaxReached = _selectedSensors.length >= 12;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                      "${_selectedSensors.length}/12 Sensores Selecionados",
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
                    widget.onSave(_selectedSensors);
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
                fillColor: onSurface.withValues(alpha: 0.05),
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
                if (_selectedSensors.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                      itemCount: _selectedSensors.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _selectedSensors.removeAt(oldIndex);
                          _selectedSensors.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final sensor = _selectedSensors[index];
                        return ListTile(
                          key: ValueKey("sel_${sensor.uniqueId}"),
                          leading: Icon(
                            Icons.drag_handle,
                            color: onSurface.withValues(alpha: 0.54),
                          ),
                          title: Text(
                            getLocalizedDisplayName(sensor),
                            style: TextStyle(color: onSurface),
                          ),
                          subtitle: Text(
                            sensor.pid.unit.isEmpty
                                ? "Status"
                                : sensor.pid.unit,
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.38),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _toggleSelection(sensor),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(color: onSurface.withValues(alpha: 0.1)),
                ],
                if (unselectedSensors.isNotEmpty) ...[
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
                      itemCount: unselectedSensors.length,
                      itemBuilder: (context, index) {
                        final sensor = unselectedSensors[index];
                        final isDisabled = isMaxReached;
                        return ListTile(
                          key: ValueKey("avail_${sensor.uniqueId}"),
                          enabled: !isDisabled,
                          leading: Icon(
                            sensor.pid.isFast ? Icons.speed : Icons.thermostat,
                            color: isDisabled
                                ? onSurface.withValues(alpha: 0.12)
                                : onSurface.withValues(alpha: 0.54),
                          ),
                          title: Text(
                            getLocalizedDisplayName(sensor),
                            style: TextStyle(
                              color: isDisabled
                                  ? onSurface.withValues(alpha: 0.24)
                                  : onSurface,
                            ),
                          ),
                          subtitle: Text(
                            sensor.pid.unit.isEmpty
                                ? "Status"
                                : sensor.pid.unit,
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
                                : () => _toggleSelection(sensor),
                          ),
                          onTap: isDisabled
                              ? null
                              : () => _toggleSelection(sensor),
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
