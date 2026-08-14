import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_grid_view.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-026 design-fidelity assertions against `cupid-app-design-system`'s
/// canvas screen `gallery`, `<sc-if value="{{ galleryOpen }}">` block
/// (`Cupid Screens.dc.html` L736-750).
GalleryTileImageBuilder _stubImage() =>
    (context, imageUrl, memCacheWidth) =>
        const ColoredBox(color: Color.fromRGBO(0, 0, 0, 1));

GalleryItem _item(String id, {String userId = 'me-1'}) => GalleryItem(
  id: id,
  userId: userId,
  filename: '$id.jpg',
  createdAt: DateTime.utc(2026, 2, 14),
);

Widget _wrap(Widget child, {double width = 400, double height = 700}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, height), devicePixelRatio: 1),
      child: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
}

Widget _grid({int count = 3}) => GalleryGridView(
  items: List.generate(count, (i) => _item('item-$i')),
  currentUserId: 'me-1',
  onTileTap: (_) {},
  onAddPhoto: () {},
  onRefresh: () async {},
  onLoadMore: () {},
  tileImageBuilder: _stubImage(),
);

void main() {
  const CupidPlatformTokens platform = CupidPlatformTokens.material();
  const CupidColorTokens colors = CupidColorTokens.dark();

  group('gallery grid frame', () {
    testWidgets('uses the design source padding 8px 16px 40px', (tester) async {
      await tester.pumpWidget(_wrap(_grid()));
      await tester.pump();

      final GridView grid = tester.widget<GridView>(find.byType(GridView));
      expect(
        grid.padding,
        const EdgeInsets.fromLTRB(
          CupidSpacing.md,
          CupidSpacing.sm,
          CupidSpacing.md,
          CupidSpacing.xl,
        ),
      );
    });
  });

  group('gallery tile', () {
    testWidgets(
      'carries --shadow (elevationShadow), not --glow, and paints it outside '
      'the corner clip so it is not clipped away',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            GalleryTile(
              item: _item('item-1'),
              currentUserId: 'me-1',
              imageBuilder: _stubImage(),
            ),
          ),
        );

        final Finder shadowBox = find.ancestor(
          of: find.byType(ClipRRect),
          matching: find.byType(DecoratedBox),
        );
        final BoxDecoration decoration =
            tester.widget<DecoratedBox>(shadowBox.first).decoration
                as BoxDecoration;

        expect(decoration.boxShadow, platform.elevationShadow);
        expect(decoration.boxShadow, isNot(colors.glowShadow));
        expect(
          decoration.borderRadius,
          BorderRadius.circular(platform.radiusSmall),
        );
      },
    );

    testWidgets(
      'renders the date caption as an inset pill at left/bottom 9px, not a '
      'full-bleed bottom bar',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            GalleryTile(
              item: _item('item-1'),
              currentUserId: 'me-1',
              imageBuilder: _stubImage(),
            ),
          ),
        );

        final Positioned chip = tester.widget<Positioned>(
          find
              .ancestor(
                of: find.text('Feb 14, 2026'),
                matching: find.byType(Positioned),
              )
              .first,
        );
        expect(chip.left, CupidSpacing.sm);
        expect(chip.bottom, CupidSpacing.sm);
        expect(chip.right, isNull);

        final BoxDecoration decoration =
            tester
                    .widget<DecoratedBox>(
                      find
                          .ancestor(
                            of: find.text('Feb 14, 2026'),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(
          decoration.borderRadius,
          BorderRadius.circular(platform.radiusButton),
        );
        expect(decoration.color, const Color.fromRGBO(23, 17, 41, 0.6));
      },
    );

    testWidgets('captions the date in Roboto Mono at the design 9px size', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          GalleryTile(
            item: _item('item-1'),
            currentUserId: 'me-1',
            imageBuilder: _stubImage(),
          ),
        ),
      );

      final Text caption = tester.widget<Text>(find.text('Feb 14, 2026'));
      expect(caption.style!.fontFamily, 'Roboto Mono');
      expect(caption.style!.fontSize, 9);
      expect(caption.maxLines, 1);
    });
  });

  group('add-photo tile', () {
    testWidgets(
      'renders the design source label under an add_photo_alternate glyph at '
      '26px in --pink',
      (tester) async {
        await tester.pumpWidget(_wrap(_grid()));
        await tester.pump();

        expect(find.text('Add photo'), findsOneWidget);

        final CupidIcon icon = tester.widget<CupidIcon>(
          find.descendant(
            of: find.byKey(const Key('gallery_add_tile')),
            matching: find.byType(CupidIcon),
          ),
        );
        expect(icon.size, 26);
        expect(icon.color, colors.colorAccentPink);
        expect(icon.icon.codePoint, 0xe43e);
      },
    );
  });
}
