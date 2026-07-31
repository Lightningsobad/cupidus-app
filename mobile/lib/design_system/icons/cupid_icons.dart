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
  static const IconData notificationsOff = IconData(0xe7f6, fontFamily: fontFamily);

  /// `timer` glyph, confirmed in the bundled font's cmap at 0xe425
  /// (STORY-008 ghost-timeout section, `ux/uiux-spec.md` §2.3).
  static const IconData timer = IconData(0xe425, fontFamily: fontFamily);
}
