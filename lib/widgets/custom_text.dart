import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String text;
  const TitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 1.2,
      ),
    );
  }
}

class HintText extends StatelessWidget {
  final String text;
  const HintText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.grey,
        fontSize: 14,
      ),
    );
  }
}
