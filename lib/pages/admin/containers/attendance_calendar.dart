// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/utils/tiles.dart';
import 'package:the_project/services/firestore_service.dart';

class AttendanceCalendar extends StatefulWidget {
  const AttendanceCalendar({super.key});

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(10)
        ),
        height: 400,
        width: 500,
        child: TableCalendar(
        firstDay: DateTime.utc(2025, 5, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            showDialog(
              context: context,
              builder: (context) {
                return BatchSelectBox(
                  selectedDay: selectedDay,
                );
              }
            );
          },
      ),
    );
  }
}

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
                future: firestoreService.getBatchesForDate(selectedDay),
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