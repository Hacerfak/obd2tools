import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/app_localizations.dart';
import '../state/obd_providers.dart';
import '../widgets/admob_banner.dart';
import 'sensors_dashboard_screen.dart';
import 'hud_screen.dart';
import 'connection_screen.dart';
import 'faults_screen.dart';
import 'vehicle_info_screen.dart';
import 'test_results_screen.dart';
import 'settings_screen.dart';
import 'debug_console_screen.dart';
import 'about_screen.dart';
import '../state/technical_data_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _moreTabKey = GlobalKey<NavigatorState>();
  late final List<Widget> _pages;

  bool _isManualDisconnect = false;

  @override
  void initState() {
    super.initState();
    _pages = [
      const SensorsDashboardScreen(),
      const HudScreen(),
      const TestResultsScreen(),
      const FaultsScreen(),
      MoreMenuScreen(navigatorKey: _moreTabKey),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final languageCode = Localizations.localeOf(context).languageCode;
      await ref.read(technicalDataProvider).loadData(languageCode);
    });
  }

  void _onTabTapped(int index) {
    if (index == 4 && _selectedIndex == 4) {
      _moreTabKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _disconnectAndExit() async {
    _isManualDisconnect = true;
    final manager = ref.read(obdManagerProvider);

    manager.reset();
    ref
        .read(connectionStateProvider.notifier)
        .updateState(AppConnectionState.disconnected);

    await manager.connection.disconnect();
  }

  Widget _buildThemeToggle(BuildContext context) {
    final currentTheme = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    String tooltip;

    if (currentTheme == ThemeMode.system) {
      icon = Icons.brightness_auto;
      tooltip = l10n.themeSystemTooltip;
    } else if (currentTheme == ThemeMode.light) {
      icon = Icons.light_mode;
      tooltip = l10n.themeLightTooltip;
    } else {
      icon = Icons.dark_mode;
      tooltip = l10n.themeDarkTooltip;
    }

    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      color: Theme.of(context).iconTheme.color,
      onPressed: () {
        final newTheme = currentTheme == ThemeMode.system
            ? ThemeMode.light
            : currentTheme == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.system;
        ref.read(themeModeProvider.notifier).setTheme(newTheme);
      },
    );
  }

  Widget _buildStatusAndDisconnect(
    AppConnectionState state,
    bool isDesktop,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    Color dotColor = Colors.grey;
    String tooltipText = l10n.statusDisconnected;

    if (state == AppConnectionState.ready) {
      dotColor = Colors.greenAccent;
      tooltipText = l10n.statusConnected;
    } else if (state == AppConnectionState.waitingForEcu) {
      dotColor = Colors.amberAccent;
      tooltipText = l10n.statusHibernating;
    }

    final ledDot = Tooltip(
      message: tooltipText,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dotColor.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );

    final powerButton = IconButton(
      icon: const Icon(Icons.power_settings_new_rounded),
      color: Theme.of(context).iconTheme.color,
      hoverColor: Colors.redAccent.withValues(alpha: 0.2),
      tooltip: l10n.btnDisconnect,
      onPressed: _disconnectAndExit,
    );

    if (isDesktop) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeToggle(context),
          const SizedBox(height: 8),
          ledDot,
          const SizedBox(height: 16),
          powerButton,
          const SizedBox(height: 16),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeToggle(context),
          const SizedBox(width: 8),
          ledDot,
          const SizedBox(width: 16),
          powerButton,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connState = ref.watch(connectionStateProvider);
    final isFullscreen = ref.watch(hudFullscreenProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(connectionStateProvider, (previous, next) {
      if (next == AppConnectionState.disconnected ||
          next == AppConnectionState.waitingForEcu) {
        if (ref.read(hudFullscreenProvider)) {
          ref.read(hudFullscreenProvider.notifier).toggle();
        }

        if (next == AppConnectionState.disconnected) {
          if (!_isManualDisconnect && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errBleDisconnected),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          _isManualDisconnect = false;
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ConnectionScreen(attemptAutoConnect: false),
            ),
            (route) => false,
          );
        }
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 600;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop && !isFullscreen)
                  Container(
                    width: 85,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: LayoutBuilder(
                      builder: (context, railConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: railConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: NavigationRail(
                                      selectedIndex: _selectedIndex,
                                      onDestinationSelected: _onTabTapped,
                                      labelType: NavigationRailLabelType.all,
                                      backgroundColor: Colors.transparent,
                                      destinations: [
                                        NavigationRailDestination(
                                          icon: const Icon(Icons.grid_view),
                                          label: Text(l10n.tabSensors),
                                        ),
                                        NavigationRailDestination(
                                          icon: const Icon(Icons.speed),
                                          label: Text(l10n.tabHud),
                                        ),
                                        NavigationRailDestination(
                                          icon: const Icon(
                                            Icons.fact_check_outlined,
                                          ),
                                          label: Text(l10n.tabTests),
                                        ),
                                        NavigationRailDestination(
                                          icon: const Icon(Icons.warning_amber),
                                          label: Text(l10n.tabFaults),
                                        ),
                                        NavigationRailDestination(
                                          icon: const Icon(Icons.menu),
                                          label: Text(l10n.tabMore),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusAndDisconnect(
                                    connState,
                                    true,
                                    context,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (!isDesktop && !isFullscreen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.appTitle,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              _buildStatusAndDisconnect(
                                connState,
                                false,
                                context,
                              ),
                            ],
                          ),
                        ),
                      Expanded(child: _pages[_selectedIndex]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // BANNER FIXO PERMANENTE (Visível em modo normal e em Tela Cheia)
              const AdMobBanner(),
              if (!isDesktop && !isFullscreen)
                NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onTabTapped,
                  backgroundColor: Theme.of(
                    context,
                  ).appBarTheme.backgroundColor,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view),
                      label: l10n.tabSensors,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.speed),
                      label: l10n.tabHud,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.fact_check_outlined),
                      label: l10n.tabTests,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.warning_amber),
                      label: l10n.tabFaults,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.menu),
                      label: l10n.tabMore,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class MoreMenuScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MoreMenuScreen({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MoreMenuListView(),
        );
      },
    );
  }
}

class MoreMenuListView extends StatelessWidget {
  const MoreMenuListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreMenuTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              l10n.moreDiagSection,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: Text(l10n.infoTitle),
            subtitle: Text(l10n.moreInfoDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VehicleInfoScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.terminal),
            title: Text(l10n.dbgTitle),
            subtitle: Text(l10n.moreTerminalDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DebugConsoleScreen(),
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              l10n.moreAppSection,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.moreSettings),
            subtitle: Text(l10n.moreSettingsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
