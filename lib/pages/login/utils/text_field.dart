import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final bool obscureText;
  
  const MyTextField({super.key, this.controller, required this.labelText, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      child: TextFormField(
        controller: controller,
        autocorrect: false,
        autofocus: true,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: labelText
        ),
      ),
    );
  }
}