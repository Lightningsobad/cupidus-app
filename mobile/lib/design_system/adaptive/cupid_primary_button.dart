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

/// Primary-CTA height, transcribed from the locked design source's CTA block.
/// [CupidPlatformTokens.tapTarget] stays the minimum-touch-size token and is
/// not a height source for this button, which the source draws taller than the
/// platform minimum on both platforms.
const double _primaryCtaHeight = 54;

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
      height: _primaryCtaHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: colors.gradientHot,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: colors.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            // The wrapper carries the fill and the glow; a Material background
            // or elevation shadow here would paint over one and double the
            // other.
            backgroundColor: Colors.transparent,
            foregroundColor: colors.colorText,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: Text(
            label,
            style: type.body.copyWith(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: colors.colorText,
            ),
          ),
        ),
      ),
    );
  }
}
