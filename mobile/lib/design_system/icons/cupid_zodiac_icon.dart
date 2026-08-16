import 'package:flutter/widgets.dart';

/// The twelve signs the locked design source's `Zodiac Icon` component draws,
/// with the vi/en display names it ships in the same `SIGNS` map.
enum CupidZodiacSign {
  aries(_ZodiacElement.fire, 'Bạch Dương', 'Aries'),
  taurus(_ZodiacElement.earth, 'Kim Ngưu', 'Taurus'),
  gemini(_ZodiacElement.air, 'Song Tử', 'Gemini'),
  cancer(_ZodiacElement.water, 'Cự Giải', 'Cancer'),
  leo(_ZodiacElement.fire, 'Sư Tử', 'Leo'),
  virgo(_ZodiacElement.earth, 'Xử Nữ', 'Virgo'),
  libra(_ZodiacElement.air, 'Thiên Bình', 'Libra'),
  scorpio(_ZodiacElement.water, 'Bọ Cạp', 'Scorpio'),
  sagittarius(_ZodiacElement.fire, 'Nhân Mã', 'Sagittarius'),
  capricorn(_ZodiacElement.earth, 'Ma Kết', 'Capricorn'),
  aquarius(_ZodiacElement.air, 'Bảo Bình', 'Aquarius'),
  pisces(_ZodiacElement.water, 'Song Ngư', 'Pisces');

  const CupidZodiacSign(this._element, this.viLabel, this.enLabel);

  final _ZodiacElement _element;
  final String viLabel;
  final String enLabel;

  /// Resolves the canonical English sign name stored on the profile contract
  /// (`CupidProfile.zodiacSign`, `features/account/domain/zodiac.dart`).
  /// Returns `null` for anything the design source has no glyph for.
  static CupidZodiacSign? tryParse(String? name) {
    if (name == null) return null;
    final String needle = name.trim().toLowerCase();
    for (final CupidZodiacSign sign in values) {
      if (sign.name == needle) return sign;
    }
    return null;
  }
}

/// Element palette from the design source's `EL` map. `disc` opacities are
/// verbatim (air is `.18`, the other three are `.16`).
enum _ZodiacElement {
  fire(Color(0xFFFF9576), Color.fromRGBO(255, 149, 118, 0.16)),
  earth(Color(0xFF5FD3BC), Color.fromRGBO(95, 211, 188, 0.16)),
  air(Color(0xFFB78CF5), Color.fromRGBO(183, 140, 245, 0.18)),
  water(Color(0xFFFF7FB6), Color.fromRGBO(255, 127, 182, 0.16));

  const _ZodiacElement(this.ink, this.disc);

  final Color ink;
  final Color disc;
}

/// The design source's `Zodiac Icon` component, ported as a painter because no
/// SVG runtime is bundled. Geometry is transcribed verbatim from
/// `cupid-app-design-system/project/Zodiac Icon.dc.html` in its own
/// `0 0 100 100` viewBox and scaled to [size] at paint time.
class CupidZodiacIcon extends StatelessWidget {
  const CupidZodiacIcon(
    this.sign, {
    required this.size,
    super.key,
    this.color,
    this.flat = false,
  });

  final CupidZodiacSign sign;
  final double size;

  /// Overrides the element ink, matching the component's `color` prop.
  final Color? color;

  /// Drops the tinted backing disc, matching the component's `flat` prop.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ZodiacPainter(
          sign: sign,
          ink: color ?? sign._element.ink,
          disc: flat ? const Color(0x00000000) : sign._element.disc,
        ),
      ),
    );
  }
}

class _ZodiacPainter extends CustomPainter {
  const _ZodiacPainter({
    required this.sign,
    required this.ink,
    required this.disc,
  });

  final CupidZodiacSign sign;
  final Color ink;
  final Color disc;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    canvas.drawCircle(
      const Offset(50, 50),
      48,
      Paint()..color = disc,
    );

    final _ZodiacGlyph glyph = _glyphs[sign]!;
    canvas.drawPath(
      _pathFor(sign),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = glyph.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      const Offset(82, 22),
      2.6,
      Paint()..color = ink.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      const Offset(18, 76),
      1.9,
      Paint()..color = ink.withValues(alpha: 0.4),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ZodiacPainter oldDelegate) =>
      oldDelegate.sign != sign ||
      oldDelegate.ink != ink ||
      oldDelegate.disc != disc;
}

final Map<CupidZodiacSign, Path> _pathCache = <CupidZodiacSign, Path>{};

Path _pathFor(CupidZodiacSign sign) {
  return _pathCache.putIfAbsent(sign, () {
    final _ZodiacGlyph glyph = _glyphs[sign]!;
    final Path path = Path();
    for (final String d in glyph.paths) {
      path.addPath(_parseSvgPath(d), Offset.zero);
    }
    for (final (double cx, double cy, double r) in glyph.circles) {
      path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    }
    return path;
  });
}

final RegExp _svgToken = RegExp(r'[MLCQA]|-?\d*\.?\d+');

/// Minimal absolute-command SVG path reader. The design source's zodiac
/// glyphs only ever use `M`, `L`, `C`, `Q` and `A`, so keeping the `d` strings
/// verbatim is safer than hand-transcribing them into `Path` calls.
Path _parseSvgPath(String d) {
  final List<String> tokens = _svgToken
      .allMatches(d)
      .map((RegExpMatch m) => m.group(0)!)
      .toList();
  final Path path = Path();
  String command = '';
  int i = 0;
  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    final String token = tokens[i];
    if (token.length == 1 && token.codeUnitAt(0) >= 0x41) {
      command = token;
      i++;
    }
    switch (command) {
      case 'M':
        path.moveTo(next(), next());
      case 'L':
        path.lineTo(next(), next());
      case 'C':
        path.cubicTo(next(), next(), next(), next(), next(), next());
      case 'Q':
        path.quadraticBezierTo(next(), next(), next(), next());
      case 'A':
        final double rx = next();
        final double ry = next();
        final double rotation = next();
        final bool largeArc = next() == 1;
        final bool clockwise = next() == 1;
        path.arcToPoint(
          Offset(next(), next()),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: clockwise,
        );
    }
  }
  return path;
}

class _ZodiacGlyph {
  const _ZodiacGlyph({
    required this.paths,
    this.strokeWidth = 6,
    this.circles = const <(double, double, double)>[],
  });

  final List<String> paths;
  final double strokeWidth;
  final List<(double, double, double)> circles;
}

const Map<CupidZodiacSign, _ZodiacGlyph> _glyphs =
    <CupidZodiacSign, _ZodiacGlyph>{
      CupidZodiacSign.aries: _ZodiacGlyph(
        paths: <String>[
          'M50 72 L50 46',
          'M50 46 C50 31 39 25 32 31 C26 36 27 46 34 49',
          'M50 46 C50 31 61 25 68 31 C74 36 73 46 66 49',
        ],
      ),
      CupidZodiacSign.taurus: _ZodiacGlyph(
        paths: <String>['M29 46 C29 24 71 24 71 46'],
        circles: <(double, double, double)>[(50, 63, 16)],
      ),
      CupidZodiacSign.gemini: _ZodiacGlyph(
        paths: <String>[
          'M35 30 L35 70',
          'M65 30 L65 70',
          'M27 29 C40 22 60 22 73 29',
          'M27 71 C40 78 60 78 73 71',
        ],
      ),
      CupidZodiacSign.cancer: _ZodiacGlyph(
        paths: <String>[
          'M24 42 C34 30 56 28 66 36',
          'M76 60 C66 72 44 74 34 66',
        ],
        circles: <(double, double, double)>[(71, 44, 8), (29, 58, 8)],
      ),
      CupidZodiacSign.leo: _ZodiacGlyph(
        paths: <String>[
          'M30 70 C19 61 23 39 40 37 C55 35 60 48 53 58 C46 68 59 76 71 67',
        ],
      ),
      CupidZodiacSign.virgo: _ZodiacGlyph(
        strokeWidth: 5.5,
        paths: <String>[
          'M26 70 L26 38 Q26 31 31.5 31 Q37 31 37 38 L37 70',
          'M37 38 Q37 31 42.5 31 Q48 31 48 38 L48 62',
          'M48 62 Q48 71 57 71 Q66 71 68 62 Q70 51 58 51',
        ],
      ),
      CupidZodiacSign.libra: _ZodiacGlyph(
        paths: <String>[
          'M24 70 L76 70',
          'M24 56 L38 56',
          'M62 56 L76 56',
          'M38 56 A12 12 0 0 1 62 56',
        ],
      ),
      CupidZodiacSign.scorpio: _ZodiacGlyph(
        strokeWidth: 5.5,
        paths: <String>[
          'M22 70 L22 38 Q22 31 27.5 31 Q33 31 33 38 L33 70',
          'M33 38 Q33 31 38.5 31 Q44 31 44 38 L44 70',
          'M44 38 Q44 31 49.5 31 Q55 31 55 38 L55 62 Q55 71 66 71 L72 71',
          'M65 63 L74 71 L65 79',
        ],
      ),
      CupidZodiacSign.sagittarius: _ZodiacGlyph(
        paths: <String>[
          'M28 72 L72 28',
          'M72 28 L53 28',
          'M72 28 L72 47',
          'M40 46 L54 60',
        ],
      ),
      CupidZodiacSign.capricorn: _ZodiacGlyph(
        paths: <String>[
          'M26 34 L38 66',
          'M38 66 L45 38 Q47 29 56 33 Q65 38 63 50',
        ],
        circles: <(double, double, double)>[(57, 61, 9)],
      ),
      CupidZodiacSign.aquarius: _ZodiacGlyph(
        paths: <String>[
          'M24 45 Q31 33 38 45 Q45 57 52 45 Q59 33 66 45 Q71 54 76 47',
          'M24 64 Q31 52 38 64 Q45 76 52 64 Q59 52 66 64 Q71 73 76 66',
        ],
      ),
      CupidZodiacSign.pisces: _ZodiacGlyph(
        paths: <String>[
          'M34 26 C21 39 21 61 34 74',
          'M66 26 C79 39 79 61 66 74',
          'M25 50 L75 50',
        ],
      ),
    };
