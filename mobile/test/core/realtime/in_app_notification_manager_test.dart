import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/core/realtime/in_app_notification_manager.dart';

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final _controller = StreamController<RealtimeEvent>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    if (names == null) return _controller.stream;
    return _controller.stream.where((e) => names.contains(e.name));
  }

  void emitEvent(RealtimeEvent event) => _controller.add(event);

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  @override
  Future<void> resync() async {}

  @override
  Future<void> start() async {}

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> stop() async {}
}

void main() {
  late _FakeRealtimeCoordinator fakeCoordinator;
  late GlobalKey<NavigatorState> navigatorKey;
  late InAppNotificationManager manager;

  setUp(() {
    fakeCoordinator = _FakeRealtimeCoordinator();
    navigatorKey = GlobalKey<NavigatorState>();
    manager = InAppNotificationManager(
      navigatorKey: navigatorKey,
      coordinator: fakeCoordinator,
    );
  });

  tearDown(() {
    manager.dispose();
  });

  testWidgets('renders InAppToastBanner when toast events arrive', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    );

    // 1. Dispatch chat:newMessage event
    fakeCoordinator.emitEvent(
      GenericRealtimeEvent(
        name: 'chat:newMessage',
        id: 'msg-123',
        data: {'content': 'Em an com chua?'},
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Bae 💬'), findsOneWidget);
    expect(find.text('Em an com chua?'), findsOneWidget);

    // 2. Dispatch pet:interacted event
    fakeCoordinator.emitEvent(
      GenericRealtimeEvent(
        name: 'pet:interacted',
        id: 'pet-123',
        data: {
          'pet': {'name': 'Mochi', 'happiness': 85},
          'isLevelUp': true,
        },
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Bé Pet tăng cấp! 🌟'), findsOneWidget);
    expect(find.text('Bé "Mochi" vừa đạt cấp độ mới! 🎉'), findsOneWidget);
  });

  testWidgets('renders ThemeRequestDialog when theme:request arrives', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    );

    fakeCoordinator.emitEvent(
      GenericRealtimeEvent(
        name: 'theme:request',
        id: 'couple-1',
        data: {
          'themeName': 'Hoàng Hôn Đà Lạt',
          'themeId': 'sunset',
          'price': 320,
        },
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Đề Xuất Đổi Giao Diện'), findsOneWidget);
    expect(find.text('Đồng ý ngay'), findsOneWidget);
    expect(find.text('Để sau'), findsOneWidget);
  });

  testWidgets('renders DreamJarApprovalDialog when dream_jar:created arrives', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    );

    fakeCoordinator.emitEvent(
      GenericRealtimeEvent(
        name: 'dream_jar:created',
        id: 'jar-1',
        data: {
          'id': 'jar-1',
          'name': 'Du lịch Phú Quốc',
          'targetAmount': 20000000,
          'currency': 'VND',
        },
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Hũ Ước Mơ Mới'), findsOneWidget);
    expect(find.text('Cùng làm nhé! 💖'), findsOneWidget);
    expect(find.text('Từ chối'), findsOneWidget);
  });

  testWidgets('renders EmojiStormOverlay when chat:emojiStormReceived arrives', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    );

    fakeCoordinator.emitEvent(
      GenericRealtimeEvent(
        name: 'chat:emojiStormReceived',
        id: null,
        data: {'penalty': 'emoji_storm'},
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('⚠️ BÃO EMOJI ĐANG DỘI XUỐNG! ⚠️'), findsOneWidget);
  });
}
