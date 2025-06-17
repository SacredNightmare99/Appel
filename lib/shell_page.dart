import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/pages/about_page.dart';
import 'package:the_project/pages/attendance_page.dart';
import 'package:the_project/pages/batches_page.dart';
import 'package:the_project/pages/home_page.dart';
import 'package:the_project/pages/students_page.dart';
import 'package:the_project/widgets/navbar/custom_navbar.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {

    final navController = Get.find<NavController>();

    return Column(
      children: [
        CustomNavigationBar(),
        Expanded(
          child: Navigator(
            key: Get.nestedKey(1),
            initialRoute: '/home',
            onGenerateRoute: (settings) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navController.updateRoute(settings.name ?? '/home');
              });

              return GetPageRoute(
                settings: settings,
                page: () => _getPageRouteBuilder(settings.name ?? '/home'),
              );
            },
          )
        )
      ],
    );
  }
}

Widget _getPageRouteBuilder(String? route) {
  switch (route) {
    case '/about':
      return AboutPage();
    case '/attendance':
      return AttendancePage();
    case '/batches':
      return BatchesPage();
    case '/students':
      return StudentsPage();
    case '/home':
    default:
      return HomePage();
  }
}