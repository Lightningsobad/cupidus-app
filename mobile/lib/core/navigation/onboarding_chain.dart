/// `architecture/solution.md` ADR-1: the canonical onboarding/pairing chain
/// order, expressed once instead of being hardcoded per screen as an inline
/// `Navigator.push`. Deliberately widget-free (no Flutter imports) so AC2/AC3
/// ordering is provable by unit tests rather than widget tests.
library;

/// Every node of the onboarding/pairing chain from `ux/uiux-spec.md`
/// § "Screens/Nodes Touched", plus `home` as the chain's exit.
enum OnboardingNode {
  welcome,
  login,
  register,
  forgotPassword,
  otp,
  permissions,
  profileSetup,
  pairingChoice,
  invite,
  joinCode,
  waiting,
  paired,
  loveContract,
  vow,
  home,
}

abstract final class OnboardingChain {
  /// `ux/uiux-spec.md` § "Corrected Navigation Graph". Branching nodes
  /// (`welcome`, `login`, `pairingChoice`) and terminals (`forgotPassword`,
  /// `home`) are absent on purpose: encoding a default successor for them
  /// would be a fake edge the UX graph does not have.
  static const Map<OnboardingNode, OnboardingNode> _forwardOrder =
      <OnboardingNode, OnboardingNode>{
        OnboardingNode.register: OnboardingNode.otp,
        OnboardingNode.otp: OnboardingNode.permissions,
        OnboardingNode.permissions: OnboardingNode.profileSetup,
        OnboardingNode.profileSetup: OnboardingNode.pairingChoice,
        OnboardingNode.invite: OnboardingNode.waiting,
        OnboardingNode.waiting: OnboardingNode.paired,
        // ADR-4: `acceptInvitation(code)` confirms synchronously for the
        // invitee, so the join-code branch has no `waiting` step.
        OnboardingNode.joinCode: OnboardingNode.paired,
        OnboardingNode.paired: OnboardingNode.loveContract,
        OnboardingNode.loveContract: OnboardingNode.vow,
        OnboardingNode.vow: OnboardingNode.home,
      };

  /// The single successor of [from], or `null` when the caller must choose
  /// (branching node) or the chain ends here.
  static OnboardingNode? next(OnboardingNode from) => _forwardOrder[from];

  /// AC4 NO_CHROME/NO_TABS membership. `home` is the first 5-tab surface in
  /// the entire flow; everything before it is chromeless.
  static bool isChromeless(OnboardingNode node) => node != OnboardingNode.home;
}
