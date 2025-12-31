import 'package:flutter/material.dart';

enum MoodType {
  happy,
  calm,
  sad,
  angry,
  anxious,
  focus,
  energetic,
  romantic,
  nostalgic,
  bored,
}

class Mood {
  final MoodType type;
  final String label;
  final IconData icon;
  final Color color;

  const Mood({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });

  static List<Mood> all() => const [
    Mood(
      type: MoodType.happy,
      label: "Vui",
      icon: Icons.sentiment_very_satisfied,
      color: Color(0xFFFFC107),
    ),
    Mood(
      type: MoodType.calm,
      label: "Bình yên",
      icon: Icons.spa,
      color: Color(0xFF00BCD4),
    ),
    Mood(
      type: MoodType.sad,
      label: "Buồn",
      icon: Icons.sentiment_dissatisfied,
      color: Color(0xFF3F51B5),
    ),
    Mood(
      type: MoodType.angry,
      label: "Bực",
      icon: Icons.local_fire_department,
      color: Color(0xFFF44336),
    ),
    Mood(
      type: MoodType.anxious,
      label: "Lo lắng",
      icon: Icons.psychology_alt,
      color: Color(0xFF9C27B0),
    ),
    Mood(
      type: MoodType.focus,
      label: "Tập trung",
      icon: Icons.center_focus_strong,
      color: Color(0xFF4CAF50),
    ),
    Mood(
      type: MoodType.energetic,
      label: "Năng lượng",
      icon: Icons.bolt,
      color: Color(0xFFFF5722),
    ),
    Mood(
      type: MoodType.romantic,
      label: "Lãng mạn",
      icon: Icons.favorite,
      color: Color(0xFFE91E63),
    ),
    Mood(
      type: MoodType.nostalgic,
      label: "Hoài niệm",
      icon: Icons.auto_stories,
      color: Color(0xFF795548),
    ),
    Mood(
      type: MoodType.bored,
      label: "Chán",
      icon: Icons.hourglass_empty,
      color: Color(0xFF607D8B),
    ),
  ];

  static Mood byType(MoodType type) =>
      all().firstWhere((m) => m.type == type, orElse: () => all().first);

  static MoodType fromString(String s) {
    final x = s.trim().toLowerCase();
    for (final m in all()) {
      if (m.type.name == x) return m.type;
    }
    // map Vietnamese keywords
    if (x.contains("vui")) return MoodType.happy;
    if (x.contains("buồn")) return MoodType.sad;
    if (x.contains("tập")) return MoodType.focus;
    if (x.contains("lo")) return MoodType.anxious;
    if (x.contains("bình")) return MoodType.calm;
    if (x.contains("năng")) return MoodType.energetic;
    return MoodType.calm;
  }
}
