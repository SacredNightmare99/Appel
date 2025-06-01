import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/utils/buttons.dart';
import 'package:the_project/pages/admin/utils/form_fields.dart';

class StudentForm extends StatelessWidget {
  
  final TextEditingController nameController;
  final void Function()? submitOnPressed;
  
  const StudentForm({super.key, required this.nameController, required this.submitOnPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        padding: EdgeInsets.all(10),
        height: 300,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 80,
          children: [
            StudentField(hint: "Name", controller: nameController),
            MyButton(onPressed: submitOnPressed, text: "Submit",)
          ],
        ),
      ),
    );
  }
}