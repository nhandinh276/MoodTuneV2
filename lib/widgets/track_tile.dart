import 'package:flutter/material.dart';
import '../models/track.dart';
import '../ui/ui_components.dart';
import '../ui/ui_tokens.dart';
import '../ui/ui_styles.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const TrackTile({super.key, required this.track, this.onTap, this.onSave});

  bool get canPlay => track.streamUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UITokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UITokens.radiusLg),
          color: cs.surface.withOpacity(0.84),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.28)),
          boxShadow: UITokens.softShadow(cs.shadow),
        ),
        child: Row(
          children: [
            _cover(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UIStyles.h2(context).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UIStyles.subtle(context),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      MoodBadge(
                        ok: canPlay,
                        text: canPlay ? "Phát full" : "Không phát được",
                      ),
                      const SizedBox(width: 8),
                      MoodBadge(ok: true, text: track.source),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onSave != null)
              IconButton(
                onPressed: onSave,
                icon: Icon(Icons.bookmark_add_outlined, color: cs.onSurface),
                tooltip: "Lưu nhật ký",
              ),
          ],
        ),
      ),
    );
  }

  Widget _cover(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (track.imageUrl.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cs.primary.withOpacity(0.9), cs.tertiary.withOpacity(0.9)],
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        track.imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surfaceContainerHighest,
          ),
          child: const Icon(Icons.music_note),
        ),
      ),
    );
  }
}
