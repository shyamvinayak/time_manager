import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../utils.dart';
import 'check_in_out_record.dart';  // Adjust the import to your model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), sqDB);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE check_in_out(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checkInTime TEXT,
        checkOutTime TEXT
      )
    ''');
  }

  Future<void> insertCheckInOutRecord(CheckInOutRecord record) async {
    final db = await database;
    await db.insert(
      checkInOut,
      {
        checkInTime: record.checkInTime.toIso8601String(),
        checkOutTime: record.checkOutTime.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CheckInOutRecord>> getCheckInOutRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(checkInOut);

    return List.generate(maps.length, (i) {
      return CheckInOutRecord(
        chooseDate: DateTime.now(),
        checkInTime: DateTime.parse(maps[i][checkInTime]),
        checkOutTime: DateTime.parse(maps[i][checkOutTime]),
      );
    });
  }

  Future<void> updateCheckInOutRecord(CheckInOutRecord record) async {
    final db = await database;
    await db.update(
      checkInOut,
      {
        checkInTime: record.checkInTime.toIso8601String(),
        checkOutTime: record.checkOutTime.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteCheckInOutRecord(int id) async {
    final db = await database;
    await db.delete(
      checkInOut,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRecord()async{
    final db = await database;
    await db.delete(checkInOut);
  }
}
