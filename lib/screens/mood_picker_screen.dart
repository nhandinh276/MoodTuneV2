import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood.dart';
import '../state/app_state.dart';
import '../widgets/mood_chip.dart';
import '../widgets/primary_button.dart';
import '../ui/ui_components.dart';
import '../ui/ui_tokens.dart';
import '../ui/ui_styles.dart';
import 'mood_quiz_screen.dart';
import 'recommendations_screen.dart';

class MoodPickerScreen extends StatefulWidget {
  const MoodPickerScreen({super.key});

  @override
  State<MoodPickerScreen> createState() => _MoodPickerScreenState();
}

class _MoodPickerScreenState extends State<MoodPickerScreen> {
  MoodType? selected;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final moods = Mood.all();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UITokens.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroHeader(
            title: "Chọn cảm xúc của bạn",
            subtitle: "Chạm 1 mood — app tự đổi theme & gợi ý nhạc phù hợp.",
            trailing: IconButton(
              tooltip: "Không biết mood?",
              icon: const Icon(Icons.quiz),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MoodQuizScreen())),
            ),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in moods)
                  MoodChip(
                    mood: m,
                    selected: selected == m.type,
                    onTap: () => setState(() => selected = m.type),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gợi ý nhanh",
                  style: UIStyles.h2(context).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  "Bạn có thể chọn mood hoặc làm quiz để app tự đoán mood.",
                  style: UIStyles.subtle(context),
                ),
                const SizedBox(height: 12),

                PrimaryButton(
                  text: "Gợi ý nhạc theo mood",
                  icon: Icons.graphic_eq,
                  onPressed: app.loading || selected == null
                      ? null
                      : () async {
                          await context.read<AppState>().recommendFromMood(
                            selected!,
                          );
                          if (!mounted) return;

                          // ✅ giữ logic: điều hướng như bạn đang làm (tránh lỗi debugLocked)
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RecommendationsScreen(),
                              ),
                            );
                          });
                        },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🎁 1 bài nhạc cho hôm nay",
                  style: UIStyles.h2(context).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  "Nếu bạn đã có danh sách gợi ý, app sẽ chọn 1 bài “định mệnh” theo ngày.",
                  style: UIStyles.subtle(context),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: app.recommendations.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RecommendationsScreen(
                                  openTodayPick: true,
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Mở bài hôm nay"),
                  ),
                ),
              ],
            ),
          ),

          if (app.error != null) ...[
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.error_outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      app.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
