import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/pages/admin/utils/containers.dart';

class AdminAddDataPage extends StatelessWidget {
  const AdminAddDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("Add Data to Database"),
      ),
      body: Container(
          padding: EdgeInsets.all(8),
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 10,
            children: [
              AddBatchContainer(),
              NavigateButton(route: 'admin', text: "Dashboard")
            ],
          ),
        ),
    );
  }
}