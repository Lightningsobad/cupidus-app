import 'package:cupid_mobile/design_system/tokens/cupid_css_angle_gradient.dart';
import 'package:flutter/material.dart';

/// The direction vectors for the shared 120deg linear gradient
/// (`gradientDream`) below, derived from the CSS `linear-gradient(120deg, ...)`
/// angle: 0deg points "to top", angles rotate clockwise.
/// `sin(120deg) = 0.8660254037844387`, `cos(120deg) = -0.5`.
const Alignment _gradient120Begin = Alignment(-0.8660254037844387, -0.5);
const Alignment _gradient120End = Alignment(0.8660254037844387, 0.5);

/// The direction vectors for `gradientHot`, derived the same way from a 95deg
/// CSS angle. `sin(95deg) = 0.9961946980917455`,
/// `cos(95deg) = -0.08715574274765817`.
///
/// 95deg is the design source's real CTA angle: every actual CTA usage in the
/// canvases hardcodes `linear-gradient(95deg, var(--pink), var(--purple))`
/// inline. The source's `--grad-hot` base variable is still declared at 120deg
/// but is stale/dead — no canvas references it. `gradientDream` is a distinct
/// token and genuinely stays at 120deg, hence the separate pair above.
///
/// Consumed through [CupidCssAngleGradient], which reads this pair as a
/// direction vector. Passing it to a plain [LinearGradient] renders the angle
/// box-normalized instead of geometric: on a 380x52 pill that turns the
/// declared 95deg into 0.69deg off horizontal.
const Alignment _gradient95Begin = Alignment(
  -0.9961946980917455,
  -0.08715574274765817,
);
const Alignment _gradient95End = Alignment(
  0.9961946980917455,
  0.08715574274765817,
);

/// The direction vectors for `gradientBrandBackdrop`, derived the same way
/// from a 165deg CSS angle. `sin(165deg) = 0.25881904510252074`,
/// `cos(165deg) = -0.9659258262890683`.
///
/// Consumed through [CupidCssAngleGradient], for the same reason as the 95deg
/// pair: on welcome's 412x915 backdrop a plain [LinearGradient] renders this
/// declared 165deg as 6.86deg off vertical.
const Alignment _gradient165Begin = Alignment(
  -0.25881904510252074,
  -0.9659258262890683,
);
const Alignment _gradient165End = Alignment(
  0.25881904510252074,
  0.9659258262890683,
);

/// Theme-axis color tokens (`ux/uiux-spec.md` section 3). Values do not vary
/// with platform — see `CupidPlatformTokens` for the platform axis.
@immutable
class CupidColorTokens extends ThemeExtension<CupidColorTokens> {
  const CupidColorTokens({
    required this.colorBackground,
    required this.colorSurface,
    required this.colorSurfaceAlt,
    required this.colorLine,
    required this.colorText,
    required this.colorTextMuted,
    required this.colorOnAccent,
    required this.colorAccentPink,
    required this.colorAccentPinkDark,
    required this.colorAccentPurple,
    required this.colorAccentPurpleDark,
    required this.colorAccentLilac,
    required this.colorMint,
    required this.colorGreen,
    required this.colorButter,
    required this.colorAmber,
    required this.colorPeach,
    required this.colorRed,
    required this.colorGhost,
    required this.colorGlowCore,
    required this.glowShadow,
    required this.skyGradient,
    required this.gradientDream,
    required this.gradientHot,
    required this.gradientBrandBackdrop,
  });

  /// Dark theme tokens (`ux/uiux-spec.md` section 3, "Dark" column).
  const CupidColorTokens.dark()
    : colorBackground = const Color(0xFF171129),
      colorSurface = const Color(0xFF241B42),
      colorSurfaceAlt = const Color(0xFF2E2456),
      colorLine = const Color.fromRGBO(247, 238, 251, 0.11),
      colorText = const Color(0xFFF7EEFB),
      colorTextMuted = const Color(0xFFB4A6CE),
      colorOnAccent = const Color(0xFFF7EEFB),
      colorAccentPink = const Color(0xFFFF7FB6),
      colorAccentPinkDark = const Color(0xFFF0609E),
      colorAccentPurple = const Color(0xFFB78CF5),
      colorAccentPurpleDark = const Color(0xFF8E5FD6),
      colorAccentLilac = const Color(0xFFD9C2FF),
      colorMint = const Color(0xFF79E2CD),
      colorGreen = const Color(0xFF79E2CD),
      colorButter = const Color(0xFFFFD79E),
      colorAmber = const Color(0xFFFFC97E),
      colorPeach = const Color(0xFFFFAB93),
      colorRed = const Color(0xFFFF6F91),
      colorGhost = const Color(0xFFB4A6CE),
      colorGlowCore = const Color(0xFFFFFFFF),
      glowShadow = const <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(255, 107, 168, 0.34),
          offset: Offset(0, 8),
          blurRadius: 28,
        ),
      ],
      skyGradient =
          'radial-gradient(120% 70% at 15% -8%, rgba(123,47,190,.55), '
          'transparent 62%), radial-gradient(90% 55% at 95% 6%, '
          'rgba(255,75,140,.32), transparent 60%), radial-gradient(80% 50% '
          'at 50% 108%, rgba(0,201,167,.16), transparent 62%)',
      gradientDream = const LinearGradient(
        begin: _gradient120Begin,
        end: _gradient120End,
        colors: <Color>[
          Color(0xFFFF9CC4),
          Color(0xFFC79BF0),
          Color(0xFF8FE6D3),
        ],
        stops: <double>[0.0, 0.52, 1.0],
      ),
      gradientHot = const CupidCssAngleGradient(
        begin: _gradient95Begin,
        end: _gradient95End,
        colors: <Color>[Color(0xFFFF7FB6), Color(0xFFB78CF5)],
      ),
      // Not theme-overridden in source: identical in dark and light.
      gradientBrandBackdrop = const CupidCssAngleGradient(
        begin: _gradient165Begin,
        end: _gradient165End,
        colors: <Color>[
          Color(0xFF7B2FBE),
          Color(0xFFFF4B8C),
          Color(0xFFFF3366),
        ],
        stops: <double>[0.0, 0.58, 1.0],
      );

  /// Light theme tokens (`ux/uiux-spec.md` section 3, "Light" column).
  ///
  /// ADR-004b (light-accent contrast): [colorAccentPink], [colorAccentPinkDark],
  /// [colorAccentPurple] and [colorAccentPurpleDark] fail the 4.5:1 AA
  /// contrast threshold for normal/small text on [colorSurface] /
  /// [colorBackground] in this theme (light `colorAccentPink` on white is
  /// ~3.4:1 — see `ux/uiux-spec.md` section 5). They may be used for large
  /// text (>=18pt, or >=14pt bold), icons, borders, focus rings, gradients
  /// and decorative accents only; body/caption text must use [colorText] or
  /// [colorTextMuted] instead. Enforced here via dartdoc and by
  /// `test/design_system/contrast_test.dart`.
  const CupidColorTokens.light()
    : colorBackground = const Color(0xFFFFF6FB),
      colorSurface = const Color(0xFFFFFFFF),
      colorSurfaceAlt = const Color(0xFFFFEEF7),
      colorLine = const Color(0xFFF7DFEC),
      colorText = const Color(0xFF3E2645),
      colorTextMuted = const Color(0xFF8A6D97),
      colorOnAccent = const Color(0xFFFFFFFF),
      colorAccentPink = const Color(0xFFE8558F),
      colorAccentPinkDark = const Color(0xFFD2417B),
      colorAccentPurple = const Color(0xFF9A63E8),
      // ADR-004c: the design source has no light-theme override for
      // `colorAccentPurpleDark`. Decision for v1: carry the dark value
      // (#8E5FD6) unchanged. This measures ~4.4:1 on white — non-text-safe
      // under ADR-004b, which matches this token's existing usage (gradient
      // stop, pressed/darker accent state). Do not substitute a different
      // value without a UI/UX Designer decision.
      colorAccentPurpleDark = const Color(0xFF8E5FD6),
      colorAccentLilac = const Color(0xFFB78CF5),
      colorMint = const Color(0xFF22B398),
      colorGreen = const Color(0xFF22B398),
      colorButter = const Color(0xFFDE9A31),
      colorAmber = const Color(0xFFDE9A31),
      colorPeach = const Color(0xFFEF7F5F),
      colorRed = const Color(0xFFEA5578),
      colorGhost = const Color(0xFFA793B4),
      colorGlowCore = const Color(0xFFFFFFFF),
      glowShadow = const <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(255, 107, 168, 0.26),
          offset: Offset(0, 8),
          blurRadius: 24,
        ),
      ],
      skyGradient =
          'radial-gradient(120% 70% at 12% -10%, rgba(255,182,214,.72), '
          'transparent 62%), radial-gradient(90% 55% at 96% 4%, '
          'rgba(206,180,255,.6), transparent 60%), radial-gradient(80% 50% '
          'at 50% 108%, rgba(178,240,226,.5), transparent 62%)',
      // Not theme-overridden in source: identical to CupidColorTokens.dark().
      gradientDream = const LinearGradient(
        begin: _gradient120Begin,
        end: _gradient120End,
        colors: <Color>[
          Color(0xFFFF9CC4),
          Color(0xFFC79BF0),
          Color(0xFF8FE6D3),
        ],
        stops: <double>[0.0, 0.52, 1.0],
      ),
      gradientHot = const CupidCssAngleGradient(
        begin: _gradient95Begin,
        end: _gradient95End,
        colors: <Color>[Color(0xFFFF7FB6), Color(0xFFB78CF5)],
      ),
      // Not theme-overridden in source: identical in dark and light.
      gradientBrandBackdrop = const CupidCssAngleGradient(
        begin: _gradient165Begin,
        end: _gradient165End,
        colors: <Color>[
          Color(0xFF7B2FBE),
          Color(0xFFFF4B8C),
          Color(0xFFFF3366),
        ],
        stops: <double>[0.0, 0.58, 1.0],
      );

  final Color colorBackground;
  final Color colorSurface;
  final Color colorSurfaceAlt;

  /// Divider/border color.
  final Color colorLine;
  final Color colorText;
  final Color colorTextMuted;

  /// Text/icon glyph rendered on top of [gradientHot]. Scoped to that
  /// accent-fill surface only; general body/label text keeps using
  /// [colorText], which stays free to diverge from this token.
  final Color colorOnAccent;

  /// See the ADR-004b dartdoc on [CupidColorTokens.light] for the
  /// light-theme usage restriction on this token.
  final Color colorAccentPink;

  /// See the ADR-004b dartdoc on [CupidColorTokens.light] for the
  /// light-theme usage restriction on this token.
  final Color colorAccentPinkDark;

  /// See the ADR-004b dartdoc on [CupidColorTokens.light] for the
  /// light-theme usage restriction on this token.
  final Color colorAccentPurple;

  /// See the ADR-004b and ADR-004c dartdocs on [CupidColorTokens.light] for
  /// the light-theme usage restriction and design-source gap on this token.
  final Color colorAccentPurpleDark;
  final Color colorAccentLilac;

  /// Success/trust role.
  final Color colorMint;

  /// Success role; duplicate of [colorMint] in dark theme.
  final Color colorGreen;

  /// Warning role, paired with [colorAmber].
  final Color colorButter;

  /// Warning role, paired with [colorButter].
  final Color colorAmber;
  final Color colorPeach;

  /// Danger/destructive role.
  final Color colorRed;

  /// Muted/inactive role.
  final Color colorGhost;

  /// Pure white core of decorative radial glow/highlight overlays, which the
  /// design source paints as `rgba(255,255,255,a)` rather than as a tinted
  /// surface colour. Deliberately not [colorOnAccent]: that token is the
  /// glyph colour on [gradientHot] and is `#F7EEFB` in dark theme, so reusing
  /// it would tint these overlays. Decorative fills only — never text.
  final Color colorGlowCore;

  /// Glow shadow used behind hero/CTA elements.
  final List<BoxShadow> glowShadow;

  /// Screen background decoration: verbatim CSS `radial-gradient(...)` value
  /// from `ux/uiux-spec.md` section 3. This is a stacked multi-layer radial
  /// gradient with independent per-layer ellipse size/position that has no
  /// lossless single-object Flutter [Gradient] equivalent; it is carried as
  /// the literal design-source string rather than an invented Flutter
  /// approximation. The screen-background rendering approach is decided by
  /// the story that first paints this decoration, not this token layer
  /// (`coding-plan/phase-P0-tokens.md` Phase Sizing: "token layer only, no
  /// theme assembly and no widgets").
  final String skyGradient;

  /// Hero/CTA/days-counter gradient. Identical in dark and light theme (not
  /// theme-overridden in source).
  final LinearGradient gradientDream;

  /// Identical in dark and light theme (not theme-overridden in source).
  final LinearGradient gradientHot;

  /// Full-screen brand backdrop, verbatim from the design source's
  /// `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)`
  /// (`Cupid Screens.dc.html` line 69, `isWelcome` block). This is a distinct
  /// token from [gradientHot]: that one is the two-stop 95deg *button* fill.
  /// Backdrops must not reuse it — the welcome screen's white and
  /// white-at-alpha foreground is only legible against these saturated stops.
  /// Identical in dark and light theme (not theme-overridden in source).
  final LinearGradient gradientBrandBackdrop;

  @override
  CupidColorTokens copyWith({
    Color? colorBackground,
    Color? colorSurface,
    Color? colorSurfaceAlt,
    Color? colorLine,
    Color? colorText,
    Color? colorTextMuted,
    Color? colorOnAccent,
    Color? colorAccentPink,
    Color? colorAccentPinkDark,
    Color? colorAccentPurple,
    Color? colorAccentPurpleDark,
    Color? colorAccentLilac,
    Color? colorMint,
    Color? colorGreen,
    Color? colorButter,
    Color? colorAmber,
    Color? colorPeach,
    Color? colorRed,
    Color? colorGhost,
    Color? colorGlowCore,
    List<BoxShadow>? glowShadow,
    String? skyGradient,
    LinearGradient? gradientDream,
    LinearGradient? gradientHot,
    LinearGradient? gradientBrandBackdrop,
  }) {
    return CupidColorTokens(
      colorBackground: colorBackground ?? this.colorBackground,
      colorSurface: colorSurface ?? this.colorSurface,
      colorSurfaceAlt: colorSurfaceAlt ?? this.colorSurfaceAlt,
      colorLine: colorLine ?? this.colorLine,
      colorText: colorText ?? this.colorText,
      colorTextMuted: colorTextMuted ?? this.colorTextMuted,
      colorOnAccent: colorOnAccent ?? this.colorOnAccent,
      colorAccentPink: colorAccentPink ?? this.colorAccentPink,
      colorAccentPinkDark: colorAccentPinkDark ?? this.colorAccentPinkDark,
      colorAccentPurple: colorAccentPurple ?? this.colorAccentPurple,
      colorAccentPurpleDark:
          colorAccentPurpleDark ?? this.colorAccentPurpleDark,
      colorAccentLilac: colorAccentLilac ?? this.colorAccentLilac,
      colorMint: colorMint ?? this.colorMint,
      colorGreen: colorGreen ?? this.colorGreen,
      colorButter: colorButter ?? this.colorButter,
      colorAmber: colorAmber ?? this.colorAmber,
      colorPeach: colorPeach ?? this.colorPeach,
      colorRed: colorRed ?? this.colorRed,
      colorGhost: colorGhost ?? this.colorGhost,
      colorGlowCore: colorGlowCore ?? this.colorGlowCore,
      glowShadow: glowShadow ?? this.glowShadow,
      skyGradient: skyGradient ?? this.skyGradient,
      gradientDream: gradientDream ?? this.gradientDream,
      gradientHot: gradientHot ?? this.gradientHot,
      gradientBrandBackdrop:
          gradientBrandBackdrop ?? this.gradientBrandBackdrop,
    );
  }

  @override
  CupidColorTokens lerp(ThemeExtension<CupidColorTokens>? other, double t) {
    if (other is! CupidColorTokens) {
      return this;
    }
    return CupidColorTokens(
      colorBackground: Color.lerp(colorBackground, other.colorBackground, t)!,
      colorSurface: Color.lerp(colorSurface, other.colorSurface, t)!,
      colorSurfaceAlt: Color.lerp(colorSurfaceAlt, other.colorSurfaceAlt, t)!,
      colorLine: Color.lerp(colorLine, other.colorLine, t)!,
      colorText: Color.lerp(colorText, other.colorText, t)!,
      colorTextMuted: Color.lerp(colorTextMuted, other.colorTextMuted, t)!,
      colorOnAccent: Color.lerp(colorOnAccent, other.colorOnAccent, t)!,
      colorAccentPink: Color.lerp(colorAccentPink, other.colorAccentPink, t)!,
      colorAccentPinkDark: Color.lerp(
        colorAccentPinkDark,
        other.colorAccentPinkDark,
        t,
      )!,
      colorAccentPurple: Color.lerp(
        colorAccentPurple,
        other.colorAccentPurple,
        t,
      )!,
      colorAccentPurpleDark: Color.lerp(
        colorAccentPurpleDark,
        other.colorAccentPurpleDark,
        t,
      )!,
      colorAccentLilac: Color.lerp(
        colorAccentLilac,
        other.colorAccentLilac,
        t,
      )!,
      colorMint: Color.lerp(colorMint, other.colorMint, t)!,
      colorGreen: Color.lerp(colorGreen, other.colorGreen, t)!,
      colorButter: Color.lerp(colorButter, other.colorButter, t)!,
      colorAmber: Color.lerp(colorAmber, other.colorAmber, t)!,
      colorPeach: Color.lerp(colorPeach, other.colorPeach, t)!,
      colorRed: Color.lerp(colorRed, other.colorRed, t)!,
      colorGhost: Color.lerp(colorGhost, other.colorGhost, t)!,
      colorGlowCore: Color.lerp(colorGlowCore, other.colorGlowCore, t)!,
      glowShadow: BoxShadow.lerpList(glowShadow, other.glowShadow, t) ?? glowShadow,
      skyGradient: t < 0.5 ? skyGradient : other.skyGradient,
      gradientDream:
          LinearGradient.lerp(gradientDream, other.gradientDream, t) ??
          gradientDream,
      gradientHot:
          LinearGradient.lerp(gradientHot, other.gradientHot, t) ??
          gradientHot,
      gradientBrandBackdrop:
          LinearGradient.lerp(
            gradientBrandBackdrop,
            other.gradientBrandBackdrop,
            t,
          ) ??
          gradientBrandBackdrop,
    );
  }
}
