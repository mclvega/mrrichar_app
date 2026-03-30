import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/excel_data_source.dart';
import 'package:mrrichar_app/widgets/team_logo_avatar.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
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
          return const Center(child: Text('No se pudieron cargar partidos.'));
        }

        final matches = snapshot.data?.matches ?? const [];
        if (matches.isEmpty) {
          return const Center(child: Text('No hay partidos programados.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final m = matches[index];
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
                  size: 24,
                  imageUrl: m.homePlayerLogoUrl,
                ),
                title: Row(
                  children: [
                    TeamLogoAvatar(
                      size: 18,
                      imageUrl: m.awayPlayerLogoUrl,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${m.homePlayer} vs ${m.awayPlayer}'),
                    ),
                  ],
                ),
                subtitle: timeLabel.isEmpty ? null : Text(timeLabel),
              ),
            );
          },
        );
      },
    );
  }
}

class MatchDetailPage extends StatelessWidget {
  const MatchDetailPage({
    super.key,
    required this.match,
  });

  final MatchInfo match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            TeamLogoAvatar(
              size: 22,
              imageUrl: match.homePlayerLogoUrl,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${match.homePlayer} vs ${match.awayPlayer}')),
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
                  Row(
                    children: [
                      TeamLogoAvatar(
                        size: 20,
                        imageUrl: match.homePlayerLogoUrl,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Equipo local: ${match.homePlayer} (${match.homePlayerCode})')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TeamLogoAvatar(
                        size: 20,
                        imageUrl: match.awayPlayerLogoUrl,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Equipo visitante: ${match.awayPlayer} (${match.awayPlayerCode})')),
                    ],
                  ),
                  if (match.timeWindowLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Horario: ${match.timeWindowLabel}'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
