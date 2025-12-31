import 'package:flutter/material.dart';
import 'ui_tokens.dart';
import 'ui_styles.dart';

class HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final IconData icon;

  const HeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.icon = Icons.auto_awesome,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(UITokens.pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UITokens.radiusLg),
        color: cs.surface.withOpacity(0.80),
        boxShadow: UITokens.softShadow(cs.shadow),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.95),
                  cs.tertiary.withOpacity(0.95),
                ],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: UIStyles.h2(context)),
                const SizedBox(height: 6),
                Text(subtitle, style: UIStyles.subtle(context)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(UITokens.pad),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UITokens.radiusLg),
        color: cs.surface.withOpacity(0.78),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.32)),
        boxShadow: UITokens.softShadow(cs.shadow),
      ),
      child: child,
    );
  }
}

class MoodBadge extends StatelessWidget {
  final bool ok;
  final String text;

  const MoodBadge({super.key, required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: ok ? cs.primary.withOpacity(0.14) : cs.error.withOpacity(0.12),
        border: Border.all(
          color: (ok ? cs.primary : cs.error).withOpacity(0.25),
        ),
      ),
      child: Text(text, style: UIStyles.badge(context, ok: ok)),
    );
  }
}
