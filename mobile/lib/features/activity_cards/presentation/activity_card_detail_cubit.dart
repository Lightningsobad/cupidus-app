import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/activity_card.dart';
import '../domain/activity_type.dart';
import '../domain/activity_card_repository.dart';

/// The two branches of the *Đã hẹn ngày → Mới nghĩ ra* regression question
/// (AC-15, `ux/uiux-spec.md` §5). Two values, no third, and no default:
/// [ActivityCardDetailCubit.changeStatus] parks the transition until the user
/// names one of them, so nothing is dropped by a tap the user did not make.
enum ScheduledDateChoice { keep, clear }

class ActivityCardDetailState {
  const ActivityCardDetailState({
    required this.card,
    this.pendingRegression,
    this.deleted = false,
    this.failed = false,
  });

  final ActivityCard card;

  /// The status a regression is waiting on. Non-null means the AC-15 question
  /// has been asked and not yet answered; nothing has been written for it.
  final ActivityCardStatus? pendingRegression;
  final bool deleted;
  final bool failed;

  /// *Đã đi rồi* — the "ghi lại" mode of this screen (SC-4).
  bool get isRecording => card.status == ActivityCardStatus.done;

  /// *Đã thành kỷ niệm* — the "xem lại" mode (AC-13). Still carries the delete
  /// path, so it is a mode of this screen and not a dead end.
  bool get isReviewing => card.status == ActivityCardStatus.memory;

  ActivityCardDetailState copyWith({
    ActivityCard? card,
    ActivityCardStatus? pendingRegression,
    bool clearPendingRegression = false,
    bool? deleted,
    bool? failed,
  }) {
    return ActivityCardDetailState(
      card: card ?? this.card,
      pendingRegression: clearPendingRegression
          ? null
          : pendingRegression ?? this.pendingRegression,
      deleted: deleted ?? this.deleted,
      failed: failed ?? this.failed,
    );
  }
}

/// Drives one card's detail screen: the SB-76 fields, the two-way lifecycle,
/// and the delete path.
///
/// Persistence boundary, stated once here so no caller has to guess it. The
/// P2 contract (`architecture/contract-summary.md` §1) exposes exactly three
/// writers for an existing card — `updateStatus`, `clearScheduledDate` and
/// `deleteCard` — so those three operations go to the store and survive a
/// restart. Field edits have no writer in that contract and are held in
/// [ActivityCardDetailState.card] for the life of the screen; the story that
/// adds a field writer replaces [_edit] with a repository call. This is the
/// same seam `ActivityCardListState.replyOverrides` already documents for the
/// `reply_state` column, and it is deliberately explicit rather than a silent
/// no-op write.
class ActivityCardDetailCubit extends Cubit<ActivityCardDetailState> {
  ActivityCardDetailCubit({
    required ActivityCardRepository repository,
    required ActivityCard card,
  })  : _repository = repository,
        super(ActivityCardDetailState(card: card));

  final ActivityCardRepository _repository;

  /// AC-12 in one gesture: the picked civil date is recorded and the card
  /// moves to *Đã hẹn ngày*, so it lands in that pane without a second step.
  Future<void> scheduleDate(String scheduledOn) async {
    _edit(scheduledOn: scheduledOn);
    await _writeStatus(ActivityCardStatus.scheduled);
  }

  /// AC-14: any of the four statuses, in either direction. The single guarded
  /// case is the regression that would strand a saved date — it is parked for
  /// [resolveRegression] instead of being written here.
  Future<void> changeStatus(ActivityCardStatus next) async {
    if (next == state.card.status) {
      return;
    }
    if (_needsScheduledDateQuestion(next)) {
      emit(state.copyWith(pendingRegression: next));
      return;
    }
    await _writeStatus(next);
  }

  /// Answers the AC-15 question. [ScheduledDateChoice.keep] writes only the
  /// status column, so the saved date, the note and the card's photo rows are
  /// all untouched; [ScheduledDateChoice.clear] is the only path that drops
  /// the date, and only because the user said so.
  Future<void> resolveRegression(ScheduledDateChoice choice) async {
    final ActivityCardStatus? next = state.pendingRegression;
    if (next == null) {
      return;
    }
    emit(state.copyWith(clearPendingRegression: true));
    if (choice == ScheduledDateChoice.clear) {
      try {
        await _repository.clearScheduledDate(state.card.id);
      } on Object {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(failed: true));
        return;
      }
      if (isClosed) {
        return;
      }
      _edit(scheduledOn: null, clearScheduledOn: true);
    }
    await _writeStatus(next);
  }

  /// Dismissing the question leaves the card exactly as it was — the safe
  /// branch is what happens when the user does nothing.
  void cancelRegression() {
    if (state.pendingRegression == null) {
      return;
    }
    emit(state.copyWith(clearPendingRegression: true));
  }

  /// AC-17/AC-18: "đã rủ" is a two-value flag the user sets by hand. No
  /// timestamp is recorded beside it and nothing infers it.
  void toggleInvited() => _edit(invited: !state.card.invited);

  void toggleReplyState() => _edit(
        replyState: state.card.replyState == ActivityCardReplyState.answered
            ? ActivityCardReplyState.notAnswered
            : ActivityCardReplyState.answered,
      );

  void editTitle(String title) => _edit(title: title);

  void editNote(String? note) => _edit(note: note, clearNote: note == null);

  void editSourceLink(String? sourceLink) =>
      _edit(sourceLink: sourceLink, clearSourceLink: sourceLink == null);

  void editActivityType(ActivityType? activityType) =>
      _edit(activityType: activityType, clearActivityType: activityType == null);

  void editPriceVnd(int? priceVnd) =>
      _edit(priceVnd: priceVnd, clearPriceVnd: priceVnd == null);

  void editDistanceKm(double? distanceKm) =>
      _edit(distanceKm: distanceKm, clearDistanceKm: distanceKm == null);

  void editNeedsBooking(bool? needsBooking) =>
      _edit(needsBooking: needsBooking, clearNeedsBooking: needsBooking == null);

  void editIndoorOutdoor(ActivityCardIndoorOutdoor? indoorOutdoor) => _edit(
        indoorOutdoor: indoorOutdoor,
        clearIndoorOutdoor: indoorOutdoor == null,
      );

  void editScheduledOn(String? scheduledOn) =>
      _edit(scheduledOn: scheduledOn, clearScheduledOn: scheduledOn == null);

  /// AC-16. Available in every mode including *Đã thành kỷ niệm*, which is
  /// what keeps that mode from being a dead end (AC-13). The card's photo rows
  /// go with it through the `ON DELETE CASCADE` the schema declares.
  Future<void> deleteCard() async {
    try {
      await _repository.deleteCard(state.card.id);
    } on Object {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(failed: true));
      return;
    }
    if (isClosed) {
      return;
    }
    emit(state.copyWith(deleted: true));
  }

  /// Only this pair strands data: leaving *Đã hẹn ngày* for *Mới nghĩ ra*
  /// while a date is saved. Every other transition keeps every column by
  /// contract, so asking about them would be a confirmation habit rather than
  /// a real question.
  bool _needsScheduledDateQuestion(ActivityCardStatus next) =>
      state.card.status == ActivityCardStatus.scheduled &&
      next == ActivityCardStatus.idea &&
      state.card.scheduledOn != null;

  Future<void> _writeStatus(ActivityCardStatus next) async {
    try {
      await _repository.updateStatus(state.card.id, next);
    } on Object {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(failed: true));
      return;
    }
    if (isClosed) {
      return;
    }
    _edit(status: next);
  }

  void _edit({
    String? title,
    ActivityCardStatus? status,
    ActivityType? activityType,
    bool clearActivityType = false,
    String? scheduledOn,
    bool clearScheduledOn = false,
    int? priceVnd,
    bool clearPriceVnd = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    bool? needsBooking,
    bool clearNeedsBooking = false,
    ActivityCardIndoorOutdoor? indoorOutdoor,
    bool clearIndoorOutdoor = false,
    String? note,
    bool clearNote = false,
    String? sourceLink,
    bool clearSourceLink = false,
    bool? invited,
    ActivityCardReplyState? replyState,
  }) {
    if (isClosed) {
      return;
    }
    final ActivityCard card = state.card;
    emit(
      state.copyWith(
        card: ActivityCard(
          id: card.id,
          ownerKey: card.ownerKey,
          title: title ?? card.title,
          status: status ?? card.status,
          origin: card.origin,
          activityType:
              clearActivityType ? null : activityType ?? card.activityType,
          scheduledOn:
              clearScheduledOn ? null : scheduledOn ?? card.scheduledOn,
          priceVnd: clearPriceVnd ? null : priceVnd ?? card.priceVnd,
          distanceKm: clearDistanceKm ? null : distanceKm ?? card.distanceKm,
          needsBooking:
              clearNeedsBooking ? null : needsBooking ?? card.needsBooking,
          indoorOutdoor:
              clearIndoorOutdoor ? null : indoorOutdoor ?? card.indoorOutdoor,
          note: clearNote ? null : note ?? card.note,
          sourceLink: clearSourceLink ? null : sourceLink ?? card.sourceLink,
          invited: invited ?? card.invited,
          replyState: replyState ?? card.replyState,
          createdAt: card.createdAt,
          // `updated_at` belongs to the repository, which owns normalization
          // and timestamps (`contract-summary.md` §3). A screen-local edit
          // does not get to invent one.
          updatedAt: card.updatedAt,
        ),
      ),
    );
  }
}
