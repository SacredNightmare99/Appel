// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class DayButton extends StatelessWidget {
  void Function()? onPressed;
  String text;

  DayButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class BatchButton extends StatelessWidget {
  void Function()? onPressed;
  String text;

  BatchButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class AttendanceToggleButton extends StatelessWidget {

  final bool isPresent;
  final VoidCallback? onToggle;
  final bool marked;

  const AttendanceToggleButton({
    super.key,
    required this.isPresent,
    required this.onToggle,
    required this.marked,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: 20,
      child: MaterialButton(
        onPressed: onToggle,
        child: Text(
          isPresent? "PRESENT" : "ABSENT",
          style: TextStyle(
            color: marked? null : (isPresent ? Colors.green : Colors.red),
          ),
        ),
      )
    );
  }
}

class SubmitButton extends StatelessWidget {
  final void Function()? onPressed;

  const SubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text("Submit"),
      ),
    );
  }
}