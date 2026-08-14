import 'package:flutter/material.dart';

/// Fingerprint Vow screen fills, transcribed from the locked design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isVow` block).
///
/// None of these values exist in `CupidColorTokens`: the screen wash reuses the
/// deep purple the design only otherwise spends inside the `--sky` decoration
/// string, the two vow avatars use hotter stops than the `paired`/`isHome`
/// couple avatars, and the "Vào Dashboard" CTA ink has no token. They cannot
/// live in `lib/features` without tripping
/// `test/design_system/no_fork_guard_test.dart` (D3/ADR-004 forbids a raw color
/// literal there), so — mirroring the `couple_presence_palette.dart` /
/// `pet_hero_gradient.dart` precedent — they are declared here as additive
/// tokens consumed only by `VowScreen`. No existing shared token is modified.
abstract final class VowPalette {
  /// CSS `135deg` under the same vector convention `cupid_color_tokens.dart`
  /// derives for its `120deg` gradients: `sin(135deg) = 0.7071067811865476`,
  /// `cos(135deg) = -0.7071067811865476`.
  static const Alignment _begin = Alignment(
    -0.7071067811865476,
    -0.7071067811865476,
  );
  static const Alignment _end = Alignment(
    0.7071067811865476,
    0.7071067811865476,
  );

  /// `radial-gradient(circle at 50% 30%, rgba(123,47,190,.5), transparent 62%)`
  /// on the screen shell. Carried at full alpha; the use site applies the
  /// design's `.5` and the transparent end stop.
  static const Color heroWash = Color(0xFF7B2FBE);

  /// `linear-gradient(135deg,#FF4B8C,#7B2FBE)`.
  static const LinearGradient selfAvatarGradient = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFFFF4B8C), heroWash],
  );

  /// `linear-gradient(135deg,#00C9A7,#7B2FBE)`.
  static const LinearGradient partnerAvatarGradient = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFF00C9A7), heroWash],
  );

  /// Avatar initial glyph color; `#fff` in the design source.
  static const Color avatarInitial = Color(0xFFFFFFFF);

  /// "Vào Dashboard" CTA label ink (`color:#04231E` on a `--green` fill).
  static const Color dashboardCtaInk = Color(0xFF04231E);
}
