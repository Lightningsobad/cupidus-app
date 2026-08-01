import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_cubit.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_pet_repository.dart';

class _MutableClock {
  _MutableClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}

/// A synchronous, manually-driven ticker double (`pet_cubit.dart`'s
/// `PetCooldownTicker`), so tests never wait on real wall-clock time.
class _ManualTicker {
  final _controller = StreamController<void>.broadcast(sync: true);

  Stream<void> call(Duration interval) => _controller.stream;

  void tick() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}

PetStatus _status({DateTime? lastInteraction, int totalInteractions = 10}) {
  return PetStatus(
    pet: Pet(
      id: 'pet-1',
      coupleId: 'couple-1',
      species: PetSpecies.bunny,
      name: 'Bun',
      happiness: 70,
      level: 1,
      totalInteractions: totalInteractions,
      lastInteraction: lastInteraction,
    ),
    mood: PetMood.happy,
    decayedHappiness: 70,
    milestone: null,
    nextMilestone: 50,
  );
}

void main() {
  group('PetCubit.load', () {
    test('emits PetLocked and never reads status when unpaired', () async {
      final repository = FakePetRepository()..paired = false;
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state, isA<PetLocked>());
      expect(repository.readStatusCalls, 0);
    });

    test('emits PetNoPet when paired but no pet exists yet', () async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state, isA<PetNoPet>());
    });

    test('emits PetReady with no cooldown when never interacted with', () async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(lastInteraction: null);
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);

      await cubit.load();

      final state = cubit.state as PetReady;
      expect(state.cooldownRemaining, isNull);
    });

    test(
      'derives cooldownRemaining from lastInteraction: 2s old leaves ~3s',
      () async {
        final now = DateTime(2026, 1, 1, 0, 0, 5);
        final lastInteraction = DateTime(2026, 1, 1, 0, 0, 3);
        final repository = FakePetRepository()
          ..paired = true
          ..status = _status(lastInteraction: lastInteraction);
        final cubit = PetCubit(repository: repository, now: () => now);
        addTearDown(cubit.close);

        await cubit.load();

        final state = cubit.state as PetReady;
        expect(state.cooldownRemaining, const Duration(seconds: 3));
      },
    );

    test('emits PetFailure when readPairing throws', () async {
      final repository = FakePetRepository()
        ..readPairingError = const NetworkUnavailableFailure();
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state, isA<PetFailure>());
      expect((cubit.state as PetFailure).failure, isA<NetworkUnavailableFailure>());
    });
  });

  group('PetCubit.interact', () {
    test('is a no-op (no network call) when not in PetReady', () async {
      final repository = FakePetRepository()..paired = false;
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state, isA<PetLocked>());

      await cubit.interact();

      expect(repository.interactCalls, 0);
      expect(cubit.state, isA<PetLocked>());
    });

    test(
      'calls repository.interact and arms a fresh 5s cooldown on success',
      () async {
        final clock = _MutableClock(DateTime(2026, 1, 1, 0, 0, 0));
        final ticker = _ManualTicker();
        addTearDown(ticker.dispose);
        final interactedAt = DateTime(2026, 1, 1, 0, 0, 0);
        final repository = FakePetRepository()
          ..paired = true
          ..status = _status(lastInteraction: null)
          ..statusAfterInteract = _status(lastInteraction: interactedAt);
        final cubit = PetCubit(
          repository: repository,
          now: clock.call,
          ticker: ticker.call,
        );
        addTearDown(cubit.close);
        await cubit.load();

        await cubit.interact();

        expect(repository.interactCalls, 1);
        final ready = cubit.state as PetReady;
        expect(ready.cooldownRemaining, petInteractionCooldown);
      },
    );

    test(
      'performs no second network call while the cooldown is active',
      () async {
        final clock = _MutableClock(DateTime(2026, 1, 1, 0, 0, 0));
        final ticker = _ManualTicker();
        addTearDown(ticker.dispose);
        final repository = FakePetRepository()
          ..paired = true
          ..status = _status(lastInteraction: null)
          ..statusAfterInteract = _status(lastInteraction: clock.call());
        final cubit = PetCubit(
          repository: repository,
          now: clock.call,
          ticker: ticker.call,
        );
        addTearDown(cubit.close);
        await cubit.load();
        await cubit.interact();
        expect(repository.interactCalls, 1);

        await cubit.interact();

        expect(repository.interactCalls, 1);
      },
    );

    test('the ticker counts the cooldown down and clears it at 5s', () async {
      final clock = _MutableClock(DateTime(2026, 1, 1, 0, 0, 0));
      final ticker = _ManualTicker();
      addTearDown(ticker.dispose);
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(lastInteraction: null)
        ..statusAfterInteract = _status(lastInteraction: clock.call());
      final cubit = PetCubit(
        repository: repository,
        now: clock.call,
        ticker: ticker.call,
      );
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.interact();
      expect((cubit.state as PetReady).cooldownRemaining, petInteractionCooldown);

      clock.advance(const Duration(seconds: 1));
      ticker.tick();
      expect((cubit.state as PetReady).cooldownRemaining, const Duration(seconds: 4));

      clock.advance(const Duration(seconds: 4));
      ticker.tick();
      expect((cubit.state as PetReady).cooldownRemaining, isNull);
    });

    test(
      'a 400 during interact re-arms the cooldown instead of emitting PetFailure',
      () async {
        final clock = _MutableClock(DateTime(2026, 1, 1, 0, 0, 0));
        final ticker = _ManualTicker();
        addTearDown(ticker.dispose);
        final staleStatus = _status(lastInteraction: null);
        final repository = FakePetRepository()
          ..paired = true
          ..status = staleStatus
          ..interactError = const HttpStatusFailure(400, 'Slow down!');
        final cubit = PetCubit(
          repository: repository,
          now: clock.call,
          ticker: ticker.call,
        );
        addTearDown(cubit.close);
        await cubit.load();
        expect((cubit.state as PetReady).cooldownRemaining, isNull);

        await cubit.interact();

        expect(cubit.state, isNot(isA<PetFailure>()));
        final ready = cubit.state as PetReady;
        expect(ready.cooldownRemaining, petInteractionCooldown);
        expect(ready.status, staleStatus);
      },
    );

    test('a non-400 failure during interact emits PetFailure', () async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(lastInteraction: null)
        ..interactError = const NetworkUnavailableFailure();
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.interact();

      expect(cubit.state, isA<PetFailure>());
      expect((cubit.state as PetFailure).failure, isA<NetworkUnavailableFailure>());
    });
  });
}
