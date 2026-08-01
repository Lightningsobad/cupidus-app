import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/presentation/screens/privacy_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: const PrivacyScreen(),
  );
}

void main() {
  group('PrivacyScreen', () {
    testWidgets('renders the three tier cards', (tester) async {
      await tester.pumpWidget(_harness());

      expect(find.text('Device only'), findsOneWidget);
      expect(find.text('Server, end-to-end'), findsOneWidget);
      expect(find.text('Standard server'), findsOneWidget);
    });

    testWidgets('renders no toggle and no export button (DEC-3/DEC-5)', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());

      expect(find.byType(Switch), findsNothing);
      expect(find.textContaining('Export'), findsNothing);
    });
  });
}
