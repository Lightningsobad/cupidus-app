import 'synced_reminder.dart';

/// Per-viewer derivation of the server-owned [SyncedReminder.status].
enum ReminderStage {
  needsMyConfirmation,
  awaitingPartner,
  bothConfirmed,
  firing,
  cleared,
  needsMyToggleConfirmation,
  needsMyDeleteConfirmation,
}

extension SyncedReminderStage on SyncedReminder {
  ReminderStage stageFor(String viewerUserId) {
    switch (status) {
      case 'pending_confirmation':
        return viewerUserId == partnerId
            ? ReminderStage.needsMyConfirmation
            : ReminderStage.awaitingPartner;
      case 'pending_toggle':
        return viewerUserId == partnerId
            ? ReminderStage.needsMyToggleConfirmation
            : ReminderStage.awaitingPartner;
      case 'pending_deletion':
        return viewerUserId == partnerId
            ? ReminderStage.needsMyDeleteConfirmation
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

  bool hasDismissed(String userId) => stopperIds.contains(userId);
}
