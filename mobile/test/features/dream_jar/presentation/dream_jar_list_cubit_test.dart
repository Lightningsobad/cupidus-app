import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/dream_jar_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `dream_jar_detail_cubit_test.dart`'s `_FakeDreamJarRepository`
/// pattern: overrides only [fetchJars], the sole method this phase's list
/// cubit calls.
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository(this._fetchJars) : super(CupidApiClient.create());

  final Future<List<DreamJar>> Function() _fetchJars;

  int fetchJarsCallCount = 0;

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) {
    fetchJarsCallCount++;
    return _fetchJars();
  }
}

DreamJar _jar({
  String id = 'jar-1',
  String name = 'Trip to Da Lat',
  num targetAmount = 1000000,
  num currentAmount = 200000,
  DreamJarStatus status = DreamJarStatus.active,
}) => DreamJar(
  id: id,
  name: name,
  targetAmount: targetAmount,
  currentAmount: currentAmount,
  deadline: null,
  currency: 'VND',
  status: status,
  serverProgress: null,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('DreamJarListCubit.load', () {
    test('emits loading then empty when there are no jars', () async {
      final repository = _FakeDreamJarRepository(() async => <DreamJar>[]);
      final cubit = DreamJarListCubit(repository);
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[
          isA<DreamJarListLoading>(),
          isA<DreamJarListEmpty>(),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test(
      'emits empty when every jar is archived (archived jars never appear)',
      () async {
        final repository = _FakeDreamJarRepository(
          () async => <DreamJar>[
            _jar(id: 'jar-1', status: DreamJarStatus.archived),
            _jar(id: 'jar-2', status: DreamJarStatus.archived),
          ],
        );
        final cubit = DreamJarListCubit(repository);
        addTearDown(cubit.close);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(<Matcher>[
            isA<DreamJarListLoading>(),
            isA<DreamJarListEmpty>(),
          ]),
        );

        await cubit.load();
        await expectation;
      },
    );

    test('emits ready with every active jar and no completed ones', () async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1'),
          _jar(id: 'jar-2'),
        ],
      );
      final cubit = DreamJarListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();

      final ready = cubit.state as DreamJarListReady;
      expect(ready.jars.map((jar) => jar.id), <String>['jar-1', 'jar-2']);
      expect(ready.completed, isEmpty);
    });

    test(
      'partitions a mixed collection into active and completed, dropping '
      'archived (STORY-061 AC1/AC5)',
      () async {
        final repository = _FakeDreamJarRepository(
          () async => <DreamJar>[
            _jar(id: 'jar-1', status: DreamJarStatus.active),
            _jar(id: 'jar-2', status: DreamJarStatus.archived),
            _jar(id: 'jar-3', status: DreamJarStatus.completed),
          ],
        );
        final cubit = DreamJarListCubit(repository);
        addTearDown(cubit.close);

        await cubit.load();

        final ready = cubit.state as DreamJarListReady;
        expect(ready.jars.map((jar) => jar.id), <String>['jar-1']);
        expect(ready.completed.map((jar) => jar.id), <String>['jar-3']);
      },
    );

    test(
      'keeps one active jar plus a completed jar in ready state so the '
      'single-jar bypass cannot fire',
      () async {
        final repository = _FakeDreamJarRepository(
          () async => <DreamJar>[
            _jar(id: 'jar-1', status: DreamJarStatus.active),
            _jar(id: 'jar-2', status: DreamJarStatus.completed),
          ],
        );
        final cubit = DreamJarListCubit(repository);
        addTearDown(cubit.close);

        await cubit.load();

        final ready = cubit.state as DreamJarListReady;
        expect(ready.jars, hasLength(1));
        expect(ready.completed, hasLength(1));
      },
    );

    test(
      'emits ready with a single active jar and no completed jars, the only '
      'shape the bypass may fire on',
      () async {
        final repository = _FakeDreamJarRepository(
          () async => <DreamJar>[_jar(id: 'jar-1')],
        );
        final cubit = DreamJarListCubit(repository);
        addTearDown(cubit.close);

        await cubit.load();

        final ready = cubit.state as DreamJarListReady;
        expect(ready.jars, hasLength(1));
        expect(ready.completed, isEmpty);
      },
    );

    test('emits ready, not empty, when every jar is completed', () async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', status: DreamJarStatus.completed),
          _jar(id: 'jar-2', status: DreamJarStatus.completed),
        ],
      );
      final cubit = DreamJarListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();

      final ready = cubit.state as DreamJarListReady;
      expect(ready.jars, isEmpty);
      expect(ready.completed, hasLength(2));
    });

    test(
      'emits unpaired when the repository throws DreamJarUnpairedFailure',
      () async {
        final repository = _FakeDreamJarRepository(
          () async =>
              throw const DreamJarUnpairedFailure('User not found or not paired'),
        );
        final cubit = DreamJarListCubit(repository);
        addTearDown(cubit.close);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(<Matcher>[
            isA<DreamJarListLoading>(),
            isA<DreamJarListUnpaired>(),
          ]),
        );

        await cubit.load();
        await expectation;
      },
    );

    test('emits failed for any other repository failure', () async {
      final failure = Exception('boom');
      final repository = _FakeDreamJarRepository(
        () => Future<List<DreamJar>>.error(failure),
      );
      final cubit = DreamJarListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();

      expect((cubit.state as DreamJarListFailed).failure, same(failure));
    });
  });

  group('DreamJarListCubit.refresh', () {
    test('re-fetches jars from the repository', () async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[_jar()],
      );
      final cubit = DreamJarListCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.refresh();

      expect(repository.fetchJarsCallCount, 2);
      expect(cubit.state, isA<DreamJarListReady>());
    });
  });
}
