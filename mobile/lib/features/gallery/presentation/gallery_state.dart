import '../domain/gallery_item.dart';

/// `GalleryScreen` state machine (`coding-plan/phase-P1-gallery-shell-and-gate.md`
/// §3-4): `locked` is the AC3 pairing gate, never a lock/encryption state
/// (`architecture/solution.md` §5 D-1 — this story renders no lock
/// affordance).
sealed class GalleryState {
  const GalleryState();
}

/// Initial state while the first `GET /users/me` + `GET /gallery` round
/// trip is in flight.
class GalleryLoading extends GalleryState {
  const GalleryLoading();
}

/// `GET /users/me.partnerId == null` (AC3): no `GET /gallery` call is made
/// for this branch.
class GalleryLocked extends GalleryState {
  const GalleryLocked();
}

/// Paired user, first page fetched fresh (not stale), zero items.
class GalleryEmpty extends GalleryState {
  const GalleryEmpty();
}

/// Paired user with at least one item, or a stale cached snapshot.
///
/// [isStale] is `true` only when the network read failed and [items] came
/// from `GalleryLocalCache` instead (`GalleryRepository.fetchPage` read
/// -through contract). [currentUserId] is carried for uploader-attribution
/// badges in P2's grid tiles.
class GalleryLoaded extends GalleryState {
  const GalleryLoaded({
    required this.items,
    required this.currentUserId,
    this.isStale = false,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<GalleryItem> items;
  final String currentUserId;
  final bool isStale;
  final bool hasMore;
  final bool isLoadingMore;

  GalleryLoaded copyWith({
    List<GalleryItem>? items,
    bool? isStale,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return GalleryLoaded(
      items: items ?? this.items,
      currentUserId: currentUserId,
      isStale: isStale ?? this.isStale,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Paired user, network read failed, and no cached snapshot exists.
class GalleryFailure extends GalleryState {
  const GalleryFailure();
}
