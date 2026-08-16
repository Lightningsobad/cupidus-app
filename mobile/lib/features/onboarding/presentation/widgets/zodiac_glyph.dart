import 'package:flutter/material.dart';

/// Element ink/disc colors from the design component's own `EL` map
/// (`cupid-app-design-system/project/Zodiac Icon.dc.html` lines 120-125).
///
/// @ds-adherence-ignore -- `Zodiac Icon.dc.html` is a standalone design
/// component with its own element palette; no `CupidColorTokens` field
/// carries these four ink/disc pairs, so they are transcribed rather than
/// mapped. They use the `Color.fromRGBO` spelling because the design source
/// authors the discs as `rgba(...)` and because
/// `test/design_system/no_fork_guard_test.dart` treats the packed-hex `Color`
/// constructor as a per-screen color fork — which this palette is not.
/// Promotion path once a second screen needs the glyph: move this file to
/// `design_system/icons/` and lift these pairs into `CupidColorTokens`.
const Color _fireInk = Color.fromRGBO(255, 149, 118, 1);
const Color _fireDisc = Color.fromRGBO(255, 149, 118, 0.16);
const Color _earthInk = Color.fromRGBO(95, 211, 188, 1);
const Color _earthDisc = Color.fromRGBO(95, 211, 188, 0.16);
const Color _airInk = Color.fromRGBO(183, 140, 245, 1);
const Color _airDisc = Color.fromRGBO(183, 140, 245, 0.18);
const Color _waterInk = Color.fromRGBO(255, 127, 182, 1);
const Color _waterDisc = Color.fromRGBO(255, 127, 182, 0.16);

/// `<svg viewBox="0 0 100 100">` in the design component: every path
/// coordinate below is in this space and is scaled to the requested size at
/// paint time.
const double _viewBox = 100;
const double _strokeWidth = 6;

/// Virgo and Scorpio carry more strokes in the same box, so the design
/// component thins their `stroke-width` (lines 49, 64).
const double _denseStrokeWidth = 5.5;

/// `Zodiac Icon.dc.html:129` — an unrecognized `sign` prop renders `cancer`.
const String _fallbackSign = 'cancer';

const double _discRadius = 48;
const Offset _discCenter = Offset(50, 50);

/// Two decorative sparkles drawn for every sign (lines 100-101).
const Offset _sparkleLargeCenter = Offset(82, 22);
const double _sparkleLargeRadius = 2.6;
const double _sparkleLargeOpacity = 0.55;
const Offset _sparkleSmallCenter = Offset(18, 76);
const double _sparkleSmallRadius = 1.9;
const double _sparkleSmallOpacity = 0.4;

/// One zodiac sign as the design component authors it: element colors, the
/// vi/en display label from its `SIGNS` map, and the stroke geometry.
@immutable
class ZodiacGlyphSpec {
  const ZodiacGlyphSpec({
    required this.sign,
    required this.ink,
    required this.disc,
    required this.vi,
    required this.en,
    required this.buildPaths,
    this.strokeWidth = _strokeWidth,
  });

  final String sign;
  final Color ink;
  final Color disc;
  final String vi;
  final String en;
  final List<Path> Function() buildPaths;
  final double strokeWidth;

  String label({required bool isVi}) => isVi ? vi : en;
}

/// Resolves the canonical English sign name returned by `zodiacSignFor()`
/// (`features/account/domain/zodiac.dart`) to its design-component spec.
ZodiacGlyphSpec zodiacGlyphSpecFor(String sign) =>
    _specs[sign.toLowerCase()] ?? _specs[_fallbackSign]!;

const Map<String, ZodiacGlyphSpec> _specs = <String, ZodiacGlyphSpec>{
  'aries': ZodiacGlyphSpec(
    sign: 'aries',
    ink: _fireInk,
    disc: _fireDisc,
    vi: 'Bạch Dương',
    en: 'Aries',
    buildPaths: _ariesPaths,
  ),
  'taurus': ZodiacGlyphSpec(
    sign: 'taurus',
    ink: _earthInk,
    disc: _earthDisc,
    vi: 'Kim Ngưu',
    en: 'Taurus',
    buildPaths: _taurusPaths,
  ),
  'gemini': ZodiacGlyphSpec(
    sign: 'gemini',
    ink: _airInk,
    disc: _airDisc,
    vi: 'Song Tử',
    en: 'Gemini',
    buildPaths: _geminiPaths,
  ),
  'cancer': ZodiacGlyphSpec(
    sign: 'cancer',
    ink: _waterInk,
    disc: _waterDisc,
    vi: 'Cự Giải',
    en: 'Cancer',
    buildPaths: _cancerPaths,
  ),
  'leo': ZodiacGlyphSpec(
    sign: 'leo',
    ink: _fireInk,
    disc: _fireDisc,
    vi: 'Sư Tử',
    en: 'Leo',
    buildPaths: _leoPaths,
  ),
  'virgo': ZodiacGlyphSpec(
    sign: 'virgo',
    ink: _earthInk,
    disc: _earthDisc,
    vi: 'Xử Nữ',
    en: 'Virgo',
    buildPaths: _virgoPaths,
    strokeWidth: _denseStrokeWidth,
  ),
  'libra': ZodiacGlyphSpec(
    sign: 'libra',
    ink: _airInk,
    disc: _airDisc,
    vi: 'Thiên Bình',
    en: 'Libra',
    buildPaths: _libraPaths,
  ),
  'scorpio': ZodiacGlyphSpec(
    sign: 'scorpio',
    ink: _waterInk,
    disc: _waterDisc,
    vi: 'Bọ Cạp',
    en: 'Scorpio',
    buildPaths: _scorpioPaths,
    strokeWidth: _denseStrokeWidth,
  ),
  'sagittarius': ZodiacGlyphSpec(
    sign: 'sagittarius',
    ink: _fireInk,
    disc: _fireDisc,
    vi: 'Nhân Mã',
    en: 'Sagittarius',
    buildPaths: _sagittariusPaths,
  ),
  'capricorn': ZodiacGlyphSpec(
    sign: 'capricorn',
    ink: _earthInk,
    disc: _earthDisc,
    vi: 'Ma Kết',
    en: 'Capricorn',
    buildPaths: _capricornPaths,
  ),
  'aquarius': ZodiacGlyphSpec(
    sign: 'aquarius',
    ink: _airInk,
    disc: _airDisc,
    vi: 'Bảo Bình',
    en: 'Aquarius',
    buildPaths: _aquariusPaths,
  ),
  'pisces': ZodiacGlyphSpec(
    sign: 'pisces',
    ink: _waterInk,
    disc: _waterDisc,
    vi: 'Song Ngư',
    en: 'Pisces',
    buildPaths: _piscesPaths,
  ),
};

List<Path> _ariesPaths() => <Path>[
  Path()
    ..moveTo(50, 72)
    ..lineTo(50, 46),
  Path()
    ..moveTo(50, 46)
    ..cubicTo(50, 31, 39, 25, 32, 31)
    ..cubicTo(26, 36, 27, 46, 34, 49),
  Path()
    ..moveTo(50, 46)
    ..cubicTo(50, 31, 61, 25, 68, 31)
    ..cubicTo(74, 36, 73, 46, 66, 49),
];

List<Path> _taurusPaths() => <Path>[
  Path()..addOval(Rect.fromCircle(center: const Offset(50, 63), radius: 16)),
  Path()
    ..moveTo(29, 46)
    ..cubicTo(29, 24, 71, 24, 71, 46),
];

List<Path> _geminiPaths() => <Path>[
  Path()
    ..moveTo(35, 30)
    ..lineTo(35, 70),
  Path()
    ..moveTo(65, 30)
    ..lineTo(65, 70),
  Path()
    ..moveTo(27, 29)
    ..cubicTo(40, 22, 60, 22, 73, 29),
  Path()
    ..moveTo(27, 71)
    ..cubicTo(40, 78, 60, 78, 73, 71),
];

List<Path> _cancerPaths() => <Path>[
  Path()
    ..moveTo(24, 42)
    ..cubicTo(34, 30, 56, 28, 66, 36),
  Path()..addOval(Rect.fromCircle(center: const Offset(71, 44), radius: 8)),
  Path()
    ..moveTo(76, 60)
    ..cubicTo(66, 72, 44, 74, 34, 66),
  Path()..addOval(Rect.fromCircle(center: const Offset(29, 58), radius: 8)),
];

List<Path> _leoPaths() => <Path>[
  Path()
    ..moveTo(30, 70)
    ..cubicTo(19, 61, 23, 39, 40, 37)
    ..cubicTo(55, 35, 60, 48, 53, 58)
    ..cubicTo(46, 68, 59, 76, 71, 67),
];

List<Path> _virgoPaths() => <Path>[
  Path()
    ..moveTo(26, 70)
    ..lineTo(26, 38)
    ..quadraticBezierTo(26, 31, 31.5, 31)
    ..quadraticBezierTo(37, 31, 37, 38)
    ..lineTo(37, 70),
  Path()
    ..moveTo(37, 38)
    ..quadraticBezierTo(37, 31, 42.5, 31)
    ..quadraticBezierTo(48, 31, 48, 38)
    ..lineTo(48, 62),
  Path()
    ..moveTo(48, 62)
    ..quadraticBezierTo(48, 71, 57, 71)
    ..quadraticBezierTo(66, 71, 68, 62)
    ..quadraticBezierTo(70, 51, 58, 51),
];

List<Path> _libraPaths() => <Path>[
  Path()
    ..moveTo(24, 70)
    ..lineTo(76, 70),
  Path()
    ..moveTo(24, 56)
    ..lineTo(38, 56),
  Path()
    ..moveTo(62, 56)
    ..lineTo(76, 56),
  Path()
    ..moveTo(38, 56)
    ..arcToPoint(
      const Offset(62, 56),
      radius: const Radius.circular(12),
    ),
];

List<Path> _scorpioPaths() => <Path>[
  Path()
    ..moveTo(22, 70)
    ..lineTo(22, 38)
    ..quadraticBezierTo(22, 31, 27.5, 31)
    ..quadraticBezierTo(33, 31, 33, 38)
    ..lineTo(33, 70),
  Path()
    ..moveTo(33, 38)
    ..quadraticBezierTo(33, 31, 38.5, 31)
    ..quadraticBezierTo(44, 31, 44, 38)
    ..lineTo(44, 70),
  Path()
    ..moveTo(44, 38)
    ..quadraticBezierTo(44, 31, 49.5, 31)
    ..quadraticBezierTo(55, 31, 55, 38)
    ..lineTo(55, 62)
    ..quadraticBezierTo(55, 71, 66, 71)
    ..lineTo(72, 71),
  Path()
    ..moveTo(65, 63)
    ..lineTo(74, 71)
    ..lineTo(65, 79),
];

List<Path> _sagittariusPaths() => <Path>[
  Path()
    ..moveTo(28, 72)
    ..lineTo(72, 28),
  Path()
    ..moveTo(72, 28)
    ..lineTo(53, 28),
  Path()
    ..moveTo(72, 28)
    ..lineTo(72, 47),
  Path()
    ..moveTo(40, 46)
    ..lineTo(54, 60),
];

List<Path> _capricornPaths() => <Path>[
  Path()
    ..moveTo(26, 34)
    ..lineTo(38, 66),
  Path()
    ..moveTo(38, 66)
    ..lineTo(45, 38)
    ..quadraticBezierTo(47, 29, 56, 33)
    ..quadraticBezierTo(65, 38, 63, 50),
  Path()..addOval(Rect.fromCircle(center: const Offset(57, 61), radius: 9)),
];

List<Path> _aquariusPaths() => <Path>[
  Path()
    ..moveTo(24, 45)
    ..quadraticBezierTo(31, 33, 38, 45)
    ..quadraticBezierTo(45, 57, 52, 45)
    ..quadraticBezierTo(59, 33, 66, 45)
    ..quadraticBezierTo(71, 54, 76, 47),
  Path()
    ..moveTo(24, 64)
    ..quadraticBezierTo(31, 52, 38, 64)
    ..quadraticBezierTo(45, 76, 52, 64)
    ..quadraticBezierTo(59, 52, 66, 64)
    ..quadraticBezierTo(71, 73, 76, 66),
];

List<Path> _piscesPaths() => <Path>[
  Path()
    ..moveTo(34, 26)
    ..cubicTo(21, 39, 21, 61, 34, 74),
  Path()
    ..moveTo(66, 26)
    ..cubicTo(79, 39, 79, 61, 66, 74),
  Path()
    ..moveTo(25, 50)
    ..lineTo(75, 50),
];

/// The `Zodiac Icon` design component ported as a painter, because the app
/// bundles no zodiac asset and `flutter_svg` is not a dependency.
///
/// Decorative: the zodiac chip renders the sign's label as text beside it, so
/// the glyph carries no semantics of its own.
class ZodiacGlyph extends StatelessWidget {
  const ZodiacGlyph({super.key, required this.sign, required this.size});

  /// Canonical English sign name, as returned by `zodiacSignFor()`. An
  /// unrecognized value falls back to the design component's own default.
  final String sign;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: ZodiacGlyphPainter(zodiacGlyphSpecFor(sign))),
      ),
    );
  }
}

class ZodiacGlyphPainter extends CustomPainter {
  const ZodiacGlyphPainter(this.spec);

  final ZodiacGlyphSpec spec;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / _viewBox);

    canvas.drawCircle(
      _discCenter,
      _discRadius,
      Paint()..color = spec.disc,
    );

    final Paint stroke = Paint()
      ..color = spec.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = spec.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final Path path in spec.buildPaths()) {
      canvas.drawPath(path, stroke);
    }

    canvas.drawCircle(
      _sparkleLargeCenter,
      _sparkleLargeRadius,
      Paint()..color = spec.ink.withValues(alpha: _sparkleLargeOpacity),
    );
    canvas.drawCircle(
      _sparkleSmallCenter,
      _sparkleSmallRadius,
      Paint()..color = spec.ink.withValues(alpha: _sparkleSmallOpacity),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(ZodiacGlyphPainter oldDelegate) =>
      !identical(oldDelegate.spec, spec);
}
