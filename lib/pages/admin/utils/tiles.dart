// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/data/student.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/services/firestore_service.dart';

// Batch Tile for marking attendance
class BatchTile extends StatefulWidget {
  final Batch batch;
  final DateTime selectedDate;

  const BatchTile({super.key, required this.batch, required this.selectedDate});

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
          MyButton(
            onPressed: widget.batch.marked? null : submitAttendance,
            text: "Submit",
          )
        ],
      ),
    );
  }
}

// Sub-tile of above Batch Tile of students
class StudentTile extends StatelessWidget {
  final Student student;
  final bool isPresent;
  final VoidCallback? onToggle;
  final bool marked;

  const StudentTile({super.key, required this.student, required this.isPresent, this.onToggle, required this.marked});

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
              marked: marked,
              isPresent: isPresent,
              onToggle: onToggle,
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------- //

// Batch Tile used in view batches that can be edited
class EditBatchTile extends StatefulWidget {
  final String weekday;
  final Batch batch;
  final void Function()? removeBatchFunc;

  const EditBatchTile({super.key, required this.batch, required this.removeBatchFunc, required this.weekday});

  @override
  State<EditBatchTile> createState() => _EditBatchTileState();
}
class _EditBatchTileState extends State<EditBatchTile> {
  final FirestoreService firestoreService = FirestoreService();
  bool editMode = false;

  void _toggleEditMode() {
    if (!editMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Warning!! Entering Edit Mode! All actions are irreversible!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
    setState(() {
      editMode = !editMode;
    });
  }

  void _removeStudent(Student student) async {
    await firestoreService.deleteStudentFromBatchInDay(widget.weekday, widget.batch, student);

    setState(() {
      widget.batch.students.removeWhere((s) => s.name == student.name);
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
          Stack(
            children: [
              editMode? Positioned(
                left: 0,
                child: IconButton(
                  onPressed: () {}, 
                  icon: Icon(Icons.text_fields)
                ),
              ) : SizedBox.shrink(),
              Center(
                child: Column(
                  children: [
                    Text(widget.batch.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(widget.batch.timing, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: _toggleEditMode,
                  icon: Icon(
                    editMode? Icons.edit_off : Icons.edit
                  )
                )
              )
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.batch.students.length,
              itemBuilder: (context, index) {
                final student = widget.batch.students[index];
                return EditStudentTile(
                  editModeBatch: editMode,
                  student: student,
                  removeStudentFunc: () {
                    _removeStudent(student);
                  },
                );
              },
            )
          ),
          editMode? Divider() : SizedBox.shrink(),
          editMode? MyButton(text: "Delete Batch", onPressed: widget.removeBatchFunc) : SizedBox.shrink()
        ],
      ),
    );
  }
}

// Sub-tile of above Edit Batch Tile of students
class EditStudentTile extends StatelessWidget {
  final Student student;
  final bool editModeBatch;
  final void Function()? removeStudentFunc;

  const EditStudentTile({super.key, required this.student, required this.editModeBatch, required this.removeStudentFunc});

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
        child: Stack(
          children: [
            editModeBatch? Positioned(top: -5, left: 0, child: IconButton(onPressed: removeStudentFunc, icon: Icon(Icons.close), color: Colors.red,))
              : SizedBox.shrink(),
            Center(child: Text(student.name)),
            editModeBatch? Positioned(top: -5, right: 0, child: IconButton(onPressed: () {}, icon: Icon(Icons.text_fields),))
              : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
