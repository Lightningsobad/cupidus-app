import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_empty_view.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_grid_columns.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_grid_view.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Never resolves a real network image
/// (`coding-plan/phase-P2-gallery-grid.md` Test Scope): records the
/// `memCacheWidth` `GalleryTile` computed for the tile instead of building a
/// `CachedNetworkImage`.
GalleryTileImageBuilder _capturingImageBuilder(List<int> capturedWidths) {
  return (context, imageUrl, memCacheWidth) {
    capturedWidths.add(memCacheWidth);
    return const ColoredBox(color: Colors.transparent);
  };
}

GalleryItem _item(String id, {String userId = 'me-1', DateTime? createdAt}) {
  return GalleryItem(
    id: id,
    userId: userId,
    filename: '$id.jpg',
    createdAt: createdAt ?? DateTime.utc(2026, 7, 30),
  );
}

Widget _wrap(Widget child, {double width = 400, double height = 700}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, height), devicePixelRatio: 1),
      child: Scaffold(body: SizedBox(width: width, height: height, child: child)),
    ),
  );
}

void main() {
  group('galleryColumnCount', () {
    test('returns 2 just below the 430dp boundary', () {
      expect(galleryColumnCount(429.99), 2);
    });

    test('returns 3 at and above the 430dp boundary', () {
      expect(galleryColumnCount(430), 3);
      expect(galleryColumnCount(600), 3);
    });

    test('returns 2 at small phone widths', () {
      expect(galleryColumnCount(360), 2);
    });
  });

  group('GalleryTile', () {
    testWidgets(
      'caps memCacheWidth at 640 and never leaves it null (R4)',
      (tester) async {
        final capturedWidths = <int>[];
        await tester.pumpWidget(
          _wrap(
            GalleryTile(
              item: _item('item-1'),
              currentUserId: 'me-1',
              imageBuilder: _capturingImageBuilder(capturedWidths),
            ),
            width: 2000,
            height: 2000,
          ),
        );

        expect(capturedWidths, hasLength(1));
        expect(capturedWidths.single, lessThanOrEqualTo(640));
      },
    );

    testWidgets(
      'exposes a semantic label combining date and uploader (UX §7)',
      (tester) async {
        final capturedWidths = <int>[];
        await tester.pumpWidget(
          _wrap(
            GalleryTile(
              item: _item(
                'item-1',
                userId: 'me-1',
                createdAt: DateTime.utc(2026, 2, 14),
              ),
              currentUserId: 'me-1',
              imageBuilder: _capturingImageBuilder(capturedWidths),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Photo from you.*Feb 14, 2026')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders the partner badge variant when userId differs from '
      'currentUserId, and the self variant when it matches',
      (tester) async {
        final capturedWidths = <int>[];

        await tester.pumpWidget(
          _wrap(
            GalleryTile(
              item: _item('item-1', userId: 'partner-1'),
              currentUserId: 'me-1',
              imageBuilder: _capturingImageBuilder(capturedWidths),
            ),
          ),
        );
        expect(
          find.byKey(const Key('gallery_tile_badge_partner')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('gallery_tile_badge_self')),
          findsNothing,
        );

        await tester.pumpWidget(
          _wrap(
            GalleryTile(
              item: _item('item-1', userId: 'me-1'),
              currentUserId: 'me-1',
              imageBuilder: _capturingImageBuilder(capturedWidths),
            ),
          ),
        );
        expect(
          find.byKey(const Key('gallery_tile_badge_self')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('gallery_tile_badge_partner')),
          findsNothing,
        );
      },
    );

    testWidgets('an onTap callback fires when the tile is tapped', (
      tester,
    ) async {
      final capturedWidths = <int>[];
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          GalleryTile(
            item: _item('item-1'),
            currentUserId: 'me-1',
            onTap: () => tapped = true,
            imageBuilder: _capturingImageBuilder(capturedWidths),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });

  group('GalleryEmptyView', () {
    testWidgets(
      'renders the empty-state copy and wires the add-photo CTA',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          _wrap(GalleryEmptyView(onAddPhoto: () => tapped = true)),
        );

        expect(find.text('No photos yet'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Add your first photo'),
          findsOneWidget,
        );

        await tester.tap(find.byType(CupidAddAction));
        expect(tapped, isTrue);
      },
    );
  });

  group('GalleryGridView', () {
    List<GalleryItem> items(int count) =>
        List.generate(count, (i) => _item('item-$i'));

    testWidgets('pins the add-photo tile as the last cell, never the first', (
      tester,
    ) async {
      final capturedWidths = <int>[];
      await tester.pumpWidget(
        _wrap(
          GalleryGridView(
            items: items(4),
            currentUserId: 'me-1',
            onTileTap: (_) {},
            onAddPhoto: () {},
            onRefresh: () async {},
            onLoadMore: () {},
            tileImageBuilder: _capturingImageBuilder(capturedWidths),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('gallery_add_tile')), findsOneWidget);
      expect(find.byType(GalleryTile), findsNWidgets(4));

      final double addTileTop = tester
          .getTopLeft(find.byKey(const Key('gallery_add_tile')))
          .dy;
      final Iterable<double> tileTops = tester
          .widgetList<GalleryTile>(find.byType(GalleryTile))
          .map(
            (tile) => tester.getTopLeft(find.byWidget(tile)).dy,
          );
      expect(tileTops.every((top) => top < addTileTop), isTrue);
    });

    testWidgets(
      'reaching the tail triggers exactly one onLoadMore() call, not one '
      'per frame',
      (tester) async {
        final capturedWidths = <int>[];
        int loadMoreCalls = 0;
        await tester.pumpWidget(
          _wrap(
            GalleryGridView(
              items: items(30),
              currentUserId: 'me-1',
              hasMore: true,
              onTileTap: (_) {},
              onAddPhoto: () {},
              onRefresh: () async {},
              onLoadMore: () => loadMoreCalls++,
              tileImageBuilder: _capturingImageBuilder(capturedWidths),
            ),
            width: 400,
            height: 700,
          ),
        );
        await tester.pump();
        expect(loadMoreCalls, 0);

        await tester.fling(
          find.byType(GridView),
          const Offset(0, -20000),
          3000,
        );
        await tester.pumpAndSettle();

        expect(loadMoreCalls, 1);

        // Further settling frames must not issue a second call.
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
        expect(loadMoreCalls, 1);
      },
    );

    testWidgets(
      'does not request another page while isLoadingMore is already true',
      (tester) async {
        final capturedWidths = <int>[];
        int loadMoreCalls = 0;
        await tester.pumpWidget(
          _wrap(
            GalleryGridView(
              items: items(30),
              currentUserId: 'me-1',
              hasMore: true,
              isLoadingMore: true,
              onTileTap: (_) {},
              onAddPhoto: () {},
              onRefresh: () async {},
              onLoadMore: () => loadMoreCalls++,
              tileImageBuilder: _capturingImageBuilder(capturedWidths),
            ),
            width: 400,
            height: 700,
          ),
        );
        // `isLoadingMore` renders an infinitely-repeating shimmer animation
        // (`gallery_grid_view.dart`'s `_GalleryShimmerTile`), so `pumpAndSettle`
        // never settles here; pump explicit frames instead.
        await tester.fling(
          find.byType(GridView),
          const Offset(0, -20000),
          3000,
        );
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));

        expect(loadMoreCalls, 0);
      },
    );

    testWidgets('tapping a tile reports its index via onTileTap', (
      tester,
    ) async {
      final capturedWidths = <int>[];
      int? tappedIndex;
      await tester.pumpWidget(
        _wrap(
          GalleryGridView(
            items: items(2),
            currentUserId: 'me-1',
            onTileTap: (index) => tappedIndex = index,
            onAddPhoto: () {},
            onRefresh: () async {},
            onLoadMore: () {},
            tileImageBuilder: _capturingImageBuilder(capturedWidths),
          ),
        ),
      );

      await tester.tap(find.byType(GalleryTile).first);
      expect(tappedIndex, 0);
    });

    testWidgets('tapping the add tile calls onAddPhoto', (tester) async {
      final capturedWidths = <int>[];
      bool addTapped = false;
      await tester.pumpWidget(
        _wrap(
          GalleryGridView(
            items: items(2),
            currentUserId: 'me-1',
            onTileTap: (_) {},
            onAddPhoto: () => addTapped = true,
            onRefresh: () async {},
            onLoadMore: () {},
            tileImageBuilder: _capturingImageBuilder(capturedWidths),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('gallery_add_tile')));
      expect(addTapped, isTrue);
    });

    testWidgets(
      'every rendered tile passes a non-null memCacheWidth no greater than '
      '640 (R4)',
      (tester) async {
        final capturedWidths = <int>[];
        await tester.pumpWidget(
          _wrap(
            GalleryGridView(
              items: items(4),
              currentUserId: 'me-1',
              onTileTap: (_) {},
              onAddPhoto: () {},
              onRefresh: () async {},
              onLoadMore: () {},
              tileImageBuilder: _capturingImageBuilder(capturedWidths),
            ),
          ),
        );
        await tester.pump();

        expect(capturedWidths, hasLength(4));
        for (final width in capturedWidths) {
          expect(width, lessThanOrEqualTo(640));
        }
      },
    );
  });
}
