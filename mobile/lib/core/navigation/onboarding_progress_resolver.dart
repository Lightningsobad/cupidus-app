import '../../features/account/domain/cupid_profile.dart';
import 'onboarding_chain.dart';

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
  Future<OnboardingNode> resolve() async {
    try {
      final CupidProfile profile = await _fetchProfile();

      if (profile.partnerId != null) {
        return profile.vowTaken
            ? OnboardingNode.home
            : OnboardingNode.loveContract;
      }

      if (!await _reloadEmailVerified()) {
        return OnboardingNode.otp;
      }

      if (profile.displayName == null) {
        return OnboardingNode.profileSetup;
      }

      return OnboardingNode.pairingChoice;
    } catch (_) {
      return OnboardingNode.pairingChoice;
    }
  }
}
