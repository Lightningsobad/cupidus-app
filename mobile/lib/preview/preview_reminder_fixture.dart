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

/// STORY-021 F-1 capture fixture for the `alarm` design-canvas screen.
///
/// The DI-backed `ReminderScheduleScreen` hydrates into its error state with no
/// backend, and the firing overlay only mounts once `ReminderFiringCubit`
/// receives a server `triggerAlarm`. Neither AC-bearing state is reachable on a
/// capture emulator, so both are authored here instead — the
/// "FAKE the state, not navigate to it" rule in `main_preview.dart`'s header.
///
/// Selected with `--dart-define=PREVIEW_REMINDER_STATE=schedule|ringing`;
/// omitting the define leaves the live DI-backed screen untouched.
class PreviewReminderFixture extends StatefulWidget {
  const PreviewReminderFixture({super.key, required this.ringing});

  /// Renders the `alarmRinging` overlay above the schedule screen, the way
  /// `ReminderOverlayHost` mounts it in the real app.
  final bool ringing;

  @override
  State<PreviewReminderFixture> createState() => _PreviewReminderFixtureState();
}

class _PreviewReminderFixtureState extends State<PreviewReminderFixture> {
  static const String _viewerId = 'user-partner';
  static const String _requesterId = 'user-requester';
  static const Duration _seedTimeout = Duration(seconds: 10);

  /// 06:30 *local* on any host timezone, matching the design reference's clock
  /// readout — the overlay formats `time.toLocal()`.
  static final DateTime _reminderTime = DateTime(2026, 7, 30, 6, 30).toUtc();

  late final Future<ReminderScheduleBloc> _bloc = _seedBloc();

  Future<ReminderScheduleBloc> _seedBloc() async {
    final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
      ..updateFromLoginResponse(<String, Object?>{'id': _viewerId});
    final ReminderLocalPrefs localPrefs = ReminderLocalPrefs();
    // T2-T6 selected, as in the design reference.
    await localPrefs.saveWeekdays(const <int>{1, 2, 3, 4, 5});

    final ReminderScheduleBloc bloc = ReminderScheduleBloc(
      repository: ReminderRepository(
        api: CupidApi(
          dio: Dio()..httpClientAdapter = _CannedRowAdapter(_rowJson()),
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
    // Without this bound a stalled hydrate leaves the fixture pending forever,
    // and a capture taken meanwhile is indistinguishable from a real one.
    await hydrated.timeout(
      _seedTimeout,
      onTimeout: () => throw TimeoutException(
        'ReminderScheduleBloc never left isLoading',
        _seedTimeout,
      ),
    );
    return bloc;
  }

  /// `pending_confirmation` seen by the partner resolves to the
  /// `needsMyConfirmation` stage the design reference shows.
  Map<String, Object?> _rowJson() => <String, Object?>{
    'id': 'preview-reminder',
    'time': _reminderTime.toIso8601String(),
    'isActive': true,
    'status': 'pending_confirmation',
    'requesterId': _requesterId,
    'partnerId': _viewerId,
    'stopperIds': <String>[],
  };

  ReminderFiringOpen get _firingState => ReminderFiringOpen(
    reminder: SyncedReminder(
      id: 'preview-reminder',
      time: _reminderTime,
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
          children: <Widget>[
            schedule,
            ReminderFiringOverlay(state: _firingState, onDismiss: () {}),
          ],
        );
      },
    );
  }
}

/// Rule 12e3 rejects a capture of a spinner or an error screen, so both states
/// below are deliberately loud: a fixture that fails to seed must produce a
/// rejected screenshot, never a plausible-looking empty one.
class _PreviewSeedPending extends StatelessWidget {
  const _PreviewSeedPending();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('PREVIEW FIXTURE SEEDING'),
          ],
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
    return Scaffold(
      backgroundColor: const Color(0xFF7F1D1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'PREVIEW FIXTURE SEED FAILED',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
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

  final Map<String, Object?> _body;

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
