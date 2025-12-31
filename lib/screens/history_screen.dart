import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/date_utils.dart';
import '../state/app_state.dart';
import '../ui/ui_components.dart';
import '../ui/ui_tokens.dart';
import '../ui/ui_styles.dart';
import 'player_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.history;

    return Padding(
      padding: const EdgeInsets.all(UITokens.pad),
      child: Column(
        children: [
          HeroHeader(
            title: "Nhật ký cảm xúc",
            subtitle: "Những bài nhạc bạn đã lưu theo mood — chạm để mở lại.",
            trailing: IconButton(
              tooltip: "Tải lại",
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                // nếu bạn có hàm reload history thì gọi ở đây (giữ logic)
                // await context.read<AppState>().loadHistory();
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: items.isEmpty
                ? Center(
                    child: GlassCard(
                      child: Text(
                        "Chưa có nhật ký.\nHãy lưu một bài nhạc theo mood nhé!",
                        textAlign: TextAlign.center,
                        style: UIStyles.subtle(context),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final e = items[i];
                      final dt = formatDateTimeVN(e.createdAt);

                      return GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlayerScreen(track: e.track),
                            ),
                          ),
                          leading: const Icon(Icons.history),
                          title: Text(
                            "${e.track.name} • ${e.track.artist}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UIStyles.body(
                              context,
                            ).copyWith(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                MoodBadge(ok: true, text: "Mood: ${e.mood}"),
                                const SizedBox(width: 8),
                                MoodBadge(ok: true, text: dt),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: "Xóa",
                            onPressed: () async {
                              await context.read<AppState>().deleteHistory(
                                e.id,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Đã xóa ✅")),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
