import '../core/utils.dart';
import 'mood.dart';

class MoodAnalysis {
  final MoodType mood;
  final double valence; // 0..1 (happy)
  final double energy; // 0..1 (energetic)
  final List<String> tags;
  final String activity;
  final String summary;

  const MoodAnalysis({
    required this.mood,
    required this.valence,
    required this.energy,
    required this.tags,
    required this.activity,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
    "mood": mood.name,
    "valence": valence,
    "energy": energy,
    "tags": tags,
    "activity": activity,
    "summary": summary,
  };

  factory MoodAnalysis.fromJson(Map<String, dynamic> json) {
    final mood = Mood.fromString(safeString(json["mood"]));
    final valence = clamp01(
      (json["valence"] is num) ? (json["valence"] as num).toDouble() : 0.5,
    );
    final energy = clamp01(
      (json["energy"] is num) ? (json["energy"] as num).toDouble() : 0.5,
    );
    final tagsRaw = (json["tags"] as List?) ?? [];
    final tags = tagsRaw
        .map((e) => safeString(e))
        .where((e) => e.isNotEmpty)
        .toList();
    final activity = safeString(json["activity"]);
    final summary = safeString(json["summary"]);

    return MoodAnalysis(
      mood: mood,
      valence: valence,
      energy: energy,
      tags: tags,
      activity: activity,
      summary: summary,
    );
  }
}
