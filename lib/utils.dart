import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'model/check_in_out_record.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import 'db/sqlitedb.dart';

const String checkIn = 'Check In';
const String checkOut = 'Check Out';
const String totalHrs = 'Total Hrs';
const String dashBoard = 'Dashboard';
const String download = 'Download';
const String delete = 'Delete Record';
const String checkInOutRecords = 'CheckInOutRecords';
const String nRf = 'No records for the selected date';
const String total = 'Total';
const String checkInOut = 'check_in_out';
const String timeManger = 'TimeManager';
const String dateCommonFormat = 'hh:mm a';
const String sqDB = 'check_in_out.db';
const String checkInTime = 'checkInTime';
const String checkOutTime = 'checkOutTime';
const String androidName = 'QuoteWidget';
const String enter_name = "Enter your name";
const String enter_dob = "Enter your date of birth";
const String enter_data = "Enter your details";
const platform = MethodChannel('com.example.widget/data');
DateTime date =
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

String formatDateTime(DateTime dateTime) {
  return DateFormat('HH:mm:ss').format(dateTime);
}

String currentDateTime() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
  return formattedDate;
}

String formatElapsedTime(Duration time) {
  return '${time.inHours.toString().padLeft(2, '0')}'
      ':${time.inMinutes.remainder(60).toString().padLeft(2, '0')}'
      ':${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
      '.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
}

String calculateTotalHours(List<CheckInOutRecord> records) {
  int totalMinutes = 0;

  for (var period in records) {
    int checkInMinutes =
        period.checkInTime.hour * 60 + period.checkInTime.minute;
    int checkOutMinutes =
        period.checkOutTime.hour * 60 + period.checkOutTime.minute;

    // Calculate the duration in minutes
    int differenceInMinutes = (checkOutMinutes - checkInMinutes).abs();

    // Add to total minutes
    totalMinutes += differenceInMinutes;
  }
  // Convert total minutes to hours
  double totalHours = totalMinutes / 60.0;
  debugPrintStack(label: "Duration:${totalHours.toString().padLeft(2, '0')}");

  return totalHours.toStringAsFixed(2);
}


String calculateDuration(DateTime checkInTime, DateTime checkOutTime) {
  // Convert both times to total minutes since midnight
  int checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
  int checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;

  // Compute the absolute difference in minutes
  int differenceInMinutes = (checkOutMinutes - checkInMinutes).abs();

  // Convert the difference to hours and minutes
  int hours = differenceInMinutes ~/ 60;
  int minutes = differenceInMinutes % 60;

  // Return the result as a formatted string
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

// Group records by check-in date
Map<String, List<CheckInOutRecord>> groupByDate(
    List<CheckInOutRecord> records) {
  Map<String, List<CheckInOutRecord>> groupedRecords = {};

  for (var record in records) {
    String date = DateFormat('yyyy-MM-dd').format(record.checkInTime);

    if (!groupedRecords.containsKey(date)) {
      groupedRecords[date] = [];
    }

    groupedRecords[date]!.add(record);
  }

  return groupedRecords;
}

Future<void> createAndSharePDF(List<CheckInOutRecord> records) async {
  final pdf = pw.Document();

  // Add a page
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Check In/Out Records',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Date', 'Check-In', 'Check-Out', 'Total Hours'],
              data: List.generate(records.length + 1, (index) {
                if (index < records.length) {
                  var record = records[index];
                  return [
                    DateFormat('yyyy-MM-dd').format(record.checkInTime),
                    // Date
                    DateFormat('hh:mm a').format(record.checkInTime),
                    // Check-In
                    DateFormat('hh:mm a').format(record.checkOutTime),
                    // Check-Out
                    calculateDuration(record.checkInTime, record.checkOutTime),
                    // Total Hours
                  ];
                } else {
                  // Add grand total row
                  return [
                    '', // Date
                    '', // Check-In
                    'Grand Total', // Check-Out
                    calculateTotalHours(records), // Total Hours
                  ];
                }
              }),
            ),
          ],
        );
      },
    ),
  );

  // Save the PDF to a file
  final outputFile = await getTemporaryDirectory();
  final outputPath = '${outputFile.path}/check_in_out_records.pdf';
  final file = File(outputPath);
  await file.writeAsBytes(await pdf.save());

  final xFile = XFile(outputPath);

  // Share the PDF file
  await Share.shareXFiles([xFile], text: 'Check In/Out Records PDF');

  // Print the PDF
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}

Future<List<CheckInOutRecord>> getRecord(DateTime selectedDate) async {
  final dbHelper = DatabaseHelper();
  //return await dbHelper.getCheckInOutRecords();
  return await dbHelper.getCheckInOutRecordsByDate(selectedDate);
}

void downloadRecord(DateTime selectedDate) async {
  // Your download logic here
  List<CheckInOutRecord> records = await getRecord(selectedDate);
  createAndSharePDF(records); // Create and share the PDF
}

void deleteAllFromDB() async {
  final dbHelper = DatabaseHelper();
  await dbHelper.deleteAllRecord();
}

void deleteDataByDate(DateTime selectedDate)async{
  final dbHelper = DatabaseHelper();
  await dbHelper.deleteCheckInOutRecordsByDate(selectedDate);
}

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatecounter') {
    int counter = 0;
    await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0)
        .then((value) {
      counter = value!;
      counter++;
    });
    await HomeWidget.saveWidgetData<int>('_counter', counter);
    await HomeWidget.updateWidget(
        //this must the class name used in .Kt
        name: 'HomeScreenWidgetProvider',
        iOSName: 'HomeScreenWidgetProvider');
  }
}

void updateAndroidWidget(DateTime? inTime, DateTime? outTime) {
  HomeWidget.saveWidgetData(checkInTime, inTime);
  HomeWidget.saveWidgetData(checkOutTime, outTime);
  HomeWidget.saveWidgetData(total, calculateDuration(inTime!, outTime!));
  HomeWidget.updateWidget(
    androidName: androidName,
  );
}

Future<void> sendDataToWidget(List<CheckInOutRecord> data) async {
  try {
    await platform.invokeMethod('sendDataToWidget', {'data': data});
  } on PlatformException catch (e) {
    print("Failed to send data: ${e.message}");
  }
}

//Show SnackBar
void showCommonSnackbar(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: duration,
    action: actionLabel != null
        ? SnackBarAction(
            label: actionLabel,
            onPressed: onAction ?? () {},
          )
        : null,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


