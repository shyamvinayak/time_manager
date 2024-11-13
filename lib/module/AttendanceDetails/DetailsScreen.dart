import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_manager/components/row_time.dart';

import '../../utils.dart';
import '../../db/check_in_out_record.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool hasData = false;
  late Future<List<CheckInOutRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = getRecord();
  }

  void handleClick(String value) {
    switch (value) {
      case download:
        downloadRecord();
        break;
      case delete:
        deleteRecord();
        break;
    }
  }

  void deleteRecord() async {
    deleteAllFromDB();
    setState(() {
      _recordsFuture = getRecord();
    });
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
                List<CheckInOutRecord> records = snapshot.data!;
                Map<String, List<CheckInOutRecord>> groupedRecords =
                    groupByDate(records);
                List<String> groupedKeys = groupedRecords.keys.toList();
                return Expanded(
                  child: ListView.builder(
                    itemCount: groupedKeys.length,
                    itemBuilder: (context, index) {
                      String date = groupedKeys[index];
                      List<CheckInOutRecord> dailyRecords =
                          groupedRecords[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(dailyRecords[index].chooseDate),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w300),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ...dailyRecords.map(
                            (record) => RowTime(
                              checkInTime: record.checkInTime,
                              checkOutTime: record.checkOutTime,
                              isDashboard: false,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            title: const Text(
                              total,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              calculateTotalHours(dailyRecords),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
