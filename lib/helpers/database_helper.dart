
import 'dart:io';
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

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo.db';
    final todoDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $projectsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(projectsTable);
    return result;
  }

  Future<int> insertProject(Map<String, dynamic> project) async {
    Database? db = await this.db;
    final int result = await db!.insert(projectsTable, project);
    return result;
  }
}
