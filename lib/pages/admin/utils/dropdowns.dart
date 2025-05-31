// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class DayDropdown extends StatelessWidget {

  String selectedDay;
  void Function(String?)? onChanged;

  DayDropdown({super.key, this.selectedDay = "", required this.onChanged});

  final List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 10,),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text("Day"),
          value: selectedDay.isNotEmpty ? selectedDay : null,
          onChanged: onChanged,
          items: weekdays.map((day) {
            return DropdownMenuItem<String>(
              value: day,
              child: Text(day),
            );
          }).toList()
        ),
      ),
    );
  }
}