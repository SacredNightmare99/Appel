import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/AI/ai_chat.dart';
import 'package:the_project/utils/colors.dart';

class AiChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var isChatOpen = false.obs;

  var messages = <Map<String, String>>[].obs;

  final students = <Map<String, dynamic>>[].obs;
  final batches = <Map<String, dynamic>>[].obs;
  final attendance = <Map<String, dynamic>>[].obs;

  final _supabase = Supabase.instance.client;

  late RealtimeChannel _studentChannel;
  late RealtimeChannel _batchChannel;
  late RealtimeChannel _attendanceChannel;

  void addMessage(String role, String text) {
    messages.add({'role': role, 'text': text});
  }

  void clearMessages() {
    messages.clear();
  }

  Future<void> _fetchAllData() async {
    students.value = await _supabase.from('students')
        .select('name, batch_name, classes, classes_present');

    batches.value = await _supabase.from('batches')
        .select('day, name, start_time, end_time');

    attendance.value = await _supabase.from('attendance')
        .select('date, present, student_name');
  }

  void _subscribeToChanges() {
    _studentChannel = _supabase.channel('students_changes');
    _batchChannel = _supabase.channel('batches_changes');
    _attendanceChannel = _supabase.channel('attendance_changes');

    _studentChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'students',
          callback: (_) => _fetchAllData(),
        )
        .subscribe();

    _batchChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'batches',
          callback: (_) => _fetchAllData(),
        )
        .subscribe();

    _attendanceChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance',
          callback: (_) => _fetchAllData(),
        )
        .subscribe();
  }

  void showChatOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final controller = Get.find<AiChatController>();

    Offset offset = const Offset(100, 100);
    Size size = const Size(400, 500);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              // Transparent background to detect outside clicks
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    controller.isChatOpen.value = false;
                    entry.remove();
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Floating draggable + resizable box
              Positioned(
                top: offset.dy,
                left: offset.dx,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() => offset += details.delta);
                  },
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {}, // prevent tap from propagating to background
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                // Header
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.frenchRed,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("AI Assistant", style: TextStyle(color: Colors.white, fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        onPressed: () {
                                          controller.isChatOpen.value = false;
                                          entry.remove();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 0),
                                Expanded(child: AIChat()),
                              ],
                            ),

                            // Resizable corner handle
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    final double newWidth = (size.width + details.delta.dx).clamp(250, 1200);
                                    final double newHeight = (size.height + details.delta.dy).clamp(200, 800);
                                    size = Size(newWidth, newHeight);
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4)),
                                  ),
                                  child: Icon(Iconsax.arrow, size: 14, color: AppColors.frenchBlue),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    overlay.insert(entry);
    controller.isChatOpen.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    _fetchAllData();
    _subscribeToChanges();
  }
  @override
  void onClose() {
    _supabase.removeChannel(_studentChannel);
    _supabase.removeChannel(_batchChannel);
    _supabase.removeChannel(_attendanceChannel);
    super.onClose();
  }

}
