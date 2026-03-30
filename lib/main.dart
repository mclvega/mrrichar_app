import 'package:flutter/material.dart';
import 'package:mrrichar_app/app_theme.dart';
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _defaultPlayerCode;
  bool _isLoadingDefaultPlayer = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultPlayer();
  }

  Future<void> _loadDefaultPlayer() async {
    final savedCode = await LocalSettingsDb.instance.getDefaultPlayerCode();
    if (!mounted) {
      return;
    }
    setState(() {
      _defaultPlayerCode = savedCode;
      _isLoadingDefaultPlayer = false;
    });
  }

  Future<void> _openSettings() async {
    final selected = await Navigator.of(context).push<String?>(
      PageRouteBuilder<String?>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SettingsPage(
            initialDefaultPlayerCode: _defaultPlayerCode,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
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
