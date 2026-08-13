# Review Report: STORY-003 Design Fidelity — Splash

Review type: compact-story-review
Story: STORY-003 (REQ-002, Scope B) — Complexity `trivial`, Lane `mobile`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-003`
Diff baseline: `8396273` → `9ab731f`

Outcome: PATCH_REQUIRED

## Scope Gate

Scope gate path:
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-003_splash_design_fidelity/review/scope-gate.md`
(written to satisfy the `validate-reviewer-two-phase.sh` stop guard, which
requires the separate file even in compact mode; the summary below is kept in
place for readers of this report.)

- Review type: `compact-story-review` (6 changed files, within the 8-file budget)
- Report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-003_splash_design_fidelity/review/review-report.md`
- Source/test files in scope:
  - `mobile/lib/features/auth/presentation/screens/splash_screen.dart`
  - `mobile/lib/design_system/tokens/splash_palette.dart` (new)
  - `mobile/lib/design_system/design_system.dart` (one export line)
  - `mobile/test/features/auth/presentation/screens/splash_design_fidelity_test.dart` (new)
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md`, `story_master.md`
- Corroborating reads: `data/devops/system/design-fidelity-config.json`,
  `mobile/lib/design_system/tokens/pet_hero_gradient.dart`,
  `mobile/lib/main.dart`, `mobile/lib/app/cupid_app.dart`,
  `mobile/lib/core/navigation/pair_gate_shell.dart`
- Query keys: AC 1-4, `SplashPalette`, `VISUAL_FIDELITY`, `Design-Screen`,
  no-fork guard, entry-point reachability
- Phase 2 proceeded; review completed with one blocking finding.

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Mobile interaction / rendering | Targeted widget tests | PASS — re-ran, 12/12 green |
| Mobile static analysis | `flutter analyze` | PASS — 0 errors, 94 pre-existing info/warn, none on changed lines |
| Design-system contract (additive token + barrel export) | `no_fork_guard_test.dart` | PASS — re-ran, green |
| Mobile design fidelity (12e2/12e3) | Rendered device capture vs design reference | **FAIL — no evidence exists** |
| Mobile navigation / discoverability | Entry point verified in code | CARRY-FORWARD — see F-2 |
| App lifecycle (dwell timer, session gate) | Pre-existing routing suite unchanged and green | PASS — 4/4 |

Runtime startup smoke (12g) is not required: `story_master.md` records
`Complexity: trivial`. See D-1 on the classification mismatch.

## Blocking Findings

### F-1 (BLOCKING) — Mobile design-fidelity evidence is prose, not rendered images

`visual-fidelity/` contains only `visual-fidelity-report.md`. There is no
`implemented-splash-<device>.png` and no `design-reference-splash-<device>.png`.
The report also carries no top-level `VISUAL_FIDELITY:` verdict line and no
resolved `Design-Screen: <id>`.

No exemption applies. `data/devops/system/design-fidelity-config.json` records
`ui_surface: true` and a locked `design_source`
(`claude-design`, `cupid-app-design-system/project`, `screens_from: canvas`,
`locked: true`), so the rendered check under skill rules 12e2/12e3 is mandatory
and non-waivable for this story.

What the report actually contains is a careful transcription of the design
source's CSS declarations (`Cupid Screens.dc.html` lines 1409-1423) compared
against the Dart widget tree, with each value pinned by a unit assertion. That
is high-quality work and it is why every other gate passes — but rule 12e2 is
explicit that "verified by source/code inspection" is exactly the substitute
this gate refuses. Transcribed CSS proves the intended values were typed into
the widget tree; it cannot prove the composed screen renders as the design
shows. Several of this story's own changes are precisely the class of thing
only a render catches: the `LayoutBuilder`-percentage glow position inside a
`ClipRect`, the removal of `SafeArea` from the centering frame, and the
absolutely-positioned bottom block at `safeBottom + 26`.

The capture path exists — `mobile/lib/main_preview.dart` already references
`SplashScreen`, so a preview-harness capture does not depend on F-2 being fixed
first. This is `PATCH_REQUIRED`, not `BLOCKED`.

Action (owner: mobile-dev):
1. Capture `visual-fidelity/implemented-splash-<device>.png` from the built app.
2. Render `visual-fidelity/design-reference-splash-<device>.png` for the splash
   screen via `render-design-canvas.js --screen=<id>`.
3. Record the resolved `Design-Screen: <id>` and a top-level
   `VISUAL_FIDELITY: PASS|FAIL` with the concrete per-state comparison
   (dark theme + `vi`, first-frame state and post-dwell state) in
   `visual-fidelity-report.md`.

## Non-Blocking Findings

### F-2 (CARRY-FORWARD, not STORY-003 rework) — Splash is not mounted in the shipped launch path

Verified in code, not on trust: `mobile/lib/main.dart` runs `CupidApp`, whose
`home` is `PairGateShell`; that shell renders only `_PairGateChecking` (a bare
`CircularProgressIndicator` `Scaffold`), `_PairingStack`, or `AppShell`.
`SplashScreen` appears nowhere in that tree — at this story's baseline it is
reachable only from `lib/main_preview.dart`.

This is correctly out of STORY-003's scope: `story_master.md` assigns launch
routing to STORY-001, and AC 4 is a no-change criterion ("no new entry point is
required — this story does not change how the screen is reached"), which the
story satisfies. Returning STORY-003 to implementation for this would push it
into another story's declared write scope.

Route: confirm at the REQ-002 requirement integration review that STORY-001
actually mounts `SplashScreen` in the launch path. If STORY-001 does not, no
story in this requirement owns it and the polished splash ships unreachable.

### D-1 (DEFERRED) — Story classification mismatch

`story_master.md` records `Complexity: trivial` / `Story-Class: trivial`; the
review handoff declares `Story-Class: standard`. This is not cosmetic — the
`trivial` value is what exempts the story from the 12g runtime startup smoke.
The change is single-lane (`mobile`), so no `STORY_UNDER_CLASSIFIED` blocker
applies, but 226 changed source lines, three new animation controllers and a new
design-system token file are not obviously trivial. Scrum Master should
reconcile the two values. Practical note: the same device session that produces
the F-1 capture also produces the launch smoke, so bundling them costs nothing.

## Ruling On The Flagged Write-Scope Deviation

**Acceptable additive token extension, not a scope violation.** Verified
against the diff and the cited precedent:

- `mobile/lib/design_system/tokens/pet_hero_gradient.dart` documents the
  identical rationale in its own dartdoc — a stop set matching neither
  `gradientDream` nor `gradientHot`, unable to live in `lib/features` because
  `no_fork_guard_test.dart` (D3/ADR-004) forbids raw color literals there — and
  itself cites `bun_sprite_palette.dart` as its precedent. `SplashPalette` is
  the third instance of an established pattern, not an improvisation.
- The diff confirms the claim: `splash_palette.dart` is purely additive, and
  the `design_system.dart` change is a single appended `export` line. **No
  existing token was modified**, so no other screen's rendering can be affected.
- The design values are genuinely absent from `CupidColorTokens`: the
  `168deg #7B4FBE/#C2508F/#4E8A87` ramp, `#fff`, and the four white alpha
  values. The re-run `no_fork_guard_test.dart` confirms nothing leaked into
  `lib/features`.
- Consumption is single-file (`splash_screen.dart`), matching the
  "additive, non-shared, single-consumer" shape of both precedents.

The worker disclosed this proactively in `visual-fidelity-report.md`. Scrum
Master should record the write-scope acknowledgement; no code change is needed.

## Acceptance Criteria

| AC | Verdict | Basis |
|---|---|---|
| 1 — layout/spacing/color/typography match in dark + `vi` | UNVERIFIED | Values pinned by assertions, but the rendered comparison that AC 1 asks for does not exist (F-1) |
| 2 — deviations corrected in the app, not merely documented | PASS | All 18 rows in the deviation table are real code changes in the diff |
| 3 — design source's own loading treatment, no ad hoc spinner | PASS | Dots + status line + pill are the design source's treatment; test asserts no `CircularProgressIndicator` |
| 4 — no new entry point | PASS | Routing code byte-for-byte unchanged; `splash_screen_test.dart` 4/4 green |

The report's own note that the design source declares no "twinkling stars"
despite the story's In Scope wording is the correct call: the locked design
source is authoritative, and inventing a star layer would have violated Out of
Scope. No finding.

## OQ Discipline

OQ5 (light theme / `en` locale) is triaged in `story_master.md` under
`## Open Question Impact` with explicit BLOCKED (none) and NOT BLOCKED (AC 1-4)
lists. Implementation respected it: no light/`en` visual pass was performed, and
the theme-invariant values incidentally fix a latent light-theme bug (wordmark
previously used theme-varying `colorText` on a fixed dark gradient) without
expanding scope. No finding.

## Traceability

- Requirements: `story_master.md` AC 1-4, In/Out of Scope, Open Question Impact
- UX / architecture: SKIPPED per `trivial` classification; design source of
  record is `cupid-app-design-system` (locked), per
  `data/devops/system/design-fidelity-config.json`
- Configuration guide: not applicable — no setup/configuration surface touched
- Test evidence: independently re-run in the story worktree —
  `flutter test` over `splash_design_fidelity_test.dart`,
  `splash_screen_test.dart`, `no_fork_guard_test.dart` → **12/12 passed**,
  confirming the recorded evidence is current and not stale

## Recommendation

- Story status: `IN_PROGRESS`
- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked
- Return to `mobile-dev` for F-1 only. The code is otherwise sound; this is an
  evidence gap, not a rework of the implementation.
- Record the F-2 carry-forward against the REQ-002 integration review and the
  write-scope acknowledgement for `splash_palette.dart`.

Blocking findings: 1
Deferred / carry-forward findings: 2
