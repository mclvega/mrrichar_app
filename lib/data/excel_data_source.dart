import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

class PlayerInfo {
  const PlayerInfo({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;
}

class PlayerRanking {
  const PlayerRanking({
    required this.position,
    required this.playerCode,
    required this.name,
    required this.points,
  });

  final int position;
  final String playerCode;
  final String name;
  final int points;
}

class ChampionshipStatsRanking {
  const ChampionshipStatsRanking({
    required this.position,
    required this.playerCode,
    required this.name,
    required this.titles,
    required this.points,
    required this.wins,
  });

  final int position;
  final String playerCode;
  final String name;
  final int titles;
  final int points;
  final List<ChampionshipWinRecord> wins;
}

class ChampionshipWinRecord {
  const ChampionshipWinRecord({
    required this.championshipCode,
    required this.championshipName,
    required this.points,
  });

  final String championshipCode;
  final String championshipName;
  final int points;
}

class ChampionshipInfo {
  const ChampionshipInfo({
    required this.code,
    required this.name,
    required this.type,
    required this.championPlayerCode,
    required this.championName,
    required this.championPoints,
    required this.status,
    required this.details,
  });

  final String code;
  final String name;
  final String type;
  final String championPlayerCode;
  final String championName;
  final int championPoints;
  final String status;
  final String details;
}

class ChampionshipPhaseInfo {
  const ChampionshipPhaseInfo({
    required this.code,
    required this.championshipCode,
    required this.name,
    required this.type,
    required this.order,
  });

  final String code;
  final String championshipCode;
  final String name;
  final String type;
  final int order;
}

class ChampionshipTableEntry {
  const ChampionshipTableEntry({
    required this.championshipCode,
    required this.playerCode,
    required this.playerName,
    required this.position,
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  final String championshipCode;
  final String playerCode;
  final String playerName;
  final int position;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
}

class MatchInfo {
  const MatchInfo({
    required this.championshipCode,
    required this.phaseCode,
    required this.groupName,
    required this.homePlayerCode,
    required this.homePlayer,
    required this.awayPlayerCode,
    required this.awayPlayer,
    required this.schedule,
    required this.homeGoals,
    required this.awayGoals,
  });

  final String championshipCode;
  final String phaseCode;
  final String groupName;
  final String homePlayerCode;
  final String homePlayer;
  final String awayPlayerCode;
  final String awayPlayer;
  final String schedule;
  final int? homeGoals;
  final int? awayGoals;
}

class AppTournamentData {
  const AppTournamentData({
    required this.communityRankings,
    required this.championshipStatsRankings,
    required this.championships,
    required this.championshipPhases,
    required this.championshipTable,
    required this.matches,
  });

  final List<PlayerRanking> communityRankings;
  final List<ChampionshipStatsRanking> championshipStatsRankings;
  final List<ChampionshipInfo> championships;
  final List<ChampionshipPhaseInfo> championshipPhases;
  final List<ChampionshipTableEntry> championshipTable;
  final List<MatchInfo> matches;
}

class ExcelDataSource {
  ExcelDataSource._();

  static final ExcelDataSource instance = ExcelDataSource._();
  static const String _assetPath = 'assets/data/virtual_football_data.xlsx';

  Future<AppTournamentData>? _cachedLoad;

  Future<AppTournamentData> loadData() {
    _cachedLoad ??= _loadFromAsset();
    return _cachedLoad!;
  }

  Future<AppTournamentData> _loadFromAsset() async {
    final bytes = await rootBundle.load(_assetPath);
    final buffer = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    final excel = Excel.decodeBytes(buffer);

    final playersByCode = _parsePlayers(excel.tables['Players']);
    final championships = _parseChampionships(excel.tables['Championships'], playersByCode);
    final championshipsByCode = {
      for (final championship in championships) championship.code: championship,
    };

    return AppTournamentData(
      communityRankings: _parseCommunityRankings(
        excel.tables['CommunityRanking'],
        playersByCode,
      ),
      championshipStatsRankings: _buildChampionshipStatsRankings(
        championships,
        playersByCode,
        championshipsByCode,
      ),
      championships: championships,
      championshipPhases: _parseChampionshipPhases(excel.tables['ChampionshipPhases']),
      championshipTable: _parseChampionshipTable(
        excel.tables['ChampionshipTable'],
        playersByCode,
      ),
      matches: _parseMatches(excel.tables['Matches'], playersByCode),
    );
  }

  Map<String, PlayerInfo> _parsePlayers(Sheet? sheet) {
    if (sheet == null) {
      return const {};
    }

    final players = <String, PlayerInfo>{};
    for (final row in sheet.rows.skip(1)) {
      final code = _readCell(row, 0);
      final name = _readCell(row, 1);

      if (code.isEmpty || name.isEmpty) {
        continue;
      }

      players[code] = PlayerInfo(code: code, name: name);
    }

    return players;
  }

  List<PlayerRanking> _parseCommunityRankings(
    Sheet? sheet,
    Map<String, PlayerInfo> playersByCode,
  ) {
    if (sheet == null) {
      return const [];
    }

    final rows = <PlayerRanking>[];
    for (final row in sheet.rows.skip(1)) {
      final position = int.tryParse(_readCell(row, 0));
      final playerCode = _readCell(row, 1);
      final points = int.tryParse(_readCell(row, 2));
      final playerName = playersByCode[playerCode]?.name ?? playerCode;

      if (position == null || playerCode.isEmpty || points == null) {
        continue;
      }

      rows.add(
        PlayerRanking(
          position: position,
          playerCode: playerCode,
          name: playerName,
          points: points,
        ),
      );
    }
    return rows;
  }

  List<ChampionshipStatsRanking> _buildChampionshipStatsRankings(
    List<ChampionshipInfo> championships,
    Map<String, PlayerInfo> playersByCode,
    Map<String, ChampionshipInfo> championshipsByCode,
  ) {
    if (championships.isEmpty) {
      return const [];
    }

    final aggregated = <String, _StatsAccumulator>{};

    for (final championship in championships) {
      if (championship.championPlayerCode.isEmpty || championship.championPoints <= 0) {
        continue;
      }

      final current = aggregated.putIfAbsent(
        championship.championPlayerCode,
        _StatsAccumulator.new,
      );
      current.titles += 1;
      current.points += championship.championPoints;
      final championshipName =
          championshipsByCode[championship.code]?.name ?? championship.code;
      current.wins.add(
        ChampionshipWinRecord(
          championshipCode: championship.code,
          championshipName: championshipName,
          points: championship.championPoints,
        ),
      );
    }

    final entries = aggregated.entries.toList()
      ..sort((a, b) {
        final byPoints = b.value.points.compareTo(a.value.points);
        if (byPoints != 0) {
          return byPoints;
        }

        final byTitles = b.value.titles.compareTo(a.value.titles);
        if (byTitles != 0) {
          return byTitles;
        }

        final aName = playersByCode[a.key]?.name ?? a.key;
        final bName = playersByCode[b.key]?.name ?? b.key;
        return aName.compareTo(bName);
      });

    final rankings = <ChampionshipStatsRanking>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final playerName = playersByCode[entry.key]?.name ?? entry.key;
      rankings.add(
        ChampionshipStatsRanking(
          position: i + 1,
          playerCode: entry.key,
          name: playerName,
          titles: entry.value.titles,
          points: entry.value.points,
          wins: List.unmodifiable(entry.value.wins),
        ),
      );
    }

    return rankings;
  }

  List<ChampionshipInfo> _parseChampionships(
    Sheet? sheet,
    Map<String, PlayerInfo> playersByCode,
  ) {
    if (sheet == null) {
      return const [];
    }

    final rows = <ChampionshipInfo>[];
    for (final row in sheet.rows.skip(1)) {
      final code = _readCell(row, 0);
      final name = _readCell(row, 1);
      final type = _readCell(row, 2);
      final championPlayerCode = _readCell(row, 3);
      final championPoints = int.tryParse(_readCell(row, 4));
      final status = _readCell(row, 5);
      final details = _readCell(row, 6);
      final championName = playersByCode[championPlayerCode]?.name ?? championPlayerCode;

      if (code.isEmpty ||
          name.isEmpty ||
          type.isEmpty ||
          championPlayerCode.isEmpty ||
          championPoints == null ||
          status.isEmpty) {
        continue;
      }

      rows.add(
        ChampionshipInfo(
          code: code,
          name: name,
          type: type,
          championPlayerCode: championPlayerCode,
          championName: championName,
          championPoints: championPoints,
          status: status,
          details: details,
        ),
      );
    }
    return rows;
  }

  List<MatchInfo> _parseMatches(Sheet? sheet, Map<String, PlayerInfo> playersByCode) {
    if (sheet == null) {
      return const [];
    }

    final rows = <MatchInfo>[];
    for (final row in sheet.rows.skip(1)) {
      final championshipCode = _readCell(row, 0);
      final phaseCode = _readCell(row, 1);
      final groupName = _readCell(row, 2);
      final homePlayerCode = _readCell(row, 3);
      final awayPlayerCode = _readCell(row, 4);
      final schedule = _readCell(row, 5);
      final homeGoals = int.tryParse(_readCell(row, 6));
      final awayGoals = int.tryParse(_readCell(row, 7));

      final homePlayer = playersByCode[homePlayerCode]?.name ?? homePlayerCode;
      final awayPlayer = playersByCode[awayPlayerCode]?.name ?? awayPlayerCode;

      if (championshipCode.isEmpty ||
          phaseCode.isEmpty ||
          homePlayerCode.isEmpty ||
          awayPlayerCode.isEmpty) {
        continue;
      }

      rows.add(
        MatchInfo(
          championshipCode: championshipCode,
          phaseCode: phaseCode,
          groupName: groupName,
          homePlayerCode: homePlayerCode,
          homePlayer: homePlayer,
          awayPlayerCode: awayPlayerCode,
          awayPlayer: awayPlayer,
          schedule: schedule,
          homeGoals: homeGoals,
          awayGoals: awayGoals,
        ),
      );
    }
    return rows;
  }

  List<ChampionshipPhaseInfo> _parseChampionshipPhases(Sheet? sheet) {
    if (sheet == null) {
      return const [];
    }

    final phases = <ChampionshipPhaseInfo>[];
    for (final row in sheet.rows.skip(1)) {
      final code = _readCell(row, 0);
      final championshipCode = _readCell(row, 1);
      final name = _readCell(row, 2);
      final type = _readCell(row, 3);
      final order = int.tryParse(_readCell(row, 4));

      if (code.isEmpty || championshipCode.isEmpty || name.isEmpty || type.isEmpty || order == null) {
        continue;
      }

      phases.add(
        ChampionshipPhaseInfo(
          code: code,
          championshipCode: championshipCode,
          name: name,
          type: type,
          order: order,
        ),
      );
    }

    phases.sort((a, b) {
      final byChampionship = a.championshipCode.compareTo(b.championshipCode);
      if (byChampionship != 0) {
        return byChampionship;
      }
      return a.order.compareTo(b.order);
    });

    return phases;
  }

  List<ChampionshipTableEntry> _parseChampionshipTable(
    Sheet? sheet,
    Map<String, PlayerInfo> playersByCode,
  ) {
    if (sheet == null) {
      return const [];
    }

    final entries = <ChampionshipTableEntry>[];
    for (final row in sheet.rows.skip(1)) {
      final championshipCode = _readCell(row, 0);
      final playerCode = _readCell(row, 1);
      final position = int.tryParse(_readCell(row, 2));
      final points = int.tryParse(_readCell(row, 3));
      final played = int.tryParse(_readCell(row, 4));
      final won = int.tryParse(_readCell(row, 5));
      final drawn = int.tryParse(_readCell(row, 6));
      final lost = int.tryParse(_readCell(row, 7));
      final goalsFor = int.tryParse(_readCell(row, 8));
      final goalsAgainst = int.tryParse(_readCell(row, 9));

      if (championshipCode.isEmpty ||
          playerCode.isEmpty ||
          position == null ||
          points == null ||
          played == null ||
          won == null ||
          drawn == null ||
          lost == null ||
          goalsFor == null ||
          goalsAgainst == null) {
        continue;
      }

      entries.add(
        ChampionshipTableEntry(
          championshipCode: championshipCode,
          playerCode: playerCode,
          playerName: playersByCode[playerCode]?.name ?? playerCode,
          position: position,
          points: points,
          played: played,
          won: won,
          drawn: drawn,
          lost: lost,
          goalsFor: goalsFor,
          goalsAgainst: goalsAgainst,
        ),
      );
    }

    entries.sort((a, b) {
      final byChampionship = a.championshipCode.compareTo(b.championshipCode);
      if (byChampionship != 0) {
        return byChampionship;
      }
      return a.position.compareTo(b.position);
    });

    return entries;
  }

  String _readCell(List<Data?> row, int index) {
    if (index >= row.length) {
      return '';
    }

    final cell = row[index];
    final value = cell?.value;
    return value?.toString().trim() ?? '';
  }
}

class _StatsAccumulator {
  int titles = 0;
  int points = 0;
  final List<ChampionshipWinRecord> wins = [];
}
