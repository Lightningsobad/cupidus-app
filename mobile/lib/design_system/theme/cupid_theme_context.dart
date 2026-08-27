import 'package:flutter/material.dart';

import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_typography_tokens.dart';
import 'cupid_platform.dart';

/// [BuildContext] accessors for the design-token [ThemeExtension]s produced
/// by [buildCupidTheme] (`architecture/solution.md` section 2 downstream
/// contract). Feature code reads tokens only through these getters, never by
/// constructing token classes directly.
extension CupidThemeContext on BuildContext {
  CupidPlatformTokens get cupidPlatform {
    final CupidPlatformTokens? tokens = Theme.of(
      this,
    ).extension<CupidPlatformTokens>();
    return tokens ?? const CupidPlatformTokens.ios();
  }

  CupidColorTokens get cupidColors {
    final CupidColorTokens? tokens = Theme.of(
      this,
    ).extension<CupidColorTokens>();
    if (tokens != null) return tokens;
    return Theme.of(this).brightness == Brightness.light
        ? const CupidColorTokens.light()
        : const CupidColorTokens.dark();
  }

  CupidTypographyTokens get cupidType {
    final CupidTypographyTokens? tokens = Theme.of(
      this,
    ).extension<CupidTypographyTokens>();
    return tokens ?? CupidTypographyTokens.forPlatform(CupidPlatform.ios);
  }
}
