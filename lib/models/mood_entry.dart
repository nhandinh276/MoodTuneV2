import 'track.dart';
import '../core/utils.dart';

class MoodEntry {
  final String id;
  final DateTime createdAt;
  final String mood; // MoodType.name
  final String note; // user text
  final Map<String, dynamic> analysis; // MoodAnalysis json
  final Track track;

  MoodEntry({
    required this.id,
    required this.createdAt,
    required this.mood,
    required this.note,
    required this.analysis,
    required this.track,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt.toIso8601String(),
    "mood": mood,
    "note": note,
    "analysis": analysis,
    "track": track.toJson(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: safeString(json["id"]),
    createdAt:
        DateTime.tryParse(safeString(json["createdAt"])) ?? DateTime.now(),
    mood: safeString(json["mood"]),
    note: safeString(json["note"]),
    analysis: (json["analysis"] as Map?)?.cast<String, dynamic>() ?? {},
    track: Track.fromJson((json["track"] as Map).cast<String, dynamic>()),
  );
}
