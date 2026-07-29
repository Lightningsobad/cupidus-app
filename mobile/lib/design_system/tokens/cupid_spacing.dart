/// Spacing scale shared across all 4 platform x theme combinations
/// (`ux/uiux-spec.md` section 4, base 8pt grid).
///
/// Not a [ThemeExtension]: the scale is invariant across platform and theme,
/// so a `Theme.of(context)` lookup would add cost without variance
/// (`architecture/solution.md` section 4).
abstract final class CupidSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
