import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/in_app_notifications/presentation/dialogs/alarm_request_dialog.dart';
import 'package:cupid_mobile/features/in_app_notifications/presentation/dialogs/contract_signing_dialog.dart';
import 'package:cupid_mobile/features/in_app_notifications/presentation/dialogs/dream_jar_approval_dialog.dart';
import 'package:cupid_mobile/features/in_app_notifications/presentation/dialogs/ghost_config_approval_dialog.dart';
import 'package:cupid_mobile/features/in_app_notifications/presentation/dialogs/theme_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildThemedApp({
  required ThemeDefinition themeDef,
  required Widget child,
}) {
  final themeData = buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
    themeDefinition: themeDef,
  );

  return MaterialApp(
    theme: themeData,
    home: Scaffold(
      body: Builder(
        builder: (context) => child,
      ),
    ),
  );
}

void main() {
  testWidgets('DreamJarApprovalDialog adopts active theme colors', (tester) async {
    final sunsetTheme = cupidThemeCatalog.firstWhere((t) => t.id == 'sunset');

    await tester.pumpWidget(
      _buildThemedApp(
        themeDef: sunsetTheme,
        child: DreamJarApprovalDialog(
          jarName: 'Du lịch Nhật Bản',
          targetAmount: 50000000,
          currency: 'VND',
          onApprove: () {},
          onReject: () {},
        ),
      ),
    );

    expect(find.text('Hũ Ước Mơ Mới'), findsOneWidget);
    expect(find.text('Cùng làm nhé! 💖'), findsOneWidget);

    final expectedColors = colorTokensForTheme(sunsetTheme, Brightness.dark);
    final titleWidget = tester.widget<Text>(find.text('Hũ Ước Mơ Mới'));
    expect(titleWidget.style?.color, expectedColors.colorText);
  });

  testWidgets('ThemeRequestDialog adopts active theme colors', (tester) async {
    final matchaTheme = cupidThemeCatalog.firstWhere((t) => t.id == 'matcha');

    await tester.pumpWidget(
      _buildThemedApp(
        themeDef: matchaTheme,
        child: ThemeRequestDialog(
          themeName: 'Matcha Latte',
          themeId: 'matcha',
          price: 200,
          onApprove: () {},
          onReject: () {},
        ),
      ),
    );

    expect(find.text('Đề Xuất Đổi Giao Diện'), findsOneWidget);
    expect(find.text('Đồng ý ngay'), findsOneWidget);

    final expectedColors = colorTokensForTheme(matchaTheme, Brightness.dark);
    final titleWidget = tester.widget<Text>(find.text('Đề Xuất Đổi Giao Diện'));
    expect(titleWidget.style?.color, expectedColors.colorText);
  });

  testWidgets('AlarmRequestDialog adopts active theme colors', (tester) async {
    final sakuraTheme = cupidThemeCatalog.firstWhere((t) => t.id == 'sakura');

    await tester.pumpWidget(
      _buildThemedApp(
        themeDef: sakuraTheme,
        child: AlarmRequestDialog(
          alarmTime: '06:30',
          days: const ['T2', 'T4', 'T6'],
          onConfirm: () {},
          onDismiss: () {},
        ),
      ),
    );

    expect(find.text('Hẹn Giờ Báo Thức Đôi'), findsOneWidget);
    final expectedColors = colorTokensForTheme(sakuraTheme, Brightness.dark);
    final titleWidget = tester.widget<Text>(find.text('Hẹn Giờ Báo Thức Đôi'));
    expect(titleWidget.style?.color, expectedColors.colorText);
  });

  testWidgets('ContractSigningDialog adopts active theme colors', (tester) async {
    final midnightTheme = cupidThemeCatalog.firstWhere((t) => t.id == 'midnight');

    await tester.pumpWidget(
      _buildThemedApp(
        themeDef: midnightTheme,
        child: ContractSigningDialog(
          contractId: 'contract-1',
          clauses: const ['Luôn lắng nghe nhau', 'Không đi ngủ khi đang giận'],
          onSign: () {},
          onDismiss: () {},
        ),
      ),
    );

    expect(find.text('Hợp Đồng Tình Yêu Chờ Ký'), findsOneWidget);
    final expectedColors = colorTokensForTheme(midnightTheme, Brightness.dark);
    final titleWidget = tester.widget<Text>(find.text('Hợp Đồng Tình Yêu Chờ Ký'));
    expect(titleWidget.style?.color, expectedColors.colorText);
  });

  testWidgets('GhostConfigApprovalDialog adopts active theme colors', (tester) async {
    final neonTheme = cupidThemeCatalog.firstWhere((t) => t.id == 'neon');

    await tester.pumpWidget(
      _buildThemedApp(
        themeDef: neonTheme,
        child: GhostConfigApprovalDialog(
          thresholdMinutes: 15,
          penalty: 'Bão Emoji',
          onApprove: () {},
          onReject: () {},
        ),
      ),
    );

    expect(find.text('Luật Anti-Ghosting Mới'), findsOneWidget);
    final expectedColors = colorTokensForTheme(neonTheme, Brightness.dark);
    final titleWidget = tester.widget<Text>(find.text('Luật Anti-Ghosting Mới'));
    expect(titleWidget.style?.color, expectedColors.colorText);
  });
}
