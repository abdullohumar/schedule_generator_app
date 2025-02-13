// import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIService {
  static const String apiKey =
      "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";
  static const String baseUrl = "https://api.openai.com/v1/chat/completions";

  static Future<String> generateSchedule(
      List<Map<String, dynamic>> tasks) async {
    final prompt = _buildPrompt(tasks);

    final response = await http.post(Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "store": true,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a student and you need to schedule the following tasks. Please provide a schedule for the tasks"
            },
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 500
        }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Failed to generate schedule");
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> tasks) {
    String tasksList = tasks
        .map((task) =>
            "- ${task['name']} (Priority: ${task['priority']}, Duration: ${task['duration']} minutes), Deadline: ${task['deadline']}")
        .join("\n");
    return "Buatkan jadwal harian yang optimal untuk tugas-tugas berikut: \n$tasksList\n Susun jadwal dari pagi hingga malam dengan efisien, dan pastikan jadwal tersebut sesuai dengan deadline dari setiap tugas.";
  }
}
