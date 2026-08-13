import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/cupid_platform.dart';
import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_typography_tokens.dart';

/// One destination in a [CupidTabBar].
@immutable
class CupidTabBarItem {
  const CupidTabBarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Tab-bar measurements transcribed verbatim from the design source's tab
/// chrome (`cupid-app-design-system/project/Cupid Screens.dc.html`, the
/// `showTabs` block: iOS variant lines 1613-1620, Material variant lines
/// 1623-1630). They are declared here rather than rounded onto
/// `CupidSpacing`'s 8pt grid so the sourcing stays auditable, matching
/// `home_screen.dart`'s `isHome` constants.
const double _barPaddingTop = 10;
const double _iosBarPaddingHorizontal = 6;
const double _iosBarPaddingBottom = 6;
const double _materialBarPaddingHorizontal = 4;
const double _materialBarPaddingBottom = 10;

/// iOS tab-bar icon size. The prototype paints 25px but `ux/uiux-spec.md`
/// section 6 ("Tab bar" row) and this story's AC4 both name 26; the locked
/// spec wins, same authority order as the days counter's 34pt display role.
const double _iosTabIconSize = 26;
const double _iosTabLabelSize = 10;
const double _iosTabItemGap = 3;

/// `letter-spacing:.01em` at [_iosTabLabelSize].
const double _iosTabLabelLetterSpacing = _iosTabLabelSize * 0.01;

const double _materialTabIconSize = 24;
const double _materialTabLabelSize = 11;
const double _materialTabItemGap = 4;
const double _materialPillPaddingHorizontal = 19;
const double _materialPillPaddingVertical = 5;

/// `rgba(255,127,182,.22)` — `colorAccentPink` at 22% alpha.
const int _materialPillActiveAlpha = 56;

const FontWeight _tabLabelWeight = FontWeight.w700;

/// `backdrop-filter:blur(26px) saturate(1.3)`. A CSS blur radius maps to a
/// Gaussian sigma of half its value.
const double _iosBarBlurSigma = 13;

/// CSS `saturate(1.3)` as a 5x4 color matrix, using the filter spec's
/// luminance weights (0.213 / 0.715 / 0.072).
const ColorFilter _iosBarSaturate = ColorFilter.matrix(<double>[
  1.2361, -0.2145, -0.0216, 0, 0, //
  -0.0639, 1.0855, -0.0216, 0, 0, //
  -0.0639, -0.2145, 1.2784, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Bottom tab bar — one of the four widgets in `design_system/adaptive/`
/// allowed to branch on platform (D3, AC 4). iOS renders a transparent bar
/// over a saturating backdrop blur with a 26pt icon + 10pt label per item;
/// Material renders an opaque surface with a pill-shaped active indicator
/// behind the selected item's icon.
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
    final bool isIos = platform == CupidPlatform.ios;

    final Widget bar = Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          isIos ? _iosBarPaddingHorizontal : _materialBarPaddingHorizontal,
          _barPaddingTop,
          isIos ? _iosBarPaddingHorizontal : _materialBarPaddingHorizontal,
          isIos ? _iosBarPaddingBottom : _materialBarPaddingBottom,
        ),
        decoration: BoxDecoration(
          color: isIos ? Colors.transparent : colors.colorSurface,
          border: Border(top: BorderSide(color: colors.colorLine)),
        ),
        // The design source's bottom padding is `calc(var(--safe-bot) + Npx)`,
        // so the device inset stacks on top of the padding above.
        child: SafeArea(
          top: false,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                // `flex:1` in both source variants: every destination takes an
                // equal share of the bar width.
                Expanded(
                  child: _CupidTabBarEntry(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                    isIos: isIos,
                    platformTokens: platformTokens,
                    colors: colors,
                    type: type,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!isIos) {
      return bar;
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.compose(
          outer: _iosBarSaturate,
          inner: ImageFilter.blur(
            sigmaX: _iosBarBlurSigma,
            sigmaY: _iosBarBlurSigma,
          ),
        ),
        child: bar,
      ),
    );
  }
}

class _CupidTabBarEntry extends StatelessWidget {
  const _CupidTabBarEntry({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.isIos,
    required this.platformTokens,
    required this.colors,
    required this.type,
  });

  final CupidTabBarItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool isIos;
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
        constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isIos)
              Icon(item.icon, size: _iosTabIconSize, color: tint)
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _materialPillPaddingHorizontal,
                  vertical: _materialPillPaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.colorAccentPink.withAlpha(
                          _materialPillActiveAlpha,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusButton,
                  ),
                ),
                child: Icon(item.icon, size: _materialTabIconSize, color: tint),
              ),
            SizedBox(height: isIos ? _iosTabItemGap : _materialTabItemGap),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: type.caption.copyWith(
                color: tint,
                fontSize: isIos ? _iosTabLabelSize : _materialTabLabelSize,
                fontWeight: _tabLabelWeight,
                letterSpacing: isIos ? _iosTabLabelLetterSpacing : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
