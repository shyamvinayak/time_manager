import 'package:flutter/material.dart';
import 'package:time_manager/db/check_in_out_record.dart';
import 'db/sqlitedb.dart';

class ItemsProvider with ChangeNotifier {
  List<CheckInOutRecord> _items = [];

  List<CheckInOutRecord> get items => _items;

  Future<void> fetchItems() async {
    final data = await DatabaseHelper().getCheckInOutRecords();
    _items = data;
    notifyListeners();
  }
}