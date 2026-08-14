import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_progress_resolver.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:flutter_test/flutter_test.dart';

CupidProfile _profile({
  String? partnerId,
  bool vowTaken = false,
  String? displayName,
}) {
  return CupidProfile(
    id: 'user-1',
    email: 'user@example.com',
    language: 'vi',
    vowTaken: vowTaken,
    isGhostModeEnabled: true,
    displayName: displayName,
    partnerId: partnerId,
  );
}

OnboardingProgressResolver _resolver({
  required CupidProfile profile,
  required bool emailVerified,
}) {
  return OnboardingProgressResolver(
    fetchProfile: () async => profile,
    reloadEmailVerified: () async => emailVerified,
  );
}

void main() {
  test('rule 1: paired and vow taken resolves to home', () async {
    final OnboardingProgressResolver resolver = _resolver(
      profile: _profile(
        partnerId: 'partner-1',
        vowTaken: true,
        displayName: 'Mai',
      ),
      emailVerified: true,
    );

    expect(await resolver.resolve(), OnboardingNode.home);
  });

  test('rule 2: paired without the vow resumes at loveContract', () async {
    final OnboardingProgressResolver resolver = _resolver(
      profile: _profile(partnerId: 'partner-1', displayName: 'Mai'),
      emailVerified: true,
    );

    expect(await resolver.resolve(), OnboardingNode.loveContract);
  });

  test('rule 3: unpaired and unverified email resumes at otp', () async {
    final OnboardingProgressResolver resolver = _resolver(
      profile: _profile(displayName: 'Mai'),
      emailVerified: false,
    );

    expect(await resolver.resolve(), OnboardingNode.otp);
  });

  test(
    'rule 4: unpaired with no display name resumes at profileSetup',
    () async {
      final OnboardingProgressResolver resolver = _resolver(
        profile: _profile(),
        emailVerified: true,
      );

      expect(await resolver.resolve(), OnboardingNode.profileSetup);
    },
  );

  test(
    'rule 5: unpaired but otherwise complete resumes at pairingChoice',
    () async {
      final OnboardingProgressResolver resolver = _resolver(
        profile: _profile(displayName: 'Mai'),
        emailVerified: true,
      );

      expect(await resolver.resolve(), OnboardingNode.pairingChoice);
    },
  );

  test('a failed profile read falls back to pairingChoice', () async {
    final OnboardingProgressResolver resolver = OnboardingProgressResolver(
      fetchProfile: () async => throw Exception('network down'),
      reloadEmailVerified: () async => true,
    );

    expect(await resolver.resolve(), OnboardingNode.pairingChoice);
  });

  test('a failed email-verified read falls back to pairingChoice', () async {
    final OnboardingProgressResolver resolver = OnboardingProgressResolver(
      fetchProfile: () async => _profile(displayName: 'Mai'),
      reloadEmailVerified: () async => throw Exception('firebase down'),
    );

    expect(await resolver.resolve(), OnboardingNode.pairingChoice);
  });

  test('an unpaired account never resolves to home', () async {
    for (final bool vowTaken in <bool>[false, true]) {
      for (final bool emailVerified in <bool>[false, true]) {
        for (final String? displayName in <String?>[null, 'Mai']) {
          final OnboardingProgressResolver resolver = _resolver(
            profile: _profile(vowTaken: vowTaken, displayName: displayName),
            emailVerified: emailVerified,
          );

          expect(
            await resolver.resolve(),
            isNot(OnboardingNode.home),
            reason:
                'unpaired (vowTaken: $vowTaken, emailVerified: $emailVerified, '
                'displayName: $displayName) must not reach home',
          );
        }
      }
    }
  });

  test('waiting and permissions are never resume targets', () async {
    for (final bool emailVerified in <bool>[false, true]) {
      final OnboardingProgressResolver resolver = _resolver(
        profile: _profile(),
        emailVerified: emailVerified,
      );

      expect(
        await resolver.resolve(),
        isNot(anyOf(OnboardingNode.waiting, OnboardingNode.permissions)),
      );
    }
  });
}
