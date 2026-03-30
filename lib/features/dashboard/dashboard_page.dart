import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/features/rankings/rankings_page.dart';
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
        final selectedName = _resolveSelectedName(data, selectedCode);
        final selectedLogoUrl = _resolveSelectedLogoUrl(data, selectedCode);
        final hasSelectedPlayer = selectedCode != null && selectedCode.isNotEmpty;
        final playerTournaments = _countPlayerTournaments(data, selectedCode);
        final wonTournaments = _countWonTournaments(data, selectedCode);
        final activeTournaments = _activeTournaments(data);
        final upcomingMatches = _upcomingMatches(data, selectedCode);
        final championshipNamesByCode = {
          for (final c in data.championships) c.code: c.name,
        };

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openSelectedPlayerDetail(data, selectedCode),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TeamLogoAvatar(
                            size: 120,
                            imageUrl: selectedLogoUrl,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            selectedName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (!hasSelectedPlayer) ...[
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: widget.onOpenSettings,
                              icon: const Icon(Icons.settings),
                              label: const Text('Ir a Configuracion'),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _IndicatorChip(
                                label: 'Torneos jugador',
                                value: '$playerTournaments',
                              ),
                              const SizedBox(width: 8),
                              _IndicatorChip(
                                label: 'Ganados',
                                value: '$wonTournaments',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Torneos activos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        if (activeTournaments.isEmpty)
                          const Text('No hay torneos activos.')
                        else
                          ...activeTournaments.map(
                            (item) => _ListInfoRow(
                              title: item.name,
                              subtitle: item.status,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proximas fechas por jugar',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        if (selectedCode == null || selectedCode.isEmpty)
                          const Text('Selecciona un jugador desde Configuracion.')
                        else if (upcomingMatches.isEmpty)
                          const Text('No hay partidos pendientes para este jugador.')
                        else
                          ...upcomingMatches.map((match) {
                            final tournamentName =
                                championshipNamesByCode[match.championshipCode] ??
                                    match.championshipCode;
                            final timeLabel = match.timeWindowLabel;
                            final subtitle = timeLabel.isEmpty
                                ? tournamentName
                                : '$tournamentName | $timeLabel';
                            return _ListInfoRow(
                              title: '${match.homePlayer} vs ${match.awayPlayer}',
                              subtitle: subtitle,
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _resolveSelectedName(AppTournamentData data, String? selectedCode) {
    if (selectedCode == null || selectedCode.isEmpty) {
      return 'Sin jugador seleccionado';
    }

    final community = data.communityRankings
        .where((p) => p.playerCode == selectedCode)
        .cast<PlayerRanking?>()
        .firstOrNull;
    final tournament = data.championshipStatsRankings
        .where((p) => p.playerCode == selectedCode)
        .cast<ChampionshipStatsRanking?>()
        .firstOrNull;

    return community?.name ?? tournament?.name ?? selectedCode;
  }

  String? _resolveSelectedLogoUrl(AppTournamentData data, String? selectedCode) {
    if (selectedCode == null || selectedCode.isEmpty) {
      return null;
    }

    for (final match in data.matches) {
      if (match.homePlayerCode == selectedCode &&
          match.homePlayerLogoUrl != null &&
          match.homePlayerLogoUrl!.trim().isNotEmpty) {
        return match.homePlayerLogoUrl;
      }
      if (match.awayPlayerCode == selectedCode &&
          match.awayPlayerLogoUrl != null &&
          match.awayPlayerLogoUrl!.trim().isNotEmpty) {
        return match.awayPlayerLogoUrl;
      }
    }

    return null;
  }

  int _countPlayerTournaments(AppTournamentData data, String? selectedCode) {
    if (selectedCode == null || selectedCode.isEmpty) {
      return 0;
    }

    final championshipCodes = data.matches
        .where((m) => m.homePlayerCode == selectedCode || m.awayPlayerCode == selectedCode)
        .map((m) => m.championshipCode)
        .toSet();

    return championshipCodes.length;
  }

  int _countWonTournaments(AppTournamentData data, String? selectedCode) {
    if (selectedCode == null || selectedCode.isEmpty) {
      return 0;
    }

    return data.championships.where((c) => c.championPlayerCode == selectedCode).length;
  }

  List<ChampionshipInfo> _activeTournaments(AppTournamentData data) {
    return data.championships.where((c) {
      final status = c.status.toLowerCase();
      return status.contains('activo') || status.contains('curso');
    }).toList(growable: false);
  }

  List<MatchInfo> _upcomingMatches(AppTournamentData data, String? selectedCode) {
    if (selectedCode == null || selectedCode.isEmpty) {
      return const [];
    }

    return data.matches
        .where(
          (m) =>
              (m.homePlayerCode == selectedCode || m.awayPlayerCode == selectedCode) &&
              m.homeGoals == null &&
              m.awayGoals == null,
        )
        .take(6)
        .toList(growable: false);
  }

  void _openSelectedPlayerDetail(AppTournamentData data, String? selectedCode) {
    if (selectedCode == null || selectedCode.isEmpty) {
      widget.onOpenSettings();
      return;
    }

    ChampionshipStatsRanking? tournamentPlayer;
    for (final player in data.championshipStatsRankings) {
      if (player.playerCode == selectedCode) {
        tournamentPlayer = player;
        break;
      }
    }

    if (tournamentPlayer != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChampionshipPlayerDetailPage(player: tournamentPlayer!),
        ),
      );
      return;
    }

    PlayerRanking? communityPlayer;
    for (final player in data.communityRankings) {
      if (player.playerCode == selectedCode) {
        communityPlayer = player;
        break;
      }
    }

    if (communityPlayer != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CommunityPlayerDetailPage(player: communityPlayer!),
        ),
      );
      return;
    }

    widget.onOpenSettings();
  }
}

class _IndicatorChip extends StatelessWidget {
  const _IndicatorChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ListInfoRow extends StatelessWidget {
  const _ListInfoRow({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
