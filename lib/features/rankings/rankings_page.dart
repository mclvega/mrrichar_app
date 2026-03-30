import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/features/championships/championships_page.dart';
import 'package:mrrichar_app/widgets/team_logo_avatar.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
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
          return const Center(child: Text('No se pudo cargar el ranking.'));
        }

        final data = snapshot.data!;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
                  tabs: const [
                    Tab(child: _OutlinedTabLabel(text: 'Campeonatos')),
                    Tab(child: _OutlinedTabLabel(text: 'Comunidad')),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ChampionshipStatsList(players: data.championshipStatsRankings),
                    _CommunityRankingList(
                      players: data.communityRankings,
                      championshipStats: data.championshipStatsRankings,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChampionshipStatsList extends StatelessWidget {
  const _ChampionshipStatsList({required this.players});

  final List<ChampionshipStatsRanking> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('No hay datos de campeones para calcular ranking.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChampionshipPlayerDetailPage(player: player),
                ),
              );
            },
            leading: CircleAvatar(child: Text('${player.position}')),
            title: Row(
              children: [
                const TeamLogoAvatar(size: 48),
                const SizedBox(width: 8),
                Expanded(child: Text(player.name)),
              ],
            ),
            trailing: Text(
              '${player.points} pts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      },
    );
  }
}

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

class ChampionshipPlayerDetailPage extends StatelessWidget {
  const ChampionshipPlayerDetailPage({
    super.key,
    required this.player,
  });

  final ChampionshipStatsRanking player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            const TeamLogoAvatar(size: 48),
            const SizedBox(width: 8),
            Expanded(child: Text(player.name)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen del Equipo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Posicion: ${player.position}'),
                  Text('Titulos ganados: ${player.titles}'),
                  Text('Puntos por campeonatos: ${player.points}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Historial de Campeonatos Ganados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          ...player.wins.map(
            (win) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () async {
                  final data = await ExcelDataSource.instance.loadData();
                  if (!context.mounted) {
                    return;
                  }

                  ChampionshipInfo? championship;
                  for (final item in data.championships) {
                    if (item.code == win.championshipCode) {
                      championship = item;
                      break;
                    }
                  }

                  if (championship == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se encontro el detalle del campeonato.'),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChampionshipDetailPage(
                        championship: championship!,
                        matches: data.matches,
                        phases: data.championshipPhases,
                        tableEntries: data.championshipTable,
                      ),
                    ),
                  );
                },
                leading: const Icon(Icons.emoji_events),
                title: Text(win.championshipName),
                trailing: Text(
                  '+${win.points} pts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityRankingList extends StatelessWidget {
  const _CommunityRankingList({
    required this.players,
    required this.championshipStats,
  });

  final List<PlayerRanking> players;
  final List<ChampionshipStatsRanking> championshipStats;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('No hay equipos en el ranking de comunidad.'));
    }

    final statsByPlayerCode = {
      for (final stats in championshipStats) stats.playerCode: stats,
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final detailStats = statsByPlayerCode[player.playerCode] ??
            ChampionshipStatsRanking(
              position: player.position,
              playerCode: player.playerCode,
              name: player.name,
              titles: 0,
              points: 0,
              wins: const <ChampionshipWinRecord>[],
            );
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChampionshipPlayerDetailPage(player: detailStats),
                ),
              );
            },
            leading: CircleAvatar(child: Text('${player.position}')),
            title: Row(
              children: [
                const TeamLogoAvatar(size: 48),
                const SizedBox(width: 8),
                Expanded(child: Text(player.name)),
              ],
            ),
            trailing: Text(
              '${player.points} pts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      },
    );
  }
}

class CommunityPlayerDetailPage extends StatelessWidget {
  const CommunityPlayerDetailPage({
    super.key,
    required this.player,
  });

  final PlayerRanking player;

  @override
  Widget build(BuildContext context) {
    return ChampionshipPlayerDetailPage(
      player: ChampionshipStatsRanking(
        position: player.position,
        playerCode: player.playerCode,
        name: player.name,
        titles: 0,
        points: 0,
        wins: const <ChampionshipWinRecord>[],
      ),
    );
  }
}
