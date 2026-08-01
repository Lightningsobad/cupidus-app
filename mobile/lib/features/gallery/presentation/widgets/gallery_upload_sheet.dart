import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/design_system.dart';
import '../gallery_upload_cubit.dart';
import '../gallery_upload_state.dart';
import 'gallery_upload_item.dart';

/// Bottom sheet host for the multi-select upload flow
/// (`ux/uiux-spec.md` §4.3): an `r-sheet` (28px, [CupidPlatformTokens.
/// radiusSheet]) modal with a horizontal strip of selected thumbnails.
/// Dismissible mid-upload — [cubit] keeps running after the sheet closes,
/// so uploads continue in the background per §4.3's "dismissible mid-
/// upload" note; the caller (not this widget) owns the [cubit]'s lifetime
/// and its `onUploaded` wiring into `GalleryCubit.insertOptimistic`, since
/// that requires the enclosing gallery screen's context (out of this
/// phase's write scope — see `coding-plan/master-plan.md` §5 P3 row).
class GalleryUploadSheet extends StatelessWidget {
  const GalleryUploadSheet({
    super.key,
    required this.cubit,
    this.thumbnailBuilder,
  });

  final GalleryUploadCubit cubit;
  final GalleryUploadThumbnailBuilder? thumbnailBuilder;

  /// Opens this sheet with the `r-sheet` corner radius and starts picking
  /// immediately, matching the flow map's "pick photo(s) from device
  /// library" step (`ux/uiux-spec.md` §3).
  static Future<void> show(BuildContext context, {required GalleryUploadCubit cubit}) {
    final CupidPlatformTokens platform = context.cupidPlatform;
    cubit.pick();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(platform.radiusSheet),
        ),
      ),
      builder: (_) => GalleryUploadSheet(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GalleryUploadCubit>.value(
      value: cubit,
      child: _GalleryUploadSheetBody(thumbnailBuilder: thumbnailBuilder),
    );
  }
}

class _GalleryUploadSheetBody extends StatelessWidget {
  const _GalleryUploadSheetBody({this.thumbnailBuilder});

  final GalleryUploadThumbnailBuilder? thumbnailBuilder;

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final bool isVi = _isVi(context);

    return BlocBuilder<GalleryUploadCubit, GalleryUploadState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVi ? 'Thêm ảnh' : 'Add photos',
                  style: context.cupidType.cardTitle.copyWith(
                    color: colors.colorText,
                  ),
                ),
                SizedBox(height: CupidSpacing.md),
                if (state.isOffline)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      key: const Key('gallery_upload_offline_message'),
                      width: double.infinity,
                      padding: EdgeInsets.all(CupidSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.colorSurfaceAlt,
                        borderRadius: BorderRadius.circular(
                          platform.radiusSmall,
                        ),
                      ),
                      child: Text(
                        isVi
                            ? 'Không có kết nối mạng. Vui lòng thử lại khi có '
                                  'mạng.'
                            : "No connection. Try again once you're back "
                                  'online.',
                        style: context.cupidType.body.copyWith(
                          color: colors.colorTextMuted,
                        ),
                      ),
                    ),
                  )
                else if (state.items.isEmpty)
                  Text(
                    isVi
                        ? 'Chọn ảnh từ thư viện của bạn'
                        : 'Choose photos from your library',
                    style: context.cupidType.body.copyWith(
                      color: colors.colorTextMuted,
                    ),
                  )
                else
                  SizedBox(
                    key: const Key('gallery_upload_item_strip'),
                    height: 88,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final record in state.items)
                          Padding(
                            padding: EdgeInsets.only(right: CupidSpacing.sm),
                            child: GalleryUploadItem(
                              key: ValueKey(record.id),
                              record: record,
                              onRetry: () => context
                                  .read<GalleryUploadCubit>()
                                  .retry(record.id),
                              thumbnailBuilder: thumbnailBuilder,
                            ),
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: CupidSpacing.lg),
                Semantics(
                  label: isVi
                      ? 'Chọn ảnh từ thư viện'
                      : 'Pick photos from library',
                  button: true,
                  excludeSemantics: true,
                  child: CupidPrimaryButton(
                    label: isVi ? 'Chọn ảnh' : 'Pick photos',
                    onPressed: state.isOffline
                        ? null
                        : () => context.read<GalleryUploadCubit>().pick(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
