import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import '../models/dtc_fault.dart';
import 'fault_detail_screen.dart';

class FaultsScreen extends ConsumerStatefulWidget {
  const FaultsScreen({super.key});

  @override
  ConsumerState<FaultsScreen> createState() => _FaultsScreenState();
}

class _FaultsScreenState extends ConsumerState<FaultsScreen> {
  DtcStatus? _selectedFilter; // null = Todas

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(obdManagerProvider).scanAllFaults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dtcState = ref.watch(dtcStateProvider);

    // Aplica o filtro selecionado
    List<DtcFault> filteredFaults = dtcState.faults.values.where((fault) {
      if (_selectedFilter == null) return true;
      return fault.statuses.contains(_selectedFilter);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Diagnóstico (DTC)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => ref.read(obdManagerProvider).scanAllFaults(),
                  icon: const Icon(Icons.refresh),
                  color: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // FILTROS (CHIPS)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Todas", null),
                  const SizedBox(width: 8),
                  _buildFilterChip("Confirmadas", DtcStatus.confirmed),
                  const SizedBox(width: 8),
                  _buildFilterChip("Pendentes", DtcStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip("Permanentes", DtcStatus.permanent),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // LISTA DE FALHAS
            Expanded(
              child: dtcState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    )
                  : filteredFaults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: Colors.greenAccent.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Nenhuma falha encontrada!",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredFaults.length,
                      itemBuilder: (context, index) {
                        final fault = filteredFaults[index];
                        return _buildFaultCard(fault);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, DtcStatus? status) {
    bool isSelected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? status : null);
      },
      backgroundColor: const Color(0xFF1A1D24),
      selectedColor: Colors.blueAccent.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.blueAccent : Colors.white70,
      ),
      side: BorderSide(
        color: isSelected ? Colors.blueAccent : Colors.transparent,
      ),
    );
  }

  Widget _buildFaultCard(DtcFault fault) {
    return Card(
      color: const Color(0xFF1A1D24),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FaultDetailScreen(fault: fault)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fault.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: fault.statuses
                          .map((s) => _buildStatusBadge(s))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DtcStatus status) {
    Color color;
    String text;

    switch (status) {
      case DtcStatus.confirmed:
        color = Colors.redAccent;
        text = "Confirmada";
        break;
      case DtcStatus.pending:
        color = Colors.orangeAccent;
        text = "Pendente";
        break;
      case DtcStatus.permanent:
        color = Colors.purpleAccent;
        text = "Permanente";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
