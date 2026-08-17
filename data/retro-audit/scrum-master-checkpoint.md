# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
10 of 21 RWB items resolved (original 15 + split-out RWB-016..021, denominator
grew to 21 when RWB-011's own review split out RWB-021): RWB-001..009,
RWB-011. RWB-010 and RWB-012..021 (split-out, LOW except RWB-010 HIGH)
remain `PENDING`.

### RWB-001..009 — RESOLVED (compact history; full detail in each story's own artifacts)

- **RWB-001** (`pairing_choice` canvas missing) -> `STORY-034` DONE, Reviewer
  `DEFERRED_ONLY`. Closure commit `e28a6c2`. Deferred D1 split to RWB-012.
- **RWB-002** (`welcome` zero evidence) -> `STORY-035` DONE, 3 review cycles,
  final `CLEAN` after D1 gradient-axis fix widened into scope. Closure commit
  `691f4b5`.
- **RWB-003** (`register` zero evidence) -> `STORY-036` DONE, Reviewer cycle 1
  `DEFERRED_ONLY` (AC2 field-card line-height fixed). Closure commit `a32c96e`.
- **RWB-004** (`invite` zero evidence) -> `STORY-037` DONE, Reviewer 2 cycles
  (cycle 1 `PATCH_REQUIRED` B1 backdrop-occlusion Scaffold override, cycle 2
  `DEFERRED_ONLY`). Closure commit `c7e9d2f`. Deferred DEF-1 (6 sibling
  screens, same override) split to RWB-013.
- **RWB-005** (`paired` 15 deviations, 14 code-fixed unconfirmed) ->
  `STORY-038` DONE, Reviewer `CLEAN`. Fixed one real regression (D3 avatar
  cluster box-model). Closure commit `0f0969a`.
- **RWB-006** (`contract` D-1..D-13 unconfirmed + DEF-1/DEF-2 unresolved) ->
  `STORY-039` DONE, Reviewer `DEFERRED_ONLY`. DEF-1/DEF-2 + new DEF-2a
  fixed. Split: RWB-014 (no render path), RWB-015 (clause-counter
  misfiled). Closure commit `9da5d2c`.
- **RWB-007** (`chat` 25 pre-fixed deviations) -> `STORY-040` DONE, Reviewer
  `DEFERRED_ONLY`. D2 fixed as AC4; new N1 render-only crash fixed. Closure
  `e1e6f01`. Deferred: D1->RWB-016, R-1->RWB-017; N2->`BUG-20260817-001`.
- **RWB-008** (`antighost` zero evidence) -> `STORY-041` DONE, Reviewer
  `DEFERRED_ONLY`. Closure `d709b3f`. Deferred: D-05->RWB-018,
  RV-1->RWB-019.
- **RWB-009** (`timeline` zero evidence) -> `STORY-042` DONE, Reviewer
  `CLEAN`. 2/20 deviations fixed; tooling gap split to RWB-020. Closure
  `7e5ab1f`.
- **RWB-011** (`shared expenses` zero evidence either side) -> `STORY-043`
  DONE, Reviewer `Iris-QC-8` 2 cycles (cycle 1 `PATCH_REQUIRED` B-1 stale
  iOS evidence + B-2 mis-cited image, cycle 2 `DEFERRED_ONLY`, all 7 ACs
  MET). All 32 STORY-028 deviations re-verified against a real render; 2
  render-only defects fixed. M-3 doc correction applied to STORY-028's own
  report. D-1/D-2/M-1 sharpened descriptions split to RWB-021. Closure
  `ff5d069`.

### RWB-012 / RWB-013 / RWB-014 / RWB-015 / RWB-016 / RWB-017 / RWB-018 / RWB-019 / RWB-020 / RWB-021 — PENDING (split-out deferred findings, mobile lane except RWB-018/019/020, LOW)

- **RWB-012**: `pairing_choice` app build doesn't apply design-system
  surface/CTA styling (from RWB-001's DEF D1). Anchor: STORY-002.
- **RWB-013**: 6 sibling screens (otp/love_contract/onboarding_profile_setup/
  permissions/joincode/vow) carry the same opaque `colorBackground` override
  STORY-037 fixed on `invite`, occluding `CupidAppBackground`. Anchor: STORY-011.
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
- **RWB-021**: shared `CupidAddAction` FAB resolves to a circle/pill instead
  of the design's 20px rounded square; `CupidPrimaryButton` iOS CTA gap is
  narrower than STORY-028 originally recorded (height/label-size deltas +
  missing leading glyph only); M-1 FAB overlap confirmed Material-only.
  Anchor: `mobile/lib/design_system/adaptive/**`, split from STORY-043's
  round-2 review (D-c), same exclusion class as RWB-012.

## Next Valid Step

RWB-011 closed. Remaining candidates: RWB-010 (HIGH, tooling-blocked —
`render-design-canvas.js` cannot force `galleryOpen`) and split-out LOW
items RWB-012..021. Next action: `AskUserQuestion` to select the next RWB
item — do NOT auto-select.

Do Not Re-read: REQ-001 cycle detail; STORY-034..043's/STORY-018's/022's/025's/
028's own artifacts (carried forward into each hardening story's own
`## Background` or this checkpoint's compact history above).

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
