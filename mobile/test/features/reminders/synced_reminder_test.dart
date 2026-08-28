import 'package:cupid_mobile/features/reminders/domain/reminder_stage.dart';
import 'package:cupid_mobile/features/reminders/domain/synced_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _row({
  String status = 'pending_confirmation',
  Object? stopperIds,
  String description = 'Thức dậy',
  Object? weekdays,
}) => {
  'id': 'alarm-1',
  'time': '2026-07-30T06:00:00.000Z',
  'description': description,
  'weekdays': weekdays ?? ['1', '2', '3', '4', '5'],
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

    test('parses a full row and its stopperIds and weekdays list', () {
      final reminder = SyncedReminder.fromJson(
        _row(stopperIds: ['user-requester']),
      )!;

      expect(reminder.id, 'alarm-1');
      expect(reminder.time, DateTime.parse('2026-07-30T06:00:00.000Z'));
      expect(reminder.description, 'Thức dậy');
      expect(reminder.weekdays, {1, 2, 3, 4, 5});
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

    test('pending_toggle + viewer is partnerId -> needsMyToggleConfirmation', () {
      final reminder = SyncedReminder.fromJson(_row(status: 'pending_toggle'))!;
      expect(
        reminder.stageFor('user-partner'),
        ReminderStage.needsMyToggleConfirmation,
      );
    });

    test('pending_deletion + viewer is partnerId -> needsMyDeleteConfirmation', () {
      final reminder = SyncedReminder.fromJson(_row(status: 'pending_deletion'))!;
      expect(
        reminder.stageFor('user-partner'),
        ReminderStage.needsMyDeleteConfirmation,
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
}
