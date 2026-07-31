import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/database/daos/timeline_dao.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/create_memory_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n_en.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the `timeline_cubit_test.dart`/`timeline_screen_test.dart` fake
/// transport: a real [TimelineRepository] over a real in-memory Drift
/// database, with the [Dio] transport swapped for a handler-driven fake so
/// no live network call is made.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);
}

ResponseBody _jsonResponse(Object? body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

TimelineRemoteDataSource _remoteWithHandler(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return TimelineRemoteDataSource(api);
}

TimelineRemoteDataSource _remoteAlwaysFailing(
  DioExceptionType type, {
  int? statusCode,
}) {
  return _remoteWithHandler((RequestOptions options) async {
    throw DioException(
      requestOptions: options,
      type: type,
      response: statusCode != null
          ? Response(requestOptions: options, statusCode: statusCode)
          : null,
    );
  });
}

/// A harness exposing a self-contained "Add a memory" affordance labeled
/// with the real `timeline_add_memory_cta` string, mirroring the P5 CTA's
/// label. `TimelineScreen`'s own wiring of this affordance is covered by
/// `timeline_screen_test.dart`; this harness isolates the sheet itself so
/// these tests don't depend on `TimelineCubit`/`TimelineScreen` state.
Widget _harness({
  required TimelineRepository repository,
  bool Function() isOffline = _online,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Builder(
      builder: (BuildContext context) {
        final AppL10n l10n = AppL10n.of(context);
        return Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => CreateMemorySheet.show(
                context,
                repository: repository,
                isOffline: isOffline,
              ),
              child: Text(l10n.timeline_add_memory_cta),
            ),
          ),
        );
      },
    ),
  );
}

bool _online() => false;

void main() {
  late db.CupidDatabase database;
  late db.TimelineDao dao;
  late AppL10n l10n;

  setUp(() {
    database = db.CupidDatabase(NativeDatabase.memory());
    dao = database.timelineDao;
    l10n = AppL10nEn();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> openSheet(WidgetTester tester, TimelineRepository repository, {
    bool Function() isOffline = _online,
  }) async {
    await tester.pumpWidget(
      _harness(repository: repository, isOffline: isOffline),
    );
    await tester.tap(find.text(l10n.timeline_add_memory_cta));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the sheet is reachable from an Add-a-memory-labeled affordance',
    (WidgetTester tester) async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((_) async => _jsonResponse(<Object?>[], 200)),
      );

      await openSheet(tester, repository);

      expect(find.text(l10n.timeline_sheet_field_title_label), findsOneWidget);
      expect(find.text(l10n.timeline_sheet_save_label), findsOneWidget);
    },
  );

  testWidgets(
    'empty title blocks submit with inline validation and no network call',
    (WidgetTester tester) async {
      int postCount = 0;
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((RequestOptions options) async {
          if (options.method == 'POST') postCount++;
          return _jsonResponse(<Object?>[], 200);
        }),
      );

      await openSheet(tester, repository);
      await tester.tap(find.text(l10n.timeline_sheet_save_label));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.timeline_sheet_validation_title_required),
        findsOneWidget,
      );
      expect(postCount, 0);
    },
  );

  testWidgets(
    'Save is disabled with explanatory copy while the timeline is known to '
    'be offline',
    (WidgetTester tester) async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((_) async => _jsonResponse(<Object?>[], 200)),
      );

      await openSheet(tester, repository, isOffline: () => true);

      expect(find.text(l10n.timeline_sheet_offline_blocked), findsOneWidget);
      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    },
  );

  testWidgets(
    'a submit that fails on connectivity preserves input, shows the retry '
    'copy, and writes no Drift row',
    (WidgetTester tester) async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.connectionError),
      );

      await openSheet(tester, repository);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Preserved title',
      );
      await tester.tap(find.text(l10n.timeline_sheet_save_label));
      await tester.pumpAndSettle();

      expect(find.text('Preserved title'), findsOneWidget);
      expect(find.text(l10n.timeline_sheet_offline_blocked), findsOneWidget);
      expect(find.text(l10n.timeline_sheet_save_label), findsOneWidget);
      expect(await database.select(database.timelineEntries).get(), isEmpty);
    },
  );

  testWidgets('a 404 renders the pairing-required message', (
    WidgetTester tester,
  ) async {
    final TimelineRepository repository = TimelineRepository(
      dao,
      _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 404),
    );

    await openSheet(tester, repository);
    await tester.enterText(find.byType(TextFormField).first, 'Unpaired');
    await tester.tap(find.text(l10n.timeline_sheet_save_label));
    await tester.pumpAndSettle();

    expect(find.text(l10n.timeline_sheet_pairing_required), findsOneWidget);
    expect(await database.select(database.timelineEntries).get(), isEmpty);
  });

  testWidgets(
    'success writes the created entry through the Drift stream and closes '
    'the sheet',
    (WidgetTester tester) async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((RequestOptions options) async {
          if (options.method == 'POST') {
            return _jsonResponse(null, 201);
          }
          return _jsonResponse(<Object?>[
            {
              'id': 'ev-new',
              'type': 'memory',
              'title': 'First date',
              'createdAt': '2026-06-01T00:00:00.000Z',
            },
          ], 200);
        }),
      );

      final List<List<TimelineEntry>> emissions = <List<TimelineEntry>>[];
      final subscription = repository.watchEntries().listen(emissions.add);
      addTearDown(subscription.cancel);

      await openSheet(tester, repository);
      await tester.enterText(find.byType(TextFormField).first, 'First date');
      await tester.tap(find.text(l10n.timeline_sheet_save_label));
      await tester.pumpAndSettle();

      expect(find.text(l10n.timeline_sheet_save_label), findsNothing);
      expect(
        emissions.last.map((TimelineEntry entry) => entry.title),
        <String>['First date'],
      );
    },
  );
}
