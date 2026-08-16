import 'package:flutter/material.dart';

/// Home dashboard couple-presence avatar fills, transcribed from the locked
/// design source (`cupid-app-design-system/project/Cupid Screens.dc.html`,
/// `isHome` block: `linear-gradient(135deg,#FFB1D3,#C79BF0)` and
/// `linear-gradient(135deg,#A8F0DF,#C79BF0)`, initial glyph `#fff`).
///
/// Neither `CupidColorTokens.gradientDream` nor `.gradientHot` carries these
/// stops, and no token exposes a pure-white on-accent foreground. The values
/// cannot live in `lib/features/home/presentation/home_screen.dart` without
/// tripping `test/design_system/no_fork_guard_test.dart` (D3/ADR-004 forbids a
/// raw color literal in `lib/features`), so — mirroring the
/// `pet_hero_gradient.dart` / `bun_sprite_palette.dart` precedent — they are
/// declared here as additive, non-shared design-system tokens consumed only by
/// `HomeScreen`'s presence header. No existing shared token is modified.
abstract final class CouplePresencePalette {
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

  static const LinearGradient selfAvatarGradient = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFFFFB1D3), Color(0xFFC79BF0)],
  );

  static const LinearGradient partnerAvatarGradient = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFFA8F0DF), Color(0xFFC79BF0)],
  );

  /// Avatar initial glyph color; `#fff` in both themes in the design source.
  static const Color avatarInitial = Color(0xFFFFFFFF);
}
