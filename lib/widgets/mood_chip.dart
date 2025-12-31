import 'package:flutter/material.dart';
import '../models/mood.dart';

class MoodChip extends StatelessWidget {
  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  const MoodChip({
    super.key,
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? mood.color.withOpacity(0.22)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? mood.color : cs.outlineVariant,
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mood.icon, color: selected ? mood.color : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              mood.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? mood.color : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
