import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/compat_content.dart';

/// "1 hoạt động nên thử" — the cell's activity plus the secondary action that
/// pushes it into the user's own activity store.
///
/// This widget only *emits* [onAddToMyStore]. It does not create a card, does
/// not touch a repository and does not show the undo snackbar; that whole path
/// belongs to P4. Keeping the signal and the effect apart is what lets this
/// phase ship before the screen exists.
///
/// The action is drawn as an outline chip rather than a filled `--grad` pill:
/// per `ux/uiux-spec.md` section 3.4 it is a secondary action, and the filled
/// treatment is reserved for the screen's primary action.
class CompatActivityBlock extends StatelessWidget {
  const CompatActivityBlock({super.key, required this.cell, this.onAddToMyStore});

  final CompatCell cell;
  final VoidCallback? onAddToMyStore;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return DecoratedBox(
      key: const Key('compat_activity_block'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                CupidIcon(
                  CupidIcons.localActivity,
                  variant: CupidIconVariant.line,
                  size: 20,
                  color: colors.colorText,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.compat_block_activity_title,
                    style: type.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.colorText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(cell.activity, style: type.body.copyWith(color: colors.colorText)),
            const SizedBox(height: CupidSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: l10n.compat_add_to_my_store_action,
                excludeSemantics: true,
                child: GestureDetector(
                  key: const Key('compat_activity_add_to_store'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onAddToMyStore,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(platform.radiusButton),
                      border: Border.all(color: colors.colorAccentPurple),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CupidSpacing.md,
                        vertical: CupidSpacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CupidIcon(
                            CupidIcons.add,
                            variant: CupidIconVariant.line,
                            size: 18,
                            color: colors.colorAccentPurple,
                          ),
                          const SizedBox(width: CupidSpacing.xs),
                          // The label is the longest string in the block and
                          // runs past the 415pt reference width at `body` size,
                          // so it wraps inside the chip rather than being cut
                          // or shrunk below the secondary-action type scale.
                          Flexible(
                            child: Text(
                              l10n.compat_add_to_my_store_action,
                              style: type.body.copyWith(
                                fontWeight: FontWeight.w400,
                                color: colors.colorAccentPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
