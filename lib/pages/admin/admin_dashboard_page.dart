import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/utils/attendance_calendar.dart';

class AdminDashboardPage extends StatefulWidget {
  AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Wrap(
              spacing: 30,
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              children: [
                AttendanceCalendar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
