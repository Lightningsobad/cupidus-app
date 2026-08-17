# Story Master: STORY-041 Hardening - Anti-Ghosting Settings Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-022_anti_ghosting_settings_design_fidelity
Scope: Retro-hardening (RWB-20260816-008)
Screen: Anti-Ghosting (threshold picker + Emoji Storm settings), Epic 3
(Daily engagement)
Design-Screen: antighost (confirm exact screen id via
`render-design-canvas.js --list-screens`)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-008 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-022_anti_ghosting_settings_design_fidelity's Design Fidelity evidence
had zero rendered evidence either side — same IF-7-class gap already
remediated for `welcome` (STORY-035), `register` (STORY-036), `invite`
(STORY-037), `paired` (STORY-038), `contract` (STORY-039), and `chat`
(STORY-040).

STORY-022's own review (`STORY-022_anti_ghosting_settings_design_fidelity/review/review-report.md`,
Outcome: DEFERRED_ONLY) and its own
`visual-fidelity/visual-fidelity-report.md` must be read directly, not
re-derived, before this story is scoped. Key facts Product Owner must weigh
in scoping:

1. **Zero rendered evidence (confirms RWB-008):** STORY-022's own
   `visual-fidelity-report.md` states plainly: "No screenshots are
   attached: provisioning simulators/emulators is outside the mobile lane's
   authority, so dark + `vi` fidelity is evidenced by the token-level
   assertions in AC1 rather than by captured frames." This is the exact
   defect this hardening story exists to fix — capture
   `implemented-antighost-<device>.png` from the running
   `anti_ghost_screen.dart`, and render
   `design-reference-antighost-<platform>.png` via
   `render-design-canvas.js --screen=antighost` (confirm the exact screen id
   via `--list-screens` if `antighost` does not resolve).
2. **10 deviations (F-01 through F-10 in `visual-fidelity-report.md`):**
   found and fixed directly in `anti_ghost_screen.dart` (467 insertions / 195
   deletions against that story's BaseHead), each verified by a new dark +
   `vi` widget test in `anti_ghost_screen_test.dart` that reads painted
   token values back out of the tree. These are code-verified but never
   visually confirmed against an actual render/screenshot — same
   re-verification posture as STORY-038's D1-D15, STORY-039's D-1..D-13, and
   STORY-040's 25 deviations.
3. **AC1/AC3 (threshold segmented control + penalty selector tiles) are the
   core re-verification targets.** F-03 (the pill-track segmented control
   replacing the old `ChoiceChip` row) and F-06 (the penalty-row icon tiles
   with peach/neutral tints, glyphs, and dividers) are this screen's most
   structurally significant fixes. This story must confirm both are visibly
   correct in an actual rendered capture, not merely re-assert the existing
   widget test's token/decoration checks.
4. **D-05 (reviewer-found, real, unresolved):** The design source's penalty
   card has three rows (design source lines 555-571); the app implements
   only two (Emoji Storm, sound) and omits the first row entirely: `Đếm
   ngược công khai` / `Public countdown`, an amber tile
   (`rgba(255,201,126,.2)`, `var(--amber)` `timer` glyph). Reviewer confirmed
   this needs a new persisted setting plus a backend field and new l10n keys
   — the same blocker class as D-01. Product Owner must give this an
   explicit disposition: fold in (unlikely — needs new backend/persisted
   state, not a pure rendering fix) or split to a new follow-up RWB item
   (mirror the RWB-20260816-016/RWB-20260816-017 split-out pattern already
   used for STORY-040's D1/R-1) — do not silently drop it.
5. **D-01/D-02/D-03 (original visual-fidelity-report deferred items, all
   real, all l10n-blocked):** storm-emoji-set card (D-01), handshake consent
   callout (D-02), per-row penalty subtitles (D-03) — all confirmed present
   in the design source by the original story's audit, all blocked on
   `mobile/lib/l10n/arb/` being outside a screen-scoped story's `WriteScope`
   (D-01 also needs a new persisted setting/backend field, same as D-05).
   Product Owner should re-confirm these stay out of scope for this
   hardening story too, not re-litigate or attempt a partial fix.
6. **R-1 (reviewer-found, residual, real but non-blocking):** the selected
   segment label paints `colors.colorText`. In dark theme that resolves to
   `#F7EEFB`, effectively the source's `#fff` (AC1/AC3 hold). In light theme
   the same code would render `#3E2645` on the hot gradient — a contrast
   risk. Out of scope here per OQ5 (light theme is not enabled for users
   yet); reviewer flagged that a future light-theme QA pass must revisit
   this specific token choice rather than assume tokens carry over
   unchanged. No design-system file touched by this story; carry the note
   forward only, same treatment as STORY-040's D1 disposition context.
7. **R-2 (reviewer-found, residual, non-blocking but actively checkable):**
   the app adds a fourth, app-only `Tuỳ chỉnh` (custom) segment beyond the
   design source's three. At `flex:1` inside a 16px-padded card on a
   ~360dp-wide device each segment is roughly 66dp, and the label is
   `maxLines: 1` with ellipsis — the existing 800x600 widget-test viewport
   cannot catch truncation at real phone widths. Because this story is
   specifically about producing a real rendered capture, Product Owner
   should scope an explicit narrow-width check into this story's own
   evidence pass (confirm no label truncation in the actual
   `implemented-antighost-<device>.png` capture) rather than deferring it
   further.
8. **R-3 (observation only, not an AC miss):** replacing the old disabled
   `ChoiceChip`s with segments means the disabled-state preview no longer
   dims the selected segment's gradient fill. The muted section headings,
   `IgnorePointer`, `Semantics(enabled: false)`, and the
   `anti_ghost_pending_mine_disabled_reason` label all remain and are
   asserted by the existing test; the design source defines no disabled
   state at all, so reviewer confirmed this is not an AC3 miss — a
   conscious visual choice already made, not a gap. No action needed; note
   only.
9. STORY-022's own `story_master.md` `Status: DONE` / all-Artifacts-checked
   record should be left undisturbed (documented-not-resolved in this
   story's Background only), matching the STORY-015/STORY-018/STORY-039/
   STORY-040 precedent — do not reopen its closed git boundary/branch.

Exact remediation steps: see `rework-backlog.md` RWB-20260816-008 detail
section (already written, do not re-derive).

Disposition decisions (Product Owner):
- **D-05 — split out.** Not folded into this story. Implementing the
  `Đếm ngược công khai` / "Public countdown" penalty row needs a new
  persisted setting, a new backend field, and new l10n keys — the same
  blocker class as D-01, and excluded by this story's own Out of Scope
  ("any new feature, new screen state, or new interaction"). It is not a
  pure rendering fix a screen-scoped hardening story can absorb. Tracked as
  a new rework-backlog item, **RWB-20260816-018** (next unused id;
  001-017 are already assigned in `data/retro-audit/rework-backlog.md`),
  for Scrum Master to add to the registry and detail section — mirroring
  the RWB-20260816-016/RWB-20260816-017 split-out pattern already used
  twice in this requirement for findings that fell outside a hardening
  story's natural boundary. This story does not edit `rework-backlog.md`
  itself and does not touch any backend, persisted-setting, or l10n file.
- **R-2 — check in this story's own evidence pass.** Folded into this
  story as an explicit acceptance criterion, not deferred again. Because
  this story is specifically about producing a real rendered capture, the
  `implemented-antighost-<device>.png` capture is taken at a narrow device
  width (~360dp) with the threshold picker's fourth, app-only `Tuỳ chỉnh`
  segment visible alongside the design source's three, so the capture can
  directly confirm whether any segment label truncates under
  `maxLines: 1` ellipsis at real phone widths — something the existing
  800x600 widget-test viewport cannot catch. If truncation is found, it is
  corrected directly in `anti_ghost_screen.dart` and re-verified with a
  fresh capture, the same "fix if the render surfaces it" posture used by
  STORY-039's DEF-1/DEF-2 and STORY-040's D2.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-001's, STORY-002's, STORY-004's, STORY-006's, STORY-011's,
  STORY-014's, STORY-015's, STORY-018's, STORY-019's, STORY-022's,
  STORY-034's, STORY-035's, STORY-036's, STORY-037's, STORY-038's,
  STORY-039's, or STORY-040's closed git boundary/branch.

## User Story
As a Product Owner verifying REQ-002's design fidelity claims, I want the
Anti-Ghosting settings screen's fidelity evidence to be a real
rendered-to-rendered comparison (an implemented app screenshot at a narrow
device width vs. a rendered design canvas) that re-confirms all 10 of
STORY-022's originally-fixed deviations — especially F-03's threshold
segmented control and F-06's penalty selector tiles — and directly checks
the four-segment picker for label truncation at real phone widths, so that
the screen's claimed fix is backed by proof instead of a token/widget-test
-only reading.

## In Scope
1. Capture `implemented-antighost-<device>.png` at a narrow device width
   (~360dp), in dark theme + `vi` locale (STORY-022's own configuration),
   with the threshold picker showing all four segments (the design
   source's `5`/`10`/`15` phút plus the app-only `Tuỳ chỉnh` segment), and
   render `design-reference-antighost-<platform>.png` via
   `render-design-canvas.js --screen=antighost` (confirm the exact screen
   id via `--list-screens` if `antighost` does not resolve).
2. Re-compare the two rendered images against STORY-022's existing claimed
   scope: layout, spacing, color/token usage, and typography, and each of
   the 10 deviations F-01 through F-10 (per
   `visual-fidelity/visual-fidelity-report.md` and the widget tests in
   `anti_ghost_screen_test.dart`), with particular attention to F-03 (the
   pill-track threshold segmented control) and F-06 (the penalty-row icon
   tiles) as actually rendered, not merely re-asserted by the existing
   widget test.
3. R-2 narrow-width check: using the same narrow-width capture from item 1,
   confirm no threshold-segment label (including `Tuỳ chỉnh`) is truncated
   or ellipsized under real phone-width constraints. If truncation is
   found, correct it directly in `anti_ghost_screen.dart` and re-verify
   with a fresh capture.
4. If the rendered-to-rendered comparison finds any of the 10 deviations
   not actually matching the design source, or surfaces any new deviation
   not caught by STORY-022's original audit or review, correct it directly
   in the app code — this is a fix, not merely a re-documentation
   exercise.
5. Place the matched, same-screen evidence pair
   (`implemented-antighost-<device>.png` and
   `design-reference-antighost-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Out of Scope
- D-05 (undisclosed penalty-card row: `Đếm ngược công khai` / "Public
  countdown", amber tile, `timer` glyph): **not** folded into this story.
  Split to a new rework-backlog item, RWB-20260816-018 (see `## Background`
  disposition decision above) — re-confirmed only here, no backend,
  persisted-setting, or l10n file touched by this story.
- D-01 (storm-emoji-set card), D-02 (handshake consent callout), D-03
  (per-row penalty subtitles): all confirmed present in the design source
  and all blocked on `mobile/lib/l10n/arb/` being outside this story's
  `WriteScope`. Re-confirmed out of scope only, no re-litigation, no
  partial fix attempted.
- R-1 (selected segment label uses `colorText`, a light-theme contrast
  risk): out of scope per OQ5 (light theme not enabled for users yet).
  Carried forward as a note for a future light-theme QA pass only; no
  `design_system/` file touched by this story.
- R-3 (disabled-state preview no longer dims the selected segment's
  gradient): observation only, confirmed not an AC3 miss by STORY-022's own
  review since the design source defines no disabled state; no action
  taken.
- Any new feature, new screen state, or new interaction not already
  present in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet). Consistent with STORY-022's own precedent and
  every prior REQ-002 hardening story, no dedicated light/`en` rendered
  pass is required for this hardening story. This is also the reason R-1
  stays out of scope.
- Re-litigating STORY-022's original scope framing beyond what is already
  carried in `## Background` above — this story only adds the missing
  rendered evidence, checks and fixes R-2 if needed, tracks D-05 as a
  follow-up item, and fixes anything the rendered comparison confirms or
  newly surfaces.
- STORY-022's own `story_master.md` `Status: DONE` / all-Artifacts-checked
  record: left undisturbed, documented-not-resolved only in this story's
  `## Background`, no reopening of its closed git boundary/branch.
- Anti-ghosting business logic (ghost config repository, anti-ghost cubit,
  ghost storm cubit, timer/backend state): untouched, consistent with
  STORY-022's own scope boundary.

## Acceptance Criteria
1. Given the Anti-Ghosting settings screen rendered in dark theme + `vi`
   locale at a narrow device width (~360dp), when
   `implemented-antighost-<device>.png` is compared against
   `design-reference-antighost-<platform>.png` (rendered via
   `render-design-canvas.js --screen=antighost`), then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
2. Given each of STORY-022's 10 originally-fixed deviations (F-01 through
   F-10, per its own `visual-fidelity/visual-fidelity-report.md` and
   `anti_ghost_screen_test.dart`), when this story's rendered comparison is
   complete, then each is re-confirmed as matching the design source in
   the actual rendered app, not merely re-read as code or widget-test
   assertion, with particular attention to F-03 (threshold segmented
   control) and F-06 (penalty selector tiles).
3. Given R-2 (the four-segment threshold picker at narrow device width,
   with `maxLines: 1` ellipsis labels), when the narrow-width
   `implemented-antighost-<device>.png` capture includes all four segments
   (the design source's three plus the app-only `Tuỳ chỉnh` segment), then
   no segment label is truncated or ellipsized in the actual rendered
   capture; if truncation is found, it is corrected directly in
   `anti_ghost_screen.dart` and re-verified with a fresh capture.
4. Given D-05 (undisclosed penalty-card row `Đếm ngược công khai` /
   "Public countdown", amber tile, needing a new persisted setting plus a
   backend field and new l10n keys), when this story is delivered, then no
   backend, persisted-setting, or l10n file is modified by this story, and
   the gap is tracked instead in `rework-backlog.md` item RWB-20260816-018
   for a future story with that scope in its `WriteScope`.
5. Given any deviation is found by the rendered-to-rendered comparison
   beyond the 10 original deviations or R-2 — whether a previously-claimed
   fix that does not actually match or a newly-surfaced deviation — when
   the story is delivered, then it is corrected in the app code (not
   merely documented) and re-verified with a fresh render pair.
6. Given the comparison is complete and passing, when the story is
   delivered, then this story's own `visual-fidelity/` directory contains
   the matched `implemented-antighost-<device>.png` and
   `design-reference-antighost-<platform>.png` image pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`, the
   10-deviation re-verification disposition, and the R-2 narrow-width
   check result.
7. Given the screen is reached through its existing normal navigation
   path, when a user arrives at it, then no new entry point is required —
   this story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Anti-Ghosting settings screen
  (threshold picker + Emoji Storm settings), already reachable in the
  shipped app via its existing navigation path — unchanged by this story.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE (confirms `## Depends On` above).
- Must not require any future story: confirmed. D-05's backend/persisted-
  state/l10n gap is tracked as RWB-20260816-018, a follow-up
  recommendation for a future story, not a dependency of this story's own
  delivery.
- Must not reopen STORY-001's, STORY-002's, STORY-004's, STORY-006's,
  STORY-011's, STORY-014's, STORY-015's, STORY-018's, STORY-019's,
  STORY-022's, STORY-034's, STORY-035's, STORY-036's, STORY-037's,
  STORY-038's, STORY-039's, or STORY-040's closed git boundary/branch:
  confirmed.

## Open Question Impact
Re-checked against `data/intake/bootstrap/conflicts_open_questions.md`:
OQ5 (light theme / `en` locale) is the only open question touching this
screen's scope, and it is also the reason R-1 stays out of scope (R-1's
visible defect only exists in light theme). It remains
unresolved-but-non-blocking there, deferred to Product Owner story
breakdown per its own working assumption, and is already excluded from
this story's scope for the same reason STORY-022 and every prior REQ-002
hardening story excluded it — dark + `vi` is the only enabled user-facing
configuration in v1. No other open item in the registry touches the
Anti-Ghosting screen or this story's evidence-pairing scope.

### Scope Items BLOCKED in this story
- None. No open question blocks any in-scope acceptance criterion.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-7) are unblocked.
