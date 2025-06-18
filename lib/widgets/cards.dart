import 'package:flutter/material.dart';

class OuterCard extends StatelessWidget {
  final Widget? child;

  const OuterCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 208, 211, 219),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
        side: BorderSide(width: 1)
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: child ?? SizedBox.shrink()
      ),
    );
  }
}

class InnerCard extends StatelessWidget {
  final Widget? child;

  const InnerCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 235, 237, 243),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(7),
        side: BorderSide(width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child ?? SizedBox.shrink(),
      ),
    );
  }
}