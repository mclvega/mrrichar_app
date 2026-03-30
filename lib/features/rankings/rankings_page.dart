import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
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
              const TabBar(
                tabs: [
                  Tab(text: 'Campeonatos'),
                  Tab(text: 'Comunidad'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ChampionshipStatsList(players: data.championshipStatsRankings),
                    _CommunityRankingList(players: data.communityRankings),
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
        final championshipsPreview = player.wins
            .take(2)
            .map((w) => w.championshipName)
            .join(' | ');
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
                const TeamLogoAvatar(size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(player.name)),
              ],
            ),
            subtitle: Text(
              'Titulos: ${player.titles}\n$championshipsPreview',
            ),
            isThreeLine: true,
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

class ChampionshipPlayerDetailPage extends StatelessWidget {
  const ChampionshipPlayerDetailPage({
    super.key,
    required this.player,
  });

  final ChampionshipStatsRanking player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const TeamLogoAvatar(size: 22),
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...player.wins.map(
            (win) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
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
  const _CommunityRankingList({required this.players});

  final List<PlayerRanking> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('No hay equipos en el ranking de comunidad.'));
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
                  builder: (_) => CommunityPlayerDetailPage(player: player),
                ),
              );
            },
            leading: CircleAvatar(child: Text('${player.position}')),
            title: Row(
              children: [
                const TeamLogoAvatar(size: 20),
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const TeamLogoAvatar(size: 22),
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
                  Text('Codigo: ${player.playerCode}'),
                  const SizedBox(height: 8),
                  Text('Posicion en comunidad: ${player.position}'),
                  const SizedBox(height: 8),
                  Text('Puntos de comunidad: ${player.points}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
