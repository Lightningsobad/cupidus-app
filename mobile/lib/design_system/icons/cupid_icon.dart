import 'package:flutter/material.dart';

import '../theme/cupid_theme_context.dart';

/// Icon fill-state variants (`ux/uiux-spec.md` section 2), mapped to the
/// Material Symbols Rounded font-variation axes bundled with the app
/// (ADR-004d). Values are exact `font-variation-settings` from the design
/// source, not invented.
enum CupidIconVariant {
  /// FILL 1, wght 400, GRAD 0, opsz 24 (design source "default (filled)").
  filled(fill: 1, weight: 400, grade: 0, opticalSize: 24),

  /// FILL 0, wght 350, GRAD 0, opsz 24 (design source "line (outline)").
  line(fill: 0, weight: 350, grade: 0, opticalSize: 24),

  /// FILL 1, wght 300, GRAD -25, opsz 24 (design source "soft").
  soft(fill: 1, weight: 300, grade: -25, opticalSize: 24);

  const CupidIconVariant({
    required this.fill,
    required this.weight,
    required this.grade,
    required this.opticalSize,
  });

  final double fill;
  final double weight;
  final double grade;
  final double opticalSize;
}

/// Renders a Material Symbols Rounded glyph with a [CupidIconVariant] fill
/// state. Platform-invariant per ADR-004d — do not branch on platform here.
///
/// [color] defaults to `context.cupidColors.colorText` rather than a
/// literal, so icons follow the active theme.
class CupidIcon extends StatelessWidget {
  const CupidIcon(
    this.icon, {
    super.key,
    this.variant = CupidIconVariant.filled,
    this.size,
    this.color,
  });

  final IconData icon;
  final CupidIconVariant variant;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      fill: variant.fill,
      weight: variant.weight,
      grade: variant.grade,
      opticalSize: variant.opticalSize,
      color: color ?? context.cupidColors.colorText,
    );
  }
}
