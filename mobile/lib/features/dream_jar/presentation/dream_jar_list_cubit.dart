import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/dream_jar.dart';
import '../data/dream_jar_repository.dart';

/// STORY-014 P3 jar-collection state (`ux/uiux-spec.md` §1.2).
sealed class DreamJarListState {
  const DreamJarListState();
}

class DreamJarListLoading extends DreamJarListState {
  const DreamJarListLoading();
}

/// Zero non-archived jars remain after the archived filter (AC: "Archived
/// jars never appear in the list").
class DreamJarListEmpty extends DreamJarListState {
  const DreamJarListEmpty();
}

/// [jars] holds [DreamJarStatus.active] jars only and [completed] holds
/// [DreamJarStatus.completed] ones; [DreamJarStatus.archived] appears in
/// neither. The split feeds the summary pill's total/count (STORY-061 AC1)
/// and the completed-jars row (AC5), which are both active-vs-completed
/// distinctions the merged list could not express. The screen renders a
/// single jar's detail directly when this holds exactly one active jar and no
/// completed ones (`ux/uiux-spec.md` §1.2), and a card list otherwise.
class DreamJarListReady extends DreamJarListState {
  const DreamJarListReady(this.jars, this.completed);

  final List<DreamJar> jars;
  final List<DreamJar> completed;
}

/// AC3: rendered as `DreamJarUnpairedNotice` by the screen.
class DreamJarListUnpaired extends DreamJarListState {
  const DreamJarListUnpaired();
}

class DreamJarListFailed extends DreamJarListState {
  const DreamJarListFailed(this.failure);

  final Object failure;
}

class DreamJarListCubit extends Cubit<DreamJarListState> {
  DreamJarListCubit(this._repository) : super(const DreamJarListLoading());

  final DreamJarRepository _repository;

  Future<void> load() => _fetch();

  /// Pull-to-refresh entry point. Reuses [_fetch] rather than a separate
  /// no-flicker code path: this phase's scope is the collection surface
  /// itself, not refresh polish beyond the existing `RefreshIndicator` spinner.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    emit(const DreamJarListLoading());
    try {
      final jars = await _repository.fetchJars();
      final active = jars
          .where((jar) => jar.status == DreamJarStatus.active)
          .toList();
      final completed = jars
          .where((jar) => jar.status == DreamJarStatus.completed)
          .toList();
      if (!isClosed) {
        emit(
          active.isEmpty && completed.isEmpty
              ? const DreamJarListEmpty()
              : DreamJarListReady(active, completed),
        );
      }
    } on DreamJarUnpairedFailure {
      if (!isClosed) emit(const DreamJarListUnpaired());
    } catch (failure) {
      if (!isClosed) emit(DreamJarListFailed(failure));
    }
  }
}
