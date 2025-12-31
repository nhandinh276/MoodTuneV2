import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_title.dart';
import 'recommendations_screen.dart';

class MoodTextAIScreen extends StatefulWidget {
  const MoodTextAIScreen({super.key});

  @override
  State<MoodTextAIScreen> createState() => _MoodTextAIScreenState();
}

class _MoodTextAIScreenState extends State<MoodTextAIScreen> {
  final controller = TextEditingController();
  bool submitted = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return LoadingOverlay(
      show: app.loading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: "Mô tả cảm xúc (AI)",
              subtitle:
                  "Viết 1–2 câu. AI sẽ đoán mood + gợi ý nhạc + gợi ý hoạt động.",
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText:
                    "Ví dụ: Hôm nay mình mệt và hơi lo, chỉ muốn yên tĩnh một chút…",
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: "Phân tích & gợi ý nhạc",
              icon: Icons.auto_awesome,
              onPressed: app.loading
                  ? null
                  : () async {
                      setState(() => submitted = true);
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      await context.read<AppState>().recommendFromText(text);
                      if (!mounted) return;

                      if (context.read<AppState>().error == null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecommendationsScreen(),
                          ),
                        );
                      }
                    },
            ),

            if (submitted && controller.text.trim().isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                "Bạn chưa nhập mô tả.",
                style: TextStyle(color: Colors.red),
              ),
            ],

            if (app.lastAnalysis != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kết quả AI",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text("Mood: ${app.lastAnalysis!.mood.name}"),
                      Text(
                        "Valence: ${app.lastAnalysis!.valence.toStringAsFixed(2)}",
                      ),
                      Text(
                        "Energy: ${app.lastAnalysis!.energy.toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: 8),
                      Text("Gợi ý hoạt động: ${app.lastAnalysis!.activity}"),
                      const SizedBox(height: 6),
                      Text(
                        app.lastAnalysis!.summary,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (app.error != null) ...[
              const SizedBox(height: 12),
              Text(app.error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
