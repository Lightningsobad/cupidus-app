import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/contribution_history_cubit.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/partner_split_card.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overrides only [fetchContributions], the sole method this phase's cubit
/// calls (mirrors `dream_jar_list_cubit_test.dart`'s
/// `_FakeDreamJarRepository` pattern).
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository(this._fetchContributions)
    : super(CupidApiClient.create());

  final Future<List<Contribution>> Function({
    required int limit,
    required int offset,
  })
  _fetchContributions;

  final List<({int limit, int offset})> calls = [];

  @override
  Future<List<Contribution>> fetchContributions(
    String jarId, {
    int limit = 50,
    int offset = 0,
  }) {
    calls.add((limit: limit, offset: offset));
    return _fetchContributions(limit: limit, offset: offset);
  }
}

Contribution _contribution({
  String id = 'c-1',
  String userId = 'user-1',
  num amount = 100000,
  String? note,
  DateTime? createdAt,
}) => Contribution(
  id: id,
  dreamJarId: 'jar-1',
  userId: userId,
  amount: amount,
  note: note,
  createdAt: createdAt ?? DateTime(2026, 1, 1),
);

List<Contribution> _page(int count, {int startIndex = 0}) => List.generate(
  count,
  (i) => _contribution(id: 'c-${startIndex + i}'),
);

void main() {
  group('ContributionHistoryCubit.loadFirstPage', () {
    test(
      'emits loading then loaded with hasMore false for a short page',
      () async {
        final repository = _FakeDreamJarRepository(
          ({required limit, required offset}) async => _page(3),
        );
        final cubit = ContributionHistoryCubit(
          repository: repository,
          jarId: 'jar-1',
        );
        addTearDown(cubit.close);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(<Matcher>[
            isA<ContributionHistoryLoading>(),
            isA<ContributionHistoryLoaded>(),
          ]),
        );

        await cubit.loadFirstPage();
        await expectation;

        final loaded = cubit.state as ContributionHistoryLoaded;
        expect(loaded.contributions, hasLength(3));
        expect(loaded.hasMore, isFalse);
        expect(repository.calls.single, (limit: 20, offset: 0));
      },
    );

    test('emits loaded with hasMore true for a full page', () async {
      final repository = _FakeDreamJarRepository(
        ({required limit, required offset}) async => _page(20),
      );
      final cubit = ContributionHistoryCubit(
        repository: repository,
        jarId: 'jar-1',
      );
      addTearDown(cubit.close);

      await cubit.loadFirstPage();

      final loaded = cubit.state as ContributionHistoryLoaded;
      expect(loaded.hasMore, isTrue);
    });

    test(
      'emits unpaired when the repository throws DreamJarUnpairedFailure',
      () async {
        final repository = _FakeDreamJarRepository(
          ({required limit, required offset}) async =>
              throw const DreamJarUnpairedFailure(
                'User not found or not paired',
              ),
        );
        final cubit = ContributionHistoryCubit(
          repository: repository,
          jarId: 'jar-1',
        );
        addTearDown(cubit.close);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(<Matcher>[
            isA<ContributionHistoryLoading>(),
            isA<ContributionHistoryUnpaired>(),
          ]),
        );

        await cubit.loadFirstPage();
        await expectation;
      },
    );

    test('emits failed for any other repository failure', () async {
      final failure = Exception('boom');
      final repository = _FakeDreamJarRepository(
        ({required limit, required offset}) =>
            Future<List<Contribution>>.error(failure),
      );
      final cubit = ContributionHistoryCubit(
        repository: repository,
        jarId: 'jar-1',
      );
      addTearDown(cubit.close);

      await cubit.loadFirstPage();

      expect((cubit.state as ContributionHistoryFailed).failure, same(failure));
    });
  });

  group('ContributionHistoryCubit.loadMore', () {
    test('appends the next page and forwards its own offset', () async {
      final repository = _FakeDreamJarRepository(
        ({required limit, required offset}) async =>
            offset == 0 ? _page(20) : _page(5, startIndex: 20),
      );
      final cubit = ContributionHistoryCubit(
        repository: repository,
        jarId: 'jar-1',
      );
      addTearDown(cubit.close);
      await cubit.loadFirstPage();

      await cubit.loadMore();

      final loaded = cubit.state as ContributionHistoryLoaded;
      expect(loaded.contributions, hasLength(25));
      expect(loaded.hasMore, isFalse);
      expect(repository.calls.last, (limit: 20, offset: 20));
    });

    test('is ignored when the current page has no further pages', () async {
      final repository = _FakeDreamJarRepository(
        ({required limit, required offset}) async => _page(3),
      );
      final cubit = ContributionHistoryCubit(
        repository: repository,
        jarId: 'jar-1',
      );
      addTearDown(cubit.close);
      await cubit.loadFirstPage();

      await cubit.loadMore();

      expect(repository.calls, hasLength(1));
    });

    test('ignores a second call while the first page fetch is in flight', () async {
      var callCount = 0;
      final repository = _FakeDreamJarRepository(
        ({required limit, required offset}) async {
          callCount++;
          if (offset == 0) return _page(20);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return _page(5, startIndex: 20);
        },
      );
      final cubit = ContributionHistoryCubit(
        repository: repository,
        jarId: 'jar-1',
      );
      addTearDown(cubit.close);
      await cubit.loadFirstPage();

      final first = cubit.loadMore();
      final second = cubit.loadMore();
      await first;
      await second;

      expect(callCount, 2);
    });

    test(
      'records loadMoreFailed without dropping already-loaded contributions',
      () async {
        final failure = Exception('network down');
        final repository = _FakeDreamJarRepository(
          ({required limit, required offset}) async {
            if (offset == 0) return _page(20);
            throw failure;
          },
        );
        final cubit = ContributionHistoryCubit(
          repository: repository,
          jarId: 'jar-1',
        );
        addTearDown(cubit.close);
        await cubit.loadFirstPage();

        await cubit.loadMore();

        final loaded = cubit.state as ContributionHistoryLoaded;
        expect(loaded.contributions, hasLength(20));
        expect(loaded.loadMoreFailed, isTrue);
        expect(loaded.isLoadingMore, isFalse);
      },
    );
  });

  group('PartnerSplitTotals.of', () {
    test('sums contributions matching currentUserId into selfTotal', () {
      final totals = PartnerSplitTotals.of(<Contribution>[
        _contribution(userId: 'me', amount: 100000),
        _contribution(userId: 'me', amount: 50000),
        _contribution(userId: 'partner', amount: 30000),
      ], 'me');

      expect(totals.selfTotal, 150000);
      expect(totals.partnerTotal, 30000);
    });

    test('attributes every contribution to the partner when currentUserId is null', () {
      final totals = PartnerSplitTotals.of(<Contribution>[
        _contribution(userId: 'me', amount: 100000),
        _contribution(userId: 'partner', amount: 30000),
      ], null);

      expect(totals.selfTotal, 0);
      expect(totals.partnerTotal, 130000);
    });

    test('returns zero totals for an empty contribution list', () {
      final totals = PartnerSplitTotals.of(<Contribution>[], 'me');

      expect(totals.selfTotal, 0);
      expect(totals.partnerTotal, 0);
    });
  });
}
