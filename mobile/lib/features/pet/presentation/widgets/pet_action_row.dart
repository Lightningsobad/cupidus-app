import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pet_cubit.dart';
import '../pet_strings.dart';

/// Feed/Play action row (`ux/uiux-spec.md` §2.1 item 3, §5 Open Item 1):
/// fixed 2-up row, both buttons calling the single
/// `context.read<PetCubit>().interact()` — there is no separate feed/play
/// backend effect (`architecture/solution.md` §1). Both buttons disable
/// while [cooldownRemaining] is non-null so a double-tap never reaches the
/// network, and expose that via `Semantics(enabled: false)` plus a
/// live-region announcement (`ux/uiux-spec.md` §7) instead of a silent
/// no-op tap.
class PetActionRow extends StatelessWidget {
  const PetActionRow({super.key, required this.cooldownRemaining});

  final Duration? cooldownRemaining;

  @override
  Widget build(BuildContext context) {
    final bool onCooldown = cooldownRemaining != null;
    final CupidColorTokens colors = context.cupidColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: CupidIcons.restaurant,
                label: context.viEn('Cho ăn', 'Feed'),
                semanticsLabel: context.viEn('Cho Bún ăn', 'Feed Bun'),
                disabled: onCooldown,
                primary: true,
                onTap: () => context.read<PetCubit>().interact(),
              ),
            ),
            SizedBox(width: CupidSpacing.sm),
            Expanded(
              child: _ActionButton(
                icon: CupidIcons.sportsEsports,
                label: context.viEn('Chơi cùng', 'Play'),
                semanticsLabel: context.viEn(
                  'Chơi cùng Bún',
                  'Play with Bun',
                ),
                disabled: onCooldown,
                primary: false,
                onTap: () => context.read<PetCubit>().interact(),
              ),
            ),
          ],
        ),
        if (onCooldown) ...[
          SizedBox(height: CupidSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              context.viEn(
                'Vui lòng đợi một chút',
                'Please wait a moment',
              ),
              textAlign: TextAlign.center,
              style: context.cupidType.caption.copyWith(
                color: colors.colorTextMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.disabled,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final bool disabled;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final Widget button = Container(
      height: platformTokens.tapTarget,
      decoration: BoxDecoration(
        gradient: primary ? colors.gradientHot : null,
        color: primary ? null : colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
        boxShadow: primary ? colors.glowShadow : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupidIcon(
            icon,
            size: 20,
            color: primary ? colors.colorText : colors.colorAccentPink,
          ),
          SizedBox(width: CupidSpacing.xs),
          Text(
            label,
            style: context.cupidType.body.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.colorText,
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Semantics(
        button: true,
        enabled: !disabled,
        label: semanticsLabel,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: button,
        ),
      ),
    );
  }
}
