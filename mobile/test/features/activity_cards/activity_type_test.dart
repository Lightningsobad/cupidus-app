import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/activity_card_tile.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The vocabulary `assets/data/req016/occasions.v1.json` produces, transcribed
/// once. The package is the only producer, so this list is what the enum is
/// allowed to contain — no more, no fewer.
const List<String> _packageVocabulary = <String>[
  'outing',
  'home',
  'visit',
  'dining',
  'handmade',
  'walk',
  'photo',
  'gift',
];

/// The `ActivityType` -> Material Symbols Rounded glyph map from
/// `coding-plan/phase-P7-activity-type-enum-and-card-icon.md` §3, with the one
/// documented substitution: `gift` uses `redeem`/0xe8b1 because the bundled
/// font's cmap carries no `card_giftcard` entry at all.
const Map<ActivityType, IconData> _expectedIcons = <ActivityType, IconData>{
  ActivityType.outing: CupidIcons.localActivity,
  ActivityType.home: CupidIcons.home,
  ActivityType.visit: CupidIcons.groups,
  ActivityType.dining: CupidIcons.restaurant,
  ActivityType.handmade: CupidIcons.draw,
  ActivityType.walk: CupidIcons.directionsWalk,
  ActivityType.photo: CupidIcons.photoCamera,
  ActivityType.gift: CupidIcons.redeem,
};

ActivityCard _card({
  ActivityType? activityType,
  String? scheduledOn = '2026-09-07',
  double? distanceKm,
  int? priceVnd,
}) {
  final DateTime now = DateTime(2026, 9, 7);
  return ActivityCard(
    id: 'x',
    ownerKey: 'owner-1',
    title: 'Cà phê sách Hào Nam',
    status: ActivityCardStatus.idea,
    origin: ActivityCardOrigin.manual,
    activityType: activityType,
    scheduledOn: scheduledOn,
    distanceKm: distanceKm,
    priceVnd: priceVnd,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: now,
    updatedAt: now,
  );
}

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

Widget _tile(ActivityCard card) => ActivityCardTile(
  card: card,
  replyState: card.replyState,
  onPrimaryAction: () {},
  onToggleReply: () {},
  onOverflowAction: (ActivityCardOverflowAction _) {},
);

void main() {
  group('ActivityType vocabulary', () {
    test('is exactly the 8 members the content package produces', () {
      expect(
        ActivityType.values.map((ActivityType t) => t.wireValue).toList(),
        _packageVocabulary,
      );
    });

    test('every member round-trips through its canonical ASCII name', () {
      for (final ActivityType type in ActivityType.values) {
        expect(activityTypeFromWireValue(type.wireValue), type);
      }
    });

    test('an unrecognized string reads as null instead of throwing', () {
      for (final String? raw in <String?>[
        'chiều',
        '',
        'Outing',
        'tối nay được',
        null,
      ]) {
        expect(activityTypeFromWireValue(raw), isNull, reason: 'raw: $raw');
      }
    });
  });

  group('Drift storage', () {
    late CupidDatabase database;
    late ActivityCardDao dao;

    setUp(() {
      database = CupidDatabase(NativeDatabase.memory());
      dao = database.activityCardDao;
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> insert(String id, Value<ActivityType?> activityType) {
      final DateTime now = DateTime.utc(2026, 9, 7, 10);
      return dao.upsertCard(
        ActivityCardsCompanion.insert(
          id: id,
          ownerKey: 'user-1',
          title: 'Đi ăn lẩu',
          origin: 'manual',
          activityType: activityType,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    test('the vocabulary survives a write/read round trip', () async {
      for (final ActivityType type in ActivityType.values) {
        await insert(type.wireValue, Value<ActivityType?>(type));
        final ActivityCardRow? row = await dao.cardById(
          ownerKey: 'user-1',
          id: type.wireValue,
        );
        expect(row?.activityType, type);
      }
    });

    test('a row holding a pre-vocabulary free-text value still reads, and '
        'reads as null', () async {
      await insert('legacy', const Value<ActivityType?>(null));
      await database.customStatement(
        "UPDATE activity_cards SET activity_type = 'chiều' WHERE id = 'legacy'",
      );

      final ActivityCardRow? row = await dao.cardById(
        ownerKey: 'user-1',
        id: 'legacy',
      );

      expect(row, isNotNull);
      expect(row!.title, 'Đi ăn lẩu');
      expect(row.activityType, isNull);
    });

    test('the column keeps its TEXT NULL storage and the converter introduces '
        'no migration of its own', () async {
      // The version moved 3 -> 4 for ruling B-1's five new columns, 4 -> 5 for
      // `location` + `invite_messages`, 5 -> 6 for the context-notebook tables,
      // 6 -> 7 for `calendar_event_state` + `portrait_answers`, 7 -> 8 for
      // `relationship_labels`, 8 -> 9 for the chapter-closure ledger, and
      // 9 -> 10 for `thank_you_activations`, never for this converter:
      // attaching it to an existing TEXT column emits no DDL.
      expect(database.schemaVersion, 10);
      final GeneratedColumn<Object> column = database.activityCards.$columns
          .firstWhere((GeneratedColumn<Object> c) => c.name == 'activity_type');
      expect(column.type, DriftSqlType.string);
      expect(column.$nullable, isTrue);
    });
  });

  group('Card tile line 2 (D-5)', () {
    for (final MapEntry<ActivityType, IconData> entry
        in _expectedIcons.entries) {
      testWidgets('${entry.key.wireValue} renders its mapped glyph', (
        WidgetTester tester,
      ) async {
        // D-3 moved the scheduled date off line 2, so a date-only card now has
        // no line 2 and therefore no leading glyph. Give the card a distance so
        // line 2 exists and this test still measures the glyph mapping.
        await tester.pumpWidget(
          _host(_tile(_card(activityType: entry.key, distanceKm: 1.8))),
        );

        final Icon icon = tester.widget<Icon>(
          find.byKey(const Key('activity_card_type_icon_x')),
        );
        expect(icon.icon, entry.value);
        expect(icon.semanticLabel, isNotEmpty);
      });
    }

    testWidgets('a null type still gets a leading glyph when line 2 has '
        'content', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(_tile(_card(activityType: null, distanceKm: 1.8))),
      );

      expect(find.byKey(const Key('activity_card_meta_x')), findsOneWidget);
      final Icon icon = tester.widget<Icon>(
        find.byKey(const Key('activity_card_type_icon_x')),
      );
      expect(icon.icon, CupidIcons.label);
    });

    testWidgets('no leading glyph when the card has no line 2 at all', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(_tile(_card(activityType: ActivityType.walk, scheduledOn: null))),
      );

      expect(find.byKey(const Key('activity_card_meta_x')), findsNothing);
      expect(find.byKey(const Key('activity_card_type_icon_x')), findsNothing);
    });

    testWidgets('the activity type is no longer a word on line 2', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _tile(
            _card(
              activityType: ActivityType.dining,
              distanceKm: 1.8,
              priceVnd: 70000,
            ),
          ),
        ),
      );

      final Text meta = tester.widget<Text>(
        find.byKey(const Key('activity_card_meta_x')),
      );
      expect(meta.data, '1.8 km · 70.000đ');
      for (final ActivityType type in ActivityType.values) {
        expect(find.textContaining(type.wireValue), findsNothing);
      }
    });
  });

  group('Card tile delete affordance (D-4)', () {
    testWidgets('no per-card delete dash is rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(_tile(_card(activityType: ActivityType.dining))),
      );

      expect(find.byKey(const Key('activity_card_delete_x')), findsNothing);
      expect(find.byIcon(CupidIcons.remove), findsNothing);
    });

    testWidgets('deleting stays reachable through the "…" overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(_tile(_card(activityType: ActivityType.dining))),
      );

      await tester.tap(find.byKey(const Key('activity_card_overflow_x')));
      await tester.pumpAndSettle();

      expect(find.text('Xoá'), findsOneWidget);
    });
  });
}
