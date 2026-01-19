import 'package:flutter/material.dart';
import 'package:moodtune_ai/core/nav_guard.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../state/app_state.dart';
import '../widgets/track_tile.dart';
import 'player_screen.dart';
import '../ui/ui_components.dart';
import '../ui/ui_tokens.dart';
import '../ui/ui_styles.dart';

class RecommendationsScreen extends StatefulWidget {
  final bool openTodayPick;
  const RecommendationsScreen({super.key, this.openTodayPick = false});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _navBusy = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final allTracks = app.recommendations;

    Track? todayPick;
    if (widget.openTodayPick) {
      todayPick = app.getTodayPick();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Gợi ý nhạc")),
      body: Padding(
        padding: const EdgeInsets.all(UITokens.pad),
        child: Column(
          children: [
            HeroHeader(
              title: "Danh sách phù hợp mood của bạn",
              subtitle:
                  app.lastAnalysis?.activity ?? "Chọn 1 bài và thả lỏng nhé.",
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.55),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.headphones, size: 18),
                    const SizedBox(width: 6),
                    Text("Audius", style: UIStyles.subtle(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (todayPick != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: Text(
                    "Bài nhạc hôm nay",
                    style: UIStyles.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    "${todayPick.name} • ${todayPick.artist}",
                    style: UIStyles.subtle(context),
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _openTrack(context, todayPick!),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(child: _buildList(context, allTracks)),
            if (app.error != null) ...[
              const SizedBox(height: 10),
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
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Track> allTracks) {
    if (allTracks.isEmpty) {
      return Center(
        child: GlassCard(
          child: Text(
            "Chưa có gợi ý.\nHãy chọn mood hoặc mô tả cảm xúc trước.",
            style: UIStyles.subtle(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: allTracks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final t = allTracks[i];
        return TrackTile(
          track: t,
          onTap: () => _openTrack(context, t),
          onSave: () async => _saveDialog(context, t),
        );
      },
    );
  }

  Future<void> _openTrack(BuildContext context, Track t) async {
    if (_navBusy) return;
    _navBusy = true;

    try {
      await Future.delayed(Duration.zero);
      if (!context.mounted) return;

      await NavGuard.push(
        MaterialPageRoute(builder: (_) => PlayerScreen(track: t)),
      );
    } finally {
      _navBusy = false;
    }
  }

  Future<void> _saveDialog(BuildContext context, Track track) async {
    final noteController = TextEditingController();
    final app = context.read<AppState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottom + 16,
          ),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lưu vào nhật ký", style: UIStyles.h2(context)),
                const SizedBox(height: 8),
                Text(
                  track.name,
                  style: UIStyles.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Ghi chú ngắn (tùy chọn)…",
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await app.saveToHistory(
                            track: track,
                            note: noteController.text.trim(),
                          );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã lưu ✅")),
                          );
                        },
                        icon: const Icon(Icons.bookmark_add),
                        label: const Text("Lưu"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
