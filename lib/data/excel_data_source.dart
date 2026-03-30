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
    this.startDate,
    this.endDate,
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
  final String? startDate;
  final String? endDate;
  final int? homeGoals;
  final int? awayGoals;

  String get timeWindowLabel {
    final hasStart = startDate != null && startDate!.trim().isNotEmpty;
    final hasEnd = endDate != null && endDate!.trim().isNotEmpty;

    if (hasStart && hasEnd) {
      return '${startDate!} - ${endDate!}';
    }
    if (hasStart) {
      return startDate!;
    }
    if (hasEnd) {
      return endDate!;
    }
    return schedule.trim();
  }
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

    final rowsData = sheet.rows;
    if (rowsData.isEmpty) {
      return const [];
    }

    final headers = _buildHeaderIndex(rowsData.first);
    final championshipCodeIndex = _columnIndex(headers, ['championshipcode'], 0);
    final phaseCodeIndex = _columnIndex(headers, ['phasecode'], 1);
    final groupNameIndex = _columnIndex(headers, ['groupname'], 2);
    final homePlayerCodeIndex = _columnIndex(headers, ['homeplayercode'], 3);
    final awayPlayerCodeIndex = _columnIndex(headers, ['awayplayercode'], 4);
    final scheduleIndex = _columnIndex(headers, ['schedule'], 5);
    final startDateIndex = _columnIndex(
      headers,
      ['startdate', 'fechainicio', 'fecha_inicio', 'inicio'],
      null,
    );
    final endDateIndex = _columnIndex(
      headers,
      ['enddate', 'fechatermino', 'fecha_termino', 'fin', 'fecha_final'],
      null,
    );
    final homeGoalsIndex = _columnIndex(headers, ['homegoals'], 6);
    final awayGoalsIndex = _columnIndex(headers, ['awaygoals'], 7);

    final rows = <MatchInfo>[];
    for (final row in rowsData.skip(1)) {
      final championshipCode = _readCell(row, championshipCodeIndex);
      final phaseCode = _readCell(row, phaseCodeIndex);
      final groupName = _readCell(row, groupNameIndex);
      final homePlayerCode = _readCell(row, homePlayerCodeIndex);
      final awayPlayerCode = _readCell(row, awayPlayerCodeIndex);
      final schedule = _readCell(row, scheduleIndex);
      final startDate = _readCellNullable(row, startDateIndex);
      final endDate = _readCellNullable(row, endDateIndex);
      final homeGoals = int.tryParse(_readCell(row, homeGoalsIndex));
      final awayGoals = int.tryParse(_readCell(row, awayGoalsIndex));

      final homePlayer = playersByCode[homePlayerCode]?.name ?? homePlayerCode;
      final awayPlayer = playersByCode[awayPlayerCode]?.name ?? awayPlayerCode;

      final resolvedSchedule = schedule.isNotEmpty
          ? schedule
          : _buildScheduleFromWindow(startDate, endDate);

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
          schedule: resolvedSchedule,
          startDate: startDate,
          endDate: endDate,
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
    if (index < 0 || index >= row.length) {
      return '';
    }

    final cell = row[index];
    final value = cell?.value;
    return value?.toString().trim() ?? '';
  }

  String? _readCellNullable(List<Data?> row, int? index) {
    if (index == null) {
      return null;
    }

    final value = _readCell(row, index);
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  String _buildScheduleFromWindow(String? startDate, String? endDate) {
    final hasStart = startDate != null && startDate.trim().isNotEmpty;
    final hasEnd = endDate != null && endDate.trim().isNotEmpty;

    if (hasStart && hasEnd) {
      return '${startDate!} - ${endDate!}';
    }
    if (hasStart) {
      return startDate!;
    }
    if (hasEnd) {
      return endDate!;
    }
    return '';
  }

  Map<String, int> _buildHeaderIndex(List<Data?> headerRow) {
    final indexByHeader = <String, int>{};

    for (var i = 0; i < headerRow.length; i++) {
      final header = _normalizeHeader(_readCell(headerRow, i));
      if (header.isNotEmpty) {
        indexByHeader[header] = i;
      }
    }

    return indexByHeader;
  }

  int _columnIndex(Map<String, int> headers, List<String> aliases, int? fallback) {
    for (final alias in aliases) {
      final normalizedAlias = _normalizeHeader(alias);
      final idx = headers[normalizedAlias];
      if (idx != null) {
        return idx;
      }
    }

    if (fallback != null) {
      return fallback;
    }
    return -1;
  }

  String _normalizeHeader(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

class _StatsAccumulator {
  int titles = 0;
  int points = 0;
  final List<ChampionshipWinRecord> wins = [];
}
