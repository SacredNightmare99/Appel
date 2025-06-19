import 'package:flutter/material.dart';

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

}
