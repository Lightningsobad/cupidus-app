# Story Requirements: STORY-046 Hardening - Shared Screen Backdrop Occlusion Fix

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening/story_master.md`
- Additional input files: `data/retro-audit/rework-backlog.md` item
  RWB-20260816-013 (source finding, already extracted into story master's own
  `## Background (Rework Item)`); STORY-037's
  `review/review-report.md` cycle 2 DEF-1 (the finding that opened this item;
  its enumeration of the 6 remaining call sites matches this story's own
  scope); STORY-032's `review/review-report.md` AC1 and
  `mobile/lib/features/auth/presentation/screens/forgot_screen.dart:99-107`
  (the original precedent fix, confirmed current in source at time of
  scoping).

## Business Summary

- Primary actor: none directly — this is a visual-correctness hardening item
  benefiting every end user who reaches any of the 6 affected screens; the
  requesting party is the REQ-002 design-fidelity audit trail (via
  RWB-20260816-013).
- Problem to solve: 6 sibling screens each set an opaque
  `backgroundColor: colors.colorBackground` on their own `Scaffold`. This
  solid-fill override paints over and hides the shared `CupidAppBackground`
  sky-gradient wash that is mounted once at `cupid_app.dart:59` and is meant
  to show through every screen in the app. STORY-032 AC1 already fixed the
  first instance of this exact defect (`forgot_screen.dart`) and STORY-037
  fixed a second instance (`invite_screen.dart`) found independently by its
  own reviewer; neither fix was swept to the remaining call sites, which are
  the 6 screens in this story's scope.
- Business outcome: all 6 screens render with the same shared sky-gradient
  backdrop as every other screen in the app, matching the confirmed design
  source and closing the last known instances of this defect pattern
  (RWB-20260816-013).
- Success signal: on each of the 6 named screens, the `Scaffold`'s
  `backgroundColor:` override is gone, the shared `--sky` wash is visibly
  unoccluded, and each screen's own already-passing content/layout
  fidelity is unchanged.
- Complexity: trivial (routing rule: no new screens, no new UX decisions, no
  new architecture decisions, single implementation lane — see "Why this
  complexity" below; overrides the story master's own `TBD`/"likely standard"
  placeholder, which pre-dated this scoping pass).
- Why this complexity: `.claude/skills/product-owner/references/complexity-routing.md`
  classifies a story as `standard` only if it needs new screens, new UX
  decisions, new architecture decisions, or spans more than one
  implementation lane. This story touches 6 existing screens with one
  already-proven mechanical remediation (delete one `Scaffold` property,
  applied identically twice before in this same requirement), no new design
  decision, and only the `mobile` lane. Per that reference's own Lane
  Consistency Rule, a single-lane story (`Implementation Lane: mobile`)
  bypassing UX/Architecture must be classified `trivial`, not `standard` —
  `standard` + a single non-`shared` lane is internally inconsistent and is
  rejected by the lane-consistency gate. UX Design and Architecture are
  therefore marked `SKIPPED:trivial` below, not left open for their normal
  specialists.
- Primary implementation lane: mobile (single lane; never `shared` for a
  `trivial` story per the routing reference).

## Scope Decision

### In Scope

1. Remove the `backgroundColor: colors.colorBackground` (or equivalent
   opaque solid-fill) property from the `Scaffold` on each of these 6
   screens, following the `forgot_screen.dart:99-107` precedent comment
   (STORY-032 AC1) exactly as STORY-037 AC-equivalent work already did for
   `invite_screen.dart`:
   1. `mobile/lib/features/auth/presentation/screens/otp_screen.dart:79`
      (Design-Screen: `otp`)
   2. `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart:109`
      (Design-Screen: `contract`)
   3. `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart:85`
      (Design-Screen: `profile`)
   4. `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart:107`
      (Design-Screen: `permissions`)
   5. `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart:125`
      (Design-Screen: `joincode`)
   6. `mobile/lib/features/vow/presentation/screens/vow_screen.dart:169`
      (Design-Screen: `vow`)

   Path correction: the story master's own `## Background` section lists all
   6 files under `mobile/lib/features/pairing/presentation/screens/`. Only
   `joincode_screen.dart` actually lives there; the other 5 files live in
   their own feature directories as listed above (confirmed by direct
   grep/read of each file at the exact line number the story master cites —
   all 6 line numbers are correct, only the directory prefix was wrong for 5
   of the 6). Implementer must use the paths in this section, not the
   Background section's paths.
2. On each screen, if removing the `backgroundColor:` line leaves the local
   `colors` (`context.cupidColors`) variable with zero remaining uses on
   that screen, remove the now-unused local too — the same cleanup STORY-037
   made for `invite_screen.dart`. If `colors` is still used elsewhere on the
   screen (for text/border/icon tokens, etc.), leave it in place.
3. Per-screen verification evidence: for each of the 6 screens, produce at
   minimum a screen-backdrop probe (sampled pixel color(s) confirming the
   shared `--sky` wash renders through where the solid override previously
   painted), or a full rendered evidence pair
   (`implemented-<screen>-<device>.png` vs. the screen's own existing
   `design-reference-<screen>-android.png`) if a fresh capture is simpler to
   produce alongside the probe. Existing design-reference renders for all 6
   screens (from STORY-007, STORY-009, STORY-010, STORY-012, STORY-015,
   STORY-016 respectively) are reusable as-is: each already
   independently confirmed its own screen's content/layout/typography as
   `MATCH` prior to this story, and this story's own defect (an opaque
   `Scaffold` backdrop fill) is verifiable directly from source and from a
   backdrop-only probe, not from re-diffing the full screen image against a
   stale capture.
4. `flutter analyze` and the existing `flutter test` suite pass clean after
   all 6 edits (no new unused-import/unused-variable warnings from the
   removed override or local).

### Out of Scope

- Any content, layout, spacing, typography, or component-level fidelity
  change on any of the 6 screens beyond the backdrop-override removal — each
  screen's own STORY-007/009/010/012/015/016 already confirmed those
  aspects `MATCH` and that scope is not reopened here.
- Any new screen, new navigation entry point, new interaction, or new
  design decision. All 6 screens keep their existing reachability paths,
  unchanged by this story.
- Sweeping the same override pattern to any screen not named in this
  story's own 6-item list, even if a similar override is later found
  elsewhere — a new instance outside this list is a new finding, not this
  story's scope.
- Reopening or editing the closed git boundary/branch of STORY-007, 009,
  010, 012, 015, 016, STORY-032, or STORY-037.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet; same precedent exclusion as STORY-037 and every
  other REQ-002 Scope B story). The shared `--sky` wash fix is a
  shell/token-level correction to the enabled dark + `vi` configuration
  only.

## System Integration And Discoverability

- UI-facing story: YES (6 existing screens; no new UI surface).
- Existing user-visible surface, workflow, or state where the actor starts:
  each of the 6 screens is already reachable in the shipped app through its
  own existing navigation path (OTP verification, love contract, onboarding
  profile setup, permissions, join/enter pairing code, fingerprint vow) —
  none of that changes.
- Required entry point, navigation item, CTA, or in-flow discovery path:
  unchanged for all 6 screens; this story only removes a backdrop paint
  override, it does not touch navigation.
- Direct URL only acceptable: N/A — all 6 are existing reachable screens,
  not new.
- Which screen of the design source this story covers: 6 screens, one per
  item in `## In Scope` above, identified unambiguously by file path plus
  `Design-Screen:` id: `otp`, `contract`, `profile`, `permissions`,
  `joincode`, `vow`. All 6 ids are already confirmed/recorded in their own
  originating stories' `story_master.md` files; no new id resolution is
  needed.
- Existing user journey affected: none — the OTP verification, love
  contract, onboarding profile setup, permissions, join/enter pairing code,
  and fingerprint vow steps of the pairing/onboarding journey keep their
  existing order and behavior.
- Out-of-scope integration surfaces: any screen not in the 6-item list; any
  navigation, persistence, or backend surface (this is a pure presentation
  paint-layer fix).

## Business Rules And Guardrails

- The remediation is mechanical and identical across all 6 screens: delete
  the `backgroundColor:` line (and its value expression) from the
  `Scaffold` constructor; do not replace it with any other color, gradient,
  or `Container`-level fill — the shared `CupidAppBackground` app-shell
  layer already supplies the backdrop for every screen.
- Preserve the removed line as an explanatory comment following the
  `forgot_screen.dart:103-106` precedent wording (or materially equivalent
  wording), so a future reader understands why no `backgroundColor:` is
  set here, matching the pattern already established twice in this
  requirement (STORY-032, STORY-037).
- Do not alter any other `Scaffold` property (`appBar`, `body`,
  `resizeToAvoidBottomInset`, etc.) on any of the 6 screens.
- Each of the 6 screens must be independently verified — a probe or
  evidence pair confirming one screen's backdrop is unoccluded is not
  evidence for any other screen.
- If verification on any one of the 6 screens surfaces a second, different
  defect (not the backdrop-override pattern), record it as a new finding
  and do not silently expand this story's scope to fix it.

## User Story

As a user of the app reaching any of the OTP verification, love contract,
onboarding profile setup, permissions, join/enter pairing code, or
fingerprint vow screens,
I want the same sky-gradient backdrop the rest of the app already shows
behind me,
So that the screen matches the confirmed design and does not look like a
flat, disconnected panel dropped on top of the app.

## Edge Cases And Failure Behavior

- If the local `colors` variable is still referenced elsewhere on a given
  screen after the override is removed (e.g., for text or icon token
  colors), it must be kept — only remove it where it becomes fully unused,
  per screen, not as a blanket rule across all 6.
- If a screen's existing design-reference render (from its originating
  STORY-007/009/010/012/015/016) is found to be stale or not representative
  of the screen's current state when reused for verification, do not treat
  it as authoritative — flag it and fall back to a fresh screen-backdrop
  probe for that screen instead of silently passing on a stale comparison.
- If `flutter analyze` reports any new warning introduced by one of the 6
  edits (e.g., an unused import left behind), it must be cleaned up as part
  of this same story, not deferred.

## Acceptance Criteria

1. Given each of the 6 screens listed in `## In Scope` item 1, when its
   `Scaffold`'s `backgroundColor: colors.colorBackground` override is
   removed, then the shared `CupidAppBackground` `--sky` gradient wash
   (mounted once at `cupid_app.dart:59`) renders through unoccluded on that
   screen.
2. Given `otp_screen.dart:79`, when the override is removed, then the OTP
   verification screen shows the shared sky wash and its own existing
   content/layout (already confirmed `MATCH` by STORY-007) is unchanged.
3. Given `love_contract_screen.dart:109`, when the override is removed,
   then the love contract screen shows the shared sky wash and its own
   existing content/layout (already confirmed `MATCH` by STORY-015) is
   unchanged.
4. Given `onboarding_profile_setup_screen.dart:85`, when the override is
   removed, then the onboarding profile setup screen shows the shared sky
   wash and its own existing content/layout (already confirmed `MATCH` by
   STORY-010) is unchanged.
5. Given `permissions_screen.dart:107`, when the override is removed, then
   the permissions screen shows the shared sky wash and its own existing
   content/layout (already confirmed `MATCH` by STORY-009) is unchanged.
6. Given `joincode_screen.dart:125`, when the override is removed, then the
   join/enter pairing code screen shows the shared sky wash and its own
   existing content/layout (already confirmed `MATCH` by STORY-012) is
   unchanged.
7. Given `vow_screen.dart:169`, when the override is removed, then the
   fingerprint vow screen shows the shared sky wash and its own existing
   content/layout (already confirmed `MATCH` by STORY-016) is unchanged.
8. Given any of the 6 screens where removing the override leaves the local
   `colors` variable fully unused on that screen, when the edit is made,
   then that unused local is also removed so `flutter analyze` reports no
   new warning; on any screen where `colors` remains used elsewhere, it is
   left in place.
9. Given the 6 edits are complete, when `flutter analyze` and the existing
   `flutter test` suite are run, then both pass clean with no new
   warnings, errors, or failing tests attributable to this story's changes.
10. Given each of the 6 screens is reached through its existing normal
    navigation path, when a user arrives at it, then no new entry point is
    required and no navigation behavior changes — this story only changes
    the `Scaffold` backdrop paint layer.

## Dependencies

- Depends on: NONE. Independent of every other REQ-002 story; must not
  reopen the closed git boundary/branch of STORY-007, STORY-009, STORY-010,
  STORY-012, STORY-015, STORY-016, STORY-032, or STORY-037.
- Must not require any future story: confirmed — this closes the last known
  instances of RWB-20260816-013's defect pattern within the 6 screens
  named in STORY-037's own DEF-1 finding.

## Assumptions (only if needed)

- The 6 file paths and line numbers verified in `## In Scope` item 1 were
  current at the time of this scoping pass (2026-08-18); if a concurrent
  change has since shifted a line number, the implementer locates the same
  `backgroundColor: colors.colorBackground` property on the same `Scaffold`
  by content, not by a stale line number.

## Open Question Impact

Re-checked against `data/intake/bootstrap/conflicts_open_questions.md` (via
the requirement-level `## Open Question Triage` in
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/requirements/requirements.md`):
OQ5 (light theme / `en` locale) is the only open question touching this
story's scope. It is RESOLVED (REQ-001 STORY-001, 2026-08-12) and explicitly
marks "shared-token-level fixes that also correct light/`en` rendering" —
which this backdrop fix is, being a shell/token-level correction — as NOT
BLOCKED. No dedicated light/`en` verification pass is added; only the
enabled dark + `vi` configuration is verified, consistent with every other
REQ-002 Scope B/hardening story.

### Scope Items BLOCKED in this story

- None. No open question blocks any in-scope acceptance criterion.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (1-10) are unblocked.

### Scope decisions driven by OQs

- OQ5 RESOLVED → does not block any item in this story; dark + `vi` remains
  the only verified user-facing configuration, matching this requirement's
  existing precedent.

### OQs not applicable to this story

- R8 (Backend Socket.IO auth gap) → not applicable; a backend-only security
  decision with no overlap with this story's mobile presentation-layer
  scope.
