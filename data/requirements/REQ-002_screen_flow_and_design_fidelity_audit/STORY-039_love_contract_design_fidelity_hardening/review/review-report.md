# Review Report: STORY-039 Hardening - Love Contract Screen Visual Fidelity

Outcome: DEFERRED_ONLY

Story: `STORY-039_love_contract_design_fidelity_hardening`
Requirement: REQ-002 (`REQ-002_screen_flow_and_design_fidelity_audit`)
Rework item: RWB-20260816-006 (RED-PATCH, fixes STORY-015)
Review type: `compact-story-review`
Reviewed: 2026-08-17
Diff baseline: `0f0969a1a196104bb386afce992d72966d6675c0`

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `compact-story-review`, Tier 1 (owes rendered visual-fidelity
  evidence), mobile lane, single lane.
- Report path: this file.
- Source/test files in scope (4, within the 8-file compact budget):
  - `mobile/lib/features/love_contracts/presentation/widgets/clause_toggle_row.dart`
  - `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`
  - `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart`
  - `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
- Evidence files in scope:
  - `visual-fidelity/visual-fidelity-report.md`
  - `visual-fidelity/design-reference-contract-android.png`
  - `visual-fidelity/implemented-contract-emulator-5560.png`
- Entry-point corroboration (unchanged surface):
  `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`
- Capture-state corroboration: `mobile/lib/main_preview.dart:303-354` (ranged read).
- Query keys: AC1-AC7, DEF-1, DEF-2, DEF-2a, DEF-3, D-1..D-13, F-1/F-2/F-3, F-5,
  `VISUAL_FIDELITY`, `Design-Screen: contract`.
- Touched risk surfaces: mobile interaction (clause toggle affordance, hold-to-sign
  gesture control), mobile design fidelity/visual, mobile
  navigation/discoverability (asserted unchanged — verified).
- Phase 2 may proceed: YES.

## Outcome Rationale

The story does what RWB-20260816-006 asked for and does it with real evidence.
Both DEF items are fixed in app code, visible as fixed in the rendered pair, and
pinned by two new regression tests. The render also caught a defect that a
code-only reading could not have (DEF-2a, the zero-height dim overlay), and that
defect was fixed in app code and re-rendered — which is exactly the behaviour
AC4 exists to require, and the strongest available proof that the rendered
comparison was genuinely performed rather than asserted.

`DEFERRED_ONLY` rather than `CLEAN` because two real deltas against the design
remain open, neither introduced by this story and neither closable inside its
declared write scope: partial rendered coverage of the D-item re-verification
(V-1) and an app-only clause-counter row that is currently misfiled against F-5
(V-2). Both are recorded below with routing rather than left to re-surface
silently — the failure mode this story was created to end.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 rendered comparison match (F-1/F-2/F-3 excluded) | PASS | Both PNGs opened and compared by the reviewer. Same screen, same card structure, same clause-row rhythm, same sign-section composition. F-1/F-2/F-3 present and explicitly excluded per AC1 text. One unexcluded delta recorded as V-2 (pre-existing, not introduced here — Core Rule 7). |
| AC2 D-1..D-13 re-confirmed in this story's own render | PASS (partial render coverage, disclosed) | 9 of 13 re-confirmed directly in the rendered pair (D-1..D-6, D-9, D-11, D-12). D-7, D-8, D-10, D-13 re-confirmed by widget test / widget-tree structure because the capture state cannot paint them and no in-scope render path exists — see V-1. No D-item unverified, none regressed. |
| AC3 DEF-1 + DEF-2 fixed and re-verified | PASS | `clause_toggle_row.dart`: `_ClauseCheckbox` is 24x24, `BorderRadius.circular(9)`, `gradientHot` fill + 16px `CupidIcons.check` when on, bare `1.5` `colorLine` border when off; column order now box / text / `§N`, `§N` at 9.5px mono with `CupidSpacing.xs` top pad. `hold_to_sign_button.dart`: `_buttonHeight = 64`, `platformTokens.radiusCard`, `colors.glowShadow`, right-anchored receding dim overlay, 32px `SweepGradient` puck over a 24px `colorAccentPink` disc; spinner and left-to-right fill removed. All visible as fixed in the implemented capture and pinned by the two new tests, which I ran. |
| AC4 new deviations fixed in code, not documented | PASS | DEF-2a found by the first post-fix render (dim overlay painted at zero height: `FractionallySizedBox` with no `heightFactor`). Fixed in app code — `Positioned.fill` + `heightFactor: 1` + `widthFactor: 1 - progress` — then re-rendered; both gradient endpoints now match the reference to within 1/255. Regression pinned (`widthFactor == 1.0`, `alignment == centerRight` at rest). |
| AC5 DEF-3 + F-5 untouched | PASS | `love_contract_screen.dart` does not appear in the diff at all, and both DEF-3 (both-signed CTA) and the add-clause copy live there. Report re-confirms both as out of scope with no new investigation. |
| AC6 evidence pair + report in this story's `visual-fidelity/` | PASS | `design-reference-contract-android.png` (406x900) and `implemented-contract-emulator-5560.png` (405x900) both exist and both open as real images of the Love Contract screen — not placeholders, not error frames, not a different canvas screen. `visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS` with the D-1..D-13 and DEF-1/DEF-2/DEF-2a disposition tables. `Design-Screen: contract` recorded in `story_master.md` and matches `--screen=contract`. |
| AC7 no new entry point / navigation change | PASS | Zero navigation change in the diff. Entry point independently verified in code: `LoveContractEntryTile` is a discoverable `Semantics(button: true)` `--surf` card row (`Key('love_contract_entry_tile')`) that pushes `LoveContractGateRoute` -> `LoveContractScreen`; unchanged by this story. |

## Rendered Evidence Verification (mobile lane, rule 12e3)

I opened both images rather than counting files.

- The reference depicts the Love Contract screen of the design canvas — the
  `myUnsigned` branch, with the 24x24 rounded checkboxes on the left, `§N` ids
  on the right, the add-clause row, and the 64px glowing hold slab. It is the
  screen this story is about, not a neighbouring canvas screen.
- The implemented capture shows the same screen in the built app on
  `emulator-5560`, dark theme, `vi` chrome (`BẢN CAM KẾT SỐ 001`, `Giữ để ký`,
  `Bản hợp đồng lưu ở Level 2 — mã hoá đầu-cuối`). No error screen, no spinner,
  no blank frame.
- What I see does not contradict the `PASS`. DEF-1 and DEF-2 both read as fixed:
  the checkbox is a filled rounded box on the left with the `§N` trailing, and
  the sign control is a tall card-radius slab with a glow and a left-side conic
  puck — matching the reference and no longer the circular glyph / flat pill the
  retro described.
- The clause body strings differ between the two sides (design sample clauses in
  Vietnamese, capture showing the fixture's English strings). This is fixture
  payload data (`main_preview.dart:334`), not localized product copy — contract
  clauses are user/backend data on both sides — so it is not a fidelity or
  localization defect. Noting it because it is the first thing a future reader
  will see when opening the two images, and the report does not mention it.

## Independent Verification Run

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/love_contracts test/features/love_contracts` | `No issues found! (ran in 1.8s)` |
| `flutter test test/features/love_contracts` | `00:02 +82: All tests passed!` |

Both rerun by the reviewer, matching the claims in `visual-fidelity-report.md`.
The `+82` count and the clean analyze reproduce exactly, so the report's
verification table is accurate and not fabricated. The APK build and the device
capture were not rerun (device lifecycle is not the reviewer's, per rule 12e3);
they are corroborated by the existence of a real 405x900 device screenshot that
could only come from a built app running on the emulator.

## Critical Gates

| Gate | Status |
| --- | --- |
| Mobile static analysis | PASS (rerun by reviewer) |
| Scoped widget/regression tests | PASS (rerun by reviewer, 82 tests) |
| Rendered design fidelity (12e2/12e3) | PASS (both images inspected; correct screen; verdict consistent with what the images show) |
| Entry point reachability (12e1) | PASS (verified in `love_contract_entry_tile.dart`; unchanged surface, no new capability introduced) |
| Runtime startup smoke (12g) | NOT REQUIRED — `Complexity: trivial`. De facto satisfied anyway: the app was built and launched on `emulator-5560` to produce the capture. |
| Configuration guide (12a) | NOT REQUIRED — no setup/config/env/runtime surface touched |

## Scope Discipline

The diff against `0f0969a` touches exactly the two declared widget files and
their two test files, plus three Scrum Master workflow artifacts
(`req_master.md`, `rework-backlog.md`, `scrum-master-checkpoint.md`) which are
control-plane bookkeeping for this story's own registration, not implementation
scope creep. `love_contract_screen.dart` is untouched, so DEF-3, F-5 and the
F-1/F-2/F-3 token surfaces were not silently altered. No closed story boundary
was reopened.

## Deferred Findings

### V-1 — AC2 rendered coverage is 9 of 13; no in-scope path to close it

D-7 and D-8 (add-clause row), D-10 (signed card) and D-13 (sign-action error
banner) were re-confirmed by widget test and widget-tree structure rather than by
the rendered pair. The report is explicit about this rather than claiming render
confirmation it did not perform, and I verified the stated cause is real:
`main_preview.dart:328-354` exposes exactly two contract fixtures,
`partnerAlreadySigned` and `bothSigned`; omitting the define falls back to the
live `getIt<LoveContractRepository>()`, which needs a running backend and a real
paired user and is therefore not capturable statically. So a requester-unsigned
capture — the state that would paint the add-clause row — is genuinely
unavailable without editing `main_preview.dart`, which is outside this story's
write scope. D-10 and D-13 additionally have no design-side reference at all: the
canvas paints only its `myUnsigned` branch, so no signed-card or error-banner
comparison exists to make.

Not blocking: the primary proof of this story's own changed behaviour (DEF-1,
DEF-2, DEF-2a) is fully render-proven, and each unrendered D-item carries a
direct test pin on the exact original defect. This is a categorically different
posture from STORY-015, which supplied no rendered evidence for any item.

Follow-up (Scrum Master / Mobile Dev, next contract-screen pass): add a
requester-unsigned preview fixture to `main_preview.dart` so the add-clause row
can be render-compared, and consider whether the design canvas can render its
signed / error branches at all before writing an AC that requires a rendered
comparison of a state the design source does not paint.

### V-2 — the `2/20 điều khoản` counter row is an app-vs-design delta filed under the wrong id

The app renders a clause-counter row that the design canvas does not have,
pushing the clause list roughly 26 px lower than the reference. The report
classifies it as belonging to "the F-5 copy family", but F-5 as scoped in
`story_master.md` is specifically the add-clause copy difference — so this delta
is currently unclassified rather than excluded, and AC1's exclusion list is
F-1/F-2/F-3 only.

Treated as deferred rather than blocking per Core Rule 7: the counter is a
pre-existing REQ-001 product affordance backing the 20-clause cap (exercised by
`the 20-clause cap disables the add-clause action`), it was not introduced by
STORY-015 or by this story, and removing it would be a product-copy decision
outside a fidelity hardening story's authority.

Follow-up (Scrum Master -> Product Owner / Tech Lead): route this with the
F-1/F-2/F-3 requirement-level token-vs-source policy question as its own
disposition, rather than leaving it filed under F-5.

### V-3 — local `IconData` constants continue to accumulate

`_iconTouchApp` (`0xe913`) is declared in `hold_to_sign_button.dart` rather than
in `CupidIcons`, because `design_system/` is outside this story's write scope.
The codepoint was verified against the bundled font's `cmap` rather than guessed,
and the pattern matches what `clause_toggle_row.dart` and
`love_contract_entry_tile.dart` already do — so this is consistent and disclosed,
not a defect. Worth consolidating into `CupidIcons` whenever `design_system/` is
next in a story's write scope.

### V-4 — story class metadata disagrees between artifact and handoff

`story_master.md` records `Complexity: trivial` / `Story-Class: trivial`; the
review handoff declared `Story-Class: standard`. Does not affect this gate — the
story is single-lane mobile either way, satisfying Core Rule 15 — but Scrum
Master should reconcile the two before closure so the DONE gate reads a
consistent class.

## Traceability

- Requirements: `story_master.md` AC1-AC7, `## In Scope` items 1-6,
  `## Out of Scope`, `## Open Question Impact` (OQ5 correctly excluded — dark +
  `vi` is the only enabled user-facing configuration).
- UX / architecture: SKIPPED per trivial story class; design source
  `cupid-app-design-system` locked, `Design-Screen: contract` resolved and
  confirmed against the rendered reference.
- Rework provenance: `data/retro-audit/rework-backlog.md` RWB-20260816-006, whose
  four stated remediation steps (capture implemented, render reference,
  re-compare and fix, place the pair with a PASS report) are all satisfied.
- Evidence: `visual-fidelity/visual-fidelity-report.md` plus both PNGs, with
  analyze and scoped tests independently rerun by the reviewer.

## State Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Route V-1 and V-2 as follow-up items; do not close them silently inside this
  story.
