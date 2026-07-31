import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';

/// Dashboard "Love Timeline" entry point (`ux/uiux-spec.md` section 1.1,
/// `coding-plan/phase-P7-entry-point-gate.md`): icon, localized label,
/// chevron affordance, navigating to `TimelineScreen`. This widget has no
/// pairing awareness of its own -- the caller decides whether to mount it at
/// all, gated on P3 `CouplePairingStore.resolve()` returning
/// `PairingStatus.paired` (AC4: unpaired users must not reach the screen).
class TimelineEntryPointCard extends StatelessWidget {
  const TimelineEntryPointCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return Semantics(
      button: true,
      label: l10n.timeline_entry_point_card_label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Container(
          constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
          padding: EdgeInsets.symmetric(
            horizontal: CupidSpacing.md,
            vertical: CupidSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platformTokens.radiusCard),
          ),
          child: Row(
            children: <Widget>[
              ExcludeSemantics(
                child: CupidIcon(
                  TimelineGlyphs.symbolFor('timeline')!,
                  size: 20,
                  color: colors.colorAccentPink,
                ),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Text(
                  l10n.timeline_entry_point_card_label,
                  style: type.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.colorText,
                  ),
                ),
              ),
              ExcludeSemantics(
                child: CupidIcon(
                  CupidIcons.chevronRight,
                  size: 20,
                  color: colors.colorTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
