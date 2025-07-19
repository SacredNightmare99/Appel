import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/utils/colors.dart';

class CustomSnackbar {
  
  // A styled snackbar for errors or warnings
  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.tileBackground,
      colorText: Colors.black87,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: Icon(Icons.error_outline, color: AppColors.frenchRed, size: 28),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    );
  }

  // A styled snackbar for success messages
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.tileBackground,
      colorText: Colors.black87,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: Icon(Icons.check_circle_outline, color: AppColors.frenchBlue, size: 28),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    );
  }
}