import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/activity_card_repository.dart';
import '../../activity_cards/domain/activity_type.dart';
import '../data/phase_content_repository.dart';
import '../domain/drip_cadence_policy.dart';
import '../domain/evening_check_in_scheduler.dart';
import '../domain/milestone_resolver.dart';
import '../domain/phase_content.dart';
import '../domain/solo_phase.dart';
import '../domain/solo_phase_resolver.dart';
import '../domain/wealth_counter.dart';
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
  const PhaseStatusState({
    this.anchorCardId,
    this.primary,
    this.secondary,
    this.actionLabel,
    this.counterValue = 0,
    this.counterLabel,
    this.milestone,
    this.giftProgress,
    this.drip,
  });

  /// The card the line hangs above, `null` when the line has no card of its
  /// own or when there is no line.
  final String? anchorCardId;

  final String? primary;
  final String? secondary;

  /// The secondary action's label, straight from the phase line, or `null` when
  /// the phase offers no action. Absent here means the line draws none: there is
  /// no default label anywhere between the package and the screen.
  final String? actionLabel;

  /// Cardinality of the kept-memory set, and only that: no term of this value
  /// comes from a clock, a day count, or an activity rate (BR-5/AC-25).
  final int counterValue;

  final String? counterLabel;
  final String? milestone;
  final String? giftProgress;
  final String? drip;

  bool get hasLine => primary != null;

  PhaseStatusState copyWith({String? milestone, String? drip}) =>
      PhaseStatusState(
        anchorCardId: anchorCardId,
        primary: primary,
        secondary: secondary,
        actionLabel: actionLabel,
        counterValue: counterValue,
        counterLabel: counterLabel,
        milestone: milestone ?? this.milestone,
        giftProgress: giftProgress,
        drip: drip ?? this.drip,
      );

  @override
  bool operator ==(Object other) =>
      other is PhaseStatusState &&
      other.anchorCardId == anchorCardId &&
      other.primary == primary &&
      other.secondary == secondary &&
      other.actionLabel == actionLabel &&
      other.counterValue == counterValue &&
      other.counterLabel == counterLabel &&
      other.milestone == milestone &&
      other.giftProgress == giftProgress &&
      other.drip == drip;

  @override
  int get hashCode => Object.hash(
        anchorCardId,
        primary,
        secondary,
        actionLabel,
        counterValue,
        counterLabel,
        milestone,
        giftProgress,
        drip,
      );
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
    MilestoneResolver? milestone,
    DripCadencePolicy? drip,
    DateTime Function()? clock,
  })  : _repository = repository,
        _content = content ?? PhaseContentRepository(),
        _widgetPublisher = widgetPublisher,
        _eveningCheckIn = eveningCheckIn,
        _milestone = milestone,
        _drip = drip,
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
  final MilestoneResolver? _milestone;
  final DripCadencePolicy? _drip;
  static const WealthCounter _counter = WealthCounter();
  final DateTime Function() _clock;

  Future<void> refresh() async {
    final DateTime today = _clock();

    final PhaseResolution resolution;
    final List<ActivityCard> cards;
    final int counterValue;
    try {
      cards = await _cards();
      resolution = resolveSoloPhase(cards: cards, today: today);
      counterValue = _counter.count(await _repository.countsByStatus());
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

    // The quiet phase is the only one that may carry a gift block or a drip
    // caption (AC-20/AC-22): during a countdown or on the date itself the user
    // already has something in front of them.
    final bool quiet = resolution.phase == SoloPhase.quiet;
    final String? giftLine = quiet && _hasGiftInProgress(cards)
        ? _nudgeBody(catalogue.nudges, NudgeSlot.giftProgress, null)
        : null;

    final PhaseStatusState next = PhaseStatusState(
      anchorCardId: item == null ? null : resolution.cardId,
      primary: item == null ? null : _fill(item.primary, days),
      secondary: item?.secondary == null ? null : _fill(item!.secondary!, days),
      actionLabel: item?.actionLabel == null
          ? null
          : _fill(item!.actionLabel!, days),
      counterValue: counterValue,
      counterLabel: _nudgeBody(
        catalogue.nudges,
        NudgeSlot.counter,
        counterValue,
      ),
      giftProgress: giftLine,
    );
    _emit(next);

    // Deliberately not awaited, for the same reason the evening reminder is
    // not: both cursors live in `SharedPreferences`, and the counter above must
    // never wait on a platform channel to reach the screen.
    unawaited(_resolveQuietExtras(next, catalogue, counterValue, today, quiet));
  }

  /// Second pass for the two surfaces that own a durable cursor.
  ///
  /// Both `resolve` and `nextItem` consume their slot as a side effect, so they
  /// run once per refresh and only when the phase they belong to is current —
  /// asking the drip policy outside the quiet phase would burn a week's quota
  /// on a screen that never shows the line (BR-9).
  Future<void> _resolveQuietExtras(
    PhaseStatusState base,
    PhaseContentCatalogue catalogue,
    int counterValue,
    DateTime today,
    bool quiet,
  ) async {
    String? milestone;
    String? drip;
    try {
      final MilestoneResolution? crossed = await _milestone?.resolve(
        counterValue: counterValue,
        thresholds: catalogue.milestoneThresholds,
        nudges: catalogue.nudges,
      );
      if (crossed != null) {
        milestone = _fill(crossed.item.body, crossed.value);
      }
      if (quiet) {
        final DripItem? item = await _drip?.nextItem(
          drip: catalogue.drip,
          today: today,
        );
        // The shipped pack has a drip line that names the kept count, so the
        // same substitution the phase line uses has to run here too: an
        // unfilled `{n}` would reach the screen as literal text.
        drip = item == null ? null : _fill(item.body, counterValue);
      }
    } catch (_) {
      // No cursor store on this device means no milestone and no drip line.
      // Silence is the defined empty state for both (AC-38), so there is
      // nothing to tell the user about it.
      return;
    }

    if (milestone == null && drip == null) {
      return;
    }
    _emit(base.copyWith(milestone: milestone, drip: drip));
  }

  /// A gift the user is making that has not been finished yet. Read-only use of
  /// the STORY-001 card contract: no field is added and no status is moved on
  /// the user's behalf (BR-12).
  bool _hasGiftInProgress(List<ActivityCard> cards) => cards.any(
        (ActivityCard card) =>
            card.activityType == ActivityType.gift ||
            card.origin == ActivityCardOrigin.giftSuggestion,
      );

  String? _nudgeBody(
    ContentPackage<NudgeItem> package,
    NudgeSlot slot,
    int? value,
  ) {
    for (final NudgeItem item in package.items) {
      if (item.slot != slot) {
        continue;
      }
      if (item.body.contains(phaseContentNumberPlaceholder) && value == null) {
        return null;
      }
      return _fill(item.body, value);
    }
    return null;
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
