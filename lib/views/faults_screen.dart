import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';
import '../models/dtc_fault.dart';
import 'fault_detail_screen.dart';

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

  void _showClearDialog(BuildContext context, WidgetRef ref, Color onSurface) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.faultClearMil, style: TextStyle(color: onSurface)),
        content: Text(
          l10n.faultClearDesc,
          style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.btnCancel,
              style: TextStyle(color: onSurface.withValues(alpha: 0.54)),
            ),
          ),
          FilledButton(
            onPressed: () {
              ref.read(obdManagerProvider).clearDTCs();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              l10n.faultYesClear,
              style: const TextStyle(color: Colors.white),
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
    AppLocalizations l10n,
    bool isLandscape,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.faultTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
        ),
        if (!isScreenLoading) ...[
          if (hasFaults) ...[
            IconButton.filled(
              onPressed: () => _showClearDialog(context, ref, onSurface),
              icon: const Icon(Icons.delete_forever),
              tooltip: l10n.faultClearMil,
              visualDensity: isLandscape ? VisualDensity.compact : null,
              style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton.filledTonal(
            onPressed: () => ref.read(obdManagerProvider).scanAllFaults(),
            icon: const Icon(Icons.refresh),
            color: primaryColor,
            tooltip: l10n.btnRefresh,
            visualDensity: isLandscape ? VisualDensity.compact : null,
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
    final l10n = AppLocalizations.of(context)!;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double vPadding = isLandscape ? 8.0 : 16.0;

    List<DtcFault> filteredFaults = dtcState.faults.values.where((fault) {
      if (_selectedFilter == null) return true;
      return fault.statuses.contains(_selectedFilter);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, vPadding, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              primaryColor,
              onSurface,
              isScreenLoading,
              hasFaults,
              l10n,
              isLandscape,
            ),
            SizedBox(height: vPadding),
            if (!isScreenLoading) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(l10n.faultAll, null, onSurface),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      l10n.faultConfirmed,
                      DtcStatus.confirmed,
                      onSurface,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      l10n.faultPending,
                      DtcStatus.pending,
                      onSurface,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      l10n.faultPermanent,
                      DtcStatus.permanent,
                      onSurface,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isLandscape ? 12 : 24),
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
                            l10n.faultReading,
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
                          Text(
                            l10n.faultNone,
                            style: const TextStyle(
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
                          l10n,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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

  Widget _buildFaultCard(
    DtcFault fault,
    Color onSurface,
    AppLocalizations l10n,
  ) {
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
                          .map((s) => _buildStatusBadge(s, l10n))
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

  Widget _buildStatusBadge(DtcStatus status, AppLocalizations l10n) {
    Color color;
    String text;
    switch (status) {
      case DtcStatus.confirmed:
        color = Colors.redAccent;
        text = l10n.faultConfirmed;
        break;
      case DtcStatus.pending:
        color = Colors.orangeAccent;
        text = l10n.faultPending;
        break;
      case DtcStatus.permanent:
        color = Colors.purpleAccent;
        text = l10n.faultPermanent;
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
