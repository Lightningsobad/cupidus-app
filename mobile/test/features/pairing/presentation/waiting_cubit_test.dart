import 'dart:async';

import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLifecycleSource implements RealtimeLifecycleSource {
  _FakeLifecycleSource(this.currentState);

  @override
  AppLifecycleState currentState;

  final _controller = StreamController<AppLifecycleState>.broadcast(
    sync: true,
  );

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  @override
  void dispose() => _controller.close();
}

class _FakeTimer implements Timer {
  _FakeTimer(this.callback);

  final void Function() callback;
  bool _cancelled = false;

  @override
  bool get isActive => !_cancelled;

  @override
  void cancel() => _cancelled = true;

  @override
  int get tick => 0;
}

void main() {
  group('WaitingCubit', () {
    late DateTime clock;
    late _FakeLifecycleSource lifecycle;
    late List<_FakeTimer> scheduled;

    Timer fakeTimerFactory(Duration duration, void Function() callback) {
      final timer = _FakeTimer(callback);
      scheduled.add(timer);
      return timer;
    }

    setUp(() {
      clock = DateTime.utc(2026, 1, 1);
      lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
      scheduled = [];
    });

    WaitingCubit buildCubit({
      required Future<PartnerLink> Function() getPartnerLink,
      required DateTime expiresAt,
    }) {
      return WaitingCubit(
        getPartnerLink: getPartnerLink,
        expiresAt: expiresAt,
        createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
          fetchPartnerLink: getPartnerLink,
          expiresAt: expiresAt,
          onPaired: onPaired,
          onTimedOut: onTimedOut,
          lifecycleSource: lifecycle,
          now: () => clock,
          timerFactory: fakeTimerFactory,
        ),
      );
    }

    test('starts in WaitingInProgress', () {
      final cubit = buildCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      addTearDown(cubit.close);

      expect(cubit.state, isA<WaitingInProgress>());
    });

    test('emits WaitingPaired when the poll finds a partnerId', () async {
      const link = PartnerLink(partnerId: 'partner-1');
      final cubit = buildCubit(
        getPartnerLink: () async => link,
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      addTearDown(cubit.close);

      scheduled.single.callback();
      await pumpEventQueue();

      expect(cubit.state, isA<WaitingPaired>());
      expect((cubit.state as WaitingPaired).link, link);
    });

    test('emits WaitingTimedOut at the poll hard stop', () async {
      final cubit = buildCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(minutes: 2)),
      );
      addTearDown(cubit.close);

      clock = clock.add(const Duration(minutes: 2));
      scheduled.single.callback();
      await pumpEventQueue();

      expect(cubit.state, isA<WaitingTimedOut>());
    });

    test('refreshNow immediately checks and can emit WaitingPaired', () async {
      const link = PartnerLink(partnerId: 'partner-1');
      final cubit = buildCubit(
        getPartnerLink: () async => link,
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      addTearDown(cubit.close);

      await cubit.refreshNow();

      expect(cubit.state, isA<WaitingPaired>());
      expect((cubit.state as WaitingPaired).link, link);
    });

    test(
      'refreshNow silently no-ops when still unpaired and keeps waiting',
      () async {
        final cubit = buildCubit(
          getPartnerLink: () async => const PartnerLink(partnerId: null),
          expiresAt: clock.add(const Duration(hours: 24)),
        );
        addTearDown(cubit.close);

        await cubit.refreshNow();

        expect(cubit.state, isA<WaitingInProgress>());
      },
    );

    test(
      'refreshNow is silent on failure and does not surface an error state',
      () async {
        final cubit = buildCubit(
          getPartnerLink: () async => throw Exception('network'),
          expiresAt: clock.add(const Duration(hours: 24)),
        );
        addTearDown(cubit.close);

        await cubit.refreshNow();

        expect(cubit.state, isA<WaitingInProgress>());
      },
    );
  });
}
