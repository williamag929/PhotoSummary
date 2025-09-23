
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
      version: 2, // Incremented version
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reports (
            id TEXT PRIMARY KEY,
            date TEXT,
            photoPath TEXT,
            section TEXT,
            issue TEXT,
            location TEXT,
            details TEXT,
            actionRequired TEXT,
            assignedTo TEXT,
            projectId INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE reports ADD COLUMN projectId INTEGER');
        }
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

  Future<List<Report>> getReports({int? projectId}) async {
    final db = await database;
    final maps = await db.query(
      'reports',
      where: projectId != null ? 'projectId = ?' : null,
      whereArgs: projectId != null ? [projectId] : null,
    );
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }

  Future<void> deleteReport(String id) async {
    final db = await database;
    await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
