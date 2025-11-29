import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/practice_stat.dart';

class StatsDb {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'stats.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            language TEXT NOT NULL,
            total INTEGER NOT NULL,
            correct INTEGER NOT NULL,
            percent REAL NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> insertStat(PracticeStat s) async {
    final database = await db;
    return await database.insert('stats', s.toMap());
  }

  static Future<List<PracticeStat>> getAllStats() async {
    final database = await db;
    final rows = await database.query('stats', orderBy: 'timestamp DESC');
    return rows.map((r) => PracticeStat.fromMap(r)).toList();
  }

  static Future<int> deleteStat(int id) async {
    final database = await db;
    return await database.delete('stats', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> clearAll() async {
    final database = await db;
    return await database.delete('stats');
  }
}
