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
- [ ] Architecture (Tech Lead)
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

## Acceptance Criteria
1. Given the new onboarding profile-setup screen rendered in the enabled
   dark theme + `vi` locale, when compared against `cupid-app-design-system`
   canvas `profile`, then layout, spacing, color/token usage, and typography
   match exactly with no visible deviation.
2. Given any deviation from canvas `profile` is found during this story's
   build, when the story is delivered, then the deviation is corrected in
   the rendered app (not merely documented) and re-verified against the
   design source.
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
- [Tech Lead] Decide the concrete route/screen registration approach (named
  route vs. preview-only widget) and the data source for the screen's three
  display fields (display name, DOB, language) at first render — e.g.
  whether these are guaranteed already present on the account by the time a
  user reaches this step, or need a fetch. Record this in
  `coding-plan/master-plan.md` per this story's `Story-Class: standard`.
- [Tech Lead] Confirm the new screen's file location and class name so
  Scrum Master can pass them to STORY-002's future implementer for the
  eventual navigation wiring.
