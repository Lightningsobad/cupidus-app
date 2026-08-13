import 'package:flutter/material.dart';

/// The two overlapping couple-avatar fills on the `paired` celebration screen
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isPaired` block:
/// `linear-gradient(135deg,#FFB1D3,#C79BF0)` and
/// `linear-gradient(135deg,#A8F0DF,#C79BF0)`). No `CupidColorTokens` gradient
/// carries these stops, and they do not vary by theme, so — mirroring the
/// `pet_hero_gradient.dart` precedent — they are declared here rather than
/// inline in `lib/features`, where `test/design_system/no_fork_guard_test.dart`
/// (D3/ADR-004) forbids a raw color literal.
///
/// `linear-gradient(135deg, ...)` points down-right: `sin(135deg)` /
/// `-cos(135deg)` give the begin/end alignment vectors.
abstract final class CoupleAvatarGradients {
  static const Alignment _begin = Alignment(-0.7071067811865476, -0.7071067811865476);
  static const Alignment _end = Alignment(0.7071067811865476, 0.7071067811865476);

  /// Leading (self) avatar: pink to purple.
  static const LinearGradient self = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFFFFB1D3), Color(0xFFC79BF0)],
  );

  /// Trailing (partner) avatar: mint to purple.
  static const LinearGradient partner = LinearGradient(
    begin: _begin,
    end: _end,
    colors: <Color>[Color(0xFFA8F0DF), Color(0xFFC79BF0)],
  );
}
