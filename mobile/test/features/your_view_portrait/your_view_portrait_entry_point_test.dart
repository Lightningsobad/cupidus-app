import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/your_view_portrait/your_view_portrait_entry_point.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase P5: the one door onto the portrait, exercised the way screen (5)
/// opens it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CupidDatabase database;

  final GlobalKey<NavigatorState> rootNavigator = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> flowNavigator = GlobalKey<NavigatorState>();

  setUp(() {
    // The door resolves its own storage from the composition root, so this is
    // the production wiring rather than an injected seam.
    database = CupidDatabase(NativeDatabase.memory());
    getIt
      ..registerSingleton<CupidDatabase>(database)
      ..registerSingleton<BackendUserIdStore>(
        BackendUserIdStore()..updateUserId('user-1'),
      );

    // The screen loads its packs through `rootBundle`, which a widget test
    // ships empty. Serving the shipped files off disk keeps the door under
    // test identical to the shipped one. `clear()` matters: a cached bundle
    // entry created in an earlier test's fake-async zone never completes in
    // this one.
    rootBundle.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final String key = utf8.decode(message!.buffer.asUint8List());
      final File file = File(key);
      if (!file.existsSync()) {
        return null;
      }
      return ByteData.sublistView(file.readAsBytesSync());
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    rootBundle.clear();
    await getIt.reset();
    await database.close();
  });

  Future<void> pumpSourceFlow(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        navigatorKey: rootNavigator,
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        home: CupidPlatformOverride(
          platform: CupidPlatform.material,
          child: Scaffold(
            body: Navigator(
              key: flowNavigator,
              onGenerateRoute: (RouteSettings _) => MaterialPageRoute<void>(
                builder: (BuildContext _) => const _SourceFlow(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the guess row door opens the portrait and comes back whole',
      (WidgetTester tester) async {
    await pumpSourceFlow(tester);

    // Progress the source flow has, that closing the portrait must not cost.
    await tester.tap(find.byKey(const Key('source-flow-bump')));
    await tester.pump();
    expect(find.text('đã chọn: 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('source-flow-open')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('portrait-provenance')), findsOneWidget);

    await tester.tap(find.byIcon(CupidIcons.arrowBack));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('portrait-provenance')), findsNothing);
    expect(find.byKey(const Key('source-flow-open')), findsOneWidget);
    // Intact, not rebuilt from scratch (AC-4).
    expect(find.text('đã chọn: 1'), findsOneWidget);
  });

  testWidgets('it pushes on the source flow navigator, never the root one',
      (WidgetTester tester) async {
    await pumpSourceFlow(tester);

    expect(flowNavigator.currentState!.canPop(), isFalse);

    await tester.tap(find.byKey(const Key('source-flow-open')));
    await tester.pumpAndSettle();

    // Pushed, so the source flow can pop back to itself; the root stack is
    // untouched, which is what `pushReplacement`/`rootNavigator: true` would
    // have broken.
    expect(flowNavigator.currentState!.canPop(), isTrue);
    expect(rootNavigator.currentState!.canPop(), isFalse);
  });
}

class _SourceFlow extends StatefulWidget {
  const _SourceFlow();

  @override
  State<_SourceFlow> createState() => _SourceFlowState();
}

class _SourceFlowState extends State<_SourceFlow> {
  int _picked = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('đã chọn: $_picked'),
          TextButton(
            key: const Key('source-flow-bump'),
            onPressed: () => setState(() => _picked++),
            child: const Text('chọn'),
          ),
          TextButton(
            key: const Key('source-flow-open'),
            onPressed: () => openYourViewPortrait(
              context,
              from: PortraitEntrySource.giftIdeas,
            ),
            child: const Text('mở'),
          ),
        ],
      ),
    );
  }
}
