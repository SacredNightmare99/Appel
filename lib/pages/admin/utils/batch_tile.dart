// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/pages/admin/utils/student_tile.dart';

class BatchTile extends StatefulWidget {

  bool marked;
  Batch batch;

  BatchTile({super.key, this.marked = false, required this.batch});

  @override
  State<BatchTile> createState() => _BatchTileState();
}

class _BatchTileState extends State<BatchTile> {

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void resetAttendance() {
    for (var student in widget.batch.students) {
      student.attendance[selectedDate.toIso8601String()] = false;
    }
    setState(() {});
  }

  void markAllPresent() {
    for (var student in widget.batch.students) {
      student.attendance[selectedDate.toIso8601String()] = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: markAllPresent, icon: Icon(Icons.check)),
              Column(
                children: [
                  Text(widget.batch.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(widget.batch.timing, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              IconButton(onPressed:resetAttendance, icon: Icon(Icons.close))
            ],
          ),
          Divider(),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.batch.students.length,
              itemBuilder: (context, index) {
                final student = widget.batch.students[index];
                bool isPresent = student.attendance[selectedDate.toIso8601String()] ?? false;

                return StudentTile(
                  student: student,
                  isPresent: isPresent,
                  onToggle: () {
                    setState(() {
                      student.attendance[selectedDate.toIso8601String()] = !isPresent;
                    });
                  }
                );
              },
            )
          ),
          Divider(),

          SubmitButton(
            onPressed: () {},
          )
        ],
      ),
    );
  }
}