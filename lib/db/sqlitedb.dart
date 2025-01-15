import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:time_manager/model/userprofile.dart';

import '../utils.dart';
import '../model/check_in_out_record.dart'; // Adjust the import to your model

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

    await db.execute('''
    CREATE TABLE stopwatch_state(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      elapsedTime INTEGER
    )
  ''');
  }

  // Insert or replace user profile data
  Future<int> insertUserProfile(UserProfile userProfile) async {
    final db = await database;
    return await db.insert(
      'user_profile',
      userProfile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert check-in and check-out record
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

  // Get all user profiles
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

  // Get all check-in/out records
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

  // Update user profile
  Future<void> updateUserProfile(UserProfile userProfile) async {
    final db = await database;
    await db.update(
      'user_profile',
      userProfile.toMap(),
      where: 'id = ?',
      whereArgs: [userProfile.id],
    );
  }

  // Update check-in/check-out record
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

  // Delete user profile by id
  Future<void> deleteUserProfile(int id) async {
    final db = await database;
    await db.delete(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete check-in/check-out record by id
  Future<void> deleteCheckInOutRecord(int id) async {
    final db = await database;
    await db.delete(
      checkInOut,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all check-in/check-out records
  Future<void> deleteAllRecord() async {
    final db = await database;
    await db.delete(checkInOut);
  }

  // Delete check-in/check-out records for a specific date
  Future<void> deleteCheckInOutRecordsByDate(DateTime date) async {
    final db = await database;
    await db.delete(
      checkInOut,
      where: 'date(checkInTime) = ?',
      whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
    );
  }

  // Get check-in/check-out records by date
  Future<List<CheckInOutRecord>> getCheckInOutRecordsByDate(
      DateTime date) async {
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

  // Check if table is empty
  Future<bool> isTableDataEmpty(String tableName) async {
    final db = await database;
    final result =
        await db.query(tableName, limit: 1); // Get one record to check
    return result
        .isEmpty; // Returns true if there are no rows in the table, false if there are any rows
  }

  // Insert or update stopwatch elapsed time
  Future<void> saveStopwatchState(int elapsedTimeInMillis) async {
    final db = await database;

    // Check if the stopwatch state already exists
    var result = await db.query('stopwatch_state');
    if (result.isEmpty) {
      // Insert new record
      await db.insert(
        'stopwatch_state',
        {'elapsedTime': elapsedTimeInMillis},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Update existing record
      await db.update(
        'stopwatch_state',
        {'elapsedTime': elapsedTimeInMillis},
        where: 'id = ?',
        whereArgs: [1], // We assume the record is unique (id=1)
      );
    }
  }

  // Retrieve stopwatch elapsed time
  Future<int> getStopwatchState() async {
    final db = await database;
    var result = await db.query('stopwatch_state', where: 'id = ?', whereArgs: [1]);

    if (result.isNotEmpty) {
      return result[0]['elapsedTime'] as int; // Explicitly cast to int
    } else {
      return 0; // Return 0 if no state is stored
    }
  }
}
