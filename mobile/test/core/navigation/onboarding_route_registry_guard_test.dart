// Guard for the gap that let a resume target ship with no way to render it:
// every router test builds its own registry from `OnboardingNode.values`, so
// none of them can see what the *production* registry actually covers.
//
// This suite drives `OnboardingProgressResolver` across its whole input space,
// collects the nodes it can return, and holds them against the shipped
// `onboardingRouteBuilders()` map.
import 'package:cupid_mobile/core/di/service_locator.dart';
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

/// Every node `resolve()` can hand a caller, derived by exhausting the signals
/// the rule table reads rather than by restating its outcomes — a new rule
/// that returns a new node shows up here without the test being updated.
Future<Set<OnboardingNode>> _resumeTargets() async {
  final Set<OnboardingNode> targets = <OnboardingNode>{};

  for (final String? partnerId in <String?>[null, 'partner-1']) {
    for (final bool vowTaken in <bool>[false, true]) {
      for (final String? displayName in <String?>[null, 'Mai']) {
        for (final bool emailVerified in <bool>[false, true]) {
          final OnboardingProgressResolver resolver =
              OnboardingProgressResolver(
                fetchProfile: () async => _profile(
                  partnerId: partnerId,
                  vowTaken: vowTaken,
                  displayName: displayName,
                ),
                reloadEmailVerified: () async => emailVerified,
              );
          targets.add((await resolver.resolve()).node);
        }
      }
    }
  }

  // Both failure fallbacks, which route without ever reading a profile.
  targets.add(
    (await OnboardingProgressResolver(
      fetchProfile: () async => throw Exception('network down'),
      reloadEmailVerified: () async => true,
    ).resolve()).node,
  );
  targets.add(
    (await OnboardingProgressResolver(
      fetchProfile: () async => _profile(),
      reloadEmailVerified: () async => throw Exception('firebase down'),
    ).resolve()).node,
  );

  return targets;
}

/// Resume targets the registry deliberately cannot build, because their screen
/// needs a runtime argument no `WidgetBuilder` can supply. Each one must be
/// pushed directly with its argument by the screen that resolved it, and must
/// have a widget test proving that edge — `profileSetup` is covered by
/// `auth_leg_edges_test.dart`. Adding a node here without that edge is how B1
/// happened, so keep the set at exactly the nodes with a proven direct push.
const Set<OnboardingNode> _directPushResumeTargets = <OnboardingNode>{};

void main() {
  test('every resume target is reachable in the shipped app', () async {
    final Set<OnboardingNode> registered = onboardingRouteBuilders().keys
        .toSet();
    final Set<OnboardingNode> unroutable = (await _resumeTargets())
        .difference(registered)
        .difference(_directPushResumeTargets);

    expect(
      unroutable,
      isEmpty,
      reason:
          'the resolver can return ${unroutable.map((OnboardingNode n) => n.name)}, '
          'which the production registry cannot build and no screen pushes '
          'directly — sign-in would throw OnboardingRouteNotRegistered',
    );
  });

  test('no direct-push resume target is also registered', () {
    final Set<OnboardingNode> registered = onboardingRouteBuilders().keys
        .toSet();

    expect(
      _directPushResumeTargets.intersection(registered),
      isEmpty,
      reason:
          'a node the registry can now build must be dropped from the '
          'direct-push exemption instead of being covered twice',
    );
  });
}
