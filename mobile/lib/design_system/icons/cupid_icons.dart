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
}
