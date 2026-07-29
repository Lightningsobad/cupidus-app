import 'package:flutter/material.dart';

import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_typography_tokens.dart';

/// [BuildContext] accessors for the design-token [ThemeExtension]s produced
/// by [buildCupidTheme] (`architecture/solution.md` section 2 downstream
/// contract). Feature code reads tokens only through these getters, never by
/// constructing token classes directly.
extension CupidThemeContext on BuildContext {
  CupidPlatformTokens get cupidPlatform {
    final CupidPlatformTokens? tokens = Theme.of(
      this,
    ).extension<CupidPlatformTokens>();
    assert(
      tokens != null,
      'CupidPlatformTokens missing from Theme; build the ThemeData with '
      'buildCupidTheme.',
    );
    return tokens!;
  }

  CupidColorTokens get cupidColors {
    final CupidColorTokens? tokens = Theme.of(
      this,
    ).extension<CupidColorTokens>();
    assert(
      tokens != null,
      'CupidColorTokens missing from Theme; build the ThemeData with '
      'buildCupidTheme.',
    );
    return tokens!;
  }

  CupidTypographyTokens get cupidType {
    final CupidTypographyTokens? tokens = Theme.of(
      this,
    ).extension<CupidTypographyTokens>();
    assert(
      tokens != null,
      'CupidTypographyTokens missing from Theme; build the ThemeData with '
      'buildCupidTheme.',
    );
    return tokens!;
  }
}
