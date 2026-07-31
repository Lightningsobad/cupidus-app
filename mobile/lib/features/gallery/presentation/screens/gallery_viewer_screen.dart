import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/gallery_item.dart';
import '../widgets/gallery_viewer_photo.dart';

/// `close` glyph, confirmed via a `fontTools` cmap lookup on the bundled
/// `MaterialSymbolsRounded-Variable.ttf` at 0xe5cd (same sourcing rule as
/// `CupidIcons`). Defined locally rather than added to `CupidIcons` because
/// this phase's write scope does not include
/// `design_system/icons/cupid_icons.dart`.
const IconData _closeIcon = IconData(0xe5cd, fontFamily: CupidIcons.fontFamily);

/// `chevron_right` glyph, confirmed via the same cmap lookup at 0xe5cc —
/// the pair of `CupidIcons.chevronLeft` (0xe5cb), which is already used
/// elsewhere in this design system.
const IconData _chevronRightIcon = IconData(
  0xe5cc,
  fontFamily: CupidIcons.fontFamily,
);

/// Full-screen `gallery-viewer` route (`ux/uiux-spec.md` §4.4, §6, §7):
/// chromeless, swipeable paged photo view opened from a `GalleryGridView`
/// tile tap (`coding-plan/master-plan.md` §5 P4). Never decides which items
/// to show — the caller (`GalleryScreen`) supplies the full page of loaded
/// items and the tapped tile's index.
class GalleryViewerScreen extends StatefulWidget {
  const GalleryViewerScreen({
    super.key,
    required this.items,
    required this.currentUserId,
    required this.initialIndex,
    this.onClose,
    this.photoImageBuilder,
  });

  final List<GalleryItem> items;
  final String currentUserId;
  final int initialIndex;

  /// Overridable for tests; defaults to popping the current route.
  final VoidCallback? onClose;

  /// Forwarded to every [GalleryViewerPhoto] so widget tests never resolve a
  /// real network image; see [GalleryViewerImageBuilder].
  final GalleryViewerImageBuilder? photoImageBuilder;

  @override
  State<GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends State<GalleryViewerScreen> {
  /// Caption fade-out delay after the last interaction
  /// (`ux/uiux-spec.md` §4.4: "fades out after ~2s of no interaction").
  static const Duration _captionAutoHideDelay = Duration(seconds: 2);

  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;
  bool _captionVisible = true;
  Timer? _captionTimer;

  @override
  void dispose() {
    _captionTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleCaptionAutoHide() {
    _captionTimer?.cancel();
    _captionTimer = Timer(_captionAutoHideDelay, () {
      if (mounted) setState(() => _captionVisible = false);
    });
  }

  /// "Caption overlay ... fades in on tap" (`ux/uiux-spec.md` §4.4): tapping
  /// the photo toggles the caption instead of only ever showing it, so a
  /// user can re-reveal it after it has auto-hidden.
  void _toggleCaption() {
    final bool nextVisible = !_captionVisible;
    setState(() => _captionVisible = nextVisible);
    if (nextVisible) {
      _scheduleCaptionAutoHide();
    } else {
      _captionTimer?.cancel();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _captionVisible = true;
    });
    _scheduleCaptionAutoHide();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _close() {
    final VoidCallback? onClose = widget.onClose;
    if (onClose != null) {
      onClose();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final bool isIos = platform == CupidPlatform.ios;
    final int itemCount = widget.items.length;
    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleCaption,
              child: PageView.builder(
                key: const Key('gallery_viewer_page_view'),
                controller: _pageController,
                itemCount: itemCount,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) => GalleryViewerPhoto(
                  item: widget.items[index],
                  imageBuilder: widget.photoImageBuilder,
                ),
              ),
            ),
          ),
          Positioned(
            top: platformTokens.safeTop,
            left: isIos ? CupidSpacing.md : null,
            right: isIos ? null : CupidSpacing.md,
            child: _ViewerIconButton(
              key: const Key('gallery_viewer_close_button'),
              icon: _closeIcon,
              tapTarget: platformTokens.tapTarget,
              semanticLabel: isVi ? 'Đóng' : 'Close',
              onPressed: _close,
            ),
          ),
          if (itemCount > 1) ...<Widget>[
            Positioned(
              left: CupidSpacing.sm,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ViewerIconButton(
                  key: const Key('gallery_viewer_previous_button'),
                  icon: CupidIcons.chevronLeft,
                  tapTarget: platformTokens.tapTarget,
                  semanticLabel: isVi ? 'Ảnh trước' : 'Previous photo',
                  onPressed: _currentIndex > 0
                      ? () => _goToPage(_currentIndex - 1)
                      : null,
                ),
              ),
            ),
            Positioned(
              right: CupidSpacing.sm,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ViewerIconButton(
                  key: const Key('gallery_viewer_next_button'),
                  icon: _chevronRightIcon,
                  tapTarget: platformTokens.tapTarget,
                  semanticLabel: isVi ? 'Ảnh tiếp theo' : 'Next photo',
                  onPressed: _currentIndex < itemCount - 1
                      ? () => _goToPage(_currentIndex + 1)
                      : null,
                ),
              ),
            ),
          ],
          Positioned(
            left: 0,
            right: 0,
            bottom: platformTokens.safeBottom + CupidSpacing.lg,
            child: IgnorePointer(
              ignoring: !_captionVisible,
              child: AnimatedOpacity(
                opacity: _captionVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: _GalleryViewerCaption(
                    item: widget.items[_currentIndex],
                    currentUserId: widget.currentUserId,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular, semi-transparent icon button used for the viewer's close and
/// prev/next controls (`ux/uiux-spec.md` §4.4, §7): always visible (not tied
/// to caption fade) so screen reader and keyboard users have a non-gesture
/// equivalent for close/swipe navigation, sized to the platform's minimum
/// tap target.
class _ViewerIconButton extends StatelessWidget {
  const _ViewerIconButton({
    super.key,
    required this.icon,
    required this.tapTarget,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final double tapTarget;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: SizedBox(
        width: tapTarget,
        height: tapTarget,
        child: Material(
          type: MaterialType.circle,
          color: const Color.fromRGBO(0, 0, 0, 0.35),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Center(
              child: CupidIcon(
                icon,
                variant: CupidIconVariant.line,
                color: onPressed == null ? Colors.white24 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Caption overlay (`ux/uiux-spec.md` §4.4): date + uploader attribution for
/// the currently-displayed photo. No location field exists on [GalleryItem]
/// (P0 domain scope), so unlike the design spec's grid-tile caption this
/// omits location rather than inventing one.
class _GalleryViewerCaption extends StatelessWidget {
  const _GalleryViewerCaption({
    required this.item,
    required this.currentUserId,
  });

  final GalleryItem item;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';
    final bool isSelf = item.userId == currentUserId;
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(item.createdAt);
    final String uploader = isSelf
        ? (isVi ? 'Bạn' : 'You')
        : (isVi ? 'Đối tác' : 'Partner');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: CupidSpacing.md,
          vertical: CupidSpacing.sm,
        ),
        child: Text(
          '$date · $uploader',
          style: context.cupidType.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
