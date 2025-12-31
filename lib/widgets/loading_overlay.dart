import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool show;
  final Widget child;

  const LoadingOverlay({super.key, required this.show, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.15),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
