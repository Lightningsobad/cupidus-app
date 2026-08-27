import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/emoji_palette.dart';
import '../../features/emojis/data/emoji_models.dart';

/// Renders a crisp vector graphic sticker for either Mochi Cat or Baby Dino.
class EmojiStickerGraphic extends StatelessWidget {
  const EmojiStickerGraphic({
    super.key,
    required this.emoji,
    this.size = 64,
    this.showLabel = false,
  });

  final EmojiItem emoji;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final bool isCat = emoji.id.startsWith('mochi_cat');

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _EmojiVectorPainter(
              emoji: emoji,
              isCat: isCat,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              emoji.localizedName(context),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: EmojiPalette.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmojiVectorPainter extends CustomPainter {
  _EmojiVectorPainter({
    required this.emoji,
    required this.isCat,
  });

  final EmojiItem emoji;
  final bool isCat;

  @override
  void paint(Canvas canvas, Size size) {
    if (isCat) {
      _drawMochiCat(canvas, size, emoji.emotion);
    } else {
      _drawBabyDino(canvas, size, emoji.emotion);
    }
  }

  void _drawMochiCat(Canvas canvas, Size size, String emotion) {
    final double s = math.min(size.width, size.height);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = s * 0.40;

    final Paint bodyPaint = Paint()
      ..color = EmojiPalette.catFur
      ..style = PaintingStyle.fill;

    final Paint earInnerPaint = Paint()
      ..color = EmojiPalette.catEarInner
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = EmojiPalette.catLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint blushPaint = Paint()
      ..color = EmojiPalette.catBlush
      ..style = PaintingStyle.fill;

    final Paint nosePaint = Paint()
      ..color = EmojiPalette.catNose
      ..style = PaintingStyle.fill;

    final Paint eyePaint = Paint()
      ..color = EmojiPalette.catEye
      ..style = PaintingStyle.fill;

    // 1. Draw Ears
    final Path leftEar = Path()
      ..moveTo(center.dx - radius * 0.82, center.dy - radius * 0.25)
      ..lineTo(center.dx - radius * 0.95, center.dy - radius * 1.05)
      ..lineTo(center.dx - radius * 0.25, center.dy - radius * 0.85)
      ..close();

    final Path rightEar = Path()
      ..moveTo(center.dx + radius * 0.82, center.dy - radius * 0.25)
      ..lineTo(center.dx + radius * 0.95, center.dy - radius * 1.05)
      ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.85)
      ..close();

    canvas.drawPath(leftEar, bodyPaint);
    canvas.drawPath(leftEar, outlinePaint);
    canvas.drawPath(rightEar, bodyPaint);
    canvas.drawPath(rightEar, outlinePaint);

    // Ear Inners
    final Path leftInner = Path()
      ..moveTo(center.dx - radius * 0.78, center.dy - radius * 0.32)
      ..lineTo(center.dx - radius * 0.88, center.dy - radius * 0.95)
      ..lineTo(center.dx - radius * 0.32, center.dy - radius * 0.80)
      ..close();
    final Path rightInner = Path()
      ..moveTo(center.dx + radius * 0.78, center.dy - radius * 0.32)
      ..lineTo(center.dx + radius * 0.88, center.dy - radius * 0.95)
      ..lineTo(center.dx + radius * 0.32, center.dy - radius * 0.80)
      ..close();
    canvas.drawPath(leftInner, earInnerPaint);
    canvas.drawPath(rightInner, earInnerPaint);

    // 2. Round Chubby Head
    canvas.drawCircle(center, radius, bodyPaint);
    canvas.drawCircle(center, radius, outlinePaint);

    // 3. Cute Pink Cheeks / Blush
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.62, center.dy + radius * 0.22),
        width: radius * 0.32,
        height: radius * 0.22,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.62, center.dy + radius * 0.22),
        width: radius * 0.32,
        height: radius * 0.22,
      ),
      blushPaint,
    );

    // 4. Little Whiskers
    final Paint whiskerPaint = Paint()
      ..color = EmojiPalette.catEye
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - radius * 0.92, center.dy + radius * 0.12),
      Offset(center.dx - radius * 0.65, center.dy + radius * 0.18),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.90, center.dy + radius * 0.30),
      Offset(center.dx - radius * 0.65, center.dy + radius * 0.26),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.92, center.dy + radius * 0.12),
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.18),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.90, center.dy + radius * 0.30),
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.26),
      whiskerPaint,
    );

    // 5. Emotion Specific Eyes & Mouth
    _drawCatEmotion(canvas, center, radius, s, emotion, eyePaint, outlinePaint, nosePaint);
  }

  void _drawCatEmotion(
    Canvas canvas,
    Offset center,
    double radius,
    double s,
    String emotion,
    Paint eyePaint,
    Paint outlinePaint,
    Paint nosePaint,
  ) {
    final Paint heartPaint = Paint()..color = EmojiPalette.accentHeart..style = PaintingStyle.fill;
    final Paint tearPaint = Paint()..color = EmojiPalette.accentTear..style = PaintingStyle.fill;
    final Paint sweatPaint = Paint()..color = EmojiPalette.accentSweat..style = PaintingStyle.fill;

    final Offset leftEye = Offset(center.dx - radius * 0.38, center.dy - radius * 0.05);
    final Offset rightEye = Offset(center.dx + radius * 0.38, center.dy - radius * 0.05);

    switch (emotion) {
      case 'love':
        _drawHeart(canvas, leftEye, radius * 0.28, heartPaint);
        _drawHeart(canvas, rightEye, radius * 0.28, heartPaint);
        _drawCatMouth(canvas, center, radius, false);
        break;

      case 'kiss':
        _drawWinkEye(canvas, leftEye, radius * 0.25, outlinePaint);
        canvas.drawCircle(rightEye, radius * 0.12, eyePaint);
        _drawKissMouth(canvas, center, radius);
        _drawHeart(canvas, Offset(center.dx + radius * 0.85, center.dy - radius * 0.25), radius * 0.22, heartPaint);
        break;

      case 'laugh':
        _drawLaughEye(canvas, leftEye, radius * 0.25, outlinePaint);
        _drawLaughEye(canvas, rightEye, radius * 0.25, outlinePaint);
        _drawCatTears(canvas, leftEye, rightEye, radius, tearPaint);
        final Path openMouth = Path()
          ..moveTo(center.dx - radius * 0.25, center.dy + radius * 0.28)
          ..quadraticBezierTo(center.dx, center.dy + radius * 0.65, center.dx + radius * 0.25, center.dy + radius * 0.28)
          ..close();
        canvas.drawPath(openMouth, Paint()..color = EmojiPalette.accentMouth);
        canvas.drawPath(openMouth, outlinePaint);
        break;

      case 'wink':
        _drawWinkEye(canvas, leftEye, radius * 0.25, outlinePaint);
        canvas.drawCircle(rightEye, radius * 0.13, eyePaint);
        _drawCatMouthWithTongue(canvas, center, radius);
        break;

      case 'cool':
        final Path glasses = Path()
          ..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: leftEye, width: radius * 0.62, height: radius * 0.45), Radius.circular(radius * 0.12)))
          ..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: rightEye, width: radius * 0.62, height: radius * 0.45), Radius.circular(radius * 0.12)))
          ..moveTo(leftEye.dx + radius * 0.28, leftEye.dy)
          ..lineTo(rightEye.dx - radius * 0.28, rightEye.dy);
        canvas.drawPath(glasses, Paint()..color = EmojiPalette.accentSunglasses);
        canvas.drawPath(glasses, outlinePaint);
        _drawSmirkMouth(canvas, center, radius);
        break;

      case 'shy':
        _drawLookAwayEyes(canvas, leftEye, rightEye, radius, eyePaint);
        _drawCatMouth(canvas, center, radius, false);
        break;

      case 'pout':
        _drawPoutEyes(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawPoutMouth(canvas, center, radius);
        break;

      case 'angry':
        _drawAngryEyes(canvas, leftEye, rightEye, radius, outlinePaint, eyePaint);
        _drawAngryMouth(canvas, center, radius);
        _drawAngerMark(canvas, Offset(center.dx + radius * 0.72, center.dy - radius * 0.65), radius * 0.22);
        break;

      case 'plead':
        _drawPleadingEye(canvas, leftEye, radius * 0.24, eyePaint);
        _drawPleadingEye(canvas, rightEye, radius * 0.24, eyePaint);
        _drawSadCatMouth(canvas, center, radius);
        break;

      case 'cry':
        _drawLaughEye(canvas, leftEye, radius * 0.22, outlinePaint);
        _drawLaughEye(canvas, rightEye, radius * 0.22, outlinePaint);
        _drawWaterfallTears(canvas, leftEye, rightEye, radius, tearPaint);
        _drawSadCatMouth(canvas, center, radius);
        break;

      case 'shock':
        canvas.drawCircle(leftEye, radius * 0.16, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.16, eyePaint);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.35), width: radius * 0.3, height: radius * 0.4),
          Paint()..color = EmojiPalette.accentDark,
        );
        break;

      case 'think':
        canvas.drawCircle(leftEye, radius * 0.12, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.12, eyePaint);
        _drawSmirkMouth(canvas, center, radius);
        _drawThinkingPaw(canvas, center, radius, outlinePaint);
        break;

      case 'sleep':
        _drawSleepingEyes(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawCatMouth(canvas, center, radius, false);
        _drawText(canvas, Offset(center.dx + radius * 0.7, center.dy - radius * 0.75), 'Zzz', EmojiPalette.accentZzz, s * 0.22);
        break;

      case 'hug':
        _drawHappyArcs(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawCatMouth(canvas, center, radius, true);
        canvas.drawCircle(Offset(center.dx - radius * 0.38, center.dy - radius * 0.05), radius * 0.2, Paint()..color = EmojiPalette.pureWhite);
        canvas.drawCircle(Offset(center.dx + radius * 0.38, center.dy - radius * 0.05), radius * 0.2, Paint()..color = EmojiPalette.pureWhite);
        break;

      case 'party':
        _drawHappyArcs(canvas, leftEye, rightEye, radius, outlinePaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.28), width: radius * 0.28, height: radius * 0.38), Paint()..color = EmojiPalette.catEye);
        // Party Hat
        final Path partyHat = Path()
          ..moveTo(center.dx - radius * 0.35, center.dy - radius * 0.75)
          ..lineTo(center.dx, center.dy - radius * 1.35)
          ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.75)
          ..close();
        canvas.drawPath(partyHat, Paint()..color = EmojiPalette.accentPartyHat);
        canvas.drawPath(partyHat, outlinePaint);
        canvas.drawCircle(Offset(center.dx, center.dy - radius * 1.35), radius * 0.1, Paint()..color = EmojiPalette.accentPartyPompom);
        break;

      case 'sweat':
        _drawHappyArcs(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawCatMouth(canvas, center, radius, true);
        _drawSweatDrop(canvas, Offset(center.dx + radius * 0.72, center.dy - radius * 0.52), radius * 0.18, sweatPaint);
        break;

      case 'sick':
        _drawSickEyes(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawSadCatMouth(canvas, center, radius);
        // Thermometer in mouth
        _drawThermometer(canvas, center, radius, outlinePaint);
        break;

      case 'gift':
        _drawHappyArcs(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawCatMouth(canvas, center, radius, true);
        final Rect giftBox = Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.55), width: radius * 0.65, height: radius * 0.55);
        canvas.drawRRect(RRect.fromRectAndRadius(giftBox, const Radius.circular(4)), Paint()..color = EmojiPalette.accentMouth);
        canvas.drawRRect(RRect.fromRectAndRadius(giftBox, const Radius.circular(4)), outlinePaint);
        canvas.drawRect(Rect.fromLTWH(giftBox.left, giftBox.top + giftBox.height * 0.4, giftBox.width, giftBox.height * 0.2), Paint()..color = EmojiPalette.accentGiftRibbon);
        canvas.drawRect(Rect.fromLTWH(giftBox.left + giftBox.width * 0.4, giftBox.top, giftBox.width * 0.2, giftBox.height), Paint()..color = EmojiPalette.accentGiftRibbon);
        break;

      case 'speechless':
        canvas.drawLine(Offset(leftEye.dx - radius * 0.15, leftEye.dy), Offset(leftEye.dx + radius * 0.15, leftEye.dy), outlinePaint);
        canvas.drawLine(Offset(rightEye.dx - radius * 0.15, rightEye.dy), Offset(rightEye.dx + radius * 0.15, rightEye.dy), outlinePaint);
        canvas.drawLine(Offset(center.dx - radius * 0.25, center.dy + radius * 0.25), Offset(center.dx + radius * 0.25, center.dy + radius * 0.25), outlinePaint);
        break;

      case 'happy':
      default:
        canvas.drawCircle(leftEye, radius * 0.13, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.13, eyePaint);
        _drawCatMouth(canvas, center, radius, true);
        break;
    }
  }

  // --- Cat Subparts Helpers ---
  void _drawCatMouth(Canvas canvas, Offset center, double radius, bool open) {
    final double mY = center.dy + radius * 0.22;
    canvas.drawCircle(Offset(center.dx, mY - radius * 0.04), radius * 0.045, Paint()..color = EmojiPalette.catBlush);

    final Paint p = Paint()
      ..color = EmojiPalette.catEye
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final Path mouth = Path()
      ..moveTo(center.dx - radius * 0.22, mY + radius * 0.02)
      ..quadraticBezierTo(center.dx - radius * 0.11, mY + radius * 0.12, center.dx, mY)
      ..quadraticBezierTo(center.dx + radius * 0.11, mY + radius * 0.12, center.dx + radius * 0.22, mY + radius * 0.02);

    canvas.drawPath(mouth, p);
  }

  void _drawCatMouthWithTongue(Canvas canvas, Offset center, double radius) {
    _drawCatMouth(canvas, center, radius, true);
    final double mY = center.dy + radius * 0.22;
    final Path tongue = Path()
      ..moveTo(center.dx - radius * 0.08, mY + radius * 0.04)
      ..quadraticBezierTo(center.dx, mY + radius * 0.22, center.dx + radius * 0.08, mY + radius * 0.04)
      ..close();
    canvas.drawPath(tongue, Paint()..color = EmojiPalette.accentPartyPompom);
  }

  void _drawKissMouth(Canvas canvas, Offset center, double radius) {
    final double mY = center.dy + radius * 0.22;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.08, mY), width: radius * 0.14, height: radius * 0.20),
      Paint()..color = EmojiPalette.catEye,
    );
  }

  void _drawSmirkMouth(Canvas canvas, Offset center, double radius) {
    final Paint p = Paint()..color = EmojiPalette.catEye..style = PaintingStyle.stroke..strokeWidth = radius * 0.08..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - radius * 0.1, center.dy + radius * 0.25), Offset(center.dx + radius * 0.2, center.dy + radius * 0.20), p);
  }

  void _drawPoutMouth(Canvas canvas, Offset center, double radius) {
    final Paint p = Paint()..color = EmojiPalette.catEye..style = PaintingStyle.stroke..strokeWidth = radius * 0.08..strokeCap = StrokeCap.round;
    final Path mouth = Path()
      ..moveTo(center.dx - radius * 0.15, center.dy + radius * 0.28)
      ..quadraticBezierTo(center.dx, center.dy + radius * 0.18, center.dx + radius * 0.15, center.dy + radius * 0.28);
    canvas.drawPath(mouth, p);
  }

  void _drawAngryMouth(Canvas canvas, Offset center, double radius) {
    final Paint p = Paint()..color = EmojiPalette.catEye..style = PaintingStyle.stroke..strokeWidth = radius * 0.08..strokeCap = StrokeCap.round;
    final Path mouth = Path()
      ..moveTo(center.dx - radius * 0.2, center.dy + radius * 0.32)
      ..lineTo(center.dx + radius * 0.2, center.dy + radius * 0.32);
    canvas.drawPath(mouth, p);
  }

  void _drawPleadingEye(Canvas canvas, Offset center, double radius, Paint eyePaint) {
    canvas.drawCircle(center, radius, Paint()..color = EmojiPalette.catEye);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.35), radius * 0.45, Paint()..color = EmojiPalette.pureWhite);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy + radius * 0.35), radius * 0.22, Paint()..color = EmojiPalette.pureWhite);
  }

  void _drawAngerMark(Canvas canvas, Offset center, double s) {
    final Paint anger = Paint()..color = EmojiPalette.accentAnger..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - s, center.dy), Offset(center.dx + s, center.dy), anger);
    canvas.drawLine(Offset(center.dx, center.dy - s), Offset(center.dx, center.dy + s), anger);
  }

  void _drawThinkingPaw(Canvas canvas, Offset center, double radius, Paint outlinePaint) {
    final Path paw = Path()
      ..addOval(Rect.fromCenter(center: Offset(center.dx + radius * 0.35, center.dy + radius * 0.38), width: radius * 0.32, height: radius * 0.25));
    canvas.drawPath(paw, Paint()..color = EmojiPalette.catFur);
    canvas.drawPath(paw, outlinePaint);
  }

  void _drawThermometer(Canvas canvas, Offset center, double radius, Paint outlinePaint) {
    final Paint tube = Paint()..color = EmojiPalette.pureWhite..style = PaintingStyle.fill;
    final Paint mercury = Paint()..color = EmojiPalette.accentAnger..style = PaintingStyle.fill;
    final Rect rect = Rect.fromLTWH(center.dx - radius * 0.1, center.dy + radius * 0.18, radius * 0.65, radius * 0.15);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), tube);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), outlinePaint);
    canvas.drawCircle(Offset(rect.right, rect.center.dy), radius * 0.1, mercury);
  }

  // --- Baby Dino Drawing ---
  void _drawBabyDino(Canvas canvas, Size size, String emotion) {
    final double s = math.min(size.width, size.height);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = s * 0.38;

    final Paint skinPaint = Paint()
      ..color = EmojiPalette.dinoSkin
      ..style = PaintingStyle.fill;

    final Paint bellyPaint = Paint()
      ..color = EmojiPalette.dinoBelly
      ..style = PaintingStyle.fill;

    final Paint spinePaint = Paint()
      ..color = EmojiPalette.dinoSpines
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = EmojiPalette.dinoLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint blushPaint = Paint()
      ..color = EmojiPalette.dinoBlush
      ..style = PaintingStyle.fill;

    final Paint eyePaint = Paint()
      ..color = EmojiPalette.dinoEye
      ..style = PaintingStyle.fill;

    // 1. Spines / Plates on head
    for (int i = -1; i <= 1; i++) {
      final double angle = -math.pi / 2 + i * 0.45;
      final Offset base = Offset(center.dx + math.cos(angle) * radius * 0.95, center.dy + math.sin(angle) * radius * 0.95);
      final Path spine = Path()
        ..moveTo(base.dx - 6, base.dy)
        ..lineTo(base.dx + math.cos(angle) * 14, base.dy + math.sin(angle) * 14)
        ..lineTo(base.dx + 6, base.dy)
        ..close();
      canvas.drawPath(spine, spinePaint);
      canvas.drawPath(spine, outlinePaint);
    }

    // 2. Head Shape
    final Path head = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 2.1, height: radius * 1.9),
        Radius.circular(radius * 0.75),
      ));
    canvas.drawPath(head, skinPaint);
    canvas.drawPath(head, outlinePaint);

    // 3. Cute Yellow/Light Belly patch
    final Path belly = Path()
      ..addOval(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.65), width: radius * 1.4, height: radius * 0.75));
    canvas.drawPath(belly, bellyPaint);

    // 4. Cheeks
    canvas.drawCircle(Offset(center.dx - radius * 0.65, center.dy + radius * 0.22), radius * 0.15, blushPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.65, center.dy + radius * 0.22), radius * 0.15, blushPaint);

    // 5. Dino Nostrils
    canvas.drawCircle(Offset(center.dx - radius * 0.14, center.dy + radius * 0.12), radius * 0.04, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.14, center.dy + radius * 0.12), radius * 0.04, eyePaint);

    // 6. Emotion Eyes & Mouth
    _drawDinoEmotion(canvas, center, radius, s, emotion, eyePaint, outlinePaint);
  }

  void _drawDinoEmotion(
    Canvas canvas,
    Offset center,
    double radius,
    double s,
    String emotion,
    Paint eyePaint,
    Paint outlinePaint,
  ) {
    final Paint heartPaint = Paint()..color = EmojiPalette.accentHeart..style = PaintingStyle.fill;
    final Paint firePaint = Paint()..color = EmojiPalette.accentFire..style = PaintingStyle.fill;
    final Paint tearPaint = Paint()..color = EmojiPalette.accentTear..style = PaintingStyle.fill;

    final Offset leftEye = Offset(center.dx - radius * 0.42, center.dy - radius * 0.12);
    final Offset rightEye = Offset(center.dx + radius * 0.42, center.dy - radius * 0.12);

    switch (emotion) {
      case 'love':
        _drawHeart(canvas, leftEye, radius * 0.28, heartPaint);
        _drawHeart(canvas, rightEye, radius * 0.28, heartPaint);
        _drawDinoMouth(canvas, center, radius);
        break;

      case 'angry':
        _drawAngryEyes(canvas, leftEye, rightEye, radius, outlinePaint, eyePaint);
        _drawDinoMouth(canvas, center, radius);
        // Little cute flame breath
        final Path flame = Path()
          ..moveTo(center.dx + radius * 0.35, center.dy + radius * 0.35)
          ..quadraticBezierTo(center.dx + radius * 0.9, center.dy + radius * 0.2, center.dx + radius * 1.1, center.dy + radius * 0.45)
          ..quadraticBezierTo(center.dx + radius * 0.8, center.dy + radius * 0.6, center.dx + radius * 0.35, center.dy + radius * 0.45)
          ..close();
        canvas.drawPath(flame, firePaint);
        break;

      case 'cry':
        _drawLaughEye(canvas, leftEye, radius * 0.22, outlinePaint);
        _drawLaughEye(canvas, rightEye, radius * 0.22, outlinePaint);
        _drawWaterfallTears(canvas, leftEye, rightEye, radius, tearPaint);
        final Rect wail = Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.38), width: radius * 0.4, height: radius * 0.3);
        canvas.drawOval(wail, Paint()..color = EmojiPalette.accentMouth);
        canvas.drawOval(wail, outlinePaint);
        break;

      case 'cool':
        final Path glasses = Path()
          ..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: leftEye, width: radius * 0.65, height: radius * 0.45), Radius.circular(radius * 0.12)))
          ..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: rightEye, width: radius * 0.65, height: radius * 0.45), Radius.circular(radius * 0.12)))
          ..moveTo(leftEye.dx + radius * 0.3, leftEye.dy)
          ..lineTo(rightEye.dx - radius * 0.3, rightEye.dy);
        canvas.drawPath(glasses, Paint()..color = EmojiPalette.accentSunglasses);
        canvas.drawPath(glasses, outlinePaint);
        _drawSmirkMouth(canvas, center, radius);
        break;

      case 'sleep':
        _drawSleepingEyes(canvas, leftEye, rightEye, radius, outlinePaint);
        _drawDinoMouth(canvas, center, radius);
        final Offset bubblePos = Offset(center.dx + radius * 0.45, center.dy + radius * 0.25);
        canvas.drawCircle(bubblePos, radius * 0.22, Paint()..color = EmojiPalette.accentSweat.withValues(alpha: 0.7));
        canvas.drawCircle(bubblePos, radius * 0.22, outlinePaint);
        break;

      case 'think':
        canvas.drawCircle(leftEye, radius * 0.14, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.14, eyePaint);
        final Rect gRect = Rect.fromCenter(center: rightEye, width: radius * 0.42, height: radius * 0.42);
        canvas.drawRRect(RRect.fromRectAndRadius(gRect, Radius.circular(radius * 0.12)), Paint()..color = EmojiPalette.accentDark);
        _drawSmirkMouth(canvas, center, radius);
        break;

      case 'happy':
      default:
        canvas.drawCircle(leftEye, radius * 0.14, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.14, eyePaint);
        canvas.drawCircle(Offset(leftEye.dx - radius * 0.04, leftEye.dy - radius * 0.04), radius * 0.04, Paint()..color = EmojiPalette.pureWhite);
        canvas.drawCircle(Offset(rightEye.dx - radius * 0.04, rightEye.dy - radius * 0.04), radius * 0.04, Paint()..color = EmojiPalette.pureWhite);
        _drawDinoMouth(canvas, center, radius);
        break;
    }
  }

  void _drawDinoMouth(Canvas canvas, Offset center, double radius) {
    final Paint p = Paint()
      ..color = EmojiPalette.dinoEye
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final Path mouth = Path()
      ..moveTo(center.dx - radius * 0.28, center.dy + radius * 0.32)
      ..quadraticBezierTo(center.dx, center.dy + radius * 0.52, center.dx + radius * 0.28, center.dy + radius * 0.32);

    canvas.drawPath(mouth, p);

    // Cute little tooth
    final Path tooth = Path()
      ..moveTo(center.dx - radius * 0.12, center.dy + radius * 0.35)
      ..lineTo(center.dx - radius * 0.06, center.dy + radius * 0.45)
      ..lineTo(center.dx, center.dy + radius * 0.38)
      ..close();
    canvas.drawPath(tooth, Paint()..color = EmojiPalette.pureWhite);
    canvas.drawPath(tooth, p);
  }

  // --- Shared Primitive Helpers ---
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path();
    path.moveTo(center.dx, center.dy + size * 0.55);
    path.cubicTo(center.dx - size * 0.9, center.dy - size * 0.15, center.dx - size * 0.55, center.dy - size * 0.85, center.dx, center.dy - size * 0.35);
    path.cubicTo(center.dx + size * 0.55, center.dy - size * 0.85, center.dx + size * 0.9, center.dy - size * 0.15, center.dx, center.dy + size * 0.55);
    canvas.drawPath(path, paint);
  }

  void _drawWinkEye(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path()
      ..moveTo(center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - size * 0.7, center.dx + size, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawLaughEye(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path()
      ..moveTo(center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - size * 0.8, center.dx + size, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawHappyArcs(Canvas canvas, Offset left, Offset right, double radius, Paint paint) {
    final double s = radius * 0.22;
    canvas.drawPath(Path()..moveTo(left.dx - s, left.dy)..quadraticBezierTo(left.dx, left.dy - s * 0.8, left.dx + s, left.dy), paint);
    canvas.drawPath(Path()..moveTo(right.dx - s, right.dy)..quadraticBezierTo(right.dx, right.dy - s * 0.8, right.dx + s, right.dy), paint);
  }

  void _drawSleepingEyes(Canvas canvas, Offset left, Offset right, double radius, Paint paint) {
    final double s = radius * 0.22;
    canvas.drawPath(Path()..moveTo(left.dx - s, left.dy)..quadraticBezierTo(left.dx, left.dy + s * 0.6, left.dx + s, left.dy), paint);
    canvas.drawPath(Path()..moveTo(right.dx - s, right.dy)..quadraticBezierTo(right.dx, right.dy + s * 0.6, right.dx + s, right.dy), paint);
  }

  void _drawAngryEyes(Canvas canvas, Offset left, Offset right, double radius, Paint outlinePaint, Paint eyePaint) {
    canvas.drawLine(Offset(left.dx - radius * 0.2, left.dy - radius * 0.15), Offset(left.dx + radius * 0.2, left.dy + radius * 0.05), outlinePaint);
    canvas.drawLine(Offset(right.dx + radius * 0.2, right.dy - radius * 0.15), Offset(right.dx - radius * 0.2, right.dy + radius * 0.05), outlinePaint);
    canvas.drawCircle(leftEyeOffset(left, radius), radius * 0.11, eyePaint);
    canvas.drawCircle(rightEyeOffset(right, radius), radius * 0.11, eyePaint);
  }

  Offset leftEyeOffset(Offset left, double radius) => Offset(left.dx, left.dy + radius * 0.05);
  Offset rightEyeOffset(Offset right, double radius) => Offset(right.dx, right.dy + radius * 0.05);

  void _drawPoutEyes(Canvas canvas, Offset left, Offset right, double radius, Paint outlinePaint) {
    canvas.drawLine(Offset(left.dx - radius * 0.2, left.dy + radius * 0.05), Offset(left.dx + radius * 0.15, left.dy - radius * 0.05), outlinePaint);
    canvas.drawLine(Offset(right.dx + radius * 0.2, right.dy + radius * 0.05), Offset(right.dx - radius * 0.15, right.dy - radius * 0.05), outlinePaint);
  }

  void _drawLookAwayEyes(Canvas canvas, Offset left, Offset right, double radius, Paint eyePaint) {
    canvas.drawCircle(Offset(left.dx + radius * 0.08, left.dy), radius * 0.13, eyePaint);
    canvas.drawCircle(Offset(right.dx + radius * 0.08, right.dy), radius * 0.13, eyePaint);
  }

  void _drawSickEyes(Canvas canvas, Offset left, Offset right, double radius, Paint paint) {
    final double s = radius * 0.14;
    canvas.drawLine(Offset(left.dx - s, left.dy - s), Offset(left.dx + s, left.dy + s), paint);
    canvas.drawLine(Offset(left.dx - s, left.dy + s), Offset(left.dx + s, left.dy - s), paint);
    canvas.drawLine(Offset(right.dx - s, right.dy - s), Offset(right.dx + s, right.dy + s), paint);
    canvas.drawLine(Offset(right.dx - s, right.dy + s), Offset(right.dx + s, right.dy - s), paint);
  }

  void _drawCatTears(Canvas canvas, Offset left, Offset right, double radius, Paint paint) {
    canvas.drawOval(Rect.fromCenter(center: Offset(left.dx - radius * 0.25, left.dy + radius * 0.2), width: radius * 0.18, height: radius * 0.3), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(right.dx + radius * 0.25, right.dy + radius * 0.2), width: radius * 0.18, height: radius * 0.3), paint);
  }

  void _drawWaterfallTears(Canvas canvas, Offset left, Offset right, double radius, Paint paint) {
    final Rect leftR = Rect.fromLTWH(left.dx - radius * 0.15, left.dy, radius * 0.3, radius * 0.7);
    final Rect rightR = Rect.fromLTWH(right.dx - radius * 0.15, right.dy, radius * 0.3, radius * 0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(leftR, const Radius.circular(6)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightR, const Radius.circular(6)), paint);
  }

  void _drawSweatDrop(Canvas canvas, Offset center, double size, Paint paint) {
    final Path p = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx + size, center.dy + size * 0.5, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx - size, center.dy + size * 0.5, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(p, paint);
  }

  void _drawSadCatMouth(Canvas canvas, Offset center, double radius) {
    final Paint p = Paint()..color = EmojiPalette.catEye..style = PaintingStyle.stroke..strokeWidth = radius * 0.08..strokeCap = StrokeCap.round;
    final Path mouth = Path()
      ..moveTo(center.dx - radius * 0.2, center.dy + radius * 0.35)
      ..quadraticBezierTo(center.dx, center.dy + radius * 0.22, center.dx + radius * 0.2, center.dy + radius * 0.35);
    canvas.drawPath(mouth, p);
  }

  void _drawText(Canvas canvas, Offset center, String text, Color color, double fontSize) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _EmojiVectorPainter oldDelegate) =>
      oldDelegate.emoji.code != emoji.code || oldDelegate.isCat != isCat;
}
