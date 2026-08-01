import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/domain/synced_reminder.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_firing_cubit.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_overlay_host.dart';
import 'package:cupid_mobile/features/reminders/presentation/widgets/reminder_firing_overlay.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Never invoked by [ReminderFiringCubitStub] (every method the base cubit
/// would call on it is overridden below), but the base constructor still
/// requires a live `events()` stream to subscribe to.
class _EmptyRealtimeCoordinator implements RealtimeCoordinator {
  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => const Stream.empty();

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> emit(String name, Object? payload) async {}

  @override
  Future<void> resync() async {}
}

SyncedReminder _reminder({Set<String> stopperIds = const {}}) => SyncedReminder(
  id: 'alarm-1',
  time: DateTime.utc(2026, 7, 30, 6),
  isActive: true,
  status: 'ringing',
  requesterId: 'user-requester',
  partnerId: 'user-partner',
  stopperIds: stopperIds,
);

Widget _harness(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: child,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ReminderFiringOverlay rendering (uiux-spec.md §3)', () {
    testWidgets('renders the never-alarm-clock notificationsActive glyph, body copy and dismiss CTA', (
      tester,
    ) async {
      final state = ReminderFiringOpen(
        reminder: _reminder(),
        viewerId: 'user-partner',
      );

      await tester.pumpWidget(
        _harness(
          ReminderFiringOverlay(state: state, onDismiss: () {}),
        ),
      );
      await tester.pump();

      expect(find.byIcon(CupidIcons.notificationsActive), findsOneWidget);
      expect(
        find.text('It stops only when both of you swipe.'),
        findsOneWidget,
      );
      expect(find.text('Swipe to wake'), findsOneWidget);
    });

    testWidgets('the waiting-on-partner state shows distinct You/Partner labels', (
      tester,
    ) async {
      final state = ReminderFiringOpen(
        reminder: _reminder(stopperIds: {'user-partner'}),
        viewerId: 'user-partner',
      );

      await tester.pumpWidget(
        _harness(
          ReminderFiringOverlay(state: state, onDismiss: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Partner'), findsOneWidget);
      expect(find.text('awake ✓'), findsOneWidget);
      expect(find.text('still asleep'), findsOneWidget);
    });

    testWidgets('honors safe-area insets (uiux-spec.md §6)', (tester) async {
      final state = ReminderFiringOpen(
        reminder: _reminder(),
        viewerId: 'user-partner',
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 40, bottom: 24)),
          child: _harness(
            ReminderFiringOverlay(state: state, onDismiss: () {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });

  group('ReminderFiringOverlay accessibility (uiux-spec.md §7)', () {
    testWidgets(
      'announces the firing body as an alert-level interruption on open and focuses the dismiss action',
      (tester) async {
        final announcements = <String>[];
        tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          (message) async {
            final data = (message as Map)['data'] as Map?;
            final text = data?['message'] as String?;
            if (text != null) announcements.add(text);
            return null;
          },
        );
        addTearDown(() {
          tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility,
            null,
          );
        });

        final semanticsHandle = tester.ensureSemantics();

        final state = ReminderFiringOpen(
          reminder: _reminder(),
          viewerId: 'user-partner',
        );

        await tester.pumpWidget(
          _harness(
            ReminderFiringOverlay(state: state, onDismiss: () {}),
          ),
        );
        // Not `pumpAndSettle`: the shake badge's `AnimationController.repeat`
        // never settles. A couple of frames is enough to flush the
        // post-frame-callback announce/focus side effect.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(announcements, contains('It stops only when both of you swipe.'));

        final focused = find.byWidgetPredicate(
          (widget) => widget is Focus && widget.focusNode?.hasPrimaryFocus == true,
        );
        expect(focused, findsOneWidget);

        semanticsHandle.dispose();
      },
    );

    testWidgets('the dismiss button is non-gesture activatable with an accessible label', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();

      bool dismissed = false;
      final state = ReminderFiringOpen(
        reminder: _reminder(),
        viewerId: 'user-partner',
      );

      await tester.pumpWidget(
        _harness(
          ReminderFiringOverlay(
            state: state,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      // Not `pumpAndSettle`: the shake badge's `AnimationController.repeat`
      // never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.bySemanticsLabel('Dismiss reminder'),
        findsOneWidget,
      );

      await tester.tap(find.text('Swipe to wake'));
      await tester.pump();

      expect(dismissed, isTrue);

      semanticsHandle.dispose();
    });

    testWidgets('a horizontal swipe also dismisses (gesture equivalent to the button)', (
      tester,
    ) async {
      bool dismissed = false;
      final state = ReminderFiringOpen(
        reminder: _reminder(),
        viewerId: 'user-partner',
      );

      await tester.pumpWidget(
        _harness(
          ReminderFiringOverlay(
            state: state,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pump();

      await tester.fling(
        find.byIcon(CupidIcons.notificationsActive),
        const Offset(300, 0),
        800,
      );
      await tester.pump();

      expect(dismissed, isTrue);
    });
  });

  group('ReminderOverlayHost', () {
    testWidgets('mounts the overlay above the child once the cubit is open', (
      tester,
    ) async {
      final cubit = ReminderFiringCubitStub();

      await tester.pumpWidget(
        _harness(
          ReminderOverlayHost(
            createCubit: () => cubit,
            child: const Scaffold(body: Text('Home screen content')),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Home screen content'), findsOneWidget);
      expect(find.byType(ReminderFiringOverlay), findsNothing);

      cubit.emitOpen(_reminder(), viewerId: 'user-partner');
      await tester.pump();
      await tester.pump();

      expect(find.text('Home screen content'), findsOneWidget);
      expect(find.byType(ReminderFiringOverlay), findsOneWidget);
    });

    testWidgets('dismissing from the overlay calls through to the cubit', (
      tester,
    ) async {
      // Not `addTearDown(cubit.close)`: `BlocProvider.create` already owns
      // this cubit's disposal when its subtree unmounts at test end; an
      // extra explicit close raced with that and hung the test runner.
      final cubit = ReminderFiringCubitStub();

      await tester.pumpWidget(
        _harness(
          ReminderOverlayHost(
            createCubit: () => cubit,
            child: const Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );
      cubit.emitOpen(_reminder(), viewerId: 'user-partner');
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Swipe to wake'));
      await tester.pump();

      expect(cubit.dismissCalls, 1);
    });
  });
}

/// A minimal `ReminderFiringCubit` test double: it never touches a
/// repository/realtime stream, only exposes an [emitOpen] hook so widget
/// tests can drive `ReminderOverlayHost`'s `BlocBuilder` deterministically.
class ReminderFiringCubitStub extends ReminderFiringCubit {
  ReminderFiringCubitStub()
    : super(
        repository: ReminderRepository(
          api: CupidApi(dio: Dio(), interceptors: const []),
          realtime: _EmptyRealtimeCoordinator(),
          backendUserIdStore: BackendUserIdStore(),
        ),
        localPrefs: ReminderLocalPrefs(),
        backendUserIdStore: BackendUserIdStore(),
      );

  int dismissCalls = 0;

  void emitOpen(SyncedReminder reminder, {required String viewerId}) {
    emit(ReminderFiringOpen(reminder: reminder, viewerId: viewerId));
  }

  @override
  Future<void> dismiss() async {
    dismissCalls++;
  }

  @override
  Future<void> refreshFromForeground() async {}

  @override
  Future<bool> consumePendingTimeoutNotice() async => false;
}
