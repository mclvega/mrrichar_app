import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalSettingsDb {
  LocalSettingsDb._();

  static final LocalSettingsDb instance = LocalSettingsDb._();

  static const String _databaseName = 'mrrichar_local.db';
  static const String _settingsTable = 'app_settings';
  static const String _defaultPlayerKey = 'default_player_code';

  Database? _db;

  Future<Database> _database() async {
    if (_db != null) {
      return _db!;
    }

    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _databaseName);

    _db = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_settingsTable (
            setting_key TEXT PRIMARY KEY,
            setting_value TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<String?> getDefaultPlayerCode() async {
    final db = await _database();
    final rows = await db.query(
      _settingsTable,
      columns: const ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: const [_defaultPlayerKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final value = rows.first['setting_value'] as String?;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> setDefaultPlayerCode(String? playerCode) async {
    final db = await _database();

    if (playerCode == null || playerCode.trim().isEmpty) {
      await db.delete(
        _settingsTable,
        where: 'setting_key = ?',
        whereArgs: const [_defaultPlayerKey],
      );
      return;
    }

    await db.insert(
      _settingsTable,
      {
        'setting_key': _defaultPlayerKey,
        'setting_value': playerCode.trim(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
