import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/data/local_settings_db.dart';
import 'package:mrrichar_app/widgets/team_logo_avatar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initialDefaultPlayerCode,
  });

  final String? initialDefaultPlayerCode;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final Future<AppTournamentData> _dataFuture;
  String? _selectedPlayerCode;

  @override
  void initState() {
    super.initState();
    _dataFuture = ExcelDataSource.instance.loadData();
    _selectedPlayerCode = widget.initialDefaultPlayerCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Configuracion'),
      ),
      body: FutureBuilder<AppTournamentData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('No se pudieron cargar los jugadores.'),
            );
          }

          final players = _buildPlayerList(snapshot.data!);
          if (players.isEmpty) {
            return const Center(child: Text('No hay jugadores disponibles.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            itemCount: players.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Text(
                      'Selecciona un jugador por defecto',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                  ),
                );
              }

              final player = players[index - 1];
              final isSelected = player.code == _selectedPlayerCode;
              final cardColor = isSelected ? Theme.of(context).colorScheme.primary : Colors.white;
              final textColor = isSelected ? Colors.white : Colors.black;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.white54
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: ListTile(
                  onTap: () => _selectPlayer(player.code),
                  leading: TeamLogoAvatar(
                    size: 30,
                    imageUrl: player.logoUrl,
                  ),
                  title: Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectPlayer(String code) async {
    await LocalSettingsDb.instance.setDefaultPlayerCode(code);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedPlayerCode = code;
    });
    Navigator.of(context).pop<String?>(code);
  }

  List<_PlayerOption> _buildPlayerList(AppTournamentData data) {
    final byCode = <String, _PlayerOption>{};

    for (final p in data.communityRankings) {
      byCode[p.playerCode] = _PlayerOption(
        code: p.playerCode,
        name: p.name,
        logoUrl: byCode[p.playerCode]?.logoUrl,
      );
    }

    for (final p in data.championshipStatsRankings) {
      byCode[p.playerCode] = _PlayerOption(
        code: p.playerCode,
        name: p.name,
        logoUrl: byCode[p.playerCode]?.logoUrl,
      );
    }

    for (final m in data.matches) {
      byCode.putIfAbsent(
        m.homePlayerCode,
        () => _PlayerOption(
          code: m.homePlayerCode,
          name: m.homePlayer,
          logoUrl: m.homePlayerLogoUrl,
        ),
      );
      byCode.putIfAbsent(
        m.awayPlayerCode,
        () => _PlayerOption(
          code: m.awayPlayerCode,
          name: m.awayPlayer,
          logoUrl: m.awayPlayerLogoUrl,
        ),
      );
    }

    final players = byCode.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return players;
  }
}

class _PlayerOption {
  const _PlayerOption({
    required this.code,
    required this.name,
    this.logoUrl,
  });

  final String code;
  final String name;
  final String? logoUrl;
}
