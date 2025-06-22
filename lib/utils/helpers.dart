import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelper {
  const AppHelper._();

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double responsiveSize(BuildContext context, double baseSize) {
    return baseSize * (screenWidth(context) / 1920); // tune divisor for your base layout
  }

  static String formatDate(DateTime date) {
    final day = date.day;
    String suffix = "";
    if (day >= 11 && day <= 13) suffix = 'th';
    switch (day % 10) {
      case 1:
        suffix = 'st';
      case 2:
        suffix = 'nd';
      case 3:
        suffix = 'rd';
      default:
        suffix = 'th';
    }
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[date.month - 1];
    final year = date.year;
    return '$day$suffix $month, $year';
  }

  static String getWeekdayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

}
