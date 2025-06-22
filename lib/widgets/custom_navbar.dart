import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:the_project/utils/colors.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NavController>(
      builder: (navController) {
        Widget buildNavButton(String label, String route) {
          final isActive = navController.currentRoute == route;

          return TextButton(
            onPressed: () {
              if (!isActive) {
                Get.toNamed(route, id: 1);
              }
            },
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.frenchRed : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }

        return Container(
          height: 60,
          color: AppColors.frenchBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              buildNavButton('Home', '/home'),
              buildNavButton('Attendance', '/attendance'),
              buildNavButton('Batches', '/batches'),
              buildNavButton('Students', '/students'),
              buildNavButton('About', '/about'),
            ],
          ),
        );
      },
    );
  }
}


class NavController extends GetxController {
  String currentRoute = '/home';

  void updateRoute(String route) {
    currentRoute = route;
    update(); // tells GetBuilder to rebuild
  }
}