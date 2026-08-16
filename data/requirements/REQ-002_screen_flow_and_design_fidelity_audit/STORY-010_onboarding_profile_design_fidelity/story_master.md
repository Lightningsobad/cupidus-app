# Story Master: STORY-010 Design Fidelity — Onboarding Profile Setup

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: profile (onboarding setup step), Epic 1 (Core connection /
onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:design-source-complete
- [x] Architecture (Tech Lead) — `coding-plan/master-plan.md` (decisions D1-D8
      are the architecture record; no separate `architecture/solution.md`)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B. See "Coordination
  note" below for the one-directional relationship with STORY-002.

## User Story
As a user setting up my profile during onboarding, I want the screen to
match the locked design source exactly, so the app feels visually
consistent and trustworthy while I set up my identity.

## In Scope
1. The onboarding profile-setup screen (canvas `profile` in
   `cupid-app-design-system`) does not exist in the shipped app today — the
   real onboarding chain runs `register -> HomeScreen` with no profile step,
   and the app's only profile screen is `ProfileEditScreen`, reachable
   exclusively from the Me hub tab (`me_screen.dart:59`, STORY-029's
   screen). Build this screen as new: a screen genuinely and structurally
   distinct from `ProfileEditScreen` — its own widget/file, its own class,
   no shared screen implementation between the two stories.
2. Match `cupid-app-design-system`'s canvas `profile`
   (`Cupid Screens.dc.html:93-119`) exactly for the enabled dark theme + `vi`
   locale: avatar/photo upload slot (`<image-slot id="cupid-onb-avatar">`
   generic upload/crop widget), the three info cards (display name, date of
   birth + auto-derived zodiac, language), and the "Tiếp tục → Love
   Contract" CTA. The design source renders these fields as static display
   text (`{{ myName }}`, `{{ myDob }}`, `{{ langLabel }}`), not editable
   form inputs — implement it as authored (a confirmation/display step),
   not as an editable form, unless Tech Lead's coding plan finds a concrete
   product reason the underlying data requires in-place editing here.
3. Register the new screen as its own named route/widget in the app so it
   is directly renderable, previewable, and covered by widget tests,
   following the same preview-capture pattern already established on this
   story's branch for `ProfileEditScreen` (`main_preview.dart` canvas
   registry, `--dart-define=PREVIEW_PROFILE=fixture`-style fixture). This
   registration is scoped to making the screen exist and be verifiable — it
   is not the same thing as wiring it into the live onboarding navigation
   chain (see Out of Scope).
4. This screen is distinct from the Epic 6 "Me / Profile" screen
   (STORY-029) — this story covers only the one-time onboarding profile
   setup step, not the ongoing profile-management screen. The design source
   itself keeps these separate: `cupid-onb-avatar` (canvas `profile`) vs.
   `cupid-me-avatar` (canvas `me`) are different `<image-slot>` ids, and
   canvas `profile` sits in the onboarding chain (`BACK_TO.profile ==
   'permissions'`) while canvas `me` is a bottom-tab destination (`TABS`
   includes `me`).

## Out of Scope
- The Epic 6 "Me / Profile" screen and its `ProfileEditScreen`
  implementation — separate screen, separate story (STORY-029). No code or
  type sharing between the two screens is required or expected.
- Wiring this screen into the live onboarding navigation chain (`permissions
  -> profile -> invite`/`join-code`). STORY-002 ("Onboarding & Pairing Flow
  Navigation Correction") already owns this transition by name in its own
  In Scope §1 and AC2. This story delivers the screen itself, registered on
  its own route for direct rendering/testing; it must not modify onboarding
  navigation, router, or permissions-screen "next" logic. See "Coordination
  note" below.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Coordination note (screen ownership vs. STORY-002)
STORY-010 owns building the screen; STORY-002 (Scope A, currently PENDING)
owns wiring it into the live onboarding flow, per STORY-002's own In Scope
§1 ("permissions → onboarding profile setup") and AC2. This is a
one-directional dependency in practice even though scheduling keeps both
stories at `Depends On: NONE`: STORY-002 cannot satisfy its own AC2 until
this screen exists to route to, but this story does not need STORY-002 to
complete first. Scrum Master should make sure whichever story's implementer
starts second is handed the other story's screen class/route name so the
eventual wiring is a small, unambiguous change rather than a second
discovery process.

## Disposition of already-implemented `ProfileEditScreen` work
This story's branch already carries `ProfileEditScreen` changes
(`mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`,
tests, and the `main_preview.dart` canvas-`profile` fixture wiring, through
reviewed HEAD `49c7eab`) built under the now-rejected premise that canvas
`profile` and `ProfileEditScreen` were the same screen. That work is out of
STORY-010's revised scope:
- It is not reverted by this story.
- It becomes STORY-029's concern, not STORY-010's. STORY-029's future
  implementer/reviewer must independently decide whether `ProfileEditScreen`
  is correctly design-matched — including whether canvas `profile`'s visual
  language is in fact the right fidelity target for the Me hub's "edit"
  affordance (`Cupid Screens.dc.html:982`, which has no design-specified
  target of its own) — and must independently resolve this branch's
  round-2 review's deferred findings R3/R7/R8 (label text, copy-wrap
  layout, header "Lưu" action) and D-2/D-5 in STORY-029's own scope. This
  story does not inherit or continue that review thread.
- Because the existing implementation does not satisfy this story's revised
  scope (it does not build a screen distinct from `ProfileEditScreen`), the
  Implementation checkbox above is reset to unchecked; STORY-010 needs new
  implementation work building the actual distinct onboarding screen.
- Recommended for `scrum-master`: decide whether `mobile-dev` removes the
  `ProfileEditScreen` changes from STORY-010's branch (leaving them for a
  future STORY-029 branch to pick up fresh) or Scrum Master reassigns/merges
  that commit range directly into STORY-029's scope. Either resolves the
  branch cleanly; STORY-010 needs new commits regardless.

**Scrum Master Disposition — 2026-08-14 (round-3 review F2):** route (a) —
remove. `mobile-dev` is instructed to drop `1e60af5`/`49c7eab`'s
`ProfileEditScreen` range from this branch by reverting
`mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`
and `mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart`
to their content at `bf808483223580df81b1fb951b141a6597cb82dd` (the
merge-base of this branch and
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`, verified
byte-identical to integration's current tip — i.e. neither file has been
touched by any other merged story since this branch forked). Reassignment
into STORY-029 was rejected: STORY-029's already-committed implementation
(`8ee9614`) only touches `me_screen.dart`/`account_cubit.dart` (its
`Design-Screen: me`, the hub tab) and never touches `profile_edit_screen.dart`;
grafting a premise-flawed commit range (built against the now-rejected
"canvas `profile` == `ProfileEditScreen`" theory, per round-2's own F3) onto
a branch already at STORY-029's own review gate would be new scope creep, not
a clean reassignment.

**Open gap flagged for `product-owner` (not blocking this story):** after
this revert, `ProfileEditScreen`'s own design fidelity against
`Cupid Screens.dc.html:982` (the Me-hub "edit" affordance, which — per this
section's original note — has no design-specified canvas target of its own)
is not in any REQ-002 Scope B story's written scope. STORY-029 covers only
the `me` hub tab per its own `Design-Screen: me` / In Scope §1. This is a
backlog-completeness question for a future story, not something either
STORY-010 or STORY-029 should absorb under this decision.

## Acceptance Criteria
1. Given the new onboarding profile-setup screen rendered in the enabled
   dark theme + `vi` locale, when compared against `cupid-app-design-system`
   canvas `profile`, then layout, spacing, color/token usage, and typography
   match exactly with no visible deviation, **except** for the four
   shared `mobile/lib/design_system/`-layer deltas ratified out of this
   story's scope by the "Product Owner Ruling" section below (ambient
   `skyGradient` backdrop, `CupidHeader` back-arrow ink, the `caption` text
   style's sub-13px sizing and its resulting wrap, CTA gradient axis) —
   those are owned by STORY-033 and are satisfied here at whatever state
   the shared design-system layer is in as of this story's write scope.
2. Given any deviation from canvas `profile` is found during this story's
   build **inside this story's own write scope** (i.e., not the four
   shared-layer deltas excluded by AC1 and the "Product Owner Ruling"
   section below), when the story is delivered, then the deviation is
   corrected in the rendered app (not merely documented) and re-verified
   against the design source. Deviations that originate in shared
   `mobile/lib/design_system/` widgets/tokens (including `CupidHeader`) are
   out of this story's correction scope; see STORY-033.
3. Given the avatar/photo upload slot on this screen, when rendered in its
   empty and populated states, then it matches the design source's
   `<image-slot id="cupid-onb-avatar">` generic upload/crop widget styling
   exactly.
4. Given the new screen is implemented and registered on its own route,
   when it is rendered directly (preview harness or widget test) without
   relying on live onboarding navigation, then it renders correctly on its
   own — this story's ACs do not require STORY-002's navigation wiring to
   be complete, and this story does not add or modify any live in-app
   navigation transition itself.

## Product Owner Ruling — 2026-08-14

**Ratifies round-3 review finding F1** (`review/review-report.md`, BaseHead
`165c0af` / Reviewed HEAD `a8d0fed`): the `VISUAL_FIDELITY: FAIL` verdict
against AC1/AC2 was unratified because four residual visual deltas are real
but all live in the shared `mobile/lib/design_system/` layer (and the
shared `CupidHeader` widget), strictly outside mobile-dev's declared
seven-file write scope for this story. Per the review's Action Item #1,
route (a) — ratify — is adopted.

**Deltas excluded from this story's AC1/AC2, owned by STORY-033:**
1. Missing ambient `skyGradient` backdrop widget (aurora wash + sparkle
   dots) behind the screen content.
2. `CupidHeader` back-arrow ink renders in primary text ink instead of the
   design source's pink.
3. The `caption` text style's declared 13px causes four elements authored
   at 11/11.5/12.5px to render oversized, with a layout consequence: the
   zodiac helper text wraps to two lines instead of the reference's one,
   pushing the DOB card taller.
4. CTA gradient axis renders at 120deg against the design canvas's 95deg.

**Rationale:** these are design-system/shared-component defects, not
onboarding-screen defects — every element this story actually authored is
present, correctly ordered, and pixel-accurate (per the review's
independently-verified §3 element table). Fixing them inside STORY-010
would require expanding write scope into shared design-system files that
every other screen in this parallel wave also consumes, which review
Action Item #1 correctly flags as a cross-screen change that should be its
own story rather than a patch to this branch. STORY-033 (see
`../STORY-033_app_shell_design_system_deltas/story_master.md`) is created
as the owner story; each of its fixes is expected to move every screen in
the live parallel wave that consumes the same shared piece, this one
included, without STORY-010 needing further implementation work.

**ID note (scrum-master, 2026-08-14):** the owner story was drafted here as
"STORY-032"; renumbered to STORY-033 at merge-reconciliation time because a
different, already-registered STORY-032
(`../STORY-032_design_system_app_shell_follow_up/story_master.md`) existed
on another branch not yet visible from this one when this ruling was
written. No scope content changed — only the ID and the path below.

**Scope boundary — explicit disclaimer:** this ruling rescopes AC1/AC2's
acceptance bar only. It does **not** authorize `mobile-dev` or any other
role to build the aurora `skyGradient` backdrop widget, fix the
`CupidHeader` back-arrow ink, fix the `caption` text style's sub-13px
sizing/wrap regression, or fix the CTA gradient axis under STORY-010. Those
four fixes belong exclusively to STORY-033's write scope.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NONE yet — this is a new screen. It is not
  reachable through live user navigation as of this story; that wiring is
  STORY-002's AC2, tracked separately (see Coordination note). This story's
  own verification uses direct route rendering / a preview-capture fixture,
  not the live onboarding flow.
- Direct URL only acceptable: N/A — internal onboarding step screen, not a
  feature reached by a link.

## Dependencies
- Depends on: NONE for this story's own execution and scheduling.
- Must not require any future story to satisfy this story's own ACs:
  confirmed (AC4 above explicitly decouples from STORY-002).
- Note for `scrum-master`: STORY-002's AC2 depends on this story's output
  (see Coordination note) — that is a dependency on STORY-002's side, not
  this story's.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-4) are unblocked.

## Open Items For Downstream Roles
- [Tech Lead] RESOLVED — route/screen registration: route-factory class
  `OnboardingProfileSetupRoute` (`/onboarding/profile`) mirroring the existing
  `features/pet/presentation/pet_route.dart` precedent, plus repointing the
  `main_preview.dart` canvas `profile` entry to the new screen. This app has no
  global routes table. See `coding-plan/master-plan.md` D2/D3.
- [Tech Lead] RESOLVED — data source: `AccountRepository.fetchProfile()`
  (`GET /users/me`) → `CupidProfile`, passed IN to a purely presentational
  screen; the screen performs no I/O and renders the fields as static display
  text per the canvas. `displayName` may be present after register but
  `birthday` can be null (register collects no DOB), so null fields render `—`
  and the zodiac chip hides. See `coding-plan/master-plan.md` D4/D5.
- [Tech Lead] RESOLVED — screen identity for STORY-002's wiring:
  class `OnboardingProfileSetupScreen` at
  `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`,
  entry point `OnboardingProfileSetupRoute.push(context, profile:, onContinue:)`
  at `mobile/lib/features/onboarding/presentation/onboarding_profile_setup_route.dart`.
  STORY-002 supplies both the `CupidProfile` and the CTA destination.
