import '../../features/account/domain/cupid_profile.dart';
import 'onboarding_chain.dart';

/// A resume target plus the profile the rule table already read.
///
/// `profileSetup` is the one outcome the router registry cannot build — its
/// screen needs a resolved [CupidProfile] no `WidgetBuilder` can supply — so
/// the caller pushes that route itself and needs the profile to do it.
/// [profile] is null only on the failure fallback, where no profile was read.
class OnboardingResume {
  const OnboardingResume(this.node, {this.profile});

  final OnboardingNode node;
  final CupidProfile? profile;
}

/// `architecture/solution.md` ADR-2: resolves where a returning sign-in lands
/// in the chain, from signals `GET /users/me` and Firebase already expose. No
/// new endpoint or field.
///
/// The two reads are injected as functions (mirroring `PairGateCubit`'s and
/// `SessionGateCubit`'s seams) rather than as repositories, so the rule table
/// is unit-testable without Dio or Firebase.
///
/// `waiting` and `permissions` are deliberately absent from the outcomes: the
/// backend exposes no read for an outstanding invitation the user created, and
/// `permissions` is a first-run-only OS prompt step (ADR-2).
class OnboardingProgressResolver {
  const OnboardingProgressResolver({
    required this._fetchProfile,
    required this._reloadEmailVerified,
  });

  final Future<CupidProfile> Function() _fetchProfile;
  final Future<bool> Function() _reloadEmailVerified;

  /// ADR-2's ordered rule table, first match wins. Any failure falls back to
  /// `pairingChoice`, mirroring `pair_gate_cubit.dart`: an unresolved check
  /// must never grant access to a paired-only surface.
  Future<OnboardingResume> resolve() async {
    try {
      final CupidProfile profile = await _fetchProfile();

      if (profile.partnerId != null) {
        return OnboardingResume(
          profile.vowTaken ? OnboardingNode.home : OnboardingNode.loveContract,
          profile: profile,
        );
      }

      if (!await _reloadEmailVerified()) {
        return OnboardingResume(OnboardingNode.otp, profile: profile);
      }

      if (profile.displayName == null) {
        return OnboardingResume(
          OnboardingNode.profileSetup,
          profile: profile,
        );
      }

      return OnboardingResume(OnboardingNode.pairingChoice, profile: profile);
    } catch (_) {
      return const OnboardingResume(OnboardingNode.pairingChoice);
    }
  }
}
