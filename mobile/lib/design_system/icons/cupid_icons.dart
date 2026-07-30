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

  /// `pets` glyph, confirmed in the bundled font's cmap at 0xe91d.
  static const IconData pets = IconData(0xe91d, fontFamily: fontFamily);

  /// `celebration` glyph, confirmed in the bundled font's cmap at 0xea65.
  static const IconData celebration = IconData(0xea65, fontFamily: fontFamily);
}
