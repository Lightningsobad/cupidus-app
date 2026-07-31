import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';
import 'vibe_mood_face.dart';

/// Discoverable entry point mounted on `HomeScreen`
/// (`architecture/solution.md` §4 D-010-5,
/// `coding-plan/phase-P3-vibe-screen-entrypoint.md`): a single tappable card
/// (icon + label + `Lịch sử`/chevron affordance) that pushes `VibeScreen`.
///
/// [today] optionally previews the mood glyph for a future home-dashboard
/// data-bind; v1 mounts this with both [today] and [partnerToday] omitted so
/// no duplicate fetch happens ahead of `VibeScreen`'s own load.
class VibeEntryCard extends StatelessWidget {
  const VibeEntryCard({
    super.key,
    this.today,
    this.partnerToday,
    required this.onTap,
  });

  final VibeMood? today;
  final VibeMood? partnerToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String title = context.viEn('Cảm xúc hằng ngày', 'Daily Vibe Check');
    final String historyLabel = context.viEn('Lịch sử', 'History');

    return Semantics(
      button: true,
      label: title,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: platform.tapTarget),
            child: Container(
              padding: const EdgeInsets.all(CupidSpacing.md),
              decoration: BoxDecoration(
                color: colors.colorSurface,
                borderRadius: BorderRadius.circular(platform.radiusCard),
                boxShadow: platform.elevationShadow,
              ),
              child: Row(
                children: <Widget>[
                  VibeMoodFace(mood: today, size: 40),
                  const SizedBox(width: CupidSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          title,
                          style: context.cupidType.body.copyWith(
                            color: colors.colorText,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          historyLabel,
                          style: context.cupidType.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: CupidSpacing.sm),
                  Icon(CupidIcons.chevronRight, color: colors.colorTextMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
