import 'package:flutter/material.dart';
import 'package:the_project/app/admin/utils/buttons.dart';
import 'package:the_project/services/auth_service.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    void _signOut() async {
      await authService.value.signOut();
      Navigator.pushReplacementNamed(context, '/auth');
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Work in Progress!!", style: TextStyle(fontSize: 32),),
            MyButton(text: "Sign Out", onPressed: _signOut)
          ],
        ),
      )
    );
  }
}