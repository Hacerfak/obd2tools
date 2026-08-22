import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final appColors = ref.watch(appColorsProvider).current(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // REMOVE O BOTÃO DE VOLTAR
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.aboutTitle,
          style: TextStyle(fontSize: 18, color: onSurface),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // HEADER (Logo e Versão Dinâmica)
              Icon(
                Icons.directions_car_filled,
                size: 80,
                color: appColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "OBD2 Tools",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: onSurface,
                ),
              ),

              // MÁGICA DA VERSÃO DINÂMICA
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? snapshot.data!.version
                      : "...";
                  return Text(
                    "${l10n.aboutVersion} $version",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // SOBRE O PROJETO
              Text(
                l10n.aboutTheProjectTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.aboutTheProjectDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // DESENVOLVEDOR
              Text(
                l10n.aboutDeveloperTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: onSurface.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: appColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: appColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        backgroundImage: const AssetImage(
                          'assets/images/eu.jpg',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Eder Gross Cichelero",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.aboutDeveloperRole,
                              style: TextStyle(
                                fontSize: 12,
                                color: appColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.aboutDeveloperDesc,
                              style: TextStyle(
                                fontSize: 13,
                                color: onSurface.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
