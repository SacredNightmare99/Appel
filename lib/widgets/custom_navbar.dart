import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/controllers/ai_chat_controller.dart';
import 'package:the_project/utils/colors.dart';

class CustomNavigationBar extends StatelessWidget {
  final bool isVertical;
  final void Function()? onLinkPressed;

  const CustomNavigationBar({super.key, this.isVertical = false, this.onLinkPressed});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(AiChatController());

    return GetBuilder<NavController>(
      builder: (navController) {
        Widget buildNavButton(String label, String route, {VoidCallback? onTap}) {
          final isActive = navController.currentRoute == route;

          return TextButton(
            onPressed: () {
              if (onTap != null) {
                onTap();
                onLinkPressed?.call();
                return;
              }

              if (!isActive) {
                Get.toNamed(route, id: 1);
                onLinkPressed?.call();
              }
            },
            child: Align(
              alignment: isVertical? Alignment.centerLeft : Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isVertical? 18 : 16,
                  color: isActive ? AppColors.frenchRed : Colors.white,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }

        final navButtons = [
          buildNavButton('Home', '/home'),
          buildNavButton('Attendance', '/attendance'),
          buildNavButton('Batches', '/batches'),
          buildNavButton('Students', '/students'),
          buildNavButton('About', '/about'),
          buildNavButton(
            'Chat with AI',
            '', // no routing
            onTap: () {
              if (!chatController.isChatOpen.value) {
                chatController.showChatOverlay(context); // floating chat trigger
              } else {
                chatController.isChatOpen.value = false;
              }
            },
          ),
        ];

        return isVertical 
        ? Container(
            color: AppColors.frenchBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: navButtons,
            ),
          )
        : Container(
            height: 60,
            color: AppColors.frenchBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: navButtons,
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