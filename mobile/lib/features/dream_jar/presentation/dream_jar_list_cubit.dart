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

/// [jars] already excludes [DreamJarStatus.archived] entries. The screen
/// renders a single jar's detail directly when this holds exactly one jar
/// (`ux/uiux-spec.md` §1.2), and a card list otherwise.
class DreamJarListReady extends DreamJarListState {
  const DreamJarListReady(this.jars);

  final List<DreamJar> jars;
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
          .where((jar) => jar.status != DreamJarStatus.archived)
          .toList();
      if (!isClosed) {
        emit(
          active.isEmpty
              ? const DreamJarListEmpty()
              : DreamJarListReady(active),
        );
      }
    } on DreamJarUnpairedFailure {
      if (!isClosed) emit(const DreamJarListUnpaired());
    } catch (failure) {
      if (!isClosed) emit(DreamJarListFailed(failure));
    }
  }
}
