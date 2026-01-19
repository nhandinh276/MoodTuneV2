import 'package:flutter/material.dart';

import 'mood_picker_screen.dart';
import 'mood_text_ai_screen.dart';
import 'history_screen.dart';
import 'community_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      MoodPickerScreen(),
      MoodTextAIScreen(),
      HistoryScreen(),
      CommunityScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("MoodTune"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mood), label: "Mood"),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: "AI"),
          NavigationDestination(icon: Icon(Icons.history), label: "History"),
          NavigationDestination(icon: Icon(Icons.public), label: "Community"),
        ],
      ),
    );
  }
}
