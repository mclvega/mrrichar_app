import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mrrichar_app/app_theme.dart';
import 'package:mrrichar_app/data/app_image_cache.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/data/local_settings_db.dart';
import 'package:mrrichar_app/features/championships/championships_page.dart';
import 'package:mrrichar_app/features/dashboard/dashboard_page.dart';
import 'package:mrrichar_app/features/rankings/rankings_page.dart';
import 'package:mrrichar_app/features/settings/settings_page.dart';

void main() {
  runApp(const VirtualFootballApp());
}

class VirtualFootballApp extends StatelessWidget {
  const VirtualFootballApp({super.key});

  Future<_AppBootstrapResult> _bootstrapApp() async {
    await AppImageCache.instance.initialize();

    // Load local data first for faster startup, then refresh from cloud in background.
    unawaited(
      ExcelDataSource.instance.syncFromCloud().then((_) {
        unawaited(ExcelDataSource.instance.loadData());
      }),
    );

    await ExcelDataSource.instance.loadData();
    final defaultCode = await LocalSettingsDb.instance.getDefaultPlayerCode();
    return _AppBootstrapResult(defaultPlayerCode: defaultCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MRRICHAR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
            backgroundColor: Colors.transparent,
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
            backgroundColor: Colors.transparent,
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

                                  unawaited(
                                    ExcelDataSource.instance.syncFromCloud().then((_) {
                                      unawaited(ExcelDataSource.instance.loadData());
                                    }),
                                  );

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
  bool _isRefreshingData = false;
  int _dataReloadToken = 0;

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

  Future<void> _refreshData() async {
    if (_isRefreshingData) {
      return;
    }

    setState(() {
      _isRefreshingData = true;
    });

    try {
      await ExcelDataSource.instance.syncFromCloud();
      await ExcelDataSource.instance.loadData();

      if (!mounted) {
        return;
      }

      setState(() {
        _dataReloadToken += 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados.')),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRefreshingData = false;
      });
    }
  }

  static const _titles = [
    'Inicio',
    'Ranking',
    'Campeonatos',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        key: ValueKey('dashboard-$_dataReloadToken'),
        defaultPlayerCode: _defaultPlayerCode,
        isLoadingDefaultPlayer: _isLoadingDefaultPlayer,
        onOpenSettings: _openSettings,
      ),
      RankingsPage(key: ValueKey('rankings-$_dataReloadToken')),
      ChampionshipsPage(key: ValueKey('championships-$_dataReloadToken')),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _isRefreshingData ? null : _refreshData,
                  icon: _isRefreshingData
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  tooltip: 'Descargar y recargar datos',
                ),
                IconButton(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings),
                  tooltip: 'Configuracion',
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          pages[_selectedIndex],
          if (_isRefreshingData)
            Positioned.fill(
              child: ColoredBox(
                color: AppTheme.primaryColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTheme.buildAppLogo(
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Recargando datos...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (_isRefreshingData) {
            return;
          }
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
        ],
      ),
    );
  }
}
