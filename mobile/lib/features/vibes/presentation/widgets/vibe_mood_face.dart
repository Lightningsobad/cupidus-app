import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/tokens/mood_face_palette.dart';
import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';

/// The seven drawn faces of the design source's `Mood Face` component
/// (`cupid-app-design-system/project/Mood Face.dc.html`).
///
/// [soft] has no backend `Mood` value (`ux/uiux-spec.md` §3 drops it), so
/// [forMood] never returns it; the artwork exists so this widget stays a
/// complete port of the design component rather than a partial one.
enum MoodFaceArt {
  happy,
  soft,
  sad,
  angry,
  tired,
  spicy,
  none;

  /// `null` is the "no check-in yet" state, which the design source models as
  /// its own `none` face rather than an absent glyph.
  static MoodFaceArt forMood(VibeMood? mood) => switch (mood) {
    null => MoodFaceArt.none,
    VibeMood.happy => MoodFaceArt.happy,
    VibeMood.sad => MoodFaceArt.sad,
    VibeMood.angry => MoodFaceArt.angry,
    VibeMood.horny => MoodFaceArt.spicy,
    VibeMood.tired => MoodFaceArt.tired,
  };
}

/// The mood glyph reused by the grid, partner card and history strip
/// (`ux/uiux-spec.md` §3, §5, §6 — design source's `Mood Face` component).
/// Renders the `none`/waiting state for `null` (no check-in yet, or the
/// UX §7 partner-unpair defensive fallback).
///
/// Always exposes [mood]'s label as its accessible name (UX §8: never the
/// artwork alone). Composite callers that build their own combined semantics
/// (for example the selectable grid cell) should wrap this widget in
/// `ExcludeSemantics` to avoid a duplicate announcement.
class VibeMoodFace extends StatelessWidget {
  const VibeMoodFace({super.key, required this.mood, this.size = 36});

  final VibeMood? mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final VibeMood? mood = this.mood;
    final String label = mood == null
        ? context.waitingLabel
        : context.moodLabel(mood);

    return Semantics(
      label: label,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: MoodFacePainter(MoodFaceArt.forMood(mood))),
      ),
    );
  }
}

/// Renders one [MoodFaceArt] at the design source's `viewBox="0 0 100 100"`
/// scale. Every path, ellipse, stroke width and color below is transcribed
/// from the matching `<sc-if>` branch of `Mood Face.dc.html`.
///
/// Static frame only: the source's `mfBob`/`mfDrift`/`mfTear`/`mfZ` keyframes
/// are not implemented (accepted deferral — an unbounded repeating animation
/// makes `pumpAndSettle` in this feature's widget tests time out). Accents
/// driven by `mfTear`/`mfZ` start at `opacity:0`, so painting a literal `t=0`
/// frame would silently drop them; they are drawn at their authored position
/// and peak keyframe opacity instead.
///
/// Public so a test can cover all seven faces, including [MoodFaceArt.soft],
/// which no [VibeMood] maps to.
class MoodFacePainter extends CustomPainter {
  const MoodFacePainter(this.art);

  final MoodFaceArt art;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);
    switch (art) {
      case MoodFaceArt.happy:
        _paintHappy(canvas);
      case MoodFaceArt.soft:
        _paintSoft(canvas);
      case MoodFaceArt.sad:
        _paintSad(canvas);
      case MoodFaceArt.angry:
        _paintAngry(canvas);
      case MoodFaceArt.tired:
        _paintTired(canvas);
      case MoodFaceArt.spicy:
        _paintSpicy(canvas);
      case MoodFaceArt.none:
        _paintNone(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MoodFacePainter oldDelegate) => oldDelegate.art != art;
}

/// `<circle cx="50" cy="50" r="38">`, the shared face disc of all six drawn
/// moods, and the bounding box its vertical `linearGradient` spans.
const Rect _faceBounds = Rect.fromLTRB(12, 12, 88, 88);

void _paintDisc(Canvas canvas, Color top, Color bottom) {
  canvas.drawCircle(
    const Offset(50, 50),
    38,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[top, bottom],
      ).createShader(_faceBounds),
  );
}

Paint _stroke(Color color, double width, [double opacity = 1]) => Paint()
  ..color = color.withValues(alpha: opacity)
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

Paint _fill(Color color, [double opacity = 1]) =>
    Paint()..color = color.withValues(alpha: opacity);

void _oval(Canvas canvas, double cx, double cy, double rx, double ry, Paint p) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
    p,
  );
}

/// `M x1 y1 Q cx cy x2 y2` — the one curve shape every brow, eye-arc and
/// mouth in the source is built from.
Path _quad(
  double x1,
  double y1,
  double cx,
  double cy,
  double x2,
  double y2,
) => Path()
  ..moveTo(x1, y1)
  ..quadraticBezierTo(cx, cy, x2, y2);

/// The 4-point sparkle at `translate(78,12)` in the happy face.
Path _sparklePath() => Path()
  ..moveTo(6, 0)
  ..cubicTo(6.4, 3.5, 8.5, 5.6, 12, 6)
  ..cubicTo(8.5, 6.4, 6.4, 8.5, 6, 12)
  ..cubicTo(5.6, 8.5, 3.5, 6.4, 0, 6)
  ..cubicTo(3.5, 5.6, 5.6, 3.5, 6, 0)
  ..close();

/// The heart used for both of the soft face's eyes and its drifting accent.
Path _heartPath() => Path()
  ..moveTo(8, 14)
  ..cubicTo(8, 14, 1.2, 9.5, 1.2, 5.3)
  ..cubicTo(1.2, 3, 3, 1.4, 5, 1.4)
  ..cubicTo(6.4, 1.4, 7.5, 2.2, 8, 3.2)
  ..cubicTo(8.5, 2.2, 9.6, 1.4, 11, 1.4)
  ..cubicTo(13, 1.4, 14.8, 3, 14.8, 5.3)
  ..cubicTo(14.8, 9.5, 8, 14, 8, 14)
  ..close();

/// The sad face's teardrop at `translate(28,60)`.
Path _tearPath() => Path()
  ..moveTo(4, 0)
  ..cubicTo(4, 0, 0, 6, 0, 8.6)
  ..cubicTo(0, 10.8, 1.8, 12.5, 4, 12.5)
  ..cubicTo(6.2, 12.5, 8, 10.8, 8, 8.6)
  ..cubicTo(8, 6, 4, 0, 4, 0)
  ..close();

void _paintHappy(Canvas canvas) {
  _paintDisc(
    canvas,
    MoodFacePalette.happyFaceTop,
    MoodFacePalette.happyFaceBottom,
  );
  final Paint ink = _stroke(MoodFacePalette.happyInk, 5);
  canvas.drawPath(_quad(31, 50, 38, 40, 45, 50), ink);
  canvas.drawPath(_quad(55, 50, 62, 40, 69, 50), ink);

  final Paint blush = _fill(MoodFacePalette.happyBlush, 0.5);
  _oval(canvas, 26, 61, 7, 4.5, blush);
  _oval(canvas, 74, 61, 7, 4.5, blush);

  canvas.drawPath(_quad(39, 63, 50, 75, 61, 63), ink);
  canvas.drawPath(
    _sparklePath().shift(const Offset(78, 12)),
    _fill(MoodFacePalette.happySparkle),
  );
}

void _paintSoft(Canvas canvas) {
  _paintDisc(
    canvas,
    MoodFacePalette.softFaceTop,
    MoodFacePalette.softFaceBottom,
  );
  final Path heart = _heartPath();
  final Paint ink = _fill(MoodFacePalette.softInk);
  canvas.drawPath(heart.shift(const Offset(30, 42)), ink);
  canvas.drawPath(heart.shift(const Offset(54, 42)), ink);

  final Paint blush = _fill(MoodFacePalette.softBlush, 0.45);
  _oval(canvas, 24, 63, 7.5, 4.5, blush);
  _oval(canvas, 76, 63, 7.5, 4.5, blush);

  canvas.drawPath(_quad(43, 65, 50, 73, 57, 65)..close(), ink);
  canvas.drawPath(
    heart
        .transform(Matrix4.diagonal3Values(0.9, 0.9, 1).storage)
        .shift(const Offset(76, 8)),
    _fill(MoodFacePalette.softHeart),
  );
}

/// `mfTear` peak opacity — see [_MoodFacePainter]'s static-frame note.
const double _tearOpacity = 0.95;

void _paintSad(Canvas canvas) {
  _paintDisc(canvas, MoodFacePalette.sadFaceTop, MoodFacePalette.sadFaceBottom);
  final Paint brow = _stroke(MoodFacePalette.sadInk, 3.6);
  canvas.drawPath(_quad(27, 39, 36, 34, 44, 39), brow);
  canvas.drawPath(_quad(73, 39, 64, 34, 56, 39), brow);

  final Paint ink = _fill(MoodFacePalette.sadInk);
  _oval(canvas, 36, 53, 8, 9.5, ink);
  _oval(canvas, 64, 53, 8, 9.5, ink);

  final Paint highlight = _fill(MoodFacePalette.eyeHighlight);
  canvas.drawCircle(const Offset(38.5, 49), 3.2, highlight);
  canvas.drawCircle(const Offset(66.5, 49), 3.2, highlight);
  final Paint softHighlight = _fill(MoodFacePalette.eyeHighlight, 0.8);
  canvas.drawCircle(const Offset(33, 56.5), 1.8, softHighlight);
  canvas.drawCircle(const Offset(61, 56.5), 1.8, softHighlight);

  canvas.drawPath(
    _quad(42, 71, 50, 65, 58, 71),
    _stroke(MoodFacePalette.sadInk, 4.2),
  );
  canvas.drawPath(
    _tearPath().shift(const Offset(28, 60)),
    _fill(MoodFacePalette.sadTear, _tearOpacity),
  );
}

void _paintAngry(Canvas canvas) {
  _paintDisc(
    canvas,
    MoodFacePalette.angryFaceTop,
    MoodFacePalette.angryFaceBottom,
  );
  final Paint brow = _stroke(MoodFacePalette.angryInk, 4.4);
  canvas.drawLine(const Offset(28, 40), const Offset(45, 46), brow);
  canvas.drawLine(const Offset(72, 40), const Offset(55, 46), brow);

  final Paint ink = _fill(MoodFacePalette.angryInk);
  _oval(canvas, 37, 55, 5, 6, ink);
  _oval(canvas, 63, 55, 5, 6, ink);

  canvas.drawPath(
    _quad(40, 71, 50, 63, 60, 71),
    _stroke(MoodFacePalette.angryInk, 4.6),
  );

  final Paint steam = _stroke(MoodFacePalette.angrySteam, 3.4);
  canvas.drawPath(
    Path()
      ..moveTo(76, 24)
      ..cubicTo(82, 20, 88, 22, 88, 27)
      ..moveTo(84, 32)
      ..cubicTo(90, 30, 95, 33, 93, 38),
    steam,
  );
}

/// `mfZ` peak opacity — see [_MoodFacePainter]'s static-frame note.
const double _sleepMarkOpacity = 0.9;

void _paintTired(Canvas canvas) {
  _paintDisc(
    canvas,
    MoodFacePalette.tiredFaceTop,
    MoodFacePalette.tiredFaceBottom,
  );
  final Paint eye = _stroke(MoodFacePalette.tiredInk, 4.6);
  canvas.drawPath(_quad(30, 50, 38, 58, 46, 50), eye);
  canvas.drawPath(_quad(54, 50, 62, 58, 70, 50), eye);

  final Paint blush = _fill(MoodFacePalette.tiredBlush, 0.6);
  _oval(canvas, 26, 60, 6.5, 4, blush);
  _oval(canvas, 74, 60, 6.5, 4, blush);

  _oval(canvas, 50, 68, 4.5, 5.5, _fill(MoodFacePalette.tiredInk));

  _paintSleepMark(canvas, 76, 26, 14);
  _paintSleepMark(canvas, 84, 16, 10);
}

/// One `<text ...>z</text>` sleep mark. SVG `y` is the alphabetic baseline,
/// so the glyph is lifted by its own ascent before painting.
void _paintSleepMark(
  Canvas canvas,
  double x,
  double baselineY,
  double fontSize,
) {
  final TextPainter painter = TextPainter(
    text: TextSpan(
      text: 'z',
      style: TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
        color: MoodFacePalette.tiredSleepMark.withValues(
          alpha: _sleepMarkOpacity,
        ),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    Offset(x, baselineY - painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    )),
  );
}

void _paintSpicy(Canvas canvas) {
  _paintDisc(
    canvas,
    MoodFacePalette.spicyFaceTop,
    MoodFacePalette.spicyFaceBottom,
  );
  final Paint ink = _fill(MoodFacePalette.spicyInk);
  _oval(canvas, 37, 50, 7.5, 9, ink);
  _oval(canvas, 63, 50, 7.5, 9, ink);

  final Paint highlight = _fill(MoodFacePalette.eyeHighlight);
  canvas.drawCircle(const Offset(40, 46), 3, highlight);
  canvas.drawCircle(const Offset(66, 46), 3, highlight);

  final Paint blush = _fill(MoodFacePalette.spicyBlush, 0.65);
  _oval(canvas, 23, 60, 8.5, 5.5, blush);
  _oval(canvas, 77, 60, 8.5, 5.5, blush);

  final Paint heatLines = _stroke(MoodFacePalette.spicyBlush, 2, 0.55);
  canvas.drawPath(
    Path()
      ..moveTo(18, 57)
      ..lineTo(28, 57)
      ..moveTo(18, 62)
      ..lineTo(28, 62)
      ..moveTo(72, 57)
      ..lineTo(82, 57)
      ..moveTo(72, 62)
      ..lineTo(82, 62),
    heatLines,
  );

  canvas.drawPath(
    _quad(42, 69, 46, 65, 50, 69)..quadraticBezierTo(54, 73, 58, 69),
    _stroke(MoodFacePalette.spicyInk, 4),
  );
  canvas.drawPath(
    Path()
      ..moveTo(74, 22)
      ..cubicTo(80, 18, 84, 22, 82, 27),
    _stroke(MoodFacePalette.spicySteam, 3.2),
  );
}

void _paintNone(Canvas canvas) {
  canvas.drawPath(
    _dash(
      Path()..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 38)),
      7,
      7,
    ),
    _stroke(MoodFacePalette.noneOutline, 3.5, 0.7),
  );

  final Paint eye = _fill(MoodFacePalette.noneOutline, 0.75);
  canvas.drawCircle(const Offset(38, 48), 4, eye);
  canvas.drawCircle(const Offset(62, 48), 4, eye);
  canvas.drawLine(
    const Offset(38, 66),
    const Offset(62, 66),
    _stroke(MoodFacePalette.noneOutline, 4, 0.75),
  );
}

/// Flutter has no `stroke-dasharray`, so the `none` face's dashed outline is
/// rebuilt as alternating extracted sub-paths.
Path _dash(Path source, double dash, double gap) {
  final Path dashed = Path();
  for (final ui.PathMetric metric in source.computeMetrics()) {
    double start = 0;
    while (start < metric.length) {
      final double end = start + dash;
      dashed.addPath(
        metric.extractPath(start, end > metric.length ? metric.length : end),
        Offset.zero,
      );
      start = end + gap;
    }
  }
  return dashed;
}
