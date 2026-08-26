import 'package:flutter/material.dart';

import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_typography_tokens.dart';
import '../tokens/theme_catalog.dart';
import 'cupid_platform.dart';

/// Resolves [CupidColorTokens] tailored to a [ThemeDefinition].
CupidColorTokens colorTokensForTheme(ThemeDefinition theme, Brightness brightness) {
  final CupidColorTokens base = brightness == Brightness.dark
      ? const CupidColorTokens.dark()
      : const CupidColorTokens.light();

  if (theme.id == 'nebula') {
    return base;
  }

  switch (theme.id) {
    case 'sunset':
      return base.copyWith(
        colorBackground: const Color(0xFF1F1218),
        colorSurface: const Color(0xFF2E1722),
        colorSurfaceAlt: const Color(0xFF3E1F2E),
        colorLine: const Color(0x33FF6B6B),
        colorAccentPink: const Color(0xFFFF6B6B),
        colorAccentPurple: const Color(0xFFFF8E53),
        colorAccentLilac: const Color(0xFFFFD93D),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x55FF6B6B),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );

    case 'sakura':
      return base.copyWith(
        colorBackground: const Color(0xFF1D141C),
        colorSurface: const Color(0xFF2B1826),
        colorSurfaceAlt: const Color(0xFF3B2034),
        colorLine: const Color(0x33FF758C),
        colorAccentPink: const Color(0xFFFF758C),
        colorAccentPurple: const Color(0xFFFF7EB3),
        colorAccentLilac: const Color(0xFFF7D1BA),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x55FF758C),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFFFF758C), Color(0xFFFF7EB3)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFFFF758C), Color(0xFFFF7EB3), Color(0xFFF7D1BA)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );

    case 'ocean':
      return base.copyWith(
        colorBackground: const Color(0xFF0D1B2A),
        colorSurface: const Color(0xFF12263A),
        colorSurfaceAlt: const Color(0xFF19354F),
        colorLine: const Color(0x3300D2D3),
        colorAccentPink: const Color(0xFF00D2D3),
        colorAccentPurple: const Color(0xFF2E86DE),
        colorAccentLilac: const Color(0xFF54A0FF),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x5500D2D3),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFF00D2D3), Color(0xFF2E86DE)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFF00D2D3), Color(0xFF2E86DE), Color(0xFF54A0FF)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );

    case 'matcha':
      return base.copyWith(
        colorBackground: const Color(0xFF0E1E17),
        colorSurface: const Color(0xFF142B21),
        colorSurfaceAlt: const Color(0xFF1B3A2C),
        colorLine: const Color(0x331DD1A1),
        colorAccentPink: const Color(0xFF1DD1A1),
        colorAccentPurple: const Color(0xFF10AC84),
        colorAccentLilac: const Color(0xFF55EFC4),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x551DD1A1),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFF1DD1A1), Color(0xFF10AC84)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFF55EFC4), Color(0xFF1DD1A1), Color(0xFF10AC84)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );

    case 'midnight':
      return base.copyWith(
        colorBackground: const Color(0xFF0A0717),
        colorSurface: const Color(0xFF15102D),
        colorSurfaceAlt: const Color(0xFF1E1740),
        colorLine: const Color(0x3301CBC6),
        colorAccentPink: const Color(0xFF01CBC6),
        colorAccentPurple: const Color(0xFF5F27CD),
        colorAccentLilac: const Color(0xFF341F97),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x5501CBC6),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFF01CBC6), Color(0xFF5F27CD)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFF01CBC6), Color(0xFF5F27CD), Color(0xFF341F97)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );

    case 'lavender':
      return base.copyWith(
        colorBackground: const Color(0xFF181528),
        colorSurface: const Color(0xFF231E3B),
        colorSurfaceAlt: const Color(0xFF302A4F),
        colorLine: const Color(0x339C88FF),
        colorAccentPink: const Color(0xFF9C88FF),
        colorAccentPurple: const Color(0xFF8C7AE6),
        colorAccentLilac: const Color(0xFFE1BEE7),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x559C88FF),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFF9C88FF), Color(0xFF8C7AE6)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFFE1BEE7), Color(0xFF9C88FF), Color(0xFF8C7AE6)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );

    case 'cyberpunk':
      return base.copyWith(
        colorBackground: const Color(0xFF0F0B1A),
        colorSurface: const Color(0xFF1A1230),
        colorSurfaceAlt: const Color(0xFF271A47),
        colorLine: const Color(0x33FF007F),
        colorAccentPink: const Color(0xFFFF007F),
        colorAccentPurple: const Color(0xFF00F0FF),
        colorAccentLilac: const Color(0xFFFFEE00),
        glowShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x55FF007F),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
        gradientHot: const LinearGradient(
          begin: Alignment(-0.95, -0.31),
          end: Alignment(0.95, 0.31),
          colors: <Color>[Color(0xFFFF007F), Color(0xFF00F0FF)],
        ),
        gradientDream: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: <Color>[Color(0xFFFF007F), Color(0xFF00F0FF), Color(0xFFFFEE00)],
        ),
        gradientBrandBackdrop: theme.gradient,
      );
  }

  final Color primary = theme.palette.length > 1 ? theme.palette[1].hex : base.colorAccentPink;
  final Color secondary = theme.palette.length > 2 ? theme.palette[2].hex : base.colorAccentPurple;
  final Color highlight = theme.palette.length > 3 ? theme.palette[3].hex : base.colorAccentLilac;
  final Color bg = theme.palette.isNotEmpty ? theme.palette[0].hex : base.colorBackground;
  final Color surface = Color.alphaBlend(primary.withValues(alpha: 0.14), const Color(0xFF140F22));
  final Color surfaceAlt = Color.alphaBlend(primary.withValues(alpha: 0.22), const Color(0xFF1C1530));
  final Color line = primary.withValues(alpha: 0.20);

  return base.copyWith(
    colorBackground: bg,
    colorSurface: surface,
    colorSurfaceAlt: surfaceAlt,
    colorLine: line,
    colorAccentPink: primary,
    colorAccentPurple: secondary,
    colorAccentLilac: highlight,
    glowShadow: <BoxShadow>[
      BoxShadow(
        color: primary.withValues(alpha: 0.36),
        offset: const Offset(0, 8),
        blurRadius: 28,
      ),
    ],
    gradientHot: LinearGradient(
      begin: const Alignment(-0.95, -0.31),
      end: const Alignment(0.95, 0.31),
      colors: <Color>[primary, secondary],
    ),
    gradientDream: LinearGradient(
      begin: const Alignment(-0.87, -0.5),
      end: const Alignment(0.87, 0.5),
      colors: <Color>[primary, secondary, highlight],
    ),
    gradientBrandBackdrop: theme.gradient,
  );
}

/// Composes the P0 tokens into a [ThemeData] for one platform x brightness
/// combination (`ux/uiux-spec.md` section 5's 4-combination matrix).
///
/// [ThemeData.colorScheme] is derived from [CupidColorTokens] so stock
/// Material widgets inherit brand color from the same source of truth as
/// `context.cupidColors`, rather than a second, divergent palette.
ThemeData buildCupidTheme({
  required CupidPlatform platform,
  required Brightness brightness,
  ThemeDefinition? themeDefinition,
}) {
  final CupidPlatformTokens platformTokens = platform == CupidPlatform.ios
      ? const CupidPlatformTokens.ios()
      : const CupidPlatformTokens.material();
  final CupidColorTokens colorTokens = themeDefinition != null
      ? colorTokensForTheme(themeDefinition, brightness)
      : (brightness == Brightness.dark
          ? const CupidColorTokens.dark()
          : const CupidColorTokens.light());
  final CupidTypographyTokens typographyTokens =
      CupidTypographyTokens.forPlatform(platform);

  final ColorScheme colorScheme = ColorScheme(
    brightness: brightness,
    primary: colorTokens.colorAccentPink,
    onPrimary: colorTokens.colorText,
    secondary: colorTokens.colorAccentPurple,
    onSecondary: colorTokens.colorText,
    error: colorTokens.colorRed,
    onError: colorTokens.colorText,
    surface: colorTokens.colorSurface,
    onSurface: colorTokens.colorText,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    // CupidAppBackground owns the base fill now, one layer above every route;
    // an opaque scaffold here would occlude its sky wash.
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: platformTokens.uiFontFamily,
    extensions: <ThemeExtension<dynamic>>[
      platformTokens,
      colorTokens,
      typographyTokens,
    ],
  );
}
