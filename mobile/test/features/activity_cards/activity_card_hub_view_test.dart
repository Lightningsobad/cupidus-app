import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/activity_card_list_cubit.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Never issues a real HTTP call: the entry-point test only asserts which
/// branch of Home renders, not Dream Jar's own loading.
class _NoOpDreamJarRepository extends DreamJarRepository {
  _NoOpDreamJarRepository() : super(CupidApiClient.create());

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async =>
      <DreamJar>[];
}

/// In-memory stand-in for the P2 repository. Records every query so the
/// paging and "one pane only" contracts can be asserted on the calls
/// themselves, not just on the rendered output.
class _FakeActivityCardRepository implements ActivityCardRepository {
  _FakeActivityCardRepository([List<ActivityCard> cards = const <ActivityCard>[]])
      : _cards = <ActivityCard>[...cards];

  final List<ActivityCard> _cards;
  final List<String> queries = <String>[];
  final List<String> deleted = <String>[];

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async {
    queries.add('${status.wireValue}:$limit:$offset');
    return _cards
        .where((ActivityCard card) => card.status == status)
        .skip(offset)
        .take(limit)
        .toList(growable: false);
  }

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
    for (final ActivityCard card in _cards) {
      counts[card.status] = (counts[card.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<ActivityCard?> cardById(String id) async =>
      _cards.cast<ActivityCard?>().firstWhere(
            (ActivityCard? card) => card?.id == id,
            orElse: () => null,
          );

  @override
  Future<int> deleteCard(String id) async {
    deleted.add(id);
    final int before = _cards.length;
    _cards.removeWhere((ActivityCard card) => card.id == id);
    return before - _cards.length;
  }

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('not exercised by the hub');

  @override
  Future<void> updateStatus(String cardId, ActivityCardStatus status) =>
      throw UnimplementedError('not exercised by the hub');

  @override
  Future<void> clearScheduledDate(String cardId) =>
      throw UnimplementedError('not exercised by the hub');
}

ActivityCard _card({
  required String id,
  required ActivityCardStatus status,
  String? title,
  bool invited = false,
  ActivityCardReplyState replyState = ActivityCardReplyState.notAnswered,
  int? priceVnd,
  String? scheduledOn,
  String? activityType,
}) {
  final DateTime now = DateTime(2026, 9, 7);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: title ?? 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: activityType,
    scheduledOn: scheduledOn,
    priceVnd: priceVnd,
    invited: invited,
    replyState: replyState,
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
        child: child,
      ),
    );

/// The SC-4 table (`ux/uiux-spec.md` §2), transcribed once and asserted
/// against the rendered footer of every status.
const Map<ActivityCardStatus, String> _sc4Labels = <ActivityCardStatus, String>{
  ActivityCardStatus.idea: 'Hẹn ngày',
  ActivityCardStatus.scheduled: 'Chuẩn bị',
  ActivityCardStatus.done: 'Ghi lại',
  ActivityCardStatus.memory: 'Xem lại',
};

const List<String> _paneLabels = <String>[
  'Mới nghĩ ra',
  'Đã hẹn ngày',
  'Đã đi rồi',
  'Đã thành kỷ niệm',
];

void main() {
  group('ActivityCardListCubit', () {
    test('loads only the selected pane and its per-pane counts', () async {
      final _FakeActivityCardRepository repository =
          _FakeActivityCardRepository(<ActivityCard>[
        _card(id: 'a', status: ActivityCardStatus.idea),
        _card(id: 'b', status: ActivityCardStatus.idea),
        _card(id: 'c', status: ActivityCardStatus.scheduled),
        _card(id: 'd', status: ActivityCardStatus.memory),
      ]);
      final ActivityCardListCubit cubit =
          ActivityCardListCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();

      expect(
        cubit.state.cards.map((ActivityCard card) => card.id),
        <String>['a', 'b'],
      );
      expect(cubit.state.countFor(ActivityCardStatus.idea), 2);
      expect(cubit.state.countFor(ActivityCardStatus.scheduled), 1);
      expect(cubit.state.countFor(ActivityCardStatus.done), 0);
      expect(cubit.state.countFor(ActivityCardStatus.memory), 1);
      expect(cubit.state.storeCount, 4);
    });

    test('switching pane replaces the list with that status only', () async {
      final _FakeActivityCardRepository repository =
          _FakeActivityCardRepository(<ActivityCard>[
        _card(id: 'a', status: ActivityCardStatus.idea),
        _card(id: 'c', status: ActivityCardStatus.scheduled),
      ]);
      final ActivityCardListCubit cubit =
          ActivityCardListCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.selectPane(ActivityCardStatus.scheduled);

      expect(cubit.state.pane, ActivityCardStatus.scheduled);
      expect(
        cubit.state.cards.map((ActivityCard card) => card.id),
        <String>['c'],
      );
      expect(
        cubit.state.cards.every(
          (ActivityCard card) => card.status == ActivityCardStatus.scheduled,
        ),
        isTrue,
      );
    });

    test('pages the pane instead of reading the whole store', () async {
      final _FakeActivityCardRepository repository =
          _FakeActivityCardRepository(<ActivityCard>[
        for (int i = 0; i < 5; i++)
          _card(id: 'i$i', status: ActivityCardStatus.idea),
      ]);
      final ActivityCardListCubit cubit =
          ActivityCardListCubit(repository: repository, pageSize: 2);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.cards, hasLength(2));
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      expect(cubit.state.cards, hasLength(4));

      await cubit.loadMore();
      expect(cubit.state.cards, hasLength(5));
      expect(cubit.state.hasMore, isFalse);

      // Every read was bounded and offset — never an unbounded full-table read.
      expect(
        repository.queries,
        <String>['idea:2:0', 'idea:2:2', 'idea:2:4'],
      );
    });

    test('the reply toggle flips between exactly two values', () async {
      final _FakeActivityCardRepository repository =
          _FakeActivityCardRepository(<ActivityCard>[
        _card(
          id: 's1',
          status: ActivityCardStatus.scheduled,
          invited: true,
        ),
      ]);
      final ActivityCardListCubit cubit =
          ActivityCardListCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.selectPane(ActivityCardStatus.scheduled);
      final ActivityCard card = cubit.state.cards.single;

      expect(cubit.state.replyStateOf(card), ActivityCardReplyState.notAnswered);
      cubit.toggleReplyState('s1');
      expect(cubit.state.replyStateOf(card), ActivityCardReplyState.answered);
      cubit.toggleReplyState('s1');
      expect(cubit.state.replyStateOf(card), ActivityCardReplyState.notAnswered);
    });

    test('AC-13: delete removes the card from a memory pane too', () async {
      final _FakeActivityCardRepository repository =
          _FakeActivityCardRepository(<ActivityCard>[
        _card(id: 'm1', status: ActivityCardStatus.memory),
      ]);
      final ActivityCardListCubit cubit =
          ActivityCardListCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.selectPane(ActivityCardStatus.memory);
      await cubit.deleteCard('m1');

      expect(repository.deleted, <String>['m1']);
      expect(cubit.state.cards, isEmpty);
    });
  });

  group('ActivityCardHubView', () {
    testWidgets('AC-10: renders exactly four panes with their full labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ActivityCardHubView(repository: _FakeActivityCardRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_status_filter')), findsOneWidget);
      for (final String label in _paneLabels) {
        expect(find.text(label), findsOneWidget);
      }
      for (final ActivityCardStatus status in kActivityCardPanes) {
        expect(
          find.byKey(Key('activity_status_filter_cell_${status.wireValue}')),
          findsOneWidget,
        );
      }
    });

    testWidgets(
      'AC-10: selecting a pane lists that status only',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            ActivityCardHubView(
              repository: _FakeActivityCardRepository(<ActivityCard>[
                _card(
                  id: 'a',
                  status: ActivityCardStatus.idea,
                  title: 'Đi xem phim',
                ),
                _card(
                  id: 'c',
                  status: ActivityCardStatus.scheduled,
                  title: 'Ăn lẩu',
                ),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Đi xem phim'), findsOneWidget);
        expect(find.text('Ăn lẩu'), findsNothing);

        await tester.tap(
          find.byKey(const Key('activity_status_filter_cell_scheduled')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ăn lẩu'), findsOneWidget);
        expect(find.text('Đi xem phim'), findsNothing);
      },
    );

    for (final ActivityCardStatus status in kActivityCardPanes) {
      testWidgets(
        'AC-11/SC-4: a ${status.wireValue} card carries exactly one primary '
        'action, labelled "${_sc4Labels[status]}"',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            _host(
              ActivityCardHubView(
                repository: _FakeActivityCardRepository(<ActivityCard>[
                  _card(id: 'x', status: status),
                ]),
              ),
            ),
          );
          await tester.pumpAndSettle();

          if (status != ActivityCardStatus.idea) {
            final Finder cell = find.byKey(
              Key('activity_status_filter_cell_${status.wireValue}'),
            );
            // The filter scrolls rather than truncating a label, so the last
            // pane sits past the right edge of a narrow viewport.
            await tester.ensureVisible(cell);
            await tester.pumpAndSettle();
            await tester.tap(cell);
            await tester.pumpAndSettle();
          }

          expect(
            find.byKey(const Key('activity_card_primary_action_x')),
            findsOneWidget,
          );
          expect(find.text(_sc4Labels[status]!), findsOneWidget);

          // No second CTA: every other status label is absent from the card.
          for (final String other in _sc4Labels.values) {
            if (other != _sc4Labels[status]) {
              expect(find.text(other), findsNothing);
            }
          }
          // AC-13's exit path exists in this pane as a non-primary affordance.
          expect(
            find.byKey(const Key('activity_card_delete_x')),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets(
      'the "đã rủ" chip shows two values, toggles on tap and carries no time '
      'label',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            ActivityCardHubView(
              repository: _FakeActivityCardRepository(<ActivityCard>[
                _card(
                  id: 's1',
                  status: ActivityCardStatus.scheduled,
                  invited: true,
                  scheduledOn: '2026-09-20',
                ),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('activity_status_filter_cell_scheduled')),
        );
        await tester.pumpAndSettle();

        final Finder chip = find.byKey(const Key('activity_card_reply_chip_s1'));
        expect(chip, findsOneWidget);
        expect(
          find.descendant(of: chip, matching: find.text('Chưa trả lời')),
          findsOneWidget,
        );

        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: chip, matching: find.text('Đã trả lời')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: chip, matching: find.text('Chưa trả lời')),
          findsNothing,
        );

        // R-1b: the chip is the only value; no clock time is rendered with it.
        expect(find.textContaining(':'), findsNothing);
      },
    );

    testWidgets('the chip is absent when the card was never invited', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ActivityCardHubView(
            repository: _FakeActivityCardRepository(<ActivityCard>[
              _card(id: 's2', status: ActivityCardStatus.scheduled),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('activity_status_filter_cell_scheduled')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('activity_card_reply_chip_s2')),
        findsNothing,
      );
      expect(find.text('Chưa trả lời'), findsNothing);
    });

    testWidgets('the price renders only when it is greater than zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ActivityCardHubView(
            repository: _FakeActivityCardRepository(<ActivityCard>[
              _card(id: 'p1', status: ActivityCardStatus.idea, priceVnd: 250000),
              _card(id: 'p0', status: ActivityCardStatus.idea, priceVnd: 0),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('250.000đ'), findsOneWidget);
      expect(find.byKey(const Key('activity_card_meta_p0')), findsNothing);
    });

    testWidgets(
      'AC-18/AC-20: no streak, day-chain, badge or partner-behaviour metric is '
      'rendered',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            ActivityCardHubView(
              repository: _FakeActivityCardRepository(<ActivityCard>[
                _card(id: 'a', status: ActivityCardStatus.idea),
                _card(
                  id: 'b',
                  status: ActivityCardStatus.scheduled,
                  invited: true,
                ),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final String forbidden in <String>[
          'streak',
          'chuỗi',
          'huy hiệu',
          'ngày liên tiếp',
          'đã xem',
        ]) {
          expect(
            find.textContaining(forbidden, skipOffstage: false),
            findsNothing,
            reason: '"$forbidden" must never reach the hub (AC-18/AC-20)',
          );
        }
        // The pane counts are plain numbers, not badges: no Badge widget and
        // no red-dot decoration is used anywhere on the filter.
        expect(find.byType(Badge), findsNothing);
      },
    );

    testWidgets(
      'UX §4b: an empty pane in a non-empty store offers one neutral line and '
      'a link back to "Mới nghĩ ra"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            ActivityCardHubView(
              repository: _FakeActivityCardRepository(<ActivityCard>[
                _card(id: 'a', status: ActivityCardStatus.idea),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('activity_status_filter_cell_done')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('activity_card_hub_empty_pane')),
          findsOneWidget,
        );
        expect(find.text('Chưa có thẻ nào ở đây.'), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('activity_card_hub_empty_pane_link')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Thẻ a'), findsOneWidget);
      },
    );

    testWidgets(
      'an empty store leaves the Minute-1 slot to P5 instead of repeating the '
      'two invitations',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(ActivityCardHubView(repository: _FakeActivityCardRepository())),
        );
        await tester.pumpAndSettle();

        // The slot paints nothing, so its sliver has no visible geometry and a
        // default finder skips it — that emptiness is the assertion.
        expect(
          find.byKey(
            const Key('activity_card_hub_minute1_slot'),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const Key('activity_card_hub_empty_pane'),
            skipOffstage: false,
          ),
          findsNothing,
        );
      },
    );

    testWidgets('UX §6: the quick-entry strip frame has exactly three cells', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(ActivityCardHubView(repository: _FakeActivityCardRepository())),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('activity_quick_entry_strip')),
        findsOneWidget,
      );
      for (int slot = 0; slot < 3; slot++) {
        expect(
          find.byKey(Key('activity_quick_entry_slot_$slot')),
          findsOneWidget,
        );
      }
      expect(find.byKey(const Key('activity_quick_entry_slot_3')), findsNothing);
    });
  });

  group('AC-22 entry point', () {
    setUp(() {
      getIt.registerLazySingleton<DreamJarRepository>(
        _NoOpDreamJarRepository.new,
      );
      getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);
    });

    tearDown(() => getIt.reset());

    testWidgets('an unpaired session renders the hub in the "Nhà" tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unpaired,
            activityCardRepository: _FakeActivityCardRepository(<ActivityCard>[
              _card(id: 'a', status: ActivityCardStatus.idea, title: 'Đi biển'),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_card_hub')), findsOneWidget);
      expect(find.text('Đi biển'), findsOneWidget);
      // No new route and no new tab: the hub replaced the dashboard in place.
      expect(find.byKey(const Key('home_screen_ready_signal')), findsNothing);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('a paired session keeps the couple dashboard untouched', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.paired,
            activityCardRepository: _FakeActivityCardRepository(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(find.byKey(const Key('activity_card_hub')), findsNothing);
    });

    testWidgets('an unresolved pairing status keeps the couple dashboard', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            activityCardRepository: _FakeActivityCardRepository(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(find.byKey(const Key('activity_card_hub')), findsNothing);
    });
  });
}
