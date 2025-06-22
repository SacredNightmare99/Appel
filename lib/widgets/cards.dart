import 'package:flutter/material.dart';

class OuterCard extends StatelessWidget {
  final Widget? child;

  const OuterCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF5F5F5), // Blanc – soft white background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFF0055A4), // Bleu border
          width: 1.2,
        ),
      ),
      elevation: 3,
      shadowColor: const Color(0x220055A4), // soft blue shadow
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child ?? const SizedBox.shrink(),
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
      color: const Color(0xFFEFF1F7), // lighter than OuterCard, soft bluish tint
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Color(0xFFEF4135), // Rouge border accent
          width: 0.8,
        ),
      ),
      elevation: 1.5,
      shadowColor: const Color(0x22EF4135), // soft red shadow
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
