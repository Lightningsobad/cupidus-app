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

  static const double _strokeWidth = 1.5;

  /// Chromium draws the design source's `border:1.5px dashed var(--line)` at a
  /// ~3px dash and a ~2px gap, measured off the "Thêm kỷ niệm" button in the
  /// rendered canvas. The previous `[6, 4]` was double that rhythm and read as
  /// a visibly longer, sparser dash next to the design.
  static const List<double> _dashPattern = <double>[3, 2];

  @override
  void paint(Canvas canvas, Size size) {
    final double cappedRadius = radius > size.height / 2
        ? size.height / 2
        : radius;
    // A CSS border is painted inside the border box, while a Flutter stroke is
    // centred on its path, so the path must be the border's centreline --
    // otherwise half the stroke lands outside the box the design sizes.
    final RRect rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(_strokeWidth / 2),
      Radius.circular(cappedRadius - _strokeWidth / 2),
    );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
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
