import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/components/row_time.dart';
import 'package:time_manager/date_change_provider.dart';

import '../../utils.dart';
import '../../model/check_in_out_record.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool hasData = false;
  DateTime _selectedDate = DateTime.now();
  late final EasyDatePickerController _controller;
  late Future<List<CheckInOutRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = getRecord(_selectedDate);
    _controller = EasyDatePickerController();
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
        backgroundColor: Colors.blue,
        title: const Text(
          checkInOutRecords,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color of the back button
        ),
        actions: hasData
            ? [
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    List<String> choices = <String>[];
                    choices.add(download);
                    choices.add(delete);
                    return choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ]
            : [],
        //automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                        EasyDateTimeLinePicker(
                          controller: _controller,
                          firstDate: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            1,
                          ),
                          lastDate: DateTime.now(),
                          focusedDate: value.selectedDate,
                          onDateChange: (date) {
                            setState(() {
                              _selectedDate = date;
                              value.setSelectedDate(_selectedDate);
                            });
                          },
                        ),
                        const SizedBox(height: 15),
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
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RowTime(
                                          checkInTime: record.checkInTime,
                                          checkOutTime: record.checkOutTime,
                                          isDashboard: false,
                                        ),
                                        const SizedBox(height: 10),
                                        if (index ==
                                            selectedDateRecords.length - 1)
                                          ListTile(
                                            title: const Text(
                                              total,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: Text(
                                              calculateTotalHours(
                                                  selectedDateRecords),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
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
    );
  }
}
