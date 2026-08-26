import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api_failure.dart'
    show NetworkUnavailableFailure;
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/camera_permission_gate.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/scan_code_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the pairing call received, so "a scanned code produces the
/// same outcome as a typed one" is checked at the exact seam manual entry
/// uses.
class _AcceptInvitationStub {
  _AcceptInvitationStub();

  final List<String> codes = <String>[];
  final List<Completer<void>> pending = <Completer<void>>[];
  PairingFailure? failure;

  /// When true, the call parks until [completeLast] so the in-flight window is
  /// observable.
  bool hold = false;

  Future<void> call(String code) async {
    codes.add(code);
    if (hold) {
      final Completer<void> completer = Completer<void>();
      pending.add(completer);
      await completer.future;
    }
    if (failure != null) throw failure!;
  }

  void completeLast() => pending.removeLast().complete();
}

void main() {
  late _AcceptInvitationStub accept;
  late JoincodeCubit joincode;

  setUp(() {
    accept = _AcceptInvitationStub();
    joincode = JoincodeCubit(acceptInvitation: accept.call);
  });

  tearDown(() async {
    await joincode.close();
  });

  ScanCodeCubit cubitFor(CameraPermissionState permission) => ScanCodeCubit(
    permissionGate: FakeCameraPermissionGate(permission),
    joincodeCubit: joincode,
  );

  group('start resolves permission', () {
    test('opens in State 1 before start', () {
      expect(cubitFor(CameraPermissionState.granted).state, isA<ScanCodeOpening>());
    });

    test('granted -> scanning', () async {
      final ScanCodeCubit cubit = cubitFor(CameraPermissionState.granted);
      await cubit.start();
      expect(cubit.state, isA<ScanCodeScanning>());
      await cubit.close();
    });

    test('denied -> denied state', () async {
      final ScanCodeCubit cubit = cubitFor(CameraPermissionState.denied);
      await cubit.start();
      expect(cubit.state, isA<ScanCodePermissionDenied>());
      await cubit.close();
    });

    test('permanentlyDenied -> permanently denied state', () async {
      final ScanCodeCubit cubit = cubitFor(
        CameraPermissionState.permanentlyDenied,
      );
      await cubit.start();
      expect(cubit.state, isA<ScanCodePermissionPermanentlyDenied>());
      await cubit.close();
    });

    test('unavailable -> unavailable state', () async {
      final ScanCodeCubit cubit = cubitFor(CameraPermissionState.unavailable);
      await cubit.start();
      expect(cubit.state, isA<ScanCodeUnavailable>());
      await cubit.close();
    });

    test('a detection without granted permission never submits', () async {
      final ScanCodeCubit cubit = cubitFor(CameraPermissionState.denied);
      await cubit.start();

      cubit.onDetected('ABC123');

      expect(accept.codes, isEmpty);
      expect(cubit.state, isA<ScanCodePermissionDenied>());
      await cubit.close();
    });
  });

  group('detection', () {
    late ScanCodeCubit cubit;

    setUp(() async {
      cubit = cubitFor(CameraPermissionState.granted);
      await cubit.start();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('a malformed payload is rejected with zero network calls', () async {
      cubit.onDetected('https://example.com');

      expect(cubit.state, isA<ScanCodeInvalid>());
      expect(accept.codes, isEmpty);
    });

    test('a valid payload submits exactly the normalized code', () async {
      accept.hold = true;
      cubit.onDetected('https://cupid.app/join/abc123');

      expect(accept.codes, <String>['ABC123']);
      expect(cubit.state, isA<ScanCodeRecognized>());
      expect((cubit.state as ScanCodeRecognized).code, 'ABC123');

      accept.completeLast();
      await pumpEventQueue();
    });

    test('repeated detections during an in-flight submit send one', () async {
      accept.hold = true;

      cubit.onDetected('ABC123');
      cubit.onDetected('ABC123');
      cubit.onDetected('ABC123');
      cubit.onDetected('ZZZ999');

      expect(accept.codes, <String>['ABC123']);

      accept.completeLast();
      await pumpEventQueue();
    });

    test('detections stay disarmed while the invalid card shows', () async {
      cubit.onDetected('nope');
      expect(cubit.state, isA<ScanCodeInvalid>());

      cubit.onDetected('ABC123');
      expect(accept.codes, isEmpty);
    });

    test('retry re-arms detection and returns to scanning', () async {
      cubit.onDetected('nope');
      cubit.retry();
      expect(cubit.state, isA<ScanCodeScanning>());

      accept.hold = true;
      cubit.onDetected('ABC123');
      expect(accept.codes, <String>['ABC123']);

      accept.completeLast();
      await pumpEventQueue();
    });

    test('retry outside the invalid state does nothing', () async {
      cubit.retry();
      expect(cubit.state, isA<ScanCodeScanning>());
    });
  });

  group('routing of JoincodeCubit outcomes', () {
    late ScanCodeCubit cubit;
    late int closeSignals;
    late StreamSubscription<void> closeSubscription;

    setUp(() async {
      cubit = cubitFor(CameraPermissionState.granted);
      await cubit.start();
      closeSignals = 0;
      closeSubscription = cubit.closeRequests.listen((_) => closeSignals++);
    });

    tearDown(() async {
      await closeSubscription.cancel();
      await cubit.close();
    });

    test('in-flight submit holds State 3, no close', () async {
      accept.hold = true;
      cubit.onDetected('ABC123');
      await pumpEventQueue();

      expect(joincode.state, isA<JoincodeInProgress>());
      expect(cubit.state, isA<ScanCodeRecognized>());
      expect(closeSignals, 0);

      accept.completeLast();
      await pumpEventQueue();
    });

    test('invalid or expired backend rejection -> State 4, no close', () async {
      accept.failure = const InvalidOrExpiredCodeFailure();

      cubit.onDetected('ABC123');
      await pumpEventQueue();

      expect(cubit.state, isA<ScanCodeInvalid>());
      expect(closeSignals, 0);
    });

    test('State 4 from the backend can be retried', () async {
      accept.failure = const InvalidOrExpiredCodeFailure();
      cubit.onDetected('ABC123');
      await pumpEventQueue();

      accept.failure = null;
      cubit.retry();
      cubit.onDetected('ZZZ999');
      await pumpEventQueue();

      expect(accept.codes, <String>['ABC123', 'ZZZ999']);
    });

    test('success closes the overlay', () async {
      cubit.onDetected('ABC123');
      await pumpEventQueue();

      expect(joincode.state, isA<JoincodeSuccess>());
      expect(closeSignals, 1);
    });
  });

  group('every failure the overlay does not render closes it', () {
    const List<PairingFailure> failures = <PairingFailure>[
      AlreadyPairedFailure(),
      SelfInviteFailure(),
      InviterAlreadyPairedFailure(),
      UnmappedPairingFailure(NetworkUnavailableFailure()),
    ];

    for (final PairingFailure failure in failures) {
      test('${failure.runtimeType} closes the overlay', () async {
        accept.failure = failure;
        final ScanCodeCubit cubit = cubitFor(CameraPermissionState.granted);
        await cubit.start();

        int closeSignals = 0;
        final StreamSubscription<void> subscription = cubit.closeRequests
            .listen((_) => closeSignals++);

        cubit.onDetected('ABC123');
        await pumpEventQueue();

        expect(closeSignals, 1);
        // The overlay stays on State 3 until the screen below pops it: it must
        // not invent an error card for a failure the join-code screen already
        // renders inline.
        expect(cubit.state, isA<ScanCodeRecognized>());

        await subscription.cancel();
        await cubit.close();
      });
    }
  });

  test('openSettings reaches the permission gate', () async {
    final FakeCameraPermissionGate gate = FakeCameraPermissionGate(
      CameraPermissionState.permanentlyDenied,
    );
    final ScanCodeCubit cubit = ScanCodeCubit(
      permissionGate: gate,
      joincodeCubit: joincode,
    );

    await cubit.openSettings();

    expect(gate.openSettingsCalls, 1);
    await cubit.close();
  });
}
