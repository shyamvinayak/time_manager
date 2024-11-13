import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Routes/routes.dart';
import '../assets.dart';
import '../utils.dart';
import 'circularIconButton.dart';

class RowTime extends StatelessWidget {
  final DateTime? checkInTime; // Variable to store check-in time
  final DateTime? checkOutTime; // Variable to store check-out time
  bool isDashboard;

  RowTime(
      {super.key,
      required this.checkInTime,
      required this.checkOutTime,
      this.isDashboard = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircularIconButton(
            icon: Assets.check_In,
            currentTime: checkInTime != null
                ? DateFormat(dateCommonFormat).format(checkInTime!)
                : '-',
            label: checkIn),
        CircularIconButton(
            icon: Assets.check_Out,
            currentTime: checkOutTime != null
                ? DateFormat(dateCommonFormat).format(checkOutTime!)
                : '-',
            label: checkOut),
        CircularIconButton(
            icon: Assets.total_hrs,
            currentTime: checkOutTime != null
                ? calculateDuration(checkInTime!, checkOutTime!)
                : '-',
            onPressed: () {
              isDashboard?Navigator.pushNamed(context, AppRoutes.detailScreen):null;
            },
            label: totalHrs)
      ],
    );
  }
}
