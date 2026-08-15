import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/dream_jar_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overrides only the two methods this phase's cubit calls; the super
/// constructor's [CupidApi] is never exercised (mirrors
/// `test/features/auth/presentation/sign_out_cubit_test.dart`'s
/// `CupidApiClient.create()` no-network pattern).
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository({
    required this._fetchJar,
    this._addContribution,
    Future<List<Contribution>> Function()? fetchContributions,
  }) : _fetchContributions =
           fetchContributions ?? (() async => <Contribution>[]),
       super(CupidApiClient.create());

  final Future<DreamJar> Function() _fetchJar;
  final Future<Contribution> Function({
    required String jarId,
    required num amount,
  })?
  _addContribution;
  final Future<List<Contribution>> Function() _fetchContributions;

  int fetchJarCallCount = 0;
  int addContributionCallCount = 0;

  @override
  Future<DreamJar> fetchJar(String id) {
    fetchJarCallCount++;
    return _fetchJar();
  }

  @override
  Future<Contribution> addContribution({
    required String jarId,
    required num amount,
  }) {
    addContributionCallCount++;
    final override = _addContribution;
    if (override == null) throw UnimplementedError();
    return override(jarId: jarId, amount: amount);
  }

  @override
  Future<List<Contribution>> fetchContributions(
    String jarId, {
    int limit = 50,
    int offset = 0,
  }) => _fetchContributions();
}

DreamJar _jar({
  String id = 'jar-1',
  num targetAmount = 1000000,
  num currentAmount = 200000,
  DreamJarStatus status = DreamJarStatus.active,
}) => DreamJar(
  id: id,
  name: 'Trip to Da Lat',
  targetAmount: targetAmount,
  currentAmount: currentAmount,
  deadline: null,
  currency: 'VND',
  status: status,
  serverProgress: null,
  createdAt: DateTime(2026, 1, 1),
);

Contribution _contribution({num amount = 100000}) => Contribution(
  id: 'contribution-1',
  dreamJarId: 'jar-1',
  userId: 'user-1',
  amount: amount,
  note: null,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('DreamJarDetailCubit.loadJar', () {
    test('emits loading then loaded on a successful fetch', () async {
      final repository = _FakeDreamJarRepository(fetchJar: () async => _jar());
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<DreamJarDetailLoading>(), isA<DreamJarDetailLoaded>()]),
      );

      await cubit.loadJar();
      await expectation;

      expect((cubit.state as DreamJarDetailLoaded).jar.id, 'jar-1');
    });

    test('emits unpaired when the repository throws DreamJarUnpairedFailure', () async {
      final repository = _FakeDreamJarRepository(
        fetchJar: () async =>
            throw const DreamJarUnpairedFailure('User not found or not paired'),
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<DreamJarDetailLoading>(), isA<DreamJarDetailUnpaired>()]),
      );

      await cubit.loadJar();
      await expectation;
    });

    test('emits failed for any other repository failure', () async {
      final failure = Exception('boom');
      final repository = _FakeDreamJarRepository(
        fetchJar: () => Future<DreamJar>.error(failure),
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);

      DreamJarDetailFailed? failedState;
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[
          isA<DreamJarDetailLoading>(),
          predicate<DreamJarDetailState>((state) {
            failedState = state as DreamJarDetailFailed;
            return true;
          }),
        ]),
      );

      await cubit.loadJar();
      await expectation;

      expect(failedState?.failure, same(failure));
    });

    test('loads contributions after the jar is already on screen', () async {
      final contributionsGate = Completer<List<Contribution>>();
      final repository = _FakeDreamJarRepository(
        fetchJar: () async => _jar(),
        fetchContributions: () => contributionsGate.future,
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);

      final load = cubit.loadJar();
      await Future<void>.delayed(Duration.zero);

      // The jar renders before the comparison data arrives.
      expect((cubit.state as DreamJarDetailLoaded).contributions, isEmpty);

      contributionsGate.complete(<Contribution>[_contribution()]);
      await load;

      expect((cubit.state as DreamJarDetailLoaded).contributions, hasLength(1));
    });

    test('keeps the jar loaded when the contributions fetch fails', () async {
      final repository = _FakeDreamJarRepository(
        fetchJar: () async => _jar(),
        fetchContributions: () =>
            Future<List<Contribution>>.error(Exception('boom')),
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);

      await cubit.loadJar();

      final loaded = cubit.state as DreamJarDetailLoaded;
      expect(loaded.jar.id, 'jar-1');
      expect(loaded.contributions, isEmpty);
    });
  });

  group('DreamJarDetailCubit.addContribution', () {
    test('is ignored when the jar has not finished loading', () async {
      final repository = _FakeDreamJarRepository(
        fetchJar: () => Completer<DreamJar>().future,
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);
      unawaited(cubit.loadJar());

      await cubit.addContribution(100000);

      expect(repository.addContributionCallCount, 0);
    });

    test('submits the preset amount and refreshes the jar on success', () async {
      var fetchCount = 0;
      final repository = _FakeDreamJarRepository(
        fetchJar: () async {
          fetchCount++;
          return _jar(currentAmount: fetchCount == 1 ? 200000 : 300000);
        },
        addContribution: ({required jarId, required amount}) async =>
            _contribution(amount: amount),
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);
      await cubit.loadJar();

      await cubit.addContribution(100000);

      expect(repository.addContributionCallCount, 1);
      expect(fetchCount, 2);
      final loaded = cubit.state as DreamJarDetailLoaded;
      expect(loaded.jar.currentAmount, 300000);
      expect(loaded.isAddingContribution, isFalse);
    });

    test('ignores a second tap while the first contribution is in flight', () async {
      final completer = Completer<Contribution>();
      final repository = _FakeDreamJarRepository(
        fetchJar: () async => _jar(),
        addContribution: ({required jarId, required amount}) => completer.future,
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);
      await cubit.loadJar();

      final first = cubit.addContribution(100000);
      final second = cubit.addContribution(100000);

      expect(repository.addContributionCallCount, 1);
      expect((cubit.state as DreamJarDetailLoaded).isAddingContribution, isTrue);

      completer.complete(_contribution());
      await first;
      await second;

      expect(repository.addContributionCallCount, 1);
    });

    test('keeps the jar visible and records the failure when submission fails', () async {
      final failure = Exception('network down');
      final repository = _FakeDreamJarRepository(
        fetchJar: () async => _jar(),
        addContribution: ({required jarId, required amount}) =>
            Future<Contribution>.error(failure),
      );
      final cubit = DreamJarDetailCubit(repository: repository, jarId: 'jar-1');
      addTearDown(cubit.close);
      await cubit.loadJar();

      await cubit.addContribution(100000);

      final loaded = cubit.state as DreamJarDetailLoaded;
      expect(loaded.isAddingContribution, isFalse);
      expect(loaded.contributionFailure, same(failure));
      expect(loaded.jar.currentAmount, 200000);
    });
  });
}
