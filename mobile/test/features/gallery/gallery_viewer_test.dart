import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_api.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/screens/gallery_viewer_screen.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_grid_view.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_tile.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_viewer_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GalleryItem _item(String id, {String userId = 'me-1', DateTime? createdAt}) {
  return GalleryItem(
    id: id,
    userId: userId,
    filename: '$id.jpg',
    createdAt: createdAt ?? DateTime.utc(2026, 7, 30),
  );
}

/// Never resolves a real network image (mirrors
/// `gallery_grid_test.dart`'s `_capturingImageBuilder`): renders the
/// resolved image URL as text so tests can assert which photo is displayed.
GalleryViewerImageBuilder _textImageBuilder() {
  return (context, imageUrl) => Text(imageUrl);
}

Widget _wrapViewer(Widget child) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: child,
  );
}

void main() {
  group('GalleryViewerScreen', () {
    testWidgets('renders the photo at initialIndex', (tester) async {
      final items = [_item('item-0'), _item('item-1'), _item('item-2')];
      await tester.pumpWidget(
        _wrapViewer(
          GalleryViewerScreen(
            items: items,
            currentUserId: 'me-1',
            initialIndex: 1,
            photoImageBuilder: _textImageBuilder(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(galleryMediaUrl('item-1.jpg')), findsOneWidget);
      expect(find.text(galleryMediaUrl('item-0.jpg')), findsNothing);
    });

    testWidgets('swiping horizontally pages to the next/previous photo', (
      tester,
    ) async {
      final items = [_item('item-0'), _item('item-1'), _item('item-2')];
      await tester.pumpWidget(
        _wrapViewer(
          GalleryViewerScreen(
            items: items,
            currentUserId: 'me-1',
            initialIndex: 0,
            photoImageBuilder: _textImageBuilder(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(galleryMediaUrl('item-0.jpg')), findsOneWidget);

      await tester.fling(
        find.byKey(const Key('gallery_viewer_page_view')),
        const Offset(-400, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text(galleryMediaUrl('item-1.jpg')), findsOneWidget);
      expect(find.text(galleryMediaUrl('item-0.jpg')), findsNothing);

      await tester.fling(
        find.byKey(const Key('gallery_viewer_page_view')),
        const Offset(400, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text(galleryMediaUrl('item-0.jpg')), findsOneWidget);
    });

    testWidgets('the next/previous on-screen buttons also page the viewer', (
      tester,
    ) async {
      final items = [_item('item-0'), _item('item-1')];
      await tester.pumpWidget(
        _wrapViewer(
          GalleryViewerScreen(
            items: items,
            currentUserId: 'me-1',
            initialIndex: 0,
            photoImageBuilder: _textImageBuilder(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('gallery_viewer_previous_button')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('gallery_viewer_next_button')));
      await tester.pumpAndSettle();

      expect(find.text(galleryMediaUrl('item-1.jpg')), findsOneWidget);
    });

    testWidgets('tapping close pops back to the previous route', (
      tester,
    ) async {
      final items = [_item('item-0')];
      await tester.pumpWidget(
        _wrapViewer(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GalleryViewerScreen(
                        items: items,
                        currentUserId: 'me-1',
                        initialIndex: 0,
                        photoImageBuilder: _textImageBuilder(),
                      ),
                    ),
                  ),
                  child: const Text('Open viewer'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open viewer'));
      await tester.pumpAndSettle();
      expect(find.byType(GalleryViewerScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('gallery_viewer_close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GalleryViewerScreen), findsNothing);
      expect(find.text('Open viewer'), findsOneWidget);
    });
  });

  group('GalleryGridView wired to GalleryViewerScreen (as in gallery_screen.dart)', () {
    testWidgets(
      'tapping a tile opens the viewer at the tapped photo index',
      (tester) async {
        final items = [_item('item-0'), _item('item-1'), _item('item-2')];

        await tester.pumpWidget(
          _wrapViewer(
            Builder(
              builder: (context) => Scaffold(
                body: GalleryGridView(
                  items: items,
                  currentUserId: 'me-1',
                  onTileTap: (index) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GalleryViewerScreen(
                        items: items,
                        currentUserId: 'me-1',
                        initialIndex: index,
                        photoImageBuilder: _textImageBuilder(),
                      ),
                    ),
                  ),
                  onAddPhoto: () {},
                  onRefresh: () async {},
                  onLoadMore: () {},
                  tileImageBuilder: (context, imageUrl, memCacheWidth) =>
                      const ColoredBox(color: Colors.transparent),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(GalleryTile).at(1));
        await tester.pumpAndSettle();

        expect(find.byType(GalleryViewerScreen), findsOneWidget);
        expect(find.text(galleryMediaUrl('item-1.jpg')), findsOneWidget);

        await tester.tap(find.byKey(const Key('gallery_viewer_close_button')));
        await tester.pumpAndSettle();

        expect(find.byType(GalleryViewerScreen), findsNothing);
        expect(find.byType(GalleryGridView), findsOneWidget);
      },
    );
  });
}
