import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../ui/ui_components.dart';
import '../ui/ui_styles.dart';
import '../ui/ui_tokens.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> feed = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final app = context.read<AppState>();
      final data = await app.community.fetchFeed();
      setState(() => feed = data);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ LOADING UI (Glass)
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(UITokens.pad),
        child: Column(
          children: [
            HeroHeader(
              title: "Cộng đồng",
              subtitle: "Đang tải bài đăng từ cộng đồng MoodTune...",
              trailing: IconButton(
                tooltip: "Tải lại",
                icon: const Icon(Icons.refresh),
                onPressed: _load,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Đang tải dữ liệu…",
                      style: UIStyles.body(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => _skeletonPost(context),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ ERROR UI (Glass)
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(UITokens.pad),
        child: Column(
          children: [
            HeroHeader(
              title: "Cộng đồng",
              subtitle: "Không thể tải dữ liệu. Vui lòng thử lại.",
              trailing: IconButton(
                tooltip: "Tải lại",
                icon: const Icon(Icons.refresh),
                onPressed: _load,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: cs.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(error!, style: TextStyle(color: cs.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text("Thử lại"),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ NORMAL UI (Glass + Vietnamese)
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(UITokens.pad),
        children: [
          HeroHeader(
            title: "Cộng đồng MoodTune",
            subtitle:
                "Xem mọi người đang chia sẻ cảm xúc & bài nhạc gì hôm nay.",
            trailing: IconButton(
              tooltip: "Tải lại",
              icon: const Icon(Icons.refresh),
              onPressed: _load,
            ),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Kéo xuống để tải lại. Chạm vào bài để xem chi tiết (nếu bạn có tính năng).",
                    style: UIStyles.subtle(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (feed.isEmpty)
            GlassCard(
              child: Column(
                children: [
                  Icon(Icons.public, size: 34, color: cs.onSurfaceVariant),
                  const SizedBox(height: 10),
                  Text(
                    "Chưa có bài đăng nào.",
                    style: UIStyles.h2(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Hãy quay lại sau hoặc thử tải lại nhé.",
                    style: UIStyles.subtle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Tải lại"),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              "Bài đăng nổi bật",
              style: UIStyles.h2(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: feed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = feed[i];
                final title = (p["title"] ?? "").toString().trim();
                final body = (p["body"] ?? "").toString().trim();

                return _communityPostCard(
                  context,
                  title: title.isEmpty ? "Bài chia sẻ" : title,
                  body: body.isEmpty ? "Không có nội dung." : body,
                );
              },
            ),
          ],

          const SizedBox(height: 18),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Lưu ý: Đây là nguồn demo. Nội dung có thể được ẩn danh tuỳ theo cấu hình dự án.",
                    style: UIStyles.subtle(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _communityPostCard(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UITokens.radiusLg),
        color: cs.surface.withOpacity(0.84),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.28)),
        boxShadow: UITokens.softShadow(cs.shadow),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.95),
                  cs.tertiary.withOpacity(0.95),
                ],
              ),
            ),
            child: const Icon(Icons.public, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UIStyles.h2(context).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: UIStyles.body(context),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    MoodBadge(ok: true, text: "Cộng đồng"),
                    const SizedBox(width: 8),
                    MoodBadge(ok: true, text: "Ẩn danh"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _skeletonPost(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UITokens.radiusLg),
        color: cs.surface.withOpacity(0.80),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cs.surfaceContainerHighest.withOpacity(0.65),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: cs.surfaceContainerHighest.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: cs.surfaceContainerHighest.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
