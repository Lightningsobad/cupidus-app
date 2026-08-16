import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({
  String initialCode = '',
  int resendSeconds = 0,
  ValueChanged<String>? onVerify,
  VoidCallback? onResend,
  CupidPlatform platform = CupidPlatform.material,
  Locale locale = const Locale('vi'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
    home: CupidPlatformOverride(
      platform: platform,
      child: OtpScreen(
        email: 'minh@gmail.com',
        initialCode: initialCode,
        resendSeconds: resendSeconds,
        onVerify: onVerify,
        onResend: onResend,
      ),
    ),
  );
}

BoxDecoration _cell(WidgetTester tester, int index) {
  final Container box = tester.widget<Container>(
    find.descendant(
      of: find.byKey(Key('otp-cell-$index')),
      matching: find.byType(Container),
      matchRoot: true,
    ),
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  const CupidColorTokens dark = CupidColorTokens.dark();

  testWidgets('renders the design source copy for the vi locale', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(initialCode: '247', resendSeconds: 42));
    await tester.pumpAndSettle();

    expect(find.text('Kiểm tra hộp thư nhé'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);
    expect(
      find.textContaining('Tụi mình vừa gửi 6 chữ số tới'),
      findsOneWidget,
    );
    expect(find.textContaining('minh@gmail.com'), findsOneWidget);
    expect(find.textContaining('Gửi lại sau'), findsOneWidget);
    expect(find.textContaining('00:42'), findsOneWidget);
  });

  testWidgets('renders the design source copy for the en locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(resendSeconds: 42, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Check your inbox'), findsOneWidget);
    // Only the CTA: AC4 leaves `otp` chromeless, so the design source's
    // `t_otp` header is not rendered.
    expect(find.text('Verify'), findsOneWidget);
    expect(find.textContaining('We sent 6 digits to'), findsOneWidget);
    expect(find.textContaining('Resend in'), findsOneWidget);
  });

  testWidgets(
    'AC3: a filled cell takes the pink border and glow, an unfilled cell '
    'takes the flat line border and no glow',
    (tester) async {
      await tester.pumpWidget(_wrap(initialCode: '247', resendSeconds: 42));
      await tester.pumpAndSettle();

      for (int i = 0; i < 3; i++) {
        final BoxDecoration filled = _cell(tester, i);
        expect(
          (filled.border! as Border).top.color,
          dark.colorAccentPink,
          reason: 'cell $i holds a digit, so it carries the pink border',
        );
        expect(filled.boxShadow, dark.glowShadow);
      }

      for (int i = 3; i < 6; i++) {
        final BoxDecoration empty = _cell(tester, i);
        expect(
          (empty.border! as Border).top.color,
          dark.colorLine,
          reason: 'cell $i holds no digit, so it stays on the line border',
        );
        expect(empty.boxShadow, isNull);
      }
    },
  );

  testWidgets('AC3: the caret sits in the first cell without a digit', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(initialCode: '247', resendSeconds: 42));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('otp-cell-3')),
        matching: find.text('|'),
      ),
      findsOneWidget,
    );
    expect(find.text('|'), findsOneWidget);
  });

  testWidgets(
    'AC3: typing walks the empty -> partial -> complete input states',
    (tester) async {
      await tester.pumpWidget(_wrap(resendSeconds: 42));
      await tester.pumpAndSettle();

      // Empty: no digits, caret on the first cell.
      expect(
        find.descendant(
          of: find.byKey(const Key('otp-cell-0')),
          matching: find.text('|'),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), '24');
      await tester.pumpAndSettle();

      // Partial: two digits rendered, caret advanced to the third cell.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('otp-cell-2')),
          matching: find.text('|'),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), '247139');
      await tester.pumpAndSettle();

      // Complete: every cell filled, so no caret is left anywhere.
      expect(find.text('|'), findsNothing);
      for (int i = 0; i < 6; i++) {
        expect((_cell(tester, i).border! as Border).top.color,
            dark.colorAccentPink);
      }
    },
  );

  testWidgets('the code field only accepts 6 digits', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12a34567890');
    await tester.pumpAndSettle();

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '123456');
  });

  testWidgets(
    'AC3: the cooldown label becomes the resend action once it expires',
    (tester) async {
      bool resent = false;
      await tester.pumpWidget(
        _wrap(resendSeconds: 0, onResend: () => resent = true),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Gửi lại sau'), findsNothing);

      final Finder resend = find.text('Gửi lại mã');
      expect(resend, findsOneWidget);
      expect(
        tester.widget<Text>(resend).style!.color,
        dark.colorAccentPink,
      );

      await tester.tap(resend);
      expect(resent, isTrue);
    },
  );

  testWidgets('the mail badge uses the bundled Material Symbols glyph', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(resendSeconds: 42));
    await tester.pumpAndSettle();

    final Icon badge = tester.widget<Icon>(find.byType(Icon).first);
    expect(badge.icon!.fontFamily, CupidIcons.fontFamily);
    expect(badge.icon!.codePoint, 0xf18a);
  });

  testWidgets('Xác nhận hands the entered code to the caller', (tester) async {
    String? verified;
    await tester.pumpWidget(
      _wrap(initialCode: '247139', onVerify: (String code) => verified = code),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xác nhận'));
    expect(verified, '247139');
  });
}
