import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_project/backend/attendance.dart';
import 'package:the_project/backend/batch.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/pages/controllers/attendance_controller.dart';
import 'package:the_project/pages/controllers/batch_controller.dart';
import 'package:the_project/pages/controllers/student_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/calendar.dart';
import 'package:the_project/widgets/cards.dart';
import 'package:the_project/widgets/custom_text.dart';
import 'package:the_project/widgets/headers.dart';
import 'package:the_project/widgets/search_overlay.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {

  final attendanceController = Get.find<AttendanceController>();
  final batchController = Get.find<BatchController>();
  final studentController = Get.find<StudentController>();
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocus = FocusNode();
  final searchButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.clear();
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchOverlay(GlobalKey key) {
    final overlay = Overlay.of(key.currentContext!);
    late OverlayEntry searchOverlay;

    searchOverlay = OverlayEntry(
      builder: (context) => CustomSearchOverlay(
        overlayEntry: searchOverlay,
        searchController: _searchController,
        layerLink: _layerLink,
        searchFocus: _searchFocus,
        onChanged: (value) => studentController.filterStudentsByName(value),
        hintText: "Search Students...",
      )
    );

    overlay.insert(searchOverlay);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Container(
          height: 880,
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
                          Container(
                            margin: EdgeInsets.only(bottom: 2),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.frenchBlue,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: TitleText(text: "Batchwise Attendance")
                                ),
                                SizedBox(width: 12,),
                                Tooltip(
                                  message: "Change Batch View",
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.frenchRed
                                    ),
                                    onPressed: () async {
                                      attendanceController.toggleDayWise();
                                      if (attendanceController.isDayWise.value) {
                                        await batchController.refreshDayBatches(AppHelper.getWeekdayName(date));
                                      } else {
                                        await batchController.refreshAllBatches();
                                      }
                                    },
                                    child: Text(
                                      isDayWise? "Day wise" : "All Batches",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 16,),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Obx(() {
                                final batches = isDayWise? batchController.dayBatches : batchController.allBatches;
                                final isLoading = isDayWise? batchController.isDayLoading.value : batchController.isAllLoading.value;
                                if (isLoading) {
                                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                                }
        
                                if (batches.isEmpty) {
                                  return const Center(child: HintText(text: "No Batches found."));
                                }
        
                                return Obx ( () {
                                  attendanceController.refreshTrigger.value;  
                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: List.generate(
                                      batches.length,
                                      (index) => _BatchTile(batch: batches[index], date: date),
                                    ),
                                  );
                                });
                              }),
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
                                Stack(
                                  children: [
                                    CustomHeader(text: "Studentwise Attendance"),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: CompositedTransformTarget(
                                        link: _layerLink,
                                        child: IconButton(
                                          key: searchButtonKey,
                                          icon: const Icon(Icons.search, color: AppColors.cardLight),
                                          tooltip: "Search Students",
                                          onPressed: () => _showSearchOverlay(searchButtonKey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 470,
                                  child: Obx(() {
                                    final students = studentController.filteredStudents;
                                    final isLoading = studentController.isLoading.value;
        
                                    if (isLoading) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.redAccent,
                                        ),
                                      );
                                    }
                                
                                    if (students.isEmpty) {
                                      return const Center(child: Text("No Students found."));
                                    }
                                    
                                    return Obx( () {
                                      attendanceController.refreshTrigger.value; 
                                      return ListView.builder(
                                        itemCount: students.length,
                                        itemBuilder: (context, index) => _StudentTile(student: students[index], date: date,),
                                      ); 
                                    });
                                  }),
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
        ),
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
    final studentController = Get.find<StudentController>();

    return FutureBuilder<bool>(
      future: ifAttendanceMarked(date, student),
      builder: (context, snapshot) {
        final alreadyMarked = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            children: [
              Opacity(
                opacity: alreadyMarked ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: alreadyMarked,
                  child: Material(
                    color: AppColors.tileBackground,
                    borderRadius: BorderRadius.circular(6),
                    elevation: 1,
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
                                              ElevatedButton(
                                                onPressed: () async {
                                                  setState(() => isLoading = true);
                                                  await markAttendanceForStudent(student, true, date);
                                                  await studentController.refreshAllStudents();
                                                  attendanceController.triggerRefresh();
                                                  Get.back();
                                                }, 
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.frenchBlue
                                                ),
                                                child: const Text("Yes", style: TextStyle(color: AppColors.cardLight),),
                                              ),
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text("Cancel", style: TextStyle(color: AppColors.frenchRed),),
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
                                              ElevatedButton(
                                                onPressed: () async {
                                                  setState(() => isLoading = true);
                                                  await markAttendanceForStudent(student, false, date);
                                                  await studentController.refreshAllStudents();
                                                  attendanceController.triggerRefresh();
                                                  Get.back();
                                                }, 
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.frenchBlue
                                                ),
                                                child: const Text("Yes", style: TextStyle(color: AppColors.cardLight),),
                                              ),
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text("Cancel", style: TextStyle(color: AppColors.frenchRed),),
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
              // Watermark overlay
              if (alreadyMarked)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "MARKED",
                      style: TextStyle(
                        color: Colors.red.withValues(alpha: 0.25),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
            ]
          ),
        );
      },
    );
  }
}

class _BatchTile extends StatefulWidget {
  final Batch batch;
  final DateTime date;

  const _BatchTile({required this.batch, required this.date});

  @override
  State<_BatchTile> createState() => _BatchTileState();
}

class _BatchTileState extends State<_BatchTile> {

  final studentController = Get.find<StudentController>();

  @override
  void initState() {
    super.initState();
    studentController.refreshBatchStudents(widget.batch.uid);
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: AppColors.tileBackground,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.frenchBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [ 
                    Text(
                      widget.batch.name,
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0
                      ),
                    ),
                    Spacer(),
                    Text(
                      "${AppHelper.formatTo12HourTime(widget.batch.startTime)} to ${AppHelper.formatTo12HourTime(widget.batch.endTime)}",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0
                      ),
                    )
                  ]
                ),
              ),
              SizedBox(
                height: 360,
                child: Obx(() {
                  final students = studentController.getBatchStudents(widget.batch.uid);
                  final isLoading = studentController.isBatchLoading.value;

                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    );
                  }
              
                  if (students.isEmpty) {
                    return const Center(child: Text("No Students Assigned."));
                  }
                  
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) => _StudentTile(student: students[index], date: widget.date,),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
