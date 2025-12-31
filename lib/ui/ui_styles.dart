import 'package:flutter/material.dart';

class UIStyles {
  static TextStyle h1(BuildContext c) => Theme.of(c).textTheme.headlineMedium!
      .copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.8);

  static TextStyle h2(BuildContext c) => Theme.of(c).textTheme.titleLarge!
      .copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3);

  static TextStyle body(BuildContext c) =>
      Theme.of(c).textTheme.bodyMedium!.copyWith(height: 1.25);

  static TextStyle subtle(BuildContext c) => Theme.of(c).textTheme.bodySmall!
      .copyWith(color: Theme.of(c).colorScheme.onSurfaceVariant, height: 1.25);

  static TextStyle badge(BuildContext c, {required bool ok}) =>
      Theme.of(c).textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
        color: ok
            ? Theme.of(c).colorScheme.primary
            : Theme.of(c).colorScheme.error,
      );
}
