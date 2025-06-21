import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_project/backend/batch.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/pages/controllers/batch_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/cards.dart';
import 'package:the_project/widgets/custom_buttons.dart';

class BatchesPage extends StatelessWidget {
  const BatchesPage({super.key});

  @override
  Widget build(BuildContext context) {

    final batchController = Get.put(BatchController());

    final assignButtonKey = GlobalKey();

    String formatTo12HourTime(TimeOfDay time) {
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mma').format(dateTime).toLowerCase();
    }

    void addBatch() {
      showDialog(
        context: context,
        builder: (context) => _AddBatchDialog()
      );
    }

    void removeBatch(Batch batch) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${batch.name}?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await deleteBatch(batch.uid);
                batchController.selectedBatch.value = null;
                Get.back();
              },
              child: const Text("Delete"),
            ),
          ],
        ),
      );
    }

    void showAssignOverlay(GlobalKey key, Batch batch) async {
      final overlay = Overlay.of(key.currentContext!);
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      final unassignedStudents = await getUnassignedStudents();

      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) => GestureDetector(
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
                top: position.dy + size.height + 8,
                left: position.dx - 150,
                width: 300,
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Assign Student",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
            ],
          ),
        ),
      );

      overlay.insert(entry);
    }


    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            // List of Batches
            Expanded(
              flex: 1,
              child: OuterCard(
                child: InnerCard(
                  child: Column(
                    children: [
                      Center(child: const Text("Batches")),
                      Divider(),
                      SizedBox(
                        height: AppHelper.screenHeight(context) - 168,
                        child: StreamBuilder(
                          stream: streamBatches(),
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
                              return const Center(child: Text("An error occurred while loading batches."));
                            }
                        
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("No Batches found."),
                                    const SizedBox(height: 20),
                                    AddButton(onPressed: addBatch)
                                  ],
                                ),
                              );
                            }

                            final batches = snapshot.data ?? [];

                            return ListView.builder(
                              itemCount: batches.length + 1,
                              itemBuilder: (context, index) {
                                if (index < batches.length) {
                                  return _BatchTile(batch: batches[index]);
                                } else {
                                  return AddButton(onPressed: addBatch);
                                }
                              }
                            );
                                
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // Batch Details
            Expanded(
              flex: 5,
              child: OuterCard(
                child: Obx(() { 
                  final selectedBatch = batchController.selectedBatch.value;
                  return Row(
                    spacing: 5,
                    children: [
                      // Details
                      Expanded(
                        flex: 5,
                        child: InnerCard(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              selectedBatch != null
                            ? SizedBox(
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Text(
                                      "Batch Details",
                                      textAlign: TextAlign.center,
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(onPressed: () => removeBatch(selectedBatch), icon: Icon(Iconsax.minus_square, color: Colors.redAccent, size: 18,))
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "Batch Details",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Divider(),
                              selectedBatch == null ? Expanded(child: Center(child: const Text("Select a batch"),)) : 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name: ${selectedBatch.name}"),
                                  Text("Timings: ${formatTo12HourTime(selectedBatch.startTime)} to ${formatTo12HourTime(selectedBatch.endTime)}"),
                                  Text("Day: ${selectedBatch.day}"),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // Students
                      Expanded(
                        flex: 1,
                        child: InnerCard(
                          child: Column(
                            children: [
                              Center(child: const Text("Students"),),
                              Divider(),
                              selectedBatch == null? Expanded(child: Center(child: const Text("Select a batch"),)) :
                              SizedBox(
                                height: AppHelper.screenHeight(context) - 168,
                                child: StreamBuilder(
                                  stream: streamStudentsByBatch(selectedBatch.uid),
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
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text("No Students assigned."),
                                            const SizedBox(height: 20),
                                            AddButton(key: assignButtonKey, onPressed: () => showAssignOverlay(assignButtonKey, selectedBatch))
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    final students = snapshot.data ?? [];
                                    return ListView.builder(
                                      itemCount: students.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < students.length) {
                                          return _StudentTile(student: students[index]);
                                        } else {
                                          return AddButton(key: assignButtonKey, onPressed: () => showAssignOverlay(assignButtonKey, selectedBatch));
                                        }
                                      }
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }
                )
              ),
            )
          ],
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
    final controller = Get.find<BatchController>();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () => controller.selectBatch(batch),
        child: Material(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5),
            side: const BorderSide(width: 1)
          ),
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            child: Text(batch.name),
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
          side: const BorderSide(width: 1)
        ),
        child: Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(4),
          child: Row(
            children: [
              Text(student.name),
              Spacer(),
              IconButton(
                onPressed: () async {
                  await unassignStudentFromBatch(student);
                }, 
                icon: Icon(Iconsax.minus_square), color: Colors.redAccent,
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
                      icon: const Icon(Icons.access_time),
                      label: Text(startTime == null
                          ? "Start Time"
                          : startTime!.format(context)),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
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
                      icon: const Icon(Icons.access_time_filled),
                      label: Text(endTime == null
                          ? "End Time"
                          : endTime!.format(context)),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty &&
                  startTime != null &&
                  endTime != null &&
                  selectedDay != null) {
                await insertBatch(
                  name: name,
                  startTime: startTime!,
                  endTime: endTime!,
                  day: selectedDay!,
                );
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

