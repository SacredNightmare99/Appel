import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/utils/dropdowns.dart';
import 'package:the_project/pages/admin/utils/form_fields.dart';

class AddBatchContainer extends StatelessWidget {
  AddBatchContainer({super.key});

  final TextEditingController batchNameController = TextEditingController();
  final TextEditingController batchTimingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 500,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(child: Text("Add Daywise Batches",)),
          Divider(),
          DayDropdown(),
          SizedBox(height: 5,),
          BatchField(hint: "Batch Name", controller: batchNameController,),
          SizedBox(height: 5,),
          BatchField(hint: "Timing", controller: batchTimingController)
        ],
      ),
    );
  }
}

class AddStudentContainer extends StatelessWidget {
  const AddStudentContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 500,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          Text("............. <Work in Progress>............"),
          Divider()
        ],
      ),
    );
  }
}