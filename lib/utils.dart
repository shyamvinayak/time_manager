import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'db/check_in_out_record.dart';

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
const String nRf = 'No records found.';
const String total = 'Total';
const String checkInOut = 'check_in_out';
const String timeManger = 'TimeManager';
const String dateCommonFormat = 'hh:mm a';
const String sqDB = 'check_in_out.db';
const String checkInTime = 'checkInTime';
const String checkOutTime = 'checkOutTime';
const String androidName = 'QuoteWidget';
const platform = MethodChannel('com.example.widget/data');

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
  //Duration totalDuration = const Duration();
  int checkInMinutes = 0;
  int checkOutMinutes = 0;
  int differenceInMinutes = 0;
  for (var record in records) {
    //totalDuration += record.checkOutTime.difference(record.checkInTime);\
    checkInMinutes = record.checkInTime.hour * 60 + record.checkInTime.minute;
    checkOutMinutes =
        record.checkOutTime.hour * 60 + record.checkOutTime.minute;
    differenceInMinutes = (checkOutMinutes - checkInMinutes).abs();
  }
// Convert the difference to hours and minutes
  int hours = differenceInMinutes ~/ 60;
  int minutes = differenceInMinutes % 60;

  /*int hours = totalDuration.inHours;
  int minutes = totalDuration.inMinutes % 60;

  if (totalDuration.inMinutes == 0 && totalDuration.inSeconds > 0) {
    minutes = 1;
  }*/

  // return totalDuration.toString().split('.').first.padLeft(8, "0");
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(
      2, '0')}';
}

/*String calculateDuration(DateTime checkInTime, DateTime checkOutTime) {

  Duration duration = checkOutTime.difference(checkInTime);

  // Get hours and minutes from the duration
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;

  debugPrintStack(label: "Duration:--${duration.inDays}");

 */
/* // Ensure duration shows 00:00 if the times are the same
  if (hours == 0 && minutes == 0 && duration.inSeconds == 0) {
    return '00:00';
  }

  // If duration is less than a minute but greater than zero, show as 00:01
  if (hours == 0 && minutes == 0 && duration.inSeconds > 0) {
    minutes = 1;
  }*/
/*


  // Return a formatted string with hours and minutes only
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}*/

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
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(
      2, '0')}';
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
                if(index< records.length){
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

Future<List<CheckInOutRecord>> getRecord() async {
  final dbHelper = DatabaseHelper();
  return await dbHelper.getCheckInOutRecords();
}

void downloadRecord() async {
  // Your download logic here
  List<CheckInOutRecord> records = await getRecord();
  createAndSharePDF(records); // Create and share the PDF
}

void deleteAllFromDB() async {
  final dbHelper = DatabaseHelper();
  await dbHelper.deleteAllRecord();
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

Future<void> sendDataToWidget(List<CheckInOutRecord>data) async {
  try {
    await platform.invokeMethod('sendDataToWidget', {'data': data});
  } on PlatformException catch (e) {
    print("Failed to send data: ${e.message}");
  }
}

