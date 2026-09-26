import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chapter_closure/data/chapter_closure_service.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_wipe_service.dart';
import 'package:cupid_mobile/features/chapter_closure/presentation/widgets/closed_archive_actions.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phrases `ux/uiux-spec.md` §2 forbids in the closing surfaces: consolation,
/// congratulation, a comment on the decision, a nudge to reach out again
/// (AC-4, AC-17, BR-9).
const List<String> _forbidden = <String>[
  'tiếc quá',
  'buồn',
  'nhớ',
  'chúc mừng',
  'tuyệt vời',
  'giỏi lắm',
  'chắc chắn không đổi ý',
  'vì sao',
  'lý do',
];

/// `implements` rather than `extends`: both real services need a database, and
/// this file only measures how many times the pane asked for a write.
class _RecordingClosureService implements ChapterClosureService {
  int closeCalls = 0;
  int reopenCalls = 0;

  @override
  Future<String> close() async {
    closeCalls++;
    return 'closure-$closeCalls';
  }

  @override
  Future<void> reopen() async => reopenCalls++;
}

class _RecordingWipeService implements Stage1WipeService {
  int purgeClosedCalls = 0;
  int wipeAllCalls = 0;

  @override
  Future<void> purgeClosed() async => purgeClosedCalls++;

  @override
  Future<void> wipeAll() async => wipeAllCalls++;
}

class _Harness {
  _Harness();

  final _RecordingClosureService closure = _RecordingClosureService();
  final _RecordingWipeService wipe = _RecordingWipeService();
  int reloads = 0;
}

Widget _host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
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

Future<_Harness> _pump(WidgetTester tester) async {
  final _Harness harness = _Harness();
  await tester.pumpWidget(
    _host(
      ClosedArchiveActions(
        closureService: harness.closure,
        wipeService: harness.wipe,
        onChanged: () async => harness.reloads++,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

List<String> _stringsIn(WidgetTester tester, Finder scope) => tester
    .widgetList<Text>(find.descendant(of: scope, matching: find.byType(Text)))
    .map((Text text) => text.data ?? '')
    .toList(growable: false);

void main() {
  testWidgets('the pane offers exactly two actions', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    expect(find.byKey(const Key('closed_archive_actions')), findsOneWidget);
    expect(find.byKey(const Key('closed_archive_reopen')), findsOneWidget);
    expect(find.byKey(const Key('closed_archive_purge')), findsOneWidget);
    expect(find.text('Mở lại ngăn'), findsOneWidget);
    expect(find.text('Xoá hẳn'), findsOneWidget);

    // Nothing opens on its own: both writes are behind a confirmation (AC-2).
    expect(find.byKey(const Key('reopen_chapter_dialog')), findsNothing);
    expect(find.byKey(const Key('purge_closed_dialog')), findsNothing);
  });

  testWidgets('one confirmation reopens the chapter exactly once (AC-17)', (
    WidgetTester tester,
  ) async {
    final _Harness harness = await _pump(tester);

    await tester.tap(find.byKey(const Key('closed_archive_reopen')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reopen_chapter_dialog')), findsOneWidget);
    for (int i = 0; i < reopenChapterFacts.length; i++) {
      expect(find.byKey(Key('closed_archive_fact_$i')), findsOneWidget);
      expect(find.text(reopenChapterFacts[i].first), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('closed_archive_confirm')));
    await tester.pumpAndSettle();

    // No second prompt, no survey, no consolation screen (AC-2).
    expect(find.byKey(const Key('reopen_chapter_dialog')), findsNothing);
    expect(harness.closure.reopenCalls, 1);
    expect(harness.closure.closeCalls, 0);
    expect(harness.wipe.purgeClosedCalls, 0);
    expect(harness.reloads, 1);
  });

  testWidgets('one confirmation purges the closed material exactly once '
      '(AC-15)', (WidgetTester tester) async {
    final _Harness harness = await _pump(tester);

    await tester.tap(find.byKey(const Key('closed_archive_purge')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('purge_closed_dialog')), findsOneWidget);
    for (int i = 0; i < purgeClosedFacts.length; i++) {
      expect(find.byKey(Key('closed_archive_fact_$i')), findsOneWidget);
      expect(find.text(purgeClosedFacts[i].first), findsOneWidget);
    }
    // The irreversibility is stated, not implied.
    expect(find.text('Không hoàn tác được.'), findsOneWidget);
    // And so is the boundary: what the user kept is out of scope (BR-6).
    expect(find.text('Những gì bạn giữ lại không bị đụng tới.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('closed_archive_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purge_closed_dialog')), findsNothing);
    expect(harness.wipe.purgeClosedCalls, 1);
    // Never the whole store: `wipeAll()` is a different decision (AC-15).
    expect(harness.wipe.wipeAllCalls, 0);
    expect(harness.closure.reopenCalls, 0);
    expect(harness.reloads, 1);
  });

  testWidgets('cancelling writes nothing, on either action (BR-9)', (
    WidgetTester tester,
  ) async {
    final _Harness harness = await _pump(tester);

    for (final Key opener in <Key>[
      const Key('closed_archive_reopen'),
      const Key('closed_archive_purge'),
    ]) {
      await tester.tap(find.byKey(opener));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('closed_archive_cancel')));
      await tester.pumpAndSettle();
    }

    expect(harness.closure.reopenCalls, 0);
    expect(harness.wipe.purgeClosedCalls, 0);
    expect(harness.wipe.wipeAllCalls, 0);
    expect(harness.reloads, 0);
    // The pane is still standing and still usable (AC-30).
    expect(find.byKey(const Key('closed_archive_actions')), findsOneWidget);
  });

  testWidgets('each dialog offers exactly two equal choices', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    for (final MapEntry<Key, Key> each in <Key, Key>{
      const Key('closed_archive_reopen'): const Key('reopen_chapter_dialog'),
      const Key('closed_archive_purge'): const Key('purge_closed_dialog'),
    }.entries) {
      await tester.tap(find.byKey(each.key));
      await tester.pumpAndSettle();

      final Finder dialog = find.byKey(each.value);
      expect(
        find.descendant(
          of: dialog,
          matching: find.byKey(const Key('closed_archive_cancel')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.byKey(const Key('closed_archive_confirm')),
        ),
        findsOneWidget,
      );
      // One question only — the title — so no second decision slips in.
      expect(
        _stringsIn(tester, dialog).where((String s) => s.contains('?')).length,
        1,
      );
      // No free-text field, no emotion label, no reason picker (AC-5).
      expect(find.descendant(of: dialog, matching: find.byType(TextField)),
          findsNothing);
      expect(find.descendant(of: dialog, matching: find.byType(EditableText)),
          findsNothing);

      await tester.tap(find.byKey(const Key('closed_archive_cancel')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('no congratulation, no consolation, no comment on the decision '
      '(AC-17)', (WidgetTester tester) async {
    final _Harness harness = await _pump(tester);

    await tester.tap(find.byKey(const Key('closed_archive_reopen')));
    await tester.pumpAndSettle();
    final List<String> dialogStrings =
        _stringsIn(tester, find.byKey(const Key('reopen_chapter_dialog')));
    await tester.tap(find.byKey(const Key('closed_archive_confirm')));
    await tester.pumpAndSettle();

    // Reopening reports in the archive itself changing, never in words.
    expect(find.byType(SnackBar), findsNothing);
    expect(harness.closure.reopenCalls, 1);

    final List<String> onScreen = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text text) => (text.data ?? '').toLowerCase())
        .toList(growable: false);
    for (final String word in _forbidden) {
      for (final String line in <String>[
        ...dialogStrings.map((String s) => s.toLowerCase()),
        ...onScreen,
      ]) {
        expect(
          line.contains(word),
          isFalse,
          reason: '"$word" is not something this surface may say',
        );
      }
    }
  });
}
