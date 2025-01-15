import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/assets.dart';
import 'package:time_manager/model/itemsProvider.dart';
import 'package:time_manager/utils.dart';

import 'Routes/routes.dart';
import 'db/sqlitedb.dart';
import 'model/userprofile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the home screen after a delay
    Future.delayed(const Duration(seconds: 3), () async {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      final stopwatchProvider =
          Provider.of<ItemsProvider>(context, listen: false);
      await stopwatchProvider
          .loadStopwatchState(); // Load the saved stopwatch state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired splash screen color
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(Assets.splash),
          const SizedBox(
            height: 10,
          ),
          const Text(
            timeManger,
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 30,
                color: Colors.redAccent),
          ),
        ],
      )),
    );
  }
}
