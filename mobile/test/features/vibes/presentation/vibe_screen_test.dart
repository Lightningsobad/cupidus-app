import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/vibes/data/vibes_repository.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_entry.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_mood.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_cubit.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// A configurable test double (mirrors `vibe_widgets_test.dart`'s
/// `_FakeVibesRepository`, duplicated per-file since it is private): no
/// `bloc_test`/mocking package is added, matching that file's rationale.
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

Widget _materialHarness(Widget home) {
  return MaterialApp(
    theme: buildCupidTheme(platform: CupidPlatform.material, brightness: Brightness.dark),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: home,
  );
}

void main() {
  group('HomeScreen entry point (D-010-5)', () {
    testWidgets(
      'tapping the vibe entry card pushes VibeScreen and the ready signal '
      'remains present beforehand',
      (tester) async {
        final repository = _FakeVibesRepository();
        getIt.registerFactory<VibeCubit>(
          () => VibeCubit(repository: repository),
        );
        addTearDown(() => getIt.unregister<VibeCubit>());

        await tester.pumpWidget(
          _materialHarness(
            // Overrides the default `getIt<CouplePairingStore>()` lookup
            // (mirrors `home_screen_test.dart`): this test only exercises
            // the vibe entry card, so it never registers a
            // `CouplePairingStore` and must not depend on one.
            HomeScreen(resolvePairingStatus: () async => PairingStatus.unknown),
          ),
        );

        expect(
          find.byKey(const Key('home_screen_ready_signal')),
          findsOneWidget,
        );
        expect(find.byType(VibeScreen), findsNothing);

        await tester.tap(find.text('Daily Vibe Check'));
        await tester.pumpAndSettle();

        expect(find.byType(VibeScreen), findsOneWidget);
      },
    );
  });

  group('VibeScreen (phase-P3-vibe-screen-entrypoint.md)', () {
    testWidgets(
      'tapping a mood cell shows the optimistic highlight and locks the grid',
      (tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          final repository = _FakeVibesRepository();
          final submitCompleter = Completer<void>();
          repository.submitAction = (_) => submitCompleter.future;

          await tester.pumpWidget(
            _materialHarness(
              VibeScreen(
                createCubit: () => VibeCubit(repository: repository),
              ),
            ),
          );
          await tester.pump();

          await tester.tap(find.bySemanticsLabel('Happy'));
          await tester.pump();

          final SemanticsNode happyCell = tester.getSemantics(
            find.bySemanticsLabel('Happy'),
          );
          expect(
            happyCell.getSemanticsData().flagsCollection.isSelected,
            Tristate.isTrue,
          );

          final SemanticsNode sadCell = tester.getSemantics(
            find.bySemanticsLabel('Sad'),
          );
          expect(
            sadCell.getSemanticsData().flagsCollection.isEnabled,
            Tristate.isFalse,
          );

          submitCompleter.complete();
          await tester.pumpAndSettle();
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets(
      'a failing submit reverts the highlight and shows exactly one inline '
      'error',
      (tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          final repository = _FakeVibesRepository();
          repository.submitAction = (_) =>
              Future<void>.error(const NetworkUnavailableFailure());

          await tester.pumpWidget(
            _materialHarness(
              VibeScreen(
                createCubit: () => VibeCubit(repository: repository),
              ),
            ),
          );
          await tester.pump();

          await tester.tap(find.bySemanticsLabel('Sad'));
          await tester.pumpAndSettle();

          expect(find.text('No internet connection'), findsOneWidget);

          final SemanticsNode sadCell = tester.getSemantics(
            find.bySemanticsLabel('Sad'),
          );
          expect(
            sadCell.getSemanticsData().flagsCollection.isSelected,
            isNot(Tristate.isTrue),
          );
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets(
      'an empty partner history renders the waiting state with no error',
      (tester) async {
        final repository = _FakeVibesRepository();
        repository.partnerLoader = () async => const [];

        await tester.pumpWidget(
          _materialHarness(
            VibeScreen(
              createCubit: () => VibeCubit(repository: repository),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Waiting…'), findsWidgets);
        expect(find.textContaining('internet connection'), findsNothing);
        expect(find.textContaining('Something went wrong'), findsNothing);
      },
    );

    testWidgets(
      'STORY-020: the chrome title is the screen name and the prompt moves '
      'into the centered hero block',
      (tester) async {
        final repository = _FakeVibesRepository();

        await tester.pumpWidget(
          _materialHarness(
            VibeScreen(createCubit: () => VibeCubit(repository: repository)),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(CupidHeader),
            matching: find.text('Vibe Check'),
          ),
          findsOneWidget,
        );

        final Finder prompt = find.text('How are you today?');
        expect(prompt, findsOneWidget);
        expect(tester.widget<Text>(prompt).style?.fontSize, 27);
        expect(
          find.text('One tap and Bae knows — no typing needed 🎀'),
          findsOneWidget,
        );
      },
    );

    testWidgets('pull-to-refresh re-runs the three reads', (tester) async {
      final repository = _FakeVibesRepository();
      var historyCallCount = 0;
      repository.historyLoader = () async {
        historyCallCount++;
        return const [];
      };

      await tester.pumpWidget(
        _materialHarness(
          VibeScreen(createCubit: () => VibeCubit(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      expect(historyCallCount, 1);

      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(historyCallCount, 2);
    });
  });
}
