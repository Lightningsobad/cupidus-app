import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/gallery_item.dart';
import 'gallery_grid_columns.dart';
import 'gallery_tile.dart';

/// `add_photo_alternate` glyph, confirmed via a `fontTools` cmap lookup on
/// the bundled `MaterialSymbolsRounded-Variable.ttf` (same sourcing rule as
/// `CupidIcons`, and the same codepoint `gallery_empty_view.dart` already
/// resolves). Defined locally rather than added to `CupidIcons` because this
/// story's write scope does not include
/// `design_system/icons/cupid_icons.dart`.
const IconData _addPhotoAlternateIcon = IconData(
  0xe43e,
  fontFamily: CupidIcons.fontFamily,
);

/// The shared gallery grid (`ux/uiux-spec.md` §4.2, §4.6): a responsive
/// `GridView.builder` over [items] with a pinned dashed add-photo tile
/// always last, pull-to-refresh, and page-ahead loading.
///
/// This widget only renders the grid itself — it does not decide which of
/// `GalleryState`'s branches to show; the caller (`GalleryScreen`, wired in a
/// later phase per `coding-plan/master-plan.md` §6) is responsible for
/// choosing between this, `GalleryEmptyView`, and the other state views.
class GalleryGridView extends StatefulWidget {
  const GalleryGridView({
    super.key,
    required this.items,
    required this.currentUserId,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.onTileTap,
    required this.onAddPhoto,
    required this.onRefresh,
    required this.onLoadMore,
    this.tileImageBuilder,
  });

  final List<GalleryItem> items;
  final String currentUserId;
  final bool hasMore;
  final bool isLoadingMore;

  /// Called with the tapped tile's index in [items] (P4 attaches the real
  /// viewer navigation).
  final ValueChanged<int> onTileTap;

  /// Called when the pinned add-photo tile is tapped (P3 attaches the real
  /// upload sheet).
  final VoidCallback onAddPhoto;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  /// Forwarded to every [GalleryTile] so widget tests never resolve a real
  /// network image; see [GalleryTileImageBuilder].
  final GalleryTileImageBuilder? tileImageBuilder;

  @override
  State<GalleryGridView> createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  /// Reaching this many tiles from the end of [GalleryGridView.items]
  /// requests the next page (`coding-plan/phase-P2-gallery-grid.md` §3).
  static const int _loadMoreLookahead = 6;

  /// The `items.length` a load-more request was already issued for; guards
  /// against issuing more than one `onLoadMore()` call per page while the
  /// same near-tail tiles keep rebuilding across frames.
  int? _loadMoreRequestedAtLength;

  void _maybeRequestLoadMore(int builtIndex) {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final int itemCount = widget.items.length;
    if (builtIndex < itemCount - _loadMoreLookahead) return;
    if (_loadMoreRequestedAtLength == itemCount) return;
    _loadMoreRequestedAtLength = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int columnCount = galleryColumnCount(constraints.maxWidth);
          final int photoCount = widget.items.length;
          final int skeletonCount = widget.isLoadingMore ? columnCount : 0;
          final int totalCount = photoCount + skeletonCount + 1;

          return GridView.builder(
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            // Design source `padding:8px 16px 40px` (`Cupid Screens.dc.html`
            // L737); 40 snaps to the nearest spacing token.
            padding: EdgeInsets.fromLTRB(
              CupidSpacing.md,
              CupidSpacing.sm,
              CupidSpacing.md,
              CupidSpacing.xl,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              mainAxisSpacing: CupidSpacing.sm,
              crossAxisSpacing: CupidSpacing.sm,
              childAspectRatio: 3 / 4,
            ),
            itemCount: totalCount,
            itemBuilder: (context, index) {
              if (index < photoCount) {
                _maybeRequestLoadMore(index);
                final GalleryItem item = widget.items[index];
                return GalleryTile(
                  key: ValueKey(item.id),
                  item: item,
                  currentUserId: widget.currentUserId,
                  onTap: () => widget.onTileTap(index),
                  imageBuilder: widget.tileImageBuilder,
                );
              }
              if (index < photoCount + skeletonCount) {
                return _GalleryShimmerTile(
                  key: ValueKey('gallery_shimmer_$index'),
                );
              }
              return _GalleryAddTile(
                key: const Key('gallery_add_tile'),
                onTap: widget.onAddPhoto,
              );
            },
          );
        },
      ),
    );
  }
}

/// Pinned dashed "add photo" tile, always the grid's last cell
/// (`ux/uiux-spec.md` §4.2) so newly-added photos read chronologically
/// without the add-affordance interrupting the flow.
class _GalleryAddTile extends StatelessWidget {
  const _GalleryAddTile({super.key, required this.onTap});

  final VoidCallback onTap;

  bool _isVi(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'vi';

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String label = _isVi(context) ? 'Thêm ảnh' : 'Add photo';

    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: colors.colorLine,
              radius: platform.radiusSmall,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupidIcon(
                  _addPhotoAlternateIcon,
                  color: colors.colorAccentPink,
                  size: 26,
                ),
                SizedBox(height: CupidSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.cupidType.caption.copyWith(
                    color: colors.colorTextMuted,
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

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dashWidth = 6;
  static const double _dashSpace = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashWidth),
          paint,
        );
        distance += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Skeleton placeholder shown for the next page while it loads
/// (`ux/uiux-spec.md` §4.2 "shimmer" keyframe), rather than a full-screen
/// spinner.
class _GalleryShimmerTile extends StatefulWidget {
  const _GalleryShimmerTile({super.key});

  @override
  State<_GalleryShimmerTile> createState() => _GalleryShimmerTileState();
}

class _GalleryShimmerTileState extends State<_GalleryShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.3, end: 0.7).animate(_controller),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorSurfaceAlt,
            borderRadius: BorderRadius.circular(platform.radiusSmall),
          ),
        ),
      ),
    );
  }
}
