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
