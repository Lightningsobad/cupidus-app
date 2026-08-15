import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';
import 'vibe_mood_face.dart';

/// Partner's current vibe plus the contextual nudge banner
/// (`ux/uiux-spec.md` §5). Props-only: `mood` is the partner's mood for
/// local today (`null` for no check-in yet, or the §7 partner-unpair
/// defensive fallback — both render the same waiting state).
///
/// The nudge CTA pill is decorative only (D-010-4): the design source wires
/// no `onClick` and no backend endpoint exists for it, so it carries no tap
/// target and no interactive semantics (UX §8).
///
/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`,
/// `isVibe` block): card `padding:17px`, avatar box `52px` at `18px` radius
/// with `5px` inset, `13px` row gap, `15.5px/800` mood label, and a nudge
/// banner at `margin-top:14px;padding:13px 15px;gap:11px`.
const double _cardPadding = 17;
const double _avatarSize = 52;
const double _avatarRadius = 18;
const double _avatarInset = 5;
const double _avatarFaceSize = 42;
const double _headerGap = 13;
const double _moodLabelSize = 15.5;
const double _bannerTopGap = 14;
const double _bannerVerticalPadding = 13;
const double _bannerHorizontalPadding = 15;
const double _bannerGap = 11;
const double _bannerTint = 0.14;
const double _bannerIconSize = 19;
const double _bannerTextSize = 12.5;
const double _bannerTextHeight = 1.45;
const double _ctaVerticalPadding = 7;
const double _ctaHorizontalPadding = 13;
const double _ctaLabelSize = 11.5;

/// `tips_and_updates`, the nudge banner's glyph (UX §5). Confirmed in the
/// bundled `MaterialSymbolsRounded-Variable.ttf` cmap at 0xe79a, never
/// invented — same verification rule as `CupidIcons`. Declared locally
/// because `design_system/icons/` is outside this story's write scope;
/// promote it to `CupidIcons` when that file is next in scope.
const IconData _tipsAndUpdates = IconData(
  0xe79a,
  fontFamily: CupidIcons.fontFamily,
);

class PartnerVibeCard extends StatelessWidget {
  const PartnerVibeCard({super.key, required this.mood});

  final VibeMood? mood;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String moodLabel = mood == null
        ? context.waitingLabel
        : context.moodLabel(mood!);

    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        boxShadow: platform.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            label: moodLabel,
            child: ExcludeSemantics(
              child: Row(
                children: <Widget>[
                  Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    padding: const EdgeInsets.all(_avatarInset),
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(_avatarRadius),
                    ),
                    child: VibeMoodFace(mood: mood, size: _avatarFaceSize),
                  ),
                  const SizedBox(width: _headerGap),
                  Expanded(
                    child: Text(
                      moodLabel,
                      style: context.cupidType.body.copyWith(
                        fontSize: _moodLabelSize,
                        color: colors.colorText,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _bannerTopGap),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _bannerHorizontalPadding,
              vertical: _bannerVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: colors.colorAmber.withValues(alpha: _bannerTint),
              borderRadius: BorderRadius.circular(platform.radiusSmall),
            ),
            child: Row(
              children: <Widget>[
                CupidIcon(
                  _tipsAndUpdates,
                  size: _bannerIconSize,
                  color: colors.colorButter,
                ),
                const SizedBox(width: _bannerGap),
                Expanded(
                  child: Text(
                    context.nudgeMessage(mood),
                    style: context.cupidType.caption.copyWith(
                      fontSize: _bannerTextSize,
                      height: _bannerTextHeight,
                      color: colors.colorText,
                    ),
                  ),
                ),
                const SizedBox(width: _bannerGap),
                // Decorative label only (D-010-4): a `Container` + `Text`, no
                // `GestureDetector`/`InkWell` wrapper, so it carries no
                // button/interactive semantics to strip.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _ctaHorizontalPadding,
                    vertical: _ctaVerticalPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: colors.gradientHot,
                    borderRadius: BorderRadius.circular(platform.radiusButton),
                  ),
                  child: Text(
                    context.nudgeCta(mood),
                    softWrap: false,
                    style: context.cupidType.caption.copyWith(
                      fontSize: _ctaLabelSize,
                      // The design source hardcodes `#fff` here. There is no
                      // theme-invariant white token and the no-fork guard bans
                      // a raw literal, so this follows `CupidPrimaryButton`'s
                      // existing on-accent convention instead.
                      color: colors.colorText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
