import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/utils/containers.dart';

class AdminAddDataPage extends StatelessWidget {
  const AdminAddDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Add Data to Database"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.maxFinite,
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            spacing: 10,
            children: [
              AddBatchContainer(),
              AddStudentContainer()
            ],
          ),
        ),
      )
    );
  }
}