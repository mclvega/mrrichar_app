import 'package:flutter/material.dart';
import 'package:mrrichar_app/app_theme.dart';
import 'package:mrrichar_app/data/app_image_cache.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/data/local_settings_db.dart';
import 'package:mrrichar_app/features/championships/championships_page.dart';
import 'package:mrrichar_app/features/dashboard/dashboard_page.dart';
import 'package:mrrichar_app/features/matches/matches_page.dart';
import 'package:mrrichar_app/features/rankings/rankings_page.dart';
import 'package:mrrichar_app/features/settings/settings_page.dart';

void main() {
  runApp(const VirtualFootballApp());
}

class VirtualFootballApp extends StatelessWidget {
  const VirtualFootballApp({super.key});

  Future<_AppBootstrapResult> _bootstrapApp() async {
    await AppImageCache.instance.initialize();
    await ExcelDataSource.instance.syncFromCloud();
    await ExcelDataSource.instance.loadData();
    final defaultCode = await LocalSettingsDb.instance.getDefaultPlayerCode();
    return _AppBootstrapResult(defaultPlayerCode: defaultCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Campeonatos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: Colors.transparent),
      builder: (context, child) {
        return DecoratedBox(
          decoration: AppTheme.backgroundDecoration,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: StartupLoadingPage(
        bootstrapFuture: _bootstrapApp(),
      ),
    );
  }
}

class StartupLoadingPage extends StatelessWidget {
  const StartupLoadingPage({
    super.key,
    required this.bootstrapFuture,
  });

  final Future<_AppBootstrapResult> bootstrapFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppBootstrapResult>(
      future: bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: Center(
              child: AppTheme.buildAppLogo(
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 56),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudo completar la carga inicial.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => StartupLoadingPage(
                              bootstrapFuture: Future<_AppBootstrapResult>.microtask(
                                () async {
                                  await AppImageCache.instance.initialize();
                                  await ExcelDataSource.instance.syncFromCloud();
                                  await ExcelDataSource.instance.loadData();
                                  final defaultCode = await LocalSettingsDb.instance
                                      .getDefaultPlayerCode();
                                  return _AppBootstrapResult(
                                    defaultPlayerCode: defaultCode,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return HomePage(initialDefaultPlayerCode: snapshot.data!.defaultPlayerCode);
      },
    );
  }
}

class _AppBootstrapResult {
  const _AppBootstrapResult({required this.defaultPlayerCode});

  final String? defaultPlayerCode;
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialDefaultPlayerCode,
  });

  final String? initialDefaultPlayerCode;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _defaultPlayerCode;
  bool _isLoadingDefaultPlayer = false;

  @override
  void initState() {
    super.initState();
    _defaultPlayerCode = widget.initialDefaultPlayerCode;
  }

  Future<void> _openSettings() async {
    final selected = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (context) {
          return SettingsPage(
            initialDefaultPlayerCode: _defaultPlayerCode,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _defaultPlayerCode = selected;
    });
  }

  static const _titles = [
    'Inicio',
    'Ranking',
    'Campeonatos',
    'Partidos',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        defaultPlayerCode: _defaultPlayerCode,
        isLoadingDefaultPlayer: _isLoadingDefaultPlayer,
        onOpenSettings: _openSettings,
      ),
      const RankingsPage(),
      const ChampionshipsPage(),
      const MatchesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Configuracion',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Campeonatos',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
        ],
      ),
    );
  }
}
