import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/cupid_api_failure.dart';
import '../data/ghost_config_models.dart';
import '../data/ghost_config_repository.dart';

/// Injectable seam for the 60s poll timer (mirrors
/// `core/realtime/realtime_coordinator.dart`'s `GraceTimerFactory`), so tests
/// assert start/cancel deterministically instead of waiting on a real timer.
typedef GhostStormPollTimerFactory = Timer Function(
  Duration duration,
  void Function() onTick,
);

Timer _defaultPollTimerFactory(Duration duration, void Function() onTick) =>
    Timer.periodic(duration, (_) => onTick());

/// ADR-2: the single 60s periodic refresh interval, live only while the row
/// is visible (this cubit exists) and the app is foregrounded.
const Duration ghostStormPollInterval = Duration(seconds: 60);

/// STORY-008 P3 (`architecture/solution.md` ADR-2, ADR-3;
/// `coding-plan/phase-P3-chat-ghost-state-row.md`). One of [GhostStormLoading],
/// [GhostStormLoaded], or [GhostStormLoadFailed]. A load failure renders
/// nothing in [GhostStateRow] rather than an error state, since this is a
/// passive, non-primary polling indicator.
sealed class GhostStormState {
  const GhostStormState();
}

class GhostStormLoading extends GhostStormState {
  const GhostStormLoading();
}

class GhostStormLoaded extends GhostStormState {
  const GhostStormLoaded(this.status);

  final StormStatus status;
}

class GhostStormLoadFailed extends GhostStormState {
  const GhostStormLoadFailed(this.failure);

  final Object failure;
}

/// STORY-008 P3: polls `GET /ghost-config/storm-status/:partnerId` for the
/// `GhostStateRow` chat mount seam (ADR-3). Fetch triggers (ADR-2): on
/// construction, on an external [refresh] call (the host screen's own focus
/// hook, once STORY-007 mounts the row), and on app foreground resume via
/// [handleAppLifecycleState]. While the row is visible (this cubit has not
/// been [close]d) and the app is foregrounded, a single 60s periodic timer
/// also triggers [refresh]; the timer is cancelled on [close] and whenever
/// the app leaves the resumed state, and restarted on the next resume. No
/// polling happens in any other state.
class GhostStormCubit extends Cubit<GhostStormState> {
  GhostStormCubit({
    required GhostConfigRepository repository,
    required String partnerId,
    GhostStormPollTimerFactory timerFactory = _defaultPollTimerFactory,
    Duration pollInterval = ghostStormPollInterval,
  })  : _repository = repository,
        _partnerId = partnerId,
        _timerFactory = timerFactory,
        _pollInterval = pollInterval,
        super(const GhostStormLoading()) {
    refresh();
    _startTimer();
  }

  final GhostConfigRepository _repository;
  final String _partnerId;
  final GhostStormPollTimerFactory _timerFactory;
  final Duration _pollInterval;
  Timer? _pollTimer;

  /// External refresh trigger (ADR-2: chat-screen focus, once STORY-007
  /// wires it) and the app-foreground-resume trigger below.
  Future<void> refresh() async {
    try {
      final status = await _repository.fetchStormStatus(_partnerId);
      _emitIfNotClosed(GhostStormLoaded(status));
    } on DioException catch (e) {
      _emitIfNotClosed(GhostStormLoadFailed(e.error ?? const UnexpectedFailure()));
    }
  }

  /// Called by [GhostStateRow]'s own `WidgetsBindingObserver`. Resuming
  /// refetches immediately and restarts the 60s timer; any other lifecycle
  /// state (inactive/paused/hidden/detached) cancels the timer so no polling
  /// happens while backgrounded (ADR-2).
  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
      _startTimer();
    } else {
      _cancelTimer();
    }
  }

  void _startTimer() {
    _cancelTimer();
    _pollTimer = _timerFactory(_pollInterval, refresh);
  }

  void _cancelTimer() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _emitIfNotClosed(GhostStormState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
