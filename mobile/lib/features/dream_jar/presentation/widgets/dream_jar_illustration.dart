import 'dart:math' as math;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The Dream Jar hero illustration, a direct transcription of the locked
/// design source's inline `<svg viewBox="0 0 120 168">` (`Cupid Screens.dc.html`,
/// `jar` screen) painted with [CustomPainter].
///
/// The design ships this as SVG, but the app has no SVG runtime and ADR-014a
/// forbids adding a `pubspec.yaml` dependency for one screen, so the same
/// geometry is painted directly. Every coordinate below is in the SVG's user
/// units; [DreamJarIllustrationPainter] scales that 120x168 space onto
/// whatever box it is given.
class DreamJarIllustration extends StatefulWidget {
  const DreamJarIllustration({
    super.key,
    required this.progressPercent,
    required this.semanticLabel,
  });

  /// Fill level, 0-100. Values above 100 render as a full jar.
  final int progressPercent;

  final String semanticLabel;

  /// `width:148px;height:207px` in the design source.
  static const Size designSize = Size(148, 207);

  @override
  State<DreamJarIllustration> createState() => _DreamJarIllustrationState();
}

class _DreamJarIllustrationState extends State<DreamJarIllustration>
    with TickerProviderStateMixin {
  /// `animation:bob 4.2s ...` and `animation:bob 5.4s ... 1s` on the two
  /// floating hearts.
  late final AnimationController _nearHeart = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  late final AnimationController _farHeart = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5400),
  );

  bool _isAnimating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour the platform "reduce motion" setting, which also makes widget
    // goldens deterministic without special-casing tests.
    _setAnimating(!MediaQuery.disableAnimationsOf(context));
  }

  void _setAnimating(bool shouldAnimate) {
    if (shouldAnimate == _isAnimating) return;
    _isAnimating = shouldAnimate;
    if (shouldAnimate) {
      _nearHeart.repeat();
      _farHeart.repeat();
    } else {
      _nearHeart
        ..stop()
        ..value = 0;
      _farHeart
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _nearHeart.dispose();
    _farHeart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: SizedBox.fromSize(
        size: DreamJarIllustration.designSize,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_nearHeart, _farHeart]),
          builder: (context, _) => CustomPaint(
            painter: DreamJarIllustrationPainter(
              progressPercent: widget.progressPercent,
              nearHeartPhase: _nearHeart.value,
              farHeartPhase: _farHeart.value,
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class DreamJarIllustrationPainter extends CustomPainter {
  const DreamJarIllustrationPainter({
    required this.progressPercent,
    required this.nearHeartPhase,
    required this.farHeartPhase,
  });

  final int progressPercent;

  /// 0-1 positions within one `bob` cycle for each floating heart.
  final double nearHeartPhase;
  final double farHeartPhase;

  static const Size _viewBox = Size(120, 168);
  static const Rect _glassBody = Rect.fromLTWH(14, 46, 92, 108);

  /// `{{ liquidY }} = 154 - 108 * min(1, jar / jarTarget)`.
  double get liquidY =>
      154 - 108 * (progressPercent / 100).clamp(0.0, 1.0).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _viewBox.width, size.height / _viewBox.height);

    final RRect glass = RRect.fromRectAndRadius(
      _glassBody,
      const Radius.circular(28),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 14, 60, 17),
        const Radius.circular(8.5),
      ),
      Paint()..color = DreamJarPalette.jarLidFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(36, 30, 48, 17),
        const Radius.circular(7),
      ),
      Paint()..color = DreamJarPalette.jarCollarFill,
    );
    canvas.drawRRect(glass, Paint()..color = DreamJarPalette.jarGlassFill);

    canvas.save();
    canvas.clipRRect(glass);
    _paintLiquid(canvas);
    canvas.restore();

    canvas.drawRRect(
      glass,
      Paint()
        ..color = DreamJarPalette.jarOutlineStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawPath(
      Path()
        ..moveTo(28, 66)
        ..cubicTo(24, 74, 24, 92, 28, 102),
      Paint()
        ..color = DreamJarPalette.jarHighlightStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    _paintBow(canvas);

    canvas.restore();
  }

  void _paintLiquid(Canvas canvas) {
    final double top = liquidY;
    // `<rect x="14" y="{{ liquidY }}" width="92" height="130">` — taller than
    // the jar on purpose; the glass clip trims the overflow.
    final Rect liquid = Rect.fromLTWH(14, top, 92, 130);
    canvas.drawRect(
      liquid,
      Paint()..shader = DreamJarPalette.jarLiquidGradient.createShader(liquid),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(60, top),
        width: 100, // rx 50
        height: 12, // ry 6
      ),
      Paint()..color = DreamJarPalette.jarMeniscusFill,
    );

    _paintHeart(canvas, const Offset(30, 116), 0.8, 0.55, nearHeartPhase);
    _paintHeart(canvas, const Offset(64, 128), 0.58, 0.4, farHeartPhase);

    canvas.drawCircle(
      const Offset(38, 140),
      3.4,
      Paint()..color = DreamJarPalette.jarFloaterFill.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      const Offset(76, 132),
      2.4,
      Paint()..color = DreamJarPalette.jarFloaterFill.withValues(alpha: 0.4),
    );
  }

  /// `@keyframes bob{0%,100%{translateY(0)}50%{translateY(-7px)}}`, eased.
  void _paintHeart(
    Canvas canvas,
    Offset origin,
    double scale,
    double opacity,
    double phase,
  ) {
    final double bob = -7 * (1 - math.cos(phase * 2 * math.pi)) / 2;

    canvas.save();
    canvas.translate(origin.dx, origin.dy + bob);
    canvas.scale(scale);
    canvas.drawPath(
      _heartPath,
      Paint()..color = DreamJarPalette.jarFloaterFill.withValues(alpha: opacity),
    );
    canvas.restore();
  }

  void _paintBow(Canvas canvas) {
    // Each wing is filled *and* stroked at width 5 with a round join, which
    // is what gives the ribbon its soft outline in the design source.
    final Paint fill = Paint()..color = DreamJarPalette.jarBowFill;
    final Paint stroke = Paint()
      ..color = DreamJarPalette.jarBowFill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round;

    for (final Path wing in <Path>[
      Path()
        ..moveTo(42, 8)
        ..lineTo(34, 16)
        ..lineTo(34, 2)
        ..close(),
      Path()
        ..moveTo(50, 8)
        ..lineTo(58, 16)
        ..lineTo(58, 2)
        ..close(),
    ]) {
      canvas.drawPath(wing, fill);
      canvas.drawPath(wing, stroke);
    }

    canvas.drawCircle(
      const Offset(46, 8),
      4.5,
      Paint()..color = DreamJarPalette.jarBowKnotFill,
    );
  }

  /// `M12 21.5C12 21.5 1.8 14.6 1.8 8.1C1.8 4.6 4.5 2.2 7.6 2.2C9.7 2.2 11.2
  /// 3.4 12 4.9C12.8 3.4 14.3 2.2 16.4 2.2C19.5 2.2 22.2 4.6 22.2 8.1C22.2
  /// 14.6 12 21.5 12 21.5Z`
  static final Path _heartPath = Path()
    ..moveTo(12, 21.5)
    ..cubicTo(12, 21.5, 1.8, 14.6, 1.8, 8.1)
    ..cubicTo(1.8, 4.6, 4.5, 2.2, 7.6, 2.2)
    ..cubicTo(9.7, 2.2, 11.2, 3.4, 12, 4.9)
    ..cubicTo(12.8, 3.4, 14.3, 2.2, 16.4, 2.2)
    ..cubicTo(19.5, 2.2, 22.2, 4.6, 22.2, 8.1)
    ..cubicTo(22.2, 14.6, 12, 21.5, 12, 21.5)
    ..close();

  @override
  bool shouldRepaint(DreamJarIllustrationPainter oldDelegate) =>
      oldDelegate.progressPercent != progressPercent ||
      oldDelegate.nearHeartPhase != nearHeartPhase ||
      oldDelegate.farHeartPhase != farHeartPhase;
}
