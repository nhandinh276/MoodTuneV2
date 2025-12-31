import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';
import 'recommendations_screen.dart';

class MoodQuizScreen extends StatefulWidget {
  const MoodQuizScreen({super.key});

  @override
  State<MoodQuizScreen> createState() => _MoodQuizScreenState();
}

class _MoodQuizScreenState extends State<MoodQuizScreen> {
  int energyChoice = 1;
  int vibeChoice = 1;
  int socialChoice = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Không biết mood?")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Trả lời nhanh 3 câu, app sẽ chọn mood phù hợp.",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            _q(
              title: "1) Mức năng lượng hiện tại?",
              value: energyChoice,
              labels: const ["Thấp", "Vừa", "Cao"],
              onChanged: (v) => setState(() => energyChoice = v),
            ),
            const SizedBox(height: 12),
            _q(
              title: "2) Bạn muốn nhạc như thế nào?",
              value: vibeChoice,
              labels: const ["Êm", "Cân bằng", "Bùng nổ"],
              onChanged: (v) => setState(() => vibeChoice = v),
            ),
            const SizedBox(height: 12),
            _q(
              title: "3) Bạn đang muốn…",
              value: socialChoice,
              labels: const ["Ở một mình", "Bình thường", "Kết nối"],
              onChanged: (v) => setState(() => socialChoice = v),
            ),

            const SizedBox(height: 16),
            PrimaryButton(
              text: "Ra mood & gợi ý nhạc",
              icon: Icons.graphic_eq,
              onPressed: () async {
                final mood = context.read<AppState>().moodFromQuiz(
                  energyChoice: energyChoice,
                  vibeChoice: vibeChoice,
                  socialChoice: socialChoice,
                );

                await context.read<AppState>().recommendFromMood(mood);
                if (!mounted) return;

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const RecommendationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _q({
    required String title,
    required int value,
    required List<String> labels,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(labels[0])),
                ButtonSegment(value: 1, label: Text(labels[1])),
                ButtonSegment(value: 2, label: Text(labels[2])),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
