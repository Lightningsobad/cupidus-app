import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/activity_card_repository.dart';
import '../data/phase_content_repository.dart';
import '../domain/evening_check_in_scheduler.dart';
import '../domain/phase_content.dart';
import '../domain/solo_phase.dart';
import '../domain/solo_phase_resolver.dart';
import 'phase_status_line.dart';

/// The seam the home-screen widget is published through.
///
/// P7 owns the call site, not the implementation: the screen must hand the
/// resolved phase to the widget on the same pass that draws it, so the two
/// surfaces can never disagree (`WIDGET-STALE`, AC-9/AC-10). P4 registers the
/// platform-channel implementation behind this port; until then the app runs
/// with none and simply publishes nothing.
abstract interface class PhaseWidgetPublisher {
  Future<void> pushWidgetPayload(PhaseResolution resolution);
}

/// What screen (1) draws for the current phase: at most one sentence and one
/// supporting line, already substituted.
///
/// Holds strings rather than a phase plus a lookup, so no second copy of the
/// "which line for which phase" decision can grow in the widget layer.
class PhaseStatusState {
  const PhaseStatusState({this.anchorCardId, this.primary, this.secondary});

  /// The card the line hangs above, `null` when the line has no card of its
  /// own or when there is no line.
  final String? anchorCardId;

  final String? primary;
  final String? secondary;

  bool get hasLine => primary != null;

  @override
  bool operator ==(Object other) =>
      other is PhaseStatusState &&
      other.anchorCardId == anchorCardId &&
      other.primary == primary &&
      other.secondary == secondary;

  @override
  int get hashCode => Object.hash(anchorCardId, primary, secondary);
}

/// Resolves the solo phase once and turns it into the line screen (1) shows.
///
/// It calls [resolveSoloPhase] and nothing else infers a phase: the widget
/// payload published here and the sentence emitted here come from the same
/// single resolution, which is the whole reason this cubit exists rather than
/// a `Builder` on the hub.
///
/// There is no timer, stream subscription or background task. [refresh] runs
/// when the hub mounts and when the app returns to the foreground; a phase
/// derived from a civil date cannot change at any other moment the user is
/// looking at this screen.
class PhaseStatusCubit extends Cubit<PhaseStatusState> {
  PhaseStatusCubit({
    required ActivityCardRepository repository,
    PhaseContentRepository? content,
    PhaseWidgetPublisher? widgetPublisher,
    EveningCheckInScheduler? eveningCheckIn,
    DateTime Function()? clock,
  })  : _repository = repository,
        _content = content ?? PhaseContentRepository(),
        _widgetPublisher = widgetPublisher,
        _eveningCheckIn = eveningCheckIn,
        _clock = clock ?? DateTime.now,
        super(const PhaseStatusState());

  /// Upper bound on the cards one resolution reads. The resolver only ever
  /// keeps the nearest future date and the newest unanswered invite, so a
  /// deeper page cannot change the answer for any realistic store.
  static const int _scanLimit = 50;

  final ActivityCardRepository _repository;
  final PhaseContentRepository _content;
  final PhaseWidgetPublisher? _widgetPublisher;
  final EveningCheckInScheduler? _eveningCheckIn;
  final DateTime Function() _clock;

  Future<void> refresh() async {
    final DateTime today = _clock();

    final PhaseResolution resolution;
    try {
      resolution = resolveSoloPhase(cards: await _cards(), today: today);
    } catch (_) {
      // A store read that fails leaves the hub without its phase line and with
      // its card list intact, which is the degraded state BR-2 asks for.
      _emit(const PhaseStatusState());
      return;
    }

    await _widgetPublisher?.pushWidgetPayload(resolution);

    // Not awaited, for the same reason the widget payload is not: the sentence
    // below must never wait on a permission dialog or a notification queue.
    // The scheduler swallows its own failures and its one-shot gate is what
    // makes a repeat refresh harmless (`REMIND-REPEAT`).
    final EveningCheckInScheduler? eveningCheckIn = _eveningCheckIn;
    if (eveningCheckIn != null) {
      unawaited(eveningCheckIn.sync(resolution));
    }

    final PhaseContentCatalogue catalogue;
    try {
      catalogue = await _content.catalogue();
    } catch (_) {
      _emit(const PhaseStatusState());
      return;
    }

    // The only place a number reaches the copy, and only on the one phase that
    // counts down to a date the user already chose. `waiting` and `quiet` pass
    // `null` here, so an item whose text needs `{n}` is skipped for them
    // instead of being filled with an elapsed count (AC-6/AC-7).
    final int? days = resolution.phase == SoloPhase.upcoming &&
            resolution.scheduledOn != null
        ? civilDaysUntil(scheduledOnIso: resolution.scheduledOn!, today: today)
        : null;

    final PhaseContentItem? item = _lineFor(
      catalogue.phaseContent,
      resolution.phase,
      days,
    );
    if (item == null) {
      _emit(const PhaseStatusState());
      return;
    }

    _emit(
      PhaseStatusState(
        anchorCardId: resolution.cardId,
        primary: _fill(item.primary, days),
        secondary: item.secondary == null ? null : _fill(item.secondary!, days),
      ),
    );
  }

  Future<List<ActivityCard>> _cards() async {
    // The two statuses a phase can be read from: a date lives on `scheduled`,
    // an open invitation on either. `done` and `memory` are cards whose moment
    // has passed and cannot start a countdown or a wait.
    final List<ActivityCard> scheduled = await _repository.cardsByStatus(
      status: ActivityCardStatus.scheduled,
      limit: _scanLimit,
    );
    final List<ActivityCard> ideas = await _repository.cardsByStatus(
      status: ActivityCardStatus.idea,
      limit: _scanLimit,
    );
    return <ActivityCard>[...scheduled, ...ideas];
  }

  /// First package item for [phase] that may appear on a screen and whose text
  /// this call can actually complete. An item carrying `{n}` with no number
  /// available is skipped rather than drawn with a blank or a zero.
  PhaseContentItem? _lineFor(
    ContentPackage<PhaseContentItem> package,
    SoloPhase phase,
    int? days,
  ) {
    for (final PhaseContentItem item in package.items) {
      if (item.phaseId.wireValue != phase.wireValue ||
          !item.surface.allowsScreen) {
        continue;
      }
      final bool needsNumber = item.displayStrings.any(
        (String text) => text.contains(phaseContentNumberPlaceholder),
      );
      if (needsNumber && days == null) {
        continue;
      }
      return item;
    }
    return null;
  }

  String _fill(String text, int? days) => days == null
      ? text
      : text.replaceAll(phaseContentNumberPlaceholder, '$days');

  void _emit(PhaseStatusState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
