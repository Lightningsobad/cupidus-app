import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../pet_strings.dart';

/// Shared lock-icon-in-gradient-circle empty-state shell
/// (`ux/uiux-spec.md` §8: reuse the Private Gallery locked pattern verbatim
/// for any pairing-gated feature). [headline] is exposed as the screen's
/// accessible title (`ux/uiux-spec.md` §7) so a screen-reader user landing on
/// the `pet` tab immediately understands why no pet content is shown.
class _GuardStateShell extends StatelessWidget {
  const _GuardStateShell({
    required this.icon,
    required this.headline,
    this.cta,
  });

  final IconData icon;
  final String headline;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: EdgeInsets.all(CupidSpacing.lg),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: colors.gradientDream,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CupidIcon(icon, size: 36, color: colors.colorText),
            ),
          ),
          SizedBox(height: CupidSpacing.md),
          Semantics(
            header: true,
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: context.cupidType.cardTitle.copyWith(
                color: colors.colorText,
              ),
            ),
          ),
          if (cta != null) ...[SizedBox(height: CupidSpacing.md), cta!],
        ],
      ),
    );
  }
}

/// AC3 unpaired hard gate (`ux/uiux-spec.md` §2.3): no adopt CTA, no
/// interact affordance, no route into the adopt sheet.
class PetLockedCard extends StatelessWidget {
  const PetLockedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _GuardStateShell(
      icon: CupidIcons.lock,
      headline: context.petLockedHeadline,
    );
  }
}

/// Paired, but no pet adopted yet (`ux/uiux-spec.md` §2.2 item 1). [onAdopt]
/// is wired by P7 to open the adopt sheet.
class PetAdoptPromptCard extends StatelessWidget {
  const PetAdoptPromptCard({super.key, required this.onAdopt});

  final VoidCallback onAdopt;

  @override
  Widget build(BuildContext context) {
    return _GuardStateShell(
      icon: CupidIcons.pets,
      headline: context.petAdoptHeadline,
      cta: CupidPrimaryButton(
        label: context.petAdoptCta,
        onPressed: onAdopt,
      ),
    );
  }
}
