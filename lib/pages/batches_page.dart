import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_project/backend/batch.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/controllers/batch_controller.dart';
import 'package:the_project/controllers/student_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/cards.dart';
import 'package:the_project/widgets/custom_buttons.dart';
import 'package:the_project/widgets/custom_text.dart';
import 'package:the_project/widgets/headers.dart';
import 'package:the_project/widgets/responsive_layout.dart';
import 'package:the_project/widgets/search_overlay.dart';

class BatchesPage extends StatefulWidget {
  const BatchesPage({super.key});

  @override
  State<BatchesPage> createState() => _BatchesPageState();
}

class _BatchesPageState extends State<BatchesPage> {

  final batchController = Get.find<BatchController>();
  final studentController = Get.find<StudentController>();
  final assignButtonKey = GlobalKey();
  final searchButtonKey = GlobalKey();

  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocus = FocusNode();

  void _addBatch() {
    showDialog(
      context: context,
      builder: (context) => _AddBatchDialog()
    );
  }

  void _removeBatch(Batch batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete", style: TextStyle(color: AppColors.frenchBlue),),
        content: Text("Are you sure you want to delete ${batch.name}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: AppColors.frenchBlue),),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteBatch(batch.uid);
              await batchController.refreshAllBatches();
              batchController.selectedBatch.value = null;
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

  void _showAssignOverlay(GlobalKey key, Batch batch) async {
    final overlay = Overlay.of(key.currentContext!);
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final unassignedStudents = await getUnassignedStudents();

    late OverlayEntry entry;

    // Initial position of the draggable popup
    Offset offset = Offset(position.dx - 250, position.dy - 200);

    entry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () => entry.remove(), // dismiss when tapped outside
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                // Transparent backdrop to catch outside taps
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent // optional subtle background
                  ),
                ),
          
                // The popup card
                Positioned(
                  top: offset.dy,
                  left: offset.dx,
                  width: 300,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        offset += details.delta;
                      });
                    },
                    child: Material(
                      elevation: 12,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 400, // Adjust as needed
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                color: AppColors.frenchBlue,
                              ),
                              child: Text(
                                "Assign Student",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Divider(height: 0),
                            if (unassignedStudents.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("No unassigned students"),
                              ) 
                            else
                              Flexible(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  shrinkWrap: true,
                                  itemCount: unassignedStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = unassignedStudents[index];
                                    return ListTile(
                                      title: Text(student.name),
                                      onTap: () async {
                                        await assignStudentToBatch(student, batch);
                                        await studentController.refreshBatchStudents(batch.uid);
                                        await studentController.refreshAllStudents();
                                        entry.remove(); // close overlay
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );

    overlay.insert(entry);
  }

  void _showSearchOverlayBatch(GlobalKey key) {
    final overlay = Overlay.of(key.currentContext!);
    late OverlayEntry searchOverlay;

    searchOverlay = OverlayEntry(
      builder: (context) => CustomSearchOverlay(
        overlayEntry: searchOverlay,
        searchController: _searchController,
        layerLink: _layerLink,
        searchFocus: _searchFocus,
        onChanged: (value) => batchController.filterBatchesByName(value),
        hintText: "Search Batches...",
        offset: Offset(-200, 0),
      )
    );

    overlay.insert(searchOverlay);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      batchController.selectedBatch.value = null;
    });
    _searchController.addListener(() {
      studentController.filterStudentsByName(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.clear();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(), 
        desktop: _buildDesktopLayout()
      )
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Container(
        height: 880,
        padding: const EdgeInsets.all(10),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            // List of Batches
            Expanded(
              flex: 2,
              child: _buildBatchList()
            ),
            // Batch Details
            Expanded(
              flex: 5,
              child: _buildDesktopDetailPanel()
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // Student List
        _buildBatchList(),
        const SizedBox(height: 12,),
        Obx(() {
          final selectedBatch = batchController.selectedBatch.value;
          if (selectedBatch != null) {
            return _buildMobileDetailPanel();
          } else {
            return const SizedBox.shrink();
          }
        })
      ],
    );
  }

  Widget _buildBatchList() {
    return OuterCard(
      child: InnerCard(
        child: Column(
          children: [
            Stack(
              children: [
                CustomHeader(text: "Batches"),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: IconButton(
                      key: searchButtonKey,
                      icon: const Icon(Icons.search, color: AppColors.cardLight),
                      tooltip: "Search Batches",
                      onPressed: () => _showSearchOverlayBatch(searchButtonKey),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 750,
              child: Obx(() {
                final batches = batchController.filteredBatches;
                final isLoading = batchController.isAllLoading.value;

                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ),
                  );
                }
            
                if (batches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HintText(text: "No Batches found."),
                        const SizedBox(height: 20),
                        AddButton(onPressed: _addBatch, tooltip: "Add Batch",)
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: batches.length + 1,
                  itemBuilder: (context, index) {
                    if (index < batches.length) {
                      return _BatchTile(batch: batches[index]);
                    } else {
                      return AddButton(onPressed: _addBatch, tooltip: "Add Batch",);
                    }
                  }
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBatchDetails(Batch? selectedBatch) {
    return InnerCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                  text: "Batch Details",
                ),
                if (selectedBatch != null)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () => _removeBatch(selectedBatch),
                      icon: const Icon(Icons.delete_forever),
                      color: AppColors.frenchRed, // French Red
                      iconSize: 24,
                      tooltip: "Remove Batch",
                    ),
                  ),
              ],
            ),
          ),
          if (selectedBatch == null || batchController.isAllLoading.value)
            const Expanded(
              child: Center(
                child: HintText(
                  text: "Select a batch"
                )
              )
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    selectedBatch.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Timings:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.frenchBlue,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${AppHelper.formatTo12HourTime(selectedBatch.startTime)} to ${AppHelper.formatTo12HourTime(selectedBatch.endTime)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Day:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.frenchBlue,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    selectedBatch.day,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStudentList(Batch? selectedBatch) {
    return InnerCard(
      child: Column(
        children: [
          CustomHeader(text: "Students"),
          selectedBatch == null? const Expanded(child: Center(child: HintText(text: "Select a batch"),)) :
          SizedBox(
            height: 750,
            child: Obx(() {
                final isLoading = studentController.isBatchLoading.value;
                final students = studentController.getBatchStudents(selectedBatch.uid);

                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ),
                  );
                }
            
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HintText(text: "No Students assigned"),
                        const SizedBox(height: 20),
                        AddButton(key: assignButtonKey, tooltip: "Assign Student", onPressed: () => _showAssignOverlay(assignButtonKey, selectedBatch))
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: students.length + 1,
                  itemBuilder: (context, index) {
                    if (index < students.length) {
                      return _StudentTile(student: students[index]);
                    } else {
                      return AddButton(key: assignButtonKey, tooltip: "Assign Student", onPressed: () => _showAssignOverlay(assignButtonKey, selectedBatch));
                    }
                  }
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDesktopDetailPanel() {
    return OuterCard(
      child: Obx(() { 
        final selectedBatch = batchController.selectedBatch.value;
        return Row(
          spacing: 5,
          children: [
            // Details
            Expanded(
              flex: 5,
              child: _buildBatchDetails(selectedBatch)
            ),
            // Students
            Expanded(
              flex: 2,
              child: _buildStudentList(selectedBatch)
            )
          ],
        );
      })
    );
  }

  Widget _buildMobileDetailPanel() {
    return OuterCard(
      child: Obx(() {
        final selectedBatch = batchController.selectedBatch.value;
        return Column(
          children: [
            // Details
            _buildBatchDetails(selectedBatch),
            const SizedBox(height: 8,),
            // Students List
            _buildStudentList(selectedBatch),
          ],
        );
      }),
    );
  }
}

class _BatchTile extends StatelessWidget {
  final Batch batch;
  const _BatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BatchController>();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () { 
          final studentController = Get.find<StudentController>();
          studentController.refreshBatchStudents(batch.uid);
          controller.selectBatch(batch);
        },
        child: Material(
          color: AppColors.tileBackground,
          borderRadius: BorderRadius.circular(6),
          elevation: 1,
          child: Obx(() { 
            final selectedBatch = controller.selectedBatch.value;
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                batch.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: (selectedBatch == null) ? AppColors.frenchBlue : (selectedBatch.uid == batch.uid) ? AppColors.frenchRed : AppColors.frenchBlue,
                ),
              ),
            );
          })
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Material(
        color: AppColors.tileBackground,
        borderRadius: BorderRadius.circular(6),
        elevation: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Text(
                student.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              IconButton(
                tooltip: "Unassign Student",
                onPressed: () async {
                  final studentController = Get.find<StudentController>();
                  final batchUid = student.batchUid;
                  await unassignStudentFromBatch(student);
                  await studentController.refreshBatchStudents(batchUid!);
                  await studentController.refreshAllStudents();
                }, 
                icon: Icon(Iconsax.minus_square), color: AppColors.frenchRed,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBatchDialog extends StatelessWidget {
  const _AddBatchDialog();

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? selectedDay;

    final batchController = Get.find<BatchController>();

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Add Batch"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Batch Name",
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time, color: AppColors.frenchBlue,),
                      label: Text(startTime == null
                          ? "Start Time"
                          : startTime!.format(context),
                          style: TextStyle(
                            color: AppColors.frenchBlue
                          ),
                        ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: AppColors.background,
                                  dialHandColor: AppColors.frenchBlue,
                                  dialBackgroundColor: AppColors.cardLight,
                                  hourMinuteTextColor: AppColors.frenchBlue,
                                  hourMinuteColor: AppColors.cardLight,
                                  entryModeIconColor: Colors.white,
                                  dayPeriodColor: AppColors.frenchBlue,
                                  dayPeriodTextColor: Colors.white  
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(foregroundColor: AppColors.frenchBlue),
                                ),
                              ),
                              child: child!
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => startTime = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time_filled, color: AppColors.frenchBlue,),
                      label: Text(endTime == null
                          ? "End Time"
                          : endTime!.format(context),
                          style: TextStyle(
                            color: AppColors.frenchBlue
                          ),
                        ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: AppColors.background,
                                  dialHandColor: AppColors.frenchBlue,
                                  dialBackgroundColor: AppColors.cardLight,
                                  hourMinuteTextColor: AppColors.frenchBlue,
                                  hourMinuteColor: AppColors.cardLight,
                                  entryModeIconColor: Colors.white,
                                  dayPeriodColor: AppColors.frenchBlue,
                                  dayPeriodTextColor: Colors.white  
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(foregroundColor: AppColors.frenchBlue),
                                ),
                              ),
                              child: child!
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => endTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Day of the Week",
                ),
                value: selectedDay,
                onChanged: (value) => setState(() => selectedDay = value),
                items: [
                  "Monday",
                  "Tuesday",
                  "Wednesday",
                  "Thursday",
                  "Friday",
                  "Saturday",
                  "Sunday"
                ].map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.frenchRed
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty || startTime == null || endTime == null || selectedDay == null) return;

              final newStartMinutes = startTime!.hour * 60 + startTime!.minute;
              final newEndMinutes = endTime!.hour * 60 + endTime!.minute;

              if (newEndMinutes <= newStartMinutes) {
                Get.snackbar(
                  "Invalid Time",
                  "End time must be after start time",
                  backgroundColor: AppColors.tileBackground,
                  colorText: AppColors.text,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 12,
                  padding: const EdgeInsets.all(16),
                  icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  shouldIconPulse: false,
                  duration: const Duration(seconds: 3),
                );

                return;
              }

              // Fetch existing batches for the selected day
              final existingBatches = batchController.allBatches.where((batch) => batch.day == selectedDay).toList();

              bool isConflict = existingBatches.any((batch) {
                final existingStart = batch.startTime.hour * 60 + batch.startTime.minute;
                final existingEnd = batch.endTime.hour * 60 + batch.endTime.minute;

                // Check for time overlap
                return !(newEndMinutes <= existingStart || newStartMinutes >= existingEnd);
              });

              if (isConflict) {
                Get.snackbar(
                  "Conflict", 
                  "Another batch already exists in this time range",
                  backgroundColor: AppColors.tileBackground,
                  colorText: AppColors.text,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 12,
                  padding: const EdgeInsets.all(16),
                  icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  shouldIconPulse: false,
                  duration: const Duration(seconds: 3),
                );
                return;
              }

              // Proceed to add the batch
              await insertBatch(
                name: name,
                startTime: startTime!,
                endTime: endTime!,
                day: selectedDay!,
              );
              await batchController.refreshAllBatches();
              Get.back();
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frenchBlue
            ),
            child: const Text(
              "Add",
              style: TextStyle(
                color: AppColors.cardLight
              ),  
            ),
          ),
        ],
      ),
    );
  }
}

