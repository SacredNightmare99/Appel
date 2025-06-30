import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/AI/gemini_service.dart';
import 'package:the_project/controllers/ai_chat_controller.dart';

class AIChat extends StatelessWidget {
  AIChat({super.key});
  final TextEditingController _controller = TextEditingController();
  final AiChatController chatController = Get.find();
  final ScrollController _scrollController = ScrollController();

  Future<String> _fetchAttendanceContext() async {
    final supabase = Supabase.instance.client;
    final result = await supabase.from('students').select();
    if (result.isEmpty) return "No records found.";

    return result.map((row) {
      return "${row['name']} - ${row['batch_name']} on ${row['uid']}";
    }).join('\n');
  }

  Future<void> _askAI() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    chatController.addMessage("user", question);
    _controller.clear();

    chatController.addMessage("bot", "Thinking...");

    final contextData = await _fetchAttendanceContext();
    final result = await GeminiService.getResponse(
      userPrompt: question,
      contextData: contextData,
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
                  child: Container(
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
                  controller: _controller,
                  onSubmitted: (_) => _askAI(),
                  decoration: InputDecoration(
                    hintText: 'Ask something about attendance...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _askAI,
                child: Text("Send"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
