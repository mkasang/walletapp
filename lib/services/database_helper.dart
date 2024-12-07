import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:walletapp/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wallet.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');
  }

  // Créer un nouvel utilisateur
  Future<UserModel> createUser(UserModel user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  // Récupérer un utilisateur par email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour le solde d'un utilisateur
  Future<int> updateUserBalance(int userId, double newBalance) async {
    final db = await instance.database;
    return db.update(
      'users',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
