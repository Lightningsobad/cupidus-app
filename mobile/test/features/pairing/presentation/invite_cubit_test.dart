import 'dart:async';

import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('InviteCubit', () {
    late DateTime clock;
    late List<_FakeTimer> scheduled;

    Timer fakeTimerFactory(Duration duration, void Function() callback) {
      final timer = _FakeTimer(callback);
      scheduled.add(timer);
      return timer;
    }

    setUp(() {
      clock = DateTime.utc(2026, 1, 1);
      scheduled = [];
    });

    InviteCubit buildCubit(
      Future<PairingInvitation> Function() generateInvitation,
    ) {
      return InviteCubit(
        generateInvitation: generateInvitation,
        now: () => clock,
        timerFactory: fakeTimerFactory,
      );
    }

    test('starts in InviteLoading then emits InviteReady on success', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(() async => invitation);
      addTearDown(cubit.close);

      expect(cubit.state, isA<InviteLoading>());
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<InviteReady>());
      expect((state as InviteReady).invitation.code, '3F9A2B');
      expect(state.remaining, const Duration(hours: 24));
    });

    test('emits InviteFailed when generation throws', () async {
      final cubit = buildCubit(() async => throw Exception('boom'));
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, isA<InviteFailed>());
    });

    test('the countdown ticks down from expiresAt on each scheduled tick', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(() async => invitation);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(scheduled, hasLength(1));
      clock = clock.add(const Duration(minutes: 20));
      scheduled.single.callback();
      await pumpEventQueue();

      final state = cubit.state as InviteReady;
      expect(state.remaining, const Duration(hours: 23, minutes: 40));
    });

    test(
      'an idempotent refresh does not flash a loading state once ready',
      () async {
        var callCount = 0;
        final invitation = PairingInvitation(
          code: '3F9A2B',
          expiresAt: clock.add(const Duration(hours: 24)),
        );
        final cubit = buildCubit(() async {
          callCount++;
          return invitation;
        });
        addTearDown(cubit.close);
        await pumpEventQueue();
        expect(cubit.state, isA<InviteReady>());

        final states = <InviteState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.refresh();
        await pumpEventQueue();
        await subscription.cancel();

        expect(callCount, 2);
        expect(states.any((s) => s is InviteLoading), isFalse);
        expect(states.last, isA<InviteReady>());
        expect((states.last as InviteReady).invitation.code, '3F9A2B');
      },
    );
  });
}
