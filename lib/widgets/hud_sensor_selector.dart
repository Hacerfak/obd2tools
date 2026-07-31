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
    // Fazemos uma cópia para o usuário poder cancelar sem estragar o HUD atual
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

    // CORREÇÃO 1: Protege contra IDs fantasmas que possam estar no SharedPreferences
    final selectedPidsFull = _selectedPids
        .where((id) => pidRegistry.containsKey(id))
        .map((id) => pidRegistry[id]!)
        .toList();

    // Pega o resto e aplica o filtro de pesquisa
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
      color: const Color(0xFF1A1D24),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Column(
        children: [
          // BARRA DE ARRASTAR
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // CABEÇALHO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Configurar HUD",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${_selectedPids.length}/12 Sensores Selecionados",
                      style: TextStyle(
                        color: isMaxReached
                            ? Colors.redAccent
                            : Colors.blueAccent,
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
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Salvar"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // BARRA DE PESQUISA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Pesquisar sensor...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // CORREÇÃO 2: Estrutura de Listas Independentes (Acaba com o Crash de Layout)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SEÇÃO REORDENÁVEL (ITENS SELECIONADOS) ---
                if (selectedPidsFull.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "SELECIONADOS (Arraste para reordenar)",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    // Flexible avisa o Flutter: "Se a lista for pequena, use pouco espaço. Se for grande, crie rolagem aqui mesmo."
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
                          key: ValueKey(
                            "sel_${pid.id}",
                          ), // Key única garante estabilidade
                          leading: const Icon(
                            Icons.drag_handle,
                            color: Colors.white54,
                          ),
                          title: Text(
                            pid.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            pid.unit.isEmpty ? "Status" : pid.unit,
                            style: const TextStyle(color: Colors.white38),
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
                  const Divider(color: Colors.white10),
                ],

                // --- SEÇÃO DE PESQUISA (ITENS DISPONÍVEIS) ---
                if (unselectedPidsFull.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "DISPONÍVEIS",
                      style: TextStyle(
                        color: Colors.white38,
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
                            color: isDisabled ? Colors.white12 : Colors.white54,
                          ),
                          title: Text(
                            pid.name,
                            style: TextStyle(
                              color: isDisabled ? Colors.white24 : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            pid.unit.isEmpty ? "Status" : pid.unit,
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.white12
                                  : Colors.white38,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: isDisabled
                                  ? Colors.white12
                                  : Colors.blueAccent,
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
