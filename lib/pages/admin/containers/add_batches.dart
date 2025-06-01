import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/data/student.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/pages/admin/utils/dropdowns.dart';
import 'package:the_project/pages/admin/utils/form_fields.dart';
import 'package:the_project/pages/admin/utils/student_form.dart';
import 'package:the_project/services/firestore_service.dart';

class AddBatchContainer extends StatefulWidget {
  const AddBatchContainer({super.key});

  @override
  State<AddBatchContainer> createState() => _AddBatchContainerState();
}
class _AddBatchContainerState extends State<AddBatchContainer> {
  final TextEditingController batchNameController = TextEditingController();
  final TextEditingController batchTimingController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  String selectedDay = "";
  List<Student> students = [];

  void _addBatch(String day, String name, String timing, List<Student> students) async {
    
    Batch newBatch = Batch(name: name, timing: timing, students: students);

    await firestoreService.saveBatchForDay(day, [newBatch]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Batch Added Successfully!"),
        duration: Duration(seconds: 2),
      )
    );

    setState(() {
      selectedDay = "";
      batchNameController.clear();
      batchTimingController.clear();
      students.clear();
    });
  }

  void _onSubmit() {
    
    if (batchNameController.text.isNotEmpty && batchTimingController.text.isNotEmpty && selectedDay.isNotEmpty && students.isNotEmpty) {
      _addBatch(selectedDay, batchNameController.text, batchTimingController.text, students);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 600,
      padding: EdgeInsets.only(top: 4, right: 10, left: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(child: Text("Add Daywise Batches",)),
          Divider(),
          DayDropdown(selectedDay: selectedDay, onChanged: (value) => {
            setState(() {
              selectedDay = value!;
            })
          },),
          SizedBox(height: 5,),
          BatchField(hint: "Batch Name", controller: batchNameController,),
          SizedBox(height: 5,),
          BatchField(hint: "Timing", controller: batchTimingController),
          SizedBox(height: 5,),
          AddStudentContainer(students: students,),
          SizedBox(height: 5,),
          MyButton(onPressed: _onSubmit, text: "Submit",)
        ],
      ),
    );
  }
}

class AddStudentContainer extends StatefulWidget {

  final List<Student> students;

  const AddStudentContainer({super.key, required this.students});

  @override
  State<AddStudentContainer> createState() => _AddStudentContainerState();
}
class _AddStudentContainerState extends State<AddStudentContainer> {
  final TextEditingController studentName = TextEditingController();
  
  void _addStudent(String name) {
    
    Student newStudent = Student(name: name);
    
    setState(() {
      widget.students.add(newStudent);
    });
    studentName.clear();
  }

  void _removeStudent(int index) {
    setState(() {
      widget.students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 550,
      padding: EdgeInsets.only(top: 1, left: 6, right: 6),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Center(child: Text("Add Students")),
              Positioned(
                top: -10,
                right: 0,
                child: IconButton(onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StudentForm(
                        nameController: studentName,
                        submitOnPressed: () {
                          if (studentName.text.isNotEmpty) {
                            Navigator.of(context).pop();
                            _addStudent(studentName.text);
                          }
                        },
                      );
                    }
                  );
                }, icon: Icon(Icons.add, size: 20,)),
              )
            ],
          ),
          Divider(),
          SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                 return StudentAddTempTile(name: widget.students[index].name, removeStudent: () {
                  _removeStudent(index);
                 },);
              },
            )
          ),
        ],
      ),
    );
  }
}

class StudentAddTempTile extends StatelessWidget {

  final String name;
  final void Function()? removeStudent;

  const StudentAddTempTile({super.key, required this.name, required this.removeStudent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(name),
          IconButton(onPressed: removeStudent, icon: Icon(Icons.close), iconSize: 20,)
        ],
      ),
    );
  }
}