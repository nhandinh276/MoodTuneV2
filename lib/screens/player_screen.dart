import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moodtune_ai/core/nav_guard.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../state/app_state.dart';
import '../ui/ui_components.dart';
import '../ui/ui_tokens.dart';
import '../ui/ui_styles.dart';

class PlayerScreen extends StatefulWidget {
  final Track track;
  const PlayerScreen({super.key, required this.track});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final player = AudioPlayer();

  bool ready = false;
  bool searchingAlt = false;
  String? localError;

  bool _usingAltPreview = false;
  Track? _effectiveTrack;

  @override
  void initState() {
    super.initState();
    _effectiveTrack = widget.track;
    _initWithTrack(widget.track);
  }

  Future<void> _initWithTrack(Track track) async {
    try {
      setState(() {
        ready = false;
        localError = null;
        _usingAltPreview = false;
        _effectiveTrack = track;
      });

      await player.stop();

      // ✅ 1) Nếu có Spotify preview -> phát luôn
      if (track.previewUrl.trim().isNotEmpty) {
        await player.setUrl(track.previewUrl);
        setState(() => ready = true);
        return;
      }

      // ✅ 2) Không có preview từ Spotify -> thử Deezer
      final app = context.read<AppState>();
      final altPreview = await app.preview.findDeezerPreviewUrl(
        trackName: track.name,
        artistName: track.artist,
      );

      if (!mounted) return;

      if (altPreview != null && altPreview.trim().isNotEmpty) {
        final patched = track.copyWith(previewUrl: altPreview);
        _effectiveTrack = patched;
        _usingAltPreview = true;

        await player.setUrl(altPreview);
        setState(() {
          localError = null;
          ready = true;
        });
        return;
      }

      // ✅ 3) Không tìm thấy preview ở đâu cả
      setState(() {
        localError =
            "Bài này không có preview 30s trên Spotify và cũng không tìm thấy preview thay thế.\n"
            "Bạn có thể bấm “Tìm preview” hoặc “Mở Spotify”.";
        ready = true;
      });
    } catch (e) {
      setState(() {
        localError = "Lỗi phát preview: $e";
        ready = true;
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;

    final moodName = app.selectedMood?.name ?? "calm";
    final activity =
        app.lastAnalysis?.activity ?? "Nghe 1 bài và hít thở sâu 3 lần.";

    final t = _effectiveTrack ?? widget.track;
    final hasPreview = t.previewUrl.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Player")),
      body: Padding(
        padding: const EdgeInsets.all(UITokens.pad),
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _cover(context, t),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: UIStyles.h2(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.artist,
                          style: UIStyles.subtle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            MoodBadge(ok: true, text: "Mood: $moodName"),
                            const SizedBox(width: 8),
                            MoodBadge(
                              ok: hasPreview,
                              text: hasPreview
                                  ? (_usingAltPreview
                                        ? "Preview 30s (Alt)"
                                        : "Preview 30s")
                                  : "Không preview",
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    "Gợi ý hoạt động",
                    style: UIStyles.h2(context).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(activity, style: UIStyles.body(context)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nghe nhạc",
                    style: UIStyles.h2(context).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (!ready)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    if (localError != null) ...[
                      Text(localError!, style: TextStyle(color: cs.error)),
                      const SizedBox(height: 10),
                    ],
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snap) {
                        final state = snap.data;
                        final playing = state?.playing ?? false;
                        final processing = state?.processingState;
                        final isLoading =
                            processing == ProcessingState.loading ||
                            processing == ProcessingState.buffering;

                        return Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed:
                                    (!hasPreview ||
                                        localError != null ||
                                        isLoading)
                                    ? null
                                    : () async {
                                        if (playing) {
                                          await player.pause();
                                        } else {
                                          await player.play();
                                        }
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                label: Text(
                                  isLoading
                                      ? "Đang tải…"
                                      : (playing ? "Pause" : "Play 30s"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: searchingAlt
                                    ? null
                                    : () async {
                                        setState(() => searchingAlt = true);
                                        try {
                                          // ✅ Thử tìm Spotify preview trước
                                          final alt = await app.spotify
                                              .findPlayableAlternative(t);
                                          if (!mounted) return;

                                          if (alt != null) {
                                            await NavGuard.pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PlayerScreen(track: alt),
                                              ),
                                            );
                                            return;
                                          }

                                          // ✅ Nếu Spotify không có -> thử Deezer
                                          final altPreview = await app.preview
                                              .findDeezerPreviewUrl(
                                                trackName: t.name,
                                                artistName: t.artist,
                                              );

                                          if (!mounted) return;

                                          if (altPreview != null &&
                                              altPreview.trim().isNotEmpty) {
                                            final patched = t.copyWith(
                                              previewUrl: altPreview,
                                            );

                                            await NavGuard.pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) => PlayerScreen(
                                                  track: patched,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Không tìm thấy bản có preview 😥",
                                                ),
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                              () => searchingAlt = false,
                                            );
                                          }
                                        }
                                      },
                                icon: searchingAlt
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.search),
                                label: const Text("Tìm preview"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _openLinkDialog(context, t.externalUrl),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text("Spotify"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lưu / Chia sẻ",
                    style: UIStyles.h2(context).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            await context.read<AppState>().saveToHistory(
                              track: t,
                              note: "",
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã lưu ✅")),
                            );
                          },
                          icon: const Icon(Icons.bookmark_add),
                          label: const Text("Lưu nhật ký"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _shareDialog(context, t);
                          },
                          icon: const Icon(Icons.public),
                          label: const Text("Chia sẻ ẩn danh"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cover(BuildContext context, Track t) {
    final cs = Theme.of(context).colorScheme;

    if (t.imageUrl.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [cs.primary.withOpacity(0.9), cs.tertiary.withOpacity(0.9)],
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        t.imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: cs.surfaceContainerHighest,
          ),
          child: const Icon(Icons.music_note),
        ),
      ),
    );
  }

  Future<void> _shareDialog(BuildContext context, Track track) async {
    final c = TextEditingController();
    final app = context.read<AppState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chia sẻ ẩn danh"),
        content: TextField(
          controller: c,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Viết caption ngắn..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          FilledButton(
            onPressed: () async {
              await app.shareAnonymous(track: track, caption: c.text.trim());
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Đã gửi demo ✅")));
            },
            child: const Text("Đăng"),
          ),
        ],
      ),
    );
  }

  Future<void> _openLinkDialog(BuildContext context, String url) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Link Spotify"),
        content: SelectableText(url.isEmpty ? "Không có link" : url),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }
}
