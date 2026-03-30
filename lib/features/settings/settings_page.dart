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
  String _query = '';

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

          final filteredPlayers = players
              .where(
                (p) => p.name.toLowerCase().contains(_query) || p.code.toLowerCase().contains(_query),
              )
              .toList(growable: false);

          final selectedPlayer = _selectedPlayerCode == null
              ? null
              : players
                  .where((p) => p.code == _selectedPlayerCode)
                  .cast<_PlayerOption?>()
                  .firstOrNull;

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedPlayer == null
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          color: selectedPlayer == null ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Jugador por defecto',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selectedPlayer == null ? Colors.black : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearSelection,
                          child: Text(
                            'Limpiar',
                            style: TextStyle(
                              color: selectedPlayer == null ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedPlayer == null
                          ? 'No seleccionado'
                          : selectedPlayer.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selectedPlayer == null ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona un jugador para mostrar sus estadisticas en Inicio.',
                      style: TextStyle(
                        color: selectedPlayer == null ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _query = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar jugador por nombre o codigo',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _selectPlayer(player.code),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const TeamLogoAvatar(size: 30),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Jugador',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _InfoChip(
                                          label: 'Torneo',
                                          value: player.tournamentRank != null
                                              ? '#${player.tournamentRank}'
                                              : '-',
                                          selected: isSelected,
                                        ),
                                        _InfoChip(
                                          label: 'Comunidad',
                                          value: player.communityRank != null
                                              ? '#${player.communityRank}'
                                              : '-',
                                          selected: isSelected,
                                        ),
                                        _InfoChip(
                                          label: 'Titulos',
                                          value: '${player.titles}',
                                          selected: isSelected,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.white : Colors.grey,
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

  Future<void> _clearSelection() async {
    await LocalSettingsDb.instance.setDefaultPlayerCode(null);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedPlayerCode = null;
    });
    Navigator.of(context).pop<String?>(null);
  }

  List<_PlayerOption> _buildPlayerList(AppTournamentData data) {
    final communityByCode = {
      for (final p in data.communityRankings) p.playerCode: p,
    };
    final tournamentByCode = {
      for (final p in data.championshipStatsRankings) p.playerCode: p,
    };

    final byCode = <String, _PlayerOption>{};

    for (final p in data.communityRankings) {
      byCode[p.playerCode] = _PlayerOption(
        code: p.playerCode,
        name: p.name,
        communityRank: p.position,
        tournamentRank: tournamentByCode[p.playerCode]?.position,
        titles: tournamentByCode[p.playerCode]?.titles ?? 0,
      );
    }

    for (final p in data.championshipStatsRankings) {
      byCode[p.playerCode] = _PlayerOption(
        code: p.playerCode,
        name: p.name,
        communityRank: communityByCode[p.playerCode]?.position,
        tournamentRank: p.position,
        titles: p.titles,
      );
    }

    for (final m in data.matches) {
      byCode.putIfAbsent(
        m.homePlayerCode,
        () => _PlayerOption(
          code: m.homePlayerCode,
          name: m.homePlayer,
          communityRank: communityByCode[m.homePlayerCode]?.position,
          tournamentRank: tournamentByCode[m.homePlayerCode]?.position,
          titles: tournamentByCode[m.homePlayerCode]?.titles ?? 0,
        ),
      );
      byCode.putIfAbsent(
        m.awayPlayerCode,
        () => _PlayerOption(
          code: m.awayPlayerCode,
          name: m.awayPlayer,
          communityRank: communityByCode[m.awayPlayerCode]?.position,
          tournamentRank: tournamentByCode[m.awayPlayerCode]?.position,
          titles: tournamentByCode[m.awayPlayerCode]?.titles ?? 0,
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
    required this.communityRank,
    required this.tournamentRank,
    required this.titles,
  });

  final String code;
  final String name;
  final int? communityRank;
  final int? tournamentRank;
  final int titles;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final String value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? Colors.white24 : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
