import 'synced_reminder.dart';

/// Per-viewer derivation of the server-owned [SyncedReminder.status]
/// (`architecture/solution.md` §4 D3). The backend has no per-user
/// confirmation column, so every value here is computed client-side.
enum ReminderStage {
  needsMyConfirmation,
  awaitingPartner,
  bothConfirmed,
  firing,
  cleared,
}

extension SyncedReminderStage on SyncedReminder {
  /// §4 D3 mapping: `pending_confirmation` + viewer is [partnerId] ->
  /// [ReminderStage.needsMyConfirmation]; `pending_confirmation` + viewer is
  /// [requesterId] -> [ReminderStage.awaitingPartner]; `scheduled` ->
  /// [ReminderStage.bothConfirmed]; `ringing` -> [ReminderStage.firing];
  /// `stopped` -> [ReminderStage.cleared].
  ReminderStage stageFor(String viewerUserId) {
    switch (status) {
      case 'pending_confirmation':
        return viewerUserId == partnerId
            ? ReminderStage.needsMyConfirmation
            : ReminderStage.awaitingPartner;
      case 'scheduled':
        return ReminderStage.bothConfirmed;
      case 'ringing':
        return ReminderStage.firing;
      case 'stopped':
      default:
        return ReminderStage.cleared;
    }
  }

  /// Per-partner firing label support: whether [userId] has already stopped
  /// the current `ringing` reminder.
  bool hasDismissed(String userId) => stopperIds.contains(userId);
}
