import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/presentation/screens/me_screen.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/domain/journal_entry.dart';
import 'package:cupid_mobile/features/journal/presentation/screens/journal_screen.dart';
import 'package:cupid_mobile/features/themes/data/themes_repository.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(json)),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _profileJson() => <String, dynamic>{
  'id': 'user-1',
  'email': 'alex@example.com',
  'displayName': 'Alex',
  'photoUrl': null,
  'birthday': '1996-05-15',
  'relationshipStartDate': null,
  'zodiacSign': 'Taurus',
  'language': 'vi',
  'partnerId': null,
  'coupleType': null,
  'vowTaken': false,
  'isGhostModeEnabled': true,
};

CupidApi _api(ResponseBody Function(RequestOptions options) handler) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _FakeAdapter(handler)
    ..interceptors.add(const CupidErrorInterceptor());
  return CupidApi(dio: dio, interceptors: const <Interceptor>[]);
}

/// `watchEntries` is a live drift query stream whose cancellation schedules a
/// timer that outlives the disposed tree, which `testWidgets` fails on. This
/// test only cares that the menu row reaches the journal, so the stream is
/// stubbed and everything else stays real.
class _QuietJournalRepository extends JournalRepository {
  _QuietJournalRepository({
    required super.database,
    required super.mediaStore,
    required super.backendUserIdStore,
  });

  @override
  Stream<List<JournalEntry>> watchEntries({int limit = 50, int offset = 0}) =>
      Stream<List<JournalEntry>>.value(const <JournalEntry>[]);

  @override
  Future<void> sweepOrphans() async {}
}

void main() {
  late db.CupidDatabase database;
  late Directory mediaDir;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = db.CupidDatabase(NativeDatabase.memory());
    mediaDir = Directory.systemTemp.createTempSync('me_screen_journal_row');

    final JournalMediaStore mediaStore = JournalMediaStore(
      baseDirectory: () async => mediaDir,
    );
    getIt.registerSingleton<JournalMediaStore>(mediaStore);
    getIt.registerSingleton<JournalRepository>(
      _QuietJournalRepository(
        database: database,
        mediaStore: mediaStore,
        backendUserIdStore: BackendUserIdStore()..updateUserId('user-1'),
      ),
    );
    getIt.registerLazySingleton<NotificationPreferencesStore>(
      NotificationPreferencesStore.new,
    );
    getIt.registerLazySingleton<ThemesRepository>(
      () => ThemesRepository(
        api: _api(
          (RequestOptions options) => _jsonBody(<String, dynamic>{
            'coupleId': 'userA:userB',
            'activeThemeId': 'nebula',
            'ownedThemeIds': <String>['nebula'],
            'heartsBalance': 1000,
          }),
        ),
      ),
    );
  });

  tearDown(() async {
    getIt.unregister<ThemesRepository>();
    getIt.unregister<NotificationPreferencesStore>();
    getIt.unregister<JournalRepository>();
    getIt.unregister<JournalMediaStore>();
    await database.close();
    if (mediaDir.existsSync()) {
      mediaDir.deleteSync(recursive: true);
    }
  });

  Widget harness() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: MeScreen(
        accountRepository: AccountRepository(
          api: _api((RequestOptions options) => _jsonBody(_profileJson())),
        ),
      ),
    );
  }

  group('MeScreen private storage block', () {
    testWidgets('renders exactly one private journal row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('My private storage'), findsOneWidget);
      expect(find.text('Private journal'), findsOneWidget);
    });

    testWidgets('tapping the row opens the journal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Private journal'));
      await tester.pumpAndSettle();

      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets(
      'the journal is a route of its own, not a tab the hub switches to',
      (WidgetTester tester) async {
        await tester.pumpWidget(harness());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Private journal'));
        await tester.pumpAndSettle();

        // AC-17: the hub stays underneath on the navigator stack and the back
        // affordance returns to it, rather than the journal replacing a tab.
        expect(find.byType(MeScreen, skipOffstage: false), findsOneWidget);
        expect(find.byType(TabBar), findsNothing);

        await tester.tap(find.byIcon(CupidIcons.arrowBack));
        await tester.pumpAndSettle();

        expect(find.byType(JournalScreen), findsNothing);
        expect(find.text('Private journal'), findsOneWidget);
      },
    );
  });
}
