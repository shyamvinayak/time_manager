import 'package:flutter/material.dart';
import 'package:time_manager/model/check_in_out_record.dart';
import '../db/sqlitedb.dart';

class ItemsProvider with ChangeNotifier {
  List<CheckInOutRecord> _items = [];

  List<CheckInOutRecord> get items => _items;

  final Stopwatch _stopwatch = Stopwatch();
  int _elapsedMilliseconds = 0;  // Store elapsed time

  Stopwatch get stopwatch => _stopwatch;

  int get elapsedMilliseconds => _elapsedMilliseconds;

  Future<void> fetchItems() async {
    final data = await DatabaseHelper().getCheckInOutRecords();
    _items = data;
    notifyListeners();
  }

  // Start the stopwatch
  void startStopwatch() {
    _stopwatch.start();
    notifyListeners();
  }

  // Stop the stopwatch
  void stopStopwatch() {
    _stopwatch.stop();
    _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;  // Store the time when stopped
    notifyListeners();
  }

  // Reset the stopwatch
  void resetStopwatch() {
    _stopwatch.reset();
    _elapsedMilliseconds = 0;  // Reset stored time
    notifyListeners();
  }

  // Load saved state from the database
  Future<void> loadStopwatchState() async {
    final int savedTime = await DatabaseHelper().getStopwatchState();  // Fetch from SQLite
    _elapsedMilliseconds = savedTime;

    // Reset stopwatch and manually set the time to the saved time
    _stopwatch.reset();
    _stopwatch.start();

    // Instead of add(), store the time manually and notify listeners
    notifyListeners();
  }


  // Save the current state to the database
  Future<void> saveStopwatchState() async {
    final int elapsedTime = _stopwatch.elapsedMilliseconds;
    await DatabaseHelper().saveStopwatchState(elapsedTime);  // Save to SQLite
    notifyListeners();
  }
}