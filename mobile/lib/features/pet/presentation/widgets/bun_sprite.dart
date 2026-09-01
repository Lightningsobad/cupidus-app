import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';
import '../../data/pet_models.dart';
import '../../data/pet_mood.dart';

/// Pure-Flutter vector rendering of the `Pet Sprite` design component
/// (`cupid-app-design-system/Pet Sprite.dc.html`), supporting all 6 adoptable
/// companion species (Bún/Cat, Bơ/Shiba, Sữa/Bunny, Mochi/Bear, Xoài/Chick, Kem/Panda)
/// across the five supported [BunSpriteState] mood values.
///
/// [size] is scaled from the design source's 200x200 viewBox to fit any canvas.
class BunSprite extends StatefulWidget {
  const BunSprite({
    super.key,
    this.species = PetSpecies.cat,
    required this.state,
    required this.size,
  });

  final PetSpecies species;
  final BunSpriteState state;
  final double size;

  @override
  State<BunSprite> createState() => _BunSpriteState();
}

/// Typedef alias so [PetSprite] can be used transparently across the codebase.
typedef PetSprite = BunSprite;

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
    if (oldWidget.state != widget.state || oldWidget.species != widget.species) {
      _bobController.duration = _bobHalfCycle(widget.state);
      _syncMotion();
    }
  }

  /// Design source: "Dỗi và ốm thì đứng yên — đó là tín hiệu" — sulk and sick
  /// intentionally hold a still pose as their own signal, so only happy/inlove/neutral bob.
  static bool _bobs(BunSpriteState state) => switch (state) {
        BunSpriteState.happy || BunSpriteState.inlove || BunSpriteState.neutral =>
          true,
        BunSpriteState.sulk || BunSpriteState.sick => false,
      };

  static Duration _bobHalfCycle(BunSpriteState state) => switch (state) {
        BunSpriteState.happy => const Duration(milliseconds: 1600),
        BunSpriteState.inlove => const Duration(milliseconds: 1300),
        BunSpriteState.neutral => const Duration(milliseconds: 2000),
        BunSpriteState.sulk || BunSpriteState.sick => const Duration(milliseconds: 1600),
      };

  void _syncMotion() {
    final bool reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
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
                species: widget.species,
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

class _BunSpritePainter extends CustomPainter {
  _BunSpritePainter({
    required this.species,
    required this.state,
    required this.bobOffset,
  });

  final PetSpecies species;
  final BunSpriteState state;
  final double bobOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 200;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(0, bobOffset);

    switch (species) {
      case PetSpecies.cat:
        _paintBun(canvas, state);
      case PetSpecies.dog:
        _paintBo(canvas, state);
      case PetSpecies.bunny:
        _paintSua(canvas, state);
      case PetSpecies.bear:
        _paintMochi(canvas, state);
      case PetSpecies.chick:
        _paintXoai(canvas, state);
      case PetSpecies.panda:
        _paintKem(canvas, state);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BunSpritePainter oldDelegate) {
    return oldDelegate.species != species ||
        oldDelegate.state != state ||
        oldDelegate.bobOffset != bobOffset;
  }

  // =========================================================================
  // SHARED BASE BODY SHAPE (200x200 base canvas)
  // =========================================================================
  static Path _baseBodyPath() {
    return Path()
      ..moveTo(100, 44)
      ..cubicTo(137, 44, 159, 72, 159, 107)
      ..cubicTo(159, 143, 134, 165, 100, 165)
      ..cubicTo(66, 165, 41, 143, 41, 107)
      ..cubicTo(41, 72, 63, 44, 100, 44)
      ..close();
  }

  static void _drawHeart(Canvas canvas, Offset center, double scale, Color color) {
    final Path heart = Path();
    heart.moveTo(12, 21.5);
    heart.cubicTo(12, 21.5, 1.8, 14.6, 1.8, 8.1);
    heart.cubicTo(1.8, 4.6, 4.5, 2.2, 7.6, 2.2);
    heart.cubicTo(9.7, 2.2, 11.2, 3.4, 12, 4.9);
    heart.cubicTo(12.8, 3.4, 14.3, 2.2, 16.4, 2.2);
    heart.cubicTo(19.5, 2.2, 22.2, 4.6, 22.2, 8.1);
    heart.cubicTo(22.2, 14.6, 12, 21.5, 12, 21.5);
    heart.close();

    canvas.save();
    canvas.translate(center.dx - 12 * scale, center.dy - 12 * scale);
    canvas.scale(scale);
    canvas.drawPath(heart, Paint()..color = color);
    canvas.restore();
  }

  static void _drawSparkle(Canvas canvas, Offset offset, double scale, Color color) {
    final Path sparkle = Path()
      ..moveTo(8, 0)
      ..cubicTo(8.6, 4.6, 11.4, 7.4, 16, 8)
      ..cubicTo(11.4, 8.6, 8.6, 11.4, 8, 16)
      ..cubicTo(7.4, 11.4, 4.6, 8.6, 0, 8)
      ..cubicTo(4.6, 7.4, 7.4, 4.6, 8, 0)
      ..close();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    canvas.drawPath(sparkle, Paint()..color = color);
    canvas.restore();
  }

  // =========================================================================
  // 1. BUN (CAT / MÈO)
  // =========================================================================
  static void _paintBun(Canvas canvas, BunSpriteState state) {
    final bool isSick = state == BunSpriteState.sick;
    final Color furTop = isSick ? BunSpritePalette.sickFurTop : BunSpritePalette.furTop;
    final Color furBottom = isSick ? BunSpritePalette.sickFurBottom : BunSpritePalette.furBottom;
    final Color tailColor = isSick ? BunSpritePalette.sickTail : BunSpritePalette.tail;
    final Color earOuter = isSick ? BunSpritePalette.sickEarOuter : BunSpritePalette.earOuter;
    final Color earInner = isSick ? BunSpritePalette.sickEarInner : BunSpritePalette.earInner;
    final Color bellyColor = isSick ? BunSpritePalette.sickBelly : BunSpritePalette.belly;
    final Color feetColor = isSick ? BunSpritePalette.sickFeet : BunSpritePalette.feet;
    final Color darkLine = BunSpritePalette.darkFace;

    // Tail
    final Paint tailPaint = Paint()
      ..color = tailColor
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

    // Ears
    final Path leftEarOuter = Path()..moveTo(56, 68)..lineTo(63, 28)..lineTo(93, 54)..close();
    final Path rightEarOuter = Path()..moveTo(144, 68)..lineTo(137, 28)..lineTo(107, 54)..close();
    canvas.drawPath(leftEarOuter, Paint()..color = earOuter);
    canvas.drawPath(leftEarOuter, Paint()..color = earOuter..style = PaintingStyle.stroke..strokeWidth = 10..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);
    canvas.drawPath(rightEarOuter, Paint()..color = earOuter);
    canvas.drawPath(rightEarOuter, Paint()..color = earOuter..style = PaintingStyle.stroke..strokeWidth = 10..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);

    final Path leftEarInner = Path()..moveTo(65, 63)..lineTo(70, 42)..lineTo(86, 57)..close();
    final Path rightEarInner = Path()..moveTo(135, 63)..lineTo(130, 42)..lineTo(114, 57)..close();
    canvas.drawPath(leftEarInner, Paint()..color = earInner);
    canvas.drawPath(leftEarInner, Paint()..color = earInner..style = PaintingStyle.stroke..strokeWidth = 6..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);
    canvas.drawPath(rightEarInner, Paint()..color = earInner);
    canvas.drawPath(rightEarInner, Paint()..color = earInner..style = PaintingStyle.stroke..strokeWidth = 6..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);

    // Body
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[furTop, furBottom],
      );
    canvas.drawPath(_baseBodyPath(), bodyPaint);

    // Belly
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 132), width: 62, height: 46),
      Paint()..color = bellyColor.withValues(alpha: 0.5),
    );

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(79, 161), width: 28, height: 16), Paint()..color = feetColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(121, 161), width: 28, height: 16), Paint()..color = feetColor);

    // Whiskers
    final Paint whiskerPaint = Paint()
      ..color = darkLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(38, 98), const Offset(18, 92), whiskerPaint);
    canvas.drawLine(const Offset(38, 108), const Offset(16, 108), whiskerPaint);
    canvas.drawLine(const Offset(38, 118), const Offset(18, 124), whiskerPaint);
    canvas.drawLine(const Offset(162, 98), const Offset(182, 92), whiskerPaint);
    canvas.drawLine(const Offset(162, 108), const Offset(184, 108), whiskerPaint);
    canvas.drawLine(const Offset(162, 118), const Offset(182, 124), whiskerPaint);

    // Cheeks
    final Color cheekColor = isSick ? BunSpritePalette.sickBlush.withValues(alpha: 0.45) : BunSpritePalette.blushPink.withValues(alpha: 0.5);
    canvas.drawOval(Rect.fromCenter(center: const Offset(60, 122), width: 20, height: 12), Paint()..color = cheekColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(140, 122), width: 20, height: 12), Paint()..color = cheekColor);

    // Nose
    final Path nose = Path()..moveTo(100, 121)..lineTo(94.5, 114)..lineTo(105.5, 114)..close();
    canvas.drawPath(nose, Paint()..color = BunSpritePalette.nosePinkDefault);

    // Mood Face
    switch (state) {
      case BunSpriteState.happy:
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(69, 108)..quadraticBezierTo(78, 95, 87, 108), eyePaint);
        canvas.drawPath(Path()..moveTo(113, 108)..quadraticBezierTo(122, 95, 131, 108), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(92, 126)..quadraticBezierTo(100, 134, 108, 126), mouthPaint);
        _drawSparkle(canvas, const Offset(20, 58), 0.9, BunSpritePalette.sparkleYellow);
        _drawSparkle(canvas, const Offset(172, 74), 0.62, BunSpritePalette.highlightWhite);
      case BunSpriteState.inlove:
        _drawHeart(canvas, const Offset(76, 103), 1.0, BunSpritePalette.heart);
        _drawHeart(canvas, const Offset(120, 103), 1.0, BunSpritePalette.heart);
        final Path mouth = Path()..moveTo(93, 124)..quadraticBezierTo(100, 136, 107, 124)..close();
        canvas.drawPath(mouth, Paint()..color = BunSpritePalette.inloveMouth);
        _drawHeart(canvas, const Offset(164, 30), 0.8, BunSpritePalette.inloveBlush);
        _drawHeart(canvas, const Offset(26, 44), 0.55, BunSpritePalette.inloveHeartSmall);
      case BunSpriteState.neutral:
        canvas.drawOval(Rect.fromCenter(center: const Offset(78, 106), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawOval(Rect.fromCenter(center: const Offset(122, 106), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawCircle(const Offset(81.5, 101), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(125.5, 101), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(74.5, 110.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        canvas.drawCircle(const Offset(118.5, 110.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(94, 130)..quadraticBezierTo(100, 134, 106, 130), mouthPaint);
      case BunSpriteState.sulk:
        final Paint browPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(68, 94), const Offset(87, 100), browPaint);
        canvas.drawLine(const Offset(132, 94), const Offset(113, 100), browPaint);
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(69, 109), const Offset(87, 109), eyePaint);
        canvas.drawLine(const Offset(113, 109), const Offset(131, 109), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(91, 134)..quadraticBezierTo(100, 126, 109, 134), mouthPaint);
        // Rain cloud
        canvas.drawOval(Rect.fromCenter(center: const Offset(154, 34), width: 34, height: 22), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        canvas.drawOval(Rect.fromCenter(center: const Offset(140, 38), width: 22, height: 16), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        final Path bolt = Path()..moveTo(152, 46)..lineTo(147, 58)..lineTo(155, 55)..lineTo(150, 66);
        canvas.drawPath(bolt, Paint()..color = BunSpritePalette.sulkRain..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      case BunSpriteState.sick:
        final Paint dizzyPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
        canvas.drawPath(Path()..moveTo(70, 99)..lineTo(85, 106)..lineTo(70, 113), dizzyPaint);
        canvas.drawPath(Path()..moveTo(130, 99)..lineTo(115, 106)..lineTo(130, 113), dizzyPaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(90, 132)..cubicTo(94.5, 127, 99, 132, 103.5, 137)..cubicTo(103.5, 137, 106, 134, 108, 132), mouthPaint);
        // Tear drop
        final Path tear = Path()..moveTo(156, 78)..cubicTo(156, 78, 150, 88, 150, 92.5)..cubicTo(150, 96, 152.7, 98.5, 156, 98.5)..cubicTo(159.3, 98.5, 162, 96, 162, 92.5)..cubicTo(162, 88, 156, 78, 156, 78)..close();
        canvas.drawPath(tear, Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9));
    }
  }

  // =========================================================================
  // 2. BO (SHIBA / DOG / CHÓ / BƠ)
  // =========================================================================
  static void _paintBo(Canvas canvas, BunSpriteState state) {
    final bool isSick = state == BunSpriteState.sick;
    final bool isSulk = state == BunSpriteState.sulk;
    final Color furTop = isSick ? BunSpritePalette.boSickFurTop : BunSpritePalette.boFurTop;
    final Color furBottom = isSick ? BunSpritePalette.boSickFurBottom : BunSpritePalette.boFurBottom;
    final Color tailColor = isSick ? BunSpritePalette.boSickTail : BunSpritePalette.boTail;
    final Color earColor = isSick ? BunSpritePalette.boSickEar : BunSpritePalette.boEar;
    final Color patchColor = isSick ? BunSpritePalette.boSickPatch : BunSpritePalette.boPatch;
    final Color muzzleColor = isSick ? BunSpritePalette.boSickMuzzle : BunSpritePalette.boMuzzle;
    final Color feetColor = isSick ? BunSpritePalette.boSickFeet : BunSpritePalette.boFeet;
    final Color darkLine = BunSpritePalette.boDarkFace;

    // Tail
    final Paint tailPaint = Paint()
      ..color = tailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    if (isSulk) {
      canvas.drawPath(Path()..moveTo(148, 156)..cubicTo(166, 160, 174, 148, 170, 138), tailPaint);
    } else if (isSick) {
      canvas.drawPath(Path()..moveTo(148, 158)..cubicTo(164, 162, 170, 152, 168, 144), tailPaint);
    } else {
      canvas.drawPath(Path()..moveTo(148, 152)..cubicTo(170, 154, 178, 132, 166, 122)..cubicTo(158, 116, 150, 122, 155, 129), tailPaint);
    }

    // Folded Shiba Ears
    final double leftAngle = isSulk ? -4 * math.pi / 180 : (isSick ? -2 * math.pi / 180 : -12 * math.pi / 180);
    final double rightAngle = isSulk ? 4 * math.pi / 180 : (isSick ? 2 * math.pi / 180 : 12 * math.pi / 180);
    final double earCy = isSulk ? 94 : (isSick ? 96 : 88);

    canvas.save();
    canvas.translate(44, earCy);
    canvas.rotate(leftAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 30, height: 54), Paint()..color = earColor);
    canvas.restore();

    canvas.save();
    canvas.translate(156, earCy);
    canvas.rotate(rightAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 30, height: 54), Paint()..color = earColor);
    canvas.restore();

    // Body
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[furTop, furBottom],
      );
    canvas.drawPath(_baseBodyPath(), bodyPaint);

    // Eye patch (distinct Shiba face patch)
    canvas.drawOval(Rect.fromCenter(center: const Offset(126, 101), width: 42, height: 38), Paint()..color = patchColor.withValues(alpha: isSick ? 0.75 : 0.8));

    // Muzzle
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 128), width: 56, height: 38), Paint()..color = muzzleColor.withValues(alpha: isSick ? 0.9 : 0.95));

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(79, 161), width: 28, height: 16), Paint()..color = feetColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(121, 161), width: 28, height: 16), Paint()..color = feetColor);

    // Cheeks
    final Color cheekColor = isSick ? BunSpritePalette.sickBlush.withValues(alpha: 0.4) : BunSpritePalette.blushPink.withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: const Offset(58, 120), width: 20, height: 12), Paint()..color = cheekColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(146, 120), width: 20, height: 12), Paint()..color = cheekColor);

    // Nose
    final Color noseColor = isSick ? BunSpritePalette.boSickNose : (isSulk ? BunSpritePalette.boSulkNose : BunSpritePalette.boNose);
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 117), width: 17, height: 13), Paint()..color = noseColor);

    // Face / Mood
    switch (state) {
      case BunSpriteState.happy:
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(69, 106)..quadraticBezierTo(78, 93, 87, 106), eyePaint);
        canvas.drawPath(Path()..moveTo(113, 106)..quadraticBezierTo(122, 93, 131, 106), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(100, 124)..quadraticBezierTo(93, 132, 86, 127), mouthPaint);
        canvas.drawPath(Path()..moveTo(100, 124)..quadraticBezierTo(107, 132, 114, 127), mouthPaint);
        final Path tongue = Path()..moveTo(94, 131)..quadraticBezierTo(100, 148, 106, 131)..close();
        canvas.drawPath(tongue, Paint()..color = BunSpritePalette.boTongue);
        _drawSparkle(canvas, const Offset(22, 42), 0.9, BunSpritePalette.sparkleYellow);
        _drawSparkle(canvas, const Offset(168, 48), 0.62, BunSpritePalette.highlightWhite);
      case BunSpriteState.inlove:
        _drawHeart(canvas, const Offset(77, 102), 1.0, BunSpritePalette.heart);
        _drawHeart(canvas, const Offset(121, 102), 1.0, BunSpritePalette.heart);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(100, 124)..quadraticBezierTo(93, 132, 86, 127), mouthPaint);
        canvas.drawPath(Path()..moveTo(100, 124)..quadraticBezierTo(107, 132, 114, 127), mouthPaint);
        final Path tongue = Path()..moveTo(93, 131)..quadraticBezierTo(100, 152, 107, 131)..close();
        canvas.drawPath(tongue, Paint()..color = BunSpritePalette.boTongue);
        _drawHeart(canvas, const Offset(166, 30), 0.8, BunSpritePalette.inloveBlush);
        _drawHeart(canvas, const Offset(28, 34), 0.55, BunSpritePalette.inloveHeartSmall);
      case BunSpriteState.neutral:
        canvas.drawOval(Rect.fromCenter(center: const Offset(78, 104), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawOval(Rect.fromCenter(center: const Offset(122, 104), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawCircle(const Offset(81.5, 99), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(125.5, 99), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(74.5, 108.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        canvas.drawCircle(const Offset(118.5, 108.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(100, 126)..quadraticBezierTo(94, 132, 88, 129), mouthPaint);
        canvas.drawPath(Path()..moveTo(100, 126)..quadraticBezierTo(106, 132, 112, 129), mouthPaint);
      case BunSpriteState.sulk:
        final Paint browPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(68, 92), const Offset(87, 98), browPaint);
        canvas.drawLine(const Offset(132, 92), const Offset(113, 98), browPaint);
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(69, 107), const Offset(87, 107), eyePaint);
        canvas.drawLine(const Offset(113, 107), const Offset(131, 107), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(89, 134)..quadraticBezierTo(100, 125, 111, 134), mouthPaint);
        // Rain cloud
        canvas.drawOval(Rect.fromCenter(center: const Offset(156, 34), width: 34, height: 22), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        canvas.drawOval(Rect.fromCenter(center: const Offset(142, 38), width: 22, height: 16), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        final Path bolt = Path()..moveTo(154, 46)..lineTo(149, 58)..lineTo(157, 55)..lineTo(152, 66);
        canvas.drawPath(bolt, Paint()..color = BunSpritePalette.sulkRain..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      case BunSpriteState.sick:
        final Paint dizzyPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
        canvas.drawPath(Path()..moveTo(70, 97)..lineTo(85, 104)..lineTo(70, 111), dizzyPaint);
        canvas.drawPath(Path()..moveTo(130, 97)..lineTo(115, 104)..lineTo(130, 111), dizzyPaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(89, 132)..cubicTo(94, 127, 99, 132, 104, 137)..cubicTo(104, 137, 106.5, 134, 109, 132), mouthPaint);
        final Path tear = Path()..moveTo(170, 76)..cubicTo(170, 76, 164, 86, 164, 90.5)..cubicTo(164, 94, 166.7, 96.5, 170, 96.5)..cubicTo(173.3, 96.5, 176, 94, 176, 90.5)..cubicTo(176, 86, 170, 76, 170, 76)..close();
        canvas.drawPath(tear, Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9));
    }
  }

  // =========================================================================
  // 3. SUA (BUNNY / THỎ / SỮA)
  // =========================================================================
  static void _paintSua(Canvas canvas, BunSpriteState state) {
    final bool isSick = state == BunSpriteState.sick;
    final bool isSulk = state == BunSpriteState.sulk;
    final Color furTop = isSick ? BunSpritePalette.sickFurTop : BunSpritePalette.furTop;
    final Color furBottom = isSick ? BunSpritePalette.sickFurBottom : BunSpritePalette.furBottom;
    final Color tailColor = isSick ? BunSpritePalette.sickTail : BunSpritePalette.tail;
    final Color earOuter = isSick ? BunSpritePalette.sickEarOuter : BunSpritePalette.earOuter;
    final Color earInner = isSick ? BunSpritePalette.sickEarInner : BunSpritePalette.earInner;
    final Color bellyColor = isSick ? BunSpritePalette.sickBelly : BunSpritePalette.belly;
    final Color feetColor = isSick ? BunSpritePalette.sickFeet : BunSpritePalette.feet;
    final Color darkLine = BunSpritePalette.darkFace;

    // Fluffy Bunny Tail
    canvas.drawCircle(const Offset(153, 150), 14, Paint()..color = tailColor);

    // Long upright Bunny ears
    final double leftAngle = isSulk ? -30 * math.pi / 180 : (isSick ? -42 * math.pi / 180 : -10 * math.pi / 180);
    final double rightAngle = isSulk ? 30 * math.pi / 180 : (isSick ? 42 * math.pi / 180 : 10 * math.pi / 180);
    final Offset leftEarPos = isSulk ? const Offset(76, 40) : (isSick ? const Offset(74, 44) : const Offset(80, 34));
    final Offset rightEarPos = isSulk ? const Offset(124, 40) : (isSick ? const Offset(126, 44) : const Offset(120, 34));

    canvas.save();
    canvas.translate(leftEarPos.dx, leftEarPos.dy);
    canvas.rotate(leftAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 60), Paint()..color = earOuter);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 40), Paint()..color = earInner);
    canvas.restore();

    canvas.save();
    canvas.translate(rightEarPos.dx, rightEarPos.dy);
    canvas.rotate(rightAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 60), Paint()..color = earOuter);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 40), Paint()..color = earInner);
    canvas.restore();

    // Body
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[furTop, furBottom],
      );
    canvas.drawPath(_baseBodyPath(), bodyPaint);

    // Belly
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 132), width: 62, height: 46), Paint()..color = bellyColor.withValues(alpha: 0.55));

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(79, 161), width: 28, height: 16), Paint()..color = feetColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(121, 161), width: 28, height: 16), Paint()..color = feetColor);

    // Cheeks
    final Color cheekColor = isSick ? BunSpritePalette.sickBlush.withValues(alpha: 0.45) : BunSpritePalette.blushPink.withValues(alpha: 0.5);
    canvas.drawOval(Rect.fromCenter(center: const Offset(60, 121), width: 20, height: 12), Paint()..color = cheekColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(140, 121), width: 20, height: 12), Paint()..color = cheekColor);

    // Bunny Nose (Triangle)
    final Path nose = Path()..moveTo(100, 121)..lineTo(94.5, 114)..lineTo(105.5, 114)..close();
    canvas.drawPath(nose, Paint()..color = isSick ? BunSpritePalette.suaSickNose : BunSpritePalette.nosePinkDefault);

    // Mood Face with Bunny Buck Tooth
    switch (state) {
      case BunSpriteState.happy:
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(69, 108)..quadraticBezierTo(78, 95, 87, 108), eyePaint);
        canvas.drawPath(Path()..moveTo(113, 108)..quadraticBezierTo(122, 95, 131, 108), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(92, 126)..quadraticBezierTo(100, 134, 108, 126), mouthPaint);
        // Buck tooth
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(94, 130, 12, 11), const Radius.circular(3.5)), Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawLine(const Offset(100, 130), const Offset(100, 141), Paint()..color = BunSpritePalette.suaToothLine..strokeWidth = 1.6);
        _drawSparkle(canvas, const Offset(20, 58), 0.9, BunSpritePalette.sparkleYellow);
        _drawSparkle(canvas, const Offset(172, 74), 0.62, BunSpritePalette.highlightWhite);
      case BunSpriteState.inlove:
        _drawHeart(canvas, const Offset(77, 104), 1.0, BunSpritePalette.heart);
        _drawHeart(canvas, const Offset(121, 104), 1.0, BunSpritePalette.heart);
        final Path mouth = Path()..moveTo(93, 124)..quadraticBezierTo(100, 136, 107, 124)..close();
        canvas.drawPath(mouth, Paint()..color = BunSpritePalette.inloveMouth);
        _drawHeart(canvas, const Offset(164, 28), 0.8, BunSpritePalette.inloveBlush);
        _drawHeart(canvas, const Offset(28, 44), 0.55, BunSpritePalette.inloveHeartSmall);
      case BunSpriteState.neutral:
        canvas.drawOval(Rect.fromCenter(center: const Offset(78, 106), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawOval(Rect.fromCenter(center: const Offset(122, 106), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawCircle(const Offset(81.5, 101), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(125.5, 101), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(74.5, 110.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        canvas.drawCircle(const Offset(118.5, 110.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(94, 130)..quadraticBezierTo(100, 134, 106, 130), mouthPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(94, 134, 12, 10), const Radius.circular(3.5)), Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawLine(const Offset(100, 134), const Offset(100, 144), Paint()..color = BunSpritePalette.suaToothLine..strokeWidth = 1.6);
      case BunSpriteState.sulk:
        final Paint browPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(68, 94), const Offset(87, 100), browPaint);
        canvas.drawLine(const Offset(132, 94), const Offset(113, 100), browPaint);
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(69, 109), const Offset(87, 109), eyePaint);
        canvas.drawLine(const Offset(113, 109), const Offset(131, 109), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(91, 134)..quadraticBezierTo(100, 126, 109, 134), mouthPaint);
        // Rain cloud
        canvas.drawOval(Rect.fromCenter(center: const Offset(154, 34), width: 34, height: 22), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        canvas.drawOval(Rect.fromCenter(center: const Offset(140, 38), width: 22, height: 16), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        final Path bolt = Path()..moveTo(152, 46)..lineTo(147, 58)..lineTo(155, 55)..lineTo(150, 66);
        canvas.drawPath(bolt, Paint()..color = BunSpritePalette.sulkRain..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      case BunSpriteState.sick:
        final Paint dizzyPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
        canvas.drawPath(Path()..moveTo(70, 99)..lineTo(85, 106)..lineTo(70, 113), dizzyPaint);
        canvas.drawPath(Path()..moveTo(130, 99)..lineTo(115, 106)..lineTo(130, 113), dizzyPaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(90, 132)..cubicTo(94.5, 127, 99, 132, 103.5, 137)..cubicTo(103.5, 137, 106, 134, 108, 132), mouthPaint);
        final Path tear = Path()..moveTo(156, 78)..cubicTo(156, 78, 150, 88, 150, 92.5)..cubicTo(150, 96, 152.7, 98.5, 156, 98.5)..cubicTo(159.3, 98.5, 162, 96, 162, 92.5)..cubicTo(162, 88, 156, 78, 156, 78)..close();
        canvas.drawPath(tear, Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9));
    }
  }

  // =========================================================================
  // 4. MOCHI (BEAR / GẤU / MOCHI)
  // =========================================================================
  static void _paintMochi(Canvas canvas, BunSpriteState state) {
    final bool isSick = state == BunSpriteState.sick;
    final bool isSulk = state == BunSpriteState.sulk;
    final Color furTop = isSick ? BunSpritePalette.mochiSickFurTop : BunSpritePalette.mochiFurTop;
    final Color furBottom = isSick ? BunSpritePalette.mochiSickFurBottom : BunSpritePalette.mochiFurBottom;
    final Color tailColor = isSick ? BunSpritePalette.mochiSickTail : BunSpritePalette.mochiTail;
    final Color earOuter = isSick ? BunSpritePalette.mochiSickEarOuter : BunSpritePalette.mochiEarOuter;
    final Color earInner = isSick ? BunSpritePalette.mochiSickEarInner : BunSpritePalette.mochiEarInner;
    final Color muzzleColor = isSick ? BunSpritePalette.mochiSickMuzzle : BunSpritePalette.mochiMuzzle;
    final Color feetColor = isSick ? BunSpritePalette.mochiSickFeet : BunSpritePalette.mochiFeet;
    final Color darkLine = BunSpritePalette.boDarkFace;

    // Bear Tail
    canvas.drawCircle(const Offset(152, 152), 11, Paint()..color = tailColor);

    // Round Bear Ears
    canvas.drawCircle(const Offset(62, 52), 21, Paint()..color = earOuter);
    canvas.drawCircle(const Offset(138, 52), 21, Paint()..color = earOuter);
    canvas.drawCircle(const Offset(62, 53), 11, Paint()..color = earInner);
    canvas.drawCircle(const Offset(138, 53), 11, Paint()..color = earInner);

    // Body
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[furTop, furBottom],
      );
    canvas.drawPath(_baseBodyPath(), bodyPaint);

    // Big round Bear Muzzle
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 127), width: 62, height: 42), Paint()..color = muzzleColor.withValues(alpha: isSick ? 0.9 : 0.95));

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(79, 161), width: 28, height: 16), Paint()..color = feetColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(121, 161), width: 28, height: 16), Paint()..color = feetColor);

    // Cheeks
    final Color cheekColor = isSick ? BunSpritePalette.sickBlush.withValues(alpha: 0.4) : BunSpritePalette.blushPink.withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: const Offset(57, 120), width: 20, height: 12), Paint()..color = cheekColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(143, 120), width: 20, height: 12), Paint()..color = cheekColor);

    // Round Bear Nose
    final Color noseColor = isSick ? BunSpritePalette.mochiSickTail : (isSulk ? BunSpritePalette.boSulkNose : BunSpritePalette.boNose);
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 116), width: 18, height: 14), Paint()..color = noseColor);

    // Face / Mood
    switch (state) {
      case BunSpriteState.happy:
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(69, 106)..quadraticBezierTo(78, 93, 87, 106), eyePaint);
        canvas.drawPath(Path()..moveTo(113, 106)..quadraticBezierTo(122, 93, 131, 106), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(100, 123)..quadraticBezierTo(93, 131, 86, 126), mouthPaint);
        canvas.drawPath(Path()..moveTo(100, 123)..quadraticBezierTo(107, 131, 114, 126), mouthPaint);
        _drawSparkle(canvas, const Offset(20, 40), 0.9, BunSpritePalette.sparkleYellow);
        _drawSparkle(canvas, const Offset(170, 44), 0.62, BunSpritePalette.highlightWhite);
      case BunSpriteState.inlove:
        _drawHeart(canvas, const Offset(77, 103), 1.0, BunSpritePalette.heart);
        _drawHeart(canvas, const Offset(121, 103), 1.0, BunSpritePalette.heart);
        final Path mouth = Path()..moveTo(92, 124)..quadraticBezierTo(100, 136, 108, 124)..close();
        canvas.drawPath(mouth, Paint()..color = BunSpritePalette.mochiInloveMouth);
        _drawHeart(canvas, const Offset(168, 28), 0.8, BunSpritePalette.inloveBlush);
        _drawHeart(canvas, const Offset(26, 32), 0.55, BunSpritePalette.inloveHeartSmall);
      case BunSpriteState.neutral:
        canvas.drawOval(Rect.fromCenter(center: const Offset(78, 104), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawOval(Rect.fromCenter(center: const Offset(122, 104), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawCircle(const Offset(81.5, 99), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(125.5, 99), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(74.5, 108.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        canvas.drawCircle(const Offset(118.5, 108.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(100, 125)..quadraticBezierTo(94, 131, 88, 128), mouthPaint);
        canvas.drawPath(Path()..moveTo(100, 125)..quadraticBezierTo(106, 131, 112, 128), mouthPaint);
      case BunSpriteState.sulk:
        final Paint browPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(68, 92), const Offset(87, 98), browPaint);
        canvas.drawLine(const Offset(132, 92), const Offset(113, 98), browPaint);
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(69, 107), const Offset(87, 107), eyePaint);
        canvas.drawLine(const Offset(113, 107), const Offset(131, 107), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(89, 133)..quadraticBezierTo(100, 124, 111, 133), mouthPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(158, 30), width: 34, height: 22), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        canvas.drawOval(Rect.fromCenter(center: const Offset(144, 34), width: 22, height: 16), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        final Path bolt = Path()..moveTo(156, 42)..lineTo(151, 54)..lineTo(159, 51)..lineTo(154, 62);
        canvas.drawPath(bolt, Paint()..color = BunSpritePalette.sulkRain..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      case BunSpriteState.sick:
        final Paint dizzyPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
        canvas.drawPath(Path()..moveTo(70, 97)..lineTo(85, 104)..lineTo(70, 111), dizzyPaint);
        canvas.drawPath(Path()..moveTo(130, 97)..lineTo(115, 104)..lineTo(130, 111), dizzyPaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(89, 131)..cubicTo(94, 126, 99, 131, 104, 136)..cubicTo(104, 136, 106.5, 133, 109, 131), mouthPaint);
        final Path tear = Path()..moveTo(168, 74)..cubicTo(168, 74, 162, 84, 162, 88.5)..cubicTo(162, 92, 164.7, 94.5, 168, 94.5)..cubicTo(171.3, 94.5, 174, 92, 174, 88.5)..cubicTo(174, 84, 168, 74, 168, 74)..close();
        canvas.drawPath(tear, Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9));
    }
  }

  // =========================================================================
  // 5. XOAI (CHICK / GÀ CON / XOÀI)
  // =========================================================================
  static void _paintXoai(Canvas canvas, BunSpriteState state) {
    final bool isSick = state == BunSpriteState.sick;
    final bool isSulk = state == BunSpriteState.sulk;
    final Color furTop = isSick ? BunSpritePalette.xoaiSickFurTop : BunSpritePalette.xoaiFurTop;
    final Color furBottom = isSick ? BunSpritePalette.xoaiSickFurBottom : BunSpritePalette.xoaiFurBottom;
    final Color crestColor = isSick ? BunSpritePalette.xoaiSickCrest : BunSpritePalette.xoaiCrest;
    final Color wingColor = isSick ? BunSpritePalette.xoaiSickWing : BunSpritePalette.xoaiWing;
    final Color feetColor = isSick ? BunSpritePalette.xoaiSickFeet : BunSpritePalette.xoaiFeet;
    final Color beakColor = isSick ? BunSpritePalette.xoaiSickBeak : (isSulk ? BunSpritePalette.xoaiSulkBeak : BunSpritePalette.xoaiBeak);
    final Color darkLine = BunSpritePalette.xoaiDarkFace;

    // Top Crest (3 feathers)
    final Paint crestPaint = Paint()
      ..color = crestColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(92, 44), const Offset(86, 24), crestPaint);
    canvas.drawLine(const Offset(100, 42), const Offset(100, 20), crestPaint);
    canvas.drawLine(const Offset(108, 44), const Offset(114, 24), crestPaint);

    // Wings
    final double leftAngle = isSulk ? -4 * math.pi / 180 : -14 * math.pi / 180;
    final double rightAngle = isSulk ? 4 * math.pi / 180 : 14 * math.pi / 180;
    final Offset leftWingPos = isSick ? const Offset(47, 122) : (isSulk ? const Offset(46, 118) : const Offset(44, 112));
    final Offset rightWingPos = isSick ? const Offset(153, 122) : (isSulk ? const Offset(154, 118) : const Offset(156, 112));

    canvas.save();
    canvas.translate(leftWingPos.dx, leftWingPos.dy);
    canvas.rotate(leftAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 22, height: 42), Paint()..color = wingColor);
    canvas.restore();

    canvas.save();
    canvas.translate(rightWingPos.dx, rightWingPos.dy);
    canvas.rotate(rightAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 22, height: 42), Paint()..color = wingColor);
    canvas.restore();

    // Body
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[furTop, furBottom],
      );
    canvas.drawPath(_baseBodyPath(), bodyPaint);

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(79, 163), width: 28, height: 14), Paint()..color = feetColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(121, 163), width: 28, height: 14), Paint()..color = feetColor);

    // Cheeks
    final Color cheekColor = isSick ? BunSpritePalette.sickBlush.withValues(alpha: 0.45) : BunSpritePalette.blushPink.withValues(alpha: 0.5);
    canvas.drawOval(Rect.fromCenter(center: const Offset(60, 122), width: 20, height: 12), Paint()..color = cheekColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(140, 122), width: 20, height: 12), Paint()..color = cheekColor);

    // Beak
    final double beakY = isSick || isSulk ? 120 : (state == BunSpriteState.inlove ? 116 : (state == BunSpriteState.neutral ? 118 : 114));
    final Path beak = Path()..moveTo(100, beakY)..lineTo(110, beakY + 8)..lineTo(90, beakY + 8)..close();
    canvas.drawPath(beak, Paint()..color = beakColor);
    canvas.drawPath(beak, Paint()..color = beakColor..style = PaintingStyle.stroke..strokeWidth = 3..strokeJoin = StrokeJoin.round);

    // Face / Mood
    switch (state) {
      case BunSpriteState.happy:
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(69, 106)..quadraticBezierTo(78, 93, 87, 106), eyePaint);
        canvas.drawPath(Path()..moveTo(113, 106)..quadraticBezierTo(122, 93, 131, 106), eyePaint);
        _drawSparkle(canvas, const Offset(24, 52), 0.85, BunSpritePalette.highlightWhite);
        _drawSparkle(canvas, const Offset(172, 64), 0.6, BunSpritePalette.xoaiSparkleYellow);
      case BunSpriteState.inlove:
        _drawHeart(canvas, const Offset(77, 104), 1.0, BunSpritePalette.xoaiHeart);
        _drawHeart(canvas, const Offset(121, 104), 1.0, BunSpritePalette.xoaiHeart);
        _drawHeart(canvas, const Offset(168, 34), 0.8, BunSpritePalette.inloveBlush);
        _drawHeart(canvas, const Offset(28, 42), 0.55, BunSpritePalette.inloveHeartSmall);
      case BunSpriteState.neutral:
        canvas.drawOval(Rect.fromCenter(center: const Offset(78, 106), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawOval(Rect.fromCenter(center: const Offset(122, 106), width: 19, height: 24), Paint()..color = darkLine);
        canvas.drawCircle(const Offset(81.5, 101), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(125.5, 101), 3.6, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(74.5, 110.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
        canvas.drawCircle(const Offset(118.5, 110.5), 2.0, Paint()..color = BunSpritePalette.highlightWhite.withValues(alpha: 0.75));
      case BunSpriteState.sulk:
        final Paint browPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(68, 94), const Offset(87, 100), browPaint);
        canvas.drawLine(const Offset(132, 94), const Offset(113, 100), browPaint);
        final Paint eyePaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(69, 109), const Offset(87, 109), eyePaint);
        canvas.drawLine(const Offset(113, 109), const Offset(131, 109), eyePaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(158, 34), width: 34, height: 22), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        canvas.drawOval(Rect.fromCenter(center: const Offset(144, 38), width: 22, height: 16), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        final Path bolt = Path()..moveTo(156, 46)..lineTo(151, 58)..lineTo(159, 51)..lineTo(154, 62);
        canvas.drawPath(bolt, Paint()..color = BunSpritePalette.sulkRain..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      case BunSpriteState.sick:
        final Paint dizzyPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
        canvas.drawPath(Path()..moveTo(70, 99)..lineTo(85, 106)..lineTo(70, 113), dizzyPaint);
        canvas.drawPath(Path()..moveTo(130, 99)..lineTo(115, 106)..lineTo(130, 113), dizzyPaint);
        final Path tear = Path()..moveTo(170, 76)..cubicTo(170, 76, 164, 86, 164, 90.5)..cubicTo(164, 94, 166.7, 96.5, 170, 96.5)..cubicTo(173.3, 96.5, 176, 94, 176, 90.5)..cubicTo(176, 86, 170, 76, 170, 76)..close();
        canvas.drawPath(tear, Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9));
    }
  }

  // =========================================================================
  // 6. KEM (PANDA / GẤU TRÚC / KEM)
  // =========================================================================
  static void _paintKem(Canvas canvas, BunSpriteState state) {
    final bool isSick = state == BunSpriteState.sick;
    final bool isSulk = state == BunSpriteState.sulk;
    final Color furTop = isSick ? BunSpritePalette.kemSickFurTop : BunSpritePalette.kemFurTop;
    final Color furBottom = isSick ? BunSpritePalette.kemSickFurBottom : BunSpritePalette.kemFurBottom;
    final Color darkPatch = isSick ? BunSpritePalette.kemSickDarkPatch : BunSpritePalette.kemDarkPatch;
    final Color darkLine = darkPatch;

    // Panda Ears
    canvas.drawCircle(const Offset(60, 50), 19, Paint()..color = darkPatch);
    canvas.drawCircle(const Offset(140, 50), 19, Paint()..color = darkPatch);

    // Dark Panda Arms/Shoulders
    final double leftArmAngle = isSulk ? -4 * math.pi / 180 : -12 * math.pi / 180;
    final double rightArmAngle = isSulk ? 4 * math.pi / 180 : 12 * math.pi / 180;
    final Offset leftArmPos = isSick ? const Offset(40, 126) : (isSulk ? const Offset(40, 124) : const Offset(40, 120));
    final Offset rightArmPos = isSick ? const Offset(160, 126) : (isSulk ? const Offset(160, 124) : const Offset(160, 120));

    canvas.save();
    canvas.translate(leftArmPos.dx, leftArmPos.dy);
    canvas.rotate(leftArmAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 46), Paint()..color = darkPatch);
    canvas.restore();

    canvas.save();
    canvas.translate(rightArmPos.dx, rightArmPos.dy);
    canvas.rotate(rightArmAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 46), Paint()..color = darkPatch);
    canvas.restore();

    // Body
    final Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 44),
        const Offset(100, 165),
        <Color>[furTop, furBottom],
      );
    canvas.drawPath(_baseBodyPath(), bodyPaint);

    // Distinctive Panda Eye Patches
    final double leftPatchAngle = isSulk ? -20 * math.pi / 180 : -14 * math.pi / 180;
    final double rightPatchAngle = isSulk ? 20 * math.pi / 180 : 14 * math.pi / 180;

    canvas.save();
    canvas.translate(78, 105);
    canvas.rotate(leftPatchAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 34, height: 40), Paint()..color = darkPatch);
    canvas.restore();

    canvas.save();
    canvas.translate(122, 105);
    canvas.rotate(rightPatchAngle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 34, height: 40), Paint()..color = darkPatch);
    canvas.restore();

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(79, 162), width: 30, height: 18), Paint()..color = darkPatch);
    canvas.drawOval(Rect.fromCenter(center: const Offset(121, 162), width: 30, height: 18), Paint()..color = darkPatch);

    // Cheeks
    final Color cheekColor = isSick ? BunSpritePalette.sickBlush.withValues(alpha: 0.5) : BunSpritePalette.blushPink.withValues(alpha: 0.55);
    canvas.drawOval(Rect.fromCenter(center: const Offset(54, 126), width: 20, height: 12), Paint()..color = cheekColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(146, 126), width: 20, height: 12), Paint()..color = cheekColor);

    // Nose
    final Color noseColor = isSick ? BunSpritePalette.kemSickNose : (isSulk ? BunSpritePalette.kemSulkNose : darkPatch);
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 124), width: 16, height: 12), Paint()..color = noseColor);

    // Face / Mood
    switch (state) {
      case BunSpriteState.happy:
        final Paint eyePaint = Paint()..color = BunSpritePalette.highlightWhite..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(70, 108)..quadraticBezierTo(78, 98, 86, 108), eyePaint);
        canvas.drawPath(Path()..moveTo(114, 108)..quadraticBezierTo(122, 98, 130, 108), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(92, 132)..quadraticBezierTo(100, 140, 108, 132), mouthPaint);
        _drawSparkle(canvas, const Offset(22, 42), 0.9, BunSpritePalette.kemSparkleMint);
        _drawSparkle(canvas, const Offset(172, 50), 0.62, BunSpritePalette.highlightWhite);
      case BunSpriteState.inlove:
        _drawHeart(canvas, const Offset(77, 104), 0.95, BunSpritePalette.blushPink);
        _drawHeart(canvas, const Offset(121, 104), 0.95, BunSpritePalette.blushPink);
        final Path mouth = Path()..moveTo(93, 131)..quadraticBezierTo(100, 143, 107, 131)..close();
        canvas.drawPath(mouth, Paint()..color = BunSpritePalette.inloveMouth);
        _drawHeart(canvas, const Offset(170, 30), 0.8, BunSpritePalette.inloveBlush);
        _drawHeart(canvas, const Offset(26, 34), 0.55, BunSpritePalette.inloveHeartSmall);
      case BunSpriteState.neutral:
        canvas.drawOval(Rect.fromCenter(center: const Offset(78, 106), width: 15, height: 19), Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawOval(Rect.fromCenter(center: const Offset(122, 106), width: 15, height: 19), Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(79, 107), 4.5, Paint()..color = BunSpritePalette.kemEyePupil);
        canvas.drawCircle(const Offset(123, 107), 4.5, Paint()..color = BunSpritePalette.kemEyePupil);
        canvas.drawCircle(const Offset(80.5, 104.5), 1.8, Paint()..color = BunSpritePalette.highlightWhite);
        canvas.drawCircle(const Offset(124.5, 104.5), 1.8, Paint()..color = BunSpritePalette.highlightWhite);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(94, 134)..quadraticBezierTo(100, 138, 106, 134), mouthPaint);
      case BunSpriteState.sulk:
        final Paint eyePaint = Paint()..color = BunSpritePalette.highlightWhite..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(70, 108), const Offset(86, 108), eyePaint);
        canvas.drawLine(const Offset(114, 108), const Offset(130, 108), eyePaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(91, 138)..quadraticBezierTo(100, 130, 109, 138), mouthPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(160, 30), width: 34, height: 22), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        canvas.drawOval(Rect.fromCenter(center: const Offset(146, 34), width: 22, height: 16), Paint()..color = BunSpritePalette.sulkCloud.withValues(alpha: 0.9));
        final Path bolt = Path()..moveTo(158, 42)..lineTo(153, 54)..lineTo(161, 51)..lineTo(156, 62);
        canvas.drawPath(bolt, Paint()..color = BunSpritePalette.sulkRain..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      case BunSpriteState.sick:
        final Paint dizzyPaint = Paint()..color = BunSpritePalette.highlightWhite..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
        canvas.drawPath(Path()..moveTo(71, 100)..lineTo(85, 106)..lineTo(71, 112), dizzyPaint);
        canvas.drawPath(Path()..moveTo(129, 100)..lineTo(115, 106)..lineTo(129, 112), dizzyPaint);
        final Paint mouthPaint = Paint()..color = darkLine..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round;
        canvas.drawPath(Path()..moveTo(90, 136)..cubicTo(95, 131, 100, 136, 105, 141)..cubicTo(105, 141, 107.5, 138, 110, 136), mouthPaint);
        final Path tear = Path()..moveTo(172, 78)..cubicTo(172, 78, 166, 88, 166, 92.5)..cubicTo(166, 96, 168.7, 98.5, 172, 98.5)..cubicTo(175.3, 98.5, 178, 96, 178, 92.5)..cubicTo(178, 88, 172, 78, 172, 78)..close();
        canvas.drawPath(tear, Paint()..color = BunSpritePalette.sickSweatDrop.withValues(alpha: 0.9));
    }
  }
}
