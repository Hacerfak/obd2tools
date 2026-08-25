import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';

class VehicleInfoScreen extends ConsumerStatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  ConsumerState<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends ConsumerState<VehicleInfoScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestData();
    });
  }

  void _requestData() async {
    setState(() => _isLoading = true);
    ref.read(obdManagerProvider).requestVehicleInfo();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String key, String value, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: "$key: $value"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.infoCopiedSnack(key)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportJson(AppLocalizations l10n) async {
    final vehicleInfo = ref.read(vehicleInfoStateProvider);

    if (vehicleInfo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dbgEmpty)));
      return;
    }

    try {
      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(vehicleInfo);

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/vehicle_info.json');
        await file.writeAsString(jsonString);
        await Share.shareXFiles([
          XFile(file.path),
        ], text: l10n.infoShareSubject);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/vehicle_info.json');
        await file.writeAsString(jsonString);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${l10n.dbgSaved}\n${file.path}"),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dbgExportError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleInfo = ref.watch(vehicleInfoStateProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;
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
                  l10n.infoTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                if (!_isLoading)
                  Row(
                    children: [
                      if (vehicleInfo.isNotEmpty) ...[
                        IconButton.filledTonal(
                          onPressed: () => _exportJson(l10n),
                          icon: const Icon(Icons.download_rounded),
                          color: primaryColor,
                          tooltip: l10n.infoExportTooltip,
                          visualDensity: isLandscape
                              ? VisualDensity.compact
                              : null,
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton.filledTonal(
                        onPressed: _requestData,
                        icon: const Icon(Icons.refresh),
                        color: primaryColor,
                        tooltip: l10n.btnRefresh,
                        visualDensity: isLandscape
                            ? VisualDensity.compact
                            : null,
                      ),
                    ],
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
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            l10n.infoConsulting,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.54),
                            ),
                          ),
                        ],
                      ),
                    )
                  : vehicleInfo.isEmpty
                  ? Center(
                      child: Text(
                        l10n.infoNone,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: vehicleInfo.length,
                      itemBuilder: (context, index) {
                        String key = vehicleInfo.keys.elementAt(index);
                        String value = vehicleInfo[key]!;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              key.contains("VIN") || key.contains("Chassi")
                                  ? Icons.directions_car
                                  : Icons.memory,
                              color: primaryColor,
                            ),
                            title: Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: onSurface,
                                fontFamily: 'Monospace',
                              ),
                            ),
                            subtitle: Text(
                              key,
                              style: TextStyle(color: primaryColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.copy_rounded,
                                color: onSurface.withValues(alpha: 0.54),
                                size: 20,
                              ),
                              tooltip: l10n.btnCopy,
                              onPressed: () =>
                                  _copyToClipboard(key, value, l10n),
                            ),
                            onTap: () => _copyToClipboard(key, value, l10n),
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
}
