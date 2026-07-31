import 'package:cupid_mobile/features/reminders/domain/reminder_stage.dart';
import 'package:cupid_mobile/features/reminders/domain/synced_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _row({
  String status = 'pending_confirmation',
  Object? stopperIds,
}) => {
  'id': 'alarm-1',
  'time': '2026-07-30T06:00:00.000Z',
  'isActive': true,
  'status': status,
  'requesterId': 'user-requester',
  'partnerId': 'user-partner',
  'stopperIds': stopperIds,
};

void main() {
  group('SyncedReminder.fromJson', () {
    test('returns null when the body is null', () {
      expect(SyncedReminder.fromJson(null), isNull);
    });

    test('parses a full row and its stopperIds list', () {
      final reminder = SyncedReminder.fromJson(
        _row(stopperIds: ['user-requester']),
      )!;

      expect(reminder.id, 'alarm-1');
      expect(reminder.time, DateTime.parse('2026-07-30T06:00:00.000Z'));
      expect(reminder.isActive, isTrue);
      expect(reminder.status, 'pending_confirmation');
      expect(reminder.requesterId, 'user-requester');
      expect(reminder.partnerId, 'user-partner');
      expect(reminder.stopperIds, {'user-requester'});
    });

    test('tolerates a missing stopperIds key', () {
      final row = _row()..remove('stopperIds');
      final reminder = SyncedReminder.fromJson(row)!;

      expect(reminder.stopperIds, isEmpty);
    });

    test('tolerates an empty stopperIds list', () {
      final reminder = SyncedReminder.fromJson(_row(stopperIds: []))!;

      expect(reminder.stopperIds, isEmpty);
    });
  });

  group('SyncedReminderStage.stageFor', () {
    test(
      'pending_confirmation + viewer is partnerId -> needsMyConfirmation',
      () {
        final reminder = SyncedReminder.fromJson(_row(stopperIds: []))!;

        expect(
          reminder.stageFor('user-partner'),
          ReminderStage.needsMyConfirmation,
        );
      },
    );

    test('pending_confirmation + viewer is requesterId -> awaitingPartner', () {
      final reminder = SyncedReminder.fromJson(_row(stopperIds: []))!;

      expect(
        reminder.stageFor('user-requester'),
        ReminderStage.awaitingPartner,
      );
    });

    test('scheduled -> bothConfirmed', () {
      final reminder = SyncedReminder.fromJson(
        _row(status: 'scheduled', stopperIds: []),
      )!;

      expect(reminder.stageFor('user-partner'), ReminderStage.bothConfirmed);
      expect(reminder.stageFor('user-requester'), ReminderStage.bothConfirmed);
    });

    test('ringing -> firing', () {
      final reminder = SyncedReminder.fromJson(
        _row(status: 'ringing', stopperIds: []),
      )!;

      expect(reminder.stageFor('user-partner'), ReminderStage.firing);
      expect(reminder.stageFor('user-requester'), ReminderStage.firing);
    });

    test('stopped -> cleared', () {
      final reminder = SyncedReminder.fromJson(
        _row(status: 'stopped', stopperIds: []),
      )!;

      expect(reminder.stageFor('user-partner'), ReminderStage.cleared);
      expect(reminder.stageFor('user-requester'), ReminderStage.cleared);
    });
  });

  group('SyncedReminderStage.hasDismissed', () {
    test('is true for a user id present in stopperIds', () {
      final reminder = SyncedReminder.fromJson(
        _row(status: 'ringing', stopperIds: ['user-partner']),
      )!;

      expect(reminder.hasDismissed('user-partner'), isTrue);
      expect(reminder.hasDismissed('user-requester'), isFalse);
    });
  });
}
