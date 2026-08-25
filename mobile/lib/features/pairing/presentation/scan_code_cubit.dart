import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pairing_failure.dart';
import 'camera_permission_gate.dart';
import 'joincode_cubit.dart';
import 'pairing_code_parser.dart';

/// The seven states of `ux/ux-spec.md`, one class each.
sealed class ScanCodeState {
  const ScanCodeState();
}

/// State 1 — permission is being resolved and the camera has not opened yet.
class ScanCodeOpening extends ScanCodeState {
  const ScanCodeOpening();
}

/// State 2 — live camera, detection armed.
class ScanCodeScanning extends ScanCodeState {
  const ScanCodeScanning();
}

/// State 3 — a code was accepted and handed to `JoincodeCubit`. Held for the
/// whole `/invitations/accept` round trip, so no separate "processing" state
/// is invented.
class ScanCodeRecognized extends ScanCodeState {
  const ScanCodeRecognized(this.code);

  /// The normalized code passed to [JoincodeCubit.submit].
  final String code;
}

/// State 4 — the payload did not parse, or the backend rejected it as invalid
/// or expired. The camera keeps running; detection stays disarmed until
/// [ScanCodeCubit.retry] so the still-framed bad code cannot re-fire.
class ScanCodeInvalid extends ScanCodeState {
  const ScanCodeInvalid();
}

/// State 5 — denied on this ask, still re-askable.
class ScanCodePermissionDenied extends ScanCodeState {
  const ScanCodePermissionDenied();
}

/// State 6 — denied for good; only the OS settings page can change it.
class ScanCodePermissionPermanentlyDenied extends ScanCodeState {
  const ScanCodePermissionPermanentlyDenied();
}

/// State 7 — no usable camera on this device.
class ScanCodeUnavailable extends ScanCodeState {
  const ScanCodeUnavailable();
}

/// Owns the scan overlay's state machine: permission read, decode debounce,
/// and the routing of [JoincodeCubit] outcomes.
///
/// It does not own pairing. A scanned code goes through the exact
/// [JoincodeCubit] instance the join-code screen already uses, so a scan and a
/// typed code hit the same `acceptInvitation`, the same failure map and the
/// same success listener.
class ScanCodeCubit extends Cubit<ScanCodeState> {
  ScanCodeCubit({
    required CameraPermissionGate permissionGate,
    required JoincodeCubit joincodeCubit,
  }) : _permissionGate = permissionGate,
       _joincodeCubit = joincodeCubit,
       super(const ScanCodeOpening());

  final CameraPermissionGate _permissionGate;
  final JoincodeCubit _joincodeCubit;
  final StreamController<void> _closeRequests =
      StreamController<void>.broadcast();
  StreamSubscription<JoincodeState>? _joincodeSubscription;

  /// Detections are accepted only while this is true, which is what keeps a
  /// 30-frames-per-second detection stream from submitting the same code many
  /// times. A double submit returns 409 `AlreadyPairedFailure` and reads to
  /// the user as a broken scan.
  bool _armed = false;

  /// Fires when the overlay should close: pairing succeeded, or it failed in a
  /// way the join-code screen renders inline better than the overlay could.
  Stream<void> get closeRequests => _closeRequests.stream;

  /// Resolves permission and moves out of State 1. Requesting here — not on
  /// screen build and not earlier — is OQ1's tap-time timing.
  Future<void> start() async {
    _joincodeSubscription ??= _joincodeCubit.stream.listen(_onJoincodeState);

    final CameraPermissionState permission = await _permissionGate.status();
    if (isClosed) return;

    _armed = permission == CameraPermissionState.granted;
    emit(switch (permission) {
      CameraPermissionState.granted => const ScanCodeScanning(),
      CameraPermissionState.denied => const ScanCodePermissionDenied(),
      CameraPermissionState.permanentlyDenied =>
        const ScanCodePermissionPermanentlyDenied(),
      CameraPermissionState.unavailable => const ScanCodeUnavailable(),
    });
  }

  /// Handles one raw QR payload from the camera. Ignored unless detection is
  /// armed.
  void onDetected(String rawPayload) {
    if (!_armed || isClosed) return;
    _armed = false;

    final String? code = parsePairingCode(rawPayload);
    if (code == null) {
      // No network call: a payload that is not a pairing code is knowably bad
      // on-device.
      emit(const ScanCodeInvalid());
      return;
    }

    emit(ScanCodeRecognized(code));
    unawaited(_joincodeCubit.submit(code));
  }

  /// Re-arms detection from State 4, whether the user tapped `Thử lại` or the
  /// error card auto-dismissed.
  void retry() {
    if (isClosed || state is! ScanCodeInvalid) return;
    _armed = true;
    emit(const ScanCodeScanning());
  }

  /// State 6's only route back to a granted permission.
  Future<void> openSettings() => _permissionGate.openSettings();

  void _onJoincodeState(JoincodeState joincodeState) {
    if (isClosed) return;
    switch (joincodeState) {
      case JoincodeIdle():
      case JoincodeInProgress():
        // State 3 holds across the round trip.
        break;
      case JoincodeFailed(failure: InvalidOrExpiredCodeFailure()):
        // The one failure the overlay renders itself, because retrying the
        // scan is the natural next move.
        emit(const ScanCodeInvalid());
      case JoincodeFailed():
      case JoincodeSuccess():
        _closeRequests.add(null);
    }
  }

  @override
  Future<void> close() async {
    await _joincodeSubscription?.cancel();
    await _closeRequests.close();
    return super.close();
  }
}
