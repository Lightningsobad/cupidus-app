import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/features/phase_status/data/local_notification_scheduler.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/domain/evening_check_in_scheduler.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:cupid_mobile/features/phase_status/domain/solo_phase.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show AndroidScheduleMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget-free tests ship no asset bundle, so the real nudge pack is read off
/// disk. The reminder's words must come from the pack and from nowhere else.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

class _Scheduled {
  const _Scheduled({
    required this.id,
    required this.at,
    required this.body,
    this.title,
    this.payload,
  });

  final int id;
  final DateTime at;
  final String body;
  final String? title;
  final String? payload;
}

class _FakeNotifications implements LocalNotificationScheduler {
  _FakeNotifications({this.granted = true});

  final bool granted;

  int permissionRequests = 0;
  int cancelAllCalls = 0;
  final List<_Scheduled> scheduled = <_Scheduled>[];
  final List<int> cancelled = <int>[];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String body,
    String? title,
    String? payload,
  }) async {
    scheduled.add(
      _Scheduled(id: id, at: at, body: body, title: title, payload: payload),
    );
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

const String _schedulerPath =
    'lib/features/phase_status/data/local_notification_scheduler.dart';
const String _domainPath =
    'lib/features/phase_status/domain/evening_check_in_scheduler.dart';
const String _manifestPath = 'android/app/src/main/AndroidManifest.xml';

const PhaseResolution _dateDay = PhaseResolution(
  phase: SoloPhase.dateDay,
  cardId: 'card-42',
  scheduledOn: '2026-09-17',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeNotifications notifications;
  late PhaseStatusPrefs prefs;
  late PhaseContentRepository content;

  EveningCheckInScheduler build({bool granted = true}) {
    notifications = _FakeNotifications(granted: granted);
    return EveningCheckInScheduler(
      notifications: notifications,
      prefs: prefs,
      content: content,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = PhaseStatusPrefs();
    content = PhaseContentRepository(bundle: _DiskBundle());
  });

  group('REMIND-REPEAT: at most one reminder per card (AC-16/BR-10)', () {
    test('five app opens on the date day queue exactly one', () async {
      final EveningCheckInScheduler scheduler = build();

      for (int open = 0; open < 5; open++) {
        await scheduler.sync(_dateDay);
      }

      expect(notifications.scheduled, hasLength(1));
      expect(notifications.permissionRequests, 1);
    });

    test('the record survives a fresh scheduler over the same store', () async {
      await build().sync(_dateDay);
      final EveningCheckInScheduler secondRun = build();

      await secondRun.sync(_dateDay);

      expect(notifications.scheduled, isEmpty);
      expect(notifications.permissionRequests, isZero);
    });

    test('a different card is a different reminder', () async {
      final EveningCheckInScheduler scheduler = build();

      await scheduler.sync(_dateDay);
      await scheduler.sync(
        const PhaseResolution(
          phase: SoloPhase.dateDay,
          cardId: 'card-7',
          scheduledOn: '2026-10-01',
        ),
      );

      expect(notifications.scheduled, hasLength(2));
      expect(
        notifications.scheduled.map((_Scheduled s) => s.id).toSet(),
        hasLength(2),
      );
    });
  });

  group('what gets queued', () {
    test('carries the pack copy, not a literal in the source (AC-37)',
        () async {
      final NudgeItem? nudge = eveningCheckInNudge(await content.catalogue());
      expect(nudge, isNotNull, reason: 'nudges.v1.json has no evening slot');

      await build().sync(_dateDay);

      expect(notifications.scheduled.single.body, nudge!.body);
      expect(notifications.scheduled.single.title, nudge.title);
    });

    test('lands in the evening of the card date, in local time', () async {
      await build().sync(_dateDay);

      final DateTime at = notifications.scheduled.single.at;
      expect(at, DateTime(2026, 9, 17, eveningCheckInHour));
      expect(at.isUtc, isFalse);
      expect(eveningCheckInHour, 23);
    });

    test('carries the card id so a tap knows where to land', () async {
      await build().sync(_dateDay);

      expect(notifications.scheduled.single.payload, 'card-42');
      expect(
        notifications.scheduled.single.id,
        eveningCheckInNotificationId('card-42'),
      );
    });

    test('the id is stable, non-negative and inside the 32-bit range', () {
      expect(
        eveningCheckInNotificationId('card-42'),
        eveningCheckInNotificationId('card-42'),
      );
      for (final String cardId in <String>['a', 'card-42', 'x' * 200]) {
        final int id = eveningCheckInNotificationId(cardId);
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThan(1 << 31));
      }
    });
  });

  group('phases that must stay silent', () {
    test('no reminder outside the date day', () async {
      final EveningCheckInScheduler scheduler = build();

      await scheduler.sync(
        const PhaseResolution(
          phase: SoloPhase.upcoming,
          cardId: 'card-42',
          scheduledOn: '2026-09-17',
        ),
      );
      await scheduler.sync(const PhaseResolution(phase: SoloPhase.quiet));
      await scheduler.sync(const PhaseResolution(phase: SoloPhase.waiting));

      expect(notifications.scheduled, isEmpty);
      expect(notifications.permissionRequests, isZero);
    });

    test('a date day without a card or a date queues nothing', () async {
      final EveningCheckInScheduler scheduler = build();

      await scheduler.sync(
        const PhaseResolution(phase: SoloPhase.dateDay, cardId: 'card-42'),
      );
      await scheduler.sync(
        const PhaseResolution(
          phase: SoloPhase.dateDay,
          scheduledOn: '2026-09-17',
        ),
      );

      expect(notifications.scheduled, isEmpty);
    });
  });

  test('a dismissed before-you-go card still gets its evening reminder (A-2)',
      () async {
    await build().sync(
      const PhaseResolution(
        phase: SoloPhase.dateDay,
        cardId: 'card-42',
        scheduledOn: '2026-09-17',
        isBeforeYouGoDismissed: true,
      ),
    );

    expect(notifications.scheduled, hasLength(1));
  });

  group('permission refused (AC-31)', () {
    test('nothing is queued and the ask is never repeated', () async {
      final EveningCheckInScheduler scheduler = build(granted: false);

      expect(await scheduler.sync(_dateDay), isFalse);
      await scheduler.sync(_dateDay);
      await scheduler.sync(_dateDay);

      expect(notifications.scheduled, isEmpty);
      expect(notifications.permissionRequests, 1);
    });

    test('the refusal is recorded, so the OS dialog is a one-time event',
        () async {
      await build(granted: false).sync(_dateDay);

      expect(await prefs.remindedOn('card-42'), '2026-09-17');
    });
  });

  group('the settings switch (AC-30/AC-32)', () {
    test('off means nothing is queued and nothing is asked', () async {
      await prefs.setEveningCheckInEnabled(false);
      final EveningCheckInScheduler scheduler = build();

      expect(await scheduler.sync(_dateDay), isFalse);

      expect(notifications.scheduled, isEmpty);
      expect(notifications.permissionRequests, isZero);
      expect(await prefs.remindedOn('card-42'), isNull);
    });

    test('switching off drops what is already queued', () async {
      final EveningCheckInScheduler scheduler = build();
      await scheduler.sync(_dateDay);

      await scheduler.setEnabled(false);

      expect(notifications.cancelAllCalls, 1);
      expect(await scheduler.isEnabled(), isFalse);
    });

    test('switching on cancels nothing and queues nothing by itself', () async {
      final EveningCheckInScheduler scheduler = build();

      await scheduler.setEnabled(true);

      expect(notifications.cancelAllCalls, isZero);
      expect(notifications.scheduled, isEmpty);
      expect(await scheduler.isEnabled(), isTrue);
    });

    test('defaults to on before any switch is touched', () async {
      expect(await build().isEnabled(), isTrue);
    });
  });

  test('a broken content pack silences the reminder instead of the app',
      () async {
    notifications = _FakeNotifications();
    final EveningCheckInScheduler scheduler = EveningCheckInScheduler(
      notifications: notifications,
      prefs: prefs,
      content: PhaseContentRepository(bundle: _ThrowingBundle()),
    );

    expect(await scheduler.sync(_dateDay), isFalse);
    expect(notifications.scheduled, isEmpty);
  });

  group('source scan', () {
    late String schedulerSource;
    late String domainSource;
    late String manifest;

    setUp(() {
      schedulerSource = File(_schedulerPath).readAsStringSync();
      domainSource = File(_domainPath).readAsStringSync();
      manifest = File(_manifestPath).readAsStringSync();

      // Non-vacuity: every assertion below is a substring search, so an empty
      // or moved file would pass each one of them silently.
      expect(schedulerSource, contains('class PluginLocalNotificationScheduler'));
      expect(domainSource, contains('class EveningCheckInScheduler'));
      expect(manifest, contains('<uses-permission'));
    });

    test('the alarm is inexact, so the OS may batch it (AC-32/BR-14)', () {
      expect(
        schedulerSource,
        contains('AndroidScheduleMode.inexactAllowWhileIdle'),
      );
      expect(
        eveningCheckInScheduleMode,
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
      expect(
        RegExp(r'(?<!in)exactAllowWhileIdle').hasMatch(schedulerSource),
        isFalse,
        reason: 'an exact alarm would need SCHEDULE_EXACT_ALARM and would be '
            'the kind of demanding reminder BR-14 rules out',
      );
      expect(schedulerSource.contains('AndroidScheduleMode.exact'), isFalse);
    });

    test('no exact-alarm permission is requested', () {
      expect(manifest.contains('SCHEDULE_EXACT_ALARM'), isFalse);
      expect(manifest.contains('USE_EXACT_ALARM'), isFalse);
      expect(
        manifest,
        contains('android.permission.POST_NOTIFICATIONS'),
        reason: 'already declared before this phase; a reminder with no '
            'permission line would never be delivered on Android 13+',
      );
    });

    test('the reminder is quiet: no sound, no vibration, no badge (BR-14)', () {
      for (final String quiet in <String>[
        'playSound: false',
        'enableVibration: false',
        'channelShowBadge: false',
        'presentSound: false',
        'presentBadge: false',
      ]) {
        expect(schedulerSource, contains(quiet), reason: quiet);
      }
    });

    test('no display string is compiled into either file (AC-37/BR-15)', () {
      for (final String source in <String>[schedulerSource, domainSource]) {
        final List<String> code = source
            .split('\n')
            .where((String line) => !line.trimLeft().startsWith('//'))
            .toList(growable: false);
        expect(code, isNotEmpty);

        for (final String line in code) {
          expect(
            RegExp(r'[^\x00-\x7F]').hasMatch(line),
            isFalse,
            reason: 'a non-ASCII character outside a comment is Vietnamese '
                'copy that belongs in nudges.v1.json: $line',
          );
        }
      }
    });
  });
}

class _ThrowingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('content pack unavailable');
}
