import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_cubit.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_state.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/bun_sprite.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_action_row.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_reactions_card.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_stats_row.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_xp_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_pet_repository.dart';

/// A synchronous, manually-driven ticker double (mirrors `pet_cubit_test.dart`'s
/// `_ManualTicker`), so this widget test never leaves a real periodic `Timer`
/// pending when the widget tree is disposed at teardown.
class _ManualTicker {
  final _controller = StreamController<void>.broadcast(sync: true);

  Stream<void> call(Duration interval) => _controller.stream;

  Future<void> dispose() => _controller.close();
}

Widget _harness(Widget child, {Locale? locale}) {
  return MediaQuery(
    // These widgets don't animate on their own; disabling motion only
    // matters transitively through the BunSprite children of
    // PetReactionsCard (mirrors bun_sprite_test.dart / pet_screen_test.dart).
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            if (locale == null) return child;
            // `PetLocaleText.viEn` only reads `Localizations.localeOf`; it
            // doesn't need translated MaterialLocalizations/
            // CupertinoLocalizations, so override just the ambient Locale
            // rather than asking MaterialApp to resolve a full 'vi' delegate
            // set it doesn't ship (mirrors the app having no
            // `flutter_localizations` dependency).
            return Localizations.override(
              context: context,
              locale: locale,
              child: child,
            );
          },
        ),
      ),
    ),
  );
}

PetStatus _status({
  int totalInteractions = 10,
  int nextMilestone = 50,
  DateTime? lastInteraction,
  PetMood mood = PetMood.happy,
}) {
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
    mood: mood,
    decayedHappiness: 70,
    milestone: null,
    nextMilestone: nextMilestone,
  );
}

void main() {
  group('PetXpCard', () {
    testWidgets(
      'progress value equals (totalInteractions % 50) / 50 for 63',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(PetXpCard(status: _status(totalInteractions: 63))),
        );
        await tester.pumpAndSettle();

        final LinearProgressIndicator indicator = tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            );
        expect(indicator.value, closeTo(0.26, 0.0001));
      },
    );
  });

  group('PetStatsRow', () {
    testWidgets('renders exactly two tiles with no streak/badge copy (en)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          PetStatsRow(
            status: _status(totalInteractions: 63, nextMilestone: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(PetStatsRow),
          matching: find.byType(Expanded),
        ),
        findsNWidgets(2),
      );
      expect(find.text('63'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('63/100'), findsOneWidget);
      expect(find.text('Interactions'), findsOneWidget);
      expect(find.text('Next milestone'), findsOneWidget);
      for (final String forbidden in <String>['streak', 'badge']) {
        expect(find.textContaining(forbidden), findsNothing);
      }
    });

    testWidgets('renders localized vi copy with no streak/badge copy', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          PetStatsRow(
            status: _status(totalInteractions: 63, nextMilestone: 100),
          ),
          locale: const Locale('vi'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tương tác'), findsOneWidget);
      expect(find.text('Mốc tiếp theo'), findsOneWidget);
      for (final String forbidden in <String>[
        'streak',
        'badge',
        'chuỗi',
        'huy hiệu',
      ]) {
        expect(find.textContaining(forbidden), findsNothing);
      }
    });
  });

  group('PetReactionsCard', () {
    testWidgets('renders three sprites with no hour/day threshold text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_harness(const PetReactionsCard()));
      await tester.pumpAndSettle();

      expect(find.byType(BunSprite), findsNWidgets(3));
      final List<BunSpriteState> states = tester
          .widgetList<BunSprite>(find.byType(BunSprite))
          .map((BunSprite sprite) => sprite.state)
          .toList();
      expect(states, <BunSpriteState>[
        BunSpriteState.happy,
        BunSpriteState.sulk,
        BunSpriteState.sick,
      ]);
      expect(find.text('Bơ một chút'), findsOneWidget);
      expect(find.text('Bơ lâu ghê'), findsOneWidget);
      for (final String forbidden in <String>[
        'giờ',
        'ngày',
        '24h',
        '48h',
        'hour',
        'day',
      ]) {
        expect(find.textContaining(forbidden), findsNothing);
      }
    });
  });

  group('PetActionRow', () {
    testWidgets('both buttons invoke the same PetCubit.interact()', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(lastInteraction: null);
      final cubit = PetCubit(repository: repository, now: () => DateTime(2026));
      addTearDown(cubit.close);
      await cubit.load();

      await tester.pumpWidget(
        _harness(
          BlocProvider<PetCubit>.value(
            value: cubit,
            child: const PetActionRow(cooldownRemaining: null),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Feed'));
      await tester.pumpAndSettle();
      expect(repository.interactCalls, 1);

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      expect(repository.interactCalls, 2);
    });

    testWidgets(
      'disables both buttons and suppresses taps during cooldown',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = _status(
            lastInteraction: DateTime(2026, 1, 1, 0, 0, 0),
          );
        final ticker = _ManualTicker();
        addTearDown(ticker.dispose);
        final cubit = PetCubit(
          repository: repository,
          now: () => DateTime(2026, 1, 1, 0, 0, 2),
          ticker: ticker.call,
        );
        addTearDown(cubit.close);
        await cubit.load();
        final PetReady ready = cubit.state as PetReady;
        expect(ready.cooldownRemaining, isNotNull);
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _harness(
            BlocProvider<PetCubit>.value(
              value: cubit,
              child: PetActionRow(cooldownRemaining: ready.cooldownRemaining),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Feed'), warnIfMissed: false);
        await tester.tap(find.text('Play'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(repository.interactCalls, 0);

        final SemanticsNode feedNode = tester.getSemantics(find.text('Feed'));
        final SemanticsNode playNode = tester.getSemantics(find.text('Play'));
        expect(feedNode.flagsCollection.isEnabled, Tristate.isFalse);
        expect(playNode.flagsCollection.isEnabled, Tristate.isFalse);
        final Finder liveRegionText = find.text('Please wait a moment');
        expect(liveRegionText, findsOneWidget);
        expect(
          tester.getSemantics(liveRegionText).flagsCollection.isLiveRegion,
          isTrue,
        );

        handle.dispose();
      },
    );

    testWidgets(
      'exposes distinct semantics labels for Feed and Play',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _harness(const PetActionRow(cooldownRemaining: null)),
        );
        await tester.pumpAndSettle();

        final SemanticsNode feedNode = tester.getSemantics(find.text('Feed'));
        final SemanticsNode playNode = tester.getSemantics(find.text('Play'));
        expect(feedNode.label, contains('Feed Bun'));
        expect(playNode.label, contains('Play with Bun'));

        handle.dispose();
      },
    );

    testWidgets('both buttons satisfy the minimum tap target size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(const PetActionRow(cooldownRemaining: null)),
      );
      await tester.pumpAndSettle();

      final double expectedTapTarget =
          const CupidPlatformTokens.material().tapTarget;
      final Finder feedGestureDetector = find.ancestor(
        of: find.text('Feed'),
        matching: find.byType(GestureDetector),
      );
      final Finder playGestureDetector = find.ancestor(
        of: find.text('Play'),
        matching: find.byType(GestureDetector),
      );
      expect(
        tester.getSize(feedGestureDetector).height,
        greaterThanOrEqualTo(expectedTapTarget),
      );
      expect(
        tester.getSize(playGestureDetector).height,
        greaterThanOrEqualTo(expectedTapTarget),
      );
    });
  });
}
