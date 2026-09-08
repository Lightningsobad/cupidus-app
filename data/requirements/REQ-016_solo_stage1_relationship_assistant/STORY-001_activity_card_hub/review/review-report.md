# Review Report — STORY-001 (REQ-016) Danh sách việc-cần-làm / Activity Card Hub

Outcome: BLOCKED

Blocker: `REVIEW_SCOPE_TOO_BROAD` (Reviewer SKILL rule 1c)

- Review type requested: `full-story-review`
- Scope gate: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-001_activity_card_hub/review/scope-gate.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline (`BaseHead`): `9207f7296a64cd37ca60e432939469ca96860762`
- Reviewed at: 2026-09-08
- Story: `Complexity: complex`, `Story-Class: shared-foundation`, `Implementation Lane: shared (mobile)`

## Rationale

The story diff is **70 files, +14690 / −469**, of which **44 are source/test/config**
files. The `full-story-review` budget is 12 such files and 2 governing artifacts
over ~20 KB; this story presents 44 files and at least 3 oversized artifacts
(`test-results.md` 923 lines, `visual-fidelity-report.md` 496 lines,
`cupid_database.g.dart` +2654/−453). That is 3.7x the file budget.

The cause is structural, not a handoff error: all seven phases (P1, P2, P3, P4,
P7, P5, P6) shipped without any incremental per-phase review, so this single pass
would have to carry 7 phase contracts, 15 acceptance criteria across two AC
sources, 4 rendered screens and 13 images in one context. Rule 1c requires
stopping before reading broadly rather than producing a verdict with unread
evidence behind it. No source, test, config, or evidence implementation file was
opened.

This matches the sibling precedent in this same requirement: STORY-003 (50 files,
+9802/−542) returned `BLOCKED` / `REVIEW_SCOPE_TOO_BROAD` on its first pass and
was completed successfully through per-phase slices plus a final synthesis.

## Measured Scope

| Metric | Budget | Actual |
|---|---|---|
| Source/test/config files | ≤ 12 | 44 |
| Governing artifacts > ~20 KB | ≤ 2 | 3+ |
| Diff | — | 70 files, +14690 / −469 |

## What Is Required To Unblock

Dispatch the 8-pass plan written in full (exact files, ACs, invariants, phase
file and query keys per slice) in `review/scope-gate.md` § *Prescribed Slice
Plan*. One at a time, since `story-state:STORY-001` admits one worker at a time
in this worktree.

| Pass | Mode | Subject | Files |
|---|---|---|---|
| S1 | `scoped-slice` | P1 local card store — schema, DAO, v2→v3 migration | 9 |
| S2 | `scoped-slice` | P2 domain repository + P7 `ActivityType` — shared contract | 9 |
| S3 | `scoped-slice` | P3 occasion content package — R-7/R-15 | 6 |
| S4 | `scoped-slice` | P4 hub list, status buckets, entry point (owns FLAG-2) | 9 |
| S5 | `scoped-slice` | P5 minute-one empty state + quick capture | 5 |
| S6 | `scoped-slice` | P6 detail, lifecycle, delete (owns FLAG-1) | 6 |
| S7 | `scoped-slice` | Visual fidelity images + runtime/entry-point evidence | artifacts only |
| S8 | `final-synthesis` | Verdict from S1–S7 reports only | slice reports only |

Each slice writes `review/slice-<n>-<name>.md` inside the declared WriteScope.
S8 overwrites this file with the story's real `Outcome:` line.

## Finding During Scoping — Acceptance Source Of Truth

`story_master.md` lists 7 acceptance criteria. The expanded set **AC-10..AC-15
exists in `requirements/requirements.md`**, and `master-plan.md` §3A binds one of
them to code: *"AC-15 mất dữ liệu âm thầm khi lùi trạng thái → P2, P6"*.

So `requirements/requirements.md` is this story's acceptance source of truth, not
`story_master.md`. Every slice handoff must name its ACs from that file. A slice
scoped only to the base 7 would skip exactly the criterion that decides FLAG-1
below — which is how a passing verdict on unread acceptance criteria happens.

## The Two Flagged Items — Not Classifiable At This Depth

Both were asked for a blocking-vs-deferred classification. Neither can be given
one honestly from a scope gate, because both turn on code this pass is blocked
from reading. Each is assigned to the slice holding its code, with the exact test
that slice must apply (full text in `scope-gate.md` § *Open Flags*):

- **FLAG-1 — repository has no field-write path** (`updateStatus`,
  `clearScheduledDate`, `deleteCard`, `createCard` only; detail-screen field edits
  reportedly live in cubit memory; `status` transitions do persist).
  → **S2** establishes the contract surface, **S6** establishes what the detail
  screen does with it and issues the classification. Rule 14 (exact AC text)
  applies: AC-4 as written in `story_master.md` requires transition + bucket
  placement and states no round-trip persistence — but AC-15 is bound to P2+P6 and
  must be read from `requirements/requirements.md` before that reading stands.
- **FLAG-2 — `activity_card_hub_view.dart` mounts neither the P5 widgets nor the
  P6 detail route.** → **S4**, against rule 12e1 (reachable entry point,
  non-waivable) and the story's *System Integration And Discoverability* section.
  Test to apply: if AC-1, AC-2, AC-4, or AC-7 can be exercised only by a widget
  test mounting the widget directly, and never by a user arriving from the main
  menu, the AC is unverifiable end-to-end — `PATCH_REQUIRED`, not a staged-rollout
  gap. S4 must confirm this in code, not inherit the claim.

## Visual Fidelity — Deferred To S7, Not Pre-Decided

`visual-fidelity-report.md` carries a top-line `VISUAL_FIDELITY: FAIL`. Per the
P6 implementer note it was held there only because requirement-level D-8 was
open; D-8 closed on 2026-09-08 with no field/column/enum change and no patch
phase required. Re-assessing that marker needs the 496-line report, the 14 deltas
(D-14..D-27) and the 13 images actually opened (rule 12e3: open the images, do not
count the files) — so S7 decides it. One scoping observation for S7: four screens
have design references but nine implemented captures exist, including
`round2`/`round3`/`round4` retries and an `-emulator-5554` variant of the same
screen; the authoritative capture per screen must be established before comparing,
or the verdict is wrong in whichever direction the stale frame points.

## Gates Not Yet Evaluated

None of the story's critical gates were evaluated in this pass. Enumerated with
their owning slice in `scope-gate.md` § *Risk Surfaces And Critical Gates*: additive
migration (ADR-015.6), R-1b no behaviour-tracking fields, shared-contract
stability for 11 downstream stories, R-7/BR-8 no runtime AI, entry-point
reachability (12e1), AC-15 silent data loss, mobile design fidelity (12e2/12e3),
mobile runtime startup smoke (12g).

## Preconditions Verified

- `data/retro-audit/rework-backlog.md` — 0 items `Status: PENDING`, 0
  `Status: IN_PROGRESS`. Rule 1a precondition clear; no retro bypass needed.
- Required artifacts present for a complex story: `requirements/`, `ux/`,
  `architecture/solution.md`, `architecture/contract-summary.md`, `coding-plan/`
  (master plan + 7 phase files + `test-results.md`), `visual-fidelity/`.

## State Recommendation

- Do NOT check `Review (Reviewer)` in `story_master.md`.
- Story status: `BLOCKED` on review scope until the slice plan runs.
- No implementation rework is requested by this pass. Nothing in the code has
  been judged; this blocker is about review method, not implementation quality.
- Owner of the next action: **Scrum Master** — dispatch S1 per `scope-gate.md`.
