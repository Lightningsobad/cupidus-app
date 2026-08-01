/// Responsive column-count resolver for the shared gallery grid
/// (`ux/uiux-spec.md` §6: width-based, not orientation-based — a landscape
/// phone and a similarly-wide portrait phablet get the same column count).
///
/// 2 columns below 430 logical-pixel width, 3 columns at or above it.
int galleryColumnCount(double widthDp) => widthDp >= 430 ? 3 : 2;
