import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/gallery_repository.dart';
import '../domain/gallery_item.dart';
import 'gallery_state.dart';

/// Drives `GalleryScreen` (`coding-plan/phase-P1-gallery-shell-and-gate.md`
/// §3): resolves the AC3 pairing gate first, then paginates the shared
/// gallery for paired users. Never calls `GalleryApi`/`GalleryLocalCache`
/// directly — only through `GalleryRepository` (`architecture/solution.md`
/// §4 Boundaries And Ownership).
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit({required this._repository}) : super(const GalleryLoading());

  final GalleryRepository _repository;

  static const int _pageSize = 30;

  /// Caches the paired user's id between emissions so [insertOptimistic]
  /// can attribute an upload without re-fetching `GET /users/me`.
  String? _currentUserId;

  /// Resolves the pairing gate, then the first gallery page.
  Future<void> load() async {
    emit(const GalleryLoading());
    await _loadFirstPage();
  }

  /// Pull-to-refresh: re-resolves the pairing gate and the first page from
  /// offset 0, matching [load] (the gate is re-checked in case pairing
  /// status changed since the screen opened).
  Future<void> refresh() => _loadFirstPage();

  Future<void> _loadFirstPage() async {
    try {
      final me = await _repository.currentUser();
      if (me.partnerId == null) {
        _currentUserId = null;
        emit(const GalleryLocked());
        return;
      }
      _currentUserId = me.id;
      final page = await _repository.fetchPage(limit: _pageSize, offset: 0);
      _emitPage(page, currentUserId: me.id);
    } catch (_) {
      if (!isClosed) emit(const GalleryFailure());
    }
  }

  void _emitPage(GalleryPage page, {required String currentUserId}) {
    if (page.items.isEmpty) {
      // A stale, empty cache carries no usable snapshot: surface failure
      // rather than an empty-state that would misreport "no photos yet".
      emit(page.isStale ? const GalleryFailure() : const GalleryEmpty());
      return;
    }
    emit(
      GalleryLoaded(
        items: page.items,
        currentUserId: currentUserId,
        isStale: page.isStale,
        // The cached snapshot holds only the first page, so there is no
        // further page to request while offline.
        hasMore: page.isStale ? false : page.items.length >= _pageSize,
      ),
    );
  }

  /// Appends the next page (offset += [_pageSize]); a no-op while already
  /// loading more or once [GalleryLoaded.hasMore] is false.
  Future<void> loadMore() async {
    final current = state;
    if (current is! GalleryLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.fetchPage(
        limit: _pageSize,
        offset: current.items.length,
      );
      if (isClosed) return;
      emit(
        current.copyWith(
          items: [...current.items, ...page.items],
          isLoadingMore: false,
          hasMore: !page.isStale && page.items.length >= _pageSize,
        ),
      );
    } catch (_) {
      if (!isClosed) emit(current.copyWith(isLoadingMore: false));
    }
  }

  /// Inserts a freshly-uploaded item at the start of the grid ahead of the
  /// next sync (P3 upload sheet's optimistic-insert contract). A no-op
  /// while [GalleryLocked]/[GalleryLoading]/[GalleryFailure], since none of
  /// those states have a paired [_currentUserId] to attribute the upload to.
  void insertOptimistic(GalleryItem item) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;
    final current = state;
    if (current is GalleryLoaded) {
      emit(current.copyWith(items: [item, ...current.items]));
    } else if (current is GalleryEmpty) {
      emit(GalleryLoaded(items: [item], currentUserId: currentUserId));
    }
  }
}
