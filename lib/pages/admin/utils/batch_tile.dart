// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/pages/admin/utils/student_tile.dart';
import 'package:the_project/services/firestore_service.dart';

class BatchTile extends StatefulWidget {

  
  final Batch batch;
  final DateTime selectedDate;
  

  BatchTile({super.key, required this.batch, required this.selectedDate});

  @override
  State<BatchTile> createState() => _BatchTileState();
}

class _BatchTileState extends State<BatchTile> {

  final FirestoreService firestoreService = FirestoreService();

  void resetAttendance() {
    for (var student in widget.batch.students) {
      student.present = false;
    }
    setState(() {});
  }

  void markAllPresent() {
    for (var student in widget.batch.students) {
      student.present = true;
    }
    setState(() {});
  }

  void submitAttendance() async {
    
    await firestoreService.saveAttendanceForBatch([widget.batch], widget.selectedDate);

    setState(() {
      widget.batch.marked = true;
    });
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
              IconButton(onPressed: widget.batch.marked? null : markAllPresent, icon: Icon(Icons.check, color: widget.batch.marked? null : Colors.green,)),
              Column(
                children: [
                  Text(widget.batch.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(widget.batch.timing, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              IconButton(onPressed: widget.batch.marked? null : resetAttendance, icon: Icon(Icons.close, color: widget.batch.marked? null : Colors.red,))
            ],
          ),
          Divider(),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.batch.students.length,
              itemBuilder: (context, index) {
                final student = widget.batch.students[index];
                bool isPresent = student.present;

                return StudentTile(
                  marked: widget.batch.marked,
                  student: student,
                  isPresent: isPresent,
                  onToggle: widget.batch.marked
                    ? null
                    : () => {
                    setState(() {
                      student.present = !isPresent;
                    })
                  },
                );
              },
            )
          ),
          Divider(),

          // Submit Button
          SubmitButton(
            onPressed: widget.batch.marked? null : submitAttendance,
          )
        ],
      ),
    );
  }
}