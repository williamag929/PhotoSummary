import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/punch_list_item.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'punch_list.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE punch_list_items(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            location TEXT,
            category TEXT,
            priority TEXT,
            status TEXT,
            assignedTo TEXT,
            createdDate TEXT,
            dueDate TEXT,
            completedDate TEXT,
            photoPaths TEXT,
            estimatedHours REAL,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertPunchListItem(PunchListItem item) async {
    final db = await database;
    return await db.insert(
      'punch_list_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PunchListItem>> getAllPunchListItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'punch_list_items',
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => PunchListItem.fromMap(maps[i]));
  }

  Future<List<PunchListItem>> getItemsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'punch_list_items',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => PunchListItem.fromMap(maps[i]));
  }

  Future<int> updatePunchListItem(PunchListItem item) async {
    final db = await database;
    return await db.update(
      'punch_list_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deletePunchListItem(String id) async {
    final db = await database;
    return await db.delete(
      'punch_list_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<PunchListItem?> getPunchListItem(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'punch_list_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return PunchListItem.fromMap(maps.first);
  }

  Future<Map<String, int>> getSummary() async {
    final db = await database;

    final total = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM punch_list_items')) ??
        0;

    final pending = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM punch_list_items WHERE status = ?',
            ['Pending'])) ??
        0;

    final inProgress = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM punch_list_items WHERE status = ?',
            ['In Progress'])) ??
        0;

    final completed = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM punch_list_items WHERE status = ?',
            ['Completed'])) ??
        0;

    final highPriority = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM punch_list_items WHERE priority = ?',
            ['High'])) ??
        0;

    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'highPriority': highPriority,
    };
  }
}
