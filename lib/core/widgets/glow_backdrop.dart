import 'package:flutter/material.dart';

import '../theme/aura.dart';

enum GlowShape {
  /// Glow across the top half, fading into the page (home, chat).
  top,

  /// Glow around the edges with a clear well in the middle for the voice orb.
  well,
}

/// The soft colour wash behind each screen: Aruba Aqua on white in light
/// mode, a faint charcoal on black in dark mode.
class GlowBackdrop extends StatelessWidget {
  final GlowShape shape;
  final double reach; // how far down the top glow fades out, 0–1
  final Alignment wellCenter;
  final Widget child;

  const GlowBackdrop({
    super.key,
    this.shape = GlowShape.top,
    this.reach = 0.55,
    this.wellCenter = const Alignment(0, -0.2),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    if (shape == GlowShape.well) {
      return DecoratedBox(
        decoration: BoxDecoration(color: a.glow),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: wellCenter,
              radius: 1.05,
              colors: [a.bg, a.bg, a.bg.withValues(alpha: 0)],
              stops: const [0.0, 0.42, 1.0],
            ),
          ),
          child: child,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: a.bg,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a.glow, a.glow.withValues(alpha: 0.35), a.bg],
          stops: [0, reach * 0.55, reach],
        ),
      ),
      child: child,
    );
  }
}
