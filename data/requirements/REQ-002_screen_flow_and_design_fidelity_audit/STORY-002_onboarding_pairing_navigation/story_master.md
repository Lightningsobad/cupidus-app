# Story Master: STORY-002 Onboarding & Pairing Flow Navigation Correction

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-002
Scope: A (Screen Flow / Navigation Correction)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development)
- [x] Review (Reviewer) — `review/review-report.md`, Outcome: DEFERRED_ONLY
  (Iris-QC, Worktree HEAD `e40836d`, Tier-3 scoped review, all 5 phases +
  synthesis; B1/R5 patch verified)

## Implementation Phase Tracking
- [x] P1 Chain Contract & Progress Resolver (mobile-dev, 2026-08-14) —
  `OnboardingChain`, `OnboardingRouter`, `OnboardingProgressResolver` under
  `mobile/lib/core/navigation/`; 19 new unit/widget tests green, full mobile
  suite 939/939 green, analyze clean for the new files. Evidence in
  `coding-plan/phase-P1-chain-contract-and-progress-resolver.md`.
- [x] P2 Session Termination Signal (mobile-dev, 2026-08-14) — AC5/AC6 now
  differ from one signal source: `SessionTerminationNotifier` +
  `SessionTerminationListener` under `mobile/lib/core/`, published by
  `CupidAuthInterceptor` (`refreshFailed`, before teardown) and `SignOutCubit`
  (`userInitiated`, after teardown), consumed once at the app root from
  `PairGateShell`. Inline `pushAndRemoveUntil` removed from `SignOutAction`.
  12 new/updated tests green; `flutter analyze lib test` reports no
  error/warning and no issue in any file this phase touched. Evidence in
  `coding-plan/phase-P2-session-termination-signal.md`.
- [x] P3 Auth-Leg Edges (mobile-dev, 2026-08-14) — welcome/login/register/
  forgot route through `OnboardingRouter`/`OnboardingProgressResolver`
  (D1/D2). Commit `3416466` (`feat(STORY-002): Phase P3 auth-leg edges...`).
- [x] P4 Pairing-Leg Edges & Chrome (mobile-dev, 2026-08-14; committed by
  Scrum Master, commit `0807fd1`) — `_PairingStack` promoted to
  `PairingChoiceScreen`; header removed from invite/joincode with in-body
  back; `onPaired` defaults wired (invite→waiting→paired, joincode→paired
  directly). `flutter analyze lib test`: 0 errors, 0 warnings, 80 infos
  (repo idiom baseline). Full suite at BaseHead `3416466`: +1186 ~2 -6;
  branch: +1196 ~2 -6 — identical pre-existing failure set, 10 net-new
  passing tests, no regressions. Scoped `flutter test test/features/pairing`:
  +95 -2. Evidence in `coding-plan/phase-P4-pairing-leg-edges-and-chrome.md`.

  **Scrum Master-ratified deviations from the P4 phase plan:**
  1. `service_locator.dart` registers TWO `OnboardingNode` builders
     (`pairingChoice` and `paired`), not the single pre-approved one —
     without a `paired` builder, `OnboardingRouter._routeFor` throws
     `OnboardingRouteNotRegistered` at runtime since both pairing legs
     terminate in `router.resetTo(paired)`. Ratified: required for the
     router to function; no scope expansion beyond wiring the existing
     paired screen into the chain table.
  2. The plan's "move invite → waiting onto the router" was not executed.
     `WaitingScreen` needs the live invitation's `expiresAt`/`code`, which a
     registry `WidgetBuilder` cannot carry, and `onboarding_router.dart` was
     declared off-limits for this phase. The pre-existing direct push was
     kept with an explanatory code comment; `WaitingScreen` still owns the
     waiting → paired edge. Ratified: correct technical constraint, no
     narrower fix available inside this phase's write scope.
  3. `PairingChoiceScreen` keeps its two direct pushes to
     `InviteScreen`/`JoincodeScreen` to preserve the `create*Cubit` test
     seams required by master-plan section 5. Ratified: consistent with the
     plan's own cross-cutting rule to preserve those injection seams.
- [x] P5 Post-Pairing Tail & Chrome Guard (mobile-dev, 2026-08-14) — `paired`,
  `loveContract`, `vow` registered in `service_locator.dart`'s
  `OnboardingRouter` builders (previously only `pairingChoice`/`paired`
  existed, per P4); `home` registers `const PairGateShell()` (Scrum
  Master-ratified, not `HomeScreen()` — restores `SessionTerminationListener`/
  `ReminderOverlayHost` and is the sole place `CupidTabBar` mounts). New
  `chain_tail_edges_test.dart` (3/3) asserts `paired->loveContract->vow->home`
  and a full `register->home` traversal touches every chain node once (Sec 6
  blocker 6). New `chain_chrome_guard_test.dart` (18/18) asserts NO_CHROME/
  NO_TABS across all 14 chromeless nodes, with 4 known pre-existing breaches
  (`forgotPassword`/`otp`/`permissions`/`profileSetup` render `CupidHeader`)
  pinned in a self-cleaning `_trackedHeaderBreaches` set — see Cross-Story/
  Infra Finding in the Scrum Master checkpoint. `flutter analyze lib test`:
  80 issues, identical to BaseHead, 0 errors/warnings. `flutter test`: +1221
  ~2 -6, the 6 failures being exactly the pre-existing BaseHead set
  (`no_fork_guard`, `waiting_screen_design_fidelity`, `joincode_screen_design`,
  `login_screen`, `pet_design_fidelity`, `reminder_copy_guard`) — independently
  re-verified by Scrum Master (git status, scoped analyze, full test run),
  not just trusted from the worker's self-report. Evidence in
  `coding-plan/phase-P5-post-pairing-tail-and-chrome-guard.md`.

  **Scrum Master-ratified deviations/decisions for P5:**
  1. WriteScope extended to add `service_locator.dart` (registry-only edits)
     and widen `chain_chrome_guard_test.dart` to `mobile/test/core/navigation/**`
     — P5's phase doc omitted `service_locator.dart` despite master-plan §5
     requiring `vow`/`paired`/`loveContract` to be registered there.
  2. `OnboardingNode.home` target changed from `const HomeScreen()` to
     `const PairGateShell()` — bare `HomeScreen` mounts no `CupidTabBar`;
     `PairGateShell` restores the session-termination/reminder-overlay
     listeners that P4's `waiting_screen.dart` `resetTo(paired)` discards.
     Known residual gap (not a P5 blocker): those listeners stay unmounted
     for the narrow `paired`->`loveContract`->`vow` NO_CHROME tail until
     `PairGateShell` remounts at `home` — disclosed to Reviewer for AC5/AC6.
  3. Accepted the worker's `_trackedHeaderBreaches` pin-and-defer test design
     for the 4 pre-existing `CupidHeader` breaches (AC4) — confirmed against
     `ux/uiux-spec.md`'s unconditional Chrome Rules, not a design-intent
     question, so not routed to UI/UX. P5 cannot fix those screens (owned by
     already-DONE STORY-007/008/009/010, master-plan §5 forbids editing their
     bodies) — disclosed to Reviewer for AC4, flagged for a post-wave
     `add-bug`.

## Visual Fidelity (DONE-gate evidence, round 3, mobile-dev)
- Design-Screen: NONE for `pairing_choice` — Step A enumerated 37 canvas ids
  with no pairing-choice equivalent; Step B shortlisted `invite`, `joincode`,
  `profile`; Step C rendered and rejected all three by inspection (kept as
  audit trail, not a baseline for `implemented-pairingchoice-emulator-5560.png`).
  Gap code: `MOBILE_VISUAL_AUDIT_STATE_MISSING`. Evidence:
  `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/implemented-pairingchoice-emulator-5560.png`,
  `visual-fidelity/design-reference-{invite,joincode,profile}-android.png`.
- Scrum Master ruling: MOBILE_VISUAL_AUDIT_STATE_MISSING accepted as a
  legitimate no-design-source state (documented A-D audit trail, not a
  shortcut or a fabricated baseline); DONE-gate proceeds on this basis rather
  than requesting a net-new Pink-Designer canvas export, since F-B below shows
  an export would mean re-exporting the pairing leg — UX/product scope beyond
  this story's navigation-correction remit.
- Pre-existing `login_screen_test.dart:91` failure at BaseHead `06da664`
  confirmed unrelated/out-of-scope — already covered by the accepted
  caption-typography baseline finding; not a STORY-002 blocker.
- Cross-story findings surfaced during this audit (not this story's scope,
  routed to REQ-002 integration review / post-wave `add-bug`):
  - F-A: all three rendered canvas screens (`invite`/`joincode`/`profile`)
    carry a back-arrow + title app bar, contradicting `ux/uiux-spec.md`
    Chrome Rules (no header on any chain node) — relevant to whoever settles
    R3.
  - F-B: canvas CTAs encode a shorter chain order than the corrected graph
    (`profile` -> Love Contract, `invite` -> Fingerprint Vow) and never had a
    `pairing_choice` node — canvas source, not implementation, is stale here.

## Depends On
- STORY-007 (otp_design_fidelity), STORY-009 (permissions_design_fidelity),
  STORY-016 (fingerprint_vow_design_fidelity). These three Scope B stories
  own building the otp, permissions, and vow screens themselves to the
  locked design source; STORY-002 only wires the routing/transitions into
  and out of those screens and cannot be implemented against screens that do
  not yet exist in the app. See "Product Owner Ruling" below.
- Independent of STORY-001: a tester can still reach welcome/login directly
  without exercising the cold-launch decision, so STORY-001's status does
  not block this story; only the otp/permissions/vow legs are gated on
  STORY-007/STORY-009/STORY-016.

## User Story
As a user moving through account creation, verification, permission grants,
profile setup, and partner pairing, I want each screen to lead me to the
correct next screen in the intended sequence, so that I complete onboarding
and pairing without getting stuck, looped, or dropped onto the wrong screen.

## In Scope
1. Audit and correct forward/back navigation across the full onboarding/
   pairing chain: welcome → login or register; register → otp; otp success →
   permissions; login → forgot-password (and back) or → home if a pairing is
   already complete for that account; permissions → onboarding profile
   setup; profile setup → invite (create code) or join-code (enter code)
   choice; invite → waiting; join-code → waiting or directly to paired (per
   the backend's supported pairing-confirmation flow); waiting → paired;
   paired → love contract; contract → fingerprint vow; vow completion →
   home.
2. Confirm and correct chrome rules across this whole chain: no header
   (NO_CHROME) and no bottom tab bar (NO_TABS) on every screen in this
   sequence; the 5-tab bar must not appear until the user lands on home
   post-pairing.
3. Sign-out navigation: a deliberate, user-initiated sign-out from anywhere
   in the authenticated app tears down the session first, then routes to
   welcome (not login).
4. Mid-session forced re-auth: if a refresh-token failure occurs while the
   app is in active use (not at cold launch), the app routes to login (not
   welcome), preserving the distinction from sign-out.

## Out of Scope
- The cold-launch entry-routing decision itself (splash → welcome/login/home
  resolution) — that is STORY-001.
- Visual/design fidelity of any screen in this chain — each has its own
  Scope B story (STORY-004 through STORY-016).
- Any new onboarding step, screen, or business rule not already present in
  the locked design source.
- The main in-app 5-tab navigation behavior once inside home/chat/pet/money/
  me — only its correct entry point from vow → home is in scope here.

## Acceptance Criteria
1. Given a user on welcome, when they choose to sign in vs. create an
   account, then they reach login or register respectively, and each of
   those in turn leads to its correct next screen (otp for register; home or
   forgot-password for login) per the design source's flow.
2. Given a user completes otp verification for the first time, when otp
   succeeds, then they are routed through permissions → onboarding profile
   setup → invite/join-code choice, in that order, with no chain screen
   skipped and no loop back to welcome/login. (The otp and permissions
   screens themselves are built by STORY-007 and STORY-009 respectively;
   this criterion covers only the transition into and out of each screen,
   not the screen content.)
3. Given a user is mid-pairing (has created or entered a pairing code but
   pairing is not yet complete), when they reach the waiting screen, then
   completing pairing on the backend's supported flow routes them to paired,
   then contract, then vow, then home, in that order.
4. Given any screen in the onboarding/auth/pairing chain (splash through
   vow), when it renders, then it has no header chrome and no bottom tab
   bar, and the 5-tab bar first appears only on home after vow completes.
5. Given an authenticated user performs a deliberate sign-out, when the
   sign-out completes, then their session is torn down first and they are
   routed to welcome.
6. Given an authenticated user's session expires or refresh fails while they
   are actively using the app (not at cold launch), when that failure is
   detected, then they are routed to login, not welcome.

## Product Owner Ruling (2026-08-14)

A prior Tech Lead attempt on this story (blocker `MISSING_CHAIN_SCREENS`,
recorded 2026-08-12) found AC2/AC3 route through the otp, permissions, and
vow screens and, at that time, found those screens had no implementation
anywhere in the repo — recommending either new build stories that STORY-002
would depend on, or reclassifying STORY-002 as complex to absorb three
net-new screens. Re-checked against the current repo: `mobile/lib/main_preview.dart`
still lists `otp`, `permissions`, and `vow` in `_notImplementedCanvasIds`
with no shipped screen, confirming the blocker's finding was accurate at the
time. However, each of these three screens already has a dedicated Scope B
design-fidelity story in this same requirement's backlog — STORY-007
(otp_design_fidelity), STORY-009 (permissions_design_fidelity, registry
status DONE), and STORY-016 (fingerprint_vow_design_fidelity, build tasks
in progress/complete as of this ruling). Scope B design-fidelity stories in
this requirement are "fix, not audit" scope (see STORY-009 AC2: "the
deviation is corrected in the rendered app... and re-verified"), so they own
building each screen to match the locked design source, not merely auditing
a screen assumed to already exist.

Ruling: STORY-002's `Depends On` becomes STORY-007, STORY-009, STORY-016,
replacing NONE. These three stories own building/shipping the otp,
permissions, and vow screens themselves; STORY-002 owns only the
routing/transition logic connecting them, consistent with its existing "Out
of Scope" item ("Visual/design fidelity of any screen in this chain — each
has its own Scope B story"). Creating brand-new net-new-build stories, or
reclassifying STORY-002 as complex to absorb screen construction, is
unnecessary — the build owners already exist in the backlog. AC2 is amended
to make explicit that STORY-002 covers only the transition into and out of
the otp/permissions screens, not their content.

This does not authorize STORY-002 to build or modify the otp/permissions/vow
screen content itself, and does not change STORY-007/STORY-009/STORY-016's
independent design-fidelity scope. If any of those three stories is not yet
`MERGE_COMPLETE` when STORY-002 implementation is scheduled, STORY-002 stays
blocked on that exact dependency rather than absorbing the missing build
work.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the app's own onboarding/pairing screen
  sequence — no new entry point created; this story fixes the transitions
  between already-existing screens.
- Direct URL only acceptable: N/A (not applicable — internal flow
  navigation, not a feature reached by a link).

## Dependencies
- Depends on: STORY-007, STORY-009, STORY-016 (see "Product Owner Ruling"
  above).
- Must not require STORY-001: confirmed — no dependency on STORY-001's
  cold-launch entry-routing decision.

## Open Question Impact
No open question from the central registry has direct impact on this
story's scope.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-6) are unblocked.

## Open Items For Downstream Roles
- [x] [Tech Lead] Decide the exact navigation-guard/routing implementation for
  branching login → home vs. login → forgot-password vs. registration chain,
  and how the backend's pairing-confirmation signal (waiting → paired
  transition) is observed (poll vs. push) — implementation detail within
  this story's approved scope.
  **Resolved 2026-08-14** in `architecture/solution.md`:
  - Routing guard: ADR-1 (one declarative `OnboardingChain` table +
    `OnboardingRouter`, no `go_router` adoption) and ADR-2
    (`OnboardingProgressResolver` over `AccountRepository.fetchProfile()` +
    `AuthRepository.reloadEmailVerified()`; 5 ordered rules, failure falls
    back to `pairingChoice`).
  - Pairing confirmation: ADR-3 — **poll**, reusing the existing bounded
    `PartnerLinkPoller`/`WaitingCubit`. Push rejected (needs a new backend
    event contract, out of scope).
  - ADR-4 additionally resolves the UX spec's third Tech Lead item:
    `join_code` → `paired` directly because `acceptInvitation` confirms
    synchronously for the invitee; `invite` → `waiting` → `paired` because the
    inviter has no synchronous confirmation.
  - Deviation flagged for Reviewer: `waiting` is **not** a login resume target
    (no backend read exists for an outstanding self-created invitation);
    resume goes to `pairingChoice` instead. See ADR-2.
- [UI/UX Designer] Confirm no chain screen needs a transitional/loading state
  not already implied by the design source when waiting on a backend
  response (e.g. otp verification in flight, pairing confirmation in
  flight).
