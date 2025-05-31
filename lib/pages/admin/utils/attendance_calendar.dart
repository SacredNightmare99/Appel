// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_project/pages/admin/utils/batch_select.dart';

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
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
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