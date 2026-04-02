import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class GeminiService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.5-flash';

  final _uuid = const Uuid();

  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Parse natural language transcript into structured tasks directly from audio
  Future<List<Task>> parseTasksFromAudio(String audioPath) async {
    final now = DateTime.now();
    final prompt = '''
You are a task parsing assistant. Listen to the provided audio clip and parse it into individual actionable tasks.
For each task, extract:
- title: A concise task title
- notes: Any additional details or context (optional)
- dueDate: Due date/time in ISO 8601 format if mentioned, relative to current date ${now.toIso8601String()} (optional)
- priority: "high", "medium", or "low" based on urgency words (urgent/asap/critical = high, normal = medium, whenever/someday = low). Default to "medium" if not specified.

Current date and time: ${now.toIso8601String()}

Return a JSON array of task objects. Example:
[
  {
    "title": "Buy groceries",
    "notes": "milk, eggs, bread",
    "dueDate": "2024-03-15T18:00:00",
    "priority": "medium"
  }
]

If the audio is unclear, contains no speech, or contains no actionable tasks, return an empty array: []

IMPORTANT: Return ONLY the JSON array, no markdown formatting, no code blocks, no additional text.
''';

    final bytes = await File(audioPath).readAsBytes();
    final base64Audio = base64Encode(bytes);

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'inlineData': {
                  'mimeType': 'audio/wav',
                  'data': base64Audio,
                }
              },
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topP': 0.8,
          'topK': 40,
          'maxOutputTokens': 2048,
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error: ${response.statusCode} ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseBody['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Gemini');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final text = parts[0]['text'] as String;

    // Clean up the response — remove markdown code blocks if present
    String cleanedText = text.trim();
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText
          .replaceFirst(RegExp(r'^```\w*\n?'), '')
          .replaceFirst(RegExp(r'\n?```$'), '');
    }

    final List<dynamic> tasksJson = jsonDecode(cleanedText) as List<dynamic>;

    return tasksJson.map((json) {
      final map = json as Map<String, dynamic>;
      return Task(
        id: _uuid.v4(),
        title: map['title'] as String? ?? 'Untitled Task',
        notes: map['notes'] as String?,
        status: TaskStatus.todo,
        priority: _parsePriority(map['priority'] as String?),
        dueDate: map['dueDate'] != null
            ? DateTime.tryParse(map['dueDate'] as String)
            : null,
      );
    }).toList();
  }

  /// Parse natural language transcript into structured tasks
  Future<List<Task>> parseTasksFromTranscript(String transcript) async {
    final now = DateTime.now();
    final prompt = '''
You are a task parsing assistant. Parse the following voice transcript into individual tasks.
For each task, extract:
- title: A concise task title
- notes: Any additional details or context (optional)
- dueDate: Due date/time in ISO 8601 format if mentioned, relative to current date ${now.toIso8601String()} (optional)
- priority: "high", "medium", or "low" based on urgency words (urgent/asap/critical = high, normal = medium, whenever/someday = low). Default to "medium" if not specified.

Current date and time: ${now.toIso8601String()}

Return a JSON array of task objects. Example:
[
  {
    "title": "Buy groceries",
    "notes": "milk, eggs, bread",
    "dueDate": "2024-03-15T18:00:00",
    "priority": "medium"
  }
]

If the transcript is unclear or contains no actionable tasks, return an empty array: []

IMPORTANT: Return ONLY the JSON array, no markdown formatting, no code blocks, no additional text.

Transcript: "$transcript"
''';

    final url = Uri.parse(
        '$_baseUrl/$_model:generateContent?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topP': 0.8,
          'topK': 40,
          'maxOutputTokens': 2048,
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error: ${response.statusCode} ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseBody['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Gemini');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final text = parts[0]['text'] as String;

    // Clean up the response — remove markdown code blocks if present
    String cleanedText = text.trim();
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText
          .replaceFirst(RegExp(r'^```\w*\n?'), '')
          .replaceFirst(RegExp(r'\n?```$'), '');
    }

    final List<dynamic> tasksJson = jsonDecode(cleanedText) as List<dynamic>;

    return tasksJson.map((json) {
      final map = json as Map<String, dynamic>;
      return Task(
        id: _uuid.v4(),
        title: map['title'] as String? ?? 'Untitled Task',
        notes: map['notes'] as String?,
        status: TaskStatus.todo,
        priority: _parsePriority(map['priority'] as String?),
        dueDate: map['dueDate'] != null
            ? DateTime.tryParse(map['dueDate'] as String)
            : null,
      );
    }).toList();
  }

  TaskPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}
