# Story Master: STORY-039 Hardening - Love Contract Screen Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-015_love_contract_design_fidelity
Scope: Retro-hardening (RWB-20260816-006)
Screen: contract (Love Contract), Epic 1 (Core connection / onboarding),
NO_CHROME / NO_TABS
Design-Screen: contract
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) (SKIPPED:trivial)
- [x] Architecture (Tech Lead) (SKIPPED:trivial)
- [x] Implementation (Development)
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY (`review/review-report.md`)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-006 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-015_love_contract_design_fidelity's Design Fidelity evidence used a
"Token Mapping Policy" (code/token comparison only) instead of a real
rendered-to-rendered image pair — same IF-7-class gap already remediated for
`welcome` (STORY-035), `register` (STORY-036), `invite` (STORY-037), and
`paired` (STORY-038).

STORY-015's own review (`STORY-015_love_contract_design_fidelity/review/review-report.md`,
Outcome: DEFERRED_ONLY) is unusually rich for this hardening item and must be
read directly, not re-derived, before this story is scoped. Key facts Product
Owner must weigh in scoping:

1. **F-4 (independently confirms RWB-006):** "No rendered evidence... For a
   story whose AC1 is phrased as a visual comparison this is an evidence
   gap." This is the exact defect this hardening story exists to fix.
2. **D-1 through D-13:** 13 deviations were found and fixed directly in
   `love_contract_screen.dart`, verified present in code by both the
   implementer and the reviewer's independent trace. These were code-verified
   but never visually confirmed against a render — same re-verification
   posture as STORY-038's D1-D15 for `paired`.
3. **DEF-1 and DEF-2 (real, unresolved, high visual impact):** two deviations
   the original implementer correctly declared outside their assigned
   `WriteScope` (`clause_toggle_row.dart`, `hold_to_sign_button.dart`), so
   they were never fixed:
   - DEF-1: clause checkbox glyph shape, size, and left/right column order do
     not match the design (design: 24x24 rounded checkbox left, `§N` mono id
     right at 9.5px; app: `§N` first at inherited size, then a circular
     glyph). Reviewer called this "the one a user would notice first."
   - DEF-2: `HoldToSignButton` height/shape/shadow/fill-direction do not
     match the design (design: 64px, card radius, glow shadow, right-to-left
     dim overlay + conic touch puck; app: pill shape, no glow, left-to-right
     fill + spinner).
   This hardening story is a fresh story with its own `WriteScope` decision;
   Product Owner must decide whether DEF-1/DEF-2 fall inside this story's
   scope now that the boundary that excluded them no longer applies, or
   whether they need their own follow-up item.
4. **DEF-3 (out of scope, confirm only):** both-signed CTA
   (`Cả hai đã ký → Ghép đôi`) is a Scope A (STORY-001/STORY-002) inter-screen
   navigation affordance, same disposition class as STORY-038's CTA seam —
   should stay out of scope here, re-confirm only.
5. **F-1/F-2/F-3 (systemic, reviewer explicitly says NOT screen-local):**
   header/signed-card wash uses token hues instead of the design's literal
   rgba values (F-1); several type sizes snap to token steps larger than the
   design source (F-2); card-internal horizontal padding snaps to 16 against
   a design 20 (F-3). Reviewer: "Needs a Scrum Master / Tech Lead call, not a
   screen-local edit" (F-1) and "will recur on every remaining REQ-002 Scope
   B story... Deciding them once at requirement level is cheaper than
   re-litigating per story" (residual risk note). Product Owner should treat
   these as a requirement-level token-vs-source policy question, not silently
   fold them into this story's AC as a per-screen fix, and should record
   whichever disposition it chooses (fix here / defer / escalate) explicitly
   rather than let the rendered comparison quietly re-surface and re-defer
   them.
6. **F-5 (out of scope, confirm only):** add-clause copy differs from the
   design source; reviewer noted copy is not enumerated in AC1's property
   list — pre-existing REQ-001 copy, not introduced by STORY-015. No action
   expected.
7. A pre-existing accessibility nuance was flagged by the reviewer as
   out-of-scope-but-worth-a-bug-queue-entry (`IgnorePointer` blocks
   hit-testing only, so a screen-reader still announces read-only clauses as
   actionable). Traced to REQ-001 STORY-019, not introduced by STORY-015 or
   in scope for this hardening story; not this story's job to fix, flagging
   so Product Owner does not need to re-derive it if asked.

Note also: STORY-015's own `story_master.md` currently records
`Status: PENDING` with the `Review (Reviewer)` artifact unchecked, even
though `req_master.md`'s `## User Stories` table treats it as a completed/DONE
screen (same discrepancy pattern already found and left undisturbed for
STORY-006/STORY-011/STORY-014, remediated via STORY-036/037/038) — Product
Owner should reconcile this discrepancy as part of scoping this hardening
story, not assume it away, and per precedent should leave STORY-015's own
record undisturbed (documented-not-resolved) rather than reopening its closed
git boundary/branch.

Reconciliation decision (Product Owner): left as documented, not resolved, in
STORY-015's own `story_master.md` — same disposition as the
STORY-006/STORY-011/STORY-014/STORY-036/STORY-037/STORY-038 precedent chain.
This is a stale-checklist/status-field data hygiene gap on STORY-015's own
record, not evidence that the Love Contract screen's implementation or
original scope was incomplete; `req_master.md`'s `## User Stories` table
treats it as a completed/DONE screen, and STORY-015's own
`Implementation (Development)` checkbox is already checked with an evidence
path of `visual-fidelity/visual-fidelity-report.md`. Unlike
STORY-006/STORY-011/STORY-014, STORY-015 did receive a full review
(`review/review-report.md`, Outcome: DEFERRED_ONLY) — the unchecked
`Review (Reviewer)` box and `Status: PENDING` field are themselves the stale
artifact, not evidence the review never happened. Does not block STORY-039's
own scope, and this story must not reopen or edit STORY-015's own closed git
boundary/branch to fix that field.

Exact remediation needed (per `rework-backlog.md`):
1. Capture `implemented-contract-<device>.png` from the running app (dark
   theme + `vi` locale, per STORY-015's own configuration).
2. Render `design-reference-contract-<platform>.png` via
   `render-design-canvas.js --screen=contract` (confirm the exact screen id
   via `--list-screens` if `contract` does not resolve).
3. Re-compare both renders against STORY-015's existing claimed scope
   (layout, spacing, color/token usage, typography, and each of D-1 through
   D-13); if any deviation remains, was missed, or was newly introduced,
   correct it in the app code — this is a fix, not merely a re-documentation.
4. Place the matched, same-screen evidence pair
   (`implemented-contract-<device>.png` and
   `design-reference-contract-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-001's, STORY-002's, STORY-006's, STORY-011's, STORY-014's, STORY-015's,
  STORY-019's, STORY-034's, STORY-035's, STORY-036's, STORY-037's, or
  STORY-038's closed git boundary/branch.

## User Story
As a Product Owner verifying REQ-002's design fidelity claims, I want the
Love Contract screen's fidelity evidence to be a real rendered-to-rendered
comparison (implemented app screenshot vs. rendered design canvas) that
re-confirms all 13 of STORY-015's originally-fixed deviations and resolves
the two real, unresolved deviations STORY-015's own review found outside its
assigned `WriteScope`, so that the screen's claimed fix is backed by proof
instead of a code/token-only reading, and the clause checkbox and
hold-to-sign button — the elements a user notices first — actually match the
locked design.

## In Scope
1. Capture `implemented-contract-<device>.png` from the running app in the
   enabled dark theme + `vi` locale configuration (STORY-015's own
   configuration), and render `design-reference-contract-<platform>.png`
   via `render-design-canvas.js --screen=contract` (confirm the exact screen
   id via `--list-screens` if `contract` does not resolve).
2. Re-compare the two rendered images against STORY-015's existing claimed
   scope: layout, spacing, color/token usage, typography, and each of D-1
   through D-13 (per STORY-015's own `visual-fidelity/visual-fidelity-report.md`
   and `review/review-report.md`).
3. Fix DEF-1 in `mobile/lib/features/love_contracts/presentation/widgets/clause_toggle_row.dart`:
   the clause checkbox does not match the design source (lines 131-139) —
   correct it to a 24x24 rounded checkbox (radius 9, `--grad-hot` fill when
   on, `1.5px solid var(--line)` when off) positioned on the left, with the
   `§N` mono id at 9.5px moved to the right with 4px top padding, replacing
   the current wrong glyph shape and reversed column order.
4. Fix DEF-2 in `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`:
   the button does not match the design source (line 153) — correct it to
   `height: 64px`, `border-radius: var(--r-card)`, `box-shadow: var(--glow)`,
   a right-to-left dim overlay, and a conic-gradient touch puck, replacing
   the current pill shape, no-glow styling, left-to-right fill, and trailing
   `CircularProgressIndicator`.
5. If the rendered-to-rendered comparison finds any of D-1 through D-13 not
   actually matching the design source, or surfaces any new deviation not
   caught by STORY-015's original audit or review, correct it directly in
   the app code — this is a fix, not a re-documentation exercise.
6. Place the matched, same-screen evidence pair
   (`implemented-contract-<device>.png` and
   `design-reference-contract-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match, and that
   explicitly re-confirms the disposition of D-1 through D-13 (re-verified
   matching) and DEF-1/DEF-2 (now fixed and visually verified).

## Out of Scope
- DEF-3 (both-signed CTA, `Cả hai đã ký → Ghép đôi`): remains Scope A
  (STORY-001/STORY-002) territory, same disposition class as STORY-038's CTA
  seam — re-confirmed only, no new investigation performed.
- F-1/F-2/F-3 (header/signed-card wash uses token hues instead of the
  design's literal rgba values; several type sizes snap to token steps
  larger than the design source; card-internal horizontal padding snaps to
  16 against a design 20): **not** folded into this story as a screen-local
  fix. STORY-015's reviewer explicitly called these "a Scrum Master / Tech
  Lead call, not a screen-local edit" that "will recur on every remaining
  REQ-002 Scope B story... Deciding them once at requirement level is
  cheaper than re-litigating per story." This story records them here as a
  requirement-level token-vs-source policy question for Scrum Master to
  route to Tech Lead, and explicitly excludes these three named gaps from
  Acceptance Criterion 1's match determination (see Acceptance Criteria)
  rather than letting the rendered comparison silently re-surface and
  re-defer them without a decision trail.
- F-5 (add-clause copy differs from the design source): pre-existing REQ-001
  copy, not introduced by STORY-015, not enumerated in AC1's property list —
  re-confirmed only, no action taken.
- The pre-existing screen-reader/read-only-clause accessibility nuance
  (`IgnorePointer` blocks hit-testing only, so a screen reader still
  announces read-only clauses as actionable): traced to REQ-001 STORY-019,
  not introduced by STORY-015 and not in scope for this hardening story;
  already flagged by STORY-015's reviewer for the bug queue, no fix
  attempted here.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet). Confirmed still unresolved-but-non-blocking in
  `conflicts_open_questions.md`; consistent with STORY-015's, STORY-036's,
  STORY-037's, and STORY-038's own precedent, no dedicated light/`en`
  rendered pass is required for this hardening story.
- Re-litigating STORY-015's original scope framing beyond what is already
  carried in `## Background` above (no Review Rework Patch exists for
  STORY-015, unlike STORY-006's for STORY-036 — see the reconciliation
  decision in `## Background`) — this story only adds the missing rendered
  evidence, fixes DEF-1/DEF-2, and fixes anything the rendered comparison
  confirms or newly surfaces.
- Love Contract business logic (cubit, repository, signature persistence,
  pairing state): untouched, per STORY-015's own out-of-scope boundary.

## Acceptance Criteria
1. Given the Love Contract screen rendered in the enabled dark theme + `vi`
   locale, when `implemented-contract-<device>.png` is compared against
   `design-reference-contract-<platform>.png` (rendered via
   `render-design-canvas.js --screen=contract`), then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation — except the requirement-level token-vs-source gaps named in
   `## Out of Scope` (F-1 header/signed-card wash hue, F-2 type-size
   snapping, F-3 card padding snapping), which are explicitly excluded from
   this criterion's pass/fail determination pending a Scrum Master/Tech Lead
   requirement-level token policy decision.
2. Given each of STORY-015's D-1 through D-13 originally-fixed deviations
   (per its own `visual-fidelity/visual-fidelity-report.md` and
   `review/review-report.md`), when this story's rendered comparison is
   complete, then each is re-confirmed as matching the design source in the
   actual rendered app, not merely re-read as code.
3. Given DEF-1 (clause checkbox glyph shape, size, and column order) and
   DEF-2 (hold-to-sign button height, shape, shadow, and fill-direction),
   both left unresolved by STORY-015's review because they fell outside its
   assigned `WriteScope`, when this story is delivered, then both are fixed
   directly in `clause_toggle_row.dart` and `hold_to_sign_button.dart` to
   match the design source exactly and re-verified in the rendered
   comparison: the checkbox rendered on the left at 24x24 with the `§N`
   mono id moved to the right, and the button rendered at 64px height with
   card-radius shape, glow shadow, and a right-to-left dim overlay with a
   conic-gradient touch puck.
4. Given any deviation is found by the rendered-to-rendered comparison
   beyond D-1 through D-13, DEF-1, or DEF-2 — whether a previously-claimed
   fix that does not actually match or a newly-surfaced deviation — when the
   story is delivered, then it is corrected in the app code (not merely
   documented) and re-verified with a fresh render pair.
5. Given DEF-3 (both-signed CTA) and F-5 (add-clause copy), when this story
   is delivered, then both remain confirmed out of scope per
   `## Background`/`## Out of Scope`, with no new investigation or fix
   attempted.
6. Given the comparison is complete and passing, when the story is
   delivered, then this story's own `visual-fidelity/` directory contains
   the matched `implemented-contract-<device>.png` and
   `design-reference-contract-<platform>.png` image pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS` and the
   D-1 through D-13 plus DEF-1/DEF-2 re-verification disposition.
7. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Love Contract screen, already
  reachable in the shipped app via its existing navigation path — unchanged
  by this story.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE (confirms `## Depends On` above).
- Must not require any future story: confirmed. F-1/F-2/F-3's
  requirement-level token policy decision is a follow-up recommendation for
  Scrum Master/Tech Lead, not a dependency of this story's own delivery.
- Must not reopen STORY-001's, STORY-002's, STORY-006's, STORY-011's,
  STORY-014's, STORY-015's, STORY-019's, STORY-034's, STORY-035's,
  STORY-036's, STORY-037's, or STORY-038's closed git boundary/branch:
  confirmed.

## Open Question Impact
Re-checked against `data/intake/bootstrap/conflicts_open_questions.md`: OQ5
(light theme / `en` locale) is the only open question touching this
screen's scope. It remains unresolved-but-non-blocking there, deferred to
Product Owner story breakdown per its own working assumption, and is
already excluded from this story's Out of Scope for the same reason
STORY-015, STORY-036, STORY-037, and STORY-038 excluded it — dark + `vi` is
the only enabled user-facing configuration in v1. No other open item in the
registry touches the Love Contract screen or this story's evidence-pairing
scope.

### Scope Items BLOCKED in this story
- None. No open question blocks any in-scope acceptance criterion. F-1/F-2/
  F-3 are excluded from AC1 by an explicit Product Owner scope decision (a
  requirement-level policy question for Scrum Master/Tech Lead), not by an
  open question.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-7) are unblocked.
