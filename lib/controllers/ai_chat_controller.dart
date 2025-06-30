import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/AI/ai_chat.dart';
import 'package:the_project/utils/colors.dart';

class AiChatController extends GetxController {
  var isChatOpen = false.obs;

  var messages = <Map<String, String>>[].obs;

  void addMessage(String role, String text) {
    messages.add({'role': role, 'text': text});
  }

  void clearMessages() {
    messages.clear();
  }

  void showChatOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final controller = Get.find<AiChatController>();

    // Initial offset
    Offset offset = const Offset(100, 100);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () {
              controller.isChatOpen.value = false;
              entry.remove();
            },
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: Colors.transparent),
                ),

                Positioned(
                  top: offset.dy,
                  left: offset.dx,
                  width: 400,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        offset += details.delta;
                      });
                    },
                    child: Material(
                      elevation: 12,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.frenchRed,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("AI Assistant", style: TextStyle(color: Colors.white, fontSize: 16)),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    controller.isChatOpen.value = false;
                                    entry.remove();
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Chat widget
                          SizedBox(
                            height: 450,
                            child: AIChat(), // your existing widget
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    overlay.insert(entry);
    controller.isChatOpen.value = true;
  }


}
