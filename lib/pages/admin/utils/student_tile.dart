// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/student.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';

class StudentTile extends StatelessWidget {
  final Student student;
  final bool isPresent;
  final VoidCallback onToggle;

  StudentTile({super.key, required this.student, required this.isPresent, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 40,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(student.name),
            AttendanceToggleButton(
              isPresent: isPresent,
              onToggle: onToggle,
            )
          ],
        ),
      ),
    );
  }
}