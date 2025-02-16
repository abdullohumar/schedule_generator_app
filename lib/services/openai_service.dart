import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = "https://api.openai.com/v1/chat/completions";
  static const String _model = "gpt-3.5-turbo";
  static const int _maxTokens = 500;

  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<String> generateSchedule(List<Map<String, dynamic>> tasks) async {
    _validateTasks(tasks);
    final prompt = _buildPrompt(tasks);
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _buildHeaders(),
        body: jsonEncode(_buildRequestBody(prompt)),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to generate schedule: ${e.toString()}");
    }
  }

  Map<String, String> _buildHeaders() => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey",
  };

  Map<String, dynamic> _buildRequestBody(String prompt) => {
    "model": _model,
    "messages": [
      {
        "role": "system",
        "content": "You are an AI assistant that creates optimal daily schedules."
      },
      {"role": "user", "content": prompt}
    ],
    "max_tokens": _maxTokens
  };

  String _buildPrompt(List<Map<String, dynamic>> tasks) {
    final tasksList = tasks.map((task) => 
      "- ${task['name']} (Priority: ${task['priority']}, "
      "Duration: ${task['duration']} minutes, "
      "Deadline: ${task['deadline']}"
    ).join("\n");
    
    return "Buatkan jadwal harian yang optimal untuk tugas-tugas berikut: \n$tasksList\n"
           "Susun jadwal dari pagi hingga malam dengan efisien.";
  }

  String _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception("API Error: ${response.statusCode}");
    }
    
    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"];
  }

  void _validateTasks(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) throw ArgumentError("Tasks list cannot be empty");
    for (final task in tasks) {
      if (!task.containsKey('name') || 
          !task.containsKey('priority') ||
          !task.containsKey('duration') ||
          !task.containsKey('deadline')) {
        throw ArgumentError("Invalid task structure");
      }
    }
  }
}