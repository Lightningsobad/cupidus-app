import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/presentation/auth_failure_text.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _messageFor(
  WidgetTester tester,
  Object failure, {
  Locale locale = const Locale('en'),
}) async {
  late String message;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Builder(
        builder: (context) {
          message = authFailureMessage(context, failure);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return message;
}

void main() {
  group('authFailureMessage', () {
    testWidgets('maps InvalidCredentialFailure', (tester) async {
      expect(
        await _messageFor(tester, const InvalidCredentialFailure()),
        'Incorrect email or password',
      );
      expect(
        await _messageFor(
          tester,
          const InvalidCredentialFailure(),
          locale: const Locale('vi'),
        ),
        'Email hoặc mật khẩu không đúng',
      );
    });

    testWidgets('maps EmailAlreadyInUseFailure', (tester) async {
      expect(
        await _messageFor(tester, const EmailAlreadyInUseFailure()),
        'This email is already in use',
      );
    });

    testWidgets('maps WeakPasswordFailure', (tester) async {
      expect(
        await _messageFor(tester, const WeakPasswordFailure()),
        'Password is too weak',
      );
    });

    testWidgets('maps SessionExpiredFailure and UnauthorizedFailure the same', (
      tester,
    ) async {
      expect(
        await _messageFor(tester, const SessionExpiredFailure()),
        'Your session has expired',
      );
      expect(
        await _messageFor(tester, const UnauthorizedFailure()),
        'Your session has expired',
      );
    });

    testWidgets(
      'maps AuthNetworkFailure and NetworkUnavailableFailure the same',
      (tester) async {
        expect(
          await _messageFor(tester, const AuthNetworkFailure()),
          'No internet connection',
        );
        expect(
          await _messageFor(tester, const NetworkUnavailableFailure()),
          'No internet connection',
        );
      },
    );

    testWidgets('maps TimeoutFailure', (tester) async {
      expect(
        await _messageFor(tester, const TimeoutFailure()),
        'Connection timed out, please try again',
      );
    });

    testWidgets('maps an unrecognized failure to a generic fallback', (
      tester,
    ) async {
      expect(
        await _messageFor(tester, const UnexpectedFailure()),
        'Something went wrong. Please try again.',
      );
      expect(
        await _messageFor(tester, const UnexpectedAuthFailure()),
        'Something went wrong. Please try again.',
      );
    });
  });
}
