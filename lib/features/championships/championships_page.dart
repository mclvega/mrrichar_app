import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/features/matches/matches_page.dart';
import 'package:mrrichar_app/widgets/team_logo_avatar.dart';

const double _statsIndexWidth = 15;
const double _statsTeamWidth = 260;
const double _groupStatsTeamWidth = 180;
const double _statsNumericWidth = 30;
const double _statsRowHeight = 34;
const double _statsMetricsWidth = _statsNumericWidth * 7;

class ChampionshipsPage extends StatefulWidget {
  const ChampionshipsPage({super.key});

  @override
  State<ChampionshipsPage> createState() => _ChampionshipsPageState();
}

class _ChampionshipsPageState extends State<ChampionshipsPage> {
  late final Future<AppTournamentData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = ExcelDataSource.instance.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppTournamentData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('No se pudieron cargar campeonatos.'));
        }

        final data = snapshot.data;
        final championships = data?.championships ?? const [];
        if (championships.isEmpty) {
          return const Center(child: Text('No hay campeonatos disponibles.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: championships.length,
          itemBuilder: (context, index) {
            final item = championships[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChampionshipDetailPage(
                        championship: item,
                        matches: data?.matches ?? const [],
                        phases: data?.championshipPhases ?? const [],
                        tableEntries: data?.championshipTable ?? const [],
                      ),
                    ),
                  );
                },
                title: Text(item.name),
                subtitle: Text('${item.type} | Campeon: ${item.championName} | ${item.championPoints} pts'),
                leading: TeamLogoAvatar(
                  size: 22,
                  imageUrl: item.logoUrl,
                ),
                trailing: Chip(label: Text(item.status)),
              ),
            );
          },
        );
      },
    );
  }
}

class ChampionshipDetailPage extends StatefulWidget {
  const ChampionshipDetailPage({
    super.key,
    required this.championship,
    required this.matches,
    required this.phases,
    required this.tableEntries,
  });

  final ChampionshipInfo championship;
  final List<MatchInfo> matches;
  final List<ChampionshipPhaseInfo> phases;
  final List<ChampionshipTableEntry> tableEntries;

  @override
  State<ChampionshipDetailPage> createState() => _ChampionshipDetailPageState();
}

class _ChampionshipDetailPageState extends State<ChampionshipDetailPage> {
  late _DetailSection _selectedSection;
  String? _selectedGroupPhaseCode;
  String? _selectedEliminationPhaseCode;
  bool _showGeneralTableInGroups = false;

  @override
  void initState() {
    super.initState();
    final phases = _relatedPhases;
    final groupPhases = phases.where(_isGroupPhase).toList(growable: false);
    final eliminationPhases = phases.where((p) => !_isGroupPhase(p)).toList(growable: false);

    _selectedGroupPhaseCode = groupPhases.isNotEmpty ? groupPhases.first.code : null;
    _selectedEliminationPhaseCode = eliminationPhases.isNotEmpty ? eliminationPhases.first.code : null;

    if (groupPhases.isNotEmpty) {
      _selectedSection = _DetailSection.group;
    } else if (eliminationPhases.isNotEmpty) {
      _selectedSection = _DetailSection.elimination;
    } else {
      _selectedSection = _DetailSection.group;
    }
  }

  List<ChampionshipPhaseInfo> get _relatedPhases =>
      widget.phases.where((p) => p.championshipCode == widget.championship.code).toList(growable: false);

  List<ChampionshipTableEntry> get _relatedTable =>
      widget.tableEntries.where((t) => t.championshipCode == widget.championship.code).toList(growable: false);

  List<MatchInfo> get _relatedMatches =>
      widget.matches.where((m) => m.championshipCode == widget.championship.code).toList(growable: false);

  bool _isGroupPhase(ChampionshipPhaseInfo phase) {
    final normalized = phase.type.toLowerCase();
    return normalized.contains('grupo');
  }

  @override
  Widget build(BuildContext context) {
    final relatedPhases = _relatedPhases;
    final groupPhases = relatedPhases.where(_isGroupPhase).toList(growable: false);
    final eliminationPhases = relatedPhases.where((p) => !_isGroupPhase(p)).toList(growable: false);
    final relatedTable = _relatedTable;
    final relatedMatches = _relatedMatches;

    final groupFilteredMatches = _selectedGroupPhaseCode == null
        ? const <MatchInfo>[]
        : relatedMatches.where((m) => m.phaseCode == _selectedGroupPhaseCode).toList(growable: false);

    final eliminationPhaseCodes = eliminationPhases.map((p) => p.code).toSet();
    final eliminationMatches =
        relatedMatches.where((m) => eliminationPhaseCodes.contains(m.phaseCode)).toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(widget.championship.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Codigo: ${widget.championship.code}'),
                  const SizedBox(height: 8),
                  Text('Tipo: ${widget.championship.type}'),
                  const SizedBox(height: 8),
                  Text('Campeon: ${widget.championship.championName} (${widget.championship.championPlayerCode})'),
                  const SizedBox(height: 8),
                  Text('Puntos al campeon: ${widget.championship.championPoints}'),
                  const SizedBox(height: 8),
                  Text('Estado: ${widget.championship.status}'),
                  const SizedBox(height: 8),
                  Text('Detalle: ${widget.championship.details}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DefaultTabController(
            length: 2,
            initialIndex: _selectedSection == _DetailSection.group ? 0 : 1,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                indicator: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onTap: (index) {
                  setState(() {
                    _selectedSection = index == 0
                        ? _DetailSection.group
                        : _DetailSection.elimination;
                  });
                },
                tabs: const [
                  Tab(child: _OutlinedTabLabel(text: 'Grupos')),
                  Tab(child: _OutlinedTabLabel(text: 'Fase Eliminatoria')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_selectedSection == _DetailSection.group)
            _GroupPhaseSection(
              phases: groupPhases,
              selectedPhaseCode: _selectedGroupPhaseCode,
              onPhaseSelected: (code) {
                setState(() {
                  _selectedGroupPhaseCode = code;
                });
              },
              matches: groupFilteredMatches,
              tableEntries: relatedTable,
              showGeneralTable: _showGeneralTableInGroups,
              onShowGeneralTableChanged: (value) {
                setState(() {
                  _showGeneralTableInGroups = value;
                });
              },
            )
          else
            _EliminationBracketSection(
              phases: eliminationPhases,
              matches: eliminationMatches,
              selectedPhaseCode: _selectedEliminationPhaseCode,
              onPhaseSelected: (code) {
                setState(() {
                  _selectedEliminationPhaseCode = code;
                });
              },
            ),
        ],
      ),
    );
  }
}

enum _DetailSection { group, elimination }

class _OutlinedTabLabel extends StatelessWidget {
  const _OutlinedTabLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.center,
      child: Text(text),
    );
  }
}

class _GroupPhaseSection extends StatelessWidget {
  const _GroupPhaseSection({
    required this.phases,
    required this.selectedPhaseCode,
    required this.onPhaseSelected,
    required this.matches,
    required this.tableEntries,
    required this.showGeneralTable,
    required this.onShowGeneralTableChanged,
  });

  final List<ChampionshipPhaseInfo> phases;
  final String? selectedPhaseCode;
  final ValueChanged<String> onPhaseSelected;
  final List<MatchInfo> matches;
  final List<ChampionshipTableEntry> tableEntries;
  final bool showGeneralTable;
  final ValueChanged<bool> onShowGeneralTableChanged;

  @override
  Widget build(BuildContext context) {
    final groupedMatches = <String, List<MatchInfo>>{};

    for (final match in matches) {
      final group = match.groupName.isEmpty ? 'Sin Grupo' : match.groupName;
      groupedMatches.putIfAbsent(group, () => []).add(match);
    }

    final orderedGroups = groupedMatches.keys.toList()..sort();

    int compareBySportsOrder({
      required int pointsA,
      required int wonA,
      required int drawnA,
      required int lostA,
      required String nameA,
      required int pointsB,
      required int wonB,
      required int drawnB,
      required int lostB,
      required String nameB,
    }) {
      final pointsCompare = pointsB.compareTo(pointsA);
      if (pointsCompare != 0) {
        return pointsCompare;
      }

      final winsCompare = wonB.compareTo(wonA);
      if (winsCompare != 0) {
        return winsCompare;
      }

      final drawnCompare = drawnB.compareTo(drawnA);
      if (drawnCompare != 0) {
        return drawnCompare;
      }

      final lostCompare = lostA.compareTo(lostB);
      if (lostCompare != 0) {
        return lostCompare;
      }

      return nameA.compareTo(nameB);
    }

    final sortedGeneralTableEntries = tableEntries.toList()
      ..sort(
        (a, b) => compareBySportsOrder(
          pointsA: a.points,
          wonA: a.won,
          drawnA: a.drawn,
          lostA: a.lost,
          nameA: a.playerName,
          pointsB: b.points,
          wonB: b.won,
          drawnB: b.drawn,
          lostB: b.lost,
          nameB: b.playerName,
        ),
      );

    final selectedPhaseIndex = phases.indexWhere((p) => p.code == selectedPhaseCode);
    final effectivePhaseIndex = selectedPhaseIndex >= 0 ? selectedPhaseIndex : 0;
    final sectionTabs = <Tab>[
      if (phases.isNotEmpty)
        Tab(child: _OutlinedTabLabel(text: phases.first.name)),
      const Tab(child: _OutlinedTabLabel(text: 'Tabla general')),
      ...phases.skip(1).map((phase) => Tab(child: _OutlinedTabLabel(text: phase.name))),
    ];
    final currentTabIndex = phases.isEmpty
        ? 0
        : (showGeneralTable
              ? 1
              : (effectivePhaseIndex == 0 ? 0 : effectivePhaseIndex + 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTabController(
          length: sectionTabs.length,
          initialIndex: currentTabIndex,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              indicator: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              onTap: (index) {
                if (phases.isEmpty) {
                  onShowGeneralTableChanged(true);
                  return;
                }

                if (index == 1) {
                  onShowGeneralTableChanged(true);
                  return;
                }

                onShowGeneralTableChanged(false);
                final phaseIndex = index == 0 ? 0 : index - 1;
                onPhaseSelected(phases[phaseIndex].code);
              },
              tabs: sectionTabs,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (showGeneralTable)
          if (sortedGeneralTableEntries.isEmpty)
            const Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay tabla general cargada para este campeonato.'),
              ),
            )
          else
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tabla General', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _GeneralPinnedNameTable(entries: sortedGeneralTableEntries),
                  ],
                ),
              ),
            )
        else
          if (orderedGroups.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay grupos con partidos para la fase seleccionada.'),
              ),
            )
          else
            ...orderedGroups.map(
              (groupName) {
                final groupMatches = groupedMatches[groupName] ?? const [];
                final teams = <String, String>{};
                for (final m in groupMatches) {
                  teams[m.homePlayerCode] = m.homePlayer;
                  teams[m.awayPlayerCode] = m.awayPlayer;
                }

                final standings = teams.entries
                    .map(
                      (team) {
                        final entry = _buildGroupStats(teamCode: team.key, matches: groupMatches);
                        return _GroupStandingData(
                          teamCode: team.key,
                          teamName: team.value,
                          points: entry.points,
                          played: entry.played,
                          won: entry.won,
                          drawn: entry.drawn,
                          lost: entry.lost,
                          goalsFor: entry.goalsFor,
                          goalsAgainst: entry.goalsAgainst,
                        );
                      },
                    )
                    .toList(growable: false)
                  ..sort(
                    (a, b) => compareBySportsOrder(
                      pointsA: a.points,
                      wonA: a.won,
                      drawnA: a.drawn,
                      lostA: a.lost,
                      nameA: a.teamName,
                      pointsB: b.points,
                      wonB: b.won,
                      drawnB: b.drawn,
                      lostB: b.lost,
                      nameB: b.teamName,
                    ),
                  );

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(groupName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _GroupPinnedNameTable(
                          rows: standings,
                          onTapTeam: (team) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeamMatchesInGroupPage(
                                  teamCode: team.teamCode,
                                  teamName: team.teamName,
                                  groupName: groupName,
                                  matches: groupMatches,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }

  _GroupStandingData _buildGroupStats({
    required String teamCode,
    required List<MatchInfo> matches,
  }) {
    var points = 0;
    var played = 0;
    var won = 0;
    var drawn = 0;
    var lost = 0;
    var goalsFor = 0;
    var goalsAgainst = 0;

    for (final match in matches) {
      final isHome = match.homePlayerCode == teamCode;
      final isAway = match.awayPlayerCode == teamCode;
      if (!isHome && !isAway) {
        continue;
      }

      final homeGoals = match.homeGoals;
      final awayGoals = match.awayGoals;
      if (homeGoals == null || awayGoals == null) {
        continue;
      }

      played += 1;

      final gf = isHome ? homeGoals : awayGoals;
      final ga = isHome ? awayGoals : homeGoals;
      goalsFor += gf;
      goalsAgainst += ga;

      if (gf > ga) {
        won += 1;
        points += 3;
      } else if (gf < ga) {
        lost += 1;
      } else {
        drawn += 1;
        points += 1;
      }
    }

    return _GroupStandingData(
      teamCode: teamCode,
      teamName: '',
      points: points,
      played: played,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
    );
  }
}

class _GroupStandingData {
  const _GroupStandingData({
    required this.teamCode,
    required this.teamName,
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  final String teamCode;
  final String teamName;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
}

class _GroupPinnedNameTable extends StatelessWidget {
  const _GroupPinnedNameTable({
    required this.rows,
    required this.onTapTeam,
  });

  final List<_GroupStandingData> rows;
  final ValueChanged<_GroupStandingData> onTapTeam;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _statsIndexWidth + _groupStatsTeamWidth,
          child: Column(
            children: [
              const SizedBox(
                height: _statsRowHeight,
                child: Row(
                  children: [
                    SizedBox(width: _statsIndexWidth, child: Text('#')),
                    SizedBox(width: _groupStatsTeamWidth, child: Text('Equipo')),
                  ],
                ),
              ),
              const Divider(height: 14),
              ...rows.asMap().entries.map(
                (entry) {
                  final rowIndex = entry.key;
                  final row = entry.value;
                  return InkWell(
                    onTap: () => onTapTeam(row),
                    child: SizedBox(
                      height: _statsRowHeight,
                      child: Row(
                        children: [
                          SizedBox(width: _statsIndexWidth, child: Text('${rowIndex + 1}')),
                          SizedBox(
                            width: _groupStatsTeamWidth,
                            child: Text(
                              '${row.teamName} (${row.teamCode})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _statsMetricsWidth,
              child: Column(
                children: [
                  const SizedBox(
                    height: _statsRowHeight,
                    child: _StatsMetricsHeader(),
                  ),
                  const Divider(height: 14),
                  ...rows.map(
                    (row) => InkWell(
                      onTap: () => onTapTeam(row),
                      child: SizedBox(
                        height: _statsRowHeight,
                        child: _StatsMetricsRow(
                          points: row.points,
                          played: row.played,
                          won: row.won,
                          drawn: row.drawn,
                          lost: row.lost,
                          goalsFor: row.goalsFor,
                          goalsAgainst: row.goalsAgainst,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneralPinnedNameTable extends StatelessWidget {
  const _GeneralPinnedNameTable({required this.entries});

  final List<ChampionshipTableEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _statsIndexWidth + _statsTeamWidth,
          child: Column(
            children: [
              const SizedBox(
                height: _statsRowHeight,
                child: Row(
                  children: [
                    SizedBox(width: _statsIndexWidth, child: Text('#')),
                    SizedBox(width: _statsTeamWidth, child: Text('Equipo')),
                  ],
                ),
              ),
              const Divider(height: 14),
              ...entries.map(
                (entry) => SizedBox(
                  height: _statsRowHeight,
                  child: Row(
                    children: [
                      SizedBox(width: _statsIndexWidth, child: Text('${entry.position}')),
                      SizedBox(
                        width: _statsTeamWidth,
                        child: Text(
                          entry.playerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _statsMetricsWidth,
              child: Column(
                children: [
                  const SizedBox(
                    height: _statsRowHeight,
                    child: _StatsMetricsHeader(),
                  ),
                  const Divider(height: 14),
                  ...entries.map(
                    (entry) => SizedBox(
                      height: _statsRowHeight,
                      child: _StatsMetricsRow(
                        points: entry.points,
                        played: entry.played,
                        won: entry.won,
                        drawn: entry.drawn,
                        lost: entry.lost,
                        goalsFor: entry.goalsFor,
                        goalsAgainst: entry.goalsAgainst,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsMetricsHeader extends StatelessWidget {
  const _StatsMetricsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: _statsNumericWidth, child: Text('PTS', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('PJ', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('G', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('E', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('P', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('GF', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('GC', textAlign: TextAlign.right)),
      ],
    );
  }
}

class _StatsMetricsRow extends StatelessWidget {
  const _StatsMetricsRow({
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: _statsNumericWidth, child: Text('$points', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('$played', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('$won', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('$drawn', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('$lost', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('$goalsFor', textAlign: TextAlign.right)),
        SizedBox(width: _statsNumericWidth, child: Text('$goalsAgainst', textAlign: TextAlign.right)),
      ],
    );
  }
}

class TeamMatchesInGroupPage extends StatelessWidget {
  const TeamMatchesInGroupPage({
    super.key,
    required this.teamCode,
    required this.teamName,
    required this.groupName,
    required this.matches,
  });

  final String teamCode;
  final String teamName;
  final String groupName;
  final List<MatchInfo> matches;

  @override
  Widget build(BuildContext context) {
    final teamMatches = matches
        .where((m) => m.homePlayerCode == teamCode || m.awayPlayerCode == teamCode)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text('$teamName - $groupName')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (teamMatches.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay partidos para este equipo en este grupo.'),
              ),
            )
          else
            ...teamMatches.map(
              (m) {
                final timeLabel = m.timeWindowLabel;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MatchDetailPage(match: m),
                        ),
                      );
                    },
                    leading: TeamLogoAvatar(
                      size: 22,
                      imageUrl: m.homePlayerLogoUrl,
                    ),
                    title: Text('${m.homePlayer} vs ${m.awayPlayer}'),
                    subtitle: timeLabel.isEmpty ? null : Text(timeLabel),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EliminationBracketSection extends StatelessWidget {
  const _EliminationBracketSection({
    required this.phases,
    required this.matches,
    required this.selectedPhaseCode,
    required this.onPhaseSelected,
  });

  final List<ChampionshipPhaseInfo> phases;
  final List<MatchInfo> matches;
  final String? selectedPhaseCode;
  final ValueChanged<String> onPhaseSelected;

  @override
  Widget build(BuildContext context) {
    final orderedPhases = phases.toList()..sort((a, b) => a.order.compareTo(b.order));

    final effectiveSelectedPhaseCode =
        selectedPhaseCode != null && orderedPhases.any((p) => p.code == selectedPhaseCode)
        ? selectedPhaseCode
        : (orderedPhases.isNotEmpty ? orderedPhases.first.code : null);
    final selectedPhaseIndex = effectiveSelectedPhaseCode == null
      ? 0
      : orderedPhases.indexWhere((p) => p.code == effectiveSelectedPhaseCode);
    final effectivePhaseIndex = selectedPhaseIndex >= 0 ? selectedPhaseIndex : 0;

    final phaseName = effectiveSelectedPhaseCode == null
      ? 'Fase'
      : orderedPhases.firstWhere((p) => p.code == effectiveSelectedPhaseCode).name;

    final selectedMatches = effectiveSelectedPhaseCode == null
        ? const <MatchInfo>[]
        : matches.where((m) => m.phaseCode == effectiveSelectedPhaseCode).toList(growable: false);

    final splitIndex = (selectedMatches.length / 2).ceil();
    final firstBlockMatches = selectedMatches.take(splitIndex).toList(growable: false);
    final secondBlockMatches = selectedMatches.skip(splitIndex).toList(growable: false);

    List<Widget> buildMatchesWithVs(
      List<MatchInfo> blockMatches, {
      required int startIndex,
    }) {
      return blockMatches.asMap().entries.expand(
        (entry) {
          final widgets = <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EliminationMatchTile(
                match: entry.value,
                matchLabel: '$phaseName ${startIndex + entry.key + 1}',
              ),
            ),
          ];

          final shouldShowVs = (entry.key + 1).isEven && entry.key != blockMatches.length - 1;
          if (shouldShowVs) {
            widgets.add(
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _DirectRivalVsSeparator(),
              ),
            );
          }

          return widgets;
        },
      ).toList(growable: false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (orderedPhases.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay fases cargadas en esta seccion.'),
            ),
          )
        else ...[
          DefaultTabController(
            length: orderedPhases.length,
            initialIndex: effectivePhaseIndex,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                indicator: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onTap: (index) => onPhaseSelected(orderedPhases[index].code),
                tabs: orderedPhases
                    .map((phase) => Tab(child: _OutlinedTabLabel(text: phase.name)))
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (matches.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay partidos de eliminacion cargados para este campeonato.'),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (selectedMatches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No hay cruces para la fase seleccionada.'),
                      )
                    else ...[
                      ...buildMatchesWithVs(firstBlockMatches, startIndex: 0),
                      if (secondBlockMatches.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _EliminationBlockSeparator(),
                        ),
                      ...buildMatchesWithVs(secondBlockMatches, startIndex: splitIndex),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _EliminationMatchTile extends StatelessWidget {
  const _EliminationMatchTile({
    required this.match,
    required this.matchLabel,
  });

  final MatchInfo match;
  final String matchLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final homeResult = _resolveSideResult(isHome: true);
    final awayResult = _resolveSideResult(isHome: false);

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MatchDetailPage(match: match),
            ),
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  matchLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _resultColor(colorScheme, homeResult),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _EliminationTeamNode(
                          teamName: match.homePlayer,
                          representativeCode: match.homePlayerCode,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _EliminationScoreNode(
                        homeGoals: match.homeGoals,
                        awayGoals: match.awayGoals,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _resultColor(colorScheme, awayResult),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _EliminationTeamNode(
                          teamName: match.awayPlayer,
                          representativeCode: match.awayPlayerCode,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _MatchSideResult _resolveSideResult({required bool isHome}) {
    final homeGoals = match.homeGoals;
    final awayGoals = match.awayGoals;
    if (homeGoals == null || awayGoals == null) {
      return _MatchSideResult.unknown;
    }

    if (homeGoals == awayGoals) {
      return _MatchSideResult.draw;
    }

    final homeWon = homeGoals > awayGoals;
    if (isHome) {
      return homeWon ? _MatchSideResult.win : _MatchSideResult.loss;
    }
    return homeWon ? _MatchSideResult.loss : _MatchSideResult.win;
  }

  Color _resultColor(ColorScheme colorScheme, _MatchSideResult result) {
    switch (result) {
      case _MatchSideResult.win:
        return Colors.green.withValues(alpha: 0.22);
      case _MatchSideResult.draw:
        return Colors.amber.withValues(alpha: 0.28);
      case _MatchSideResult.loss:
        return Colors.red.withValues(alpha: 0.18);
      case _MatchSideResult.unknown:
        return colorScheme.surfaceContainerHighest;
    }
  }
}

enum _MatchSideResult { win, draw, loss, unknown }

class _EliminationScoreNode extends StatelessWidget {
  const _EliminationScoreNode({
    required this.homeGoals,
    required this.awayGoals,
  });

  final int? homeGoals;
  final int? awayGoals;

  @override
  Widget build(BuildContext context) {
    final hasScore = homeGoals != null && awayGoals != null;
    return Text(
      hasScore ? '${homeGoals!} : ${awayGoals!}' : 'VS',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _EliminationTeamNode extends StatelessWidget {
  const _EliminationTeamNode({
    required this.teamName,
    required this.representativeCode,
  });

  final String teamName;
  final String representativeCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: TeamLogoAvatar(size: 46)),
        ),
        const SizedBox(height: 6),
        Text(
          teamName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Jugador: $representativeCode',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _EliminationBlockSeparator extends StatelessWidget {
  const _EliminationBlockSeparator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
      ],
    );
  }
}

class _DirectRivalVsSeparator extends StatelessWidget {
  const _DirectRivalVsSeparator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'VS',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
      ],
    );
  }
}

