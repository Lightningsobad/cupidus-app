import 'package:flutter/material.dart';

/// Splash-screen-only design values transcribed from the locked design
/// source (`cupid-app-design-system/project/Cupid Screens.dc.html`, the
/// `isSplash` block).
///
/// Splash paints its own fixed gradient rather than the themed app surface,
/// so these values intentionally do not vary with theme: the design source
/// declares one gradient and pure-white foregrounds for both themes. Neither
/// `CupidColorTokens.gradientDream` nor `.gradientHot` matches this stop set,
/// and a raw color literal cannot live in `lib/features` without tripping
/// `test/design_system/no_fork_guard_test.dart` (D3/ADR-004), so — mirroring
/// the `PetHeroGradient` precedent — they are declared here as additive,
/// non-shared design-system values consumed only by `SplashScreen`.
abstract final class SplashPalette {
  /// `linear-gradient(168deg, #7B4FBE, #C2508F 55%, #4E8A87)`. CSS 0deg
  /// points "to top" and rotates clockwise, so the axis vector is
  /// `(sin(168deg), cos(168deg))` pointing from `begin` to `end`.
  static const LinearGradient background = LinearGradient(
    begin: Alignment(-0.20791169081775931, -0.9781476007338057),
    end: Alignment(0.20791169081775931, 0.9781476007338057),
    colors: <Color>[Color(0xFF7B4FBE), Color(0xFFC2508F), Color(0xFF4E8A87)],
    stops: <double>[0.0, 0.55, 1.0],
  );

  /// `radial-gradient(circle, rgba(255,255,255,.28), transparent 70%)` for
  /// the breathing glow orb.
  static const RadialGradient glow = RadialGradient(
    colors: <Color>[
      Color.fromRGBO(255, 255, 255, 0.28),
      Color.fromRGBO(255, 255, 255, 0.0),
    ],
    stops: <double>[0.0, 0.7],
  );

  /// Wordmark and tap-affordance label color (`#fff`).
  static const Color foreground = Color(0xFFFFFFFF);

  /// Loading-dot color (`rgba(255,255,255,.9)`).
  static const Color dot = Color.fromRGBO(255, 255, 255, 0.9);

  /// Caption color (`rgba(255,255,255,.6)`).
  static const Color caption = Color.fromRGBO(255, 255, 255, 0.6);

  /// Tap-affordance pill fill (`rgba(255,255,255,.16)`).
  static const Color pillFill = Color.fromRGBO(255, 255, 255, 0.16);

  /// Tap-affordance pill border (`rgba(255,255,255,.24)`).
  static const Color pillBorder = Color.fromRGBO(255, 255, 255, 0.24);
}
