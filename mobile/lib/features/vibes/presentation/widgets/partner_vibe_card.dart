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
      padding: const EdgeInsets.all(CupidSpacing.md),
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
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(CupidSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(platform.radiusSmall),
                    ),
                    child: VibeMoodFace(mood: mood, size: 42),
                  ),
                  const SizedBox(width: CupidSpacing.sm),
                  Expanded(
                    child: Text(
                      moodLabel,
                      style: context.cupidType.body.copyWith(
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
          const SizedBox(height: CupidSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.sm + CupidSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.colorButter,
              borderRadius: BorderRadius.circular(platform.radiusSmall),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.nudgeMessage(mood),
                    style: context.cupidType.caption.copyWith(color: colors.colorText),
                  ),
                ),
                const SizedBox(width: CupidSpacing.sm),
                // Decorative label only (D-010-4): a plain `Text`, no
                // `GestureDetector`/`InkWell` wrapper, so it carries no
                // button/interactive semantics to strip.
                Text(
                  context.nudgeCta(mood),
                  style: context.cupidType.caption.copyWith(
                    color: colors.colorText,
                    fontWeight: FontWeight.w800,
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
