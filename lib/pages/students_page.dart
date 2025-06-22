import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/backend/attendance.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/pages/controllers/attendance_controller.dart';
import 'package:the_project/pages/controllers/student_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/cards.dart';
import 'package:the_project/widgets/custom_buttons.dart';
import 'package:the_project/widgets/custom_text.dart';
import 'package:the_project/widgets/headers.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {

  final studentController = Get.find<StudentController>();
  final attendanceController = Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentController.selectedStudent.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    void addStudent() {
      final nameController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Add Student", style: TextStyle(color: AppColors.frenchBlue),),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter Student name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(), 
              child: const Text('Cancel', style: TextStyle(color: AppColors.frenchRed),)
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await insertStudent(name);
                  await studentController.refreshAllStudents();
                  Get.back();
                }
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.frenchBlue
              ),
              child: const Text("Add", style: TextStyle(color: AppColors.cardLight),),
            )
          ],
        )
      );
    }

    void removeStudent(Student student) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm Delete", style: TextStyle(color: AppColors.frenchRed),),
          content: Text("Are you sure you want to delete ${student.name}?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.frenchBlue)),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteStudent(student.uid);
                await studentController.refreshAllStudents();
                studentController.selectedStudent.value = null;
                Get.back();
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.frenchRed
              ),
              child: const Text("Delete", style: TextStyle(color: AppColors.cardLight),),
            )
          ],
        ),
      );
    }


    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            // View Students List
            Expanded(
              flex: 1,
              child: OuterCard(
                child: InnerCard(
                  child: Column(
                    children: [
                      CustomHeader(text: "Students"),
                      SizedBox(
                        height: AppHelper.screenHeight(context)-190,
                        child: Obx( () {
                            if (studentController.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.redAccent,
                                ),
                              );
                            }
                        
                            if (studentController.allStudents.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const HintText(
                                      text: "No student found",              
                                    ),
                                    const SizedBox(height: 20),
                                    AddButton(onPressed: addStudent, tooltip: "Add Student",)
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: studentController.allStudents.length + 1,
                              itemBuilder: (context, index) {
                                if (index < studentController.allStudents.length) {
                                  return _StudentTile(student: studentController.allStudents[index]);
                                } else {
                                  return AddButton(onPressed: addStudent, tooltip: "Add Student",);
                                }
                              } 
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Student Details
            Expanded(
              flex: 5,
              child: OuterCard(
                child: Obx(() {
                  final selectedStudent = studentController.selectedStudent.value;
                  return Row(
                    spacing: 5,
                    children: [
                      // Details
                      Expanded(
                        flex: 2,
                        child: InnerCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.frenchBlue,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    TitleText(
                                      text: "Student Details",
                                    ),
                                    if (selectedStudent != null)
                                      Positioned(
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () => removeStudent(selectedStudent),
                                          icon: const Icon(Icons.delete_forever),
                                          color: AppColors.frenchRed, // French Red
                                          iconSize: 24,
                                          tooltip: "Remove Student",
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (selectedStudent == null || studentController.isLoading.value)
                                const Expanded(
                                  child: Center(
                                    child: HintText(
                                      text:"Select a Student",
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.frenchBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        selectedStudent.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Batch:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.frenchBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        selectedStudent.batchName ?? "No batch assigned",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Classes Attended:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.frenchBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "${selectedStudent.classesPresent}/${selectedStudent.classes}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Attendance
                      Expanded(
                        flex: 1,
                        child: InnerCard(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.frenchBlue,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12)
                                  )
                                ),
                                child: Center(
                                  child: TitleText(
                                    text: "Attendance",
                                  ),
                                ),
                              ),
                              selectedStudent == null ? 
                              const Expanded(
                                child: Center(
                                  child: HintText(
                                    text: "Attendance will be shown after a Student has been selected",
                                  )
                                )
                              ) 
                            : SizedBox(
                                height: AppHelper.screenHeight(context) - 188,
                                child: Obx( () {
                                  final isLoading = attendanceController.isLoading.value;
                                  final records = attendanceController.attendance;

                                  if (isLoading) {
                                    return const Center(child: CircularProgressIndicator(
                                        color: Colors.redAccent,
                                      ),
                                    );
                                  }
                        
                                  if (records.isEmpty) {
                                    return const Center(child: HintText(text: "No attendance found."));
                                  }

                                  return ListView.builder(
                                    itemCount: records.length,
                                    itemBuilder: (context, index) => _AttendanceTile(attendance: records[index],)
                                  );
                                }),
                              ),
                            ],
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

class _AttendanceTile extends StatelessWidget {
  final Attendance attendance;

  const _AttendanceTile({required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      child: Material(
        elevation: 1,
        color: AppColors.tileBackground,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppHelper.formatDate(attendance.date)),
              Text.rich(
                TextSpan(
                  children: attendance.present
                      ? [
                          TextSpan(
                            text: 'P',
                            style: TextStyle(
                              color: AppColors.frenchBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: 'resent',
                            style: TextStyle(color: Colors.black),
                          ),
                        ]
                      : [
                          TextSpan(
                            text: 'A',
                            style: TextStyle(
                              color: AppColors.frenchRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: 'bsent',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: InkWell(
        onTap: () { 
          controller.selectStudent(student);
          final attendanceController = Get.find<AttendanceController>();
          attendanceController.fetchAttendanceForStudent(student);
        },
        child: Material(
          color: AppColors.tileBackground,
          borderRadius: BorderRadius.circular(6),
          elevation: 1,
          child: Obx(() { 
            final selectedStudent = controller.selectedStudent.value;
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                student.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: (selectedStudent == null) ? AppColors.frenchBlue : (selectedStudent.name == student.name) ? AppColors.frenchRed : AppColors.frenchBlue,
                ),
              ),
            );
          })
        ),
      ),
    );
  }
}

