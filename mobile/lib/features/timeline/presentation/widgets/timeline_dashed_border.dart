import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Dashed rounded-rect outline used by the "Add a memory" pill and the photo
/// placeholder frame. Hand-rolled path dashing rather than a new dependency --
/// `dash_path`-style dashing is a well-known ~15-line `CustomPainter`
/// technique.
class TimelineDashedBorder extends StatelessWidget {
  const TimelineDashedBorder({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const List<double> _dashPattern = <double>[6, 4];

  @override
  void paint(Canvas canvas, Size size) {
    final double cappedRadius = radius > size.height / 2
        ? size.height / 2
        : radius;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(cappedRadius),
    );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Path source = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(source), paint);
  }

  static Path _dashPath(Path source) {
    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      int dashIndex = 0;
      while (distance < metric.length) {
        final double length = _dashPattern[dashIndex % _dashPattern.length];
        final double next = (distance + length).clamp(0, metric.length);
        if (draw) {
          dest.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        draw = !draw;
        dashIndex++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
