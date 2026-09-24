import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/presentation/widgets/thanks_section.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload_repository.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_preset.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_renderer.dart';
import 'package:cupid_mobile/features/invite_composer/domain/mad_libs.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_content_gate.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/invite_composer_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves asset keys out of a map, so a test can hand the catalogue the shipped
/// pack read off disk or a synthetic one without going through `rootBundle`.
class _JsonBundle extends CachingAssetBundle {
  _JsonBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final String? source = _assets[key];
    if (source == null) {
      throw FlutterError('no asset bundled under "$key"');
    }
    return ByteData.view(Uint8List.fromList(utf8.encode(source)).buffer);
  }
}

PresetCatalogue _catalogueOf(Map<String, String> assets) =>
    PresetCatalogue(loader: ContentPackageLoader(bundle: _JsonBundle(assets)));

/// The shipped thank-you pack, read from the repository rather than from a
/// literal, so every assertion below is about the content that ships.
String _shippedSource() =>
    File(presetAssetKey(thankYouAfterDateCategoryId)).readAsStringSync();

ContentPackage<InvitePreset> _shippedPack() => ContentPackage.parse<InvitePreset>(
      _shippedSource(),
      expectedSchemaId: presetsSchemaId,
      itemParser: invitePresetFromJson,
      source: presetAssetKey(thankYouAfterDateCategoryId),
    );

PresetCatalogue _shippedCatalogue() => _catalogueOf(<String, String>{
      presetAssetKey(thankYouAfterDateCategoryId): _shippedSource(),
    });

/// A pack with [count] presets under the thank-you category, for the rotation
/// edge case the seed pack cannot express.
String _syntheticPack(int count) => jsonEncode(<String, Object?>{
      'id': 'presets.$thankYouAfterDateCategoryId',
      'version': '1.0.0',
      'schema_id': presetsSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        for (int index = 0; index < count; index++)
          <String, Object?>{
            'id': '$thankYouAfterDateCategoryId.synthetic$index.v1',
            'frame': 'synthetic frame $index',
            'clauses': <Map<String, Object?>>[
              <String, Object?>{
                'text': 'synthetic body $index',
                'requires': <String>[],
                'targets': 'sender',
              },
            ],
            'editorial_review': <String, Object?>{
              'layer1': 'reviewer.a',
              'layer2': 'reviewer.b',
              'approved_at': '2026-09-23',
            },
          },
      ],
    });

ActivityCard _card({
  String? scheduledOn = '2026-09-20',
  String? location = 'Trúc Bạch',
  int? durationMinutes = 120,
  TimeOfDaySlot? timeOfDaySlot = TimeOfDaySlot.evening,
}) =>
    ActivityCard(
      id: 'card-1',
      ownerKey: 'owner-1',
      title: 'đi ăn lẩu',
      status: ActivityCardStatus.done,
      origin: ActivityCardOrigin.manual,
      activityType: ActivityType.dining,
      scheduledOn: scheduledOn,
      location: location,
      durationMinutes: durationMinutes,
      timeOfDaySlot: timeOfDaySlot,
      invited: false,
      replyState: ActivityCardReplyState.answered,
      createdAt: DateTime(2026, 9, 18),
      updatedAt: DateTime(2026, 9, 18),
    );

/// The two repositories the Cubit needs to exist. Rotation never reaches
/// either: a frame change writes nothing.
class _UnusedPayloads implements InvitePayloadRepository {
  @override
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  }) =>
      throw UnimplementedError('rotation never shares');

  @override
  Future<InvitePayload?> latestForCard(String cardId) =>
      throw UnimplementedError('rotation never reads');

  @override
  Future<InvitePayload?> payloadById(String id) =>
      throw UnimplementedError('rotation never reads');
}

class _UnusedCards implements ActivityCardRepository {
  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) =>
      throw UnimplementedError('rotation never writes');

  @override
  Future<int> clearScheduledDate(String cardId) =>
      throw UnimplementedError('rotation never writes');

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) =>
      throw UnimplementedError('rotation never writes');

  @override
  Future<int> deleteCard(String id) =>
      throw UnimplementedError('rotation never writes');

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('rotation never writes');

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) =>
      throw UnimplementedError('rotation never lists');

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) =>
      throw UnimplementedError('rotation never lists');

  @override
  Future<ActivityCard?> cardById(String id) =>
      throw UnimplementedError('the card is handed in');

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError('rotation never counts');
}

Future<InviteComposerCubit> _composer(PresetCatalogue catalogue) async {
  final InviteComposerCubit cubit = InviteComposerCubit(
    card: _card(),
    categoryId: thankYouAfterDateCategoryId,
    catalogue: catalogue,
    payloads: _UnusedPayloads(),
    cards: _UnusedCards(),
    share: (String text) async {},
  );
  await cubit.load();
  return cubit;
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

void main() {
  group('danh mục cảm ơn nạp theo quy ước tên file (AC-21/AC-29)', () {
    test('id danh mục dịch thẳng sang khoá asset, không qua bảng tra', () {
      expect(
        presetAssetKey(thankYouAfterDateCategoryId),
        'assets/data/req016/presets.thank_you_after_date.v1.json',
      );
    });

    test('bộ seed nạp được qua catalogue bằng đúng id danh mục', () async {
      final ContentPackage<InvitePreset> package =
          await _shippedCatalogue().load(thankYouAfterDateCategoryId);

      expect(package.items, isNotEmpty);
      expect(package.id, 'presets.$thankYouAfterDateCategoryId');
    });

    test('dùng chung schema id với danh mục lời mời, không fork schema', () {
      expect(
        jsonDecode(_shippedSource()),
        containsPair('schema_id', presetsSchemaId),
      );
    });

    test('mọi id preset mang tiền tố danh mục và ổn định', () {
      for (final InvitePreset preset in _shippedPack().items) {
        expect(preset.id, startsWith('$thankYouAfterDateCategoryId.'));
        expect(preset.id, endsWith('.v1'));
      }
    });
  });

  group('nội dung bộ seed (AC-27, BR-6, BR-14, BR-18)', () {
    test('cổng nội dung không tìm thấy vi phạm nào trong bộ seed', () {
      expect(
        validatePresetPack(
          _shippedPack(),
          categoryId: thankYouAfterDateCategoryId,
        ).map((PresetViolation violation) => violation.toString()),
        isEmpty,
      );
    });

    test('câu cuối mỗi khung là câu hỏi hoặc là lối từ chối (BR-14)', () {
      for (final InvitePreset preset in _shippedPack().items) {
        final PresetClause last = preset.clauses.last;
        expect(
          last.role == ClauseRole.declineDoor || last.text.endsWith('?'),
          isTrue,
          reason: '${preset.id} đóng lại như một kết luận thay vì hỏi lại',
        );
      }
    });

    test('khung có lời rủ đi tiếp thì kèm đúng một lối từ chối (BR-6)', () {
      final List<InvitePreset> invitations = _shippedPack()
          .items
          .where(
            (InvitePreset preset) => preset.clauses.any(
              (PresetClause clause) => clause.text.contains('rủ'),
            ),
          )
          .toList(growable: false);

      expect(invitations, isNotEmpty, reason: 'bộ seed phải có khung rủ tiếp');
      for (final InvitePreset preset in invitations) {
        expect(
          preset.clauses.where(
            (PresetClause clause) => clause.role == ClauseRole.declineDoor,
          ),
          hasLength(1),
          reason: '${preset.id} nhúng lời mời nên nợ người đọc một lối ra',
        );
      }
    });

    test('mọi câu đùa đều nhắm vào người gửi, không nhắm người nhận (AC-27)',
        () {
      for (final InvitePreset preset in _shippedPack().items) {
        for (final PresetClause clause in preset.clauses) {
          expect(
            clause.targets,
            anyOf(ClauseTarget.sender, ClauseTarget.neutral),
            reason: '${preset.id}: "${clause.text}"',
          );
        }
      }
    });
  });

  group('cổng nội dung theo phạm vi danh mục (ruling 2026-09-23)', () {
    ContentPackage<InvitePreset> packWith(List<Map<String, Object?>> clauses) =>
        ContentPackage.parse<InvitePreset>(
          jsonEncode(<String, Object?>{
            'id': 'presets.fixture',
            'version': '1.0.0',
            'schema_id': presetsSchemaId,
            'locale': 'vi',
            'items': <Map<String, Object?>>[
              <String, Object?>{
                'id': 'fixture.one.v1',
                'frame': 'khung thử',
                'clauses': clauses,
                'editorial_review': <String, Object?>{
                  'layer1': 'reviewer.a',
                  'layer2': 'reviewer.b',
                  'approved_at': '2026-09-23',
                },
              },
            ],
          }),
          expectedSchemaId: presetsSchemaId,
          itemParser: invitePresetFromJson,
          source: '<fixture>',
        );

    final List<Map<String, Object?>> noDoor = <Map<String, Object?>>[
      <String, Object?>{
        'text': 'Cảm ơn cậu vì hôm nay.',
        'requires': <String>[],
        'targets': 'neutral',
      },
    ];

    test('danh mục lời mời vẫn từ chối khung thiếu lối từ chối', () {
      expect(
        validatePresetPack(packWith(noDoor), categoryId: inviteCategoryId)
            .map((PresetViolation violation) => violation.rule),
        contains(PresetGateRule.declineDoorMissing),
      );
    });

    test('danh mục cảm ơn không bị từ chối vì thiếu lối từ chối', () {
      expect(
        validatePresetPack(
          packWith(noDoor),
          categoryId: thankYouAfterDateCategoryId,
        ),
        isEmpty,
      );
    });

    test('bộ seed cảm ơn nạp dưới danh mục lời mời thì hỏng ngay', () {
      expect(
        validatePresetPack(_shippedPack(), categoryId: inviteCategoryId)
            .map((PresetViolation violation) => violation.rule),
        contains(PresetGateRule.declineDoorMissing),
        reason: 'luật cũ của danh mục lời mời phải còn nguyên độ chặt',
      );
    });

    test('fixture chứa % làm hỏng bản dựng ở danh mục cảm ơn', () {
      expect(
        validatePresetPack(
          packWith(<Map<String, Object?>>[
            <String, Object?>{
              'text': 'Buổi hôm nay vui 90%.',
              'requires': <String>[],
              'targets': 'sender',
            },
          ]),
          categoryId: thankYouAfterDateCategoryId,
        ).map((PresetViolation violation) => violation.rule),
        contains(PresetGateRule.percentDisplay),
      );
    });

    test('fixture đo hành vi người kia làm hỏng bản dựng (BR-18)', () {
      expect(
        validatePresetPack(
          packWith(<Map<String, Object?>>[
            <String, Object?>{
              'text': 'Tớ thấy cậu đã xem tin lúc nãy.',
              'requires': <String>[],
              'targets': 'neutral',
            },
          ]),
          categoryId: thankYouAfterDateCategoryId,
        ).map((PresetViolation violation) => violation.rule),
        contains(PresetGateRule.recipientBehaviour),
      );
    });

    test('lối từ chối gắn điều kiện vẫn bị từ chối ở danh mục cảm ơn', () {
      expect(
        validatePresetPack(
          packWith(<Map<String, Object?>>[
            <String, Object?>{
              'text': 'Bận ngày {date} thì cậu nói nhé.',
              'requires': <String>['date'],
              'targets': 'neutral',
              'role': 'decline_door',
            },
          ]),
          categoryId: thankYouAfterDateCategoryId,
        ).map((PresetViolation violation) => violation.rule),
        contains(PresetGateRule.declineDoorConditional),
      );
    });
  });

  group('kết xuất tất định và xoay vòng (AC-8/AC-9, R-15b)', () {
    test('cùng thẻ và cùng khung thì hai lần gọi ra đúng một chuỗi', () {
      final MadLibsValues values = MadLibsValues.fromCard(_card());

      for (final InvitePreset preset in _shippedPack().items) {
        final String first = renderInvite(preset, values);
        final String second = renderInvite(preset, values);

        expect(first, second, reason: preset.id);
        expect(first, isNotEmpty, reason: preset.id);
      }
    });

    test('thẻ thiếu trường: câu rụng cả cụm, không lộ placeholder nào', () {
      final MadLibsValues values = MadLibsValues.fromCard(
        _card(
          scheduledOn: null,
          location: null,
          durationMinutes: null,
          timeOfDaySlot: null,
        ),
      );

      for (final InvitePreset preset in _shippedPack().items) {
        final String text = renderInvite(preset, values);

        expect(text, isNot(contains('{')), reason: preset.id);
        expect(text, isNot(contains('}')), reason: preset.id);
        expect(text.trim(), isNotEmpty, reason: preset.id);
      }
    });

    test('xoay vòng với N của bộ seed: quá cuối thì về đầu, không báo hết',
        () async {
      final InviteComposerCubit cubit = await _composer(_shippedCatalogue());
      addTearDown(cubit.close);
      final int n = cubit.state.presets.length;

      expect(n, greaterThan(1));
      cubit.selectFrame(n);
      expect(cubit.state.frameIndex, 0);
      cubit.selectFrame(-1);
      expect(cubit.state.frameIndex, n - 1);
      expect(cubit.state.status, InviteComposerStatus.ready);
      expect(cubit.state.preset, isNotNull);
    });

    test('xoay vòng với N=1: mọi chỉ số đều về khung duy nhất', () async {
      final InviteComposerCubit cubit = await _composer(
        _catalogueOf(<String, String>{
          presetAssetKey(thankYouAfterDateCategoryId): _syntheticPack(1),
        }),
      );
      addTearDown(cubit.close);

      for (final int index in <int>[1, 2, -1, 7]) {
        cubit.selectFrame(index);
        expect(cubit.state.frameIndex, 0, reason: 'selectFrame($index)');
        expect(cubit.state.preset, isNotNull);
        expect(cubit.state.status, InviteComposerStatus.ready);
      }
    });
  });

  group('phần 1 — chip "Soạn lời cảm ơn" (AC-8/AC-9)', () {
    testWidgets('bấm chip mở composer với đúng thẻ và đúng danh mục',
        (WidgetTester tester) async {
      final List<String> categories = <String>[];
      final List<String> cards = <String>[];

      await tester.pumpWidget(
        _host(
          ThanksSection(
            card: _card(),
            options: ThanksOptions(
              openComposer: (
                BuildContext context,
                ActivityCard card,
                String categoryId,
                List<String> attachmentPaths,
              ) async {
                cards.add(card.id);
                categories.add(categoryId);
                return true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Soạn lời cảm ơn'), findsOneWidget);
      await tester.tap(find.byKey(const Key('thanks_compose_chip')));
      await tester.pumpAndSettle();

      expect(categories, <String>[thankYouAfterDateCategoryId]);
      expect(cards, <String>['card-1']);
    });

    testWidgets('sheet đóng xong thì hàng soạn lời cảm ơn vẫn còn (mục 4)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          ThanksSection(
            card: _card(),
            options: ThanksOptions(
              openComposer: (
                BuildContext context,
                ActivityCard card,
                String categoryId,
                List<String> attachmentPaths,
              ) async =>
                  true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('thanks_compose_chip')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('thanks_section')), findsOneWidget);
      expect(find.text('Soạn lời cảm ơn'), findsOneWidget);
    });

    testWidgets('chip không tự soạn hay tự gửi gì khi chỉ hiện ra',
        (WidgetTester tester) async {
      int opened = 0;

      await tester.pumpWidget(
        _host(
          ThanksSection(
            card: _card(),
            options: ThanksOptions(
              openComposer: (
                BuildContext context,
                ActivityCard card,
                String categoryId,
                List<String> attachmentPaths,
              ) async {
                opened++;
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(opened, 0);
    });
  });

  group('phòng thủ trước khi vẽ điểm vào (AC-27)', () {
    test('bộ seed có preset thì điểm vào được phép hiện', () async {
      expect(await thankYouPresetsAvailable(_shippedCatalogue()), isTrue);
    });

    test('thiếu file bộ nội dung thì không hiện điểm vào', () async {
      expect(
        await thankYouPresetsAvailable(_catalogueOf(<String, String>{})),
        isFalse,
      );
    });

    test('bộ nội dung hỏng thì không hiện điểm vào, cũng không ném lỗi',
        () async {
      expect(
        await thankYouPresetsAvailable(
          _catalogueOf(<String, String>{
            presetAssetKey(thankYouAfterDateCategoryId): '{ not json',
          }),
        ),
        isFalse,
      );
    });
  });
}
