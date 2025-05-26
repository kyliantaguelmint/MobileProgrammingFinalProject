import 'package:firebase/models/articles.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

const String fileName = 'articles_database/db';

class AppDatabase{
  AppDatabase._init();

  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initializeDB(fileName);
    return _database!;
  }

  Future _createDB(Database db, int version) async{
    await db.execute(createArticleTable);
  }
  
  Future<Database> _initializeDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }

}