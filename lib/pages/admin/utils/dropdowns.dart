import 'package:flutter/material.dart';

class DayDropdown extends StatefulWidget {

  DayDropdown({super.key});

  @override
  State<DayDropdown> createState() => _DayDropdownState();
}

class _DayDropdownState extends State<DayDropdown> {
  
  String selectedDay = "";
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
          onChanged: (String? newValue) => {
            setState(() {
              selectedDay = newValue!;
            })
          },
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