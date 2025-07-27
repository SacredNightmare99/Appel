import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/pages/app/attendance_page.dart';
import 'package:the_project/pages/app/batches_page.dart';
import 'package:the_project/pages/app/home_page.dart';
import 'package:the_project/pages/app/students_page.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/widgets/custom_navbar.dart';
import 'package:the_project/widgets/responsive_layout.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {

    final navController = Get.find<NavController>();

    return ResponsiveLayout(
      mobile: _buildMobile(navController), 
      desktop: _buildDesktop(navController)
    );

  }

  Widget _buildDesktop(NavController navController) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(NavController navController) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Appel", style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.frenchBlue,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: CustomNavigationBar(
            isVertical: true,
            onLinkPressed: () {
              scaffoldKey.currentState?.closeDrawer();
            },
          ),
        ),
      ),
      body: Navigator(
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
      ),
    );
  }

}


Widget _getPageRouteBuilder(String? route) {
  switch (route) {
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