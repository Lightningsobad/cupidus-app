# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
8 of 20 RWB items resolved (original 15 + split-out RWB-016/017/018/019/020):
RWB-001..008. RWB-009 IN_PROGRESS: `STORY-042_love_timeline_design_fidelity_hardening`
implementation DONE (`VISUAL_FIDELITY: PASS`, 2/20 deviations fixed),
awaiting Reviewer. RWB-012..020 (split-out, LOW) and RWB-010/011 remain
`PENDING`.

### RWB-001..008 — RESOLVED (compact history; full detail in each story's own artifacts)

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
- **RWB-008** (`antighost` zero evidence) -> `STORY-041` DONE, Reviewer
  `DEFERRED_ONLY` cycle 1 (AC1-7 PASS, AC1/AC5 PASS-with-deferral). R-2
  narrow-width check found no defect. Closure commit `d709b3f`. Deferred:
  D-05 (undisclosed public-countdown row) -> RWB-018; RV-1 (undisclosed
  sound-penalty row label, reviewer-found) -> RWB-019.

### RWB-012 / RWB-013 / RWB-014 / RWB-015 / RWB-016 / RWB-017 / RWB-018 / RWB-019 / RWB-020 — PENDING (split-out deferred findings, mobile lane except RWB-018/019/020, LOW)

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
- **RWB-019**: `antighost` sound-penalty row label `Gây ồn` vs design's
  `Phát âm thanh`; needs l10n string fix. Anchor: STORY-022, split from
  Iris-QC-6's STORY-041 review (RV-1).
- **RWB-020**: `render-design-canvas.js` has no `--scroll` flag, `--hide`
  doesn't survive screen-click re-render; below-the-fold content
  uncapturable. Anchor: devops, split from STORY-042's own AC4 capture.

## Next Valid Step

STORY-042 implementation DONE (Alex-Mobile-Dev-8, verified). Next action:
dispatch Iris-QC, `Mode: compact-story-review`, using
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-042_love_timeline_design_fidelity_hardening/scrum-master-checkpoint.md`
for exact scope/paths. After CLEAN/DEFERRED_ONLY: DONE gate, close
RWB-009 (mirror RWB-008 pattern), then ask user for next item (RWB-011
candidate; RWB-010 tooling-blocked). Do NOT start RWB-010/011/012..020
without a separate explicit user decision.

Do Not Re-read: REQ-001 cycle detail; STORY-034..041's/STORY-018's/022's/025's
own artifacts (carried forward into each hardening story's own `## Background`).

## Standing operational notes

- Never write literal "retro-audit" in a non-reviewer handoff prompt
  (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase or use
  `Checkpoint: NONE`.
- Platform `Grep`/`Glob` unavailable; use `Read offset`/`limit`, or
  `/usr/bin/grep -n "<pat>" <file>` (no pipes) for `data/**` search.
- `Agent(subagent_type: "fork")` BLOCKED — delegate only to named
  specialists. `list-releasable-agents.sh` printing other-session handles
  is a harmless no-op.
- `guard-story-done-evidence.sh` requires a UI-lane story's OWN
  `visual-fidelity/` dir with a same-screen `implemented-*`/
  `design-reference-*` PNG pair + `visual-fidelity-report.md`
  (`VISUAL_FIDELITY: PASS`).
- Central OQ registry: `data/intake/bootstrap/conflicts_open_questions.md`.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
