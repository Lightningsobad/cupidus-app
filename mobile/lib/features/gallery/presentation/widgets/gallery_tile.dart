import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../../data/gallery_api.dart' show galleryMediaUrl;
import '../../domain/gallery_item.dart';

/// Builds the tile's image widget given the resolved [imageUrl] and the
/// R4-mandated [memCacheWidth] decode cap (`architecture/solution.md` §5
/// D-2). Overridable so widget tests never resolve a real network image
/// (`coding-plan/phase-P2-gallery-grid.md` Test Scope); defaults to
/// [GalleryTile.defaultImageBuilder], which renders the real
/// [CachedNetworkImage].
typedef GalleryTileImageBuilder =
    Widget Function(BuildContext context, String imageUrl, int memCacheWidth);

/// One shared-gallery grid cell (`ux/uiux-spec.md` §4.2): a fixed
/// `3:4`-aspect photo with a date caption chip and an uploader-initial badge
/// distinguishing the current user's own uploads from their partner's.
class GalleryTile extends StatelessWidget {
  const GalleryTile({
    super.key,
    required this.item,
    required this.currentUserId,
    this.onTap,
    this.imageBuilder,
  });

  final GalleryItem item;
  final String currentUserId;
  final VoidCallback? onTap;

  /// Defaults to [defaultImageBuilder]; see [GalleryTileImageBuilder].
  final GalleryTileImageBuilder? imageBuilder;

  /// R4 decode budget: no tile ever requests more than 640 physical pixels
  /// of width from the image codec (`architecture/solution.md` §5 D-2).
  static const int maxDecodeWidth = 640;

  static Widget defaultImageBuilder(
    BuildContext context,
    String imageUrl,
    int memCacheWidth,
  ) {
    final CupidColorTokens colors = context.cupidColors;
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheWidth: memCacheWidth,
      placeholder: (context, url) => ColoredBox(color: colors.colorSurfaceAlt),
      errorWidget: (context, url, error) =>
          ColoredBox(color: colors.colorSurfaceAlt),
    );
  }

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';

  String _resolvedImageUrl() {
    final String? thumbnailUrl = item.thumbnailUrl;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    }
    return galleryMediaUrl(item.filename);
  }

  String _dateLabel(BuildContext context) => DateFormat.yMMMd(
    Localizations.localeOf(context).toString(),
  ).format(item.createdAt);

  String _semanticsLabel(BuildContext context, {required bool isSelf}) {
    final String date = _dateLabel(context);
    final bool isVi = _isVi(context);
    if (isVi) {
      return isSelf ? 'Ảnh của bạn, $date' : 'Ảnh của đối tác, $date';
    }
    return isSelf ? 'Photo from you, $date' : 'Photo from your partner, $date';
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final bool isSelf = item.userId == currentUserId;
    final String imageUrl = _resolvedImageUrl();

    return Semantics(
      label: _semanticsLabel(context, isSelf: isSelf),
      image: true,
      button: onTap != null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(platform.radiusSmall),
          child: DecoratedBox(
            decoration: BoxDecoration(boxShadow: colors.glowShadow),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double devicePixelRatio =
                      MediaQuery.devicePixelRatioOf(context);
                  final int memCacheWidth = min(
                    maxDecodeWidth,
                    (constraints.maxWidth * devicePixelRatio).round(),
                  );
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      (imageBuilder ?? defaultImageBuilder)(
                        context,
                        imageUrl,
                        memCacheWidth,
                      ),
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
                              horizontal: CupidSpacing.sm,
                              vertical: CupidSpacing.xs,
                            ),
                            child: Text(
                              _dateLabel(context),
                              style: context.cupidType.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: CupidSpacing.xs,
                        right: CupidSpacing.xs,
                        child: _UploaderBadge(isSelf: isSelf),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 24px avatar-initial badge distinguishing the tile's uploader
/// (`ux/uiux-spec.md` §4.2): the current user's own uploads get
/// [CupidColorTokens.colorAccentPink], the partner's get
/// [CupidColorTokens.colorAccentPurple], so both partners' contributions
/// stay visually distinguishable in the shared grid (AC2).
class _UploaderBadge extends StatelessWidget {
  const _UploaderBadge({required this.isSelf});

  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final bool isVi =
        Localizations.localeOf(context).languageCode == 'vi';
    final String initial = isSelf
        ? (isVi ? 'B' : 'Y')
        : (isVi ? 'Đ' : 'P');
    return Container(
      key: isSelf
          ? const Key('gallery_tile_badge_self')
          : const Key('gallery_tile_badge_partner'),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelf ? colors.colorAccentPink : colors.colorAccentPurple,
      ),
      child: Text(
        initial,
        style: context.cupidType.labelMono.copyWith(
          fontSize: 12,
          color: colors.colorText,
        ),
      ),
    );
  }
}
