import 'dart:developer';

import 'package:path/path.dart';
import 'package:skinoura/models/ritual_model.dart';
import 'package:skinoura/models/user_model_sql.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'skinoura.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT,
          email TEXT UNIQUE,
          password TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE rituals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          subtitle TEXT,
          isDone INTEGER DEFAULT 0,
<<<<<<< HEAD
          ownerEmail TEXT
=======
          ownerEmail TEXT 
>>>>>>> 5dbd063a1eeaa9e47ff4989c4e42a2eed4fcb6db
        )
      ''');
      },
    );
  }

  Future<bool> registerUser(UserModelSql pengguna) async {
    final db = await database;
    try {
      await db.insert('users', pengguna.toMap());
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<UserModelSql?> loginUser(UserModelSql pengguna) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [pengguna.email, pengguna.password],
    );
    log(results.toString());

    if (results.isNotEmpty) {
      return UserModelSql.fromMap(results.first);
    }
    return null;
  }

  Future<List<UserModelSql>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('users');

    return results.map((map) => UserModelSql.fromMap(map)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> updateUser(UserModelSql pengguna) async {
    final db = await database;
    try {
      int count = await db.update(
        'users',
        pengguna.toMap(),
        where: 'id = ?',
        whereArgs: [pengguna.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  //crud ritual
  Future<int> insertRitual(RitualModel ritual) async {
    final db = await database;

    return await db.insert('rituals', ritual.toMap());
  }

  Future<List<RitualModel>> getRitualsByEmail(String email) async {
    final db = await database;

    final results = await db.query(
      'rituals',
      where: 'ownerEmail = ?',
      whereArgs: [email],
    );

    return results.map((e) => RitualModel.fromMap(e)).toList();
  }

  Future<bool> updateRitualStatus(int id, bool isDone) async {
    final db = await database;

    int count = await db.update(
      'rituals',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    return count > 0;
  }

  Future<bool> updateRitual(RitualModel ritual) async {
    final db = await database;

    int count = await db.update(
      'rituals',
      ritual.toMap(),
      where: 'id = ?',
      whereArgs: [ritual.id],
    );

    return count > 0;
  }

  Future<bool> deleteRitual(int id) async {
    final db = await database;

    int count = await db.delete('rituals', where: 'id = ?', whereArgs: [id]);

    return count > 0;
  }
}
