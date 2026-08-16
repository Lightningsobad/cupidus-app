import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chat/data/chat_events.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/screens/ghost_settings_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// STORY-019 design-fidelity assertions for `ghostset`, transcribed from
/// `cupid-app-design-system/project/Cupid Screens.dc.html` lines 391-431 and
/// the binding block at lines 2200-2213. Audited configuration: dark theme +
/// `vi` locale.
const CupidColorTokens _dark = CupidColorTokens.dark();
const CupidPlatformTokens _material = CupidPlatformTokens.material();

const String _localOptInKey = 'cupid_ghost_local_opt_in_v1';
const String _partnerId = 'partner-1';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter({required this.serverGhostFlag});

  final bool serverGhostFlag;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, Object?>{
        'partnerId': _partnerId,
        'displayName': 'Bae',
        'isGhostModeEnabled': serverGhostFlag,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();

  void fireGhostTyping(String content) {
    _events.add(
      GenericRealtimeEvent(
        name: ChatEvents.ghostTyping,
        id: null,
        data: {'content': content},
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.utc(2026, 8, 13),
      ),
    );
  }

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => names == null
      ? _events.stream
      : _events.stream.where((event) => names.contains(event.name));

  @override
  Stream<RealtimeStatus> get status => const Stream<RealtimeStatus>.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  @override
  Future<void> resync() async {}
}

class _Harness {
  _Harness({required this.widget, required this.coordinator});

  final Widget widget;
  final _FakeRealtimeCoordinator coordinator;
}

Future<_Harness> _buildHarness({
  required bool localOptIn,
  required bool serverGhostFlag,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    _localOptInKey: localOptIn,
  });

  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _FakeHttpClientAdapter(
      serverGhostFlag: serverGhostFlag,
    );
  final partnerStore = ChatPartnerStore(dio: dio);
  await partnerStore.refreshFromServer();
  final coordinator = _FakeRealtimeCoordinator();

  return _Harness(
    coordinator: coordinator,
    widget: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: GhostSettingsScreen(
        coordinator: coordinator,
        consentStore: GhostConsentStore(dio: dio),
        partnerStore: partnerStore,
        backendUserIdStore: BackendUserIdStore()
          ..updateFromLoginResponse({'id': 'me-1'}),
      ),
    ),
  );
}

Future<T> _realAsync<T>(WidgetTester tester, Future<T> Function() body) async =>
    (await tester.runAsync(body)) as T;

/// Mounts the screen on a 412pt-wide surface — the design source frame width —
/// tall enough that the whole scroll region is laid out for geometry probes.
Future<_Harness> _pumpScreen(
  WidgetTester tester, {
  required bool localOptIn,
  required bool serverGhostFlag,
}) async {
  await tester.binding.setSurfaceSize(const Size(412, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final _Harness harness = await _realAsync(
    tester,
    () =>
        _buildHarness(localOptIn: localOptIn, serverGhostFlag: serverGhostFlag),
  );
  await tester.pumpWidget(harness.widget);
  await tester.pump();
  return harness;
}

final Finder _switchTrack = find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.constraints == BoxConstraints.tightFor(width: 54, height: 32),
);

final Finder _switchKnob = find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.constraints == BoxConstraints.tightFor(width: 26, height: 26),
);

BoxDecoration _decorationOf(WidgetTester tester, Finder finder) =>
    tester.widget<Container>(finder).decoration! as BoxDecoration;

TextStyle _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

void main() {
  testWidgets(
    'AC3 off: the 54x32 pill switch uses the --line track with the knob at '
    'flex-start',
    (tester) async {
      await _pumpScreen(tester, localOptIn: false, serverGhostFlag: true);

      expect(find.text('Tắt'), findsNWidgets(2));
      expect(_decorationOf(tester, _switchTrack).color, _dark.colorLine);
      expect(_decorationOf(tester, _switchTrack).gradient, isNull);

      final Rect track = tester.getRect(_switchTrack);
      final Rect knob = tester.getRect(_switchKnob);
      expect(knob.left - track.left, 3);
      expect(knob.size, const Size(26, 26));
    },
  );

  testWidgets(
    'AC3 pending: the switch keeps the off-position --line track while the '
    'state line and accessible label carry the pending state',
    (tester) async {
      await _pumpScreen(tester, localOptIn: true, serverGhostFlag: true);

      expect(find.text('Đang chờ cả hai đồng ý'), findsOneWidget);
      expect(_decorationOf(tester, _switchTrack).color, _dark.colorLine);

      final Rect track = tester.getRect(_switchTrack);
      final Rect knob = tester.getRect(_switchKnob);
      expect(knob.left - track.left, 3);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  'Typing Ghost: đang chờ cả hai đồng ý' &&
              widget.properties.button == true,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'AC3 on: the switch uses the --grad-hot track with the knob at flex-end '
    'and the "You" tile turns --mint',
    (tester) async {
      final _Harness harness = await _pumpScreen(
        tester,
        localOptIn: true,
        serverGhostFlag: true,
      );
      harness.coordinator.fireGhostTyping('anh ăn cơm chưa');
      // The cubit's state stream delivers on a microtask, so the first pump
      // only schedules the frame that the second pump then draws.
      await tester.pump();
      await tester.pump();

      expect(find.text('Đang bật · cả hai đã đồng ý'), findsOneWidget);
      expect(_decorationOf(tester, _switchTrack).gradient, _dark.gradientHot);
      expect(_decorationOf(tester, _switchTrack).color, isNull);

      final Rect track = tester.getRect(_switchTrack);
      final Rect knob = tester.getRect(_switchKnob);
      expect(track.right - knob.right, 3);

      expect(_styleOf(tester, 'Đã đồng ý').color, _dark.colorMint);
      expect(_styleOf(tester, 'Chưa rõ').color, _dark.colorTextMuted);
    },
  );

  testWidgets(
    'AC4: the Level-1 device-only lock chip is rendered on this screen',
    (tester) async {
      await _pumpScreen(tester, localOptIn: false, serverGhostFlag: true);

      const String chipCopy = 'Level 1 · chỉ nằm trên máy hai người';
      expect(find.text(chipCopy), findsOneWidget);
      expect(_styleOf(tester, chipCopy).fontSize, 10.5);
      expect(_styleOf(tester, chipCopy).color, _dark.colorTextMuted);

      final Icon lock = tester.widget<Icon>(
        find.descendant(
          of: find.byType(CupidIcon),
          matching: find.byType(Icon),
        ),
      );
      expect(lock.icon, CupidIcons.lock);
      expect(lock.size, 13);
      expect(lock.color, _dark.colorMint);
    },
  );

  testWidgets(
    'AC1: card geometry, tokens and typography match the locked design source',
    (tester) async {
      await _pumpScreen(tester, localOptIn: false, serverGhostFlag: true);

      final ListView list = tester.widget<ListView>(find.byType(ListView));
      expect(list.padding, const EdgeInsets.fromLTRB(16, 14, 16, 40));

      // Hero card: 145deg purple/pink wash, 1px --purple .45 hairline.
      final BoxDecoration hero = _decorationOf(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).gradient
                  is LinearGradient &&
              ((widget.decoration! as BoxDecoration).gradient!
                          as LinearGradient)
                      .colors
                      .length ==
                  2 &&
              (widget.decoration! as BoxDecoration).border != null,
        ),
      );
      expect((hero.gradient! as LinearGradient).colors, <Color>[
        _dark.colorAccentPurple.withValues(alpha: 0.32),
        _dark.colorAccentPink.withValues(alpha: 0.2),
      ]);
      expect(
        hero.border,
        Border.all(color: _dark.colorAccentPurple.withValues(alpha: 0.45)),
      );
      expect(hero.borderRadius, BorderRadius.circular(_material.radiusCard));
      expect(
        _styleOf(tester, 'Đối phương thấy cả phần bạn đã xoá').fontSize,
        25,
      );

      // Consent tiles: --surf2 fill on the --r-sm radius, centred 11pt label.
      final BoxDecoration consentTile = _decorationOf(
        tester,
        find
            .ancestor(of: find.text('Bạn'), matching: find.byType(Container))
            .first,
      );
      expect(consentTile.color, _dark.colorSurfaceAlt);
      expect(
        consentTile.borderRadius,
        BorderRadius.circular(_material.radiusSmall),
      );
      expect(_styleOf(tester, 'Bạn').fontSize, 11);

      // Legend: uppercase section label, deleted swatch before live swatch,
      // 11x11 rounded squares rather than circles.
      expect(find.text('NHÌN NHƯ THẾ NÀO'), findsOneWidget);
      final Finder swatches = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints ==
                BoxConstraints.tightFor(width: 11, height: 11),
      );
      expect(swatches, findsNWidgets(2));
      expect(
        (tester.widget<Container>(swatches.first).decoration! as BoxDecoration)
            .color,
        _dark.colorGhost,
      );
      expect(
        (tester.widget<Container>(swatches.at(1)).decoration! as BoxDecoration)
            .borderRadius,
        BorderRadius.circular(4),
      );
      expect(
        tester.getCenter(find.text('Đã xoá')).dx,
        lessThan(tester.getCenter(find.text('Đang gõ')).dx),
      );

      // Ephemeral footer: mint .12 fill with the .34 hairline the previous
      // implementation omitted, and the shield_moon glyph.
      final BoxDecoration ephemeral = _decorationOf(
        tester,
        find.ancestor(
          of: find.byIcon(Icons.shield_moon),
          matching: find.byType(Container),
        ),
      );
      expect(ephemeral.color, _dark.colorMint.withValues(alpha: 0.12));
      expect(
        ephemeral.border,
        Border.all(color: _dark.colorMint.withValues(alpha: 0.34)),
      );
    },
  );

  testWidgets('AC1/§8: the pill switch keeps the platform minimum tap target', (
    tester,
  ) async {
    await _pumpScreen(tester, localOptIn: false, serverGhostFlag: true);

    final Size hitArea = tester.getSize(
      find.ancestor(of: _switchTrack, matching: find.byType(SizedBox)).first,
    );
    expect(hitArea.height, greaterThanOrEqualTo(_material.tapTarget));
    expect(hitArea.width, greaterThanOrEqualTo(44));
  });
}
