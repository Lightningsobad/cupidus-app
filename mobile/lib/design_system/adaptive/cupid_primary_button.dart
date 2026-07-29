import 'package:flutter/material.dart';

import '../theme/cupid_platform.dart';
import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_typography_tokens.dart';

/// Material primary-CTA corner radius (`ux/uiux-spec.md` section 6, "Primary
/// CTA" row: "Filled button, 20dp corner radius"). Distinct from
/// [CupidPlatformTokens.radiusButton] (999, pill), which the iOS variant
/// uses instead; no token field covers a non-pill CTA radius, so this value
/// is transcribed verbatim from the design source rather than invented.
const double _materialPrimaryCtaRadius = 20;

/// Primary call-to-action button — one of the four widgets in
/// `design_system/adaptive/` allowed to branch on platform (D3, AC 4).
/// Behavior is `ux/uiux-spec.md` section 6, "Primary CTA" row: iOS renders a
/// full-width pill using `radiusButton`; Material renders a filled button at
/// a 20dp corner radius with ripple feedback on press.
class CupidPrimaryButton extends StatelessWidget {
  const CupidPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    final double radius = platform == CupidPlatform.ios
        ? platformTokens.radiusButton
        : _materialPrimaryCtaRadius;

    return SizedBox(
      width: double.infinity,
      height: platformTokens.tapTarget,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.colorAccentPink,
          foregroundColor: colors.colorText,
          elevation: platform == CupidPlatform.ios ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Text(label, style: type.body.copyWith(color: colors.colorText)),
      ),
    );
  }
}
