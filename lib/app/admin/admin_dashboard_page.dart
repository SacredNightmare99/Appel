import 'package:flutter/material.dart';
import 'package:the_project/app/admin/pages/attendance_calendar.dart';
import 'package:the_project/app/admin/pages/add_batches.dart';
import 'package:the_project/app/admin/pages/view_batches.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {

  int _selectedIndex = 1;

  static const List<Widget> _pages = [
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
