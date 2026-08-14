import 'package:flutter/widgets.dart';

/// Dream Jar screen palette, transcribed from the locked design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, the `jar` screen).
///
/// These colors are screen-specific artwork rather than semantic theme roles,
/// so they live here instead of in [CupidColorTokens] — the same split already
/// used by `pet_hero_gradient.dart` and `bun_sprite_palette.dart`. Declaring
/// them here is what keeps `lib/features` free of raw color literals (D3 /
/// ADR-004, enforced by `test/design_system/no_fork_guard_test.dart`).
abstract final class DreamJarPalette {
  /// `linear-gradient(172deg,#5E4E9E,#8A5E9E 55%,#4E8A87)`. A CSS angle of
  /// `N` runs along `(sin N, -cos N)` in screen coordinates, which for 172°
  /// is very nearly top-to-bottom with a slight rightward lean.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment(-0.13917310096006544, -0.9902680687415704),
    end: Alignment(0.13917310096006544, 0.9902680687415704),
    colors: <Color>[Color(0xFF5E4E9E), Color(0xFF8A5E9E), Color(0xFF4E8A87)],
    stops: <double>[0.0, 0.55, 1.0],
  );

  /// The hero's decorative `radial-gradient(circle,rgba(255,255,255,.26),
  /// transparent 70%)` bloom.
  static const RadialGradient heroBloom = RadialGradient(
    colors: <Color>[Color(0x42FFFFFF), Color(0x00FFFFFF)],
    stops: <double>[0.0, 0.7],
  );

  /// `text-shadow:0 3px 14px rgba(40,20,70,.3)` on the hero amount.
  static const Shadow heroAmountShadow = Shadow(
    color: Color(0x4D281446),
    offset: Offset(0, 3),
    blurRadius: 14,
  );

  /// Fills and strokes layered over [heroGradient]. All are white at the
  /// opacities the design source specifies.
  static const Color onHeroChipFill = Color(0x2EFFFFFF); // rgba(255,255,255,.18)
  static const Color onHeroChipBorder = Color(
    0x38FFFFFF,
  ); // rgba(255,255,255,.22)
  static const Color onHeroPillFill = Color(0x29FFFFFF); // rgba(255,255,255,.16)
  static const Color onHeroSubText = Color(0xC7FFFFFF); // rgba(255,255,255,.78)
  static const Color onHeroText = Color(0xFFFFFFFF);

  /// Jar illustration, in `viewBox="0 0 120 168"` order: lid, collar, glass
  /// body, liquid, meniscus, outline, highlight, then the ribbon bow.
  static const Color jarLidFill = Color(0xFFFFD79E);
  static const Color jarCollarFill = Color(0xFFFFC98A);
  static const Color jarGlassFill = Color(0x29FFFFFF); // rgba(255,255,255,.16)
  static const LinearGradient jarLiquidGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFA8F0DF), Color(0xFF6FD0E8)],
  );
  static const Color jarMeniscusFill = Color(0xFFBFF6E8);
  static const Color jarOutlineStroke = Color(0x80FFFFFF); // rgba(255,255,255,.5)
  static const Color jarHighlightStroke = Color(
    0x8CFFFFFF,
  ); // rgba(255,255,255,.55)
  static const Color jarBowFill = Color(0xFFFF9CC4);
  static const Color jarBowKnotFill = Color(0xFFF0609E);

  /// The floating hearts and bubbles suspended in the liquid. Opacities are
  /// applied by the painter; these are the base colors.
  static const Color jarFloaterFill = Color(0xFFFFFFFF);

  /// "Who loves the jar more" comparison bars,
  /// `linear-gradient(180deg,...)` top-to-bottom.
  static const LinearGradient comparisonSelfBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFFFB1D3), Color(0xFFF0609E)],
  );
  static const LinearGradient comparisonPartnerBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFA8F0DF), Color(0xFF3FBFA6)],
  );
}
