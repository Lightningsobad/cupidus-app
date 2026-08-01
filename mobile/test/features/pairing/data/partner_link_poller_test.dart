import 'dart:async';

import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLifecycleSource implements RealtimeLifecycleSource {
  _FakeLifecycleSource(this.currentState);

  @override
  AppLifecycleState currentState;

  bool disposed = false;
  final _controller = StreamController<AppLifecycleState>.broadcast(
    sync: true,
  );

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  void emit(AppLifecycleState state) {
    currentState = state;
    _controller.add(state);
  }

  @override
  void dispose() {
    disposed = true;
    _controller.close();
  }
}

class _FakeTimer implements Timer {
  _FakeTimer(this.duration, this.callback);

  final Duration duration;
  final void Function() callback;
  bool _cancelled = false;

  @override
  bool get isActive => !_cancelled;

  @override
  void cancel() {
    _cancelled = true;
  }

  @override
  int get tick => 0;
}

void main() {
  group('PartnerLinkPoller', () {
    late DateTime clock;
    late _FakeLifecycleSource lifecycle;
    late List<_FakeTimer> scheduled;
    late List<PartnerLink> paired;
    late int timedOutCount;

    Timer fakeTimerFactory(Duration duration, void Function() callback) {
      final timer = _FakeTimer(duration, callback);
      scheduled.add(timer);
      return timer;
    }

    PartnerLinkPoller buildPoller({
      required PartnerLinkFetcher fetchPartnerLink,
      required DateTime expiresAt,
    }) {
      return PartnerLinkPoller(
        fetchPartnerLink: fetchPartnerLink,
        expiresAt: expiresAt,
        onPaired: paired.add,
        onTimedOut: () => timedOutCount++,
        lifecycleSource: lifecycle,
        now: () => clock,
        timerFactory: fakeTimerFactory,
      );
    }

    setUp(() {
      clock = DateTime.utc(2026, 1, 1);
      lifecycle = _FakeLifecycleSource(AppLifecycleState.resumed);
      scheduled = [];
      paired = [];
      timedOutCount = 0;
    });

    test('schedules a 3s poll immediately when foreground at start', () {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();

      expect(scheduled, hasLength(1));
      expect(scheduled.single.duration, const Duration(seconds: 3));
    });

    test('stops on partnerId != null and calls onPaired exactly once', () async {
      const link = PartnerLink(partnerId: 'partner-1');
      final poller = buildPoller(
        fetchPartnerLink: () async => link,
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      scheduled.single.callback();
      await pumpEventQueue();

      expect(paired, [link]);
      expect(timedOutCount, 0);
      // No further timer scheduled once paired.
      expect(scheduled, hasLength(1));
    });

    test('a poll failure is silent and the loop reschedules', () async {
      var callCount = 0;
      final poller = buildPoller(
        fetchPartnerLink: () async {
          callCount++;
          if (callCount == 1) {
            throw Exception('transient network failure');
          }
          return const PartnerLink(partnerId: null);
        },
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      scheduled.single.callback();
      await pumpEventQueue();

      expect(paired, isEmpty);
      expect(timedOutCount, 0);
      expect(scheduled, hasLength(2));
    });

    test('switches from a 3s to a 10s interval after 60s elapsed', () async {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      expect(scheduled[0].duration, const Duration(seconds: 3));

      clock = clock.add(const Duration(seconds: 61));
      scheduled[0].callback();
      await pumpEventQueue();

      expect(scheduled[1].duration, const Duration(seconds: 10));
    });

    test('dispose tears down the timer and lifecycle subscription', () async {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      poller.dispose();

      expect(lifecycle.disposed, isTrue);

      // Even if the already-scheduled timer somehow fires late, dispose must
      // make it inert.
      scheduled.single.callback();
      await pumpEventQueue();

      expect(paired, isEmpty);
      expect(timedOutCount, 0);
      expect(scheduled, hasLength(1));
    });

    test('backgrounding cancels the pending timer and stops polling', () async {
      var callCount = 0;
      final poller = buildPoller(
        fetchPartnerLink: () async {
          callCount++;
          return const PartnerLink(partnerId: null);
        },
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      lifecycle.emit(AppLifecycleState.paused);

      expect(scheduled.single.isActive, isFalse);
      expect(callCount, 0);
    });

    test('resuming in foreground before the hard stop reschedules a poll', () {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      lifecycle.emit(AppLifecycleState.paused);
      lifecycle.emit(AppLifecycleState.resumed);

      expect(scheduled, hasLength(2));
      expect(scheduled[1].isActive, isTrue);
      expect(paired, isEmpty);
      expect(timedOutCount, 0);
    });

    test('hard stop fires at 10 minutes even when expiresAt is later', () async {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(hours: 24)),
      );

      poller.start();
      clock = clock.add(const Duration(minutes: 10));
      scheduled.single.callback();
      await pumpEventQueue();

      expect(timedOutCount, 1);
      expect(paired, isEmpty);
    });

    test('hard stop fires at expiresAt when it is sooner than 10 minutes', () async {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(minutes: 2)),
      );

      poller.start();
      clock = clock.add(const Duration(minutes: 2));
      scheduled.single.callback();
      await pumpEventQueue();

      expect(timedOutCount, 1);
      expect(paired, isEmpty);
    });

    test('resuming after the hard-stop deadline elapsed while backgrounded '
        'times out immediately', () {
      final poller = buildPoller(
        fetchPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: clock.add(const Duration(minutes: 2)),
      );

      poller.start();
      lifecycle.emit(AppLifecycleState.paused);
      clock = clock.add(const Duration(minutes: 5));
      lifecycle.emit(AppLifecycleState.resumed);

      expect(timedOutCount, 1);
      expect(paired, isEmpty);
    });
  });
}
