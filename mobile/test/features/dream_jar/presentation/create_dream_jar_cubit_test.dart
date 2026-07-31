import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/create_dream_jar_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `dream_jar_detail_cubit_test.dart`'s `_FakeDreamJarRepository`
/// pattern: overrides only [createJar], the sole method this cubit calls.
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository(this._createJar) : super(CupidApiClient.create());

  final Future<DreamJar> Function({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  })
  _createJar;

  int createJarCallCount = 0;

  @override
  Future<DreamJar> createJar({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  }) {
    createJarCallCount++;
    return _createJar(name: name, targetAmount: targetAmount, deadline: deadline);
  }
}

DreamJar _jar({String name = 'Trip to Da Lat', num targetAmount = 500000}) =>
    DreamJar(
      id: 'jar-1',
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
      deadline: null,
      currency: 'VND',
      status: DreamJarStatus.active,
      serverProgress: null,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('CreateDreamJarCubit.submit validation', () {
    test('emits validation failure for a blank name', () async {
      final repository = _FakeDreamJarRepository(
        ({required name, required targetAmount, deadline}) async => _jar(),
      );
      final cubit = CreateDreamJarCubit(repository);
      addTearDown(cubit.close);

      await cubit.submit(name: '   ', targetAmount: 500000);

      final state = cubit.state as CreateDreamJarValidationFailed;
      expect(state.nameInvalid, isTrue);
      expect(state.targetAmountInvalid, isFalse);
      expect(repository.createJarCallCount, 0);
    });

    test(
      'emits validation failure for a null or below-minimum target amount',
      () async {
        final repository = _FakeDreamJarRepository(
          ({required name, required targetAmount, deadline}) async => _jar(),
        );
        final cubit = CreateDreamJarCubit(repository);
        addTearDown(cubit.close);

        await cubit.submit(name: 'Trip to Da Lat', targetAmount: 0);

        final state = cubit.state as CreateDreamJarValidationFailed;
        expect(state.nameInvalid, isFalse);
        expect(state.targetAmountInvalid, isTrue);
        expect(repository.createJarCallCount, 0);
      },
    );
  });

  group('CreateDreamJarCubit.submit', () {
    test('creates the jar and emits success on valid input', () async {
      final repository = _FakeDreamJarRepository(
        ({required name, required targetAmount, deadline}) async =>
            _jar(name: name, targetAmount: targetAmount),
      );
      final cubit = CreateDreamJarCubit(repository);
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[
          isA<CreateDreamJarSubmitting>(),
          isA<CreateDreamJarSuccess>(),
        ]),
      );

      await cubit.submit(name: 'Trip to Da Lat', targetAmount: 500000);
      await expectation;

      expect(repository.createJarCallCount, 1);
      final success = cubit.state as CreateDreamJarSuccess;
      expect(success.jar.name, 'Trip to Da Lat');
    });

    test('ignores a second submit while the first is in flight', () async {
      final completer = Completer<DreamJar>();
      final repository = _FakeDreamJarRepository(
        ({required name, required targetAmount, deadline}) => completer.future,
      );
      final cubit = CreateDreamJarCubit(repository);
      addTearDown(cubit.close);

      final first = cubit.submit(name: 'Trip to Da Lat', targetAmount: 500000);
      final second = cubit.submit(name: 'Trip to Da Lat', targetAmount: 500000);

      expect(repository.createJarCallCount, 1);
      expect(cubit.state, isA<CreateDreamJarSubmitting>());

      completer.complete(_jar());
      await first;
      await second;

      expect(repository.createJarCallCount, 1);
    });

    test('emits failed when the repository call fails', () async {
      final failure = Exception('network down');
      final repository = _FakeDreamJarRepository(
        ({required name, required targetAmount, deadline}) =>
            Future<DreamJar>.error(failure),
      );
      final cubit = CreateDreamJarCubit(repository);
      addTearDown(cubit.close);

      await cubit.submit(name: 'Trip to Da Lat', targetAmount: 500000);

      expect((cubit.state as CreateDreamJarFailed).failure, same(failure));
    });
  });
}
