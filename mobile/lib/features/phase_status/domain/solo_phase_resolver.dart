import '../../activity_cards/domain/activity_card.dart';
import '../../before_you_go/domain/before_you_go_resolver.dart';
import 'solo_phase.dart';

/// The story's one and only "which phase is the nearest card in" answer
/// (`architecture/solution.md` §4 `Lane Handoff`). The phase line on screen (1)
/// and the home-screen widget payload both call this; two independent
/// derivations would drift apart, which is the failure this function exists to
/// prevent.
///
/// Pure by contract: [today] and [beforeYouGo] are parameters, never read from
/// a clock or a repository inside. The same [cards] in any order always give
/// the same result, so the widget and the screen agree even when they resolve
/// seconds apart.
///
/// The rule, in this exact order:
///
/// 1. the `scheduled` card with the nearest `scheduled_on` from today onward —
///    equal to today gives [SoloPhase.dateDay], later gives
///    [SoloPhase.upcoming];
/// 2. otherwise the card with `invited` set and `reply_state` still
///    `not_answered`, newest `updated_at` first, giving [SoloPhase.waiting];
/// 3. otherwise [SoloPhase.quiet], with no card.
///
/// Ties break on ascending `id`.
///
/// A `scheduled` card whose date has already passed matches no branch on its
/// own: it is deliberately skipped in step 1 rather than folded into
/// [SoloPhase.upcoming], because a phase derived from a missed date is exactly
/// the reproachful content AC-15 forbids.
PhaseResolution resolveSoloPhase({
  required List<ActivityCard> cards,
  required DateTime today,
  BeforeYouGoPhase? beforeYouGo,
}) {
  final String todayIso = civilDateIso(today);

  final ActivityCard? nearest = _nearestScheduledFrom(cards, todayIso);
  if (nearest != null) {
    final String scheduledOn = nearest.scheduledOn!;
    if (scheduledOn == todayIso) {
      // STORY-006 owns the "trước giờ đi" state for today, so when it supplied
      // one its card identity wins (AC-1). Absent it, the date alone still
      // produces this phase (AC-2) — this story never becomes a reverse
      // dependency of STORY-006 (AC-3).
      return PhaseResolution(
        phase: SoloPhase.dateDay,
        cardId: beforeYouGo?.cardId ?? nearest.id,
        scheduledOn: scheduledOn,
        isBeforeYouGoDismissed: beforeYouGo?.isDismissed ?? false,
      );
    }
    return PhaseResolution(
      phase: SoloPhase.upcoming,
      cardId: nearest.id,
      scheduledOn: scheduledOn,
    );
  }

  final ActivityCard? awaited = _newestUnanswered(cards);
  if (awaited != null) {
    // No `scheduledOn` on purpose: this is the branch that must not be able to
    // report how long the wait has been (AC-6/AC-7).
    return PhaseResolution(phase: SoloPhase.waiting, cardId: awaited.id);
  }

  return const PhaseResolution(phase: SoloPhase.quiet);
}

/// Dates compare as civil `YYYY-MM-DD` strings, which sort chronologically by
/// construction. That keeps every comparison on the device calendar with no
/// instant, no time zone, and no midnight arithmetic anywhere in the path.
ActivityCard? _nearestScheduledFrom(List<ActivityCard> cards, String todayIso) {
  ActivityCard? best;
  for (final ActivityCard card in cards) {
    if (card.status != ActivityCardStatus.scheduled) {
      continue;
    }
    final String? scheduledOn = card.scheduledOn;
    if (scheduledOn == null || scheduledOn.compareTo(todayIso) < 0) {
      continue;
    }
    if (best == null) {
      best = card;
      continue;
    }
    final int byDate = scheduledOn.compareTo(best.scheduledOn!);
    if (byDate < 0 || (byDate == 0 && card.id.compareTo(best.id) < 0)) {
      best = card;
    }
  }
  return best;
}

/// `reply_state` is the only response signal read here. Nothing about the other
/// person's behaviour is an input, and there is no field on [ActivityCard] that
/// would let one become one (BR-3).
ActivityCard? _newestUnanswered(List<ActivityCard> cards) {
  ActivityCard? best;
  for (final ActivityCard card in cards) {
    if (!card.invited ||
        card.replyState != ActivityCardReplyState.notAnswered) {
      continue;
    }
    if (best == null) {
      best = card;
      continue;
    }
    final int byUpdated = card.updatedAt.compareTo(best.updatedAt);
    if (byUpdated > 0 || (byUpdated == 0 && card.id.compareTo(best.id) < 0)) {
      best = card;
    }
  }
  return best;
}
