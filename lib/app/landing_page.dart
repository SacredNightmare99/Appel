import 'package:flutter/material.dart';
import 'package:the_project/app/admin/utils/buttons.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Landing Page"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            MyButton(text: "Login", onPressed: () {
              Navigator.pushNamed(context, '/login');
            }),
            MyButton(text: "Register", onPressed: () {
              Navigator.pushNamed(context, '/register');
            })
          ],
        ),
      ),
    );
  }
}