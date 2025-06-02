// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/data/student.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/pages/admin/utils/student_form.dart';
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
  void toggleMarked() async {
    setState(() {
      widget.batch.marked = !widget.batch.marked;
    });

    if (widget.batch.marked) {
      await firestoreService.saveAttendanceForBatch([widget.batch], widget.selectedDate);
    }
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
            onPressed: toggleMarked,
            text: widget.batch.marked? "Un-mark" : "Mark",
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  void _addStudent() {
    final TextEditingController newStudentName = TextEditingController();

    showDialog(context: context, builder: (builder) {
      return StudentForm(
        nameController: newStudentName,
        submitOnPressed: () async {
          Student newStudent = Student(name: newStudentName.text);
          await firestoreService.addStudentToBatchOnDay(widget.weekday, widget.batch, newStudent);
          setState(() {
            widget.batch.students.add(newStudent);
          });
          newStudentName.clear();
          Navigator.of(context).pop();
        },
      );
    });
  }

  void _editStudentName(Student student) {
    final TextEditingController editController = TextEditingController(text: student.name);

    showDialog(
      context: context,
      builder: (builder) {
        return StudentForm(
          nameController: editController,
          submitOnPressed: () async {
            final oldName = student.name;
            final newName = editController.text.trim();

            if (newName.isNotEmpty && newName != oldName) {
              await firestoreService.deleteStudentFromBatchInDay(widget.weekday, widget.batch, student);

              final updatedStudent = Student(name: newName);
              await firestoreService.addStudentToBatchOnDay(widget.weekday, widget.batch, updatedStudent);

              final snapshots = await firestoreService.attendance.get();

              for (final doc in snapshots.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final List<dynamic> batches = data['batches'] ?? [];

                bool changed = false;

                final updatedBatches = batches.map((b) {
                  if (b['name'] == widget.batch.name) {
                    final List<dynamic> students = b['students'] ?? [];

                    final updatedStudents = students.map((s) {
                      if (s['name'] == oldName) {
                        changed = true;
                        return {
                          'name': newName,
                          'present': s['present'],
                        };
                      }
                      return s;
                    }).toList();

                    return {
                      ...b,
                      'students': updatedStudents,
                    };
                  }
                  return b;
                }).toList();

                if (changed) {
                  await firestoreService.attendance.doc(doc.id).update({'batches': updatedBatches});
                }
              }

              setState(() {
                final index = widget.batch.students.indexWhere((s) => s.name == oldName);
                if (index != -1) {
                  widget.batch.students[index] = updatedStudent;
                }
              });
            }

            Navigator.of(context).pop();
          }
        );
      }
    );
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
          // Student Tiles View
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.batch.students.length,
              itemBuilder: (context, index) {
                final student = widget.batch.students[index];
                return EditStudentTile(
                  editModeBatch: editMode,
                  student: student,
                  removeStudentFunc: () => _removeStudent(student),
                  editStudentFunc: () => _editStudentName(student),
                );
              },
            )
          ),
          // Add Student Button
          editMode? IconButton(
            onPressed: _addStudent, 
            icon: Icon(Icons.add)
          ) : SizedBox.shrink(),
          editMode? Divider() : SizedBox.shrink(),
          // Delete Batch Button
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
  final void Function()? editStudentFunc;

  const EditStudentTile({
    super.key, 
    required this.student, 
    required this.editModeBatch, 
    required this.removeStudentFunc,
    required this.editStudentFunc
  });

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
            editModeBatch? Positioned(
              top: -5, 
              right: 0, 
              child: IconButton(
                onPressed: editStudentFunc, 
                icon: Icon(Icons.text_fields),
                )
              )
              : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
