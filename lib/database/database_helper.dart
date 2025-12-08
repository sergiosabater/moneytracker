import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter to obtain the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the transactions table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
