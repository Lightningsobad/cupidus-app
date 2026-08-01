import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pet_models.dart';
import '../data/pet_repository.dart';
import 'pet_state.dart';

/// The server-side interaction cooldown (`backend/src/modules/pets/
/// pets.service.ts` `interact`). Mirrored client-side only to surface the
/// wait (`ux/uiux-spec.md` §5 Open Item 1) — never to gate the request
/// instead of the server.
const petInteractionCooldown = Duration(seconds: 5);

/// A single tick of the cooldown countdown. Injectable (`coding-plan/
/// phase-P3-pet-state.md` §3: "do not call `Timer` directly inside the cubit
/// body") so tests can drive the countdown without waiting on real
/// wall-clock time.
typedef PetCooldownTicker = Stream<void> Function(Duration interval);

Stream<void> _defaultTicker(Duration interval) =>
    Stream<void>.periodic(interval);

class PetCubit extends Cubit<PetState> {
  PetCubit({
    required this._repository,
    this._now = DateTime.now,
    this._ticker = _defaultTicker,
  }) : super(const PetLoading());

  static const _tickInterval = Duration(seconds: 1);

  final PetRepository _repository;
  final DateTime Function() _now;
  final PetCooldownTicker _ticker;

  StreamSubscription<void>? _cooldownSub;
  bool _isInteracting = false;

  Future<void> load() async {
    _cooldownSub?.cancel();
    emit(const PetLoading());
    try {
      final pairing = await _repository.readPairing();
      if (!pairing.isPaired) {
        if (!isClosed) emit(const PetLocked());
        return;
      }
      final status = await _repository.readStatus();
      if (status == null) {
        if (!isClosed) emit(const PetNoPet());
        return;
      }
      if (!isClosed) _emitReady(status);
    } on CupidApiFailure catch (failure) {
      if (!isClosed) emit(PetFailure(failure));
    }
  }

  /// Ignores taps during the cooldown window or while a request is already
  /// in flight, so double-tapping Feed/Play never reaches the network
  /// (`coding-plan/phase-P3-pet-state.md` §4 acceptance criteria).
  Future<void> interact() async {
    final current = state;
    if (current is! PetReady || current.cooldownRemaining != null) return;
    if (_isInteracting) return;
    _isInteracting = true;
    try {
      final status = await _repository.interact();
      if (!isClosed) _emitReady(status);
    } on CupidApiFailure catch (failure) {
      if (isClosed) return;
      if (failure is HttpStatusFailure && failure.statusCode == 400) {
        // The 5s cooldown rejected a request that slipped past the guard
        // above; re-arm from the last known server truth rather than
        // surfacing a raw error banner (architecture/solution.md §4 error
        // contract).
        final remaining = _cooldownFor(current.status) ?? petInteractionCooldown;
        _armCooldown(current.status, remaining);
      } else {
        _cooldownSub?.cancel();
        emit(PetFailure(failure));
      }
    } finally {
      _isInteracting = false;
    }
  }

  void _emitReady(PetStatus status) {
    final remaining = _cooldownFor(status);
    if (remaining == null) {
      _cooldownSub?.cancel();
      emit(PetReady(status: status, cooldownRemaining: null));
    } else {
      _armCooldown(status, remaining);
    }
  }

  void _armCooldown(PetStatus status, Duration remaining) {
    emit(PetReady(status: status, cooldownRemaining: remaining));
    _cooldownSub?.cancel();
    _cooldownSub = _ticker(_tickInterval).listen((_) {
      final current = state;
      if (current is! PetReady) return;
      final left = _cooldownFor(current.status);
      if (left == null) {
        _cooldownSub?.cancel();
        emit(PetReady(status: current.status, cooldownRemaining: null));
      } else {
        emit(PetReady(status: current.status, cooldownRemaining: left));
      }
    });
  }

  Duration? _cooldownFor(PetStatus status) {
    final last = status.pet.lastInteraction;
    if (last == null) return null;
    final elapsed = _now().difference(last);
    if (elapsed >= petInteractionCooldown) return null;
    return petInteractionCooldown - elapsed;
  }

  @override
  Future<void> close() {
    _cooldownSub?.cancel();
    return super.close();
  }
}
