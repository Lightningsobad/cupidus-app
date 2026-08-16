# Diagnosis: BUG-20260814-001 Chrome Header Breach (forgot_password/otp/permissions/onboarding_profile_setup)

Bug id: BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding
Scope classification: mobile (Flutter)
Impacted Runtime Service/App: mobile-app

## Input Anchors

- Failing/pinning test: `mobile/test/core/navigation/chain_chrome_guard_test.dart`,
  symbol `_trackedHeaderBreaches`
- Component: `CupidHeader` rendered on routes `forgotPassword`, `otp`,
  `permissions`, `profileSetup`
- Expected behavior source: `ux/uiux-spec.md` Chrome Rules (locked, unconditional)
- Query keys: `chain_chrome_guard_test`, `CupidHeader`, `_trackedHeaderBreaches`

## Pre-Fix Reproduction Gate

Original failure anchor: `chain_chrome_guard_test.dart` `_trackedHeaderBreaches`;
`CupidHeader` present on 4 chromeless routes.

Reproduction method and modality: widget-render test (same modality as the
STORY-002 P5 audit finding, which was itself produced by this guard harness).

Exact command:
`cd mobile && flutter test test/core/navigation/chain_chrome_guard_test.dart --reporter expanded`
(`flutter` resolved from `/Users/alantravala/flutter/bin`; not on default PATH)

Expected failure: the four chromeless auth/onboarding routes must render no
`CupidHeader`; the guard suite should therefore assert header absence for them.

Actual result (step 1, unmodified tree): 18/18 passed, but the four route tests
are named `renders no tab bar (AC4 header breach tracked)` instead of
`renders no header and no tab bar`. They deliberately drop the header assertion
and the routes are listed in `_trackedHeaderBreaches`. The suite is pinning the
defect rather than failing on it, so a green run is itself the reproduction
signal: the breach is present and accepted by the guard.

Actual result (step 2, breach pins removed): see `## Reproduction Hardening`
below — with the tracked-breach exemption removed the four routes fail with
`CupidHeader` found, proving the header renders on all four chromeless routes.

Result: REPRODUCED
Blocker type: N/A

## Reproduction Hardening

The guard suite could not fail on this defect as shipped, so the first change
was to remove the pin, not to patch a screen.

Change applied to `mobile/test/core/navigation/chain_chrome_guard_test.dart`:

- deleted the `_trackedHeaderBreaches` const set and its doc comment
- deleted the test `every tracked header breach is still a chain node`
  (it only guarded the pin list's own integrity and dies with the list)
- made the per-node header assertions unconditional, so every chromeless chain
  node now asserts `find.byType(CupidHeader)` and `find.byType(AppBar)` are
  `findsNothing`

With the pin removed and no production code touched, the suite failed exactly
4 times, one per reported route, each with
`<route> grew a header AC4 forbids`. That is the deterministic red state this
fix has to turn green, and it names precisely the four routes in the bug report
and no others.

## Expected vs Observed

Expected (`ux/uiux-spec.md` Chrome Rules, locked): "Applies to every node in
this chain, `splash` through `fingerprint_vow` (AC4) … No header/app-bar chrome
on any screen in this list … `home` is the first point in the entire flow where
the 5-tab bar appears." The rule is unconditional and enumerates no exceptions.

Observed: `forgot_password`, `otp`, `permissions`, and
`onboarding_profile_setup` each rendered a `CupidHeader` as their `Scaffold`
`appBar`.

## Root Cause

Not a shared composition-layer defect. There is no route wrapper, shell, or
header flag that these four screens inherit — `OnboardingRouter` builds each
chain node's screen widget directly, and `OnboardingChain.isChromeless(node)`
is a chain-level classifier that no screen consults before building its own
`Scaffold`.

Each of the four screens independently sets `appBar: CupidHeader(...)` on its
own `Scaffold`. So this is one defect *cluster* with four same-family call
sites: the locked Chrome Rule was never applied at screen composition time, and
each screen author instead followed the per-screen design source, which carries
a header block for these screens. `forgot_screen.dart` made that reasoning
explicit in a code comment claiming the design source's `NO_CHROME` map omits
`forgot` — a design-source detail that the spec's unconditional Chrome Rules
override.

The fix is therefore four localized `appBar:` removals, one per call site, plus
the reproduction hardening above. No shared code was modified, so no screen
outside the four reported routes changes behavior.

### Root-Cause Family / Cluster Boundary

- In-cluster (fixed here): `forgot_password`, `otp`, `permissions`,
  `onboarding_profile_setup` — all four are chain nodes covered by AC4 Chrome
  Rules and all four carried a self-composed `CupidHeader`.
- Adjacent but out of scope: `welcome_screen.dart` is tracked separately as
  BUG-20260816-001 and was deliberately not touched.
- Verified not in cluster: every other chromeless chain node already asserted
  header absence in the guard suite before this fix and still passes with the
  now-unconditional assertion, so no additional breach sites exist in the chain.

## Risk Surfaces

1. **Lost back affordance.** `CupidHeader` carried the back arrow on
   `forgot_password`. `ux/uiux-spec.md:34` locks the transition
   (`forgot_password | back | login`) but does not prescribe the affordance,
   and the sibling `register` leg — also chromeless — already relies on the
   platform back gesture. The back leg is preserved via `Navigator.pop`, and
   the regression test now exercises it through `handlePopRoute()` instead of a
   header tap. Confirmed on-device: hardware back from `forgot` returns to
   `login`.
2. **Content sliding under the status bar.** All four screens already wrap
   their `body` in `SafeArea`, so removing the `AppBar` does not push content
   into the status-bar inset. Confirmed visually on emulator for all four
   routes.
3. **Same-family tests asserting the removed header.** Six tests across five
   files asserted header text or the header back arrow. Each was corrected to
   the AC4 expectation rather than deleted, and three of them were strengthened
   into explicit "no header chrome" regression assertions.

## Files And Ranges Inspected

- `mobile/test/core/navigation/chain_chrome_guard_test.dart` (full; ~250 lines)
- `mobile/lib/features/auth/presentation/screens/forgot_screen.dart` (ranged, around the `Scaffold`)
- `mobile/lib/features/auth/presentation/screens/otp_screen.dart` (ranged)
- `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart` (ranged)
- `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` (ranged)
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/ux/uiux-spec.md` (lines 30-40, 62-68)
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/story_master.md` (lines 99-105)
- `data/devops/system/runtime-command-registry.json` (`mobile-app` block, lines 89-168)
- `mobile/lib/main_preview.dart` (preview id list only)

## Stop-Rule Check

The bug-fixer stop rule requires halting if the guard test's expected chrome
behavior conflicts with other locked spec text. A candidate conflict was found
and resolved without guessing:

- `forgot_screen.dart` carried a comment asserting the design source's
  `NO_CHROME` map omits `forgot`, and the guard test comment suggested the
  headers "may well be deliberate".
- `story_master.md:99-105` records the already-made adjudication: the
  `_trackedHeaderBreaches` pin design was accepted, confirmed against
  `ux/uiux-spec.md`'s unconditional Chrome Rules, explicitly ruled "not a
  design-intent question, so not routed to UI/UX", and deferred solely because
  STORY-002/P5 had no write scope over the already-DONE STORY-007/008/009/010
  screen bodies.

The precedence question was therefore already decided by a locked artifact, not
by this session. No blocker raised.

## Context Ledger

- Anchors used: `_trackedHeaderBreaches`, `CupidHeader`, route ids
  `forgotPassword`/`otp`/`permissions`/`profileSetup`
- Large-file full reads: `chain_chrome_guard_test.dart` only (the named failure
  anchor); every other source file was read by range
- `data/**` artifacts: grep-then-ranged-read only; no full reads
