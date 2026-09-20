import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload_repository.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/invite_composer_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityCard _card({
  String title = 'Xem phim Dune',
  String? location = 'Rạp CGV Vincom',
  bool invited = false,
  String? note = 'nhớ đặt vé sớm',
}) => ActivityCard(
  id: 'card-1',
  ownerKey: 'owner-1',
  title: title,
  status: ActivityCardStatus.scheduled,
  origin: ActivityCardOrigin.manual,
  scheduledOn: '2026-08-15',
  timeOfDaySlot: TimeOfDaySlot.evening,
  durationMinutes: 120,
  location: location,
  note: note,
  invited: invited,
  replyState: ActivityCardReplyState.notAnswered,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

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
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

String _packJson({int presetCount = 3, String version = '1.0.0'}) =>
    jsonEncode(<String, Object?>{
      'id': 'presets.invite',
      'version': version,
      'schema_id': presetsSchemaId,
      'locale': 'vi',
      'items': List<Map<String, Object?>>.generate(presetCount, (int index) {
        return <String, Object?>{
          'id': 'frame.$index.v1',
          'frame': 'Khung $index',
          'clauses': <Map<String, Object?>>[
            <String, Object?>{
              'text': 'Khung$index rủ {activity} nhé?',
              'requires': <String>['activity'],
              'targets': 'neutral',
            },
            <String, Object?>{
              'text': 'Ở {place}.',
              'requires': <String>['place'],
              'targets': 'neutral',
            },
            <String, Object?>{
              'text': 'Bận thì nói mình biết nha.',
              'requires': <String>[],
              'targets': 'neutral',
              'role': 'decline_door',
            },
          ],
        };
      }, growable: false),
    });

PresetCatalogue _catalogue({int presetCount = 3, String version = '1.0.0'}) =>
    PresetCatalogue(
      loader: ContentPackageLoader(
        bundle: _TestBundle(<String, String>{
          presetAssetKey(inviteCategoryId): _packJson(
            presetCount: presetCount,
            version: version,
          ),
        }),
      ),
    );

class _RecordingPayloadRepository implements InvitePayloadRepository {
  final List<InvitePayload> saved = <InvitePayload>[];
  bool throwOnSave = false;

  @override
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  }) async {
    if (throwOnSave) {
      throw StateError('disk full');
    }
    final InvitePayload payload = InvitePayload(
      id: 'payload-${saved.length}',
      cardId: cardId,
      categoryId: categoryId,
      presetId: presetId,
      packVersion: packVersion,
      filledValues: filledValues,
      userEditedText: userEditedText,
      createdAt: DateTime.utc(2026, 8, 2),
    );
    saved.add(payload);
    return payload;
  }

  @override
  Future<InvitePayload?> latestForCard(String cardId) async =>
      saved.isEmpty ? null : saved.last;

  @override
  Future<InvitePayload?> payloadById(String id) async => null;
}

class _RecordingCardRepository implements ActivityCardRepository {
  final List<({String cardId, ActivityCardEdit edit})> edits =
      <({String cardId, ActivityCardEdit edit})>[];

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async {
    edits.add((cardId: cardId, edit: edit));
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'the composer must not call ${invocation.memberName} on the card store',
  );
}

void main() {
  late _RecordingPayloadRepository payloads;
  late _RecordingCardRepository cards;
  late List<String> shared;

  setUp(() {
    payloads = _RecordingPayloadRepository();
    cards = _RecordingCardRepository();
    shared = <String>[];
  });

  Future<InviteComposerCubit> build({
    ActivityCard? card,
    int presetCount = 3,
    String version = '1.0.0',
    PresetCatalogue? catalogue,
  }) async {
    final InviteComposerCubit cubit = InviteComposerCubit(
      card: card ?? _card(),
      categoryId: inviteCategoryId,
      catalogue:
          catalogue ??
          _catalogue(presetCount: presetCount, version: version),
      payloads: payloads,
      cards: cards,
      share: (String text) async => shared.add(text),
    );
    await cubit.load();
    return cubit;
  }

  group('load', () {
    test('renders the first frame from the pack straight away', () async {
      final InviteComposerCubit cubit = await build();

      expect(cubit.state.status, InviteComposerStatus.ready);
      expect(cubit.state.frameIndex, 0);
      expect(
        cubit.state.text,
        'Khung0 rủ Xem phim Dune nhé? Ở Rạp CGV Vincom. '
        'Bận thì nói mình biết nha.',
      );
      addTearDown(cubit.close);
    });

    test('an empty pack is unavailable, not an empty composer', () async {
      final InviteComposerCubit cubit = await build(presetCount: 0);

      expect(cubit.state.status, InviteComposerStatus.unavailable);
      expect(cubit.state.preset, isNull);
      addTearDown(cubit.close);
    });

    test('a missing asset is unavailable rather than a crash', () async {
      final InviteComposerCubit cubit = await build(
        catalogue: PresetCatalogue(
          loader: ContentPackageLoader(bundle: _TestBundle(<String, String>{})),
        ),
      );

      expect(cubit.state.status, InviteComposerStatus.unavailable);
      addTearDown(cubit.close);
    });

    test('a card with no location drops the clause that needs it (AC-6)',
        () async {
      final InviteComposerCubit cubit = await build(
        card: _card(location: null),
      );

      expect(
        cubit.state.text,
        'Khung0 rủ Xem phim Dune nhé? Bận thì nói mình biết nha.',
      );
      addTearDown(cubit.close);
    });
  });

  group('frame selection (AC-5/AC-26/AC-27/R-15b)', () {
    test('changing chip re-renders immediately, with no apply step', () async {
      final InviteComposerCubit cubit = await build();

      cubit.selectFrame(2);

      expect(cubit.state.frameIndex, 2);
      expect(cubit.state.text, startsWith('Khung2 '));
      addTearDown(cubit.close);
    });

    test('walking past the end wraps instead of ending', () async {
      final InviteComposerCubit cubit = await build(presetCount: 3);

      cubit.selectFrame(3);
      expect(cubit.state.frameIndex, 0);
      cubit.selectFrame(4);
      expect(cubit.state.frameIndex, 1);
      cubit.selectFrame(97);
      expect(cubit.state.frameIndex, 1);
      addTearDown(cubit.close);
    });

    test('walking back past the start wraps too', () async {
      final InviteComposerCubit cubit = await build(presetCount: 3);

      cubit.selectFrame(-1);
      expect(cubit.state.frameIndex, 2);
      addTearDown(cubit.close);
    });

    test('a one-frame pack has no dead end either', () async {
      final InviteComposerCubit cubit = await build(presetCount: 1);

      cubit.selectFrame(1);
      expect(cubit.state.frameIndex, 0);
      expect(cubit.state.text, startsWith('Khung0 '));
      addTearDown(cubit.close);
    });

    test('works at a pack size no code mentions', () async {
      final InviteComposerCubit cubit = await build(presetCount: 41);

      cubit.selectFrame(40);
      expect(cubit.state.frameIndex, 40);
      cubit.selectFrame(41);
      expect(cubit.state.frameIndex, 0);
      addTearDown(cubit.close);
    });
  });

  group('manual edit (AC-7)', () {
    test('survives a round trip through another frame', () async {
      final InviteComposerCubit cubit = await build();

      cubit.editText('Tối nay đi xem Dune không?');
      cubit.selectFrame(1);
      expect(cubit.state.text, startsWith('Khung1 '));

      cubit.selectFrame(0);
      expect(cubit.state.text, 'Tối nay đi xem Dune không?');
      addTearDown(cubit.close);
    });

    test('is per frame, so an untouched frame still re-renders', () async {
      final InviteComposerCubit cubit = await build();

      cubit.editText('bản sửa tay');
      cubit.selectFrame(2);

      expect(cubit.state.userEditedText, isNull);
      expect(cubit.state.text, cubit.state.renderedText);
      addTearDown(cubit.close);
    });

    test('typing the draft back verbatim clears the override', () async {
      final InviteComposerCubit cubit = await build();
      final String draft = cubit.state.renderedText;

      cubit.editText('khác hẳn');
      expect(cubit.state.userEditedText, 'khác hẳn');

      cubit.editText(draft);
      expect(cubit.state.userEditedText, isNull);
      addTearDown(cubit.close);
    });
  });

  group('share (AC-16/AC-17/AC-18/AC-19)', () {
    test('writes the payload before handing the text to the OS', () async {
      final _OrderRecordingRepository ordered = _OrderRecordingRepository();
      final List<String> order = <String>[];
      ordered.onSave = () => order.add('save');
      final InviteComposerCubit cubit = InviteComposerCubit(
        card: _card(),
        categoryId: inviteCategoryId,
        catalogue: _catalogue(),
        payloads: ordered,
        cards: cards,
        share: (String text) async => order.add('share'),
      );
      await cubit.load();

      await cubit.share();

      expect(order, <String>['save', 'share']);
      addTearDown(cubit.close);
    });

    test('stores the structured input, never the rendered sentence', () async {
      final InviteComposerCubit cubit = await build(version: '2.4.0');

      await cubit.share();

      final InvitePayload payload = payloads.saved.single;
      expect(payload.presetId, 'frame.0.v1');
      expect(payload.packVersion, '2.4.0');
      expect(payload.categoryId, inviteCategoryId);
      expect(payload.userEditedText, isNull);
      expect(
        payload.filledValues.keys,
        unorderedEquals(<String>[
          'activity',
          'date',
          'time',
          'place',
          'duration',
        ]),
      );
      expect(payload.filledValues['activity'], 'Xem phim Dune');
      expect(payload.filledValues['place'], 'Rạp CGV Vincom');
      expect(payload.filledValues['time'], 'tối');
      // The rendered sentence must not appear anywhere in the stored input --
      // that is the exact flattening AC-17 forbids.
      for (final String value in payload.filledValues.values) {
        expect(value, isNot(contains('Bận thì nói')));
        expect(value, isNot(contains('Khung0')));
      }
      addTearDown(cubit.close);
    });

    test('a manual edit is stored alongside the input, not instead of it',
        () async {
      final InviteComposerCubit cubit = await build();

      cubit.editText('Đi xem Dune tối nay nhé?');
      await cubit.share();

      final InvitePayload payload = payloads.saved.single;
      expect(payload.userEditedText, 'Đi xem Dune tối nay nhé?');
      expect(payload.filledValues['activity'], 'Xem phim Dune');
      expect(shared.single, 'Đi xem Dune tối nay nhé?');
      addTearDown(cubit.close);
    });

    test('the shared text is exactly what the preview showed', () async {
      final InviteComposerCubit cubit = await build();
      cubit.selectFrame(1);

      await cubit.share();

      expect(shared.single, cubit.state.text);
      addTearDown(cubit.close);
    });

    test('sets invited on first export and leaves every other field alone',
        () async {
      final ActivityCard card = _card();
      final InviteComposerCubit cubit = await build(card: card);

      await cubit.share();

      final ({String cardId, ActivityCardEdit edit}) written =
          cards.edits.single;
      final ActivityCardEdit reference = ActivityCardEdit.from(card);
      expect(written.cardId, 'card-1');
      expect(written.edit.invited, isTrue);
      expect(written.edit.title, reference.title);
      expect(written.edit.activityType, reference.activityType);
      expect(written.edit.scheduledOn, reference.scheduledOn);
      expect(written.edit.priceVnd, reference.priceVnd);
      expect(written.edit.distanceKm, reference.distanceKm);
      expect(written.edit.needsBooking, reference.needsBooking);
      expect(written.edit.indoorOutdoor, reference.indoorOutdoor);
      expect(written.edit.note, reference.note);
      expect(written.edit.sourceLink, reference.sourceLink);
      expect(written.edit.durationMinutes, reference.durationMinutes);
      expect(written.edit.timeOfDaySlot, reference.timeOfDaySlot);
      expect(written.edit.noteKeywords, reference.noteKeywords);
      expect(written.edit.linkSourceLabel, reference.linkSourceLabel);
      expect(written.edit.linkSavedAt, reference.linkSavedAt);
      expect(written.edit.location, reference.location);
      expect(written.edit.replyState, reference.replyState);
      addTearDown(cubit.close);
    });

    test('an already-invited card is not rewritten', () async {
      final InviteComposerCubit cubit = await build(
        card: _card(invited: true),
      );

      await cubit.share();

      expect(cards.edits, isEmpty);
      expect(payloads.saved, hasLength(1));
      addTearDown(cubit.close);
    });

    test('a second export in the same session does not re-flip invited',
        () async {
      final InviteComposerCubit cubit = await build();

      await cubit.share();
      await cubit.share();

      expect(cards.edits, hasLength(1));
      expect(payloads.saved, hasLength(2));
      addTearDown(cubit.close);
    });

    test('a failed write aborts the share instead of exporting silently',
        () async {
      final InviteComposerCubit cubit = await build();
      payloads.throwOnSave = true;

      await cubit.share();

      expect(shared, isEmpty);
      expect(cards.edits, isEmpty);
      expect(cubit.state.failure, InviteComposerFailure.saveFailed);
      expect(cubit.state.exporting, isFalse);
      expect(cubit.state.exported, isFalse);
      addTearDown(cubit.close);
    });

    test('a later successful attempt clears the failure', () async {
      final InviteComposerCubit cubit = await build();
      payloads.throwOnSave = true;
      await cubit.share();

      payloads.throwOnSave = false;
      await cubit.share();

      expect(cubit.state.failure, isNull);
      expect(cubit.state.exported, isTrue);
      expect(shared, hasLength(1));
      addTearDown(cubit.close);
    });
  });

  group('nothing countable leaks out of this Cubit (AC-14/AC-26/AC-27)', () {
    test('the state exposes no count, total, or progress member', () {
      final String source = File(
        'lib/features/invite_composer/presentation/invite_composer_cubit.dart',
      ).readAsStringSync();
      final String code = source
          .split('\n')
          .where((String line) => !line.trimLeft().startsWith('//'))
          .join('\n');

      for (final String forbidden in const <String>[
        'ShareResult',
        'countForCard',
        'totalFrames',
        'presetCount',
        'remaining',
      ]) {
        expect(
          code,
          isNot(contains(forbidden)),
          reason: '"$forbidden" would be the seam a count/progress surface '
              'gets built on (AC-26/AC-27/R-15b, AC-19)',
        );
      }
    });
  });
}

class _OrderRecordingRepository implements InvitePayloadRepository {
  VoidCallback? onSave;

  @override
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  }) async {
    onSave?.call();
    return InvitePayload(
      id: 'payload-0',
      cardId: cardId,
      categoryId: categoryId,
      presetId: presetId,
      packVersion: packVersion,
      filledValues: filledValues,
      userEditedText: userEditedText,
      createdAt: DateTime.utc(2026, 8, 2),
    );
  }

  @override
  Future<InvitePayload?> latestForCard(String cardId) async => null;

  @override
  Future<InvitePayload?> payloadById(String id) async => null;
}
