import 'package:flutter/material.dart';
import 'package:the_project/utils/routes.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  int _selectedIndex = 1;

  static const List<Widget> _pages = [
    viewScreenRoute,
    markAttendanceRoute,
    addDataRoute
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
            label: "Add"
          ),
        ]
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
    );
  }
}
