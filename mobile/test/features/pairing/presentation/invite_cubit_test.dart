import 'dart:async';

import 'package:cupid_api/cupid_api.dart' show UpdateProfileDtoCoupleTypeEnum;
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/presentation/couple_type.dart';
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
      Future<PairingInvitation> Function() generateInvitation, {
      Future<String?> Function()? fetchCoupleType,
      Future<void> Function(CoupleType coupleType)? saveCoupleType,
    }) {
      return InviteCubit(
        generateInvitation: generateInvitation,
        fetchCoupleType: fetchCoupleType,
        saveCoupleType: saveCoupleType,
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

    test('pre-fills the selection from the profile on the first ready state', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(
        () async => invitation,
        fetchCoupleType: () async => 'SAME_CITY',
      );
      addTearDown(cubit.close);

      final states = <InviteState>[];
      final subscription = cubit.stream.listen(states.add);
      await pumpEventQueue();
      await subscription.cancel();

      // AC5 is about the *first* paint, so asserting the settled state alone
      // would pass even if the card flickered in unselected first.
      expect(
        states.whereType<InviteReady>().first.selectedCoupleType,
        CoupleType.sameCity,
      );
    });

    test('a profile read resolving after the code still pre-fills', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(
        () async => invitation,
        fetchCoupleType: () => Future<String?>.delayed(
          const Duration(milliseconds: 5),
          () => 'DATING',
        ),
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect((cubit.state as InviteReady).selectedCoupleType, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect((cubit.state as InviteReady).selectedCoupleType, CoupleType.dating);
    });

    test('a failing profile read still reaches InviteReady unselected', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(
        () async => invitation,
        fetchCoupleType: () async => throw Exception('profile unavailable'),
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<InviteReady>());
      expect((state as InviteReady).selectedCoupleType, isNull);
    });

    test('an unknown persisted value leaves every card unselected', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(
        () async => invitation,
        fetchCoupleType: () async => 'LONG_TERM',
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect((cubit.state as InviteReady).selectedCoupleType, isNull);
    });

    test('the selection replaces the previous one instead of adding', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(() async => invitation);
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.selectCoupleType(CoupleType.longDistance);
      cubit.selectCoupleType(CoupleType.livingTogether);

      expect(
        (cubit.state as InviteReady).selectedCoupleType,
        CoupleType.livingTogether,
      );
    });

    test('the selection survives a countdown tick', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(() async => invitation);
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.selectCoupleType(CoupleType.dating);
      expect(scheduled, hasLength(1));
      clock = clock.add(const Duration(minutes: 20));
      scheduled.single.callback();
      await pumpEventQueue();

      final state = cubit.state as InviteReady;
      expect(state.selectedCoupleType, CoupleType.dating);
      expect(state.remaining, const Duration(hours: 23, minutes: 40));
    });

    test('submitCoupleType persists the selection once and returns true', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final saved = <CoupleType>[];
      final cubit = buildCubit(
        () async => invitation,
        saveCoupleType: (coupleType) async => saved.add(coupleType),
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.selectCoupleType(CoupleType.livingTogether);
      final bool result = await cubit.submitCoupleType();

      expect(result, isTrue);
      expect(saved, <CoupleType>[CoupleType.livingTogether]);
      expect(saved.single.wireValue, 'LIVING_TOGETHER');
      final state = cubit.state as InviteReady;
      expect(state.selectedCoupleType, CoupleType.livingTogether);
      expect(state.isSaving, isFalse);
    });

    test('a second submit while the write is in flight is ignored', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final completer = Completer<void>();
      var callCount = 0;
      final cubit = buildCubit(
        () async => invitation,
        saveCoupleType: (_) {
          callCount++;
          return completer.future;
        },
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.selectCoupleType(CoupleType.dating);
      final Future<bool> inFlight = cubit.submitCoupleType();
      await pumpEventQueue();

      expect((cubit.state as InviteReady).isSaving, isTrue);
      expect(await cubit.submitCoupleType(), isFalse);

      completer.complete();

      expect(await inFlight, isTrue);
      expect(callCount, 1);
      expect((cubit.state as InviteReady).isSaving, isFalse);
    });

    test('submitCoupleType keeps the selection when the write fails', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      final cubit = buildCubit(
        () async => invitation,
        saveCoupleType: (_) async => throw Exception('boom'),
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.selectCoupleType(CoupleType.sameCity);
      final bool result = await cubit.submitCoupleType();

      expect(result, isFalse);
      final state = cubit.state as InviteReady;
      // The CTA must come back enabled so the failure is retryable in place.
      expect(state.selectedCoupleType, CoupleType.sameCity);
      expect(state.isSaving, isFalse);
      expect(state, isA<InviteReady>());
    });

    test('submitCoupleType is a no-op with nothing selected', () async {
      final invitation = PairingInvitation(
        code: '3F9A2B',
        expiresAt: clock.add(const Duration(hours: 24)),
      );
      var callCount = 0;
      final cubit = buildCubit(
        () async => invitation,
        saveCoupleType: (_) async => callCount++,
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(await cubit.submitCoupleType(), isFalse);
      expect(callCount, 0);
    });
  });

  group('CoupleType', () {
    test('exposes the 4 backend literals in catalog order', () {
      expect(
        CoupleType.values.map((c) => c.wireValue).toList(),
        <String>['LONG_DISTANCE', 'SAME_CITY', 'DATING', 'LIVING_TOGETHER'],
      );
    });

    test('parses every wire value and degrades unknown ones to null', () {
      expect(coupleTypeFromWire('LONG_DISTANCE'), CoupleType.longDistance);
      expect(coupleTypeFromWire('SAME_CITY'), CoupleType.sameCity);
      expect(coupleTypeFromWire('DATING'), CoupleType.dating);
      expect(coupleTypeFromWire('LIVING_TOGETHER'), CoupleType.livingTogether);
      expect(coupleTypeFromWire('LONG_TERM'), isNull);
      expect(coupleTypeFromWire(''), isNull);
      expect(coupleTypeFromWire(null), isNull);
    });

    test('every wire value exists in the generated client enum', () {
      // `invite_screen.dart` maps to `UpdateProfileDtoCoupleTypeEnum` by this
      // literal, so drift here is a `StateError` at tap time, not a build
      // error.
      final Set<String> generated = UpdateProfileDtoCoupleTypeEnum.values
          .map((UpdateProfileDtoCoupleTypeEnum value) => value.value)
          .toSet();
      for (final CoupleType coupleType in CoupleType.values) {
        expect(generated, contains(coupleType.wireValue));
      }
    });
  });
}
