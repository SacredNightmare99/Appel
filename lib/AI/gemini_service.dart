import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static final String _apiKey = dotenv.env['GeminiAPI']!;
  static final String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$_apiKey';

  static Future<String> getResponse({
    required String userPrompt,
    required String contextData,
    required List<Map<String, String>> history,
  }) async {
    final List<Map<String, dynamic>> contents = [];

    for (var msg in history) {
      contents.add({
        "parts": [{"text": msg['text']}],
        "role": msg['role'] == "user" ? "user" : "model"
      });
    }

    contents.add({
      "parts": [
        {
          "text": "$userPrompt\n\nContext Data:\n$contextData",
        }
      ],
      "role": "user"
    });

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"contents": contents}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ?? "No response.";
    } else {
      debugPrint("Gemini error: ${response.body}");
      return 'Gemini API Error';
    }
  }
}
