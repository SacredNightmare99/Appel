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
    final chatController = Get.find<AiChatController>();

    return GetBuilder<NavController>(
      builder: (navController) {
        Widget buildNavButton(String label, String route, {VoidCallback? onTap, Color? bgColor}) {
          final isActive = navController.currentRoute == route;

          return TextButton(
            style: TextButton.styleFrom(
              backgroundColor: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2)
              )
            ),
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
            bgColor: AppColors.frenchRed
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    update();
  }
}