import 'package:flutter/material.dart';

import '../../account/domain/cupid_profile.dart';
import 'screens/onboarding_profile_setup_screen.dart';

/// Single navigation entry point into [OnboardingProfileSetupScreen], mirroring
/// `features/pet/presentation/pet_route.dart`.
///
/// Nothing in the shipped app calls [push] yet: STORY-002 owns wiring
/// `permissions -> profile -> invite/join-code`, and this class exists so that
/// wiring is a one-line call. The caller resolves the [CupidProfile] and owns
/// the [onContinue] destination.
class OnboardingProfileSetupRoute {
  const OnboardingProfileSetupRoute._();

  static const String name = '/onboarding/profile';

  static Route<void> route({
    required CupidProfile profile,
    required VoidCallback onContinue,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: name),
      builder: (_) => OnboardingProfileSetupScreen(
        profile: profile,
        onContinue: onContinue,
      ),
    );
  }

  static Future<void> push(
    BuildContext context, {
    required CupidProfile profile,
    required VoidCallback onContinue,
  }) {
    return Navigator.of(
      context,
    ).push(route(profile: profile, onContinue: onContinue));
  }
}
