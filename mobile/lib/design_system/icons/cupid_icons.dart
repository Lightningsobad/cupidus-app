import 'package:flutter/widgets.dart';

/// Material Symbols Rounded is the single icon family for both platforms
/// (`ux/uiux-spec.md` section 2, ADR-004d): no second icon package, no
/// platform-specific icon set.
///
/// Named constants below are added on demand as `design_system/adaptive/`
/// widgets consume specific glyphs, keeping Flutter's icon tree-shaking
/// effective per glyph. Codepoints are read from the bundled
/// `MaterialSymbolsRounded-Variable.ttf` cmap (via `fontTools`), never
/// invented from memory of a different icon font's PUA range.
abstract final class CupidIcons {
  /// The bundled variable font family declared in `pubspec.yaml`.
  static const String fontFamily = 'Material Symbols Rounded';

  /// `chevron_left` glyph, confirmed in the bundled font's cmap at 0xe5cb
  /// (0xe408 aliases to the identical glyph in this font).
  static const IconData chevronLeft = IconData(0xe5cb, fontFamily: fontFamily);

  /// `arrow_back` glyph, confirmed in the bundled font's cmap at 0xe5c4.
  static const IconData arrowBack = IconData(0xe5c4, fontFamily: fontFamily);

  /// `add` glyph, confirmed in the bundled font's cmap at 0xe145.
  static const IconData add = IconData(0xe145, fontFamily: fontFamily);

  /// `chevron_right` glyph, confirmed in the bundled font's cmap at 0xe5cc
  /// (0xe409 aliases to the identical glyph in this font), used by
  /// `VibeEntryCard` as the entry-point discoverability affordance
  /// (`architecture/solution.md` §4 D-010-5).
  static const IconData chevronRight = IconData(0xe5cc, fontFamily: fontFamily);

  /// `savings` glyph, confirmed in the bundled font's cmap at 0xe2eb.
  static const IconData savings = IconData(0xe2eb, fontFamily: fontFamily);

  /// `notifications_active` glyph, confirmed in the bundled font's cmap at
  /// 0xe7f7 (STORY-009: the alarm-clock glyph replacement per
  /// `ux/uiux-spec.md` §3/§4 — never render an `alarm` glyph for this
  /// feature).
  static const IconData notificationsActive = IconData(
    0xe7f7,
    fontFamily: fontFamily,
  );

  /// `remove` glyph, confirmed in the bundled font's cmap at 0xe15b
  /// (STORY-009: the schedule screen's "decrease time" stepper).
  static const IconData remove = IconData(0xe15b, fontFamily: fontFamily);

  /// `hourglass` glyph, confirmed in the bundled font's cmap at 0xebff
  /// (STORY-009: the "waiting on partner" schedule-screen state).
  static const IconData hourglass = IconData(0xebff, fontFamily: fontFamily);

  /// `swipe_right` glyph, confirmed in the bundled font's cmap at 0xeb52
  /// (STORY-009: the accessible label carrier for the firing overlay's
  /// swipe-to-dismiss affordance).
  static const IconData swipeRight = IconData(0xeb52, fontFamily: fontFamily);

  /// `check` glyph, confirmed in the bundled font's cmap at 0xe5ca (0xe668
  /// aliases to the identical glyph in this font, matching the
  /// [chevronLeft]/0xe408 aliasing precedent above).
  static const IconData check = IconData(0xe5ca, fontFamily: fontFamily);

  /// `cyclone` glyph, confirmed in the bundled font's cmap at 0xebd5
  /// (STORY-008 "Emoji Storm" penalty option, `ux/uiux-spec.md` §2.3).
  static const IconData cyclone = IconData(0xebd5, fontFamily: fontFamily);

  /// `volume_up` glyph, confirmed in the bundled font's cmap at 0xe050
  /// (STORY-008 "Noise" penalty option, `ux/uiux-spec.md` §2.3).
  static const IconData volumeUp = IconData(0xe050, fontFamily: fontFamily);

  /// `notifications_off` glyph, confirmed in the bundled font's cmap at
  /// 0xe7f6 (STORY-008 "None" penalty option — a muted/neutral icon per
  /// `ux/uiux-spec.md` §2.3; chosen over `block`/`do_not_disturb`, which
  /// alias ambiguous multi-codepoint entries in this font's cmap).
  static const IconData notificationsOff = IconData(
    0xe7f6,
    fontFamily: fontFamily,
  );

  /// `timer` glyph, confirmed in the bundled font's cmap at 0xe425
  /// (STORY-008 ghost-timeout section, `ux/uiux-spec.md` §2.3).
  static const IconData timer = IconData(0xe425, fontFamily: fontFamily);

  /// `sentiment_dissatisfied` glyph, confirmed in the bundled font's cmap at
  /// 0xe811 (single codepoint, no alias; `sentiment_neutral`/0xe812 and
  /// `sentiment_very_dissatisfied`/0xe814 are distinct glyphs — do not
  /// substitute either). The anti-ghost alert banner's leading tile glyph in
  /// the locked design source.
  static const IconData sentimentDissatisfied = IconData(
    0xe811,
    fontFamily: fontFamily,
  );

  /// `restaurant` glyph, confirmed in the bundled font's cmap at 0xe56c.
  static const IconData restaurant = IconData(0xe56c, fontFamily: fontFamily);

  /// `sports_esports` glyph, confirmed in the bundled font's cmap at 0xea28
  /// (0xe6ec aliases to the identical glyph in this font).
  static const IconData sportsEsports = IconData(
    0xea28,
    fontFamily: fontFamily,
  );

  /// `lock` glyph, confirmed in the bundled font's cmap at 0xe897 (0xe88d and
  /// 0xe899 alias to the identical glyph in this font).
  static const IconData lock = IconData(0xe897, fontFamily: fontFamily);

  /// `lock_reset` glyph, confirmed in the bundled font's cmap at 0xeade
  /// (single codepoint, no alias; a distinct outline from [lock]). The
  /// `forgot` hero badge glyph in the locked design source.
  static const IconData lockReset = IconData(0xeade, fontFamily: fontFamily);

  /// `shield_moon` glyph, confirmed in the bundled font's cmap at 0xeaa9
  /// (single codepoint, no alias; a distinct outline from [lock]). The
  /// `forgot` privacy-note glyph in the locked design source.
  static const IconData shieldMoon = IconData(0xeaa9, fontFamily: fontFamily);

  /// `pets` glyph, confirmed in the bundled font's cmap at 0xe91d.
  static const IconData pets = IconData(0xe91d, fontFamily: fontFamily);

  /// `celebration` glyph, confirmed in the bundled font's cmap at 0xea65.
  static const IconData celebration = IconData(0xea65, fontFamily: fontFamily);

  /// `link` glyph, confirmed in the bundled font's cmap at 0xe157 (0xe250
  /// aliases to the identical glyph in this font, matching the
  /// [chevronLeft]/0xe408 aliasing precedent above). STORY-012: the
  /// `joincode` hero badge glyph.
  static const IconData link = IconData(0xe157, fontFamily: fontFamily);

  /// `ios_share` glyph, confirmed in the bundled font's cmap at 0xe6b8
  /// (STORY-013: the share affordance the design source hard-codes on the
  /// `waiting` screen's "Gửi lại" CTA — not the platform-branched
  /// `share`/0xe80d used by the share-sheet flows).
  static const IconData iosShare = IconData(0xe6b8, fontFamily: fontFamily);

  /// `share` glyph, confirmed in the bundled font's cmap at 0xe80d (single
  /// codepoint). The non-iOS half of the design source's
  /// `shareIcon: isIOS ? 'ios_share' : 'share'` branch.
  static const IconData share = IconData(0xe80d, fontFamily: fontFamily);

  /// `edit` glyph, confirmed in the bundled font's cmap at 0xe3c9 (the pencil
  /// outline; 0xe150/0xe254/0xf035/0xf097 alias other edit-family glyphs).
  static const IconData edit = IconData(0xe3c9, fontFamily: fontFamily);

  /// `notifications` glyph, confirmed in the bundled font's cmap at 0xe7f4
  /// (0xe7f5 aliases to the identical glyph in this font).
  static const IconData notifications = IconData(
    0xe7f4,
    fontFamily: fontFamily,
  );

  /// `palette` glyph, confirmed in the bundled font's cmap at 0xe40a (0xe3b7
  /// aliases to the identical glyph in this font).
  static const IconData palette = IconData(0xe40a, fontFamily: fontFamily);

  /// `blur_on` glyph, confirmed in the bundled font's cmap at 0xe3a5 (single
  /// codepoint). The Typing Ghost badge glyph in the locked design source.
  static const IconData blurOn = IconData(0xe3a5, fontFamily: fontFamily);

  /// `draw` glyph, confirmed in the bundled font's cmap at 0xe746 (single
  /// codepoint). The Love Contract badge glyph in the locked design source.
  static const IconData draw = IconData(0xe746, fontFamily: fontFamily);

  /// `translate` glyph, confirmed in the bundled font's cmap at 0xe8e2
  /// (single codepoint).
  static const IconData translate = IconData(0xe8e2, fontFamily: fontFamily);

  /// `heart_broken` glyph, confirmed in the bundled font's cmap at 0xeac2
  /// (single codepoint). The Digital Divorce card glyph.
  static const IconData heartBroken = IconData(0xeac2, fontFamily: fontFamily);

  /// `schedule` glyph, confirmed in the bundled font's cmap at 0xe8b5 (the
  /// clock face; 0xe192/0xe8ae/0xe924/0xefd6 alias other timing glyphs).
  static const IconData schedule = IconData(0xe8b5, fontFamily: fontFamily);

  /// `person` glyph, confirmed in the bundled font's cmap at 0xe7fd
  /// (0xe7ff/0xe8a6/0xf0d3 alias other person-family glyphs). The avatar
  /// placeholder when a profile has no photo.
  static const IconData person = IconData(0xe7fd, fontFamily: fontFamily);

  /// `fingerprint` glyph, confirmed in the bundled font's cmap at 0xe90d
  /// (single codepoint, no alias). The Fingerprint Vow hold target.
  static const IconData fingerprint = IconData(0xe90d, fontFamily: fontFamily);

  /// `check_circle` glyph, confirmed in the bundled font's cmap at 0xe86c
  /// (0xe92d and 0xf0be alias to the identical glyph outline in this font,
  /// matching the [chevronLeft]/0xe408 aliasing precedent above). The
  /// Fingerprint Vow signed-confirmation disc.
  static const IconData checkCircle = IconData(0xe86c, fontFamily: fontFamily);

  /// `flight_takeoff` glyph, confirmed in the bundled font's cmap at 0xe905
  /// (0xe539 is plain `flight`, a different glyph — do not substitute it).
  /// STORY-027: the `jar` selector-chip glyph in the locked design source.
  static const IconData flightTakeoff = IconData(
    0xe905,
    fontFamily: fontFamily,
  );

  /// `expand_more` glyph, confirmed in the bundled font's cmap at 0xe5cf
  /// (STORY-027: the `jar` selector chip's disclosure affordance).
  static const IconData expandMore = IconData(0xe5cf, fontFamily: fontFamily);

  /// `favorite` glyph, confirmed in the bundled font's cmap at 0xe87d
  /// (STORY-027: the `jar` hero's "remaining" pill glyph).
  static const IconData favorite = IconData(0xe87d, fontFamily: fontFamily);

  /// `volunteer_activism` glyph, confirmed in the bundled font's cmap at
  /// 0xea70 (STORY-027: the emphasized third quick-add preset tile).
  static const IconData volunteerActivism = IconData(
    0xea70,
    fontFamily: fontFamily,
  );

  /// `visibility_off` glyph, confirmed in the bundled font's cmap at 0xe8f5
  /// (single codepoint, no alias). The obscured half of the `login` password
  /// field's show/hide toggle in the locked design source (line 1441).
  static const IconData visibilityOff = IconData(
    0xe8f5,
    fontFamily: fontFamily,
  );

  /// `visibility` glyph, confirmed in the bundled font's cmap at 0xe8f4
  /// (0xe417 aliases to the identical glyph in this font, matching the
  /// [chevronLeft]/0xe408 aliasing precedent above). The revealed half of the
  /// password show/hide toggle.
  static const IconData visibility = IconData(0xe8f4, fontFamily: fontFamily);
}

/// Third-party sign-in brand marks.
///
/// These are deliberately *not* [CupidIcons] entries: Material Symbols
/// Rounded carries no brand logos (the bundled font's cmap has no `facebook`
/// or Google mark), and the Google mark is four-color, which a single-color
/// icon font cannot express. The locked design source draws Google as an
/// inline four-path SVG and Facebook as an 18px `#1877F2` mark
/// (`Cupid Screens.dc.html` lines 1449 and 1454), so both are carried here as
/// vector path data at their original viewBox coordinates.
enum CupidBrandMark {
  /// Google "G", from the design source's 48x48 inline SVG.
  google,

  /// Facebook "f", the Material `facebook` outline in the brand blue.
  facebook,
}

/// Renders a [CupidBrandMark] at [size] logical pixels square.
///
/// Brand colors are fixed by the trademark owners, so they do not follow
/// `CupidColorTokens` and do not vary with platform or theme.
class CupidBrandMarkIcon extends StatelessWidget {
  const CupidBrandMarkIcon(this.mark, {super.key, required this.size});

  final CupidBrandMark mark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _BrandMarkPainter(mark)),
    );
  }
}

@immutable
class _BrandLayer {
  const _BrandLayer(this.color, this.path);

  final Color color;
  final Path path;
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter(this.mark);

  final CupidBrandMark mark;

  @override
  void paint(Canvas canvas, Size size) {
    final double viewBox = mark == CupidBrandMark.google ? 48 : 24;
    final List<_BrandLayer> layers = mark == CupidBrandMark.google
        ? _googleLayers
        : _facebookLayers;

    canvas.save();
    canvas.scale(size.width / viewBox, size.height / viewBox);
    for (final _BrandLayer layer in layers) {
      canvas.drawPath(layer.path, Paint()..color = layer.color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) => oldDelegate.mark != mark;
}

/// The design source's four Google-mark paths, transcribed verbatim from the
/// inline `viewBox="0 0 48 48"` SVG at `Cupid Screens.dc.html` line 1449.
final List<_BrandLayer> _googleLayers = <_BrandLayer>[
  _BrandLayer(
    const Color(0xFF4285F4),
    Path()
      ..moveTo(45.1, 24.5)
      ..cubicTo(45.1, 22.9, 45, 21.3, 44.7, 19.8)
      ..lineTo(24, 19.8)
      ..lineTo(24, 28.7)
      ..lineTo(35.8, 28.7)
      ..cubicTo(35.3, 31.4, 33.7, 33.8, 31.4, 35.3)
      ..lineTo(31.4, 40.8)
      ..lineTo(38.5, 40.8)
      ..cubicTo(42.7, 37, 45.1, 31.3, 45.1, 24.5)
      ..close(),
  ),
  _BrandLayer(
    const Color(0xFF34A853),
    Path()
      ..moveTo(24, 46)
      ..cubicTo(30, 46, 35, 44, 38.6, 40.7)
      ..lineTo(31.5, 35.2)
      ..cubicTo(29.5, 36.5, 27, 37.3, 24, 37.3)
      ..cubicTo(18.2, 37.3, 13.3, 33.4, 11.6, 28.2)
      ..lineTo(4.3, 28.2)
      ..lineTo(4.3, 33.9)
      ..cubicTo(7.9, 41.1, 15.4, 46, 24, 46)
      ..close(),
  ),
  _BrandLayer(
    const Color(0xFFFBBC05),
    Path()
      ..moveTo(11.6, 28.2)
      ..cubicTo(11.2, 26.9, 10.9, 25.5, 10.9, 24)
      ..cubicTo(10.9, 22.5, 11.2, 21.1, 11.6, 19.8)
      ..lineTo(11.6, 14.1)
      ..lineTo(4.3, 14.1)
      ..cubicTo(2.8, 17.1, 2, 20.4, 2, 24)
      ..cubicTo(2, 27.6, 2.8, 30.9, 4.3, 33.9)
      ..lineTo(11.6, 28.2)
      ..close(),
  ),
  _BrandLayer(
    const Color(0xFFEA4335),
    Path()
      ..moveTo(24, 10.7)
      ..cubicTo(27.3, 10.7, 30.2, 11.8, 32.5, 14)
      ..lineTo(38.8, 7.7)
      ..cubicTo(35, 4.1, 30, 2, 24, 2)
      ..cubicTo(15.4, 2, 7.9, 6.9, 4.3, 14.1)
      ..lineTo(11.6, 19.8)
      ..cubicTo(13.3, 14.6, 18.2, 10.7, 24, 10.7)
      ..close(),
  ),
];

/// The Material `facebook` outline on a 24x24 viewBox — a filled disc with
/// the "f" carved out — in the design source's `#1877F2`
/// (`Cupid Screens.dc.html` line 1454).
final List<_BrandLayer> _facebookLayers = <_BrandLayer>[
  _BrandLayer(
    const Color(0xFF1877F2),
    Path()
      ..moveTo(22, 12)
      ..cubicTo(22, 6.48, 17.52, 2, 12, 2)
      ..cubicTo(6.48, 2, 2, 6.48, 2, 12)
      ..cubicTo(2, 16.84, 5.44, 20.87, 10, 21.8)
      ..lineTo(10, 15)
      ..lineTo(8, 15)
      ..lineTo(8, 12)
      ..lineTo(10, 12)
      ..lineTo(10, 9.5)
      ..cubicTo(10, 7.57, 11.57, 6, 13.5, 6)
      ..lineTo(16, 6)
      ..lineTo(16, 9)
      ..lineTo(14, 9)
      ..cubicTo(13.45, 9, 13, 9.45, 13, 10)
      ..lineTo(13, 12)
      ..lineTo(16, 12)
      ..lineTo(16, 15)
      ..lineTo(13, 15)
      ..lineTo(13, 21.95)
      ..cubicTo(18.05, 21.45, 22, 17.19, 22, 12)
      ..close(),
  ),
];
