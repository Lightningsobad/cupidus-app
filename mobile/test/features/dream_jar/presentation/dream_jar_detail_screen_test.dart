import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/contribution_history_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_unpaired_notice.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/partner_split_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `dream_jar_detail_cubit_test.dart`'s fake — kept local to this
/// file rather than shared, matching this repo's existing per-file fake
/// convention (`test/features/auth/presentation/*_test.dart`).
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository({required this._fetchJar, this._addContribution})
    : super(CupidApiClient.create());

  final Future<DreamJar> Function() _fetchJar;
  final Future<Contribution> Function({
    required String jarId,
    required num amount,
  })?
  _addContribution;

  int addContributionCallCount = 0;

  @override
  Future<DreamJar> fetchJar(String id) => _fetchJar();

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
  }) async => <Contribution>[];
}

DreamJar _jar({num targetAmount = 1000000, num currentAmount = 200000}) =>
    DreamJar(
      id: 'jar-1',
      name: 'Trip to Da Lat',
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: null,
      currency: 'VND',
      status: DreamJarStatus.active,
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

Widget _harness(DreamJarRepository repository) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: DreamJarDetailScreen(jarId: 'jar-1', repository: repository),
  );
}

void main() {
  testWidgets('shows the hero card with jar name and progress once loaded', (
    tester,
  ) async {
    final repository = _FakeDreamJarRepository(fetchJar: () async => _jar());

    await tester.pumpWidget(_harness(repository));
    await tester.pump();
    await tester.pump();

    expect(find.text('Trip to Da Lat'), findsOneWidget);
    expect(find.textContaining('20%'), findsOneWidget);
    expect(find.text('+100k'), findsOneWidget);
    expect(find.text('+200k'), findsOneWidget);
    expect(find.text('+500k'), findsOneWidget);
  });

  testWidgets('shows the unpaired notice when the fetch is unpaired (AC3)', (
    tester,
  ) async {
    final repository = _FakeDreamJarRepository(
      fetchJar: () async =>
          throw const DreamJarUnpairedFailure('User not found or not paired'),
    );

    await tester.pumpWidget(_harness(repository));
    await tester.pump();
    await tester.pump();

    expect(find.byType(DreamJarUnpairedNotice), findsOneWidget);
    expect(find.text('Pair up to see your Dream Jar'), findsOneWidget);
  });

  testWidgets(
    'quick-add tiles ignore a second tap while a contribution is in flight',
    (tester) async {
      final completer = Completer<Contribution>();
      final repository = _FakeDreamJarRepository(
        fetchJar: () async => _jar(),
        addContribution: ({required jarId, required amount}) =>
            completer.future,
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('+100k'));
      await tester.pump();
      await tester.tap(find.text('+100k'));
      await tester.pump();

      expect(repository.addContributionCallCount, 1);

      completer.complete(_contribution());
      await tester.pumpAndSettle();

      expect(repository.addContributionCallCount, 1);
    },
  );

  testWidgets(
    'tapping "See all contributions" pushes ContributionHistoryScreen',
    (tester) async {
      final repository = _FakeDreamJarRepository(fetchJar: () async => _jar());

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Contribution history'));
      await tester.pumpAndSettle();

      expect(find.byType(ContributionHistoryScreen), findsOneWidget);
      expect(find.byType(PartnerSplitCard), findsOneWidget);
    },
  );
}
