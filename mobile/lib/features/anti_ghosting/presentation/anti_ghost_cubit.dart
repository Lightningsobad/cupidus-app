import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/cupid_api_failure.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../data/ghost_config_models.dart';
import '../data/ghost_config_repository.dart';

/// STORY-008 P1: the settings-screen lifecycle state machine
/// (`architecture/solution.md` §4 Mobile Lane Handoff, ADR-2, ADR-4;
/// `ux/uiux-spec.md` §2.3). One of [AntiGhostLoading],
/// [AntiGhostPairingRequired] (AC3), [AntiGhostLoadFailed], or
/// [AntiGhostLoaded], which nests the four config-lifecycle states (A/B/C/D)
/// as [AntiGhostLifecycle].
sealed class AntiGhostState {
  const AntiGhostState();
}

class AntiGhostLoading extends AntiGhostState {
  const AntiGhostLoading();
}

/// AC3: the couple is not paired. There is no client-side pairing/`partnerId`
/// field anywhere in this codebase yet (STORY-005 pairing is a separate,
/// still-pending story), so this is derived defense-in-depth from the
/// backend's own `BadRequestException` (`architecture/solution.md` §4 risk
/// table), surfaced as a `400` on the initial fetch in [AntiGhostCubit.load].
class AntiGhostPairingRequired extends AntiGhostState {
  const AntiGhostPairingRequired();
}

class AntiGhostLoadFailed extends AntiGhostState {
  const AntiGhostLoadFailed(this.failure);

  final Object failure;
}

class AntiGhostLoaded extends AntiGhostState {
  const AntiGhostLoaded(
    this.lifecycle, {
    this.isSubmitting = false,
    this.actionFailure,
  });

  final AntiGhostLifecycle lifecycle;

  /// True while a propose/approve/reject request is in flight; guards every
  /// mutating action so a double-tap issues exactly one request
  /// (`architecture/solution.md` §7 risk table).
  final bool isSubmitting;

  final Object? actionFailure;

  AntiGhostLoaded copyWith({
    AntiGhostLifecycle? lifecycle,
    bool? isSubmitting,
    Object? actionFailure,
    bool clearActionFailure = false,
  }) {
    return AntiGhostLoaded(
      lifecycle ?? this.lifecycle,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
    );
  }
}

/// The four config-lifecycle view-states (`ux/uiux-spec.md` §2.3).
sealed class AntiGhostLifecycle {
  const AntiGhostLifecycle();
}

/// State A — no active config, no pending proposal.
class AntiGhostNoConfig extends AntiGhostLifecycle {
  const AntiGhostNoConfig();
}

/// State D — an active config is in force.
class AntiGhostActiveConfig extends AntiGhostLifecycle {
  const AntiGhostActiveConfig(this.config);

  final GhostConfig config;
}

/// State B — the signed-in user proposed a config still awaiting the
/// partner's approval (`proposedBy == backendUserId`, ADR-4).
class AntiGhostPendingMine extends AntiGhostLifecycle {
  const AntiGhostPendingMine(this.config);

  final GhostConfig config;
}

/// State C — the partner proposed a config awaiting the signed-in user's
/// approval (`proposedBy != backendUserId`, resolved, ADR-4).
class AntiGhostPendingPartner extends AntiGhostLifecycle {
  const AntiGhostPendingPartner(this.config);

  final GhostConfig config;
}

/// ADR-4: `BackendUserIdStore.backendUserId` has not resolved yet, so
/// mine-vs-partner cannot be derived. A read-only summary is shown with no
/// mutating actions rather than guessing.
class AntiGhostPendingUnknownRole extends AntiGhostLifecycle {
  const AntiGhostPendingUnknownRole(this.config);

  final GhostConfig config;
}

/// STORY-008 P1 (`coding-plan/phase-P1-lifecycle-and-settings-screen.md`).
/// Loads on construction and exposes `propose`/`approve`/`reject`, each
/// guarded so a double-tap issues exactly one request and always reloading
/// from the server afterward rather than trusting the mutation response's
/// shape for the next lifecycle state.
class AntiGhostCubit extends Cubit<AntiGhostState> {
  AntiGhostCubit({
    required GhostConfigRepository repository,
    required BackendUserIdStore backendUserIdStore,
  }) : _repository = repository,
       _backendUserIdStore = backendUserIdStore,
       super(const AntiGhostLoading()) {
    load();
  }

  final GhostConfigRepository _repository;
  final BackendUserIdStore _backendUserIdStore;

  /// ADR-2 refresh triggers covered by this phase: screen entry (called from
  /// the constructor) and app-foreground resume (called by the screen's
  /// `WidgetsBindingObserver`). Always re-derives the lifecycle from a fresh
  /// fetch rather than trusting cached state.
  Future<void> load() async {
    emit(const AntiGhostLoading());
    try {
      final active = await _repository.fetchActive();
      if (active != null) {
        _emitIfNotClosed(AntiGhostLoaded(AntiGhostActiveConfig(active)));
        return;
      }
      final pending = await _repository.fetchPending();
      if (pending.isEmpty) {
        _emitIfNotClosed(const AntiGhostLoaded(AntiGhostNoConfig()));
        return;
      }
      _emitIfNotClosed(AntiGhostLoaded(_lifecycleForPending(pending.first)));
    } on DioException catch (e) {
      final failure = e.error;
      if (failure is HttpStatusFailure && failure.statusCode == 400) {
        _emitIfNotClosed(const AntiGhostPairingRequired());
        return;
      }
      _emitIfNotClosed(AntiGhostLoadFailed(failure ?? const UnexpectedFailure()));
    }
  }

  AntiGhostLifecycle _lifecycleForPending(GhostConfig config) {
    final backendUserId = _backendUserIdStore.backendUserId;
    if (backendUserId == null) {
      return AntiGhostPendingUnknownRole(config);
    }
    return config.proposedBy == backendUserId
        ? AntiGhostPendingMine(config)
        : AntiGhostPendingPartner(config);
  }

  /// State A CTA (also State D's "Change" action, which submits a new
  /// proposal over an active config per `ux/uiux-spec.md` §2.3 State D).
  Future<void> propose({
    required int timeoutMinutes,
    required Penalty penalty,
    bool publicCountdown = true,
  }) {
    return _mutate(
      () => _repository.propose(
        timeoutMinutes: timeoutMinutes,
        penalty: penalty,
        publicCountdown: publicCountdown,
      ),
    );
  }

  /// State C primary action.
  Future<void> approve(String id) => _mutate(() => _repository.approve(id));

  /// State C secondary action. ADR-6: there is no withdraw path, so this is
  /// only ever the partner declining, never a self-cancel.
  Future<void> reject(String id) => _mutate(() => _repository.reject(id));

  Future<void> _mutate(Future<GhostConfig> Function() action) async {
    final current = state;
    if (current is! AntiGhostLoaded || current.isSubmitting) {
      return;
    }
    _emitIfNotClosed(current.copyWith(isSubmitting: true, clearActionFailure: true));
    try {
      await action();
      await load();
    } on DioException catch (e) {
      final failure = e.error;
      if (failure is HttpStatusFailure && failure.statusCode == 400) {
        // The couple's pairing state changed, or the proposal was already
        // resolved by the partner since the screen loaded (stale local
        // state): reload rather than surface a raw error (ADR-4/§7 risk
        // table -- the client's view is presentation only, never authority).
        await load();
        return;
      }
      final latest = state;
      if (latest is AntiGhostLoaded) {
        _emitIfNotClosed(
          latest.copyWith(
            isSubmitting: false,
            actionFailure: failure ?? const UnexpectedFailure(),
          ),
        );
      }
    }
  }

  void _emitIfNotClosed(AntiGhostState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
