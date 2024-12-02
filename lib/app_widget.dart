import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/model/itemsProvider.dart';

import 'components/row_time.dart';


class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Consumer<ItemsProvider>(
          builder: (context, itemsProvider, child) {
            return FutureBuilder(
              future: itemsProvider.fetchItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    itemCount: itemsProvider.items.length,
                    itemBuilder: (context, index) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            ...itemsProvider.items.map((record) {
                              return RowTime(
                                checkInTime: record.checkInTime,
                                checkOutTime: record.checkOutTime,
                                isDashboard: false,
                              );
                            }),
                          ]);
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
