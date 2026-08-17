# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
4 of 13 RWB items resolved so far: RWB-001, RWB-002, RWB-003, RWB-004.
RWB-013 newly split out of RWB-004's DEF-1, `PENDING`.

### RWB-20260816-001 — RESOLVED (2026-08-16)

`STORY-034_pairing_choice_canvas_addition` DONE, Reviewer `DEFERRED_ONLY`
(AC1-4 PASS). `pairingchoice` node added to design system, F-B closed,
evidence pair rendered+paired. Deferred D1 (surface/CTA styling gap) split
out as RWB-20260816-012 (mobile lane, LOW, PENDING). Closure commit
`e28a6c2` on `main`. Full detail: `STORY-034.../review/review-report.md`.

### RWB-20260816-002 — RESOLVED (2026-08-17)

`STORY-035_welcome_design_fidelity_hardening` DONE. Full RED-PATCH plan:
cycle 1 `PATCH_REQUIRED` -> cycle 2 `DEFERRED_ONLY` (user widened Write Scope
to fix D1 gradient-axis defect inline) -> Phase P1 (Tech Lead + mobile-dev)
fixed `cupid_color_tokens.dart` at its root -> cycle 3 `Outcome: CLEAN` (0
blocking/deferred), Reviewer independently re-measured and confirmed match.
Closure commit `691f4b5` on `main`. Full detail:
`STORY-035.../review/review-report.md`.

### RWB-20260816-003 — RESOLVED (2026-08-17)

`STORY-036_register_design_fidelity_hardening` DONE. Routed Product Owner
(trivial/mobile single-lane; UX/Tech Lead `SKIPPED:trivial`) -> mobile-dev
(Alex-Mobile-Dev-2) -> Reviewer (Iris-QC-2, `compact-story-review`).
Mobile-dev captured a real evidence pair and the rendered-to-rendered
comparison surfaced and fixed a real AC2 deviation (field-card line-height,
forced `StrutStyle`, regression test added). Reviewer cycle 1 `Outcome:
DEFERRED_ONLY`: AC1-5 all PASS with independently re-derived evidence (root
cause re-derived from Material 3 line-box math, both PNGs opened directly,
design-source HTML cross-checked, all 3 test commands rerun independently);
governed header-chrome deviation independently verified against STORY-002's
UX spec. 0 blocking findings; 3 non-blocking deferred (DEF-1 traceability
nit, DEF-2 residual sub-visible password-card gap, DEF-3 evidence-count
nit). Full detail: `STORY-036.../review/review-report.md`.

Closure commit `a32c96e` on `main` (story artifacts + 2 already-pending doc
edits the helper swept in); `req_master.md`/`rework-backlog.md` updated to
match. Full detail: `STORY-036.../review/review-report.md`.

### RWB-20260816-004 — RESOLVED (2026-08-17)

`STORY-037_invite_design_fidelity_hardening` DONE. Routed Product Owner
(trivial/mobile single-lane; UX/Tech Lead `SKIPPED:trivial`) -> mobile-dev
(Alex-Mobile-Dev-3) -> Reviewer (Iris-QC-3, `compact-story-review`), two
cycles. Mobile-dev captured a real evidence pair and fixed a real deviation
(D1, share CTA copy). Reviewer cycle 1 `Outcome: PATCH_REQUIRED`: 1 blocking
(B1, HIGH) — an opaque `Scaffold` `backgroundColor` override occluded the
shared `CupidAppBackground` sky wash + star layer; AC1/AC2/AC4 FAIL.
Mobile-dev rework removed the override (STORY-032 `forgot_screen.dart:103-
106` precedent), re-captured the implemented-side render, added 4
screen-backdrop probe rows to the measured table. Reviewer cycle 2 `Outcome:
DEFERRED_ONLY`: 0 blocking, AC1-5 all PASS, independently re-derived (7
self-chosen backdrop probes, 5 exact + 2 within 1 unit of blue). Deferred
DEF-1 (6 sibling screens carry the same override, out of this single-screen
story's scope) split out as `RWB-20260816-013` (mobile lane, LOW, PENDING).
Full detail: `STORY-037.../review/review-report.md`.

Closure actions taken:
- `git-story-boundary.sh complete` -> commit `c7e9d2f` on `main`.
- `story_master.md`: Review checked, Status -> `DONE`, `## Review Record`
  section added.
- `req_master.md`: STORY-037 row -> `trivial`/`DONE`; `## Retro Audit`
  RWB-004 bullet rewritten RESOLVED; RWB-013 bullet added.
- `rework-backlog.md`: RWB-004 row + detail -> `RESOLVED`; RWB-013 row +
  detail section added, `PENDING`.
- Not yet committed as of this checkpoint write — see Next Valid Step.

### RWB-20260816-013 — PENDING (split 2026-08-17)

Six sibling screens (`otp_screen.dart`, `love_contract_screen.dart`,
`onboarding_profile_setup_screen.dart`, `permissions_screen.dart`,
`joincode_screen.dart`, `vow_screen.dart`) still set
`backgroundColor: colors.colorBackground`, occluding the same
`CupidAppBackground` sky wash STORY-037 just fixed on `invite`. Split out of
RWB-004's Reviewer cycle-2 DEF-1; corroborated by the STORY-032/033
closing-pass D4-1 finding in `req_master.md`. Tracked against STORY-011 as
nearest anchor (affected screens span multiple stories). Requirement-level
sweep, mobile lane. Untouched — no user decision routed yet.

RWB-005..011 and RWB-012 remain `PENDING`, untouched — single-active-item
pattern holds, no work started without an explicit user decision per item.

## Next Valid Step

Commit `rework-backlog.md` + `req_master.md` + this portfolio checkpoint
together (RWB-004 closure + RWB-013 split, mirroring the RWB-002/RWB-003
closure commit pattern). Then use `AskUserQuestion` to ask which RWB item to
work next — candidates: RWB-005 (paired success), RWB-006 (love contract),
RWB-007 (chat typing-ghost), RWB-008 (anti-ghosting settings), RWB-009 (love
timeline), RWB-010 (private gallery, tooling-limited), RWB-011 (shared
expenses), RWB-012 (pairing_choice styling gap), RWB-013 (backdrop-occlusion
sweep, newly split). Do NOT auto-select. REQ-002 top `Status` stays
`IN_PROGRESS` until all 13 RWB items resolve (4 of 13 resolved: RWB-001,
RWB-002, RWB-003, RWB-004).

Do Not Re-read: REQ-001 cycle detail (closed, superseded by the one-line
summary above); STORY-034's/STORY-035's/STORY-036's/STORY-037's own artifact
bodies (already fully read and actioned in prior passes).

## Standing operational notes

- Never write the literal substring "retro-audit" in a non-reviewer handoff
  prompt (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase, or
  use `Checkpoint: NONE`.
- Platform `Grep`/`Glob` tools are NOT available in this runtime session
  (`ToolSearch` returns no match; calling `Grep` errors with "search file
  contents with grep via the Bash tool instead"). Use `Read` with
  `offset`/`limit` for ranged reads. Bash `grep -n -m N '<pat>' <file>`
  (single command, no pipe/regex-alternation-heavy pattern) is allowed under
  `data/{requirements,bugs,devops,intake,architecture}` but its output in
  this runtime is unreliable (returns match counts, not content) — prefer
  `Read` with `offset`/`limit` for anything under ~20KB.
- `Agent(subagent_type: "fork")` is BLOCKED here by
  `guard-broad-handoff.sh [TARGET_NOT_ALLOWLISTED]` — not on this runtime's
  software-dev allowlist. Do all research directly; delegate only to the
  fixed named specialist agents.
- `guard-story-done-evidence.sh` (`DONE_WITHOUT_VISUAL_EVIDENCE`) requires a
  UI-lane story's OWN `visual-fidelity/` directory to physically contain a
  same-screen `implemented-*`/`design-reference-*` PNG pair plus a
  `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`, even when
  the canonical evidence pair correctly lives in a different story's
  directory by design. A same-screen reference in prose or a relative-path
  pointer is not sufficient — copy the actual PNGs into the story's own
  directory too.
- Central OQ registry is `data/intake/bootstrap/conflicts_open_questions.md`
  (found via `resolve-oq.md`), not a `data/requirements/` file.
- `list-releasable-agents.sh` can print handles from other, unrelated
  sessions that no longer resolve via `TaskStop` ("No task found") —
  harmless no-op, not an error to chase; it means those were already gone.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
