import 'dart:io';

import 'package:cupid_mobile/features/pairing/presentation/camera_permission_gate.dart';
import 'package:flutter_test/flutter_test.dart';
// `permission_handler` deliberately does not re-export `PermissionHandlerPlatform`,
// so swapping in a fake platform means importing its interface package
// directly rather than adding a third pubspec entry for test-only reach.
// ignore: depend_on_referenced_packages
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// Stands in for the method channel so the mapping below is exercised without
/// a device. Extending (not implementing) `PermissionHandlerPlatform` is what
/// makes `PermissionHandlerPlatform.instance =` pass its token check.
class _FakePermissionHandlerPlatform extends PermissionHandlerPlatform {
  _FakePermissionHandlerPlatform(this.status);

  PermissionStatus status;
  int openAppSettingsCalls = 0;
  final List<Permission> requested = <Permission>[];

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requested.addAll(permissions);
    return <Permission, PermissionStatus>{
      for (final Permission permission in permissions) permission: status,
    };
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }
}

void main() {
  late _FakePermissionHandlerPlatform platform;
  final PermissionHandlerPlatform original = PermissionHandlerPlatform.instance;

  setUp(() {
    platform = _FakePermissionHandlerPlatform(PermissionStatus.granted);
    PermissionHandlerPlatform.instance = platform;
  });

  tearDown(() {
    PermissionHandlerPlatform.instance = original;
  });

  group('PermissionHandlerCameraGate.status', () {
    Future<CameraPermissionState> stateFor(PermissionStatus status) {
      platform.status = status;
      return const PermissionHandlerCameraGate().status();
    }

    test('asks for the camera permission, and nothing else', () async {
      await const PermissionHandlerCameraGate().status();

      expect(platform.requested, <Permission>[Permission.camera]);
    });

    test('granted maps to granted', () async {
      expect(
        await stateFor(PermissionStatus.granted),
        CameraPermissionState.granted,
      );
    });

    test('denied maps to denied', () async {
      expect(
        await stateFor(PermissionStatus.denied),
        CameraPermissionState.denied,
      );
    });

    test('permanentlyDenied maps to permanentlyDenied', () async {
      expect(
        await stateFor(PermissionStatus.permanentlyDenied),
        CameraPermissionState.permanentlyDenied,
      );
    });

    test('restricted maps to unavailable', () async {
      expect(
        await stateFor(PermissionStatus.restricted),
        CameraPermissionState.unavailable,
      );
    });

    test('limited and provisional map to granted, not to a dead end', () async {
      expect(
        await stateFor(PermissionStatus.limited),
        CameraPermissionState.granted,
      );
      expect(
        await stateFor(PermissionStatus.provisional),
        CameraPermissionState.granted,
      );
    });
  });

  test('PermissionHandlerCameraGate.openSettings opens the OS page', () async {
    await const PermissionHandlerCameraGate().openSettings();

    expect(platform.openAppSettingsCalls, 1);
  });

  group('FakeCameraPermissionGate', () {
    test('drives every state with no platform channel', () async {
      PermissionHandlerPlatform.instance = original;

      for (final CameraPermissionState state in CameraPermissionState.values) {
        expect(await FakeCameraPermissionGate(state).status(), state);
      }
    });

    test('counts openSettings calls', () async {
      final FakeCameraPermissionGate gate = FakeCameraPermissionGate(
        CameraPermissionState.permanentlyDenied,
      );

      expect(gate.openSettingsCalls, 0);
      await gate.openSettings();
      expect(gate.openSettingsCalls, 1);
    });
  });

  group('platform permission declarations', () {
    test('Android manifest declares CAMERA', () {
      final String manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(
        manifest,
        contains('android.permission.CAMERA'),
        reason:
            'Without this uses-permission the runtime request is auto-denied '
            'and the scan overlay can only ever reach its denied state.',
      );
    });

    test('iOS Info.plist carries a camera usage description', () {
      final String plist = File(
        'ios/Runner/Info.plist',
      ).readAsStringSync();

      expect(
        plist,
        contains('NSCameraUsageDescription'),
        reason:
            'iOS terminates the app on a camera request with no usage '
            'description, and App Store review rejects the build.',
      );
    });
  });
}
