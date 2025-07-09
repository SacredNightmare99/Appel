import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:the_project/AI/gemini_service.dart';
import 'package:the_project/controllers/ai_chat_controller.dart';
import 'package:the_project/utils/colors.dart';

class AIChat extends StatelessWidget {
  AIChat({super.key});
  final TextEditingController _controller = TextEditingController();
  final AiChatController chatController = Get.find<AiChatController>();
  final ScrollController _scrollController = ScrollController();

  String _generateContextFromPrompt(String prompt) {
    final lower = prompt.toLowerCase();

    final includeStudent = lower.contains("student");
    final includeBatch = lower.contains("batch");
    final includeAttendance = lower.contains("attendance") ||
        lower.contains("present") ||
        lower.contains("absent");

    final isRelevant = includeStudent || includeBatch || includeAttendance;
    if (!isRelevant) return "Not a relevant query.";

    final isCountQuery = lower.contains("total") ||
        lower.contains("count") ||
        lower.contains("how many");

    final students = chatController.students;
    final batches = chatController.batches;
    final attendance = chatController.attendance;

    List<String> contextSections = [];

    // Add current date
    final today = DateTime.now();
    final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    contextSections.add("_Current Date: ${formattedDate}_");

    // Manual counts for summary
    if (isCountQuery) {
      contextSections.add("**Summary:**");

      if (includeStudent || lower.contains("student")) {
        contextSections.add("- Total students: ${students.length}");
      }

      if (includeBatch || lower.contains("batch")) {
        contextSections.add("- Total batches: ${batches.length}");
      }

      if (includeAttendance || lower.contains("attendance")) {
        contextSections.add("- Total attendance entries: ${attendance.length}");

        final presentCount =
            attendance.where((e) => e['present'] == true).length;
        final absentCount =
            attendance.where((e) => e['present'] == false).length;

        contextSections.add("- Present entries: $presentCount");
        contextSections.add("- Absent entries: $absentCount");
      }

      contextSections.add("");
    }

    // Student Info
    if (includeStudent && students.isNotEmpty) {
      contextSections.add("**Students:**\n${students.map((row) {
        final name = row['name'] ?? "Unnamed";
        final batch = row['batch_name'] != null ? ", Batch: ${row['batch_name']}" : "";
        final classes = row['classes'] ?? 0;
        final present = row['classes_present'] ?? 0;

        return "- $name$batch, Classes: $classes, Present: $present";
      }).join("\n")}");
    }

    // Batch Info
    if (includeBatch && batches.isNotEmpty) {
      contextSections.add("**Batches:**\n${batches.map((row) {
        final name = row['name'] ?? "Unnamed";
        final day = row['day'] ?? "N/A";
        final start = row['start_time'] ?? "??";
        final end = row['end_time'] ?? "??";

        return "- $name, Day: $day, Time: $start - $end";
      }).join("\n")}");
    }

    // Attendance info
    if (includeAttendance && attendance.isNotEmpty) {
      contextSections.add("**Attendance Records:**\n${attendance.map((row) {
        final name = row['student_name'] ?? "Unknown";
        final date = row['date'] ?? "Unknown date";
        final present = row['present'] == true ? "present" : "absent";

        return "- $name was $present on $date";
      }).join("\n")}");
    }

    return contextSections.isEmpty
        ? "No relevant data found for this query."
        : contextSections.join("\n\n");
  }

  
  Future<void> _askAI() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    chatController.addMessage("user", question);
    _controller.clear();

    chatController.addMessage("bot", "Thinking...");

    final List<Map<String, String>> history = chatController.messages
      .where((msg) => msg['text'] != "Thinking...")
      .map((msg) => {
            "role": msg['role']!,
            "text": msg['text']!,
          })
      .toList();

    final result = await GeminiService.getResponse(
      userPrompt: question,
      contextData: _generateContextFromPrompt(question),
      history: history
    );

    final botIndex = chatController.messages.lastIndexWhere((msg) => msg['role'] == 'bot');
    if (botIndex != -1) {
      chatController.messages[botIndex] = {'role': 'bot', 'text': result};
      chatController.messages.refresh();
    }

    await Future.delayed(Duration(milliseconds: 300));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final messages = chatController.messages;
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MarkdownBody(
                          data: msg['text'] ?? '',
                        ),
                      ),
                      if (!isUser) 
                        Padding(
                          padding: const EdgeInsets.only(top: 2, left: 4),
                          child: Text(
                            "Powered by Google Gemini",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        )  
                    ],
                  ),
                );
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _controller,
                  onSubmitted: (_) => _askAI(),
                  decoration: InputDecoration(
                    hintText: 'Ask something...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.frenchBlue)
                ),
                onPressed: _askAI,
                child: Text("Send", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
