import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// `link_off` glyph, confirmed via a `fontTools` cmap lookup on the bundled
/// `MaterialSymbolsRounded-Variable.ttf` (same sourcing rule as
/// `CupidIcons`). Defined locally rather than added to `CupidIcons` because
/// this phase's write scope does not include
/// `design_system/icons/cupid_icons.dart`. Deliberately not `lock`/
/// `fingerprint`: `ux/uiux-spec.md` §4.5 requires this gate to read as an
/// access-state, not an encryption-state.
const IconData _linkOffIcon = IconData(0xe16f, fontFamily: CupidIcons.fontFamily);

/// AC3 gate (`ux/uiux-spec.md` §4.5): shown when `GalleryCubit` resolves
/// `GalleryLocked`. The CTA routes to the pairing/invite flow — never a
/// lock/biometric-unlock affordance, per `architecture/solution.md` §5 D-1.
class GalleryLockedView extends StatelessWidget {
  const GalleryLockedView({super.key, required this.onPairingCta});

  /// Navigates to the pairing/invite flow. Required (no default) so the
  /// screen composing this view must make an explicit routing decision —
  /// see `GalleryScreen`'s doc comment for the current wiring gap.
  final VoidCallback onPairingCta;

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';

  String _viEn(BuildContext context, String vi, String en) =>
      _isVi(context) ? vi : en;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final ctaLabel = _viEn(context, 'Ghép đôi ngay', 'Pair up now');
    final ctaSemanticLabel = _viEn(
      context,
      'Đi đến màn hình ghép đôi',
      'Go to the pairing screen',
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupidIcon(
              _linkOffIcon,
              variant: CupidIconVariant.soft,
              size: 64,
              color: colors.colorTextMuted,
            ),
            SizedBox(height: CupidSpacing.lg),
            Text(
              _viEn(
                context,
                'Ghép đôi để mở Gallery chung',
                'Pair up to unlock the shared gallery',
              ),
              textAlign: TextAlign.center,
              style: context.cupidType.cardTitle.copyWith(
                color: colors.colorText,
              ),
            ),
            SizedBox(height: CupidSpacing.sm),
            Text(
              _viEn(
                context,
                'Gallery ảnh chung chỉ mở khi hai bạn đã ghép đôi.',
                'The shared gallery only unlocks once you and your partner '
                    'are paired.',
              ),
              textAlign: TextAlign.center,
              style: context.cupidType.body.copyWith(
                color: colors.colorTextMuted,
              ),
            ),
            SizedBox(height: CupidSpacing.xl),
            Semantics(
              label: ctaSemanticLabel,
              button: true,
              excludeSemantics: true,
              child: CupidPrimaryButton(
                label: ctaLabel,
                onPressed: onPairingCta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
