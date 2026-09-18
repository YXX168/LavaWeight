import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

abstract interface class StateStore {
  Future<String?> read();
  Future<void> write(String value);
}

class SqliteStateStore implements StateStore {
  final Database database;
  SqliteStateStore(this.database);

  static Future<SqliteStateStore> open() async {
    final db = await openDatabase(
      path.join(await getDatabasesPath(), 'lavaweight.db'),
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE app_state (id INTEGER PRIMARY KEY, value TEXT NOT NULL)',
      ),
    );
    return SqliteStateStore(db);
  }

  @override
  Future<String?> read() async {
    final rows = await database.query(
      'app_state',
      where: 'id = ?',
      whereArgs: [1],
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  @override
  Future<void> write(String value) async {
    await database.transaction((txn) async {
      await txn.insert('app_state', {
        'id': 1,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
