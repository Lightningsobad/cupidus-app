import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/cupid_api.dart';
import '../core/realtime/backend_user_id_store.dart';
import '../core/realtime/cupid_realtime.dart';
import '../features/reminders/data/reminder_local_prefs.dart';
import '../features/reminders/data/reminder_repository.dart';
import '../features/reminders/domain/synced_reminder.dart';
import '../features/reminders/presentation/reminder_firing_cubit.dart';
import '../features/reminders/presentation/reminder_schedule_bloc.dart';
import '../features/reminders/presentation/reminder_schedule_state.dart';
import '../features/reminders/presentation/screens/reminder_schedule_screen.dart';
import '../features/reminders/presentation/widgets/reminder_firing_overlay.dart';

/// Preview fixture for the `alarm` / reminders screens.
class PreviewReminderFixture extends StatefulWidget {
  const PreviewReminderFixture({super.key, required this.ringing});

  final bool ringing;

  @override
  State<PreviewReminderFixture> createState() => _PreviewReminderFixtureState();
}

class _PreviewReminderFixtureState extends State<PreviewReminderFixture> {
  static const String _viewerId = 'user-partner';
  static const String _requesterId = 'user-requester';
  static const Duration _seedTimeout = Duration(seconds: 10);

  static final DateTime _reminderTime1 = DateTime(2026, 7, 30, 6, 30).toUtc();
  static final DateTime _reminderTime2 = DateTime(2026, 7, 30, 12, 0).toUtc();
  static final DateTime _reminderTime3 = DateTime(2026, 7, 30, 22, 30).toUtc();

  late final Future<ReminderScheduleBloc> _bloc = _seedBloc();

  Future<ReminderScheduleBloc> _seedBloc() async {
    final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
      ..updateFromLoginResponse(<String, Object?>{'id': _viewerId});
    final ReminderLocalPrefs localPrefs = ReminderLocalPrefs();
    await localPrefs.saveWeekdays(const <int>{1, 2, 3, 4, 5});

    final ReminderScheduleBloc bloc = ReminderScheduleBloc(
      repository: ReminderRepository(
        api: CupidApi(
          dio: Dio()..httpClientAdapter = _CannedRowAdapter(_rowsJson()),
          interceptors: const <Interceptor>[],
        ),
        realtime: _InertRealtimeCoordinator(),
        backendUserIdStore: backendUserIdStore,
      ),
      localPrefs: localPrefs,
      backendUserIdStore: backendUserIdStore,
    );

    final Future<ReminderScheduleState> hydrated = bloc.stream.firstWhere(
      (ReminderScheduleState state) => !state.isLoading,
    );
    bloc.add(const ReminderScheduleStarted());
    await hydrated.timeout(
      _seedTimeout,
      onTimeout: () => throw TimeoutException(
        'ReminderScheduleBloc never left isLoading',
        _seedTimeout,
      ),
    );
    return bloc;
  }

  List<Map<String, Object?>> _rowsJson() => <Map<String, Object?>>[
    <String, Object?>{
      'id': 'preview-reminder-1',
      'time': _reminderTime1.toIso8601String(),
      'description': '🌅 Thức dậy cùng Bae',
      'weekdays': <String>['1', '2', '3', '4', '5'],
      'isActive': true,
      'status': 'scheduled',
      'requesterId': _requesterId,
      'partnerId': _viewerId,
      'stopperIds': <String>[],
    },
    <String, Object?>{
      'id': 'preview-reminder-2',
      'time': _reminderTime2.toIso8601String(),
      'description': '💊 Uống vitamin & ăn trưa',
      'weekdays': <String>['1', '2', '3', '4', '5', '6', '7'],
      'isActive': true,
      'status': 'pending_confirmation',
      'requesterId': _requesterId,
      'partnerId': _viewerId,
      'stopperIds': <String>[],
    },
    <String, Object?>{
      'id': 'preview-reminder-3',
      'time': _reminderTime3.toIso8601String(),
      'description': '💤 Đi ngủ đúng giờ',
      'weekdays': <String>['1', '2', '3', '4', '5', '6', '7'],
      'isActive': false,
      'status': 'scheduled',
      'requesterId': _viewerId,
      'partnerId': _requesterId,
      'stopperIds': <String>[],
    },
  ];

  ReminderFiringOpen get _firingState => ReminderFiringOpen(
    reminder: SyncedReminder(
      id: 'preview-reminder-1',
      time: _reminderTime1,
      description: '🌅 Thức dậy cùng Bae',
      isActive: true,
      status: 'ringing',
      requesterId: _requesterId,
      partnerId: _viewerId,
      stopperIds: const <String>{},
    ),
    viewerId: _viewerId,
  );

  @override
  void dispose() {
    _bloc.then((ReminderScheduleBloc bloc) => bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReminderScheduleBloc>(
      future: _bloc,
      builder: (BuildContext context, AsyncSnapshot<ReminderScheduleBloc> snapshot) {
        if (snapshot.hasError) {
          return _PreviewSeedFailure(error: snapshot.error!);
        }
        final ReminderScheduleBloc? bloc = snapshot.data;
        if (bloc == null) {
          return const _PreviewSeedPending();
        }
        final Widget schedule = BlocProvider<ReminderScheduleBloc>.value(
          value: bloc,
          child: const ReminderScheduleView(),
        );
        if (!widget.ringing) {
          return schedule;
        }
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            schedule,
            ReminderFiringOverlay(
              state: _firingState,
              onDismiss: () {},
            ),
          ],
        );
      },
    );
  }
}

class _PreviewSeedPending extends StatelessWidget {
  const _PreviewSeedPending();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF171129),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7FB6)),
          ),
        ),
      ),
    );
  }
}

class _PreviewSeedFailure extends StatelessWidget {
  const _PreviewSeedFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF2A0812),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, color: Color(0xFFFF6F91), size: 36),
              const SizedBox(height: 12),
              const Text(
                'Preview seed failed',
                style: TextStyle(
                  color: Color(0xFFF7EEFB),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: const TextStyle(color: Color(0xFFFFE4E6), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CannedRowAdapter implements HttpClientAdapter {
  _CannedRowAdapter(this._body);

  final Object _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}

class _InertRealtimeCoordinator implements RealtimeCoordinator {
  @override
  Stream<RealtimeEvent> events({Set<String>? names}) =>
      const Stream<RealtimeEvent>.empty();

  @override
  Stream<RealtimeStatus> get status => const Stream<RealtimeStatus>.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> emit(String name, Object? payload) async {}

  @override
  Future<void> resync() async {}
}
