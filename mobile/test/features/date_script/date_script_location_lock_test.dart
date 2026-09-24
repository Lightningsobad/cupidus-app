import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Screen (9) is reachable from exactly one row of exactly one sheet, on
/// exactly one card status, and from nowhere else in the binary
/// (`ux/uiux-spec.md` §1, AC-2/AC-4, BR-1a). This file is the whole of that
/// claim: the two rendered halves, plus the source scan that covers the paths a
/// widget test cannot reach.

const String _entryPointPath =
    'lib/features/date_script/date_script_entry_point.dart';
const String _prepareSheetPath =
    'lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart';
const String _featureDir = 'lib/features/date_script';

const Size _designFrame = Size(415, 900);

class _TestBundle extends AssetBundle {
  _TestBundle(this._sources);

  final Map<String, String> _sources;

  @override
  Future<ByteData> load(String key) async {
    final String? source = _sources[key];
    if (source == null) {
      throw FlutterError('asset not registered in this test bundle: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

String _packJson() => jsonEncode(<String, Object?>{
  'id': 'presets.invite',
  'version': '1.0.0',
  'schema_id': presetsSchemaId,
  'locale': 'vi',
  'items': <Map<String, Object?>>[
    <String, Object?>{
      'id': 'frame.0.v1',
      'frame': 'Rủ nhẹ nhàng',
      'clauses': <Map<String, Object?>>[
        <String, Object?>{
          'text': 'Rảnh không, mình đi {activity} nhé?',
          'requires': <String>['activity'],
          'targets': 'neutral',
        },
        <String, Object?>{
          'text': 'Bận thì cứ nói mình biết nha.',
          'requires': <String>[],
          'targets': 'neutral',
          'role': 'decline_door',
        },
      ],
    },
  ],
});

PresetCatalogue _catalogue() => PresetCatalogue(
  loader: ContentPackageLoader(
    bundle: _TestBundle(<String, String>{
      presetAssetKey(inviteCategoryId): _packJson(),
    }),
  ),
);

ActivityCard _card(ActivityCardStatus status) => ActivityCard(
  id: 'card-1',
  ownerKey: 'owner-1',
  title: 'xem phim Dune',
  status: status,
  origin: ActivityCardOrigin.manual,
  activityType: ActivityType.outing,
  scheduledOn: '2026-09-20',
  timeOfDaySlot: TimeOfDaySlot.evening,
  durationMinutes: 120,
  location: 'rạp CGV Vincom Đồng Khởi',
  invited: status != ActivityCardStatus.idea,
  replyState: ActivityCardReplyState.answered,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

List<File> _libDartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.dart'))
    .toList(growable: false);

List<File> _featureDartFiles() => Directory(_featureDir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.dart'))
    .toList(growable: false);

/// Anything that would let this feature move on its own clock. J7 is left empty
/// on purpose: no reminder, no countdown, no "the date starts now" nudge
/// (AC-13..AC-16, BR-3).
const List<String> _j7Terms = <String>[
  'dart:async',
  'Timer',
  'Ticker',
  'AnimationController',
  'flutter_local_notifications',
  'firebase_messaging',
  'awesome_notifications',
  'showNotification',
  'countdown',
  'scheduleAt',
];

List<String> _j7Hits(String source) => <String>[
  for (final String term in _j7Terms)
    if (source.contains(term)) term,
];

/// Route registration of any shape. A named route, a generated route, a tab bar
/// item or a menu item are four different ways to make screen (9) reachable
/// without a source card, and all four are out (BR-1a).
const List<String> _routeRegistrationTerms = <String>[
  'routes:',
  'onGenerateRoute',
  'pushNamed',
  'RouteSettings',
  'settings:',
  'BottomNavigationBarItem',
  'PopupMenuItem',
  'NavigationDestination',
];

void main() {
  Widget host(Widget child) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: CupidPlatformOverride(platform: CupidPlatform.material, child: child),
  );

  late Future<void> pendingSheet;
  late List<String> openedCardIds;

  Future<void> openSheet(
    WidgetTester tester,
    ActivityCardStatus status,
  ) async {
    tester.view.physicalSize = _designFrame;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    openedCardIds = <String>[];

    late BuildContext hostContext;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (BuildContext context) {
            hostContext = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );

    pendingSheet = showPrepareActionsSheet(
      hostContext,
      _card(status),
      catalogue: _catalogue(),
      openComposer: (BuildContext _, ActivityCard _, String _) async => false,
      openDateScript: (BuildContext _, ActivityCard card) async {
        openedCardIds.add(card.id);
      },
    );
    await tester.pumpAndSettle();
  }

  group('part 1 — the one door that exists', () {
    testWidgets('a scheduled card offers the script row, second in the sheet', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, ActivityCardStatus.scheduled);

      expect(find.byKey(const Key('prepare_actions_sheet')), findsOneWidget);
      expect(find.byKey(const Key('prepare_action_date_script')), findsOneWidget);
      expect(find.text('Kịch bản buổi hẹn'), findsOneWidget);

      // Item #2 of the "Chuẩn bị" area: after "Xuất lời mời"
      // (`ux/uiux-spec.md` §1).
      final Offset invite = tester.getTopLeft(
        find.byKey(const Key('prepare_action_invite')),
      );
      final Offset script = tester.getTopLeft(
        find.byKey(const Key('prepare_action_date_script')),
      );
      expect(script.dy, greaterThan(invite.dy));

      await tester.tap(find.byKey(const Key('prepare_action_date_script')));
      await tester.pumpAndSettle();
      await pendingSheet;

      // The source card is handed over, and the sheet is gone before the screen
      // opens, so backing out lands on the card detail.
      expect(openedCardIds, <String>['card-1']);
      expect(find.byKey(const Key('prepare_actions_sheet')), findsNothing);
    });
  });

  group('part 2 — every other status has no door at all', () {
    for (final ActivityCardStatus status in ActivityCardStatus.values) {
      if (status == ActivityCardStatus.scheduled) {
        continue;
      }
      testWidgets('"${status.name}" shows no script row (AC-2/SC-6)', (
        WidgetTester tester,
      ) async {
        await openSheet(tester, status);

        // The sheet itself still opens — the invite row resolves for any status
        // — so this is a missing row, not a missing sheet.
        expect(find.byKey(const Key('prepare_actions_sheet')), findsOneWidget);
        expect(find.byKey(const Key('prepare_action_invite')), findsOneWidget);
        expect(find.byKey(const Key('prepare_action_date_script')), findsNothing);
        expect(find.text('Kịch bản buổi hẹn'), findsNothing);

        // Not disabled and not explained away either: nothing on the sheet
        // points at screen (9).
        for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
          expect(text.data ?? '', isNot(contains('ịch bản')));
        }
      });
    }

    test('the status scan covered every value there is', () {
      expect(ActivityCardStatus.values.length, greaterThan(1));
      expect(ActivityCardStatus.values, contains(ActivityCardStatus.scheduled));
    });
  });

  group('part 3 — no other door exists anywhere in lib/', () {
    test('the scan finds files to scan', () {
      expect(_libDartFiles(), isNotEmpty);
      expect(_featureDartFiles(), isNotEmpty);
      expect(File(_entryPointPath).existsSync(), isTrue);
      expect(File(_prepareSheetPath).existsSync(), isTrue);
    });

    test('no file that names the date script registers a route for it', () {
      final List<String> offenders = <String>[];
      for (final File file in _libDartFiles()) {
        final String source = file.readAsStringSync();
        if (!source.contains('DateScript') &&
            !source.contains('openDateScriptScreen')) {
          continue;
        }
        for (final String term in _routeRegistrationTerms) {
          if (source.contains(term)) {
            offenders.add('${file.path} uses "$term"');
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('no route-shaped string literal names the date script', () {
      final RegExp literal = RegExp("'([^'\n]*)'");
      final List<String> offenders = <String>[];
      for (final File file in _libDartFiles()) {
        for (final RegExpMatch match in literal.allMatches(
          file.readAsStringSync(),
        )) {
          final String value = match.group(1)!;
          final String lower = value.toLowerCase();
          final bool namesTheScreen =
              (lower.contains('date_script') ||
                  lower.contains('date-script') ||
                  lower.contains('datescript'));
          if (namesTheScreen && (value.startsWith('/') || lower.contains('://'))) {
            offenders.add('${file.path} declares route literal "$value"');
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('openDateScriptScreen is declared once and called from one file only',
        () {
      final List<String> declaring = <String>[];
      final List<String> calling = <String>[];
      for (final File file in _libDartFiles()) {
        final String source = file.readAsStringSync();
        if (!source.contains('openDateScriptScreen')) {
          continue;
        }
        if (file.path == _entryPointPath) {
          declaring.add(file.path);
        } else {
          calling.add(file.path);
        }
      }

      expect(declaring, <String>[_entryPointPath]);
      expect(calling, <String>[_prepareSheetPath]);
    });

    test('the entry point pushes an anonymous route and exports nothing else',
        () {
      final String source = File(_entryPointPath).readAsStringSync();

      expect(source, contains('MaterialPageRoute'));
      expect(source, isNot(contains('settings:')));
      expect(source, isNot(contains('RouteSettings')));
      expect(source, contains('show DateScriptScreen, dateScriptEntryPointId;'));
      expect(
        RegExp('^export ', multiLine: true).allMatches(source),
        hasLength(1),
      );
    });

    test('screen (9) offers no share or copy-link affordance (SC-6)', () {
      final List<String> offenders = <String>[
        for (final File file in _featureDartFiles())
          for (final String term in const <String>[
            'Share.share',
            'share_plus',
            'Clipboard.setData',
            'launchUrl',
            'url_launcher',
          ])
            if (file.readAsStringSync().contains(term)) '${file.path}: $term',
      ];

      expect(offenders, isEmpty);
    });
  });

  group('the J7 boundary is empty (AC-13..AC-16 / BR-3)', () {
    test('nothing under the feature can move on its own clock', () {
      final List<String> offenders = <String>[
        for (final File file in _featureDartFiles())
          for (final String term in _j7Hits(file.readAsStringSync()))
            '${file.path}: $term',
      ];

      expect(offenders, isEmpty);
    });

    test('the J7 scan actually catches a timer', () {
      expect(
        _j7Hits(
          "import 'dart:async';\n"
          'Timer.periodic(const Duration(minutes: 1), (Timer _) {});',
        ),
        containsAll(<String>['dart:async', 'Timer']),
      );
    });

    test('the J7 scan does not fire on the clean feature source', () {
      expect(_j7Hits(File(_entryPointPath).readAsStringSync()), isEmpty);
    });
  });
}
