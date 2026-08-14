import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar_amount_format.dart';
import '../dream_jar_strings.dart';

/// The 3 fixed VND presets confirmed for v1 (`ux/uiux-spec.md` §1.1; the 4th
/// "custom amount" tile is an unresolved Product Owner flag, not in scope).
const List<num> _presetAmounts = <num>[100000, 200000, 500000];

/// STORY-027 quick-add section, transcribed from the locked design source's
/// `jar` screen. It sits below the hero card as its own section, not inside
/// it, and each tile pairs a `savings`/`volunteer_activism` glyph with the
/// compact amount label.
class DreamJarQuickAddSection extends StatelessWidget {
  const DreamJarQuickAddSection({
    super.key,
    required this.enabled,
    required this.onQuickAdd,
  });

  final bool enabled;
  final ValueChanged<num> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DreamJarStrings.quickAddPrompt(context),
          textAlign: TextAlign.center,
          style: type.caption.copyWith(
            fontSize: 12.5,
            color: colors.colorTextMuted,
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            for (int i = 0; i < _presetAmounts.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _QuickAddTile(
                  amount: _presetAmounts[i],
                  isEmphasized: i == _presetAmounts.length - 1,
                  // The design alternates the first two tiles' glyph colour.
                  iconColor: i == 0 ? colors.colorButter : colors.colorMint,
                  enabled: enabled,
                  onTap: () => onQuickAdd(_presetAmounts[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.amount,
    required this.isEmphasized,
    required this.iconColor,
    required this.enabled,
    required this.onTap,
  });

  final num amount;
  final bool isEmphasized;
  final Color iconColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    final Color foreground = isEmphasized
        ? DreamJarPalette.onHeroText
        : colors.colorText;
    final BorderRadius radius = BorderRadius.circular(22);

    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.dream_jar_quick_add_semantic_label(
        DreamJarAmountFormat.vnd(amount),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isEmphasized ? null : colors.colorSurface,
          gradient: isEmphasized ? colors.gradientHot : null,
          borderRadius: radius,
          boxShadow: isEmphasized
              ? colors.glowShadow
              : context.cupidPlatform.elevationShadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 13,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupidIcon(
                      isEmphasized
                          ? CupidIcons.volunteerActivism
                          : CupidIcons.savings,
                      size: 20,
                      color: isEmphasized ? foreground : iconColor,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '+${DreamJarAmountFormat.compact(amount)}',
                      style: type.caption.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
