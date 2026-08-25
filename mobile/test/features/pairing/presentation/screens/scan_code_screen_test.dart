import 'dart:async';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/camera_permission_gate.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/scan_code_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the code the pairing call received, so "scanned equals typed" (AC2)
/// is asserted at the same seam manual entry uses.
class _AcceptInvitationStub {
  final List<String> codes = <String>[];
  final List<Completer<void>> pending = <Completer<void>>[];
  PairingFailure? failure;

  /// When true the call parks until [completeLast], which is what makes
  /// State 3 observable — an instantly-resolving pairing call pops the overlay
  /// before a frame can be inspected.
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

/// Holds State 1 open until [resolve] is called, so the opening frame is
/// observable instead of racing the first microtask flush.
class _DeferredCameraGate implements CameraPermissionGate {
  _DeferredCameraGate(this._state);

  final CameraPermissionState _state;
  final Completer<void> _release = Completer<void>();
  int openSettingsCalls = 0;

  void resolve() => _release.complete();

  @override
  Future<CameraPermissionState> status() async {
    await _release.future;
    return _state;
  }

  @override
  Future<void> openSettings() async => openSettingsCalls++;
}

/// The placeholder camera surface. Counts its own disposals so "the camera
/// session dies with the subtree" is a real assertion rather than a claim.
class _FakePreview extends StatefulWidget {
  const _FakePreview({required this.onDetected, required this.lifecycle});

  final ValueChanged<String> onDetected;
  final _PreviewLifecycle lifecycle;

  @override
  State<_FakePreview> createState() => _FakePreviewState();
}

class _PreviewLifecycle {
  int mounts = 0;
  int disposals = 0;
  ValueChanged<String>? emit;
}

class _FakePreviewState extends State<_FakePreview> {
  @override
  void initState() {
    super.initState();
    widget.lifecycle.mounts++;
    widget.lifecycle.emit = widget.onDetected;
  }

  @override
  void dispose() {
    widget.lifecycle.disposals++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(key: Key('fake_camera_preview'));
}

const Key _hostKey = Key('host_screen');

/// The cubit publishes over a stream, so the frame that carries a new state is
/// the one after the frame that delivers it. A single pump lands mid-flight.
Future<void> _pumpState(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

/// Pushes the overlay the way `JoincodeScreen` will in P4, and records the exit
/// reason the route hands back.
class _Host extends StatefulWidget {
  const _Host({
    required this.joincodeCubit,
    required this.permissionGate,
    required this.lifecycle,
    required this.exits,
  });

  final JoincodeCubit joincodeCubit;
  final CameraPermissionGate permissionGate;
  final _PreviewLifecycle lifecycle;
  final List<ScanCodeExit?> exits;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _hostKey,
      body: Center(
        child: TextButton(
          onPressed: () async {
            final ScanCodeExit? exit = await Navigator.of(context).push(
              ScanCodeRoute(
                joincodeCubit: widget.joincodeCubit,
                permissionGate: widget.permissionGate,
                previewBuilder:
                    (BuildContext context, ValueChanged<String> onDetected) =>
                        _FakePreview(
                          onDetected: onDetected,
                          lifecycle: widget.lifecycle,
                        ),
              ),
            );
            widget.exits.add(exit);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  late _AcceptInvitationStub accept;
  late JoincodeCubit joincode;
  late _PreviewLifecycle lifecycle;
  late List<ScanCodeExit?> exits;

  setUp(() {
    accept = _AcceptInvitationStub();
    joincode = JoincodeCubit(acceptInvitation: accept.call);
    lifecycle = _PreviewLifecycle();
    exits = <ScanCodeExit?>[];
  });

  tearDown(() async {
    await joincode.close();
  });

  /// Pumps the host and opens the overlay, leaving permission unresolved so
  /// State 1 can be asserted. Call [_DeferredCameraGate.resolve] to advance.
  Future<_DeferredCameraGate> open(
    WidgetTester tester,
    CameraPermissionState permission,
  ) async {
    final _DeferredCameraGate gate = _DeferredCameraGate(permission);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        home: _Host(
          joincodeCubit: joincode,
          permissionGate: gate,
          lifecycle: lifecycle,
          exits: exits,
        ),
      ),
    );

    await tester.tap(find.text('open'));
    // Not `pumpAndSettle`: State 1's progress indicator spins forever, so
    // settling is only possible once permission has resolved.
    await tester.pump();
    await tester.pump(scanCodeFadeDuration);
    return gate;
  }

  Future<_DeferredCameraGate> openResolved(
    WidgetTester tester,
    CameraPermissionState permission,
  ) async {
    final _DeferredCameraGate gate = await open(tester, permission);
    gate.resolve();
    await tester.pumpAndSettle();
    return gate;
  }

  group('State 1 — opening', () {
    testWidgets('shows no camera and no error while permission resolves', (
      WidgetTester tester,
    ) async {
      await open(tester, CameraPermissionState.granted);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('fake_camera_preview')), findsNothing);
      expect(find.textContaining('invalid'), findsNothing);
      expect(lifecycle.mounts, 0);
    });
  });

  group('State 2 — live scanning', () {
    testWidgets('mounts the camera preview exactly once', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      expect(find.byKey(const Key('fake_camera_preview')), findsOneWidget);
      expect(lifecycle.mounts, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows the aiming helper and the manual-entry way out', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      expect(find.text('Point your camera at their QR code'), findsOneWidget);
      expect(find.text('Enter code manually'), findsOneWidget);
    });
  });

  group('State 3 — recognized', () {
    testWidgets('a scanned code reaches the same pairing call manual entry uses', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('https://cupid.app/join/abc123');
      await tester.pump();

      expect(accept.codes, <String>['ABC123']);
    });

    testWidgets('drops the scanning helper copy on a hit', (
      WidgetTester tester,
    ) async {
      accept.hold = true;
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('ABC123');
      await _pumpState(tester);

      expect(find.text('Point your camera at their QR code'), findsNothing);
      expect(find.byKey(const Key('fake_camera_preview')), findsOneWidget);

      accept.completeLast();
      await tester.pumpAndSettle();
    });

    testWidgets('a backend success closes the overlay on its own', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('ABC123');
      await tester.pumpAndSettle();

      expect(find.byKey(_hostKey), findsOneWidget);
      expect(find.byKey(const Key('fake_camera_preview')), findsNothing);
      expect(exits, <ScanCodeExit>[ScanCodeExit.dismissed]);
      expect(lifecycle.disposals, 1);
    });
  });

  group('State 4 — invalid or expired', () {
    testWidgets('a malformed payload shows the honest card, not a success', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('https://example.com');
      await _pumpState(tester);

      expect(
        find.text('This QR code is invalid or has expired'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Enter code manually'), findsOneWidget);
      expect(accept.codes, isEmpty);
      expect(exits, isEmpty);
    });

    testWidgets('the camera keeps running under the card', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('nope');
      await _pumpState(tester);

      expect(find.byKey(const Key('fake_camera_preview')), findsOneWidget);
      // Not remounted: a torn-down and rebuilt preview reads to the user as
      // the camera restarting on every misread.
      expect(lifecycle.mounts, 1);
      expect(lifecycle.disposals, 0);
    });

    testWidgets('Try again re-arms scanning immediately', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('nope');
      await _pumpState(tester);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('This QR code is invalid or has expired'), findsNothing);
      expect(find.text('Point your camera at their QR code'), findsOneWidget);

      lifecycle.emit!('ABC123');
      await tester.pumpAndSettle();
      expect(accept.codes, <String>['ABC123']);
    });

    testWidgets('the card steps aside on its own after ~3s', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('nope');
      await _pumpState(tester);
      expect(
        find.text('This QR code is invalid or has expired'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('This QR code is invalid or has expired'), findsNothing);
      expect(find.text('Point your camera at their QR code'), findsOneWidget);
    });

    testWidgets('a backend rejection lands on the same card', (
      WidgetTester tester,
    ) async {
      accept.failure = const InvalidOrExpiredCodeFailure();
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('ABC123');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(
        find.text('This QR code is invalid or has expired'),
        findsOneWidget,
      );
      expect(exits, isEmpty);
    });

    testWidgets('the manual-entry link leaves with the manualEntry reason', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      lifecycle.emit!('nope');
      await _pumpState(tester);
      await tester.tap(find.text('Enter code manually'));
      await tester.pumpAndSettle();

      expect(exits, <ScanCodeExit>[ScanCodeExit.manualEntry]);
      expect(lifecycle.disposals, 1);
    });
  });

  group('State 5 — permission denied', () {
    testWidgets('explains the block and offers manual entry, no camera', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.denied);

      expect(
        find.text('Cupid needs camera access to scan QR codes'),
        findsOneWidget,
      );
      expect(find.text('Enter code manually'), findsOneWidget);
      expect(find.byKey(const Key('fake_camera_preview')), findsNothing);
      expect(lifecycle.mounts, 0);
    });

    testWidgets('the way out returns to manual entry', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.denied);

      await tester.tap(find.text('Enter code manually'));
      await tester.pumpAndSettle();

      expect(exits, <ScanCodeExit>[ScanCodeExit.manualEntry]);
    });
  });

  group('State 6 — permanently denied', () {
    testWidgets('points at Settings and keeps a second way forward', (
      WidgetTester tester,
    ) async {
      await openResolved(
        tester,
        CameraPermissionState.permanentlyDenied,
      );

      expect(
        find.text('Camera access is off in Settings — turn it on to scan QR codes'),
        findsOneWidget,
      );
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Enter code manually'), findsOneWidget);
    });

    testWidgets('Open Settings reaches the permission gate', (
      WidgetTester tester,
    ) async {
      final _DeferredCameraGate gate = await openResolved(
        tester,
        CameraPermissionState.permanentlyDenied,
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(gate.openSettingsCalls, 1);
      // The overlay stays put: the user has to come back from Settings.
      expect(exits, isEmpty);
    });
  });

  group('State 7 — camera unavailable', () {
    testWidgets('states the limit plainly with one way forward', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.unavailable);

      expect(
        find.text("Camera isn't available on this device"),
        findsOneWidget,
      );
      expect(find.text('Enter code manually'), findsOneWidget);
      expect(find.text('Open Settings'), findsNothing);
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('close control', () {
    testWidgets('is present and labelled in every state', (
      WidgetTester tester,
    ) async {
      for (final CameraPermissionState permission in CameraPermissionState.values) {
        await openResolved(tester, permission);
        expect(
          find.byTooltip('Close'),
          findsOneWidget,
          reason: 'missing close control in $permission',
        );
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('meets the 44x44 minimum hit target', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      final Size size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('closing tears down the camera and reports dismissed', (
      WidgetTester tester,
    ) async {
      await openResolved(tester, CameraPermissionState.granted);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(exits, <ScanCodeExit>[ScanCodeExit.dismissed]);
      expect(lifecycle.disposals, 1);
      expect(find.byKey(_hostKey), findsOneWidget);
    });
  });

  group('failures the join-code screen already renders', () {
    for (final PairingFailure failure in <PairingFailure>[
      AlreadyPairedFailure(),
      SelfInviteFailure(),
      InviterAlreadyPairedFailure(),
    ]) {
      testWidgets('${failure.runtimeType} hands back to the screen below', (
        WidgetTester tester,
      ) async {
        accept.failure = failure;
        await openResolved(tester, CameraPermissionState.granted);

        lifecycle.emit!('ABC123');
        await tester.pumpAndSettle();

        expect(find.byKey(_hostKey), findsOneWidget);
        expect(lifecycle.disposals, 1);
        // No invented error card: that message belongs to the join-code screen.
        expect(find.text('This QR code is invalid or has expired'), findsNothing);
      });
    }
  });
}
