import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:moneytracker/model/transaction.dart';

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

  // Insert a new transaction
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;

    return await db.insert('transactions', {
      'type': transaction.type.toString(),
      'amount': transaction.amount,
      'description': transaction.description,
      'dateTime': transaction.dateTime.toIso8601String(),
    });
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    final db = await instance.database;

    final result = await db.query(
      'transactions',
      orderBy: 'dateTime DESC', // Order by most recent first
    );

    return result
        .map(
          (json) => Transaction(
            id: json['id'] as int,
            type: json['type'] == 'TransactionType.income'
                ? TransactionType.income
                : TransactionType.expense,
            amount: json['amount'] as double,
            description: json['description'] as String,
            dateTime: DateTime.parse(json['dateTime'] as String),
          ),
        )
        .toList();
  }

  // Delete a transaction by id
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;

    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all transactions
  Future<int> deleteAllTransactions() async {
    final db = await instance.database;

    return await db.delete('transactions');
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
