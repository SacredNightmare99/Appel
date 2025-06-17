import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/pages/controllers/student_controller.dart';
import 'package:the_project/utils/colors.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {

    List<Student> students = [
      Student(name: 'Ishaan Jindal'),
      Student(name: 'Student 2'),
      Student(name: 'John Doe'),
      Student(name: 'Mary Jane'),
    ];

    final studentController = Get.put(StudentController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 10,
          children: [
            // View Students
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Card(
                  color: const Color.fromARGB(255, 208, 211, 219),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    side: BorderSide(width: 1)
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: students.length,
                    itemBuilder: (context, index) => _StudentTile(student: students[index])
                  ),
                ),
              ),
            ),
            // Student Details
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Card(
                  color: const Color.fromARGB(255, 208, 211, 219),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    side: BorderSide(width: 1)
                  ),
                  child: Center(
                    child: Obx(() {
                      final selected = studentController.selectedStudent.value;
                      if (selected == null) {
                        return const Text("Select a Student to see details");
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selected.name,

                          )
                        ],
                      );
                    })
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StudentTile extends StatelessWidget {
  final Student student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentController>();

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () => controller.selectStudent(student),
        child: Material(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5),
            side: const BorderSide(width: 1)
          ),
          color: Colors.redAccent,
          child: Container(
            padding: EdgeInsets.all(4),
            child: Text(student.name),
          ),
        ),
      ),
    );
  }
}