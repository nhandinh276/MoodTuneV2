import 'package:flutter/material.dart';

class UITokens {
  static const double radiusLg = 24;
  static const double radiusMd = 18;
  static const double radiusSm = 14;

  static const double pad = 16;
  static const double padSm = 12;

  // ✅ Thêm duration để dùng cho animation (Settings đang cần UITokens.normal)
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 260);

  static List<BoxShadow> softShadow(Color c) => [
    BoxShadow(
      blurRadius: 24,
      offset: const Offset(0, 10),
      color: c.withOpacity(0.12),
    ),
    BoxShadow(
      blurRadius: 10,
      offset: const Offset(0, 2),
      color: c.withOpacity(0.08),
    ),
  ];

  static LinearGradient moodGradient(Color seed, {bool dark = false}) {
    final a = seed;
    final b = Color.lerp(seed, Colors.white, dark ? 0.06 : 0.30)!;
    final c = Color.lerp(seed, Colors.black, dark ? 0.38 : 0.10)!;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [b, a, c],
      stops: const [0.0, 0.55, 1.0],
    );
  }
}
