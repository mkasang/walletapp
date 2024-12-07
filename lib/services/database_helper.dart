// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:walletapp/models/card_model.dart';
import 'package:walletapp/models/notifications.dart';
import 'package:walletapp/models/transaction_model.dart';
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
    try {
      // Table utilisateurs
      await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');

      // Table transactions
      await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        recipient_id TEXT,
        bill_reference TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

      // Table cartes
      await db.execute('''
      CREATE TABLE IF NOT EXISTS cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        card_number TEXT NOT NULL,
        card_holder_name TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        cvv TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

      // Table notifications
      await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    } catch (e) {
      print('Erreur lors de la création des tables: $e');
      rethrow;
    }
  }

  // Méthodes pour les utilisateurs
  Future<UserModel> createUser(UserModel user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

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

  Future<int> updateUserBalance(int userId, double newBalance) async {
    final db = await instance.database;
    return db.update(
      'users',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Méthodes pour les transactions
  Future<TransactionModel> createTransaction(
      TransactionModel transaction) async {
    final db = await instance.database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction;
  }

  Future<List<TransactionModel>> getUserTransactions(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Méthodes pour les cartes
  Future<WalletCard> createCard(WalletCard card) async {
    final db = await instance.database;
    final id = await db.insert('cards', card.toMap());
    return card;
  }

  Future<WalletCard?> getUserCard(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'cards',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return WalletCard.fromMap(result.first);
    }
    return null;
  }

  // Méthodes pour les notifications
  Future<WalletNotification> createNotification(
    WalletNotification notification,
  ) async {
    final db = await instance.database;
    final id = await db.insert('notifications', notification.toMap());
    return notification;
  }

  Future<List<WalletNotification>> getUserNotifications(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((map) => WalletNotification.fromMap(map)).toList();
  }

  Future<int> markNotificationAsRead(int notificationId) async {
    final db = await instance.database;
    return db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }
}
