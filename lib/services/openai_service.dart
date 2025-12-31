import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/env.dart';
import '../models/mood_analysis.dart';
import '../models/mood.dart';

class OpenAIService {
  Future<MoodAnalysis> analyzeMoodFromText(String text) async {
    final key = Env.openAiApiKey;
    if (key.isEmpty) {
      // fallback if user doesn't set key: simple heuristic
      final lower = text.toLowerCase();
      MoodType mood = MoodType.calm;
      if (lower.contains("buồn") ||
          lower.contains("khóc") ||
          lower.contains("mất"))
        mood = MoodType.sad;
      if (lower.contains("vui") ||
          lower.contains("hạnh phúc") ||
          lower.contains("tuyệt"))
        mood = MoodType.happy;
      if (lower.contains("lo") ||
          lower.contains("sợ") ||
          lower.contains("căng"))
        mood = MoodType.anxious;
      if (lower.contains("tức") || lower.contains("giận"))
        mood = MoodType.angry;

      return MoodAnalysis(
        mood: mood,
        valence: mood == MoodType.happy
            ? 0.8
            : (mood == MoodType.sad ? 0.2 : 0.5),
        energy: mood == MoodType.angry
            ? 0.85
            : (mood == MoodType.calm ? 0.25 : 0.5),
        tags: const ["fallback"],
        activity: "Uống nước và hít thở sâu 1 phút.",
        summary:
            "Mình đang dùng chế độ phân tích đơn giản vì bạn chưa nhập OPENAI_API_KEY.",
      );
    }

    final uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    final body = {
      "model": "gpt-4.1-mini",
      "messages": [
        {
          "role": "system",
          "content":
              "Bạn là bộ phân tích cảm xúc. Hãy đọc mô tả và trả về JSON đúng schema. "
              "mood chỉ dùng 1 trong: happy, calm, sad, angry, anxious, focus, energetic, romantic, nostalgic, bored. "
              "valence và energy là số 0..1. activity là gợi ý hoạt động ngắn 1 câu. summary là tóm tắt 1 câu.",
        },
        {"role": "user", "content": "Mô tả cảm xúc:\n$text"},
      ],
      "response_format": {
        "type": "json_schema",
        "json_schema": {
          "name": "mood_result",
          "schema": {
            "type": "object",
            "properties": {
              "mood": {"type": "string"},
              "valence": {"type": "number"},
              "energy": {"type": "number"},
              "tags": {
                "type": "array",
                "items": {"type": "string"},
              },
              "activity": {"type": "string"},
              "summary": {"type": "string"},
            },
            "required": [
              "mood",
              "valence",
              "energy",
              "tags",
              "activity",
              "summary",
            ],
          },
        },
      },
    };

    final res = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $key",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("OpenAI error: ${res.statusCode} - ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final content =
        (((json["choices"] as List).first as Map)["message"] as Map)["content"]
            as String;

    final parsed = jsonDecode(content) as Map<String, dynamic>;
    return MoodAnalysis.fromJson(parsed);
  }
}
