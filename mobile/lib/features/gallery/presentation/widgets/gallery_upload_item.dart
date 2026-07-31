import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../gallery_upload_state.dart';

/// Builds the item's thumbnail given the picked [file]. Overridable so
/// widget tests never decode a real on-disk image
/// (`coding-plan/phase-P3-gallery-upload.md` Test Scope, mirroring
/// `GalleryTile.imageBuilder`'s seam); defaults to
/// [GalleryUploadItem.defaultThumbnailBuilder], which renders a real
/// `Image.file`.
typedef GalleryUploadThumbnailBuilder =
    Widget Function(BuildContext context, File file);

/// `check_circle` glyph. Material Symbols Rounded kept the same PUA
/// codepoint as legacy Material Icons for this established glyph name; not
/// independently re-verified via a `fontTools` cmap lookup in this phase —
/// flag to mobile visual audit if it renders as a missing-glyph box.
const IconData _checkCircleIcon = IconData(
  0xe86c,
  fontFamily: CupidIcons.fontFamily,
);

/// `refresh` glyph, same sourcing caveat as [_checkCircleIcon] above.
const IconData _refreshIcon = IconData(0xe5d5, fontFamily: CupidIcons.fontFamily);

/// One selected photo's status inside `GalleryUploadSheet`
/// (`ux/uiux-spec.md` §4.3): queued -> uploading (progress ring) -> done
/// (checkmark) -> failed (retry). Every state also exposes a text
/// equivalent (`ux/uiux-spec.md` §7) announced via a live region, so status
/// is never conveyed by ring color/icon alone.
class GalleryUploadItem extends StatelessWidget {
  const GalleryUploadItem({
    super.key,
    required this.record,
    required this.onRetry,
    this.thumbnailBuilder,
  });

  final GalleryUploadRecord record;
  final VoidCallback onRetry;
  final GalleryUploadThumbnailBuilder? thumbnailBuilder;

  static Widget defaultThumbnailBuilder(BuildContext context, File file) {
    return Image.file(file, fit: BoxFit.cover);
  }

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';

  String _statusLabel(BuildContext context) {
    final bool isVi = _isVi(context);
    return switch (record.status) {
      GalleryUploadItemStatus.queued => isVi ? 'Đang chờ tải lên' : 'Queued',
      GalleryUploadItemStatus.uploading => isVi
          ? 'Đang tải lên ${(record.progress * 100).round()}%'
          : 'Uploading ${(record.progress * 100).round()}%',
      GalleryUploadItemStatus.done => isVi ? 'Đã tải lên' : 'Uploaded',
      GalleryUploadItemStatus.failed => isVi
          ? 'Tải lên thất bại, chạm để thử lại'
          : 'Upload failed, tap to retry',
    };
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String statusLabel = _statusLabel(context);
    final bool isFailed = record.status == GalleryUploadItemStatus.failed;

    return Semantics(
      liveRegion: true,
      label: statusLabel,
      button: isFailed,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isFailed ? onRetry : null,
        child: SizedBox(
          key: Key('gallery_upload_item_${record.id}'),
          width: 88,
          height: 88,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(platform.radiusSmall),
            child: Stack(
              fit: StackFit.expand,
              children: [
                (thumbnailBuilder ?? defaultThumbnailBuilder)(
                  context,
                  record.file,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(23, 17, 41, 0.35),
                  ),
                ),
                Center(child: _StatusGlyph(record: record, colors: colors)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(23, 17, 41, 0.6),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: CupidSpacing.xs,
                        vertical: 2,
                      ),
                      child: Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.cupidType.caption.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusGlyph extends StatelessWidget {
  const _StatusGlyph({required this.record, required this.colors});

  final GalleryUploadRecord record;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return switch (record.status) {
      GalleryUploadItemStatus.queued => const SizedBox.shrink(),
      GalleryUploadItemStatus.uploading => SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          value: record.progress > 0 ? record.progress : null,
          color: colors.colorAccentPink,
          strokeWidth: 3,
        ),
      ),
      GalleryUploadItemStatus.done => Icon(
        _checkCircleIcon,
        color: colors.colorMint,
        size: 28,
      ),
      GalleryUploadItemStatus.failed => Icon(
        _refreshIcon,
        color: colors.colorRed,
        size: 28,
      ),
    };
  }
}
