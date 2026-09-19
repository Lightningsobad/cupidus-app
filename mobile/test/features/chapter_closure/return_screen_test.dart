import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_last_opened_store.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_wipe_service.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/return_gate_resolver.dart';
import 'package:cupid_mobile/features/chapter_closure/presentation/screens/return_screen.dart';
import 'package:cupid_mobile/features/chapter_closure/presentation/widgets/wipe_confirm_dialog.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phrases J13 and its confirmation must never contain: a reference to the
/// absence, a loss frame, a retention offer, a ranking hint
/// (`ux/uiux-spec.md` §2, AC-20, AC-21, AC-22, AC-28).
const List<String> _forbidden = <String>[
  'ngày',
  'tuần',
  'tháng',
  'lâu',
  'vắng',
  'quay lại',
  'trở lại',
  'chuỗi',
  'bỏ quên',
  'cũ',
  'tiếc quá',
  'buồn',
  'nhớ',
  'chắc chắn không đổi ý',
  'để lại một lời nhắn',
  'thử nhắn lại',
  'nên làm trước',
  'gợi ý',
  'đề xuất',
  'mở lại ngay',
];

class _RecordingWipeService implements Stage1WipeService {
  int purgeClosedCalls = 0;
  int wipeAllCalls = 0;

  @override
  Future<void> purgeClosed() async => purgeClosedCalls++;

  @override
  Future<void> wipeAll() async => wipeAllCalls++;
}

/// Parks the shell on [PairGateChecking] forever, so landing on
/// [PairGateShell] is observable without dragging the home tree's `getIt`
/// dependencies into this file.
PairGateCubit _parkedPairGateCubit() =>
    PairGateCubit(getPartnerLink: () => Completer<PartnerLink>().future);

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
    child: child,
  ),
);

Future<_RecordingWipeService> _pump(WidgetTester tester) async {
  final _RecordingWipeService wipe = _RecordingWipeService();
  await tester.pumpWidget(
    _host(
      ReturnScreen(
        wipeService: wipe,
        createPairGateCubit: _parkedPairGateCubit,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return wipe;
}

/// Not `pumpAndSettle`: the parked shell spins forever on [PairGateChecking],
/// so settling would never terminate. Two pumps clear the route transition.
Future<void> _pumpTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

/// Stands in for the real gate so the splash branch can be driven without a
/// preference store, and so `markOpened` is observable.
class _CountingResolver extends ReturnGateResolver {
  _CountingResolver({required this.shouldShowValue})
    : super(
        store: Stage1LastOpenedStore(
          preferences: () => throw UnimplementedError(),
        ),
      );

  final bool shouldShowValue;
  int markOpenedCalls = 0;

  @override
  Future<bool> shouldShow() async => shouldShowValue;

  @override
  Future<void> markOpened() async => markOpenedCalls++;
}

Widget _splashHost(
  StreamController<CupidSessionState> session,
  ReturnGateResolver resolver,
) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: SplashScreen(
    returnGateResolver: resolver,
    createSessionGateCubit: () => SessionGateCubit(
      sessionState: session.stream,
      idToken: ({bool forceRefresh = false}) async => 'token',
    ),
    createPairGateCubit: _parkedPairGateCubit,
  ),
);

/// Clears splash's 2s minimum dwell, the async gate lookup, and the route
/// transition. Not `pumpAndSettle`: both destinations animate or spin forever.
Future<void> _pumpSplashHandoff(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  for (int i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

List<String> _visibleStrings(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text text) => text.data ?? '')
    .where((String value) => value.isNotEmpty)
    .toList();

void main() {
  group('ReturnScreen layout (AC-21, AC-22, `ux/uiux-spec.md` §6)', () {
    testWidgets('shows a neutral greeting, one lead line, and three choices', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      expect(find.text('Chào bạn'), findsOneWidget);
      expect(find.text('Bạn muốn bắt đầu từ đâu?'), findsOneWidget);
      for (final Key key in returnScreenChoiceKeys) {
        expect(find.byKey(key), findsOneWidget);
      }
      expect(returnScreenChoiceKeys.length, 3);
    });

    testWidgets('draws all three choices at the same size and weight', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      final List<Size> sizes = returnScreenChoiceKeys
          .map((Key key) => tester.getSize(find.byKey(key)))
          .toList();
      expect(sizes[1], sizes[0]);
      expect(sizes[2], sizes[0]);

      final Set<FontWeight?> weights = returnScreenChoices
          .map(
            (List<String> pair) =>
                tester.widget<Text>(find.text(pair.first)).style?.fontWeight,
          )
          .toSet();
      expect(weights, hasLength(1));
    });

    testWidgets('carries no forbidden phrase on the screen or in the dialog', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final List<String> screenStrings = _visibleStrings(tester);

      await tester.tap(find.byKey(returnScreenWipeLinkKey));
      await tester.pumpAndSettle();
      final List<String> allStrings = <String>[
        ...screenStrings,
        ..._visibleStrings(tester),
      ];

      for (final String phrase in _forbidden) {
        for (final String rendered in allStrings) {
          expect(
            rendered.toLowerCase(),
            isNot(contains(phrase)),
            reason: '"$rendered" contains the forbidden phrase "$phrase"',
          );
        }
      }
    });

    testWidgets('gives the close icon a full tap target (≥44pt)', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      final Size closeSize = tester.getSize(find.byKey(returnScreenCloseKey));
      expect(closeSize.width, greaterThanOrEqualTo(44));
      expect(closeSize.height, greaterThanOrEqualTo(44));
    });

    testWidgets('separates the wipe link from the last choice by at least lg', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      final double lastChoiceBottom = tester
          .getRect(find.byKey(returnScreenChoiceKeys.last))
          .bottom;
      final double linkTop = tester
          .getRect(find.byKey(returnScreenWipeLinkKey))
          .top;
      expect(linkTop - lastChoiceBottom, greaterThanOrEqualTo(CupidSpacing.lg));
    });
  });

  group('every exit leaves for a usable screen (AC-24, AC-30)', () {
    for (int i = 0; i < returnScreenChoiceKeys.length; i++) {
      testWidgets('choice ${i + 1} replaces the screen with the app root', (
        WidgetTester tester,
      ) async {
        await _pump(tester);

        await tester.tap(find.byKey(returnScreenChoiceKeys[i]));
        await _pumpTransition(tester);

        expect(find.byType(PairGateShell), findsOneWidget);
        expect(find.byKey(returnScreenKey), findsNothing);
      });
    }

    testWidgets('the close icon behaves exactly like a choice', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byKey(returnScreenCloseKey));
      await _pumpTransition(tester);

      expect(find.byType(PairGateShell), findsOneWidget);
      expect(find.byKey(returnScreenKey), findsNothing);
    });

    testWidgets('the screen cannot be popped back to', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byKey(returnScreenChoiceKeys.first));
      await _pumpTransition(tester);
      final NavigatorState navigator = tester.state(find.byType(Navigator));

      expect(navigator.canPop(), isFalse);
    });
  });

  group('wipe (AC-25, AC-26, AC-28, AC-29)', () {
    testWidgets('one confirmation wipes and lands on the first-run state', (
      WidgetTester tester,
    ) async {
      final _RecordingWipeService wipe = await _pump(tester);

      await tester.tap(find.byKey(returnScreenWipeLinkKey));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wipe_confirm_dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('wipe_confirm_accept')));
      await _pumpTransition(tester);
      await _pumpTransition(tester);

      expect(wipe.wipeAllCalls, 1);
      expect(find.byKey(const Key('wipe_confirm_dialog')), findsNothing);
      expect(find.byType(PairGateShell), findsOneWidget);
      expect(find.byKey(returnScreenKey), findsNothing);
    });

    testWidgets('cancelling wipes nothing and keeps the screen', (
      WidgetTester tester,
    ) async {
      final _RecordingWipeService wipe = await _pump(tester);

      await tester.tap(find.byKey(returnScreenWipeLinkKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wipe_confirm_cancel')));
      await tester.pumpAndSettle();

      expect(wipe.wipeAllCalls, 0);
      expect(find.byKey(returnScreenKey), findsOneWidget);
    });

    testWidgets('the confirmation asks nothing and offers exactly two actions', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byKey(returnScreenWipeLinkKey));
      await tester.pumpAndSettle();

      final Finder dialog = find.byKey(const Key('wipe_confirm_dialog'));
      final List<String> lines = tester
          .widgetList<Text>(
            find.descendant(of: dialog, matching: find.byType(Text)),
          )
          .map((Text text) => text.data ?? '')
          .toList();

      // The title is the only line allowed to end in a question mark, and it
      // asks for the decision itself rather than for a reason (AC-28).
      expect(lines.where((String line) => line.contains('?')), hasLength(1));
      expect(find.byKey(const Key('wipe_confirm_cancel')), findsOneWidget);
      expect(find.byKey(const Key('wipe_confirm_accept')), findsOneWidget);
      expect(find.byKey(const Key('wipe_confirm_fact_0')), findsOneWidget);
      expect(find.byKey(const Key('wipe_confirm_fact_1')), findsOneWidget);
      expect(wipeConfirmFacts, hasLength(2));
      expect(wipeConfirmFacts[1].first, contains('Không hoàn tác được'));
    });
  });

  group('reached through splash, not built directly (AC-18, AC-24)', () {
    testWidgets('an authenticated launch past the threshold lands on J13', (
      WidgetTester tester,
    ) async {
      final _CountingResolver resolver = _CountingResolver(shouldShowValue: true);
      final StreamController<CupidSessionState> session =
          StreamController<CupidSessionState>();
      addTearDown(session.close);

      await tester.pumpWidget(_splashHost(session, resolver));
      session.add(const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'));
      await _pumpSplashHandoff(tester);

      expect(find.byKey(returnScreenKey), findsOneWidget);
      expect(find.byType(PairGateShell), findsNothing);
      // The mark is refreshed on the same launch, so the gate is one-shot: the
      // next launch is below threshold and J13 cannot reappear (AC-24).
      expect(resolver.markOpenedCalls, 1);
    });

    testWidgets('an authenticated launch below the threshold keeps the old '
        'route', (WidgetTester tester) async {
      final _CountingResolver resolver = _CountingResolver(
        shouldShowValue: false,
      );
      final StreamController<CupidSessionState> session =
          StreamController<CupidSessionState>();
      addTearDown(session.close);

      await tester.pumpWidget(_splashHost(session, resolver));
      session.add(const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'));
      await _pumpSplashHandoff(tester);

      expect(find.byType(PairGateShell), findsOneWidget);
      expect(find.byKey(returnScreenKey), findsNothing);
      expect(resolver.markOpenedCalls, 1);
    });
  });

  group('visual fidelity', () {
    testWidgets('captures the implemented J13 at the reference viewport', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = _referenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);
      final GlobalKey boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildCupidTheme(
              platform: CupidPlatform.ios,
              brightness: Brightness.dark,
            ),
            locale: const Locale('vi'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: CupidPlatformOverride(
              platform: CupidPlatform.ios,
              child: ReturnScreen(
                wipeService: _RecordingWipeService(),
                createPairGateCubit: _parkedPairGateCubit,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      await tester.runAsync(() async {
        final ui.Image image =
            await (tester.renderObject(find.byKey(boundary))
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final ByteData? png = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image.dispose();
        final File out = File('$_visualFidelityDir/implemented-j13-man-quay-lai-ios.png');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });

      expect(
        File(
          '$_visualFidelityDir/implemented-j13-man-quay-lai-ios.png',
        ).existsSync(),
        isTrue,
      );
    });
  });
}

const Size _referenceViewport = Size(390, 844);

const String _visualFidelityDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-013_graceful_exit_and_return/visual-fidelity';

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// straight off disk; without this every Vietnamese glyph rasterizes as a
/// fallback box and the capture proves nothing about the typography.
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
