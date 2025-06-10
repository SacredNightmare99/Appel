import 'package:flutter/material.dart';

class BatchField extends StatelessWidget {

  final TextEditingController? controller;
  final String hint;

  const BatchField({super.key, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1)
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero
        ),
        controller: controller,
      ),
    );
  }
}

class StudentField extends StatelessWidget {

  final TextEditingController? controller;
  final String hint;

  const StudentField({super.key, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1)
      ),
      child: TextFormField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero
        ),
        controller: controller,
      ),
    );
  }
}