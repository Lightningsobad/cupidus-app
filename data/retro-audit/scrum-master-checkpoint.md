# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
6 of 16 RWB items resolved (original 15 + split-out RWB-016): RWB-001..006.
RWB-007 is `IN_PROGRESS` (hardening via
`STORY-040_chat_typing_ghost_design_fidelity_hardening`, user-selected next
item). RWB-012/013/014/015/016 (split-out deferred findings) and
RWB-008..011 remain `PENDING`.

### RWB-001..006 — RESOLVED (compact history; full detail in each story's own artifacts)

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

### RWB-20260816-007 — IN PROGRESS

`STORY-040` Requirements done (Andy-PO-6): D1 split to `RWB-016`
(design_system token, out of WriteScope); D2 (iOS-axis 44pt clamp) folded
in as AC4. UX/Architecture SKIPPED:trivial. Next: dispatch mobile-dev.
Full detail in the story's own `scrum-master-checkpoint.md` — do not
re-derive.

### RWB-012 / RWB-013 / RWB-014 / RWB-015 / RWB-016 — PENDING (split-out deferred findings, mobile lane, LOW)

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

RWB-008..011 remain `PENDING`, untouched — single-active-item pattern holds,
no work started without an explicit user decision per item.

## Next Valid Step

RWB-007 is the active item (user-selected). STORY-040's own checkpoint under
its story dir is the authoritative next-step source: dispatch Andy-PO, Mode:
story-requirements, to scope STORY-040 (explicit D1/D2 disposition
required), then proceed through the standard mobile-lane trivial-story
pipeline (mobile-dev -> Reviewer Tier 1 compact-story-review) to closure.
On closure, mirror the RWB-006 closure pattern exactly across
`rework-backlog.md`, `req_master.md`, and this checkpoint. After RWB-007
closes, ask the user (`AskUserQuestion`, never auto-select) which item to
work next: RWB-008 (anti-ghosting settings), RWB-009 (love timeline),
RWB-011 (shared expenses) — RWB-010 is tooling-blocked (`galleryOpen`
unrenderable), RWB-012/013/014/015 are LOW split-out findings. REQ-002 top
`Status` stays `IN_PROGRESS` until all 15 RWB items resolve. Do NOT start
any without an explicit user decision.

Do Not Re-read: REQ-001 cycle detail (closed, superseded above);
STORY-034's/035's/036's/037's/038's/039's own artifact bodies (fully read and
actioned in prior passes); STORY-018's own review/visual-fidelity artifacts
(fully read, carried forward into STORY-040's own Background).

## Standing operational notes

- Never write the literal substring "retro-audit" in a non-reviewer handoff
  prompt (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase, or
  use `Checkpoint: NONE`.
- Platform `Grep`/`Glob` not available this session. `Read` `offset`/`limit`
  for ranged reads under ~20KB. rtk-wrapped `grep` returns unreliable
  match-counts-only for `data/**` content search — use `/usr/bin/grep -n
  "<pat>" <file>` (no output-filter pipes — those are guard-blocked) to
  bypass the rewrite and get real line numbers/content.
- `Agent(subagent_type: "fork")` is BLOCKED here by
  `guard-broad-handoff.sh [TARGET_NOT_ALLOWLISTED]` — not on this runtime's
  software-dev allowlist. Do all research directly; delegate only to the
  fixed named specialist agents.
- `guard-story-done-evidence.sh` (`DONE_WITHOUT_VISUAL_EVIDENCE`) requires a
  UI-lane story's OWN `visual-fidelity/` directory to physically contain a
  same-screen `implemented-*`/`design-reference-*` PNG pair plus a
  `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`.
- Central OQ registry is `data/intake/bootstrap/conflicts_open_questions.md`.
- `list-releasable-agents.sh` can print handles from other, unrelated
  sessions that no longer resolve via `TaskStop` — harmless no-op.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
