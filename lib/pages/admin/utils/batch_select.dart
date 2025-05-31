// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/utils/batch_tile.dart';
import 'package:the_project/services/firestore_service.dart';

class BatchSelectBox extends StatelessWidget {
  
  DateTime selectedDay;
  BatchSelectBox({super.key, required this.selectedDay});

  final FirestoreService firestoreService = FirestoreService();

  String getFormatedDate() {
    String day = selectedDay.day.toString();
    String month = DateFormat('MMMM').format(selectedDay);
    String year = selectedDay.year.toString();
    String weekday = DateFormat('EEEE').format(selectedDay);
    String suffix = getDaySuffix(selectedDay.day);

    return '$weekday, $day$suffix $month, $year';
  }
  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day%10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      content: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(getFormatedDate(), style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),

            Expanded(
              child: FutureBuilder<List<Batch>>(
                future: firestoreService.getBatchesForDay(selectedDay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No batches found."));
                  }

                  final batches = snapshot.data!;

                  return SingleChildScrollView(
                    child: Container(
                      width: double.maxFinite,
                      child: Center(
                        child: Wrap(
                          runSpacing: 15,
                          spacing: 15,
                          children: batches.map((batch) => BatchTile(batch: batch, selectedDate: selectedDay)).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}