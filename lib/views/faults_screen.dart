import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/obd_providers.dart';
import '../models/dtc_fault.dart';
import 'fault_detail_screen.dart';
import '../widgets/admob_banner.dart'; // IMPORT DO BANNER

class FaultsScreen extends ConsumerStatefulWidget {
  const FaultsScreen({super.key});

  @override
  ConsumerState<FaultsScreen> createState() => _FaultsScreenState();
}

class _FaultsScreenState extends ConsumerState<FaultsScreen> {
  DtcStatus? _selectedFilter;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(obdManagerProvider).scanAllFaults();
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    });
  }

  // --- MUDAMOS O DIÁLOGO PARA CÁ ---
  void _showClearDialog(BuildContext context, WidgetRef ref, Color onSurface) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Apagar Luz de Injeção?",
          style: TextStyle(color: onSurface),
        ),
        content: Text(
          "Esta ação vai resetar a memória de falhas e o Freeze Frame da injeção eletrônica. Certifique-se de estar com a CHAVE LIGADA e o MOTOR DESLIGADO.",
          style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(color: onSurface.withValues(alpha: 0.54)),
            ),
          ),
          FilledButton(
            onPressed: () {
              ref.read(obdManagerProvider).clearDTCs();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              "Sim, Apagar!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    Color primaryColor,
    Color onSurface,
    bool isScreenLoading,
    bool hasFaults,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Diagnóstico (DTC)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
        ),

        // SÓ MOSTRA AÇÕES SE A VARREDURA TIVER CONCLUÍDA!
        if (!isScreenLoading) ...[
          // BOTÃO DE APAGAR (SÓ APARECE SE HOUVER ALGUMA FALHA GRAVADA!)
          if (hasFaults) ...[
            IconButton.filled(
              onPressed: () => _showClearDialog(context, ref, onSurface),
              icon: const Icon(Icons.delete_forever),
              tooltip: "Apagar todas as falhas",
              style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // BOTÃO DE ATUALIZAR (SEMPRE DISPONÍVEL APÓS O LOADING)
          IconButton.filledTonal(
            onPressed: () => ref.read(obdManagerProvider).scanAllFaults(),
            icon: const Icon(Icons.refresh),
            color: primaryColor,
            tooltip: "Refazer Leitura",
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dtcState = ref.watch(dtcStateProvider);
    final bool isScreenLoading = _isInitializing || dtcState.isLoading;
    final bool hasFaults = dtcState.faults.isNotEmpty;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    List<DtcFault> filteredFaults = dtcState.faults.values.where((fault) {
      if (_selectedFilter == null) return true;
      return fault.statuses.contains(_selectedFilter);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primaryColor, onSurface, isScreenLoading, hasFaults),
            const SizedBox(height: 16),
            if (!isScreenLoading) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Todas", null, onSurface),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      "Confirmadas",
                      DtcStatus.confirmed,
                      onSurface,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      "Em avaliação",
                      DtcStatus.pending,
                      onSurface,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      "Monitoradas pela ECU",
                      DtcStatus.permanent,
                      onSurface,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Expanded(
              child: isScreenLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            "Lendo memória da ECU e dados congelados...\nPor favor, aguarde.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
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
                        return _buildFaultCard(
                          filteredFaults[index],
                          onSurface,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // --- BANNER DO ADMOB NO RODAPÉ ---
      bottomNavigationBar: const AdMobBanner(),
    );
  }

  Widget _buildFilterChip(String label, DtcStatus? status, Color onSurface) {
    bool isSelected = _selectedFilter == status;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? status : null);
      },
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      selectedColor: primaryColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? primaryColor : onSurface.withValues(alpha: 0.7),
      ),
      side: BorderSide(color: isSelected ? primaryColor : Colors.transparent),
    );
  }

  Widget _buildFaultCard(DtcFault fault, Color onSurface) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                      style: TextStyle(
                        color: onSurface,
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
              Icon(
                Icons.chevron_right,
                color: onSurface.withValues(alpha: 0.54),
              ),
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
        text = "Em avaliação";
        break;
      case DtcStatus.permanent:
        color = Colors.purpleAccent;
        text = "Monitorada pela ECU";
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
