import 'dart:io';

import 'package:excel/excel.dart';

void main() {
  final excel = Excel.createExcel();

  final teams = <(String, String)>[
    ('PLY001', 'Jugador 1'),
    ('PLY002', 'Jugador 2'),
    ('PLY003', 'Jugador 3'),
    ('PLY004', 'Jugador 4'),
    ('PLY005', 'Jugador 5'),
    ('PLY006', 'Jugador 6'),
    ('PLY007', 'Jugador 7'),
    ('PLY008', 'Jugador 8'),
    ('PLY009', 'Jugador 9'),
    ('PLY010', 'Jugador 10'),
    ('PLY011', 'Jugador 11'),
    ('PLY012', 'Jugador 12'),
    ('PLY013', 'Jugador 13'),
    ('PLY014', 'Jugador 14'),
    ('PLY015', 'Jugador 15'),
    ('PLY016', 'Jugador 16'),
  ];

  final championships = <_CupSeed>[
    _CupSeed(
      code: 'CHP2020',
      name: 'UEFA Champions League 2019-20',
      logoUrl: 'https://mrrichar.netlify.app/logo.png',
      championCode: 'PLY003',
      championPoints: 900,
      details: 'Final: Paris Saint-Germain 0-1 Bayern Munich',
    ),
    _CupSeed(
      code: 'CHP2021',
      name: 'UEFA Champions League 2020-21',
      logoUrl: 'https://mrrichar.netlify.app/logo.png',
      championCode: 'PLY004',
      championPoints: 920,
      details: 'Final: Manchester City 0-1 Chelsea',
    ),
    _CupSeed(
      code: 'CHP2022',
      name: 'UEFA Champions League 2021-22',
      logoUrl: 'https://mrrichar.netlify.app/logo.png',
      championCode: 'PLY001',
      championPoints: 980,
      details: 'Final: Liverpool 0-1 Real Madrid',
    ),
    _CupSeed(
      code: 'CHP2023',
      name: 'UEFA Champions League 2022-23',
      logoUrl: 'https://mrrichar.netlify.app/logo.png',
      championCode: 'PLY002',
      championPoints: 1020,
      details: 'Final: Manchester City 1-0 Inter Milan',
    ),
    _CupSeed(
      code: 'CHP2024',
      name: 'UEFA Champions League 2023-24',
      logoUrl: 'https://mrrichar.netlify.app/logo.png',
      championCode: 'PLY001',
      championPoints: 1100,
      details: 'Final: Borussia Dortmund 0-2 Real Madrid',
    ),
  ];

  final groups = <String, List<String>>{
    'Grupo A': ['PLY001', 'PLY005', 'PLY006', 'PLY016'],
    'Grupo B': ['PLY002', 'PLY007', 'PLY004', 'PLY013'],
    'Grupo C': ['PLY003', 'PLY009', 'PLY010', 'PLY015'],
    'Grupo D': ['PLY008', 'PLY011', 'PLY012', 'PLY014'],
  };

  final playersSheet = excel['Players'];
  playersSheet.appendRow([
    TextCellValue('code'),
    TextCellValue('name'),
    TextCellValue('logoUrl'),
  ]);
  for (final team in teams) {
    playersSheet.appendRow([
      TextCellValue(team.$1),
      TextCellValue(team.$2),
      TextCellValue('https://mrrichar.netlify.app/logo.png'),
    ]);
  }

  final communityRankingSheet = excel['CommunityRanking'];
  communityRankingSheet.appendRow([
    TextCellValue('position'),
    TextCellValue('playerCode'),
    TextCellValue('points'),
  ]);
  final communityOrder = [
    'PLY001',
    'PLY002',
    'PLY003',
    'PLY004',
    'PLY007',
    'PLY008',
    'PLY005',
    'PLY006',
    'PLY009',
    'PLY010',
    'PLY011',
    'PLY012',
    'PLY013',
    'PLY014',
    'PLY015',
    'PLY016',
  ];
  for (var i = 0; i < communityOrder.length; i++) {
    communityRankingSheet.appendRow([
      IntCellValue(i + 1),
      TextCellValue(communityOrder[i]),
      IntCellValue(1600 - (i * 35)),
    ]);
  }

  final championshipsSheet = excel['Championships'];
  championshipsSheet.appendRow([
    TextCellValue('code'),
    TextCellValue('name'),
    TextCellValue('logoUrl'),
    TextCellValue('type'),
    TextCellValue('championPlayerCode'),
    TextCellValue('championPoints'),
    TextCellValue('status'),
    TextCellValue('details'),
  ]);
  for (final cup in championships) {
    championshipsSheet.appendRow([
      TextCellValue(cup.code),
      TextCellValue(cup.name),
      TextCellValue(cup.logoUrl),
      TextCellValue('Copa Internacional'),
      TextCellValue(cup.championCode),
      IntCellValue(cup.championPoints),
      TextCellValue('Finalizado'),
      TextCellValue(cup.details),
    ]);
  }

  final phasesSheet = excel['ChampionshipPhases'];
  phasesSheet.appendRow([
    TextCellValue('code'),
    TextCellValue('championshipCode'),
    TextCellValue('name'),
    TextCellValue('type'),
    TextCellValue('order'),
  ]);
  for (final cup in championships) {
    phasesSheet.appendRow([
      TextCellValue('${cup.code}_G'),
      TextCellValue(cup.code),
      TextCellValue('Fase de Grupos'),
      TextCellValue('grupo'),
      IntCellValue(1),
    ]);
    phasesSheet.appendRow([
      TextCellValue('${cup.code}_R16'),
      TextCellValue(cup.code),
      TextCellValue('Octavos de Final'),
      TextCellValue('eliminacion directa'),
      IntCellValue(2),
    ]);
    phasesSheet.appendRow([
      TextCellValue('${cup.code}_QF'),
      TextCellValue(cup.code),
      TextCellValue('Cuartos de Final'),
      TextCellValue('eliminacion directa'),
      IntCellValue(3),
    ]);
    phasesSheet.appendRow([
      TextCellValue('${cup.code}_SF'),
      TextCellValue(cup.code),
      TextCellValue('Semifinales'),
      TextCellValue('eliminacion directa'),
      IntCellValue(4),
    ]);
    phasesSheet.appendRow([
      TextCellValue('${cup.code}_F'),
      TextCellValue(cup.code),
      TextCellValue('Final'),
      TextCellValue('eliminacion directa'),
      IntCellValue(5),
    ]);
  }

  final matchesSheet = excel['Matches'];
  matchesSheet.appendRow([
    TextCellValue('championshipCode'),
    TextCellValue('phaseCode'),
    TextCellValue('groupName'),
    TextCellValue('homePlayerCode'),
    TextCellValue('awayPlayerCode'),
    TextCellValue('schedule'),
    TextCellValue('startDate'),
    TextCellValue('endDate'),
    TextCellValue('homeGoals'),
    TextCellValue('awayGoals'),
  ]);
  for (final cup in championships) {
    final groupPhaseCode = '${cup.code}_G';
    final round16PhaseCode = '${cup.code}_R16';
    final quarterPhaseCode = '${cup.code}_QF';
    final semiPhaseCode = '${cup.code}_SF';
    final finalPhaseCode = '${cup.code}_F';

    final top16 = <String>[];
    for (final groupEntry in groups.entries) {
      final groupName = groupEntry.key;
      final groupTeams = groupEntry.value;

      // Round-robin in each group: 6 matches (every pair once)
      var matchDay = 1;
      for (var i = 0; i < groupTeams.length; i++) {
        for (var j = i + 1; j < groupTeams.length; j++) {
          matchesSheet.appendRow([
            TextCellValue(cup.code),
            TextCellValue(groupPhaseCode),
            TextCellValue(groupName),
            TextCellValue(groupTeams[i]),
            TextCellValue(groupTeams[j]),
            TextCellValue('${cup.code} MD$matchDay 21:00'),
            TextCellValue('2026-04-${(matchDay + 9).toString().padLeft(2, '0')} 21:00'),
            TextCellValue('2026-04-${(matchDay + 9).toString().padLeft(2, '0')} 23:00'),
            IntCellValue((i + j + matchDay) % 4),
            IntCellValue((i * 2 + j + 1) % 4),
          ]);
          matchDay++;
        }
      }

      top16.addAll(groupTeams);
    }

    // Octavos (8 cruces)
    for (var i = 0; i < 8; i++) {
      matchesSheet.appendRow([
        TextCellValue(cup.code),
        TextCellValue(round16PhaseCode),
        TextCellValue(''),
        TextCellValue(top16[i]),
        TextCellValue(top16[15 - i]),
        TextCellValue('${cup.code} Octavos ${i + 1}'),
        TextCellValue('2026-05-${(i + 1).toString().padLeft(2, '0')} 20:00'),
        TextCellValue('2026-05-${(i + 1).toString().padLeft(2, '0')} 22:00'),
        IntCellValue((i + 1) % 3),
        IntCellValue((i + 2) % 3),
      ]);
    }

    // Cuartos (4 cruces)
    final quarterTeams = top16.take(8).toList(growable: false);
    for (var i = 0; i < 4; i++) {
      matchesSheet.appendRow([
        TextCellValue(cup.code),
        TextCellValue(quarterPhaseCode),
        TextCellValue(''),
        TextCellValue(quarterTeams[i]),
        TextCellValue(quarterTeams[7 - i]),
        TextCellValue('${cup.code} Cuartos ${i + 1}'),
        TextCellValue('2026-05-${(i + 11).toString().padLeft(2, '0')} 20:00'),
        TextCellValue('2026-05-${(i + 11).toString().padLeft(2, '0')} 22:00'),
        IntCellValue((i + 2) % 3),
        IntCellValue((i + 1) % 2),
      ]);
    }

    // Semifinales (2 cruces)
    final semiTeams = quarterTeams.take(4).toList(growable: false);
    matchesSheet.appendRow([
      TextCellValue(cup.code),
      TextCellValue(semiPhaseCode),
      TextCellValue(''),
      TextCellValue(semiTeams[0]),
      TextCellValue(semiTeams[3]),
      TextCellValue('${cup.code} Semifinal 1'),
      TextCellValue('2026-05-20 20:00'),
      TextCellValue('2026-05-20 22:00'),
      IntCellValue(1),
      IntCellValue(0),
    ]);
    matchesSheet.appendRow([
      TextCellValue(cup.code),
      TextCellValue(semiPhaseCode),
      TextCellValue(''),
      TextCellValue(semiTeams[1]),
      TextCellValue(semiTeams[2]),
      TextCellValue('${cup.code} Semifinal 2'),
      TextCellValue('2026-05-21 20:00'),
      TextCellValue('2026-05-21 22:00'),
      IntCellValue(0),
      IntCellValue(1),
    ]);

    // Final (1 cruce) - incluye al campeon del campeonato
    matchesSheet.appendRow([
      TextCellValue(cup.code),
      TextCellValue(finalPhaseCode),
      TextCellValue(''),
      TextCellValue(cup.championCode),
      TextCellValue('PLY002' == cup.championCode ? 'PLY001' : 'PLY002'),
      TextCellValue('${cup.code} Final 21:00'),
      TextCellValue('2026-05-28 21:00'),
      TextCellValue('2026-05-28 23:00'),
      IntCellValue(2),
      IntCellValue(1),
    ]);
  }

  excel.delete('Sheet1');

  final encoded = excel.encode();
  if (encoded == null) {
    stderr.writeln('No se pudo generar el archivo Excel.');
    exitCode = 1;
    return;
  }

  final output = File('assets/data/mrrichar_data.xlsx');
  output.createSync(recursive: true);
  output.writeAsBytesSync(encoded, flush: true);

  stdout.writeln('Excel generado en: ${output.path}');
}

class _CupSeed {
  const _CupSeed({
    required this.code,
    required this.name,
    required this.logoUrl,
    required this.championCode,
    required this.championPoints,
    required this.details,
  });

  final String code;
  final String name;
  final String logoUrl;
  final String championCode;
  final int championPoints;
  final String details;
}
