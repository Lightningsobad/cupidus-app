import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../data/pet_mood.dart';

/// Pure-Flutter vector rendering of the `Bun Sprite` design component
/// (`cupid-mobile-design/Bun Sprite.dc.html`), restricted to the five
/// [BunSpriteState] values this story is allowed to render — the design's
/// sixth `sleep` state has no backend equivalent and is intentionally absent
/// from [BunSpriteState] itself (`ux/uiux-spec.md` §3).
///
/// [size] must be one of the three fixed UX sizes (206 hero, 74 dashboard
/// preview, 46 "how Bun reacts" row — `ux/uiux-spec.md` §6); geometry is
/// authored against the design source's 200x200 viewBox and scaled to fit, so
/// any size renders correctly without branching.
///
/// The sprite is decorative — mood is conveyed via the level pill and status
/// line, not this widget (`ux/uiux-spec.md` §7) — so it is excluded from the
/// semantics tree entirely.
class BunSprite extends StatefulWidget {
  const BunSprite({super.key, required this.state, required this.size});

  final BunSpriteState state;
  final double size;

  @override
  State<BunSprite> createState() => _BunSpriteState();
}

class _BunSpriteState extends State<BunSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bobController = AnimationController(
    vsync: this,
    duration: _bobHalfCycle(widget.state),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant BunSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _bobController.duration = _bobHalfCycle(widget.state);
      _syncMotion();
    }
  }

  /// Design source: "Dỗi và ốm thì đứng yên — đó là tín hiệu" (`Bun Pet
  /// Art.dc.html`) — sulk and sick intentionally hold a still pose as their
  /// own signal, so only happy/inlove/neutral bob.
  static bool _bobs(BunSpriteState state) => switch (state) {
        BunSpriteState.happy || BunSpriteState.inlove || BunSpriteState.neutral =>
          true,
        BunSpriteState.sulk || BunSpriteState.sick => false,
      };

  /// Half of the source `bunBob` keyframe's full up-down cycle length, one
  /// per bobbing state (`Bun Sprite.dc.html` inline `animation:bunBob <Ns>`).
  static Duration _bobHalfCycle(BunSpriteState state) => switch (state) {
        BunSpriteState.happy => const Duration(milliseconds: 1600),
        BunSpriteState.inlove => const Duration(milliseconds: 1300),
        BunSpriteState.neutral => const Duration(milliseconds: 2000),
        BunSpriteState.sulk ||
        BunSpriteState.sick =>
          const Duration(milliseconds: 1600),
      };

  void _syncMotion() {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_bobs(widget.state) && !reduceMotion) {
      if (!_bobController.isAnimating) {
        _bobController.repeat(reverse: true);
      }
    } else {
      _bobController.stop();
      _bobController.value = 0;
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _bobController,
          builder: (BuildContext context, Widget? _) {
            final double bobOffset = _bobs(widget.state)
                ? -6 * Curves.easeInOut.transform(_bobController.value)
                : 0;
            return CustomPaint(
              painter: _BunSpritePainter(
                state: widget.state,
                bobOffset: bobOffset,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shared body palette (`Bun Pet Art.dc.html` "Bảng màu của Bún"). Only
/// [BunSpriteState.sick] overrides these with its own paler tones; the other
/// four bobbing/still states share one palette because the body/ears/tail
/// never change shape or color across them.
class _BunPalette {
  const _BunPalette({
    required this.furTop,
    required this.furBottom,
    required this.tail,
    required this.earOuter,
    required this.earInner,
    required this.belly,
    required this.feet,
  });

  final Color furTop;
  final Color furBottom;
  final Color tail;
  final Color earOuter;
  final Color earInner;
  final Color belly;
  final Color feet;

  static const _BunPalette standard = _BunPalette(
    furTop: BunSpritePalette.furTop,
    furBottom: BunSpritePalette.furBottom,
    tail: BunSpritePalette.tail,
    earOuter: BunSpritePalette.earOuter,
    earInner: BunSpritePalette.earInner,
    belly: BunSpritePalette.belly,
    feet: BunSpritePalette.feet,
  );

  static const _BunPalette sick = _BunPalette(
    furTop: BunSpritePalette.sickFurTop,
    furBottom: BunSpritePalette.sickFurBottom,
    tail: BunSpritePalette.sickTail,
    earOuter: BunSpritePalette.sickEarOuter,
    earInner: BunSpritePalette.sickEarInner,
    belly: BunSpritePalette.sickBelly,
    feet: BunSpritePalette.sickFeet,
  );

  static _BunPalette forState(BunSpriteState state) =>
      state == BunSpriteState.sick ? sick : standard;
}

class _BunSpritePainter extends CustomPainter {
  _BunSpritePainter({required this.state, required this.bobOffset});

  final BunSpriteState state;
  final double bobOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 200;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(0, bobOffset);

    _paintSharedBody(canvas, _BunPalette.forState(state));
    switch (state) {
      case BunSpriteState.happy:
        _paintHappyFace(canvas);
      case BunSpriteState.inlove:
        _paintInloveFace(canvas);
      case BunSpriteState.neutral:
        _paintNeutralFace(canvas);
      case BunSpriteState.sulk:
        _paintSulkFace(canvas);
      case BunSpriteState.sick:
        _paintSickFace(canvas);
    }

    canvas.restore();
  }

  static void _paintSharedBody(Canvas canvas, _BunPalette palette) {
    final Paint tailPaint = Paint()
      ..color = palette.tail
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(144, 154)
        ..cubicTo(166, 162, 182, 150, 180, 133)
        ..cubicTo(178, 120, 168, 116, 163, 121),
      tailPaint,
    );

    final Paint earOuterFill = Paint()..color = palette.earOuter;
    final Paint earOuterStroke = Paint()
      ..color = palette.earOuter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final Path leftEarOuter = Path()
      ..moveTo(56, 68)
      ..lineTo(63, 28)
      ..lineTo(93, 54)
      ..close();
    final Path rightEarOuter = Path()
      ..moveTo(144, 68)
      ..lineTo(137, 28)
      ..lineTo(107, 54)
      ..close();
    canvas.drawPath(leftEarOuter, earOuterFill);
    canvas.drawPath(leftEarOuter, earOuterStroke);
    canvas.drawPath(rightEarOuter, earOuterFill);
    canvas.drawPath(rightEarOuter, earOuterStroke);

    final Paint earInnerFill = Paint()..color = palette.earInner;
    final Paint earInnerStroke = Paint()
      ..color = palette.earInner
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final Path leftEarInner = Path()
      ..moveTo(65, 63)
      ..lineTo(70, 42)
      ..lineTo(86, 57)
      ..close();
    final Path rightEarInner = Path()
      ..moveTo(135, 63)
      ..lineTo(130, 42)
      ..lineTo(114, 57)
      ..close();
    canvas.drawPath(leftEarInner, earInnerFill);
    canvas.drawPath(leftEarInner, earInnerStroke);
    canvas.drawPath(rightEarInner, earInnerFill);
    canvas.drawPath(rightEarInner, earInnerStroke);

    final Path body = Path()
      ..moveTo(100, 44)
      ..cubicTo(137, 44, 159, 72, 159, 107)
      ..cubicTo(159, 143, 134, 165, 100, 165)
      ..cubicTo(66, 165, 41, 143, 41, 107)
      ..cubicTo(41, 72, 63, 44, 100, 44)
      ..close();
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[palette.furTop, palette.furBottom],
      );
    canvas.drawPath(body, bodyPaint);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 132), width: 62, height: 46),
      Paint()..color = palette.belly.withValues(alpha: 0.5),
    );

    final Paint feetPaint = Paint()..color = palette.feet;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(79, 161), width: 28, height: 16),
      feetPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(121, 161), width: 28, height: 16),
      feetPaint,
    );
  }

  static void _paintHappyFace(Canvas canvas) {
    final Paint browPaint = Paint()
      ..color = BunSpritePalette.darkFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(69, 108)
        ..quadraticBezierTo(78, 95, 87, 108),
      browPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(113, 108)
        ..quadraticBezierTo(122, 95, 131, 108),
      browPaint,
    );

    final Paint blushPaint = Paint()
      ..color = BunSpritePalette.blushPink.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 121), width: 20, height: 12),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(140, 121), width: 20, height: 12),
      blushPaint,
    );

    _paintNoseTriangle(
      canvas,
      top: 121,
      base: 114,
      color: BunSpritePalette.nosePinkDefault,
    );

    canvas.drawPath(
      Path()
        ..moveTo(92, 126)
        ..quadraticBezierTo(100, 134, 108, 126),
      Paint()
        ..color = BunSpritePalette.darkFace
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _paintInloveFace(Canvas canvas) {
    final Paint heartPaint = Paint()..color = BunSpritePalette.heart;
    canvas.drawPath(_heartPath(const Offset(65, 93)), heartPaint);
    canvas.drawPath(_heartPath(const Offset(109, 93)), heartPaint);

    final Paint blushPaint = Paint()
      ..color = BunSpritePalette.inloveBlush.withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(59, 123), width: 22, height: 13),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(141, 123), width: 22, height: 13),
      blushPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(93, 124)
        ..quadraticBezierTo(100, 136, 107, 124)
        ..close(),
      Paint()..color = BunSpritePalette.inloveMouth,
    );
  }

  static void _paintNeutralFace(Canvas canvas) {
    final Paint eyePaint = Paint()..color = BunSpritePalette.darkFace;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(78, 106), width: 19, height: 24),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(122, 106), width: 19, height: 24),
      eyePaint,
    );

    final Paint highlightPaint = Paint()
      ..color = BunSpritePalette.highlightWhite;
    canvas.drawCircle(const Offset(81.5, 101), 3.6, highlightPaint);
    canvas.drawCircle(const Offset(125.5, 101), 3.6, highlightPaint);
    final Paint dimHighlightPaint = Paint()
      ..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75);
    canvas.drawCircle(const Offset(74.5, 110.5), 2, dimHighlightPaint);
    canvas.drawCircle(const Offset(118.5, 110.5), 2, dimHighlightPaint);

    final Paint blushPaint = Paint()
      ..color = BunSpritePalette.blushPink.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 122), width: 19, height: 11),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(140, 122), width: 19, height: 11),
      blushPaint,
    );

    _paintNoseTriangle(
      canvas,
      top: 124,
      base: 117,
      color: BunSpritePalette.nosePinkDefault,
    );

    canvas.drawPath(
      Path()
        ..moveTo(94, 130)
        ..quadraticBezierTo(100, 134, 106, 130),
      Paint()
        ..color = BunSpritePalette.darkFace
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _paintSulkFace(Canvas canvas) {
    final Paint browPaint = Paint()
      ..color = BunSpritePalette.darkFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(68, 94), const Offset(87, 100), browPaint);
    canvas.drawLine(const Offset(132, 94), const Offset(113, 100), browPaint);

    final Paint eyePaint = Paint()
      ..color = BunSpritePalette.darkFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(69, 109), const Offset(87, 109), eyePaint);
    canvas.drawLine(const Offset(113, 109), const Offset(131, 109), eyePaint);

    _paintNoseTriangle(
      canvas,
      top: 124,
      base: 117,
      color: BunSpritePalette.sulkNose,
    );

    canvas.drawPath(
      Path()
        ..moveTo(91, 134)
        ..quadraticBezierTo(100, 126, 109, 134),
      Paint()
        ..color = BunSpritePalette.darkFace
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    final Paint cloudPaint = Paint()
      ..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(152, 32), width: 34, height: 22),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(138, 36), width: 22, height: 16),
      cloudPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(148, 46)
        ..lineTo(143, 58)
        ..lineTo(151, 55)
        ..lineTo(146, 66),
      Paint()
        ..color = BunSpritePalette.sulkRain
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  static void _paintSickFace(Canvas canvas) {
    final Paint eyePaint = Paint()
      ..color = BunSpritePalette.darkFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(70, 99)
        ..lineTo(85, 106)
        ..lineTo(70, 113),
      eyePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(130, 99)
        ..lineTo(115, 106)
        ..lineTo(130, 113),
      eyePaint,
    );

    final Paint blushPaint = Paint()
      ..color = BunSpritePalette.sickBlush.withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 122), width: 19, height: 11),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(140, 122), width: 19, height: 11),
      blushPaint,
    );

    _paintNoseTriangle(
      canvas,
      top: 124,
      base: 117,
      color: BunSpritePalette.sickNose,
    );

    canvas.drawPath(
      Path()
        ..moveTo(90, 132)
        ..quadraticBezierTo(94.5, 127, 99, 132)
        ..quadraticBezierTo(103.5, 137, 108, 132),
      Paint()
        ..color = BunSpritePalette.darkFace
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      Path()
        ..moveTo(154, 76)
        ..cubicTo(154, 76, 148, 86, 148, 90.5)
        ..cubicTo(148, 94, 150.7, 96.5, 154, 96.5)
        ..cubicTo(157.3, 96.5, 160, 94, 160, 90.5)
        ..cubicTo(160, 86, 154, 76, 154, 76)
        ..close(),
      Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9),
    );
  }

  /// Every state's nose is the same downward-pointing triangle at x=100,
  /// only its vertical placement and color differ between states.
  static void _paintNoseTriangle(
    Canvas canvas, {
    required double top,
    required double base,
    required Color color,
  }) {
    final Path nose = Path()
      ..moveTo(100, top)
      ..lineTo(94.5, base)
      ..lineTo(105.5, base)
      ..close();
    canvas.drawPath(nose, Paint()..color = color);
    canvas.drawPath(
      nose,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// The `Bun Sprite.dc.html` heart-eye path, translated by [offset].
  static Path _heartPath(Offset offset) {
    return Path()
      ..moveTo(offset.dx + 12, offset.dy + 21.5)
      ..cubicTo(
        offset.dx + 12,
        offset.dy + 21.5,
        offset.dx + 1.8,
        offset.dy + 14.6,
        offset.dx + 1.8,
        offset.dy + 8.1,
      )
      ..cubicTo(
        offset.dx + 1.8,
        offset.dy + 4.6,
        offset.dx + 4.5,
        offset.dy + 2.2,
        offset.dx + 7.6,
        offset.dy + 2.2,
      )
      ..cubicTo(
        offset.dx + 9.7,
        offset.dy + 2.2,
        offset.dx + 11.2,
        offset.dy + 3.4,
        offset.dx + 12,
        offset.dy + 4.9,
      )
      ..cubicTo(
        offset.dx + 12.8,
        offset.dy + 3.4,
        offset.dx + 14.3,
        offset.dy + 2.2,
        offset.dx + 16.4,
        offset.dy + 2.2,
      )
      ..cubicTo(
        offset.dx + 19.5,
        offset.dy + 2.2,
        offset.dx + 22.2,
        offset.dy + 4.6,
        offset.dx + 22.2,
        offset.dy + 8.1,
      )
      ..cubicTo(
        offset.dx + 22.2,
        offset.dy + 14.6,
        offset.dx + 12,
        offset.dy + 21.5,
        offset.dx + 12,
        offset.dy + 21.5,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant _BunSpritePainter oldDelegate) {
    return state != oldDelegate.state || bobOffset != oldDelegate.bobOffset;
  }
}
