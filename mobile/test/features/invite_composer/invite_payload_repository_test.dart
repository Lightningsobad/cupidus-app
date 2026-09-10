import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/features/invite_composer/data/invite_payload_repository_impl.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload_repository.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_preset.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_renderer.dart';
import 'package:cupid_mobile/features/invite_composer/domain/mad_libs.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The SB-125 payload contract (`architecture/contract-summary.md` §4).
///
/// The load-bearing test here is the round trip through a database that is
/// *closed and reopened* between the write and the read. An in-memory database
/// reused across both halves would keep the Dart objects alive and pass even if
/// the stored columns were wrong, which is exactly the failure AC-18 is about.
void main() {
  const InvitePreset moviePreset = InvitePreset(
    id: 'invite.rap_phim.v1',
    frame: 'Rủ đi xem phim',
    clauses: <PresetClause>[
      PresetClause(
        text: 'Tui đang tính đi {activity}.',
        requires: <MadLibsVariable>[MadLibsVariable.activity],
        targets: ClauseTarget.sender,
      ),
      PresetClause(
        text: 'Chắc là {date}, tầm {time}.',
        requires: <MadLibsVariable>[MadLibsVariable.date, MadLibsVariable.time],
        targets: ClauseTarget.neutral,
      ),
      PresetClause(
        text: 'Chỗ hẹn là {place}.',
        requires: <MadLibsVariable>[MadLibsVariable.place],
        targets: ClauseTarget.neutral,
      ),
      PresetClause(
        text: 'Bận thì thôi nha, tui tự đi cũng vui.',
        requires: <MadLibsVariable>[],
        targets: ClauseTarget.sender,
        role: ClauseRole.declineDoor,
      ),
    ],
  );

  const InvitePreset coffeePreset = InvitePreset(
    id: 'invite.quan_ca_phe.v1',
    frame: 'Rủ đi cà phê',
    clauses: <PresetClause>[
      PresetClause(
        text: 'Đi {activity} không?',
        requires: <MadLibsVariable>[MadLibsVariable.activity],
        targets: ClauseTarget.neutral,
      ),
      PresetClause(
        text: 'Không rảnh cũng không sao.',
        requires: <MadLibsVariable>[],
        targets: ClauseTarget.sender,
        role: ClauseRole.declineDoor,
      ),
    ],
  );

  ContentPackage<InvitePreset> packageOf(
    List<InvitePreset> items, {
    String version = '1.0.0',
  }) =>
      ContentPackage<InvitePreset>(
        id: 'presets.invite',
        version: version,
        schemaId: 'req016.presets.v1',
        items: items,
      );

  const Map<String, String> exportedValues = <String, String>{
    'activity': 'xem phim',
    'date': 'thứ Bảy 20/9',
    'time': 'tối',
  };

  group('filled_values codec', () {
    test('round-trips a filled map through JSON unchanged', () {
      expect(decodeFilledValues(encodeFilledValues(exportedValues)),
          exportedValues);
    });

    test('round-trips an empty map', () {
      expect(decodeFilledValues(encodeFilledValues(const <String, String>{})),
          isEmpty);
    });

    test('encodes only filled_values, never the other payload fields', () {
      // A blob holding card_id/preset_id would make the payload opaque and
      // break AC-17 even though it would still re-render.
      final String encoded = encodeFilledValues(exportedValues);
      expect(encoded, isNot(contains('preset')));
      expect(encoded, isNot(contains('card')));
      expect(encoded, isNot(contains('pack_version')));
    });

    test('rejects a corrupt row instead of half-filling the sentence', () {
      expect(() => decodeFilledValues('not json'), throwsFormatException);
      expect(() => decodeFilledValues('["activity"]'), throwsFormatException);
      expect(() => decodeFilledValues('{"activity": 7}'), throwsFormatException);
      expect(
        () => decodeFilledValues('{"activity": null}'),
        throwsFormatException,
      );
    });

    test('maps to and from the renderer\'s closed variable set', () {
      final MadLibsValues values = madLibsValuesFrom(exportedValues);
      expect(values[MadLibsVariable.activity], 'xem phim');
      expect(values.contains(MadLibsVariable.place), isFalse);
      expect(filledValuesFrom(values), exportedValues);
    });

    test('drops a key outside the closed set rather than failing the render',
        () {
      final MadLibsValues values = madLibsValuesFrom(<String, String>{
        ...exportedValues,
        'weather': 'mưa',
      });
      expect(filledValuesFrom(values), exportedValues);
    });
  });

  group('renderStored', () {
    InvitePayload payload({String? userEditedText}) => InvitePayload(
          id: 'payload-1',
          cardId: 'card-1',
          categoryId: 'invite',
          presetId: moviePreset.id,
          packVersion: '1.0.0',
          filledValues: exportedValues,
          userEditedText: userEditedText,
          createdAt: DateTime.fromMillisecondsSinceEpoch(1758326400000),
        );

    test('unedited: re-renders from preset + filled values', () {
      expect(
        renderStored(payload(), packageOf(<InvitePreset>[moviePreset])),
        'Tui đang tính đi xem phim. Chắc là thứ Bảy 20/9, tầm tối. '
        'Bận thì thôi nha, tui tự đi cũng vui.',
      );
    });

    test('unedited: a clause whose variable is absent stays dropped (AC-6)', () {
      expect(
        renderStored(payload(), packageOf(<InvitePreset>[moviePreset])),
        isNot(contains('Chỗ hẹn là')),
      );
    });

    test('edited: returns the user text verbatim, without consulting the pack',
        () {
      // Empty package on purpose: the AC-7 override must survive a preset being
      // reworded, reordered, or removed entirely.
      expect(
        renderStored(
          payload(userEditedText: 'Đi xem phim với tui đi, mai tối.'),
          packageOf(const <InvitePreset>[]),
        ),
        'Đi xem phim với tui đi, mai tối.',
      );
    });

    test('edited: an empty override is an override, not a missing one', () {
      expect(
        renderStored(
          payload(userEditedText: ''),
          packageOf(const <InvitePreset>[]),
        ),
        '',
      );
    });

    test('names the missing preset instead of rendering a wrong sentence', () {
      expect(
        () => renderStored(payload(), packageOf(<InvitePreset>[coffeePreset])),
        throwsA(isA<StateError>().having(
          (StateError e) => e.message,
          'message',
          contains('invite.rap_phim.v1'),
        )),
      );
    });

    test('survives a pack version bump that keeps the preset id', () {
      final String atExport =
          renderStored(payload(), packageOf(<InvitePreset>[moviePreset]));
      // v2 adds a preset and reorders: nothing about the stored payload's own
      // preset changed, so the stored id still resolves.
      final String afterBump = renderStored(
        payload(),
        packageOf(<InvitePreset>[coffeePreset, moviePreset], version: '2.0.0'),
      );
      expect(afterBump, atExport);
    });
  });

  group('round trip through a reopened database', () {
    late Directory tempDir;
    late File databaseFile;
    final List<CupidDatabase> opened = <CupidDatabase>[];

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cupid_invite_payload');
      databaseFile =
          File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
      final CupidDatabase seed = CupidDatabase(NativeDatabase(databaseFile));
      await seed.activityCardDao.upsertCard(
        ActivityCardsCompanion.insert(
          id: 'card-1',
          ownerKey: 'user-1',
          title: 'Xem phim',
          origin: 'manual',
          createdAt: DateTime.utc(2026, 9, 1),
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );
      await seed.close();
    });

    tearDown(() async {
      for (final CupidDatabase database in opened) {
        try {
          await database.close();
        } catch (_) {}
      }
      opened.clear();
      await tempDir.delete(recursive: true);
    });

    /// Opens a fresh connection every time. Each call is a separate app launch
    /// as far as the payload is concerned. Tests close the writer explicitly;
    /// the teardown is a net for the rest, which is why a double close is
    /// swallowed here.
    CupidDatabase openDatabase() {
      final CupidDatabase database = CupidDatabase(NativeDatabase(databaseFile));
      opened.add(database);
      return database;
    }

    InvitePayloadRepository repositoryOn(
      CupidDatabase database, {
      String id = 'payload-1',
      DateTime? now,
    }) =>
        InvitePayloadRepositoryImpl(
          database.inviteMessageDao,
          newId: () => id,
          now: () => now ?? DateTime.utc(2026, 9, 20, 12),
        );

    test('unedited payload re-renders to the exact export-time string (AC-18)',
        () async {
      final ContentPackage<InvitePreset> pack =
          packageOf(<InvitePreset>[moviePreset]);
      final String atExport =
          renderInvite(moviePreset, madLibsValuesFrom(exportedValues));

      final CupidDatabase writer = openDatabase();
      await repositoryOn(writer).savePayload(
        cardId: 'card-1',
        categoryId: 'invite',
        presetId: moviePreset.id,
        packVersion: '1.0.0',
        filledValues: exportedValues,
      );
      await writer.close();

      final InvitePayload? reloaded =
          await repositoryOn(openDatabase()).payloadById('payload-1');
      expect(reloaded, isNotNull);
      expect(renderStored(reloaded!, pack), atExport);
      expect(
        renderStored(reloaded, pack),
        'Tui đang tính đi xem phim. Chắc là thứ Bảy 20/9, tầm tối. '
        'Bận thì thôi nha, tui tự đi cũng vui.',
      );
    });

    test('edited payload re-renders to the edited string (AC-7/AC-18)',
        () async {
      const String edited = 'Mai tối đi xem phim với tui nha, hong đi cũng ok.';

      final CupidDatabase writer = openDatabase();
      await repositoryOn(writer).savePayload(
        cardId: 'card-1',
        categoryId: 'invite',
        presetId: moviePreset.id,
        packVersion: '1.0.0',
        filledValues: exportedValues,
        userEditedText: edited,
      );
      await writer.close();

      final InvitePayload? reloaded =
          await repositoryOn(openDatabase()).payloadById('payload-1');
      expect(reloaded!.userEditedText, edited);
      expect(
        renderStored(reloaded, packageOf(<InvitePreset>[moviePreset])),
        edited,
      );
    });

    test('the stored columns hold the input, never the rendered sentence',
        () async {
      final CupidDatabase writer = openDatabase();
      await repositoryOn(writer).savePayload(
        cardId: 'card-1',
        categoryId: 'invite',
        presetId: moviePreset.id,
        packVersion: '1.0.0',
        filledValues: exportedValues,
      );
      await writer.close();

      final CupidDatabase reader = openDatabase();
      final row = await reader
          .customSelect('SELECT * FROM invite_messages WHERE id = ?',
              variables: [Variable<String>('payload-1')])
          .getSingle();
      final String filledValues = row.read<String>('filled_values');
      expect(filledValues, isNot(contains('Tui đang tính')));
      expect(filledValues, isNot(contains('Bận thì thôi')));
      expect(decodeFilledValues(filledValues), exportedValues);
      expect(row.read<String>('preset_id'), moviePreset.id);
      expect(row.read<String>('pack_version'), '1.0.0');
    });

    test('a payload stored before a pack revision still re-renders', () async {
      final String atExport =
          renderInvite(moviePreset, madLibsValuesFrom(exportedValues));

      final CupidDatabase writer = openDatabase();
      await repositoryOn(writer).savePayload(
        cardId: 'card-1',
        categoryId: 'invite',
        presetId: moviePreset.id,
        packVersion: '1.0.0',
        filledValues: exportedValues,
      );
      await writer.close();

      final InvitePayload? reloaded =
          await repositoryOn(openDatabase()).payloadById('payload-1');
      expect(reloaded!.packVersion, '1.0.0');
      expect(
        renderStored(
          reloaded,
          packageOf(<InvitePreset>[coffeePreset, moviePreset],
              version: '2.0.0'),
        ),
        atExport,
      );
    });

    test('two share taps are two items, and latestForCard returns the newer',
        () async {
      final CupidDatabase writer = openDatabase();
      await repositoryOn(writer, id: 'payload-1', now: DateTime.utc(2026, 9, 20, 12))
          .savePayload(
        cardId: 'card-1',
        categoryId: 'invite',
        presetId: moviePreset.id,
        packVersion: '1.0.0',
        filledValues: exportedValues,
      );
      await repositoryOn(writer, id: 'payload-2', now: DateTime.utc(2026, 9, 20, 13))
          .savePayload(
        cardId: 'card-1',
        categoryId: 'invite',
        presetId: coffeePreset.id,
        packVersion: '1.0.0',
        filledValues: const <String, String>{'activity': 'cà phê'},
      );
      await writer.close();

      final CupidDatabase reader = openDatabase();
      expect((await repositoryOn(reader).latestForCard('card-1'))!.id,
          'payload-2');
      expect((await repositoryOn(reader).payloadById('payload-1'))!.presetId,
          moviePreset.id);
    });

    test('latestForCard is null for a card that never exported', () async {
      final CupidDatabase reader = openDatabase();
      await reader.activityCardDao.upsertCard(
        ActivityCardsCompanion.insert(
          id: 'card-2',
          ownerKey: 'user-1',
          title: 'Đi bộ',
          origin: 'manual',
          createdAt: DateTime.utc(2026, 9, 1),
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );
      expect(await repositoryOn(reader).latestForCard('card-2'), isNull);
    });

    test('the table carries no recipient or recipient-behaviour column '
        '(AC-19/R-1b)', () async {
      final CupidDatabase reader = openDatabase();
      final rows =
          await reader.customSelect("PRAGMA table_info('invite_messages')").get();
      final Set<String> columns =
          rows.map((row) => row.read<String>('name')).toSet();

      expect(columns, <String>{
        'id',
        'card_id',
        'category_id',
        'preset_id',
        'pack_version',
        'filled_values',
        'user_edited_text',
        'created_at',
      });
      for (final String forbidden in const <String>[
        'recipient',
        'partner',
        'sent',
        'delivered',
        'opened',
        'seen',
        'viewed',
        'read',
        'reply',
        'response',
        'share_result',
        'channel',
      ]) {
        expect(
          columns.where((String column) => column.contains(forbidden)),
          isEmpty,
          reason: 'invite_messages must not track "$forbidden" (R-1b/AC-19)',
        );
      }
    });
  });

  group('no counting surface (R-1e/AC-14)', () {
    /// Source scan rather than a type check: the point is that a count query
    /// must not be *addable* quietly, and a future `countForCard` would compile
    /// fine against the interface. Comment lines are stripped so the doc
    /// comments that explain the ban do not trip their own rule.
    List<String> codeLinesOf(String path) => File(path)
        .readAsLinesSync()
        .where((String line) {
          final String trimmed = line.trimLeft();
          return !trimmed.startsWith('//');
        })
        .toList();

    const List<String> payloadSources = <String>[
      'lib/features/invite_composer/domain/invite_payload_repository.dart',
      'lib/features/invite_composer/data/invite_payload_repository_impl.dart',
      'lib/core/database/daos/invite_message_dao.dart',
    ];

    for (final String path in payloadSources) {
      test('$path declares no aggregate, count, or ranking query', () {
        final List<String> lines = codeLinesOf(path);
        expect(lines, isNotEmpty, reason: '$path must exist and have code');
        for (final String forbidden in const <String>[
          'count',
          'rank',
          'score',
          'aggregate',
          'histogram',
          'groupby',
          'selectonly',
          'allpayloads',
        ]) {
          expect(
            lines.where(
                (String line) => line.toLowerCase().contains(forbidden)),
            isEmpty,
            reason: '$path must expose no "$forbidden" surface (R-1e/AC-14)',
          );
        }
      });
    }

    test('the repository interface exposes exactly three members', () {
      // A structural companion to the source scan: implementing the interface
      // with these three and nothing else has to keep compiling.
      final InvitePayloadRepository repository = _MinimalRepository();
      expect(repository, isA<InvitePayloadRepository>());
    });
  });
}

class _MinimalRepository implements InvitePayloadRepository {
  @override
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  }) async =>
      throw UnimplementedError();

  @override
  Future<InvitePayload?> latestForCard(String cardId) async => null;

  @override
  Future<InvitePayload?> payloadById(String id) async => null;
}
