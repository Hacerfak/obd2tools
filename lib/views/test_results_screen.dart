import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';
import '../parser/parsers/mode_06_parser.dart';
import '../state/technical_data_service.dart';
import 'test_detail_screen.dart';

enum TestFilter { all, passed, failed, waiting }

class TestResultsScreen extends ConsumerStatefulWidget {
  const TestResultsScreen({super.key});

  @override
  ConsumerState<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends ConsumerState<TestResultsScreen> {
  bool _isLoading = true;
  TestFilter _selectedFilter = TestFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runScan();
    });
  }

  void _runScan() async {
    setState(() => _isLoading = true);
    ref.read(obdManagerProvider).scanTestResults();
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsList = ref.watch(testResultsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);
    final l10n = AppLocalizations.of(context)!;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double vPadding = isLandscape ? 8.0 : 16.0;

    final totalCount = resultsList.length;
    final passedCount = resultsList.where((t) => t.hasData && t.isPass).length;
    final failedCount = resultsList.where((t) => t.hasData && !t.isPass).length;
    final waitingCount = resultsList.where((t) => !t.hasData).length;

    final filteredList = resultsList.where((test) {
      switch (_selectedFilter) {
        case TestFilter.passed:
          return test.hasData && test.isPass;
        case TestFilter.failed:
          return test.hasData && !test.isPass;
        case TestFilter.waiting:
          return !test.hasData;
        case TestFilter.all:
          return true;
      }
    }).toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, vPadding, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.testTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                if (!_isLoading)
                  IconButton.filledTonal(
                    onPressed: _runScan,
                    icon: const Icon(Icons.refresh),
                    color: appColors.primary,
                    tooltip: l10n.btnRefresh,
                    visualDensity: isLandscape ? VisualDensity.compact : null,
                  ),
              ],
            ),
            SizedBox(height: vPadding / 2),

            if (!_isLoading && resultsList.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: l10n.faultAll,
                      filter: TestFilter.all,
                      count: totalCount,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.testPassed,
                      filter: TestFilter.passed,
                      count: passedCount,
                      activeColor: appColors.normal,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.testFailed,
                      filter: TestFilter.failed,
                      count: failedCount,
                      activeColor: appColors.critical,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.testWaiting,
                      filter: TestFilter.waiting,
                      count: waitingCount,
                      activeColor: onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              SizedBox(height: vPadding),
            ],

            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: appColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            l10n.testConsulting,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.54),
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredList.isEmpty
                  ? Center(
                      child: Text(
                        l10n.testNone,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final test = filteredList[index];
                        Color statusColor;
                        IconData statusIcon;
                        String statusText;

                        if (!test.hasData) {
                          statusColor = onSurface.withValues(alpha: 0.3);
                          statusIcon = Icons.pending_actions;
                          statusText = l10n.testWaiting;
                        } else if (test.isPass) {
                          statusColor = appColors.normal;
                          statusIcon = Icons.check_circle;
                          statusText = l10n.testPassed;
                        } else {
                          statusColor = appColors.critical;
                          statusIcon = Icons.cancel;
                          statusText = l10n.testFailed;
                        }

                        final unit = Mode06Parser.getUasUnit(test.cid, l10n);

                        // CONSULTA DIRETA AO DICIONÁRIO TÉCNICO
                        final midHex = test.mid
                            .toRadixString(16)
                            .padLeft(2, '0')
                            .toUpperCase();
                        final tidHex = test.tid
                            .toRadixString(16)
                            .padLeft(2, '0')
                            .toUpperCase();
                        final techData = ref
                            .watch(technicalDataProvider)
                            .getMode06Data(midHex, tidHex);

                        final testTitle = techData?.title.isNotEmpty == true
                            ? techData!.title
                            : "Monitor 0x$midHex (Teste 0x$tidHex)";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TestDetailScreen(test: test),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          testTitle,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "MID: 0x$midHex | TID: 0x$tidHex — $statusText",
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildMiniBox(
                                              l10n.testValue,
                                              "${test.value} $unit".trim(),
                                              onSurface,
                                            ),
                                            _buildMiniBox(
                                              l10n.testMin,
                                              "${test.min} $unit".trim(),
                                              onSurface,
                                            ),
                                            _buildMiniBox(
                                              l10n.testMax,
                                              "${test.max} $unit".trim(),
                                              onSurface,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required TestFilter filter,
    required int count,
    Color? activeColor,
  }) {
    final isSelected = _selectedFilter == filter;
    final theme = Theme.of(context);
    final color = activeColor ?? theme.colorScheme.primary;

    return ChoiceChip(
      label: Text("$label ($count)"),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
        }
      },
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? color
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      side: BorderSide(
        color: isSelected
            ? color
            : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildMiniBox(String title, String value, Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: onSurface.withValues(alpha: 0.4),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: onSurface,
            fontFamily: 'Monospace',
          ),
        ),
      ],
    );
  }
}
