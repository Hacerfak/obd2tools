import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';
import '../parser/parsers/mode_06_parser.dart';
import '../widgets/admob_banner.dart';

class TestResultsScreen extends ConsumerStatefulWidget {
  const TestResultsScreen({super.key});

  @override
  ConsumerState<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends ConsumerState<TestResultsScreen> {
  bool _isLoading = true;

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
            SizedBox(height: vPadding),
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
                  : resultsList.isEmpty
                  ? Center(
                      child: Text(
                        l10n.testNone,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: resultsList.length,
                      itemBuilder: (context, index) {
                        final test = resultsList[index];
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

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 40),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Mode06Parser.getMonitorName(
                                          test.mid,
                                          l10n,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${Mode06Parser.getTidDescription(test.tid, l10n)}   $statusText",
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
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
