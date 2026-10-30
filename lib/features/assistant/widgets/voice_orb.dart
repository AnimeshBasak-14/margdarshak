import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/aura.dart';

/// The glowing sphere at the heart of the voice screen. Soft light drifts
/// across it on its own; [level] (0–1, the live mic loudness) makes it swell
/// and brighten while the user speaks.
class VoiceOrb extends StatefulWidget {
  final double size;
  final ValueListenable<double>? level;

  /// Small orbs (chat avatars) can stay still to save battery.
  final bool animate;

  const VoiceOrb({super.key, required this.size, this.level, this.animate = true});

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _drift.repeat();
  }

  @override
  void didUpdateWidget(VoiceOrb old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_drift.isAnimating) {
      _drift.repeat();
    } else if (!widget.animate) {
      _drift.stop();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final level = widget.level ?? const AlwaysStoppedAnimation(0.0);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_drift, level]),
        builder: (context, _) {
          final l = reduceMotion ? 0.0 : level.value.clamp(0.0, 1.0);
          return CustomPaint(
            size: Size.square(widget.size),
            painter: _OrbPainter(
              t: reduceMotion ? 0.15 : _drift.value,
              level: l,
              colors: a.orb,
              halo: a.orbHalo,
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  final double level;
  final List<Color> colors; // highlight, glow, mid, deep, deepest
  final Color halo;

  _OrbPainter({
    required this.t,
    required this.level,
    required this.colors,
    required this.halo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Leave room for the halo and the swell.
    final r = size.width / 2 * 0.86 * (1 + level * 0.05);
    final a = t * math.pi * 2;

    // Halo behind the sphere.
    canvas.drawCircle(
      c + Offset(0, r * 0.06),
      r * (0.92 + level * 0.1),
      Paint()
        ..color = halo.withValues(alpha: halo.a * (0.7 + level * 0.6))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.22),
    );

    final sphere = Rect.fromCircle(center: c, radius: r);
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Body: lit from the upper left, falling into shadow at the lower right.
    canvas.drawRect(
      sphere,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.45),
          radius: 1.15,
          colors: [colors[1], colors[2], colors[3], colors[4]],
          stops: const [0.0, 0.38, 0.72, 1.0],
        ).createShader(sphere),
    );

    void blob(Offset at, double radius, Color color, double blur) {
      canvas.drawCircle(
        c + at * r,
        radius * r,
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * r),
      );
    }

    // Drifting light, like the swirl in a glass marble.
    blob(
      Offset(-0.28 + math.cos(a) * 0.14, -0.3 + math.sin(a * 2) * 0.1),
      0.42 + level * 0.12,
      colors[0].withValues(alpha: 0.75 + level * 0.25),
      0.24,
    );
    blob(
      Offset(0.18 + math.sin(a + 1.3) * 0.18, -0.05 + math.cos(a * 3) * 0.12),
      0.34,
      colors[1].withValues(alpha: 0.55),
      0.22,
    );
    // Shadow that rolls around the lower edge.
    blob(
      Offset(0.42 + math.cos(a * 2 + 0.6) * 0.1, 0.45 + math.sin(a) * 0.08),
      0.55,
      colors[4].withValues(alpha: 0.7),
      0.3,
    );
    // A bright fleck that sharpens with the voice.
    blob(
      Offset(-0.36 + math.sin(a * 2) * 0.05, -0.42 + math.cos(a) * 0.04),
      0.12 + level * 0.05,
      colors[0].withValues(alpha: 0.5 + level * 0.5),
      0.08,
    );

    canvas.restore();

    // Thin rim of reflected light along the lower right edge.
    canvas.drawArc(
      sphere.deflate(0.6),
      -0.2,
      math.pi * 0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * 0.012)
        ..shader = SweepGradient(
          startAngle: -0.2,
          endAngle: math.pi * 0.7,
          colors: [
            colors[0].withValues(alpha: 0),
            colors[0].withValues(alpha: 0.35),
            colors[0].withValues(alpha: 0),
          ],
        ).createShader(sphere),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.t != t || old.level != level || old.colors != colors;
}
