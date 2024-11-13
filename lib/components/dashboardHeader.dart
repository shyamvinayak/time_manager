import 'package:flutter/material.dart';
import 'package:time_manager/utils.dart';

class DashboardHeader extends StatelessWidget {
  final String elapsedTimeString;

  const DashboardHeader({
    super.key,
    required this.elapsedTimeString,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            elapsedTimeString,
            style: const TextStyle(fontSize: 48,fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            currentDateTime(),
            style:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
