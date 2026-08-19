import 'package:flutter/material.dart';

import '../icons/cupid_icons.dart';
import '../theme/cupid_platform.dart';
import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';

/// Material FAB box, corner radius and glyph size, transcribed from the locked
/// design source's `isMD` add-action block (`Cupid Screens.dc.html` line 881:
/// `width:60px;height:60px;border-radius:20px`, glyph `font-size:27px`).
/// [CupidPlatformTokens.radiusButton] is the pill token (999) and resolves to
/// a circle on a square FAB, so it is not a radius source here.
const double _materialFabSize = 60;
const double _materialFabRadius = 20;
const double _materialFabGlyphSize = 27;

/// Add-new action — one of the four widgets in `design_system/adaptive/`
/// allowed to branch on platform (D3, AC 4). Behavior is
/// `ux/uiux-spec.md` section 6, "Add-new action" row: iOS renders a `+`
/// button meant for a nav bar's actions slot; Material renders a floating
/// action button meant for `Scaffold.floatingActionButton` (anchored
/// bottom-right by `Scaffold`'s default `FloatingActionButtonLocation`).
///
/// This widget builds no `Scaffold` or navigation shell itself (no screens,
/// per phase scope) — callers place it in the platform-appropriate slot.
class CupidAddAction extends StatelessWidget {
  const CupidAddAction({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidColorTokens colors = context.cupidColors;

    if (platform == CupidPlatform.ios) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: platformTokens.tapTarget,
          minHeight: platformTokens.tapTarget,
        ),
        child: IconButton(
          icon: Icon(CupidIcons.add, color: colors.colorAccentPink),
          onPressed: onPressed,
        ),
      );
    }

    return SizedBox(
      width: _materialFabSize,
      height: _materialFabSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: colors.gradientHot,
          borderRadius: BorderRadius.circular(_materialFabRadius),
          boxShadow: colors.glowShadow,
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          // The wrapper carries the fill and the glow; a Material background
          // or elevation shadow here would paint over one and double the
          // other.
          backgroundColor: Colors.transparent,
          foregroundColor: colors.colorText,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_materialFabRadius),
          ),
          child: const Icon(CupidIcons.add, size: _materialFabGlyphSize),
        ),
      ),
    );
  }
}
