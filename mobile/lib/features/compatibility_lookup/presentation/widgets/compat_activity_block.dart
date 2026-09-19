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
/// The action is drawn as a round outlined `(+)` rather than a filled `--grad`
/// pill: per `ux/uiux-spec.md` section 3.4 it is a secondary action, and the
/// filled treatment is reserved for the screen's primary action.
class CompatActivityBlock extends StatelessWidget {
  const CompatActivityBlock({super.key, required this.cell, this.onAddToMyStore});

  final CompatCell cell;
  final VoidCallback? onAddToMyStore;

  /// The `(+)` glyph is far smaller than this, but dropping the label also
  /// dropped the chip padding that used to carry the hit area, so the tap
  /// target is restated here (`ux/uiux-spec.md` section 3.4).
  static const double _minTapTarget = 44;
  static const double _addIconSize = 20;

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
                  child: SizedBox(
                    width: _minTapTarget,
                    height: _minTapTarget,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.colorAccentPurple),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(CupidSpacing.xs),
                          child: CupidIcon(
                            CupidIcons.add,
                            variant: CupidIconVariant.line,
                            size: _addIconSize,
                            color: colors.colorAccentPurple,
                          ),
                        ),
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
