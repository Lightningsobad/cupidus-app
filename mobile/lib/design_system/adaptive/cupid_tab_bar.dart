import 'package:flutter/material.dart';

import '../theme/cupid_platform.dart';
import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_spacing.dart';
import '../tokens/cupid_typography_tokens.dart';

/// One destination in a [CupidTabBar].
@immutable
class CupidTabBarItem {
  const CupidTabBarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// iOS tab-bar icon size (`ux/uiux-spec.md` section 6, "Tab bar" row).
/// Sourced verbatim from the design source; no [CupidPlatformTokens] field
/// covers a tab-icon-specific size.
const double _iosTabIconSize = 26;

/// iOS tab-bar label size (`ux/uiux-spec.md` section 6, "Tab bar" row).
const double _iosTabLabelSize = 10;

/// Bottom tab bar — one of the four widgets in `design_system/adaptive/`
/// allowed to branch on platform (D3, AC 4). Behavior is `ux/uiux-spec.md`
/// section 6, "Tab bar" row: iOS renders a translucent background with a
/// 26pt icon + 10pt label per item; Material renders a pill-shaped
/// active-state indicator behind the selected item's icon.
class CupidTabBar extends StatelessWidget {
  const CupidTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CupidTabBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: CupidSpacing.xs),
        decoration: BoxDecoration(
          color: platform == CupidPlatform.ios
              ? colors.colorSurface.withAlpha(217)
              : colors.colorSurface,
          border: Border(top: BorderSide(color: colors.colorLine)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              _CupidTabBarEntry(
                item: items[i],
                selected: i == currentIndex,
                onTap: () => onTap(i),
                platform: platform,
                platformTokens: platformTokens,
                colors: colors,
                type: type,
              ),
          ],
        ),
      ),
    );
  }
}

class _CupidTabBarEntry extends StatelessWidget {
  const _CupidTabBarEntry({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.platform,
    required this.platformTokens,
    required this.colors,
    required this.type,
  });

  final CupidTabBarItem item;
  final bool selected;
  final VoidCallback onTap;
  final CupidPlatform platform;
  final CupidPlatformTokens platformTokens;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    final Color tint = selected ? colors.colorAccentPink : colors.colorTextMuted;

    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: platformTokens.tapTarget,
          minHeight: platformTokens.tapTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (platform == CupidPlatform.material)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CupidSpacing.md,
                    vertical: CupidSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.colorAccentPink.withAlpha(38)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      platformTokens.radiusButton,
                    ),
                  ),
                  child: Icon(item.icon, color: tint),
                )
              else
                Icon(item.icon, size: _iosTabIconSize, color: tint),
              const SizedBox(height: CupidSpacing.xs),
              Text(
                item.label,
                style: type.caption.copyWith(
                  color: tint,
                  fontSize: platform == CupidPlatform.ios
                      ? _iosTabLabelSize
                      : type.caption.fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
