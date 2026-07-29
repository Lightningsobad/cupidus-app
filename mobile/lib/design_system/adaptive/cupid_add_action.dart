import 'package:flutter/material.dart';

import '../icons/cupid_icons.dart';
import '../theme/cupid_platform.dart';
import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';

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

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colors.colorAccentPink,
      foregroundColor: colors.colorText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
      ),
      child: const Icon(CupidIcons.add),
    );
  }
}
