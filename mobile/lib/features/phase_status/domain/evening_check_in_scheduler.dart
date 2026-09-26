import '../data/local_notification_scheduler.dart';
import '../data/phase_content_repository.dart';
import '../data/phase_status_prefs.dart';
import 'phase_content.dart';
import 'solo_phase.dart';

/// The hour of the date day the nudge is set for (`ux/uiux-spec.md` §4).
const int eveningCheckInHour = 23;

/// A stable id per card, so a repeat sync replaces that card's own pending
/// notification instead of queueing a second one. Dart's `String.hashCode` is
/// not stable across runs and a cancel issued in a later run has to find the
/// same id, so the fold is written out here.
int eveningCheckInNotificationId(String cardId) {
  int hash = 0;
  for (final int unit in cardId.codeUnits) {
    hash = (hash * 31 + unit) & 0x3FFFFFFF;
  }
  return hash;
}

/// The one item of `nudges.v1.json` this reminder may draw from. `null` when
/// the pack ships without the slot, which silences the reminder rather than
/// substituting a hardcoded sentence (AC-37/BR-15).
NudgeItem? eveningCheckInNudge(PhaseContentCatalogue catalogue) {
  for (final NudgeItem item in catalogue.nudges.items) {
    if (item.slot == NudgeSlot.eveningCheckIn) {
      return item;
    }
  }
  return null;
}

/// Sets the one 23h nudge a date day is allowed (AC-16), and nothing else.
///
/// The whole rule lives in [sync]: a card whose
/// `phase_status.reminded_on.<cardId>` already holds a value is finished with
/// this reminder forever, whether it fired, was skipped, or was refused
/// permission. There is no escalation, no second attempt and no catch-up when
/// the app is opened later — `REMIND-REPEAT`, BR-10, AC-17.
class EveningCheckInScheduler {
  EveningCheckInScheduler({
    required this.notifications,
    PhaseStatusPrefs? prefs,
    PhaseContentRepository? content,
  })  : _prefs = prefs ?? PhaseStatusPrefs(),
        _content = content ?? PhaseContentRepository();

  final LocalNotificationScheduler notifications;
  final PhaseStatusPrefs _prefs;
  final PhaseContentRepository _content;

  /// `true` when this call put a notification on the queue.
  ///
  /// Never throws: a failed prefs or pack read leaves the hub drawing its
  /// phase line with no reminder queued, which is the degraded state BR-2 asks
  /// for.
  Future<bool> sync(PhaseResolution resolution) async {
    try {
      return await _sync(resolution);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _sync(PhaseResolution resolution) async {
    if (resolution.phase != SoloPhase.dateDay) {
      return false;
    }
    final String? cardId = resolution.cardId;
    final String? scheduledOn = resolution.scheduledOn;
    if (cardId == null || scheduledOn == null) {
      return false;
    }
    if (!await _prefs.eveningCheckInEnabled()) {
      return false;
    }
    if (await _prefs.remindedOn(cardId) != null) {
      return false;
    }

    final NudgeItem? nudge = eveningCheckInNudge(await _content.catalogue());
    if (nudge == null) {
      return false;
    }

    // Asked here rather than at app startup, and asked at most once per card:
    // the key below is written on the refusal branch too, so a denial ends in
    // silence instead of the same prompt on every open.
    final bool granted = await notifications.requestPermission();
    if (granted) {
      await notifications.schedule(
        id: eveningCheckInNotificationId(cardId),
        at: _eveningOf(scheduledOn),
        title: nudge.title,
        body: nudge.body,
        payload: cardId,
      );
    }
    await _prefs.markReminded(cardId, scheduledOn);
    return granted;
  }

  /// Turns the "Nhắc về tới nhà chưa?" row on or off (AC-30/AC-32). Off
  /// cancels what is already pending, so the switch takes effect on a
  /// notification queued minutes earlier rather than only on the next one.
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setEveningCheckInEnabled(enabled);
    if (!enabled) {
      await notifications.cancelAll();
    }
  }

  Future<bool> isEnabled() => _prefs.eveningCheckInEnabled();

  DateTime _eveningOf(String scheduledOnIso) {
    final DateTime day = DateTime.parse(scheduledOnIso);
    return DateTime(day.year, day.month, day.day, eveningCheckInHour);
  }
}
