import 'dart:ui';
import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class UIBg extends StatelessWidget {
  final Widget child;
  const UIBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final seed = cs.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: UITokens.moodGradient(seed, dark: dark),
          ),
        ),

        Positioned(
          top: -90,
          right: -70,
          child: _GlowBlob(
            color: cs.primaryContainer.withOpacity(0.75),
            size: 260,
          ),
        ),
        Positioned(
          bottom: -110,
          left: -80,
          child: _GlowBlob(
            color: cs.tertiaryContainer.withOpacity(0.65),
            size: 300,
          ),
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(color: cs.surface.withOpacity(dark ? 0.36 : 0.42)),
        ),

        SafeArea(child: child),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            blurRadius: 140,
            spreadRadius: 28,
            color: color.withOpacity(0.40),
          ),
        ],
      ),
    );
  }
}
