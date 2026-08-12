# Story Brief: STORY-002 Onboarding & Pairing Flow Navigation Correction

- Actor: any user moving through account creation, verification,
  permissions, profile setup, and partner pairing.
- Capability: every screen in the onboarding/pairing chain leads to its
  correct next screen; sign-out and mid-session re-auth route to their
  correct, distinct targets.
- Business value: users complete onboarding/pairing without getting stuck,
  looped, or dropped onto the wrong screen.
- Key business rules: NO_CHROME/NO_TABS across the whole chain (splash
  through vow); 5-tab bar appears only on home post-pairing; deliberate
  sign-out → welcome (session torn down first); mid-session forced re-auth →
  login. These two forced-navigation targets must stay distinct.
- Key edge/failure case: otp/pairing-confirmation screens must not skip a
  chain step or loop back to welcome/login on success.
- Existing system entry/discoverability seed: existing onboarding/pairing
  screen sequence — no new entry point, only transitions between existing
  screens change.
- Direct AC/OQ anchors: AC1-6 in `story_master.md`; no OQ blocks this story.
- Complexity and why: standard — new architecture decision needed (routing/
  guard logic across the chain, pairing-confirmation signal handling), Lane:
  shared (UX + Tech Lead input required).
- Dependencies: NONE. Independent of STORY-001 and all Scope B stories.
