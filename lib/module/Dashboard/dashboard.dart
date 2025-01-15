import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/components/dashboardBody.dart';
import 'package:time_manager/components/dashboardHeader.dart';
import 'package:time_manager/utils.dart';

import '../../db/sqlitedb.dart';
import '../../model/itemsProvider.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Timer timer;
  late Duration elapsedTime;
  late String elapsedTimeString;
  final Stopwatch stopwatch = Stopwatch();
  late final stopwatchProvider;

  @override
  void initState() {
    super.initState();
    stopwatchProvider = Provider.of<ItemsProvider>(context, listen: false);
    stopwatchProvider.loadStopwatchState;
    updateElapsedTime();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    stopwatchProvider.saveStopwatchState();
    if (!stopwatch.isRunning) {
      stopwatch.stop();
    }
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          dashBoard,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true, // Centers the text horizontally
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DashboardHeader(elapsedTimeString: elapsedTimeString),
            DashboardBody(stopwatch: stopwatch),
          ],
        ),
      ),
    );
  }

  void updateElapsedTime() {
    elapsedTime = stopwatch.elapsed;
    elapsedTimeString = formatElapsedTime(elapsedTime);
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        updateElapsedTime(); // Update elapsed time for UI
      });
    });
  }
}
