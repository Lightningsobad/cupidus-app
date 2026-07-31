import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/gallery_api.dart' show galleryMediaUrl;
import '../../domain/gallery_item.dart';

/// Builds the viewer's full-resolution image widget given the resolved
/// [imageUrl]. Overridable so widget tests never resolve a real network
/// image, mirroring `GalleryTileImageBuilder`
/// (`widgets/gallery_tile.dart`).
typedef GalleryViewerImageBuilder =
    Widget Function(BuildContext context, String imageUrl);

/// One full-screen `gallery-viewer` page (`ux/uiux-spec.md` §4.4, §6):
/// letterboxes (never crops) the photo via `BoxFit.contain` and supports
/// pinch-to-zoom via [InteractiveViewer] — a standard platform gallery
/// affordance built into the Flutter framework, not a new pub dependency.
class GalleryViewerPhoto extends StatelessWidget {
  const GalleryViewerPhoto({super.key, required this.item, this.imageBuilder});

  final GalleryItem item;

  /// Defaults to [defaultImageBuilder]; see [GalleryViewerImageBuilder].
  final GalleryViewerImageBuilder? imageBuilder;

  static Widget defaultImageBuilder(BuildContext context, String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => const SizedBox.shrink(),
      errorWidget: (context, url, error) => const SizedBox.shrink(),
    );
  }

  String _resolvedImageUrl() {
    final String? thumbnailUrl = item.thumbnailUrl;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    }
    return galleryMediaUrl(item.filename);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: (imageBuilder ?? defaultImageBuilder)(
          context,
          _resolvedImageUrl(),
        ),
      ),
    );
  }
}
