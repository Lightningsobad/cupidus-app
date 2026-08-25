import 'package:permission_handler/permission_handler.dart';

/// The only camera-permission outcomes the scan flow branches on
/// (`ux/ux-spec.md` States 2, 5, 6, 7). `permission_handler`'s six-value
/// `PermissionStatus` is collapsed here and never leaks past this seam, so the
/// scan cubit, its widgets and the preview harness stay free of a platform
/// channel.
enum CameraPermissionState {
  /// The camera may be opened now (`ux/ux-spec.md` State 2).
  granted,

  /// Denied on this ask, but re-askable (State 5).
  denied,

  /// Blocked; only the OS settings page can change it (State 6).
  permanentlyDenied,

  /// No usable camera, and not a permission decision (State 7).
  unavailable,
}

/// Reads the camera permission and, when it has not been decided yet, asks for
/// it. The whole interface is one call because OQ1 fixes the timing: permission
/// is requested at the moment the user taps `Quét QR`, never earlier, so a
/// separate `check` step would have no caller.
abstract interface class CameraPermissionGate {
  /// Resolves the current camera permission, prompting once if the user has
  /// not decided yet.
  Future<CameraPermissionState> status();

  /// Opens the OS app-settings page (State 6's only route back to granted).
  Future<void> openSettings();
}

/// The shipped gate. `Permission.camera.request()` prompts only while the
/// status is undecided; on an already-decided permission it resolves to the
/// stored decision without showing a dialog, which is what keeps a granted
/// second scan promptless.
class PermissionHandlerCameraGate implements CameraPermissionGate {
  const PermissionHandlerCameraGate();

  @override
  Future<CameraPermissionState> status() async {
    final PermissionStatus status = await Permission.camera.request();
    return switch (status) {
      // `limited`/`provisional` never occur for the camera permission on
      // either platform, but the switch is exhaustive so a future
      // permission_handler value cannot silently fall through to a
      // permissive default.
      PermissionStatus.granted ||
      PermissionStatus.limited ||
      PermissionStatus.provisional => CameraPermissionState.granted,
      PermissionStatus.denied => CameraPermissionState.denied,
      PermissionStatus.permanentlyDenied =>
        CameraPermissionState.permanentlyDenied,
      // iOS parental controls: the user cannot grant this, so it reads as a
      // missing camera rather than as a decision they can revisit.
      PermissionStatus.restricted => CameraPermissionState.unavailable,
    };
  }

  @override
  Future<void> openSettings() => openAppSettings();
}

/// Drives all four states from a widget test or from `main_preview.dart` with
/// no platform channel. It ships in `lib/` rather than `test/` because the
/// preview harness — the only way AC5's states are capturable on a machine
/// with no camera — is itself a `lib/` entrypoint.
class FakeCameraPermissionGate implements CameraPermissionGate {
  FakeCameraPermissionGate(this._state);

  final CameraPermissionState _state;

  /// How many times [openSettings] was called, for State 6's assertion.
  int openSettingsCalls = 0;

  @override
  Future<CameraPermissionState> status() async => _state;

  @override
  Future<void> openSettings() async => openSettingsCalls++;
}
