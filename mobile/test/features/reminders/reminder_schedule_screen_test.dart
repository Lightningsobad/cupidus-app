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
import 'package:cupid_mobile/features/reminders/presentation/widgets/add_edit_reminder_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Map<String, Object?> _row({
  required String status,
  String? time,
  String id = 'alarm-1',
  String description = 'Thức dậy cùng Bae',
  bool isActive = true,
}) => {
  'id': id,
  'time': time ?? '2026-07-30T06:30:00.000Z',
  'description': description,
  'weekdays': ['1', '2', '3', '4', '5'],
  'isActive': isActive,
  'status': status,
  'requesterId': 'user-requester',
  'partnerId': 'user-partner',
  'stopperIds': <String>[],
};

Future<ReminderScheduleBloc> _seededBloc(
  WidgetTester tester, {
  required List<Map<String, Object?>> rows,
  bool viewerIsRequester = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final bloc = await tester.runAsync(() async {
    final backendUserIdStore = BackendUserIdStore()
      ..updateFromLoginResponse({
        'id': viewerIsRequester ? 'user-requester' : 'user-partner',
      });
    final bloc = ReminderScheduleBloc(
      repository: ReminderRepository(
        api: _apiReturningInOrder([rows]),
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: backendUserIdStore,
      ),
      localPrefs: ReminderLocalPrefs(),
      backendUserIdStore: backendUserIdStore,
    );
    final hydrated = bloc.stream.firstWhere((state) => !state.isLoading);
    bloc.add(const ReminderScheduleStarted());
    await hydrated;
    return bloc;
  });
  return bloc!;
}

Widget _harness(ReminderScheduleBloc bloc, {Locale locale = const Locale('vi')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: BlocProvider<ReminderScheduleBloc>.value(
      value: bloc,
      child: const ReminderScheduleView(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReminderScheduleView Multi-Alarm and Agreement UI', () {
    testWidgets('renders alarm cards with time, description, and toggle switch', (tester) async {
      final bloc = await _seededBloc(
        tester,
        rows: [
          _row(status: 'scheduled', description: 'Thức dậy cùng Bae'),
          _row(id: 'alarm-2', status: 'scheduled', description: 'Uống thuốc', isActive: false),
        ],
      );

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Thức dậy cùng Bae'), findsOneWidget);
      expect(find.text('Uống thuốc'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNWidgets(2));
    });

    testWidgets('empty state renders with Add CTA button', (tester) async {
      final bloc = await _seededBloc(tester, rows: []);

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reminder_empty_add_cta')), findsOneWidget);
    });

    testWidgets('tapping Add button opens AddEditReminderSheet', (tester) async {
      final bloc = await _seededBloc(tester, rows: []);

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reminder_add_appbar_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditReminderSheet), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('partner confirmation banner renders for pending alarm', (tester) async {
      final bloc = await _seededBloc(
        tester,
        rows: [_row(status: 'pending_confirmation')],
        viewerIsRequester: false,
      );

      await tester.pumpWidget(_harness(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Đồng ý'), findsOneWidget);
      expect(find.text('Từ chối'), findsOneWidget);
    });
  });
}
