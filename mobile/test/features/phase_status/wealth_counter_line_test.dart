import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:cupid_mobile/features/phase_status/presentation/wealth_counter_line.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The day every test in this file reads as "today".
final DateTime _today = DateTime(2026, 9, 16);

/// Widget tests ship no asset bundle, so the shipped packs are read off disk.
/// The sentences asserted below are therefore the ones an author actually
/// shipped, not fixtures transcribed into this file (AC-37/BR-15).
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

PhaseContentRepository _content() =>
    PhaseContentRepository(bundle: _DiskBundle());

/// A store whose contents can change between two reads, which is the only way
/// to exercise "đọc lại khi resume" without a stream the repository does not
/// have (and must not grow — BR-12).
class _MutableRepository implements ActivityCardRepository {
  _MutableRepository(this.cards);

  List<ActivityCard> cards;

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async =>
      cards
          .where((ActivityCard card) => card.status == status)
          .skip(offset)
          .take(limit)
          .toList(growable: false);

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    yield await cardsByStatus(status: status, limit: limit, offset: offset);
  }

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    final Map<ActivityCardStatus, int> counts = <ActivityCardStatus, int>{};
    for (final ActivityCard card in cards) {
      counts[card.status] = (counts[card.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<ActivityCard?> cardById(String id) async =>
      cards.cast<ActivityCard?>().firstWhere(
            (ActivityCard? card) => card?.id == id,
            orElse: () => null,
          );

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async =>
      throw UnimplementedError();

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;
}

ActivityCard _card({
  required String id,
  required ActivityCardStatus status,
}) {
  final DateTime stamp = DateTime(2026, 9, 7);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

/// [count] kept memories plus one open idea, so the hub is past minute-one and
/// standing in the quiet phase in every test below.
List<ActivityCard> _store(int count) => <ActivityCard>[
      _card(id: 'idea-1', status: ActivityCardStatus.idea),
      for (int i = 0; i < count; i++)
        _card(id: 'memory-$i', status: ActivityCardStatus.memory),
    ];

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
        child: child,
      ),
    );

Widget _hub(_MutableRepository repository, {DateTime? today}) => _host(
      ActivityCardHubView(
        repository: repository,
        phaseContent: _content(),
        phaseStatusPrefs: PhaseStatusPrefs(),
        today: today ?? _today,
      ),
    );

Future<String> _nudgeCopy(NudgeSlot slot, int value) async {
  final PhaseContentCatalogue catalogue = await _content().catalogue();
  final NudgeItem item = catalogue.nudges.items.firstWhere(
    (NudgeItem item) => item.slot == slot,
  );
  return item.body.replaceAll(phaseContentNumberPlaceholder, '$value');
}

String _counterText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(wealthCounterLineKey)).data!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('the counter reports the kept set and nothing else', () {
    testWidgets('it shows the number of memory cards (AC-24/AC-25)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(3))));
      await tester.pumpAndSettle();

      expect(_counterText(tester), await _nudgeCopy(NudgeSlot.counter, 3));
    });

    testWidgets('it rises on resume when a memory was added (AC-24)',
        (WidgetTester tester) async {
      final _MutableRepository repository = _MutableRepository(_store(3));
      await tester.pumpWidget(_hub(repository));
      await tester.pumpAndSettle();
      expect(_counterText(tester), await _nudgeCopy(NudgeSlot.counter, 3));

      repository.cards = _store(4);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(_counterText(tester), await _nudgeCopy(NudgeSlot.counter, 4));
    });

    testWidgets('it falls when a card is deleted, with no warning (AC-29)',
        (WidgetTester tester) async {
      final _MutableRepository repository = _MutableRepository(_store(3));
      await tester.pumpWidget(_hub(repository));
      await tester.pumpAndSettle();

      repository.cards = _store(2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(_counterText(tester), await _nudgeCopy(NudgeSlot.counter, 2));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('the same store 60 days later reads the same (BR-5/AC-26)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(3))));
      await tester.pumpAndSettle();
      final String first = _counterText(tester);

      await tester.pumpWidget(
        _hub(
          _MutableRepository(_store(3)),
          today: _today.add(const Duration(days: 60)),
        ),
      );
      await tester.pumpAndSettle();

      expect(_counterText(tester), first);
    });

    testWidgets('a kept set of zero still reads as a fact (BR-6)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(0))));
      await tester.pumpAndSettle();

      expect(_counterText(tester), await _nudgeCopy(NudgeSlot.counter, 0));
    });
  });

  group('the milestone stops at recognising', () {
    testWidgets('crossing a threshold shows one caption (AC-28)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(5))));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(wealthCounterMilestoneKey)).data,
        await _nudgeCopy(NudgeSlot.milestone, 5),
      );
    });

    testWidgets('the caption carries no action of any kind (AC-28/BR-8)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(5))));
      await tester.pumpAndSettle();

      final Finder caption = find.byKey(wealthCounterMilestoneKey);
      expect(caption, findsOneWidget);
      expect(
        find.ancestor(of: caption, matching: find.byType(ButtonStyleButton)),
        findsNothing,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('it does not come back on the next open (AC-28)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(5))));
      await tester.pumpAndSettle();
      expect(find.byKey(wealthCounterMilestoneKey), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_hub(_MutableRepository(_store(5))));
      await tester.pumpAndSettle();

      expect(find.byKey(wealthCounterMilestoneKey), findsNothing);
    });

    testWidgets('below the first threshold there is no caption at all',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(3))));
      await tester.pumpAndSettle();

      expect(find.byKey(wealthCounterMilestoneKey), findsNothing);
    });
  });

  group('no engagement mechanic reaches screen (1)', () {
    testWidgets('nothing rendered carries a percentage, a streak, or a run of '
        'days (BR-5/BR-7)', (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(5))));
      await tester.pumpAndSettle();

      for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
        final String? body = text.data;
        if (body == null) {
          continue;
        }
        final String lower = body.toLowerCase();
        expect(body, isNot(contains('%')));
        expect(lower, isNot(contains('streak')));
        expect(lower, isNot(contains('chuỗi')));
        expect(lower, isNot(contains('liên tiếp')));
        expect(lower, isNot(contains('tuần trước')));
        expect(
          RegExp(r'\d+\s*ngày\s*(liên|liền)').hasMatch(lower),
          isFalse,
          reason: 'a run of days is a streak under another name (BR-5)',
        );
      }
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('the counter carries no target beside it (AC-27/BR-7)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_MutableRepository(_store(3))));
      await tester.pumpAndSettle();

      final String body = _counterText(tester);
      expect(body, isNot(contains('/')));
      expect(body, isNot(contains('%')));
    });
  });

  group('the card contract stays read-only', () {
    test('this phase does not touch activity_card_repository.dart (BR-12)',
        () async {
      final ProcessResult diff = await Process.run(
        'git',
        <String>['diff', '--name-only', 'HEAD'],
        workingDirectory: Directory.current.parent.path,
      );

      expect(diff.exitCode, 0, reason: diff.stderr.toString());
      expect(
        (diff.stdout as String).split('\n'),
        isNot(
          contains(
            'mobile/lib/features/activity_cards/domain/'
            'activity_card_repository.dart',
          ),
        ),
      );
    });
  });
}
