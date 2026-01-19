import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/mood_theme.dart';
import 'core/nav_guard.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'ui/ui_background.dart';

class MoodTuneApp extends StatelessWidget {
  const MoodTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final themeData = MoodTheme.buildTheme(
      baseMode: app.isDarkMode ? Brightness.dark : Brightness.light,
      accent: app.currentAccentColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MoodTune",
      theme: themeData,

      // ✅ KEY quan trọng để NavGuard điều hướng an toàn
      navigatorKey: NavGuard.key,

      builder: (context, child) =>
          UIBg(child: child ?? const SizedBox.shrink()),
      home: const SplashScreen(),
    );
  }
}
