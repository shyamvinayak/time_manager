import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:time_manager/model/userprofile.dart';

import '../utils.dart';
import '../model/check_in_out_record.dart';  // Adjust the import to your model

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
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }

    Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE user_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            dateOfBirth TEXT
          )
        ''');
      }
    }


    Future<void> _createDB(Database db, int version) async {
      await db.execute('''
        CREATE TABLE check_in_out(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          checkInTime TEXT,
          checkOutTime TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE user_profile(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          dateOfBirth TEXT
        )
      ''');
    }

    Future<int> insertUserProfile(UserProfile userProfile) async {
      final db = await database;
      return await db.insert(
        'user_profile',
        userProfile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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

    Future<List<UserProfile>> getUserProfiles() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('user_profile');

      return List.generate(maps.length, (i) {
        return UserProfile(
          id: maps[i]['id'],
          name: maps[i]['name'],
          dateOfBirth: DateTime.parse(maps[i]['dateOfBirth']),
        );
      });
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

    Future<void> updateUserProfile(UserProfile userProfile) async {
      final db = await database;
      await db.update(
        'user_profile',
        userProfile.toMap(),
        where: 'id = ?',
        whereArgs: [userProfile.id],
      );
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

    Future<void> deleteUserProfile(int id) async {
      final db = await database;
      await db.delete(
        'user_profile',
        where: 'id = ?',
        whereArgs: [id],
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

    Future<void> deleteCheckInOutRecordsByDate(DateTime date) async {
      final db = await database;
      await db.delete(
        checkInOut,
        where: 'date(checkInTime) = ?',
        whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
      );
    }

    Future<List<CheckInOutRecord>> getCheckInOutRecordsByDate(DateTime date) async {
      final db = await database;
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final List<Map<String, dynamic>> maps = await db.query(
        'check_in_out',
        where: 'date(checkInTime) = ?',
        whereArgs: [formattedDate],
      );

      return List.generate(maps.length, (i) {
        return CheckInOutRecord(
          chooseDate: DateTime.now(),
          checkInTime: DateTime.parse(maps[i][checkInTime]),
          checkOutTime: DateTime.parse(maps[i][checkOutTime]),
        );
      });
    }

  }
