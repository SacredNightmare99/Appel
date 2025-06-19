import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
                        Row(
                          children: [
                            Center(child: const Text("Batchwise"),),
                            // Positioned(
                            //   child: TextButton(
                            //     onPressed: () {}, 
                            //     child: Text("daywise")
                            //   ),
                            // )
                          ],
                        ),
                        Divider(),
                        SizedBox(
                          height: AppHelper.screenHeight(context)-188,
                          child: StreamBuilder(
                            stream: isDayWise? streamBatchesByDay(getWeekdayName(date)) : streamBatches(),
                            builder: (context, snapshot) {

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                );
                              }
                          
                              if (snapshot.hasError) {
                                return Center(child: Text("Error: ${snapshot.error}"));
                              }
                          
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text("No Batches found."));
                              }
                              
                              final batches = snapshot.data ?? [];

                              return Wrap(
                                children: List.generate(batches.length, (index) {
                                  return _BatchTile(batch: batches[index]);
                                }),
                              );
                            },
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
                              Center(child: const Text("Studentwise"),),
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
                                      return Center(child: Text("Error: ${snapshot.error}"));
                                    }
                                
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Center(child: Text("No Students found."));
                                    }
                                    
                                    final students = snapshot.data ?? [];
                                
                                    return ListView.builder(
                                      itemCount: students.length,
                                      itemBuilder: (context, index) => _StudentTile(student: students[index]),
                                    );
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

  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
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
    );
  }
}

class _BatchTile extends StatelessWidget {
  final Batch batch;
  const _BatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
          side: const BorderSide(width: 1)
        ),
        color: Colors.redAccent[200],
        child: Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(4),
          child: Text(batch.name),
        ),
      ),
    );
  }
}
