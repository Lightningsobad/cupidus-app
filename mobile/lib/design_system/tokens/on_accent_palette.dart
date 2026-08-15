import 'package:flutter/material.dart';

/// Pure-white foreground the locked design source paints on top of the hot
/// gradient (`#fff` in both themes: toggle knobs and glyphs layered over
/// `CupidColorTokens.gradientHot`).
///
/// No shared token exposes an on-accent foreground — `colorSurface` is white
/// only in the light theme — and a raw color literal cannot live in
/// `lib/features` without tripping `test/design_system/no_fork_guard_test.dart`
/// (D3/ADR-004). Mirroring the `SplashPalette` / `CouplePresencePalette`
/// precedent, it is declared here as an additive design-system value. No
/// existing shared token is modified.
abstract final class OnAccentPalette {
  /// Foreground/knob color layered over `CupidColorTokens.gradientHot`
  /// (`#fff`).
  static const Color foreground = Color(0xFFFFFFFF);
}
