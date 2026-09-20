import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';

/// Journal list state (`coding-plan/phase-P3-journal-list-screen-and-delete.md`
/// §3). A plain [Cubit], never a `HydratedCubit`: persisting this state would
/// write a second, un-deletable copy of the entries to disk and break AC-13.
sealed class JournalListState {
  const JournalListState();
}

/// Shown until the first repository emission arrives. The screen renders it the
/// same way as [JournalListReady] with no entries, so a slow first frame cannot
/// flash a different empty state than the real one (`architecture/solution.md`
/// §4: the empty and the no-owner-id states are indistinguishable by design).
class JournalListLoading extends JournalListState {
  const JournalListLoading();
}

class JournalListReady extends JournalListState {
  const JournalListReady({required this.entries, required this.hasMore});

  /// At most one page window, never the whole table (`solution.md` §5).
  final List<JournalEntry> entries;

  final bool hasMore;
}

/// Reads the private journal list and runs its two delete flows.
///
/// There is deliberately no entry count, no day streak and no goal anywhere in
/// this state (AC-1, BR-4) — the absence is the requirement, so adding a
/// convenience `length` getter here would already be the drift the story is
/// gated against.
class JournalListCubit extends Cubit<JournalListState> {
  JournalListCubit({
    required this._repository,
    int pageSize = defaultPageSize,
  })  : _pageSize = pageSize,
        _limit = pageSize,
        super(const JournalListLoading()) {
    _start();
  }

  static const int defaultPageSize = 20;

  final JournalRepository _repository;
  final int _pageSize;

  /// Size of the window currently requested from the repository. Grows by
  /// [_pageSize] per [loadMore]; nothing else in the app holds the rows.
  int _limit;

  StreamSubscription<List<JournalEntry>>? _subscription;

  Future<void> _start() async {
    // AC-13's compensating half: files left behind by a delete that died
    // between its two phases are removed on feature open, exactly once.
    await _repository.sweepOrphans();
    if (!isClosed) {
      _watch();
    }
  }

  void _watch() {
    unawaited(_subscription?.cancel());
    // One row past the window is what distinguishes "this is the whole
    // journal" from "there is another page", without reading the other page.
    _subscription = _repository.watchEntries(limit: _limit + 1).listen((rows) {
      if (isClosed) {
        return;
      }
      final bool hasMore = rows.length > _limit;
      emit(
        JournalListReady(
          entries: hasMore ? rows.sublist(0, _limit) : rows,
          hasMore: hasMore,
        ),
      );
    });
  }

  void loadMore() {
    final JournalListState current = state;
    if (current is! JournalListReady || !current.hasMore) {
      return;
    }
    _limit += _pageSize;
    _watch();
  }

  /// AC-11. The repository is the only holder of the entry; nothing is copied
  /// into an undo buffer here, so there is no state to roll back either.
  Future<void> deleteEntry(String id) => _repository.deleteEntry(id);

  /// AC-12. Resets the window as well as the data so the screen returns to the
  /// first-open empty state rather than a scrolled-open one.
  Future<void> deleteAll() async {
    await _repository.deleteAll();
    if (isClosed) {
      return;
    }
    _limit = _pageSize;
    _watch();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
