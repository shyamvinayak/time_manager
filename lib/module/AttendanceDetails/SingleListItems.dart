import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_manager/model/check_in_out_record.dart';
import 'package:time_manager/utils.dart';

import '../../assets.dart';
import '../../components/circularIconButton.dart';

class Singlelistitems extends StatelessWidget {
  CheckInOutRecord records;

  Singlelistitems(this.records, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(left:10, right: 10, bottom: 10),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Set the border radius here
        ),
        color: const Color(0xff523a7f),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.timelapse, size: 30,color: Colors.white,),
                title: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                        children: [
                          Text(
                            DateFormat(dateCommonFormat).format(records.checkInTime),
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 15),
                          ),
                          Text(
                            checkIn,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodySmall!.copyWith(color: Colors.white60,fontWeight: FontWeight.w400,fontSize: 13),
                          )
                        ],
                      ),
                      const SizedBox(width: 5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                        children: [
                          Text(
                            DateFormat(dateCommonFormat).format(records.checkOutTime),
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 15),
                          ),
                          Text(
                            checkOut,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodySmall!.copyWith(color: Colors.white60,fontWeight: FontWeight.w400,fontSize: 13),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      calculateDuration(records.checkInTime, records.checkOutTime),
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall!.copyWith(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16),
                    ),
                    Text(
                      totalHrs,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall!.copyWith(color: Colors.white60,fontWeight: FontWeight.w500,fontSize: 12),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),


      ),
    );
  }
}

