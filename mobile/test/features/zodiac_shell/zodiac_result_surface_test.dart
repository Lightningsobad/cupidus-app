import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content_gate.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_resolver.dart';
import 'package:cupid_mobile/features/zodiac_shell/presentation/widgets/zodiac_result_surface.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shipped outcomes, read off disk: these assertions are about the packs an
/// author actually shipped, not about fixture copy that could drift from them.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }

  /// Decoded in-process: above 50 KB the inherited `loadString` hands the
  /// decode to `compute()`, and an isolate never finishes inside the fake async
  /// zone of a widget test.
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());
}

/// Tall enough that every block of the surface is mounted at once. The surface
/// is a `ListView`, so in a short frame an absence assertion could pass by
/// never having built the widget it is looking for.
const Size _tallViewport = Size(415, 4000);

Widget _host(Widget child) => MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: Scaffold(body: child),
      ),
    );

Finder _suggestionCards() => find.byWidgetPredicate((Widget widget) {
      final Key? key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('zodiac_suggestion_card_');
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<ZodiacOutcome> outcomes;

  setUpAll(() async {
    final ContentPackage<ZodiacOutcome> package =
        await ContentPackageLoader(bundle: _DiskBundle()).load<ZodiacOutcome>(
      zodiacOutcomesAssetKey,
      expectedSchemaId: zodiacOutcomesSchemaId,
      itemParser: zodiacOutcomeFromJson,
    );
    outcomes = package.items;
  });

  /// What the resolver hands the surface for an empty notebook: the first
  /// [minimumSuggestionsPerOutcome] of the pool, in pack order.
  ZodiacShellResult resultFor(ZodiacOutcome outcome) => ZodiacShellResult(
        outcome: outcome,
        suggestions: outcome.suggestions
            .take(minimumSuggestionsPerOutcome)
            .toList(growable: false),
      );

  Future<void> pumpOutcome(
    WidgetTester tester,
    ZodiacOutcome outcome, {
    ValueChanged<ZodiacSuggestion>? onAdd,
  }) async {
    tester.view.physicalSize = _tallViewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        ZodiacResultSurface(
          result: resultFor(outcome),
          onAddToCards: onAdd ?? (ZodiacSuggestion _) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('một bề mặt, ba thẻ, không ngoại lệ (AC-4/AC-5/AC-6, BR-2)', () {
    testWidgets('every shipped outcome renders exactly three suggestion cards',
        (WidgetTester tester) async {
      expect(outcomes, isNotEmpty);

      for (final ZodiacOutcome outcome in outcomes) {
        await pumpOutcome(tester, outcome);

        expect(
          _suggestionCards(),
          findsNWidgets(minimumSuggestionsPerOutcome),
          reason: 'outcome "${outcome.id}" did not render three cards',
        );
        expect(
          find.text(outcome.insight),
          findsOneWidget,
          reason: 'outcome "${outcome.id}" lost its insight',
        );
      }
    });

    testWidgets('the verdict and the three cards share one scrollable',
        (WidgetTester tester) async {
      for (final ZodiacOutcome outcome in outcomes) {
        await pumpOutcome(tester, outcome);

        // One Scrollable in the whole tree: there is no second surface, and
        // nothing between the verdict and the cards can be a separate list
        // that scrolls away from it.
        expect(find.byType(Scrollable), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('zodiac_result_surface')),
            matching: find.byKey(const Key('zodiac_result_insight')),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('zodiac_result_surface')),
            matching: _suggestionCards(),
          ),
          findsNWidgets(minimumSuggestionsPerOutcome),
          reason: 'outcome "${outcome.id}" put its cards outside the surface',
        );
      }
    });

    testWidgets('the verdict, the ask block and the subheading come before the '
        'first card', (WidgetTester tester) async {
      final ZodiacOutcome outcome = outcomes.firstWhere(
        (ZodiacOutcome candidate) => candidate.aboutOther,
      );
      await pumpOutcome(tester, outcome);

      double topOf(Finder finder) => tester.getTopLeft(finder).dy;

      final double insight = topOf(find.byKey(const Key('zodiac_result_insight')));
      final double ask = topOf(find.byKey(const Key('zodiac_result_ask_block')));
      final double subheading =
          topOf(find.byKey(const Key('zodiac_result_suggestions_subheading')));
      final double firstCard = topOf(_suggestionCards().first);

      expect(insight, lessThan(ask));
      expect(ask, lessThan(subheading));
      expect(subheading, lessThan(firstCard));
    });

    testWidgets('nothing on the surface can hide a card behind a tap',
        (WidgetTester tester) async {
      for (final ZodiacOutcome outcome in outcomes) {
        await pumpOutcome(tester, outcome);

        expect(find.byType(ExpansionTile), findsNothing);
        expect(find.byType(ExpansionPanelList), findsNothing);
      }
    });
  });

  group('ranh giới đạo đức (AC-13/AC-14/AC-19)', () {
    testWidgets('no percentage, no band, no progress bar, no counter',
        (WidgetTester tester) async {
      for (final ZodiacOutcome outcome in outcomes) {
        await pumpOutcome(tester, outcome);

        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(Slider), findsNothing);

        for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
          expect(
            text.data ?? '',
            isNot(contains('%')),
            reason: 'outcome "${outcome.id}" put a percentage on screen',
          );
        }
      }
    });

    testWidgets('the positioning note keeps the screen out of prophecy '
        '(AC-16/AC-17)', (WidgetTester tester) async {
      await pumpOutcome(tester, outcomes.first);

      expect(
        find.byKey(const Key('zodiac_result_positioning_note')),
        findsOneWidget,
      );
    });
  });

  group('câu để hỏi khi và chỉ khi nói về người kia (AC-12/AC-15)', () {
    testWidgets('an outcome about the other person carries the guess basis and '
        'ends on a question', (WidgetTester tester) async {
      final List<ZodiacOutcome> aboutOther = outcomes
          .where((ZodiacOutcome outcome) => outcome.aboutOther)
          .toList(growable: false);
      expect(
        aboutOther,
        isNotEmpty,
        reason: 'without one of these the assertion below tests nothing',
      );

      for (final ZodiacOutcome outcome in aboutOther) {
        await pumpOutcome(tester, outcome);

        expect(
          find.byKey(const Key('zodiac_result_ask_block')),
          findsOneWidget,
          reason: 'outcome "${outcome.id}" speaks about them with no question',
        );
        expect(find.text(outcome.askLine!), findsOneWidget);
        expect(
          find.byKey(const Key('zodiac_result_guess_basis')),
          findsOneWidget,
        );
      }
    });

    testWidgets('an outcome about the reader carries neither',
        (WidgetTester tester) async {
      final List<ZodiacOutcome> aboutSelf = outcomes
          .where((ZodiacOutcome outcome) => !outcome.aboutOther)
          .toList(growable: false);
      expect(aboutSelf, isNotEmpty);

      for (final ZodiacOutcome outcome in aboutSelf) {
        await pumpOutcome(tester, outcome);

        expect(
          find.byKey(const Key('zodiac_result_ask_block')),
          findsNothing,
          reason: 'outcome "${outcome.id}" drew an ask block it has no line '
              'for',
        );
        expect(
          find.byKey(const Key('zodiac_result_guess_basis')),
          findsNothing,
        );
      }
    });
  });

  group('thêm vào kho của tôi', () {
    testWidgets('each card emits its own suggestion, and more than one card '
        'can be picked', (WidgetTester tester) async {
      final List<ZodiacSuggestion> added = <ZodiacSuggestion>[];
      final ZodiacOutcome outcome = outcomes.first;

      await pumpOutcome(tester, outcome, onAdd: added.add);

      final ZodiacShellResult result = resultFor(outcome);
      for (final ZodiacSuggestion suggestion in result.suggestions) {
        await tester.tap(
          find.byKey(Key('zodiac_suggestion_add_${suggestion.id}')),
        );
        await tester.pumpAndSettle();
      }

      expect(
        <String>[for (final ZodiacSuggestion s in added) s.id],
        <String>[for (final ZodiacSuggestion s in result.suggestions) s.id],
      );
    });

    testWidgets('the action has a readable name even though it draws no text',
        (WidgetTester tester) async {
      final ZodiacOutcome outcome = outcomes.first;
      await pumpOutcome(tester, outcome);

      final BuildContext context = tester.element(
        find.byKey(const Key('zodiac_result_surface')),
      );
      final String label = AppL10n.of(context).zodiac_shell_add_to_my_store_action;

      final int labelled = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((Semantics node) => node.properties.label == label)
          .length;

      expect(labelled, minimumSuggestionsPerOutcome);
    });
  });
}
