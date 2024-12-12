import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:time_manager/components/row_time.dart';
import 'package:time_manager/utils.dart';
import '../model/check_in_out_record.dart';
import '../db/sqlitedb.dart';
import 'package:flutter/services.dart';
import 'circularImageButton.dart';
import 'package:vibration/vibration.dart';

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
  String nativeMessage = '';
  final service = FlutterBackgroundService();
  static const appChannel = MethodChannel('com.background_service');

  @override
  void initState() {
    super.initState();
  }


  void startService() async {
    dynamic value = await appChannel.invokeMethod('startService');
    print("START"+value);
  }

  void stopService() async {
    dynamic value = await appChannel.invokeMethod('stopService');
    print("STOP"+value);
  }

  @override
  void dispose() {
    stopStopwatch();
    super.dispose();
  }

  // Toggle the stopwatch and manage check-in/check-out times
  void toggleStopwatch() {
    if (!widget.stopwatch.isRunning) {
      //startService();
      startStopwatch();
    } else {
      //stopService();
      stopStopwatch();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void startStopwatch() {
    HapticFeedback.heavyImpact();
    widget.stopwatch.start();
    checkInTime = DateTime.now(); // Set current time as check-in time
    checkOutTime = null;
  }

  void stopStopwatch() async {
    Vibration.vibrate();
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
