import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/utils/dropdowns.dart';
import 'package:the_project/pages/admin/utils/tiles.dart';
import 'package:the_project/services/firestore_service.dart';

class ViewBatches extends StatefulWidget {
  const ViewBatches({super.key});

  @override
  State<ViewBatches> createState() => _ViewBatchesState();
}

class _ViewBatchesState extends State<ViewBatches> {
  final FirestoreService firestoreService = FirestoreService();
  String selectedDay = "Monday";

  void _removeBatch(Batch batch) async {
    await firestoreService.deleteBatchFromDay(selectedDay, batch);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        spacing: 10,
        children: [

          DayDropdown(selectedDay: selectedDay, onChanged: (value) {
            setState(() {
              selectedDay = value!;
            });
          }),

          Expanded(
            child: FutureBuilder<List<Batch>>(
              future: firestoreService.getBatchesForDay(selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No batches found."));
                }

                final batches = snapshot.data!;

                return SingleChildScrollView(
                  child: Container(
                    width: double.maxFinite,
                    child: Center(
                      child: Wrap(
                        runSpacing: 15,
                        spacing: 15,
                        children: batches.map((batch) => EditBatchTile(
                          batch: batch, 
                          removeBatchFunc: () {_removeBatch(batch);},
                          weekday: selectedDay,
                        )).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}