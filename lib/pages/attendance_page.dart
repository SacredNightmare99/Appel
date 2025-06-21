import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_project/backend/attendance.dart';
import 'package:the_project/backend/batch.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/pages/controllers/attendance_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/calendar.dart';
import 'package:the_project/widgets/cards.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {

    final attendanceController = Get.put(AttendanceController());

    String getWeekdayName(DateTime date) {
      return DateFormat('EEEE').format(date);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          DateTime date = attendanceController.selectedDate.value ?? DateTime.now();
          bool isDayWise = attendanceController.isDayWise.value;
          
          return OuterCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                // Batchwise
                Expanded(
                  flex: 3,
                  child: InnerCard(
                    child: Column(
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Batchwise Attendance"),
                              TextButton(
                                onPressed: () {
                                  attendanceController.toggleDayWise();
                                }, 
                                child: Text(isDayWise? "Daywise" : "All Batches")
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: StreamBuilder(
                              stream: isDayWise ? streamBatchesByDay(getWeekdayName(date)) : streamBatches(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                                }

                                if (snapshot.hasError) {
                                  debugPrint('Stream error: ${snapshot.error}');
                                  return const Center(child: Text("An error occurred while loading batches."));
                                }

                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text("No Batches found."));
                                }

                                final batches = snapshot.data!;
                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: List.generate(
                                    batches.length,
                                    (index) => _BatchTile(batch: batches[index], date: date),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      // Calendar
                      Expanded(
                        flex: 1,
                        child: InnerCard(
                          child: CustomCalendar()
                        ),
                      ),
                      // Studentwise
                      Expanded(
                        flex: 2,
                        child: InnerCard(
                          child: Column(
                            children: [
                              Center(child: const Text("Studentwise Attendance"),),
                              Divider(),
                              SizedBox(
                                height: (AppHelper.screenHeight(context) - 200) * 0.66,
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
                                
                                    if (snapshot.hasError) {
                                      debugPrint('Stream error: ${snapshot.error}');
                                      return const Center(child: Text("An error occurred while loading students."));
                                    }
                                
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Center(child: Text("No Students found."));
                                    }
                                    
                                    final students = snapshot.data ?? [];
                                
                                    return Obx( () {
                                      attendanceController.refreshTrigger.value; 
                                      return ListView.builder(
                                        itemCount: students.length,
                                        itemBuilder: (context, index) => _StudentTile(student: students[index], date: date,),
                                      ); 
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
          }
        )
      )
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  final DateTime date;

  const _StudentTile({required this.student, required this.date});

  @override
  Widget build(BuildContext context) {

    final attendanceController = Get.find<AttendanceController>();

    return FutureBuilder<bool>(
      future: ifAttendanceMarked(date, student),
      builder: (context, snapshot) {
        final alreadyMarked = snapshot.data ?? false;

        return Opacity(
          opacity: alreadyMarked ? 0.5 : 1.0,
          child: IgnorePointer(
            ignoring: alreadyMarked,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Material(
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(5),
                  side: const BorderSide(width: 1)
                ),
                color: Colors.white10,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Text(student.name),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              bool isLoading = false;
                              return StatefulBuilder(
                                builder: (context, setState) => AlertDialog(
                                  title: Text.rich(
                                    TextSpan(
                                      text: 'Mark ',
                                      children: [
                                        TextSpan(
                                          text: student.name,
                                          style: const TextStyle(color: Colors.blueAccent),
                                        ),
                                        const TextSpan(text: ' as '),
                                        const TextSpan(
                                          text: 'present',
                                          style: TextStyle(color: Colors.blueAccent),
                                        ),
                                        const TextSpan(text: ' for '),
                                        TextSpan(
                                          text: AppHelper.formatDate(date),
                                          style: const TextStyle(color: Colors.blueAccent),
                                        ),
                                        const TextSpan(text: '?'),
                                      ],
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  actions: isLoading
                                      ? [const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())]
                                      : [
                                          TextButton(
                                            onPressed: () async {
                                              setState(() => isLoading = true);
                                              await markAttendanceForStudent(student, true, date);
                                              attendanceController.triggerRefresh();
                                              Get.back();
                                            },
                                            child: const Text("Yes"),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Iconsax.tick_square, color: Colors.blueAccent),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              bool isLoading = false;
                              return StatefulBuilder(
                                builder: (context, setState) => AlertDialog(
                                  title: Text.rich(
                                    TextSpan(
                                      text: 'Mark ',
                                      children: [
                                        TextSpan(
                                          text: student.name,
                                          style: const TextStyle(color: Colors.blueAccent),
                                        ),
                                        const TextSpan(text: ' as '),
                                        const TextSpan(
                                          text: 'absent',
                                          style: TextStyle(color: Colors.redAccent),
                                        ),
                                        const TextSpan(text: ' for '),
                                        TextSpan(
                                          text: AppHelper.formatDate(date),
                                          style: const TextStyle(color: Colors.blueAccent),
                                        ),
                                        const TextSpan(text: '?'),
                                      ],
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  actions: isLoading
                                      ? [const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())]
                                      : [
                                          TextButton(
                                            onPressed: () async {
                                              setState(() => isLoading = true);
                                              await markAttendanceForStudent(student, false, date);
                                              attendanceController.triggerRefresh();
                                              Get.back();
                                            },
                                            child: const Text("Yes"),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Iconsax.close_square, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class _BatchTile extends StatelessWidget {
  final Batch batch;
  final DateTime date;

  const _BatchTile({required this.batch, required this.date});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
          side: const BorderSide(width: 1)
        ),
        color: Colors.white10,
        child: Container(
          padding: EdgeInsets.all(5),
          width: (AppHelper.screenWidth(context)/4).clamp(300, 600),
          height: AppHelper.screenHeight(context)/3,
          child: Column(
            children: [
              Center(child: Text(batch.name),),
              Divider(),
              SizedBox(
                height: AppHelper.screenHeight(context)/4,
                child: StreamBuilder(
                  stream: streamStudentsByBatch(batch.uid),
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      );
                    }
                
                    if (snapshot.hasError) {
                      debugPrint('Stream error: ${snapshot.error}');
                      return const Center(child: Text("An error occurred while loading students."));
                    }
                
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Students Assigned."));
                    }
                    
                    final students = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) => _StudentTile(student: students[index], date: date,),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
