import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'construction_daily_report.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reports (
            id TEXT PRIMARY KEY,
            date TEXT,
            note TEXT,
            photoPath TEXT,
            aiAnalysis TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertReport(Report report) async {
    final db = await database;
    await db.insert(
      'reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Report>> getReports() async {
    final db = await database;
    final maps = await db.query('reports');
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }
}
