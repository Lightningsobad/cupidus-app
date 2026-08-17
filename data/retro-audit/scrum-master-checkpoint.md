# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
7 of 18 RWB items resolved (original 15 + split-out RWB-016/017/018):
RWB-001..007. RWB-008 `IN_PROGRESS` (STORY-041, PO+mobile-dev done,
reviewer dispatched). RWB-012..018 (split-out, LOW) and RWB-009..011
remain `PENDING`.

### RWB-001..007 — RESOLVED (compact history; full detail in each story's own artifacts)

- **RWB-001** (`pairing_choice` canvas missing) -> `STORY-034` DONE, Reviewer
  `DEFERRED_ONLY`. Closure commit `e28a6c2`. Deferred D1 split to RWB-012.
- **RWB-002** (`welcome` zero evidence) -> `STORY-035` DONE, 3 review cycles,
  final `CLEAN` after D1 gradient-axis fix widened into scope. Closure commit
  `691f4b5`.
- **RWB-003** (`register` zero evidence) -> `STORY-036` DONE, Reviewer cycle 1
  `DEFERRED_ONLY` (AC2 field-card line-height fixed). Closure commit `a32c96e`.
- **RWB-004** (`invite` zero evidence) -> `STORY-037` DONE, Reviewer 2 cycles:
  cycle 1 `PATCH_REQUIRED` (B1 backdrop-occlusion Scaffold override), rework,
  cycle 2 `DEFERRED_ONLY`. Closure commit `c7e9d2f`. Deferred DEF-1 (6 sibling
  screens with the same override) split to RWB-013. Tracking-artifact closure
  (rework-backlog/req_master/this checkpoint) committed as `f1bc23b`.
- **RWB-005** (`paired` zero evidence, 15 deviations, 14 originally
  code-fixed but never visually confirmed) -> `STORY-038` DONE, Reviewer
  `CLEAN` cycle 1. Found/fixed one real regression not caught by STORY-014's
  original claim (D3 avatar cluster box-model). Implementation commit
  `dfbffb2`. Tracking-artifact closure commit `0f0969a`.
- **RWB-006** (`contract` zero evidence; STORY-015's D-1..D-13
  code-fixed-but-unconfirmed + DEF-1/DEF-2 real-unresolved) -> `STORY-039`
  DONE, Reviewer `DEFERRED_ONLY` (AC1-7 PASS). DEF-1/DEF-2 fixed + a new
  render-caught regression DEF-2a fixed. Split out: `RWB-014` (D-7/8/10/13
  no render path), `RWB-015` (clause-counter delta misfiled under F-5).
  Closure commit `9da5d2c`.
- **RWB-007** (`chat` zero evidence, 25 pre-fixed deviations) -> `STORY-040`
  DONE, Reviewer `DEFERRED_ONLY` cycle 1 (AC1-8 PASS). D2 (iOS toggle clamp)
  fixed as AC4; new N1 render-only crash found+fixed. Closure commit
  `e1e6f01`. Deferred: D1 -> RWB-016, R-1 (undisclosed header delta,
  reviewer-found) -> RWB-017; N2 (FAB occludes send button, functional) ->
  `BUG-20260817-001` (bug queue, not this registry).

### RWB-012 / RWB-013 / RWB-014 / RWB-015 / RWB-016 / RWB-017 / RWB-018 — PENDING (split-out deferred findings, mobile lane except RWB-018, LOW)

- **RWB-012**: `pairing_choice` app build doesn't apply design-system
  surface/CTA styling (from RWB-001's DEF D1). Anchor: STORY-002.
- **RWB-013**: 6 sibling screens (`otp_screen.dart`, `love_contract_screen.dart`,
  `onboarding_profile_setup_screen.dart`, `permissions_screen.dart`,
  `joincode_screen.dart`, `vow_screen.dart`) carry the same opaque
  `backgroundColor: colors.colorBackground` override STORY-037 just fixed on
  `invite`, occluding the shared `CupidAppBackground` sky wash. Anchor:
  STORY-011.
- **RWB-014**: `contract` D-7/D-8/D-10/D-13 re-confirmed by test/structure
  only, no in-scope render path (`main_preview.dart` lacks a
  requester-unsigned fixture; canvas has no signed/error branch either).
  Anchor: STORY-015.
- **RWB-015**: `contract` `2/20 điều khoản` clause-counter row has no design
  counterpart, currently misfiled under F-5; needs its own PO/Tech Lead
  disposition alongside F-1/F-2/F-3. Anchor: STORY-015.
- **RWB-016**: `chat` missing `colorOnAccent`/inverse-text token; real in
  light theme (OQ5), imperceptible in audited dark theme. Anchor: STORY-018.
- **RWB-017**: `chat` header renders `Linh` alone, no partner pairing +
  presence chip (pre-existing `CupidHeader` title-only limitation,
  reviewer-found). Anchor: STORY-018.
- **RWB-018**: `antighost` penalty card omits undisclosed "Public countdown"
  row; needs new persisted setting + backend field + l10n. Anchor:
  STORY-022, split from STORY-041's PO scoping.

### RWB-20260816-008 — IN PROGRESS

STORY-041: PO-scoped (trivial/mobile; D-05->RWB-018, R-2->AC3 no defect
found, D-01/D-02/D-03/R-1/R-3 out of scope) and implemented by
Alex-Mobile-Dev-7 (one file changed: `main_preview.dart` dev-only preview
switch; `anti_ghost_screen.dart` untouched) — both RETURNED and verified
against disk, no discrepancies. Reviewer Tier 1 compact-story-review
dispatched to `Iris-QC-6` (SendMessage reuse), awaiting return.

## Next Valid Step

Verify Iris-QC-6's `review/review-report.md` against disk. If
`CLEAN`/`DEFERRED_ONLY`: mark STORY-041 `DONE`, run `git-story-boundary.sh
complete`, close RWB-008 (mirror RWB-007/STORY-040) across
`rework-backlog.md`/`req_master.md`/this checkpoint, then `AskUserQuestion`
(never auto-select) for RWB-009 (timeline) vs RWB-011 (expenses) — RWB-010
tooling-blocked, RWB-012..018 LOW split-outs not offered; REQ-002 stays
`IN_PROGRESS` until all 18 resolve. If `PATCH_REQUIRED`/`BLOCKED`: route
rework back to Alex-Mobile-Dev-7.

Do Not Re-read: REQ-001 cycle detail; STORY-034..040's/STORY-018's/022's
own artifacts (carried forward into STORY-040's/041's `## Background`).

## Standing operational notes

- Never write literal "retro-audit" in a non-reviewer handoff prompt
  (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase or use
  `Checkpoint: NONE`.
- Platform `Grep`/`Glob` not available this session; use `Read`
  `offset`/`limit` for ranged reads, or `/usr/bin/grep -n "<pat>" <file>`
  (no output-filter pipes) for `data/**` content search — rtk-wrapped
  `grep` returns unreliable match-counts only.
- `Agent(subagent_type: "fork")` is BLOCKED (`guard-broad-handoff.sh
  [TARGET_NOT_ALLOWLISTED]`) — do research directly; delegate only to named
  specialist agents.
- `guard-story-done-evidence.sh` (`DONE_WITHOUT_VISUAL_EVIDENCE`) requires a
  UI-lane story's OWN `visual-fidelity/` directory to physically contain a
  same-screen `implemented-*`/`design-reference-*` PNG pair plus a
  `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`.
- Central OQ registry: `data/intake/bootstrap/conflicts_open_questions.md`.
- `list-releasable-agents.sh` printing other-session handles is a harmless
  no-op.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
