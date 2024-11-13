import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_manager/components/row_time.dart';
import 'package:time_manager/utils.dart';
import '../db/check_in_out_record.dart';
import '../db/sqlitedb.dart';
import 'circularImageButton.dart';

class DashboardBody extends StatefulWidget {
  final Stopwatch stopwatch;

  const DashboardBody({super.key, required this.stopwatch});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  final dbHelper = DatabaseHelper();
  DateTime? checkInTime; // Variable to store check-in time
  DateTime? checkOutTime; // Variable to store check-out time

  @override
  void initState() {
    super.initState();
  }

  // Toggle the stopwatch and manage check-in/check-out times
  void toggleStopwatch() {
    if (!widget.stopwatch.isRunning) {
      startStopwatch();
    } else {
      stopStopwatch();
    }
  }

  void startStopwatch() {
    widget.stopwatch.start();
    checkInTime = DateTime.now(); // Set current time as check-in time
    checkOutTime = null;
  }

  void stopStopwatch() async {
    widget.stopwatch.stop();
    checkOutTime = DateTime.now(); // Set current time as check-out time
    // Save the check-in/out record to db
    if (checkInTime != null && checkOutTime != null) {
      await dbHelper.insertCheckInOutRecord(
        CheckInOutRecord(
          chooseDate: DateTime.now(),
          checkInTime: checkInTime!,
          checkOutTime: checkOutTime!,
        ),
      );
      updateAndroidWidget(checkInTime, checkOutTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularImageButton(
          onPressed: toggleStopwatch,
          buttonColor: widget.stopwatch.isRunning
              ? [Colors.red, Colors.redAccent]
              : [Colors.black26, Colors.lightBlue],
          labelText: widget.stopwatch.isRunning ? checkOut : checkIn,
        ),
        const SizedBox(height: 20.0),
        RowTime(checkInTime: checkInTime, checkOutTime: checkOutTime)
      ],
    );
  }
}
