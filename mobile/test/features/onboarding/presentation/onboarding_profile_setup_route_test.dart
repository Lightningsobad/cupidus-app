import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/onboarding/presentation/onboarding_profile_setup_route.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final CupidProfile _profile = CupidProfile(
  id: 'user-1',
  email: 'linh@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
  displayName: 'Linh',
  birthday: DateTime(2001, 3, 3),
);

void main() {
  group('OnboardingProfileSetupRoute', () {
    test('carries the route name as its settings', () {
      final Route<void> route = OnboardingProfileSetupRoute.route(
        profile: _profile,
        onContinue: () {},
      );

      expect(OnboardingProfileSetupRoute.name, '/onboarding/profile');
      expect(route.settings.name, '/onboarding/profile');
    });

    testWidgets('pushes the screen with the caller-supplied profile', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          home: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => OnboardingProfileSetupRoute.push(
                context,
                profile: _profile,
                onContinue: () {},
              ),
              child: const Text('go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      final OnboardingProfileSetupScreen screen = tester
          .widget<OnboardingProfileSetupScreen>(
            find.byType(OnboardingProfileSetupScreen),
          );
      expect(screen.profile, same(_profile));
    });
  });
}
