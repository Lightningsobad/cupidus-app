import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_schedule_bloc.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_strings.dart';
import 'package:cupid_mobile/features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Same low-level-fake-transport approach as
/// `test/features/reminders/reminder_schedule_bloc_test.dart`.
class _QueueHttpClientAdapter implements HttpClientAdapter {
  _QueueHttpClientAdapter(this._bodies);

  final List<Object?> _bodies;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = _bodies.length > 1 ? _bodies.removeAt(0) : _bodies.first;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

CupidApi _apiReturningInOrder(List<Object?> bodies) {
  final dio = Dio()..httpClientAdapter = _QueueHttpClientAdapter(bodies);
  return CupidApi(dio: dio, interceptors: const []);
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final emitted = <MapEntry<String, Object?>>[];
  final _events = StreamController<RealtimeEvent>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final stream = _events.stream;
    return names == null
        ? stream
        : stream.where((e) => names.contains(e.name));
  }

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> emit(String name, Object? payload) async {
    emitted.add(MapEntry(name, payload));
  }

  @override
  Future<void> resync() async {}
}

Map<String, Object?> _row({required String status}) => {
  'id': 'alarm-1',
  'time': '2026-07-30T06:00:00.000Z',
  'isActive': true,
  'status': status,
  'requesterId': 'user-requester',
  'partnerId': 'user-partner',
  'stopperIds': <String>[],
};

/// Builds a bloc already hydrated into one of the three schedule stages
/// (viewer is always `user-partner`, per `../architecture/solution.md` §4 D3:
/// `pending_confirmation` + viewer is `partnerId` -> `needsMyConfirmation`;
/// `pending_confirmation` + viewer is `requesterId` -> `awaitingPartner`;
/// `scheduled` -> `bothConfirmed`).
Future<ReminderScheduleBloc> _seededBloc({
  required String status,
  bool viewerIsRequester = false,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse({
      'id': viewerIsRequester ? 'user-requester' : 'user-partner',
    });
  final bloc = ReminderScheduleBloc(
    repository: ReminderRepository(
      api: _apiReturningInOrder([_row(status: status)]),
      realtime: _FakeRealtimeCoordinator(),
      backendUserIdStore: backendUserIdStore,
    ),
    localPrefs: ReminderLocalPrefs(),
    backendUserIdStore: backendUserIdStore,
  );
  bloc.add(const ReminderScheduleStarted());
  await bloc.stream.firstWhere((state) => !state.isLoading);
  return bloc;
}

Widget _harness(ReminderScheduleBloc bloc, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: BlocProvider<ReminderScheduleBloc>.value(
      value: bloc,
      child: const ReminderScheduleView(),
    ),
  );
}

void main() {
  group('ReminderStrings', () {
    testWidgets('resolves vi under Locale(vi) and en otherwise', (
      tester,
    ) async {
      late String enCopy;
      late String viCopy;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (context) {
              enCopy = context.reminderConfirmCta;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (context) {
              viCopy = context.reminderConfirmCta;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(enCopy, 'Confirm this time');
      expect(viCopy, 'Xác nhận giờ này');
    });
  });

  group('ReminderScheduleView primary action', () {
    testWidgets(
      'needsMyConfirmation renders the confirm CTA only',
      (tester) async {
        final bloc = await _seededBloc(status: 'pending_confirmation');
        addTearDown(bloc.close);

        await tester.pumpWidget(_harness(bloc));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(find.text('Confirm this time'), findsOneWidget);
        expect(find.byIcon(CupidIcons.hourglass), findsNothing);
        expect(find.text('Try it now (demo)'), findsNothing);
      },
    );

    testWidgets('awaitingPartner renders the waiting pill only', (
      tester,
    ) async {
      final bloc = await _seededBloc(
        status: 'pending_confirmation',
        viewerIsRequester: true,
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(
        find.text('Waiting for your partner to confirm the synced reminder…'),
        findsOneWidget,
      );
      expect(find.byIcon(CupidIcons.hourglass), findsOneWidget);
      expect(find.text('Confirm this time'), findsNothing);
      expect(find.text('Try it now (demo)'), findsNothing);
    });

    testWidgets('bothConfirmed renders the try-it-now CTA only', (
      tester,
    ) async {
      final bloc = await _seededBloc(status: 'scheduled');
      addTearDown(bloc.close);

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Try it now (demo)'), findsOneWidget);
      expect(find.text('Confirm this time'), findsNothing);
      expect(find.byIcon(CupidIcons.hourglass), findsNothing);
    });
  });

  group('ReminderScheduleView partner confirmation and rule card', () {
    testWidgets(
      'partner confirmation state is conveyed by text alongside colour',
      (tester) async {
        final bloc = await _seededBloc(status: 'pending_confirmation');
        addTearDown(bloc.close);

        await tester.pumpWidget(_harness(bloc));
        await tester.pumpAndSettle();

        expect(find.text('Not confirmed yet'), findsOneWidget);
        expect(find.text('You confirmed ✓'), findsNothing);
        expect(find.text('Confirmed ✓'), findsOneWidget);
      },
    );

    testWidgets('rule card copy includes the 5-minute timeout caveat', (
      tester,
    ) async {
      final bloc = await _seededBloc(status: 'scheduled');
      addTearDown(bloc.close);

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('times out after 5 minutes'),
        findsOneWidget,
      );
    });
  });

  group('ReminderScheduleView glyphs', () {
    testWidgets('the added glyph constants render (no blank glyph box)', (
      tester,
    ) async {
      final bloc = await _seededBloc(status: 'scheduled');
      addTearDown(bloc.close);

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupidIcons.remove), findsOneWidget);
      expect(find.byIcon(CupidIcons.add), findsOneWidget);
      expect(find.byIcon(CupidIcons.swipeRight), findsOneWidget);
    });
  });

  group('nextReminderOccurrence', () {
    test('with no weekday selected, returns today when still in the future', () {
      final now = DateTime(2026, 7, 30, 5, 0); // Thursday 05:00
      final result = nextReminderOccurrence(
        timeOfDay: const TimeOfDay(hour: 6, minute: 0),
        weekdays: const {},
        now: now,
      );

      expect(result, DateTime(2026, 7, 30, 6, 0).toUtc());
    });

    test('with no weekday selected, rolls to tomorrow when today has passed', () {
      final now = DateTime(2026, 7, 30, 7, 0); // Thursday 07:00, after 06:00
      final result = nextReminderOccurrence(
        timeOfDay: const TimeOfDay(hour: 6, minute: 0),
        weekdays: const {},
        now: now,
      );

      expect(result, DateTime(2026, 7, 31, 6, 0).toUtc());
    });

    test('with weekdays selected, returns the same day when still upcoming', () {
      final now = DateTime(2026, 7, 30, 5, 0); // Thursday == DateTime.thursday (4)
      final result = nextReminderOccurrence(
        timeOfDay: const TimeOfDay(hour: 6, minute: 0),
        weekdays: {DateTime.thursday},
        now: now,
      );

      expect(result, DateTime(2026, 7, 30, 6, 0).toUtc());
      expect(result.toLocal().weekday, DateTime.thursday);
    });

    test('wraps to next week when this week\'s occurrence has already passed', () {
      final now = DateTime(2026, 7, 30, 7, 0); // Thursday 07:00, past 06:00
      final result = nextReminderOccurrence(
        timeOfDay: const TimeOfDay(hour: 6, minute: 0),
        weekdays: {DateTime.thursday},
        now: now,
      );

      expect(result, DateTime(2026, 8, 6, 6, 0).toUtc());
      expect(result.toLocal().weekday, DateTime.thursday);
    });

    test('picks the nearest of several selected weekdays', () {
      final now = DateTime(2026, 7, 30, 7, 0); // Thursday 07:00
      final result = nextReminderOccurrence(
        timeOfDay: const TimeOfDay(hour: 6, minute: 0),
        weekdays: {DateTime.monday, DateTime.saturday},
        now: now,
      );

      // Saturday 2026-08-01 is nearer than Monday 2026-08-03.
      expect(result, DateTime(2026, 8, 1, 6, 0).toUtc());
      expect(result.toLocal().weekday, DateTime.saturday);
    });
  });
}
