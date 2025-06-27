import 'package:flutter/material.dart';
import 'package:the_project/AI/ai_bottom_chat.dart';
import 'package:the_project/utils/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => AIBottomChat(),
          );
        },
      ),
      body: Center(child: Image.asset('assets/lfwa_logo.png')),
    );
  }
}