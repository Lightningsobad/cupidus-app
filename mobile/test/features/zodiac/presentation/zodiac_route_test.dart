import 'dart:async';
import 'dart:io';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_cubit.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_red_flag_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'zodiac_screen_fixtures.dart';

/// Mirrors `test/app/cupid_app_entry_routing_test.dart`'s harness: both
/// injection points are supplied so the launch path never reaches `getIt`,
/// leaving [ZodiacCubit] as the only registration this suite makes.
class _Harness {
  _Harness() : controller = StreamController<CupidSessionState>();

  final StreamController<CupidSessionState> controller;

  Widget build() => CupidApp(
    createSessionGateCubit: () => SessionGateCubit(
      sessionState: controller.stream,
      idToken: ({bool forceRefresh = false}) async => 'token',
    ),
    createPairGateCubit: () => PairGateCubit(
      getPartnerLink: () async => const PartnerLink(partnerId: null),
    ),
  );
}

Future<void> _launchAuthenticated(
  WidgetTester tester,
  _Harness harness,
) async {
  await tester.pumpWidget(harness.build());
  harness.controller.add(
    const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'),
  );
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

List<File> _zodiacSources() =>
    Directory('lib/features/zodiac')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList();

void main() {
  // REQ-016 STORY-001 P9: this harness declares an unpaired session, which now
  // lands on the solo card hub instead of the pairing stack. The hub resolves
  // its repository through the composition root, so the launch path needs one
  // registered even though this suite only asserts zodiac routing. An
  // in-memory database keeps that off disk and off the network; mirrors
  // `test/core/navigation/pair_gate_shell_test.dart`.
  setUp(() {
    final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
      ..updateFromLoginResponse(<String, Object?>{'id': 'u1'});
    final CupidDatabase activityDatabase = CupidDatabase(
      NativeDatabase.memory(),
    );
    getIt.registerSingleton<CupidDatabase>(
      activityDatabase,
      dispose: (CupidDatabase database) => database.close(),
    );
    getIt.registerSingleton<ActivityCardRepository>(
      ActivityCardRepositoryImpl(
        dao: ActivityCardDao(activityDatabase),
        ownerKeyStore: backendUserIdStore,
      ),
    );
  });

  tearDown(() => getIt.reset());

  group('ZodiacRedFlagScreen.routeName (P3 §1B)', () {
    testWidgets('is registered on CupidApp and reachable with pushNamed', (
      WidgetTester tester,
    ) async {
      final _Harness harness = _Harness();
      addTearDown(harness.controller.close);

      getIt.registerFactory<ZodiacCubit>(
        () => ZodiacCubit(repository: FakeZodiacRepository.ready()),
      );
      addTearDown(() => getIt.unregister<ZodiacCubit>());

      await _launchAuthenticated(tester, harness);
      expect(find.byType(ZodiacRedFlagScreen), findsNothing);

      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      unawaited(navigator.pushNamed(ZodiacRedFlagScreen.routeName));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ZodiacRedFlagScreen), findsOneWidget);
      expect(find.text(kZodiacReadyFixture.conflictIndex.headline),
          findsOneWidget);
    });

    testWidgets('the route map never shadows `home:` with a `/` entry', (
      WidgetTester tester,
    ) async {
      final _Harness harness = _Harness();
      addTearDown(harness.controller.close);

      await tester.pumpWidget(harness.build());
      await tester.pump();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.home, isNotNull);
      expect(app.routes!.containsKey('/'), isFalse);
      expect(app.routes!.containsKey(ZodiacRedFlagScreen.routeName), isTrue);
    });
  });

  group('preview canvas registry (P3 §1C)', () {
    test('`zodiac` is no longer listed as a not-implemented canvas id', () {
      final String source = File('lib/main_preview.dart').readAsStringSync();
      const String marker = '_notImplementedCanvasIds = <String>[';
      final int start = source.indexOf(marker);
      expect(start, isNot(-1));
      final int end = source.indexOf('];', start);
      final String block = source.substring(start + marker.length, end);

      expect(block.contains("'zodiac'"), isFalse);
      expect(source.contains("'zodiac': const PreviewScreenEntry("), isTrue);
    });
  });

  group('zodiac feature source guards', () {
    test('no Unicode zodiac glyph is used anywhere in the feature', () {
      // U+2648..U+2653. `CupidZodiacIcon` is the only sanctioned renderer;
      // a text glyph would silently lose the element colour coding and the
      // design source\'s geometry.
      final RegExp glyph = RegExp(r'[♈-♓]');
      for (final File file in _zodiacSources()) {
        expect(
          glyph.hasMatch(file.readAsStringSync()),
          isFalse,
          reason: '${file.path} contains a Unicode zodiac glyph',
        );
      }
    });

    test('no raw hex colour is declared in the feature', () {
      final RegExp rawColor = RegExp(r'Color(\.fromRGBO|\.fromARGB)?\(0x|#[0-9a-fA-F]{6}');
      for (final File file in _zodiacSources()) {
        expect(
          rawColor.hasMatch(file.readAsStringSync()),
          isFalse,
          reason: '${file.path} declares a raw colour instead of a token',
        );
      }
    });
  });
}
