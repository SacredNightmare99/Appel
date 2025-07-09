import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Base Theme
  static const background = Color(0xFFF5F5F5);        // Soft Blanc (Background)
  static const tileBackground = Color(0xFFFFFFFF);    // Tiles, Cards

  // French Tricolor
  static const frenchBlue = Color(0xFF0055A4);        // Bleu (Primary)
  static const frenchRed = Color(0xFFEF4135);         // Rouge (Accent)
  static const frenchBlueAccent = Color(0xFF3385D6);  // Lighter Blue Accent

  // UI Elements
  static const cardLight = Color(0xFFEFF1F7);         // Light cards

  // Text Colors
  static const text = Color(0xFF1C1C1C);              // Default text
  static const textMuted = Color(0xFF6E6E6E);         // Subtle / secondary

  // Semantic Colors (optional, for future)
  static const success = Color(0xFF4CAF50);           // Success green
  static const warning = Color(0xFFFFC107);           // Warning yellow
  static const error = Color(0xFFEF4135);             // Same as frenchRed
  static const info = Color(0xFF2196F3);              // Info blue

  // Theme Shortcuts
  static const primary = frenchBlue;
  static const secondary = frenchRed;
}
