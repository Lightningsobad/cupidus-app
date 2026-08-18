import 'dart:async';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/chat/presentation/ghost_cubit.dart'
    show GhostConsentLevel;
import 'package:cupid_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:cupid_mobile/features/chat/presentation/widgets/chat_composer.dart';
import 'package:cupid_mobile/features/chat/presentation/widgets/ghost_bubble.dart';
import 'package:cupid_mobile/features/chat/presentation/widgets/message_bubble.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const CupidColorTokens _dark = CupidColorTokens.dark();
const CupidColorTokens _light = CupidColorTokens.light();
const String _partnerName = 'Bae';

class _FakeChatRepository implements ChatRepository {
  final StreamController<List<Message>> _thread =
      StreamController<List<Message>>();

  @override
  Stream<List<Message>> watchThread() => _thread.stream;

  @override
  Future<void> send(String text) async {}

  @override
  Future<void> loadOlder() async {}

  @override
  Future<List<RealtimeEvent>> resyncPageOne() async => const <RealtimeEvent>[];

  @override
  Future<void> markSeen() async {}

  @override
  Future<void> dispose() async => _thread.close();
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final StreamController<RealtimeStatus> _status =
      StreamController<RealtimeStatus>.broadcast();
  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => _events.stream;

  @override
  Stream<RealtimeStatus> get status => _status.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  @override
  Future<void> resync() async {}
}

Widget _hostOn(
  CupidPlatform platform,
  Widget child, {
  Brightness brightness = Brightness.dark,
}) => MaterialApp(
  theme: buildCupidTheme(platform: platform, brightness: brightness),
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: Scaffold(body: child),
);

Widget _host(Widget child) => _hostOn(CupidPlatform.material, child);

Message _message({
  required String id,
  required String senderId,
  String status = 'sent',
}) => Message(
  id: id,
  senderId: senderId,
  receiverId: senderId == 'me' ? 'partner' : 'me',
  content: 'xin chào',
  type: 'text',
  status: status,
  createdAt: DateTime(2026, 8, 13, 16, 5),
  cachedAt: DateTime(2026, 8, 13, 16, 5),
);

/// The bubble fill is the only [Container] inside [MessageBubble].
BoxDecoration _bubbleDecoration(WidgetTester tester) => tester
        .widget<Container>(
          find.descendant(
            of: find.byType(MessageBubble),
            matching: find.byType(Container),
          ),
        )
        .decoration!
    as BoxDecoration;

void main() {
  group('chat thread bubbles match the locked design source', () {
    testWidgets(
      'own bubble carries the hot gradient, white text and the glow shadow',
      (tester) async {
        await tester.pumpWidget(
          _host(
            MessageBubble(
              message: _message(id: 'm1', senderId: 'me'),
              isMine: true,
            ),
          ),
        );

        final BoxDecoration decoration = _bubbleDecoration(tester);
        expect(decoration.gradient, _dark.gradientHot);
        expect(decoration.boxShadow, _dark.glowShadow);
        expect(
          (decoration.borderRadius! as BorderRadius).bottomRight,
          const Radius.circular(7),
        );

        final Text body = tester.widget<Text>(find.text('xin chào'));
        expect(body.style!.color, _dark.colorText);
        expect(body.style!.fontSize, 15.5);
        expect(body.style!.height, 1.4);
      },
    );

    testWidgets('partner bubble uses the surface fill and elevation shadow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          MessageBubble(
            message: _message(id: 'm2', senderId: 'partner'),
            isMine: false,
          ),
        ),
      );

      final BoxDecoration decoration = _bubbleDecoration(tester);
      expect(decoration.color, _dark.colorSurface);
      expect(decoration.gradient, isNull);
      expect(
        decoration.boxShadow,
        const CupidPlatformTokens.material().elevationShadow,
      );
      expect(
        (decoration.borderRadius! as BorderRadius).bottomLeft,
        const Radius.circular(7),
      );
    });

    // `colorOnAccent` is scoped to text drawn on `gradientHot`, so only the
    // own bubble may use it. Dark theme cannot police that split: there
    // `colorOnAccent` and `colorText` are the same hex, so a mis-scoped
    // `colorOnAccent` on the partner bubble is invisible to any dark-only
    // assertion. In light theme it is white-on-white against `colorSurface`.
    testWidgets('partner bubble text is never its own fill colour', (
      tester,
    ) async {
      for (final Brightness brightness in Brightness.values) {
        final CupidColorTokens colors = brightness == Brightness.dark
            ? _dark
            : _light;

        await tester.pumpWidget(
          _hostOn(
            CupidPlatform.material,
            MessageBubble(
              message: _message(id: 'm4', senderId: 'partner'),
              isMine: false,
            ),
            brightness: brightness,
          ),
        );
        // Second iteration rebuilds the same tree, so `AnimatedTheme` is
        // mid-lerp and still reports the previous brightness on the first
        // frame.
        await tester.pumpAndSettle();

        final Text body = tester.widget<Text>(find.text('xin chào'));
        expect(body.style!.color, colors.colorText, reason: '$brightness');
        expect(
          body.style!.color,
          isNot(_bubbleDecoration(tester).color),
          reason: '$brightness',
        );
      }
    });

    testWidgets('light theme keeps the two on-fill text roles distinct', (
      tester,
    ) async {
      expect(_light.colorOnAccent, isNot(_light.colorText));

      await tester.pumpWidget(
        _hostOn(
          CupidPlatform.material,
          MessageBubble(
            message: _message(id: 'm5', senderId: 'me'),
            isMine: true,
          ),
          brightness: Brightness.light,
        ),
      );
      expect(
        tester.widget<Text>(find.text('xin chào')).style!.color,
        _light.colorOnAccent,
      );

      await tester.pumpWidget(
        _hostOn(
          CupidPlatform.material,
          MessageBubble(
            message: _message(id: 'm6', senderId: 'partner'),
            isMine: false,
          ),
          brightness: Brightness.light,
        ),
      );
      expect(
        tester.widget<Text>(find.text('xin chào')).style!.color,
        _light.colorText,
      );
    });

    testWidgets(
      'the timestamp/tick meta row sits outside the bubble in the muted role',
      (tester) async {
        await tester.pumpWidget(
          _host(
            MessageBubble(
              message: _message(id: 'm3', senderId: 'me', status: 'seen'),
              isMine: true,
            ),
          ),
        );

        // The design source draws the meta row below the bubble, not inside
        // the gradient fill.
        expect(
          find.descendant(
            of: find.byType(Container),
            matching: find.text('16:05'),
          ),
          findsNothing,
        );

        final Text stamp = tester.widget<Text>(find.text('16:05'));
        expect(stamp.style!.color, _dark.colorTextMuted);
        expect(stamp.style!.fontSize, 10);

        final Icon tick = tester.widget<Icon>(find.byIcon(Icons.done_all));
        expect(tick.color, _dark.colorMint);
        expect(tick.size, 12);
      },
    );
  });

  group('typing ghost bubble matches the ghostFade keyframe', () {
    testWidgets('renders the purple "<name> đang nghĩ…" header', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const GhostBubble(
            keptContent: 'anh nghĩ',
            struckContent: '',
            partnerDisplayName: _partnerName,
          ),
        ),
      );
      await tester.pump();

      final Text header = tester.widget<Text>(
        find.text('$_partnerName đang nghĩ…'),
      );
      expect(header.style!.color, _dark.colorAccentPurple);
      expect(header.style!.fontSize, 10);
      expect(header.style!.fontWeight, FontWeight.w800);
      expect(tester.widget<Icon>(find.byIcon(Icons.blur_on)).size, 13);
    });

    testWidgets('draws the pink half-block cursor, not a purple one', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const GhostBubble(
            keptContent: 'anh nghĩ',
            struckContent: '',
            partnerDisplayName: _partnerName,
          ),
        ),
      );
      await tester.pump();

      // U+258C LEFT HALF BLOCK, per the design source's `<span>▌</span>`.
      final Text cursor = tester.widget<Text>(find.text('▌'));
      expect(cursor.style!.color, _dark.colorAccentPink);
    });

    testWidgets(
      'deleted tail is struck through and fades from .95 to .45 over 1.3s',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const GhostBubble(
              keptContent: 'anh nghĩ ',
              struckContent: 'em sai rồi',
              partnerDisplayName: _partnerName,
            ),
          ),
        );

        final Text struck = tester.widget<Text>(find.text('em sai rồi'));
        expect(struck.style!.color, _dark.colorGhost);
        expect(struck.style!.decoration, TextDecoration.lineThrough);
        // `text-decoration-color:rgba(180,166,206,.85)` expressed as the
        // ghost token at 85% alpha.
        expect(
          struck.style!.decorationColor,
          _dark.colorGhost.withValues(alpha: 0.85),
        );

        Opacity fade() => tester.widget<Opacity>(
          find.ancestor(
            of: find.text('em sai rồi'),
            matching: find.byType(Opacity),
          ),
        );

        await tester.pump();
        expect(fade().opacity, closeTo(0.95, 0.001));

        await tester.pump(const Duration(milliseconds: 1300));
        expect(fade().opacity, closeTo(0.45, 0.001));
      },
    );
  });

  testWidgets(
    'the Level-1 device-only lock chip is always visible above the thread',
    (tester) async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));

      await tester.pumpWidget(
        _host(
          ChatScreen(
            repository: _FakeChatRepository(),
            coordinator: _FakeRealtimeCoordinator(),
            backendUserIdStore: BackendUserIdStore()
              ..updateFromLoginResponse({'id': 'me'}),
            partnerStore: ChatPartnerStore(dio: dio),
            consentStore: GhostConsentStore(dio: dio),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Level 1 · chỉ nằm trên máy hai người'),
        findsOneWidget,
      );

      final Icon lock = tester.widget<Icon>(find.byIcon(Icons.lock));
      expect(lock.color, _dark.colorMint);
      expect(lock.size, 13);

      final BoxDecoration chip =
          tester
                  .widget<Container>(
                    find
                        .ancestor(
                          of: find.byIcon(Icons.lock),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(chip.color, _dark.colorSurface);
    },
  );

  group('ghost toggle keeps its 46pt visual on both platform silhouettes', () {
    // `Cupid Screens.dc.html`, `isChat` composer: `width:46px;height:46px`.
    const double visualSize = 46;

    Future<void> pumpComposer(
      WidgetTester tester,
      CupidPlatform platform,
    ) async {
      await tester.pumpWidget(
        _hostOn(
          platform,
          ChatComposer(
            onSend: (_) async => true,
            showNetworkUnavailableError: false,
            ghostConsentLevel: GhostConsentLevel.on,
            onGhostTogglePressed: () {},
            partnerDisplayName: _partnerName,
          ),
        ),
      );
      await tester.pump();
    }

    /// The toggle's visual fill is the nearest [Container] wrapping its
    /// `blur_on` glyph; the tap-target slot is the nearest [SizedBox] above it.
    Finder ghostVisual() => find
        .ancestor(
          of: find.byIcon(Icons.blur_on),
          matching: find.byType(Container),
        )
        .first;

    Finder ghostSlot() => find
        .ancestor(
          of: find.byIcon(Icons.blur_on),
          matching: find.byType(SizedBox),
        )
        .first;

    for (final MapEntry<CupidPlatform, CupidPlatformTokens> entry
        in const <CupidPlatform, CupidPlatformTokens>{
          CupidPlatform.material: CupidPlatformTokens.material(),
          CupidPlatform.ios: CupidPlatformTokens.ios(),
        }.entries) {
      testWidgets('${entry.key.name} renders the visual unclamped at 46x46', (
        tester,
      ) async {
        await pumpComposer(tester, entry.key);

        expect(tester.getSize(ghostVisual()), const Size(visualSize, visualSize));

        // The slot still has to clear the platform minimum — the fix widens
        // the slot to the visual, it never shrinks the tap target.
        final Size slot = tester.getSize(ghostSlot());
        expect(slot.width, greaterThanOrEqualTo(entry.value.tapTarget));
        expect(slot.height, greaterThanOrEqualTo(entry.value.tapTarget));
      });
    }
  });
}
