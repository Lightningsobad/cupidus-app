import 'package:flutter/material.dart';

import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_typography_tokens.dart';
import 'cupid_platform.dart';

/// Composes the P0 tokens into a [ThemeData] for one platform x brightness
/// combination (`ux/uiux-spec.md` section 5's 4-combination matrix).
///
/// [ThemeData.colorScheme] is derived from [CupidColorTokens] so stock
/// Material widgets inherit brand color from the same source of truth as
/// `context.cupidColors`, rather than a second, divergent palette.
ThemeData buildCupidTheme({
  required CupidPlatform platform,
  required Brightness brightness,
}) {
  final CupidPlatformTokens platformTokens = platform == CupidPlatform.ios
      ? const CupidPlatformTokens.ios()
      : const CupidPlatformTokens.material();
  final CupidColorTokens colorTokens = brightness == Brightness.dark
      ? const CupidColorTokens.dark()
      : const CupidColorTokens.light();
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
    scaffoldBackgroundColor: colorTokens.colorBackground,
    fontFamily: platformTokens.uiFontFamily,
    extensions: <ThemeExtension<dynamic>>[
      platformTokens,
      colorTokens,
      typographyTokens,
    ],
  );
}
