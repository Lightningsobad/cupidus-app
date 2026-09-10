import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_detail_screen.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/activity_card_tile.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/card_detail_overflow_menu.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/time_of_day_slot_picker.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered-evidence capture for the per-story visual fidelity gate. Off by
/// default so the scoped suite stays hermetic; enable with
/// `flutter test test/features/activity_cards/activity_card_detail_screen_test.dart
/// --dart-define=CAPTURE_VISUALS=true`.
///
/// A widget-tree capture rather than a device screenshot, so the frame is
/// pinned to `_iosReferenceViewport` and compares against the design PNG
/// without rescaling. (Since B-1 the screen is reachable from the hub, but
/// driving it through navigation would not give the capture a fixed frame.)
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Exactly the frame the `design-reference-*-ios.png` pair was rendered at, so
/// the PNGs compare without rescaling either side.
const Size _iosReferenceViewport = Size(415, 900);

const String _visualEvidenceDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-001_activity_card_hub/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

class _StubRepository implements ActivityCardRepository {
  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;

  @override
  Future<int> deleteCard(String id) async => 1;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('detail screen never creates');

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Future<ActivityCard?> cardById(String id) =>
      throw UnimplementedError('the card is handed in, not fetched');

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError('detail screen never counts');
}

class _RecordingRepository extends _StubRepository {
  final List<String> cardIds = <String>[];
  final List<ActivityCardEdit> edits = <ActivityCardEdit>[];

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async {
    cardIds.add(cardId);
    edits.add(edit);
    return 1;
  }
}

/// One editable text field of the detail screen, with the value the write
/// contract is expected to carry once that field commits.
class _EditableField {
  const _EditableField({
    required this.name,
    required this.fieldKey,
    required this.input,
    required this.read,
    required this.expected,
    this.submits = true,
  });

  final String name;
  final Key fieldKey;
  final String input;
  final Object? Function(ActivityCardEdit edit) read;
  final Object? expected;

  /// The note is the one multi-line field, so it has no `onSubmitted` path.
  final bool submits;
}

const List<_EditableField> _editableFields = <_EditableField>[
  _EditableField(
    name: 'title',
    fieldKey: Key('card_detail_title_field'),
    input: 'Cà phê Hào Nam buổi tối',
    read: _readTitle,
    expected: 'Cà phê Hào Nam buổi tối',
  ),
  _EditableField(
    name: 'note',
    fieldKey: Key('card_detail_note_field'),
    input: 'Nhớ hỏi bàn ở tầng hai.',
    read: _readNote,
    expected: 'Nhớ hỏi bàn ở tầng hai.',
    submits: false,
  ),
  _EditableField(
    name: 'sourceLink',
    fieldKey: Key('card_detail_source_link_field'),
    input: 'https://maps.app/quan-moi',
    read: _readSourceLink,
    expected: 'https://maps.app/quan-moi',
  ),
  _EditableField(
    name: 'priceVnd',
    fieldKey: Key('card_detail_price_field'),
    input: '250000',
    read: _readPriceVnd,
    expected: 250000,
  ),
  _EditableField(
    name: 'distanceKm',
    fieldKey: Key('card_detail_distance_field'),
    input: '4.2',
    read: _readDistanceKm,
    expected: 4.2,
  ),
  _EditableField(
    name: 'durationMinutes',
    fieldKey: Key('card_detail_duration_field'),
    input: '90',
    read: _readDurationMinutes,
    expected: 90,
  ),
];

Object? _readTitle(ActivityCardEdit edit) => edit.title;
Object? _readNote(ActivityCardEdit edit) => edit.note;
Object? _readSourceLink(ActivityCardEdit edit) => edit.sourceLink;
Object? _readPriceVnd(ActivityCardEdit edit) => edit.priceVnd;
Object? _readDistanceKm(ActivityCardEdit edit) => edit.distanceKm;
Object? _readDurationMinutes(ActivityCardEdit edit) => edit.durationMinutes;

ActivityCard _card(ActivityCardStatus status) {
  final DateTime now = DateTime(2026, 9, 8);
  return ActivityCard(
    id: 'card-1',
    ownerKey: 'owner-1',
    title: 'Cà phê sách Hào Nam',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: ActivityType.dining,
    scheduledOn: status == ActivityCardStatus.idea ? null : '2026-10-01',
    priceVnd: 120000,
    distanceKm: 3.5,
    needsBooking: false,
    indoorOutdoor: ActivityCardIndoorOutdoor.indoor,
    note: 'Quán nhỏ, có kệ sách cũ ở tầng hai.',
    sourceLink: 'https://maps.app/hao-nam',
    invited: status != ActivityCardStatus.idea,
    replyState: ActivityCardReplyState.answered,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _host(Widget child, {CupidPlatform platform = CupidPlatform.material}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(platform: platform, child: child),
    );

/// Keyed by status so pumping a second status rebuilds the screen from
/// scratch. Without the key the element tree is reused, the `BlocProvider`
/// keeps the first card, and the assertion silently re-checks status one.
Widget _detail(ActivityCardStatus status) => ActivityCardDetailScreen(
      key: ValueKey<ActivityCardStatus>(status),
      card: _card(status),
      repository: _StubRepository(),
    );

/// The whole detail screen at once, so a CTA at the bottom is hit-testable
/// without a scroll step in the middle of the assertion.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(415, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// A fresh screen over a fresh recorder. The key is unique per pump because a
/// second pump with the same key reuses the element tree, and the reused
/// `BlocProvider` would keep writing into the *previous* recorder.
Future<_RecordingRepository> _pumpEditable(WidgetTester tester) =>
    _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

Future<_RecordingRepository> _pumpEditableCard(
  WidgetTester tester,
  ActivityCard card,
) async {
  final _RecordingRepository repository = _RecordingRepository();
  await tester.pumpWidget(
    _host(
      ActivityCardDetailScreen(
        key: UniqueKey(),
        card: card,
        repository: repository,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

/// The same card with the five B-1 columns populated, so a test can prove an
/// unrelated edit does not clear them and that a stored duration renders
/// formatted.
ActivityCard _cardWithB1() {
  final ActivityCard base = _card(ActivityCardStatus.scheduled);
  return ActivityCard(
    id: base.id,
    ownerKey: base.ownerKey,
    title: base.title,
    status: base.status,
    origin: base.origin,
    activityType: base.activityType,
    scheduledOn: base.scheduledOn,
    priceVnd: base.priceVnd,
    distanceKm: base.distanceKm,
    needsBooking: base.needsBooking,
    indoorOutdoor: base.indoorOutdoor,
    note: base.note,
    sourceLink: base.sourceLink,
    durationMinutes: 90,
    timeOfDaySlot: TimeOfDaySlot.evening,
    noteKeywords: 'cà phê, sách cũ',
    linkSourceLabel: 'Google Maps',
    linkSavedAt: 1757462400000,
    invited: base.invited,
    replyState: base.replyState,
    createdAt: base.createdAt,
    updatedAt: base.updatedAt,
  );
}

/// The card the evidence frames are rendered from: the same fixture as
/// [_card], with the five B-1 columns filled.
///
/// An empty column renders as nothing (the keyword strip) or as `chưa rõ` (the
/// meta cells), so a frame captured from the bare fixture would show none of
/// the work P11-P14 did on those columns and could not be compared against the
/// reference, which draws all five.
ActivityCard _captureCard(ActivityCardStatus status) {
  final ActivityCard base = _card(status);
  return ActivityCard(
    id: base.id,
    ownerKey: base.ownerKey,
    title: base.title,
    status: base.status,
    origin: base.origin,
    activityType: base.activityType,
    scheduledOn: base.scheduledOn,
    priceVnd: base.priceVnd,
    distanceKm: base.distanceKm,
    needsBooking: base.needsBooking,
    indoorOutdoor: base.indoorOutdoor,
    note: base.note,
    sourceLink: base.sourceLink,
    durationMinutes: 120,
    timeOfDaySlot: TimeOfDaySlot.afternoon,
    noteKeywords: 'thích đọc sách cũ,không uống được cà phê đậm',
    linkSourceLabel: 'Từ cái link bạn dán',
    linkSavedAt: DateTime(2026, 8, 28).millisecondsSinceEpoch,
    invited: base.invited,
    replyState: base.replyState,
    createdAt: base.createdAt,
    updatedAt: base.updatedAt,
  );
}

/// A card whose link carries both provenance values. The timestamp is built
/// from a local `DateTime` rather than a literal epoch so the expected `10/9`
/// does not depend on the machine's time zone.
ActivityCard _cardWithSavedLink() {
  final ActivityCard base = _card(ActivityCardStatus.scheduled);
  return ActivityCard(
    id: base.id,
    ownerKey: base.ownerKey,
    title: base.title,
    status: base.status,
    origin: base.origin,
    activityType: base.activityType,
    scheduledOn: base.scheduledOn,
    priceVnd: base.priceVnd,
    distanceKm: base.distanceKm,
    needsBooking: base.needsBooking,
    indoorOutdoor: base.indoorOutdoor,
    note: base.note,
    sourceLink: base.sourceLink,
    linkSourceLabel: 'Google Maps',
    linkSavedAt: DateTime(2025, 9, 10, 8, 30).millisecondsSinceEpoch,
    invited: base.invited,
    replyState: base.replyState,
    createdAt: base.createdAt,
    updatedAt: base.updatedAt,
  );
}

/// What tapping away from a field does: the focus leaves it, and nothing else.
Future<void> _blur(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

/// The value the field is actually showing, read off the rendered
/// `EditableText` rather than off the state's private controller.
String _fieldText(WidgetTester tester, Key fieldKey) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(fieldKey),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

/// D-18: A4 words its CTA for this screen instead of using the fixed SC-4
/// label. Kept here verbatim so a wording change has to be made twice.
const Map<ActivityCardStatus, String> _screenCtaText =
    <ActivityCardStatus, String>{
  ActivityCardStatus.idea: 'Chốt ngày đi thôi',
  ActivityCardStatus.scheduled: 'Chuẩn bị cho tươm tất',
  ActivityCardStatus.done: 'Ghi lại buổi đó đi',
  ActivityCardStatus.memory: 'Đọc lại · rủ đi lần nữa',
};

/// D-19: the single secondary line under the CTA, on this screen only.
const Map<ActivityCardStatus, String> _screenSecondaryText =
    <ActivityCardStatus, String>{
  ActivityCardStatus.idea: 'hoặc soạn lời rủ cho ngọt · để dành hôm khác',
  ActivityCardStatus.scheduled: 'hoặc ngó lại ghi chú · để mai tính tiếp',
  ActivityCardStatus.done: 'hoặc thêm ảnh sau · viết dần cũng được',
  ActivityCardStatus.memory: 'hoặc để yên đó · lúc nào nhớ thì mở lại',
};

/// A-1: every lifecycle route now starts at the header overflow.
Future<void> _openOverflow(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('card_detail_overflow')));
  await tester.pumpAndSettle();
}

Future<void> _dismissMenu(WidgetTester tester) async {
  Navigator.of(tester.element(find.byKey(const Key('activity_card_detail'))))
      .pop();
  await tester.pumpAndSettle();
}

Future<void> _selectOverflow(WidgetTester tester, String action) async {
  await _openOverflow(tester);
  await tester.tap(find.byKey(Key('card_detail_overflow_$action')));
  await tester.pumpAndSettle();
}

List<String> _renderedText(WidgetTester tester) => <String>[
      for (final Text text in tester.widgetList<Text>(find.byType(Text)))
        if (text.data != null) text.data!.toLowerCase(),
    ];

void main() {
  group('one screen, two modes (AC-13)', () {
    testWidgets('"ghi lại" is a mode of the detail screen, not a destination',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.done)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_card_detail')), findsOneWidget);
      expect(find.text('GHI LẠI BUỔI ĐÓ'), findsOneWidget);
      expect(find.byKey(const Key('card_detail_note_field')), findsOneWidget);
      // The record mode is the working mode, so it carries no memory frame.
      expect(find.byKey(const Key('card_detail_memory_photo')), findsNothing);
    });

    testWidgets('"xem lại" keeps a way out, so a memory is not a dead end',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.memory)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_card_detail')), findsOneWidget);
      expect(find.byKey(const Key('card_detail_memory_photo')), findsOneWidget);
      expect(find.text('CÂU BẠN VIẾT TỐI ĐÓ'), findsOneWidget);

      // Both exits are still on this screen, one tap away in the header
      // overflow: back down the lifecycle, or delete (A-1).
      await _openOverflow(tester);
      expect(
        find.byKey(const Key('card_detail_overflow_changeStatus')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('card_detail_overflow_delete')),
        findsOneWidget,
      );
      await _dismissMenu(tester);
      expect(find.text('Đọc lại · rủ đi lần nữa'), findsOneWidget);
    });
  });

  group('SC-4 · exactly one primary action', () {
    testWidgets('every status shows one CTA, worded for this screen (D-18)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      for (final MapEntry<ActivityCardStatus, String> expected
          in _screenCtaText.entries) {
        await tester.pumpWidget(_host(_detail(expected.key)));
        await tester.pumpAndSettle();

        final Finder cta = find.byKey(const Key('card_detail_primary_action'));
        expect(cta, findsOneWidget, reason: 'status ${expected.key.wireValue}');

        expect(
          find.descendant(of: cta, matching: find.text(expected.value)),
          findsOneWidget,
          reason: 'status ${expected.key.wireValue}',
        );

        // D-18 loosens only this screen: the fixed SC-4 label the P4 tile
        // still renders must no longer be the text on A4's CTA.
        final BuildContext context = tester.element(cta);
        expect(
          find.descendant(
            of: cta,
            matching: find.text(
              activityPrimaryActionLabel(
                context,
                primaryActionFor(expected.key),
              ),
            ),
          ),
          findsNothing,
          reason: 'status ${expected.key.wireValue}',
        );
      }
    });

    testWidgets('the one secondary line sits below the CTA, inert (D-19)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      for (final MapEntry<ActivityCardStatus, String> expected
          in _screenSecondaryText.entries) {
        await tester.pumpWidget(_host(_detail(expected.key)));
        await tester.pumpAndSettle();

        final Finder secondary =
            find.byKey(const Key('card_detail_secondary_line'));
        expect(
          secondary,
          findsOneWidget,
          reason: 'status ${expected.key.wireValue}',
        );
        expect(
          tester.widget<Text>(secondary).data,
          expected.value,
          reason: 'status ${expected.key.wireValue}',
        );

        // Structurally distinct: it is not inside the CTA, and it is below it.
        final Finder cta = find.byKey(const Key('card_detail_primary_action'));
        expect(
          find.descendant(of: cta, matching: secondary),
          findsNothing,
          reason: 'status ${expected.key.wireValue}',
        );
        expect(
          tester.getTopLeft(secondary).dy,
          greaterThan(tester.getBottomLeft(cta).dy - 1),
          reason: 'status ${expected.key.wireValue}',
        );

        // Visually distinct: no CTA pill, and not a second tappable action.
        expect(
          find.ancestor(of: secondary, matching: find.byType(GestureDetector)),
          findsNothing,
          reason: 'status ${expected.key.wireValue}',
        );
        expect(
          tester.widget<Text>(secondary).style?.fontWeight,
          isNot(FontWeight.w700),
          reason: 'status ${expected.key.wireValue}',
        );
      }
    });

    testWidgets('the Mới nghĩ ra CTA opens a date picker (AC-12)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.idea)));
      await tester.pumpAndSettle();

      final Finder cta = find.byKey(const Key('card_detail_primary_action'));
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('AC-18/AC-19 · nothing about the other person', () {
    testWidgets('no behaviour metric and no verdict in any mode',
        (WidgetTester tester) async {
      // Every phrase `ux/uiux-spec.md` §7 rules out, plus the scoring and
      // streak vocabulary AC-19/AC-20 rule out. This is a copy gate: the
      // schema already has no column to feed any of them.
      const List<String> forbidden = <String>[
        'đã xem',
        'đã đọc',
        'lần mở',
        'lượt mở',
        'lượt xem',
        'trả lời sau',
        'tốc độ trả lời',
        'tỷ lệ',
        'điểm',
        'xếp hạng',
        'chuỗi ngày',
        'streak',
        'huy hiệu',
        'lần cuối',
        'online',
      ];

      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        await tester.pumpWidget(_host(_detail(status)));
        await tester.pumpAndSettle();

        final List<String> rendered = _renderedText(tester);
        for (final String phrase in forbidden) {
          expect(
            rendered.where((String line) => line.contains(phrase)),
            isEmpty,
            reason:
                '"$phrase" appeared in ${status.wireValue} mode; the detail '
                'screen may not measure or judge the other person',
          );
        }
      }
    });

    testWidgets('the reply flag carries no time label',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.scheduled)));
      await tester.pumpAndSettle();

      await _selectOverflow(tester, 'markReply');

      final Finder chip = find.byKey(const Key('card_detail_reply_chip'));
      await tester.ensureVisible(chip);
      expect(chip, findsOneWidget);
      expect(
        find.descendant(of: chip, matching: find.byType(Text)),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(
          find.descendant(of: chip, matching: find.byType(Text)),
        ).data,
        'Đã trả lời',
      );
    });
  });

  group('AC-15 · an edit reaches the store when the user leaves the field', () {
    testWidgets('every text field writes its new value on blur',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final _EditableField field in _editableFields) {
        final _RecordingRepository repository = await _pumpEditable(tester);

        await tester.enterText(find.byKey(field.fieldKey), field.input);
        await tester.pump();
        // Nothing is written per keystroke: the field is still the only place
        // the new value exists until focus leaves it.
        expect(repository.edits, isEmpty, reason: field.name);

        await _blur(tester);

        expect(repository.edits, hasLength(1), reason: field.name);
        expect(repository.cardIds, <String>['card-1'], reason: field.name);
        expect(
          field.read(repository.edits.single),
          field.expected,
          reason: field.name,
        );
      }
    });

    testWidgets('every submittable field writes the same value on submit',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final _EditableField field in _editableFields) {
        if (!field.submits) {
          continue;
        }
        final _RecordingRepository repository = await _pumpEditable(tester);

        await tester.enterText(find.byKey(field.fieldKey), field.input);
        await tester.pump();
        expect(repository.edits, isEmpty, reason: field.name);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // `done` also drops focus, so the blur listener may commit the same
        // value a second time; what matters is that every write carries it.
        expect(repository.edits, isNotEmpty, reason: field.name);
        for (final ActivityCardEdit edit in repository.edits) {
          expect(field.read(edit), field.expected, reason: field.name);
        }
        expect(
          repository.cardIds.toSet(),
          <String>{'card-1'},
          reason: field.name,
        );
      }
    });

    testWidgets('an unedited field still commits its stored value unchanged',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository = await _pumpEditable(tester);

      await tester.showKeyboard(find.byKey(const Key('card_detail_note_field')));
      await tester.pump();
      await _blur(tester);

      // A blur with no edit is still a full-snapshot write, so it must not
      // quietly clear the columns the user never touched.
      final ActivityCardEdit edit = repository.edits.single;
      expect(edit.title, 'Cà phê sách Hào Nam');
      expect(edit.note, 'Quán nhỏ, có kệ sách cũ ở tầng hai.');
      expect(edit.sourceLink, 'https://maps.app/hao-nam');
      expect(edit.priceVnd, 120000);
      expect(edit.distanceKm, 3.5);
    });
  });

  group('AC-6/S6-F-6 · the title is the one field a card cannot lose', () {
    const Key titleKey = Key('card_detail_title_field');
    const String stored = 'Cà phê sách Hào Nam';

    testWidgets('an emptied title is never written and the field reverts',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final String emptied in <String>['', '   ']) {
        final _RecordingRepository repository = await _pumpEditable(tester);

        await tester.enterText(find.byKey(titleKey), emptied);
        await tester.pump();
        expect(_fieldText(tester, titleKey), emptied, reason: 'input $emptied');

        await _blur(tester);

        expect(repository.edits, isEmpty, reason: 'input $emptied');
        expect(_fieldText(tester, titleKey), stored, reason: 'input $emptied');
        expect(find.text(stored), findsOneWidget, reason: 'input $emptied');
      }
    });

    testWidgets('submitting an emptied title reverts it and stores no blank',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository = await _pumpEditable(tester);

      await tester.enterText(find.byKey(titleKey), '');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(_fieldText(tester, titleKey), stored);
      // `done` reverts the field and *then* drops focus, so the blur listener
      // commits the restored title: an unchanged snapshot, never a blank one.
      // Blank is the thing AC-6 rules out, so that is what is asserted here.
      for (final ActivityCardEdit edit in repository.edits) {
        expect(edit.title, stored);
      }
    });

    testWidgets('the revert restores the edited title, not the original one',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository = await _pumpEditable(tester);

      await tester.enterText(find.byKey(titleKey), 'Cà phê Hào Nam buổi tối');
      await _blur(tester);
      expect(repository.edits, hasLength(1));

      await tester.enterText(find.byKey(titleKey), '');
      await _blur(tester);

      // The stored title is now the edited one, so reverting to the card the
      // screen was handed would silently undo a write that already landed.
      expect(repository.edits, hasLength(1));
      expect(_fieldText(tester, titleKey), 'Cà phê Hào Nam buổi tối');
    });
  });

  group('A-2/AC-8 · chuỗi hiển thị vs. bộ đệm sửa', () {
    const Key priceKey = Key('card_detail_price_field');
    const Key distanceKey = Key('card_detail_distance_field');
    const Key durationKey = Key('card_detail_duration_field');

    testWidgets('an unfocused field shows the formatted Vietnamese string',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _cardWithB1());

      expect(_fieldText(tester, priceKey), '120.000đ');
      expect(_fieldText(tester, distanceKey), '3,5 km');
      expect(_fieldText(tester, durationKey), '1 tiếng 30 phút');
    });

    testWidgets('focusing a field swaps it to the raw buffer, blurring it '
        'swaps it back', (WidgetTester tester) async {
      _useTallViewport(tester);
      const List<(Key, String, String)> cases = <(Key, String, String)>[
        (priceKey, '120000', '120.000đ'),
        (distanceKey, '3.5', '3,5 km'),
        (durationKey, '90', '1 tiếng 30 phút'),
      ];

      for (final (Key key, String raw, String formatted) in cases) {
        await _pumpEditableCard(tester, _cardWithB1());

        await tester.showKeyboard(find.byKey(key));
        await tester.pumpAndSettle();
        expect(_fieldText(tester, key), raw, reason: '$key focused');

        await _blur(tester);
        expect(_fieldText(tester, key), formatted, reason: '$key blurred');
      }
    });

    testWidgets('typing into the price field never grows a separator '
        'mid-typing', (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _cardWithB1());

      await tester.showKeyboard(find.byKey(priceKey));
      await tester.pumpAndSettle();

      // Invariant 3: the buffer is raw for the whole of the typing, so a
      // thousands separator must not appear at 1.234 or anywhere after it.
      const List<String> keystrokes = <String>[
        '1',
        '12',
        '123',
        '1234',
        '12345',
        '123456',
        '1234567',
      ];
      for (final String typed in keystrokes) {
        await tester.enterText(find.byKey(priceKey), typed);
        await tester.pump();
        expect(_fieldText(tester, priceKey), typed, reason: typed);
        expect(_fieldText(tester, priceKey), isNot(contains('.')),
            reason: typed);
        expect(repository.edits, isEmpty, reason: typed);
      }

      // Formatting happens on focus loss, and only there.
      await _blur(tester);
      expect(_fieldText(tester, priceKey), '1.234.567đ');
    });

    testWidgets('the write path receives numbers, never a formatted string',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _cardWithB1());

      await tester.showKeyboard(find.byKey(priceKey));
      await tester.enterText(find.byKey(priceKey), '250000');
      await _blur(tester);

      final ActivityCardEdit edit = repository.edits.single;
      expect(edit.priceVnd, isA<int>());
      expect(edit.priceVnd, 250000);
      // The two fields that were never focused still hold their formatted
      // strings, and still commit as numbers.
      expect(edit.distanceKm, isA<double>());
      expect(edit.distanceKm, 3.5);
      expect(edit.durationMinutes, isA<int>());
      expect(edit.durationMinutes, 90);
    });

    testWidgets('an unrelated edit carries the five B-1 columns through the '
        'full-snapshot write', (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _cardWithB1());

      await tester.showKeyboard(find.byKey(const Key('card_detail_note_field')));
      await tester.enterText(
        find.byKey(const Key('card_detail_note_field')),
        'Đổi chỗ ngồi sang ban công.',
      );
      await _blur(tester);

      // `updateCardDetails` takes a full snapshot, so a column left out of the
      // edit is a column cleared. None of these has an editor yet.
      final ActivityCardEdit edit = repository.edits.single;
      expect(edit.note, 'Đổi chỗ ngồi sang ban công.');
      expect(edit.durationMinutes, 90);
      expect(edit.timeOfDaySlot, TimeOfDaySlot.evening);
      expect(edit.noteKeywords, 'cà phê, sách cũ');
      expect(edit.linkSourceLabel, 'Google Maps');
      expect(edit.linkSavedAt, 1757462400000);
    });

    testWidgets('clearing a field writes null rather than a zero',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _cardWithB1());

      await tester.showKeyboard(find.byKey(durationKey));
      await tester.enterText(find.byKey(durationKey), '');
      await _blur(tester);

      expect(repository.edits.single.durationMinutes, isNull);
      expect(_fieldText(tester, durationKey), '');
    });
  });

  group('A-1 · the lifecycle moved to the header overflow', () {
    testWidgets('the body no longer carries the two lifecycle rows',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditable(tester);

      expect(find.text('…'), findsOneWidget);
      expect(find.byKey(const Key('card_detail_overflow')), findsOneWidget);
      // The two Keys the body used to own, asserted by name so a future
      // re-added row fails here rather than quietly doubling the route.
      expect(
        find.byKey(const Key('card_detail_change_status_row')),
        findsNothing,
      );
      expect(find.byKey(const Key('card_detail_delete_row')), findsNothing);
    });

    testWidgets('three items, each opening its own dialog at one level',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditable(tester);

      await _openOverflow(tester);
      expect(
        find.byType(PopupMenuItem<CardDetailOverflowAction>),
        findsNWidgets(3),
      );
      await _dismissMenu(tester);

      // "Chuyển trạng thái" lands on the 4-option picker itself, with no
      // intermediate menu or screen in between.
      await _selectOverflow(tester, 'changeStatus');
      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        expect(
          find.byKey(Key('status_change_option_${status.name}')),
          findsOneWidget,
          reason: status.name,
        );
      }
      await _dismissMenu(tester);

      await _selectOverflow(tester, 'delete');
      expect(find.byKey(const Key('delete_card_dialog')), findsOneWidget);
    });

    testWidgets('AC-14 still runs both ways, and AC-15 still asks',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      await _selectOverflow(tester, 'changeStatus');
      await tester.tap(find.byKey(const Key('status_change_option_idea')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('scheduled_date_choice_dialog')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('scheduled_date_choice_keep')), findsOneWidget);
      expect(
        find.byKey(const Key('scheduled_date_choice_clear')),
        findsOneWidget,
      );
    });

    testWidgets('AC-17 · the reply flag has two states and no time label',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      await _selectOverflow(tester, 'markReply');
      expect(find.byKey(const Key('card_detail_reply_sheet')), findsOneWidget);

      final Finder chip = find.byKey(const Key('card_detail_reply_chip'));
      expect(find.descendant(of: chip, matching: find.text('Đã trả lời')),
          findsOneWidget);

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.descendant(of: chip, matching: find.text('Chưa trả lời')),
          findsOneWidget);

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.descendant(of: chip, matching: find.text('Đã trả lời')),
          findsOneWidget);

      // AC-18/AC-19: a flag, not a log. Nothing in the sheet says when.
      for (final String line in _renderedText(tester)) {
        expect(line, isNot(contains('lúc')), reason: line);
        expect(line, isNot(contains('phút')), reason: line);
        expect(line, isNot(contains(':')), reason: line);
      }
    });
  });

  group('A-3/A-4 · header alignment and block order', () {
    testWidgets('the pill sits at the right edge on `memory` only',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        await tester.pumpWidget(_host(_detail(status)));
        await tester.pumpAndSettle();

        final Rect pill =
            tester.getRect(find.byKey(const Key('card_detail_status_pill')));
        final Rect overflow =
            tester.getRect(find.byKey(const Key('card_detail_overflow')));
        final Rect back =
            tester.getRect(find.byKey(const Key('card_detail_back')));

        if (status == ActivityCardStatus.memory) {
          // A-3: the only gap left between the pill and the overflow is the
          // fixed `sm` spacer.
          expect(overflow.left - pill.right, closeTo(CupidSpacing.sm, 0.5),
              reason: status.name);
        } else {
          // The other three keep the old alignment: hard against the back
          // button, with all the slack pushed to the right of the pill.
          expect(pill.left - back.right, closeTo(CupidSpacing.sm, 0.5),
              reason: status.name);
          expect(overflow.left - pill.right, greaterThan(CupidSpacing.sm),
              reason: status.name);
        }
      }
    });

    testWidgets('the blocks read title → meta → note → chip → link → CTA',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _cardWithB1());

      // Order asserted by paint position, not by presence: a Column whose
      // children were re-shuffled would still pass a `findsOneWidget` sweep.
      final Map<String, double> top = <String, double>{
        for (final MapEntry<String, Key> block in <String, Key>{
          'title': const Key('card_detail_title_field'),
          'meta': const Key('card_detail_meta'),
          'note': const Key('card_detail_note_field'),
          'chip': const Key('card_detail_booking_chip'),
          'link': const Key('card_detail_source_link_field'),
          'cta': const Key('card_detail_primary_action'),
        }.entries)
          block.key: tester.getTopLeft(find.byKey(block.value)).dy,
      };

      final List<String> byPosition = top.keys.toList()
        ..sort((String a, String b) => top[a]!.compareTo(top[b]!));
      expect(
        byPosition,
        <String>['title', 'meta', 'note', 'chip', 'link', 'cta'],
        reason: top.toString(),
      );
    });
  });

  group('D-20 · the CTA icon separates a memory from an open card', () {
    testWidgets('memory draws `history`, the three open states draw `event`',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        await tester.pumpWidget(_host(_detail(status)));
        await tester.pumpAndSettle();

        // Read off the `Icon` widget rather than the CTA wording: D-18 lets
        // this screen reword the label freely, so a label assertion would go
        // red for a copy change and stay green for the icon regressing.
        final Icon icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(const Key('card_detail_primary_action')),
            matching: find.byType(Icon),
          ),
        );
        expect(
          icon.icon,
          status == ActivityCardStatus.memory
              ? CupidIcons.history
              : CupidIcons.event,
          reason: status.wireValue,
        );
      }
    });
  });

  group('D-29 · the meta date reads as a Vietnamese date', () {
    testWidgets('a scheduled card shows the weekday, and no ISO string',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _cardWithB1());

      expect(
        tester
            .widget<Text>(find.byKey(const Key('card_detail_meta_date')))
            .data,
        'Thứ Năm 1/10',
      );
      for (final String line in _renderedText(tester)) {
        expect(line, isNot(contains('2026-')), reason: line);
      }
    });

    testWidgets('a card with no date still reads "chưa hẹn ngày"',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _card(ActivityCardStatus.idea));

      expect(
        tester
            .widget<Text>(find.byKey(const Key('card_detail_meta_date')))
            .data,
        'chưa hẹn ngày',
      );
    });
  });

  group('A8 · the photo leads, and only on A8', () {
    testWidgets('the memory blocks read photo → title → meta → note → chip → '
        'link → CTA', (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _captureCard(ActivityCardStatus.memory));

      final Map<String, double> top = <String, double>{
        for (final MapEntry<String, Key> block in <String, Key>{
          'photo': const Key('card_detail_memory_photo'),
          'title': const Key('card_detail_title_field'),
          'meta': const Key('card_detail_meta'),
          'note': const Key('card_detail_note_field'),
          'chip': const Key('card_detail_booking_chip'),
          'link': const Key('card_detail_source_link_field'),
          'cta': const Key('card_detail_primary_action'),
        }.entries)
          block.key: tester.getTopLeft(find.byKey(block.value)).dy,
      };

      final List<String> byPosition = top.keys.toList()
        ..sort((String a, String b) => top[a]!.compareTo(top[b]!));
      expect(
        byPosition,
        <String>['photo', 'title', 'meta', 'note', 'chip', 'link', 'cta'],
        reason: top.toString(),
      );
    });

    testWidgets('the three open states have no photo and still lead with the '
        'title', (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        if (status == ActivityCardStatus.memory) {
          continue;
        }
        await _pumpEditableCard(tester, _captureCard(status));

        expect(
          find.byKey(const Key('card_detail_memory_photo')),
          findsNothing,
          reason: status.wireValue,
        );
        expect(
          tester
              .getTopLeft(find.byKey(const Key('card_detail_title_field')))
              .dy,
          lessThan(
            tester.getTopLeft(find.byKey(const Key('card_detail_meta'))).dy,
          ),
          reason: status.wireValue,
        );
      }
    });
  });

  group('F-3 · KHUNG GIỜ is picked, not read-only', () {
    testWidgets('the cell opens a one-level picker with five options',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      await tester.tap(find.byKey(const Key('card_detail_time_slot_cell')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('time_of_day_slot_picker')), findsOneWidget);
      for (final TimeOfDaySlotChoice choice in TimeOfDaySlotChoice.values) {
        expect(
          find.byKey(Key('time_of_day_slot_option_${choice.name}')),
          findsOneWidget,
          reason: choice.name,
        );
      }
      // One level: nothing inside the sheet opens another sheet.
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('picking *Tối* fills the cell and *Chưa rõ* empties it again',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      final Finder cell = find.byKey(const Key('card_detail_time_slot_cell'));
      final Finder value = find.byKey(const Key('card_detail_time_slot'));

      await tester.tap(cell);
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const Key('time_of_day_slot_option_evening')));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(value).data, 'Tối');
      expect(repository.edits.last.timeOfDaySlot, TimeOfDaySlot.evening);

      await tester.tap(cell);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('time_of_day_slot_option_unset')));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(value).data, 'chưa rõ');
      expect(repository.edits.last.timeOfDaySlot, isNull);
    });
  });

  group('F-2 · note keywords', () {
    testWidgets('stored keywords render as chips, in order, under the label',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _cardWithB1());

      final Finder strip = find.byKey(const Key('card_detail_note_keywords'));
      expect(strip, findsOneWidget);
      expect(
        find.descendant(of: strip, matching: find.byType(Text)),
        findsNWidgets(2),
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(const Key('card_detail_note_keyword_0')),
                matching: find.byType(Text),
              ),
            )
            .data,
        'cà phê',
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(const Key('card_detail_note_keyword_1')),
                matching: find.byType(Text),
              ),
            )
            .data,
        'sách cũ',
      );
      // The strip belongs to the note block, so it sits under its label.
      expect(
        tester.getTopLeft(strip).dy,
        greaterThan(
          tester
              .getTopLeft(find.byKey(const Key('card_detail_memory_quote')))
              .dy,
        ),
      );
    });

    testWidgets('a card with no keywords renders no strip at all',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      expect(find.byKey(const Key('card_detail_note_keywords')), findsNothing);
      expect(find.byKey(const Key('card_detail_note_keyword_0')), findsNothing);
    });

    testWidgets('blank items are dropped and the last deletion writes null',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      await tester.enterText(
        find.byKey(const Key('card_detail_note_keyword_field')),
        'cà phê , , sách ',
      );
      await _blur(tester);

      expect(repository.edits.last.noteKeywords, 'cà phê,sách');
      expect(find.byKey(const Key('card_detail_note_keyword_1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('card_detail_note_keyword_1')));
      await tester.pumpAndSettle();
      expect(repository.edits.last.noteKeywords, 'cà phê');

      await tester.tap(find.byKey(const Key('card_detail_note_keyword_0')));
      await tester.pumpAndSettle();
      // Null, never `''`: an empty string would leave a row that still reads
      // as "has keywords" to anything counting non-nulls.
      expect(repository.edits.last.noteKeywords, isNull);
      expect(find.byKey(const Key('card_detail_note_keywords')), findsNothing);
    });
  });

  group('F-2/§13.4 · link provenance', () {
    testWidgets('the provenance row appears only when the card has one',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpEditableCard(tester, _cardWithSavedLink());

      expect(find.byKey(const Key('card_detail_link_provenance')),
          findsOneWidget);
      expect(
        _fieldText(tester, const Key('card_detail_link_source_label_field')),
        'Google Maps',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('card_detail_link_saved_at')))
            .data,
        'lưu 10/9',
      );
      expect(find.byKey(const Key('card_detail_source_link_field')),
          findsOneWidget);

      await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));
      expect(find.byKey(const Key('card_detail_link_provenance')), findsNothing);
      // The link row itself is untouched by the row above it going away.
      expect(find.byKey(const Key('card_detail_source_link_field')),
          findsOneWidget);
    });

    testWidgets('a new link stamps `linkSavedAt` in the same single write',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository =
          await _pumpEditableCard(tester, _card(ActivityCardStatus.scheduled));

      final int before = repository.edits.length;
      await tester.enterText(
        find.byKey(const Key('card_detail_source_link_field')),
        'https://maps.app/quan-moi',
      );
      await _blur(tester);

      expect(repository.edits.length - before, 1);
      expect(repository.edits.last.sourceLink, 'https://maps.app/quan-moi');
      final int? stamped = repository.edits.last.linkSavedAt;
      expect(stamped, isNotNull);

      // An unrelated edit must not restamp or drop it — this is the
      // `_withEdits` carry-forward regression.
      await tester.enterText(
        find.byKey(const Key('card_detail_note_field')),
        'Đổi ý, đi chỗ khác.',
      );
      await _blur(tester);
      expect(repository.edits.last.note, 'Đổi ý, đi chỗ khác.');
      expect(repository.edits.last.linkSavedAt, stamped);

      // Clearing the link clears its stamp with it.
      await tester.enterText(
        find.byKey(const Key('card_detail_source_link_field')),
        '',
      );
      await _blur(tester);
      expect(repository.edits.last.sourceLink, isNull);
      expect(repository.edits.last.linkSavedAt, isNull);
    });
  });

  testWidgets(
    'renders the visual-fidelity evidence frames',
    (WidgetTester tester) async {
      tester.view.physicalSize = _iosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);

      const Map<ActivityCardStatus, String> pillLabel =
          <ActivityCardStatus, String>{
        ActivityCardStatus.idea: 'MỚI NGHĨ RA',
        ActivityCardStatus.done: 'ĐÃ ĐI RỒI',
        ActivityCardStatus.memory: 'ĐÃ THÀNH KỶ NIỆM',
      };

      for (final MapEntry<ActivityCardStatus, String> frame
          in <ActivityCardStatus, String>{
        ActivityCardStatus.idea: 'implemented-chi-tiet-the-moi-nghi-ra-ios.png',
        ActivityCardStatus.done:
            'implemented-chi-tiet-the-moi-nghi-ra-ios-ghi-lai.png',
        ActivityCardStatus.memory: 'implemented-the-da-thanh-ky-niem-ios.png',
      }.entries) {
        await tester.pumpWidget(
          RepaintBoundary(
            key: _captureBoundaryKey,
            child: _host(
              ActivityCardDetailScreen(
                key: ValueKey<ActivityCardStatus>(frame.key),
                card: _captureCard(frame.key),
                repository: _StubRepository(),
              ),
              platform: CupidPlatform.ios,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        // A frame that silently re-rendered the previous status is worse than
        // no evidence at all, so the pill is read back before the PNG is kept.
        expect(
          find.descendant(
            of: find.byKey(const Key('card_detail_status_pill')),
            matching: find.text(pillLabel[frame.key]!),
          ),
          findsOneWidget,
        );
        await _writeCapture(tester, frame.value);
      }
    },
    skip: !kCaptureVisuals,
  );
}

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// off disk. Without this every glyph rasterizes as a fallback box and the
/// capture is worthless for typography comparison.
Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }
  });
}

Future<void> _writeCapture(WidgetTester tester, String fileName) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    final File out = File('$_visualEvidenceDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}
