import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/widgets/team_logo_avatar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.defaultPlayerCode,
    required this.isLoadingDefaultPlayer,
    required this.onOpenSettings,
  });

  final String? defaultPlayerCode;
  final bool isLoadingDefaultPlayer;
  final VoidCallback onOpenSettings;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Future<AppTournamentData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = ExcelDataSource.instance.loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingDefaultPlayer) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<AppTournamentData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('No se pudo cargar el resumen.'));
        }

        final data = snapshot.data!;
        final selectedCode = widget.defaultPlayerCode;

        if (selectedCode == null || selectedCode.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_search, size: 52),
                  const SizedBox(height: 10),
                  Text(
                    'No hay jugador por defecto seleccionado.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona un jugador desde el boton Config de arriba o usa el acceso rapido aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: widget.onOpenSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Acceso rapido a Configuracion'),
                  ),
                ],
              ),
            ),
          );
        }

        final community = data.communityRankings
            .where((p) => p.playerCode == selectedCode)
            .cast<PlayerRanking?>()
            .firstOrNull;
        final tournament = data.championshipStatsRankings
            .where((p) => p.playerCode == selectedCode)
            .cast<ChampionshipStatsRanking?>()
            .firstOrNull;

        final selectedName = community?.name ?? tournament?.name ?? selectedCode;
        final playerMatches = data.matches
            .where((m) => m.homePlayerCode == selectedCode || m.awayPlayerCode == selectedCode)
            .toList(growable: false);
        final nextMatch = playerMatches.isEmpty ? null : playerMatches.first;

        final wonCups = data.championships
            .where((c) => c.championPlayerCode == selectedCode)
            .toList(growable: false);

        final activeCups = data.championships.where((c) {
          final status = c.status.toLowerCase();
          return status.contains('activo') || status.contains('curso');
        }).length;

        final cards = [
          _DashboardCardData(
            title: 'Jugador por defecto',
            value: selectedName,
            subtitle: 'Perfil seleccionado',
            icon: Icons.person,
          ),
          _DashboardCardData(
            title: 'Ranking Torneo',
            value: tournament != null ? '#${tournament.position}' : '-',
            subtitle: tournament != null
                ? 'Titulos: ${tournament.titles} | Puntos: ${tournament.points}'
                : 'Sin datos en ranking de torneo',
            icon: Icons.emoji_events,
          ),
          _DashboardCardData(
            title: 'Ranking Comunidad',
            value: community != null ? '#${community.position}' : '-',
            subtitle:
                community != null ? 'Puntos: ${community.points}' : 'Sin datos en comunidad',
            icon: Icons.groups,
          ),
          _DashboardCardData(
            title: 'Copas activas',
            value: '$activeCups',
            subtitle: 'Torneos actualmente en curso',
            icon: Icons.sports_score,
          ),
          _DashboardCardData(
            title: 'Copas ganadas',
            value: '${wonCups.length}',
            subtitle: wonCups.isEmpty
                ? 'Aun no registra titulos'
                : wonCups.take(2).map((c) => c.name).join(' | '),
            icon: Icons.workspace_premium,
          ),
          _DashboardCardData(
            title: 'Proximo Partido',
            value: nextMatch != null
                ? '${nextMatch.homePlayer} vs ${nextMatch.awayPlayer}'
                : '-',
            subtitle: nextMatch?.schedule ?? 'Sin partidos para este jugador',
            icon: Icons.sports_soccer,
          ),
        ];

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = cards[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    item.icon,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: SizedBox(
                  width: 170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (item.title == 'Top Equipo' || item.title == 'Proximo Partido') ...[
                        const TeamLogoAvatar(size: 20),
                        const SizedBox(width: 6),
                      ] else if (item.title == 'Jugador por defecto') ...[
                        const TeamLogoAvatar(size: 20),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          item.value,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardCardData {
  const _DashboardCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
}
