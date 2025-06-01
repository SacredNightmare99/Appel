import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/containers/attendance_calendar.dart';
import 'package:the_project/pages/admin/containers/add_batches.dart';
import 'package:the_project/pages/admin/containers/view_batches.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {

  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ViewBatches(),
    AttendanceCalendar(),
    AddBatchContainer()
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Dashboard"),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            label: "View Batches"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), 
            label: "Mark Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), 
            label: "Add Batches"
          ),
        ]
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
    );
  }
}
