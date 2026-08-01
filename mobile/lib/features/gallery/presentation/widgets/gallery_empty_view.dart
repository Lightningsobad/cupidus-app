import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// `add_photo_alternate` glyph, confirmed via a `fontTools` cmap lookup on
/// the bundled `MaterialSymbolsRounded-Variable.ttf` (same sourcing rule as
/// `CupidIcons`). Defined locally rather than added to `CupidIcons` because
/// this phase's write scope does not include
/// `design_system/icons/cupid_icons.dart`.
const IconData _addPhotoAlternateIcon = IconData(
  0xe43e,
  fontFamily: CupidIcons.fontFamily,
);

/// First-run empty state (`ux/uiux-spec.md` §4.1): shown when
/// `GalleryCubit` resolves `GalleryEmpty` for a paired user with zero
/// photos yet.
class GalleryEmptyView extends StatelessWidget {
  const GalleryEmptyView({super.key, required this.onAddPhoto});

  /// Opens the upload flow (wired to the real destination by P3).
  final VoidCallback onAddPhoto;

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';

  String _viEn(BuildContext context, String vi, String en) =>
      _isVi(context) ? vi : en;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.2,
              child: CupidIcon(
                _addPhotoAlternateIcon,
                variant: CupidIconVariant.soft,
                size: 96,
                color: colors.colorTextMuted,
              ),
            ),
            SizedBox(height: CupidSpacing.lg),
            Text(
              _viEn(context, 'Chưa có ảnh nào', 'No photos yet'),
              textAlign: TextAlign.center,
              style: context.cupidType.cardTitle.copyWith(
                color: colors.colorText,
              ),
            ),
            SizedBox(height: CupidSpacing.sm),
            Text(
              _viEn(
                context,
                'Thêm khoảnh khắc đầu tiên của hai bạn',
                'Add your first moment together',
              ),
              textAlign: TextAlign.center,
              style: context.cupidType.body.copyWith(
                color: colors.colorTextMuted,
              ),
            ),
            SizedBox(height: CupidSpacing.xl),
            Semantics(
              label: _viEn(
                context,
                'Thêm ảnh đầu tiên',
                'Add your first photo',
              ),
              button: true,
              excludeSemantics: true,
              child: CupidAddAction(onPressed: onAddPhoto),
            ),
          ],
        ),
      ),
    );
  }
}
