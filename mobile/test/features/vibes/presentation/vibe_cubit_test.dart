import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/vibes/data/vibes_repository.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_entry.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_mood.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_cubit.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A configurable test double. `VibesRepository` has no interface (the
/// concrete class is the shared contract per `architecture/solution.md`
/// §4), so this subclasses it and overrides every method, matching the
/// fake-gateway precedent in `sign_out_cubit_test.dart`. No `bloc_test` or
/// mocking package is used or added: neither is a `pubspec.yaml` dependency,
/// and this phase's write scope does not include `pubspec.yaml`
/// (`architecture/solution.md` §3/§6: no new dependency). The wrapped
/// `CupidApi` is never exercised.
class _FakeVibesRepository extends VibesRepository {
  _FakeVibesRepository() : super(CupidApi(dio: Dio(), interceptors: const []));

  Future<VibeEntry?> Function() todayLoader = () async => null;
  Future<List<VibeEntry>> Function() historyLoader = () async => const [];
  Future<List<VibeEntry>> Function() partnerLoader = () async => const [];
  Future<void> Function(VibeMood mood) submitAction = (_) async {};

  @override
  Future<VibeEntry?> fetchMyToday() => todayLoader();

  @override
  Future<List<VibeEntry>> fetchMyHistory() => historyLoader();

  @override
  Future<List<VibeEntry>> fetchPartnerHistory() => partnerLoader();

  @override
  Future<void> submitMood(VibeMood mood) => submitAction(mood);
}

void main() {
  group('VibeCubit.load', () {
    test('emits loading, then populates myToday/myWeek/partnerWeek', () async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      final repository = _FakeVibesRepository();
      final today = VibeEntry(id: 't1', mood: VibeMood.happy, createdAt: todayDate);
      repository.todayLoader = () async => today;
      repository.historyLoader = () async => [
        VibeEntry(id: 'h1', mood: VibeMood.sad, createdAt: yesterdayDate),
      ];
      repository.partnerLoader = () async => [
        VibeEntry(id: 'p1', mood: VibeMood.tired, createdAt: todayDate),
      ];

      final cubit = VibeCubit(repository: repository);
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[
          predicate<VibeState>((s) => s.loading),
          predicate<VibeState>((s) {
            expect(s.loading, isFalse);
            expect(s.myToday, same(today));
            expect(s.myWeek, hasLength(7));
            expect(s.myWeek[5], VibeMood.sad); // yesterday's bucket slot
            expect(s.partnerWeek.last, VibeMood.tired);
            expect(s.partnerToday, VibeMood.tired);
            expect(s.failure, isNull);
            return true;
          }),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('records the failure and clears loading on error', () async {
      final repository = _FakeVibesRepository();
      const failure = NetworkUnavailableFailure();
      repository.todayLoader = () => Future<VibeEntry?>.error(failure);

      final cubit = VibeCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.failure, same(failure));
      expect(cubit.state.myToday, isNull);
    });
  });

  group('VibeCubit.refresh', () {
    test('does not toggle loading', () async {
      final repository = _FakeVibesRepository();
      repository.todayLoader = () async => null;

      final cubit = VibeCubit(repository: repository);
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emits(predicate<VibeState>((s) => !s.loading)),
      );

      await cubit.refresh();
      await expectation;
    });
  });

  group('VibeCubit.pick', () {
    test(
      'optimistically highlights the tapped mood while submitting, then confirms after refetch',
      () async {
        final repository = _FakeVibesRepository();
        final submitCompleter = Completer<void>();
        repository.submitAction = (_) => submitCompleter.future;
        final confirmedToday = VibeEntry(
          id: 'server-1',
          mood: VibeMood.happy,
          createdAt: DateTime(2026, 7, 30),
        );
        repository.todayLoader = () async => confirmedToday;

        final cubit = VibeCubit(repository: repository);
        addTearDown(cubit.close);

        final pickFuture = cubit.pick(VibeMood.happy);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.submitting, isTrue);
        expect(cubit.state.selectedMood, VibeMood.happy);

        submitCompleter.complete();
        await pickFuture;

        expect(cubit.state.submitting, isFalse);
        expect(cubit.state.optimisticMood, isNull);
        expect(cubit.state.myToday, same(confirmedToday));
        expect(cubit.state.selectedMood, VibeMood.happy);
      },
    );

    test(
      'reverts the optimistic overlay (not myToday) and records the failure when submit fails',
      () async {
        final repository = _FakeVibesRepository();
        final previousToday = VibeEntry(
          id: 'prev',
          mood: VibeMood.sad,
          createdAt: DateTime(2026, 7, 29),
        );
        repository.todayLoader = () async => previousToday;

        final cubit = VibeCubit(repository: repository);
        addTearDown(cubit.close);
        await cubit.load();
        expect(cubit.state.myToday, same(previousToday));

        const failure = UnexpectedFailure();
        repository.submitAction = (_) => Future<void>.error(failure);

        await cubit.pick(VibeMood.angry);

        expect(cubit.state.submitting, isFalse);
        expect(cubit.state.optimisticMood, isNull);
        expect(cubit.state.myToday, same(previousToday));
        expect(cubit.state.selectedMood, VibeMood.sad);
        expect(cubit.state.failure, same(failure));
      },
    );

    test('ignores a second pick while one is already in flight', () async {
      final repository = _FakeVibesRepository();
      var submitCallCount = 0;
      final submitCompleter = Completer<void>();
      repository.submitAction = (_) {
        submitCallCount++;
        return submitCompleter.future;
      };
      repository.todayLoader = () async => null;

      final cubit = VibeCubit(repository: repository);
      addTearDown(cubit.close);

      final first = cubit.pick(VibeMood.happy);
      await Future<void>.delayed(Duration.zero);
      final second = cubit.pick(VibeMood.sad);

      expect(submitCallCount, 1);
      expect(cubit.state.selectedMood, VibeMood.happy);
      expect(cubit.state.submitting, isTrue);

      submitCompleter.complete();
      await first;
      await second;

      expect(submitCallCount, 1);
    });

    test('an empty partner history yields partnerToday null with no failure', () async {
      final repository = _FakeVibesRepository();
      repository.todayLoader = () async => null;
      repository.partnerLoader = () async => const [];

      final cubit = VibeCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.partnerToday, isNull);
      expect(cubit.state.failure, isNull);
    });
  });
}
