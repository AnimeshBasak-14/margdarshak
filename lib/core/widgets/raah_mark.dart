import 'package:flutter/material.dart';

/// The Raah mark: a road that bends up from the bottom left towards a
/// dot, the place you were trying to get to. 64-unit grid.
class RaahMark extends StatelessWidget {
  final double size;
  final Color color;
  const RaahMark({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _MarkPainter(color));
}

class _MarkPainter extends CustomPainter {
  final Color color;
  _MarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64);
    final road = Path()
      ..moveTo(18, 54)
      ..cubicTo(18, 34, 46, 44, 46, 26);
    canvas.drawPath(
      road,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(46, 12), 6.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.color != color;
}
