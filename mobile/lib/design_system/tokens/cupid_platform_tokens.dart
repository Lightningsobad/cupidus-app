import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Platform-axis shape, motion and typeface-stack tokens
/// (`ux/uiux-spec.md` section 2). Values do not vary with [Brightness] — see
/// `CupidColorTokens` for the theme axis.
@immutable
class CupidPlatformTokens extends ThemeExtension<CupidPlatformTokens> {
  const CupidPlatformTokens({
    required this.radiusCard,
    required this.radiusButton,
    required this.radiusSheet,
    required this.radiusSmall,
    required this.safeTop,
    required this.safeBottom,
    required this.tapTarget,
    required this.uiFontFamily,
    required this.elevationShadow,
  });

  /// iOS-style platform tokens (`ux/uiux-spec.md` section 2, "iOS-style"
  /// column). [uiFontFamily] is left `null` so text falls back to the host
  /// OS default (SF Pro on iOS): SF Pro cannot be bundled as an app asset
  /// under Apple's licence (`architecture/solution.md` section 3,
  /// assumption a), so iOS-style typography is verified on iOS targets only.
  const CupidPlatformTokens.ios()
    : radiusCard = 26,
      radiusButton = 999,
      radiusSheet = 28,
      radiusSmall = 16,
      safeTop = 54,
      safeBottom = 24,
      tapTarget = 44,
      uiFontFamily = null,
      elevationShadow = const <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(80, 30, 110, 0.18),
          offset: Offset(0, 10),
          blurRadius: 30,
        ),
      ];

  /// Material-style platform tokens (`ux/uiux-spec.md` section 2,
  /// "Material-style" column). `Roboto` is bundled as an app asset
  /// (`architecture/solution.md` section 4, Infrastructure), so it is set
  /// explicitly rather than left to the host OS default.
  const CupidPlatformTokens.material()
    : radiusCard = 24,
      radiusButton = 999,
      radiusSheet = 28,
      radiusSmall = 16,
      safeTop = 6,
      safeBottom = 6,
      tapTarget = 48,
      uiFontFamily = 'Roboto',
      elevationShadow = const <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(80, 30, 110, 0.16),
          offset: Offset(0, 6),
          blurRadius: 18,
        ),
      ];

  /// Card/content container corner radius.
  final double radiusCard;

  /// Button corner radius (999 = pill on both platforms).
  final double radiusButton;

  /// Bottom sheet / modal corner radius.
  final double radiusSheet;

  /// Small chip/input corner radius.
  final double radiusSmall;

  /// Top safe-area allowance used by the design frame.
  final double safeTop;

  /// Bottom safe-area allowance used by the design frame.
  final double safeBottom;

  /// Minimum interactive hit target (matches HIG/M3 minimums).
  final double tapTarget;

  /// UI/body font family for this platform, or `null` to use the host OS
  /// default (iOS only — see [CupidPlatformTokens.ios]).
  final String? uiFontFamily;

  /// Card/sheet elevation shadow.
  final List<BoxShadow> elevationShadow;

  @override
  CupidPlatformTokens copyWith({
    double? radiusCard,
    double? radiusButton,
    double? radiusSheet,
    double? radiusSmall,
    double? safeTop,
    double? safeBottom,
    double? tapTarget,
    String? uiFontFamily,
    List<BoxShadow>? elevationShadow,
  }) {
    return CupidPlatformTokens(
      radiusCard: radiusCard ?? this.radiusCard,
      radiusButton: radiusButton ?? this.radiusButton,
      radiusSheet: radiusSheet ?? this.radiusSheet,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      safeTop: safeTop ?? this.safeTop,
      safeBottom: safeBottom ?? this.safeBottom,
      tapTarget: tapTarget ?? this.tapTarget,
      uiFontFamily: uiFontFamily ?? this.uiFontFamily,
      elevationShadow: elevationShadow ?? this.elevationShadow,
    );
  }

  @override
  CupidPlatformTokens lerp(
    ThemeExtension<CupidPlatformTokens>? other,
    double t,
  ) {
    if (other is! CupidPlatformTokens) {
      return this;
    }
    return CupidPlatformTokens(
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      radiusButton: lerpDouble(radiusButton, other.radiusButton, t)!,
      radiusSheet: lerpDouble(radiusSheet, other.radiusSheet, t)!,
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t)!,
      safeTop: lerpDouble(safeTop, other.safeTop, t)!,
      safeBottom: lerpDouble(safeBottom, other.safeBottom, t)!,
      tapTarget: lerpDouble(tapTarget, other.tapTarget, t)!,
      uiFontFamily: t < 0.5 ? uiFontFamily : other.uiFontFamily,
      elevationShadow:
          BoxShadow.lerpList(elevationShadow, other.elevationShadow, t) ??
          elevationShadow,
    );
  }
}
