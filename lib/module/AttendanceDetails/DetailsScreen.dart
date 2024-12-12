import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/components/row_time.dart';
import 'package:time_manager/date_change_provider.dart';
import 'package:time_manager/module/AttendanceDetails/SingleListItems.dart';

import '../../utils.dart';
import '../../model/check_in_out_record.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool hasData = false;
  final _now = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  late EasyDatePickerController _controller;

  late Future<List<CheckInOutRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _controller = EasyDatePickerController();
    Provider.of<DatePickerModel>(context, listen: false)
        .setSelectedDate(DateTime.now());
    _recordsFuture = getRecord(_selectedDate);
  }

  void handleClick(String value) {
    switch (value) {
      case download:
        downloadRecord(_selectedDate);
        break;
      case delete:
        deleteRecord();
        break;
    }
  }

  void deleteRecord() async {
    deleteDataByDate(_selectedDate);
    setState(() {
      _recordsFuture = getRecord(_selectedDate);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          checkInOutRecords,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: [
             EasyDateTimeLinePicker(
               controller: _controller,
               firstDate: DateTime(DateTime.now().year, 1, 1),
               lastDate: DateTime.now(),
               focusedDate: _selectedDate,
               onDateChange: (date) {
                 setState(
                       () {
                     _selectedDate = date;
                     Provider.of<DatePickerModel>(context, listen: false)
                         .setSelectedDate(_selectedDate);
                   },
                 );
               },
             ),
             const SizedBox(height: 15),
             Expanded(
               child: Padding(
                 padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                 child: FutureBuilder<List<CheckInOutRecord>>(
                   future: _recordsFuture,
                   builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return const Center(child: CircularProgressIndicator());
                     } else if (snapshot.hasError) {
                       return Center(child: Text('Error: ${snapshot.error}'));
                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         setState(() {
                           hasData = false;
                         });
                       });
                       return const Center(child: Text(nRf));
                     } else {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         setState(() {
                           hasData = true;
                         });
                       });
                       List<CheckInOutRecord> records = snapshot.data!.toList();
                       Map<String, List<CheckInOutRecord>> groupedRecords =
                       groupByDate(records);
               
                       return Consumer<DatePickerModel>(
                         builder: (context, value, child) {
                           List<CheckInOutRecord> selectedDateRecords = groupedRecords[
                           DateFormat('yyyy-MM-dd')
                               .format(value.selectedDate)] ??
                               [];
               
                           String totalHours =
                           calculateTotalHours(selectedDateRecords);
               
                           return Column(
                             children: [
                               selectedDateRecords.isEmpty
                                   ? Container()
                                   : Row(
                                 mainAxisAlignment:
                                 MainAxisAlignment.spaceAround,
                                 children: [
                                   TextButton(
                                     child: const Text(download),
                                     onPressed: () {
                                       handleClick(download);
                                     },
                                   ),
                                   const SizedBox(width: 10),
                                   TextButton(
                                     child: const Text(delete),
                                     onPressed: () {
                                       handleClick(delete);
                                     },
                                   ),
                                 ],
                               ),
                               selectedDateRecords.isEmpty
                                   ? const Expanded(
                                 child: Center(
                                   child: Text(nRf),
                                 ),
                               )
                                   : Expanded(
                                 child: ListView.builder(
                                   itemCount: selectedDateRecords.length,
                                   itemBuilder: (context, index) {
                                     CheckInOutRecord record =
                                     selectedDateRecords[index];
                                     return Singlelistitems(
                                       CheckInOutRecord(
                                         checkInTime: record.checkInTime,
                                         checkOutTime: record.checkOutTime,
                                         chooseDate: _selectedDate,
                                       ),
                                     );
                                   },
                                 ),
                               ),
                             ],
                           );
                         },
                       );
                     }
                   },
                 ),
               ),
             ),
           ],
        ),
      ),
    );
  }
}
