import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const LoginButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
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