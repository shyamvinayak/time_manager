import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_manager/components/dashboardBody.dart';
import 'package:time_manager/components/dashboardHeader.dart';
import 'package:time_manager/utils.dart';


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


  @override
  void initState() {
    super.initState();
    updateElapsedTime();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
         updateElapsedTime(); // Update elapsed time for UI
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
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
            DashboardHeader(
                elapsedTimeString: elapsedTimeString),
            DashboardBody(stopwatch:stopwatch),
          ],
        ),
      ),
    );
  }

  void updateElapsedTime() {
    elapsedTime = stopwatch.elapsed;
    elapsedTimeString = formatElapsedTime(elapsedTime);
  }
}
