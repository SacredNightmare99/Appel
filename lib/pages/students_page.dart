import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_project/backend/attendance.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/pages/controllers/student_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final studentController = Get.put(StudentController());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton( // Add students
        onPressed: () {},
        backgroundColor: AppColors.navbar,
        child: Icon(Iconsax.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            // View Students
            Expanded(
              flex: 1,
              child: _OuterCard(
                child: StreamBuilder(
                  stream: streamStudents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      );
                    }

                    final students = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) => _StudentTile(student: students[index])
                    );
                  }
                ),
              ),
            ),
            // Student Details
            Expanded(
              flex: 5,
              child: _OuterCard(
                child: Obx(() {
                  final selectedStudent = studentController.selectedStudent.value;
                  return Row(
                    spacing: 5,
                    children: [
                      // Details
                      Expanded(
                        flex: 2,
                        child: _InnerCard(
                          child: selectedStudent == null? 
                          Center(child: Text("Select a Student"),) :
                          Column(
                            children: [
                              Text(selectedStudent.name)
                            ],
                          ),
                        ),
                      ),
                      // Attendance
                      Expanded(
                        flex: 1,
                        child: _InnerCard(
                          child: selectedStudent == null ? Center(child: Text("Attendance will be shown after a Student has been selected"),) : 
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              spacing: 10,
                              children: [
                                Text("Attendance"),
                                Divider(),
                                SizedBox(
                                  height: AppHelper.screenHeight(context) - 188,
                                  child: StreamBuilder(
                                    stream: streamAttendanceForStudent(studentController.selectedStudent.value!),
                                    builder: (context, snapshot) {

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator(
                                            color: Colors.redAccent,
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Center(child: Text("Error: ${snapshot.error}"));
                                      }

                                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Center(child: Text("No attendance found."));
                                      }

                                      final attendance = snapshot.data!;
                                      return ListView.builder(
                                        itemCount: attendance.length,
                                        itemBuilder: (context, index) => _AttendanceTile(attendance: attendance[index],)
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                      ),
                    ],
                  );
                }),
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
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () => controller.selectStudent(student),
        child: Material(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5),
            side: const BorderSide(width: 1)
          ),
          color: Colors.redAccent[200],
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            child: Text(student.name),
          ),
        ),
      ),
    );
  }
}

class _OuterCard extends StatelessWidget {
  final Widget? child;

  const _OuterCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 208, 211, 219),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
        side: BorderSide(width: 1)
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: child ?? SizedBox.shrink()
      ),
    );
  }
}

class _InnerCard extends StatelessWidget {
  final Widget? child;

  const _InnerCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 235, 237, 243),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(7),
        side: BorderSide(width: 0.5)
      ),
      child: child ?? SizedBox.shrink(),
    );
  }
}

class _AttendanceTile extends StatelessWidget {

  final Attendance attendance;

  const _AttendanceTile({required this.attendance});

  @override
  Widget build(BuildContext context) {

    String formatDate(DateTime date) {
      final day = date.day;
      String suffix = "";
      if (day >= 11 && day <= 13) suffix = 'th';
      switch (day % 10) {
        case 1:
          suffix = 'st';
        case 2:
          suffix = 'nd';
        case 3:
          suffix = 'rd';
        default:
          suffix = 'th';
      }
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final month = months[date.month - 1];
      final year = date.year;
      return '$day$suffix $month, $year';
    }
   
    return Material(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(4)
      ),
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatDate(attendance.date)),
            Text(
              attendance.present? "Present" : "Absent"
            )
          ],
        ),
      ),
    );
  }
}
