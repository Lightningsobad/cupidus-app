// Not a test. This is a `flutter run -t` entrypoint used to capture the
// implemented shared-gallery grid from a device for STORY-026's
// visual-fidelity evidence. It renders `GalleryGridView` directly with a
// local image builder so the tile chrome under audit (shadow, corner radius,
// caption pill, uploader badge, dashed add tile) renders without a backend,
// a paired couple, or the service locator.
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Stand-in for the design source's `<image-slot>` photo placeholders. The
/// photo bitmap itself is not one of this story's audit dimensions; the tile
/// chrome painted over it is.
Widget _placeholderImage(BuildContext context, String imageUrl, int _) {
  final CupidColorTokens colors = context.cupidColors;
  final List<LinearGradient> fills = <LinearGradient>[
    colors.gradientDream,
    colors.gradientHot,
  ];
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: fills[imageUrl.hashCode.abs() % fills.length],
    ),
  );
}

GalleryItem _item(String id, String userId, DateTime createdAt) => GalleryItem(
  id: id,
  userId: userId,
  filename: '$id.jpg',
  createdAt: createdAt,
);

void main() {
  final List<GalleryItem> items = <GalleryItem>[
    _item('a', 'me-1', DateTime.utc(2026, 2, 14)),
    _item('b', 'partner-1', DateTime.utc(2026, 3, 2)),
    _item('c', 'me-1', DateTime.utc(2026, 4, 19)),
  ];

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      // The global delegates are what initialize `intl` date-symbol data for
      // 'vi'; without them `GalleryTile`'s `DateFormat.yMMMd('vi')` throws and
      // every tile renders as a bare release-mode ErrorWidget.
      locale: const Locale('vi'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const <Locale>[Locale('vi'), Locale('en')],
      home: Scaffold(
        appBar: const CupidHeader(title: 'Gallery chung'),
        body: GalleryGridView(
          items: items,
          currentUserId: 'me-1',
          onTileTap: (_) {},
          onAddPhoto: () {},
          onRefresh: () async {},
          onLoadMore: () {},
          tileImageBuilder: _placeholderImage,
        ),
      ),
    ),
  );
}
