import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/project.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String projectsTable = 'projects_table';
  String colId = 'id';
  String colName = 'name';
  String colCompany = 'company';
  String colAddress = 'address';
  String colZipcode = 'zipcode';
  String colLatitude = 'latitude';
  String colLongitude = 'longitude';

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'todo.db');
    final todoDb = await openDatabase(path, version: 2, onCreate: _createDb, onUpgrade: _upgradeDb);
    return todoDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $projectsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colCompany TEXT, $colAddress TEXT, $colZipcode TEXT, $colLatitude REAL, $colLongitude REAL)',
    );
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $projectsTable ADD COLUMN $colCompany TEXT');
      await db.execute('ALTER TABLE $projectsTable ADD COLUMN $colAddress TEXT');
      await db.execute('ALTER TABLE $projectsTable ADD COLUMN $colZipcode TEXT');
      await db.execute('ALTER TABLE $projectsTable ADD COLUMN $colLatitude REAL');
      await db.execute('ALTER TABLE $projectsTable ADD COLUMN $colLongitude REAL');
    }
  }

  Future<List<Project>> getProjects() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query(projectsTable);
    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  Future<int> insertProject(Project project) async {
    Database? db = await this.db;
    final int result = await db!.insert(projectsTable, project.toMap());
    return result;
  }

  Future<int> updateProject(Project project) async {
    Database? db = await this.db;
    final int result = await db!.update(
      projectsTable,
      project.toMap(),
      where: '$colId = ?',
      whereArgs: [project.id],
    );
    return result;
  }

  Future<int> deleteProject(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(
      projectsTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
