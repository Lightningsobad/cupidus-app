import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/gift_ideas/data/gift_repository.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_content.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_selector.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';

/// The gift feature's whole source tree, scanned as text by the guard tests
/// below.
const String _giftSourceDirectory = 'lib/features/gift_ideas';

/// Widget-free tests ship no asset bundle, so the real packs are read straight
/// off disk. Reading the shipped files rather than a fixture is the point: the
/// integration test must fail if an author's pack stops resolving.
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

class _RepositoryReader implements ContextNotebookReader {
  const _RepositoryReader(this._repository);

  final ContextNotebookRepository _repository;

  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) =>
      _repository.entries(kind: kind);

  @override
  Future<List<SkillEntry>> skills() => _repository.skills();
}

List<String> _idsOf(List<GiftSuggestion> suggestions) =>
    suggestions.map((GiftSuggestion s) => s.idea.id).toList(growable: false);

List<File> _giftSourceFiles() =>
    Directory(_giftSourceDirectory)
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false)
      ..sort((File a, File b) => a.path.compareTo(b.path));

void main() {
  const GiftSelector selector = GiftSelector();

  late CupidDatabase database;
  late ContextNotebookRepository notebook;
  late GiftRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    notebook = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
    repository = GiftRepository(
      notebook: _RepositoryReader(notebook),
      loader: ContentPackageLoader(bundle: _DiskBundle()),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('đọc ba gói đã ship', () {
    test('the shipped packs load and expose their taxonomy as data', () async {
      final GiftCatalogue catalogue = await repository.catalogue();

      expect(catalogue.gifts.items, isNotEmpty);
      expect(catalogue.giftIndex.items, isNotEmpty);
      expect(
        catalogue.branches.map((GiftTaxonomyItem item) => item.id),
        containsAll(requiredGiftBranchIds),
      );
      expect(catalogue.effortTiers, isNotEmpty);
      expect(
        catalogue.effortTiers.every(
          (GiftTaxonomyItem tier) => tier.maxMinutes != null,
        ),
        isTrue,
      );
    });

    test('the catalogue is parsed once and handed back as the same value',
        () async {
      expect(
        identical(await repository.catalogue(), await repository.catalogue()),
        isTrue,
      );
    });
  });

  group('đọc kho ngữ cảnh thật (AC-15, AC-28)', () {
    test('a fresh owner reads an empty snapshot and still gets suggestions',
        () async {
      final GiftContextSnapshot context = await repository.context();

      expect(context.isEmpty, isTrue);
      expect(
        selector.suggest(
          catalogue: await repository.catalogue(),
          context: context,
        ),
        isNotEmpty,
      );
    });

    test('what the user wrote reaches the selector and lifts the right ideas',
        () async {
      await notebook.addEntry(
        kind: NotebookKind.event,
        value: 'sinh nhật',
        source: ContextEntrySource.askOnTheSpot,
        eventOn: '2026-11-02',
        questionId: 'ask.birthday.v1',
      );

      final GiftCatalogue catalogue = await repository.catalogue();
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: catalogue,
        context: await repository.context(),
      );

      expect(ranked.first.matches, isNotEmpty);
      expect(ranked.first.matches.first.context.label, 'sinh nhật');
      expect(ranked.first.score, greaterThan(ranked.last.score));
    });

    test('a seed skill matches by its durable id, typed text does not',
        () async {
      await notebook.addSkill(
        label: 'gói quà đẹp',
        source: ContextEntrySource.manual,
        seedId: 'skill.goi_qua_dep.v1',
      );
      await notebook.addSkill(
        label: 'skill.goi_qua_dep.v1',
        source: ContextEntrySource.manual,
      );

      final GiftContextSnapshot context = await repository.context();

      expect(context.values, hasLength(1));
      expect(context.values.single.kind, GiftContextKind.skill);
      expect(context.values.single.key, 'skill.goi_qua_dep.v1');
      expect(context.values.single.label, 'gói quà đẹp');
    });

    test('the same recorded state ranks the same way on a second read',
        () async {
      await notebook.addEntry(
        kind: NotebookKind.interest,
        value: 'nấu ăn',
        source: ContextEntrySource.manual,
      );
      await notebook.addEntry(
        kind: NotebookKind.event,
        value: 'kỷ niệm ngày quen nhau',
        source: ContextEntrySource.manual,
      );
      await notebook.addSkill(
        label: 'nhớ dai',
        source: ContextEntrySource.manual,
        seedId: 'skill.nho_dai.v1',
      );

      final GiftCatalogue catalogue = await repository.catalogue();
      final List<String> first = _idsOf(
        selector.suggest(
          catalogue: catalogue,
          context: await repository.context(),
        ),
      );
      final List<String> second = _idsOf(
        selector.suggest(
          catalogue: catalogue,
          context: await repository.context(),
        ),
      );

      expect(first, second);
      expect(first, isNotEmpty);
    });

    test('the handmade branch answers an empty skill profile (AC-13)',
        () async {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: await repository.catalogue(),
        context: await repository.context(),
        filter: const GiftFilter(branchId: 'handmade'),
      );

      expect(ranked, isNotEmpty);
      expect(ranked.every((GiftSuggestion s) => s.idea.isHandmade), isTrue);
    });

    test('an entry added mid-session is visible on the next read', () async {
      expect((await repository.context()).isEmpty, isTrue);

      await notebook.addEntry(
        kind: NotebookKind.interest,
        value: 'âm nhạc',
        source: ContextEntrySource.askOnTheSpot,
        questionId: 'ask.interest.v1',
      );

      expect((await repository.context()).values, hasLength(1));
    });
  });

  group('không mọc kho thứ hai, không nguồn ngẫu nhiên (AC-17, AC-18, AC-28)',
      () {
    test('the gift feature declares no store of its own', () {
      final Map<String, List<String>> offenders = <String, List<String>>{};

      for (final File file in _giftSourceFiles()) {
        final String source = file.readAsStringSync();
        final List<String> hits = <String>[
          // A local schema, a data-access object, or the ORM itself would be
          // the second store `contract-summary.md` §6 forbids.
          for (final String token in <String>['Table', 'DAO', 'Dao', 'drift'])
            if (source.contains(token)) token,
          // A clock or a randomness source would break the "same input, same
          // list" promise of AC-28.
          for (final String token in <String>[
            'Random',
            'DateTime.now',
            'Stopwatch',
          ])
            if (source.contains(token)) token,
          // No network and no model call on any path (R-7, BR-8).
          for (final String token in <String>[
            'dart:io',
            'package:dio',
            'package:http',
            'HttpClient',
            'cupid_api',
          ])
            if (source.contains(token)) token,
          // A saved-gift list is the second hub SC-1'/AC-22 rules out.
          for (final String token in <String>['savedGift', 'saved_gift'])
            if (source.contains(token)) token,
        ];

        if (hits.isNotEmpty) {
          offenders[file.path] = hits;
        }
      }

      expect(offenders, isEmpty, reason: 'forbidden constructs: $offenders');
    });

    test('the scan actually reaches the files it claims to cover', () {
      final List<String> scanned = _giftSourceFiles()
          .map((File file) => file.path)
          .toList(growable: false);

      expect(scanned, isNotEmpty);
      expect(
        scanned,
        containsAll(<String>[
          '$_giftSourceDirectory/data/gift_repository.dart',
          '$_giftSourceDirectory/domain/gift_selector.dart',
        ]),
      );
    });
  });

  group('xuất xứ check-in không rò sang mặt quà (REQ-017 AC-10)', () {
    test('an entry written by a check-in reaches the snapshot as its value only',
        () async {
      await notebook.recordFromCheckIn(
        kind: NotebookKind.interest,
        value: 'cà phê muối',
        originCheckInRef: 'checkin-2026-09-27',
        cardId: 'card-1',
        cardTitle: 'Đi cà phê tối',
      );

      final GiftContextSnapshot context = await repository.context();

      // Exactly the text the user wrote, on both fields. The origin is
      // notebook-screen chrome: no card title, no check-in reference and no
      // origin wording may travel with the row to this surface.
      expect(context.values, hasLength(1));
      expect(context.values.single.key, 'cà phê muối');
      expect(context.values.single.label, 'cà phê muối');
      expect(context.values.single.kind, GiftContextKind.interest);

      final String carried =
          '${context.values.single.key}\n${context.values.single.label}';
      expect(carried, isNot(contains('Đi cà phê tối')));
      expect(carried, isNot(contains('checkin-2026-09-27')));
    });

    test('no gift source file can read an origin column at all', () {
      final Map<String, List<String>> offenders = <String, List<String>>{};
      for (final File file in _giftSourceFiles()) {
        final String source = file.readAsStringSync();
        final List<String> hits = <String>[
          for (final String token in <String>[
            'originCheckInRef',
            'originCardId',
            'originCardTitle',
            'origin_check_in_ref',
            'origin_card_id',
            'origin_card_title',
            'originLabel',
            'CheckinOriginResolver',
          ])
            if (source.contains(token)) token,
        ];
        if (hits.isNotEmpty) {
          offenders[file.path] = hits;
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'the gift surface must not reach the origin columns: $offenders',
      );
    });
  });
}
