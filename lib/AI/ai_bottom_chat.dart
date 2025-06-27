import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/AI/gemini_service.dart';


class AIBottomChat extends StatefulWidget {
  const AIBottomChat({super.key});

  @override
  _AIBottomChatState createState() => _AIBottomChatState();
}

class _AIBottomChatState extends State<AIBottomChat> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";

  Future<String> _fetchAttendanceContext() async {
    final supabase = Supabase.instance.client;

    // TODO: customize filters based on user input
    final result = await supabase
        .from('students')
        .select();

    if (result.isEmpty) return "No records found.";

    return result.map((row) {
      return "${row['name']} - ${row['batch_name']} on ${row['uid']}";
    }).join('\n');
  }

  void _askAI() async {
    final question = _controller.text;
    if (question.trim().isEmpty) return;

    setState(() => _response = "Thinking...");

    final contextData = await _fetchAttendanceContext();

    final result = await GeminiService.getResponse(
      userPrompt: question,
      contextData: contextData,
    );

    setState(() => _response = result);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ask something about attendance...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {
              _askAI();
            }, child: Text('Ask Gemini')),
            SizedBox(height: 10),
            MarkdownBody(
              data: _response,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 15),
                h1: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                em: TextStyle(fontStyle: FontStyle.italic),
                strong: TextStyle(fontWeight: FontWeight.bold),
                listBullet: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
