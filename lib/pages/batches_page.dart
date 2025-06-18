import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_project/backend/batch.dart';
import 'package:the_project/pages/controllers/batch_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/cards.dart';

class BatchesPage extends StatelessWidget {
  const BatchesPage({super.key});

  @override
  Widget build(BuildContext context) {

    final batchController = Get.put(BatchController());

    String formatTo12HourTime(TimeOfDay time) {
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mma').format(dateTime).toLowerCase();
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
                              return Center(child: Text("Error: ${snapshot.error}"));
                            }
                        
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("No Batches found."));
                            }

                            final batches = snapshot.data ?? [];

                            return ListView.builder(
                              itemCount: batches.length,
                              itemBuilder: (context, index) => _BatchTile(batch: batches[index]),
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
                  return InnerCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: const Text("Batch Details")),
                        Divider(),
                        selectedBatch == null ? Expanded(child: Center(child: const Text("Select a batch"),)) : 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${selectedBatch.name}"),
                            Text("Timings: ${formatTo12HourTime(selectedBatch.startTime)} to ${formatTo12HourTime(selectedBatch.endTime)}")
                          ],
                        )
                      ],
                    ),
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
          color: Colors.redAccent[200],
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

