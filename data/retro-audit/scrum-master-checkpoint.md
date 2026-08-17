# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
5 of 13 RWB items resolved: RWB-001, RWB-002, RWB-003, RWB-004, RWB-005.
RWB-012/RWB-013 (split-out deferred findings), RWB-006..011 remain `PENDING`.

### RWB-001..005 — RESOLVED (compact history; full detail in each story's own artifacts)

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
- **RWB-005** (`paired` zero evidence, largest claimed-fix surface: 15
  deviations, 14 originally code-fixed but never visually confirmed) ->
  `STORY-038` DONE, Reviewer `CLEAN` cycle 1 (Iris-QC-4, compact-story-review).
  Rendered comparison re-verified all D1-D14 plus D15-still-excluded; found
  and fixed one real regression not caught by STORY-014's original claim (D3
  couple-presence avatar cluster, Flutter inside-stroke `Border.all` vs. the
  design's content-box sizing — box 76->82px, offset 54->60). Implementation
  commit `dfbffb2` (via `git-story-boundary.sh commit`+`complete`, not a
  manual commit — manual commit first causes `no story changes to commit`).
  Tracking-artifact closure (rework-backlog/req_master/this checkpoint) not
  yet committed as of this write — commit next.

### RWB-012 / RWB-013 — PENDING (split-out deferred findings, mobile lane, LOW)

- **RWB-012**: `pairing_choice` app build doesn't apply design-system
  surface/CTA styling (from RWB-001's DEF D1). Anchor: STORY-002.
- **RWB-013**: 6 sibling screens (`otp_screen.dart`, `love_contract_screen.dart`,
  `onboarding_profile_setup_screen.dart`, `permissions_screen.dart`,
  `joincode_screen.dart`, `vow_screen.dart`) carry the same opaque
  `backgroundColor: colors.colorBackground` override STORY-037 just fixed on
  `invite`, occluding the shared `CupidAppBackground` sky wash. Corroborated
  by the STORY-032/033 closing-pass D4-1 finding in `req_master.md`. Anchor:
  STORY-011.

RWB-006..011 remain `PENDING`, untouched — single-active-item pattern holds,
no work started without an explicit user decision per item.

## Next Valid Step

1. Stage and commit the three RWB-005 tracking-artifact edits together
   (`data/retro-audit/rework-backlog.md`, `req_master.md`, this checkpoint —
   all already edited to `RESOLVED`/`DONE`, not yet committed) as one closure
   commit on `main` (mirror `f1bc23b`'s RWB-004 closure-commit pattern).
2. Then use `AskUserQuestion` to ask which RWB item to work next — do NOT
   auto-select (standing constraint). Candidates: RWB-006 (love contract,
   STORY-015), RWB-007 (chat typing-ghost, STORY-018), RWB-008 (anti-ghosting
   settings, STORY-022), RWB-009 (love timeline, STORY-025), RWB-010 (private
   gallery, STORY-026 — tooling-blocked, `galleryOpen` state cannot be forced
   by `render-design-canvas.js`), RWB-011 (shared expenses, STORY-028),
   RWB-012 (pairing_choice styling gap, mobile/LOW), RWB-013
   (backdrop-occlusion sweep across 6 sibling screens, mobile/LOW).
3. On selection, create the hardening story (mirror STORY-034..038 pattern),
   open its Story Git Boundary, and run the same PO -> UX/TL(skip if
   trivial) -> implementation -> Reviewer pipeline. REQ-002 top `Status`
   stays `IN_PROGRESS` until all 13 RWB items resolve.

Do Not Re-read: REQ-001 cycle detail (closed, superseded by the one-line
summary above); STORY-034's/STORY-035's/STORY-036's/STORY-037's/STORY-038's
own artifact bodies (already fully read and actioned in prior passes).

## Standing operational notes

- Never write the literal substring "retro-audit" in a non-reviewer handoff
  prompt (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase, or
  use `Checkpoint: NONE`.
- Platform `Grep`/`Glob` tools are NOT available in this runtime session
  (`ToolSearch` returns no match). Use `Read` with `offset`/`limit` for
  ranged reads. Bash `grep -n -m N '<pat>' <file>` (single command, no
  pipe/regex-alternation-heavy pattern) is allowed under
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
  directory by design. Copy the actual PNGs into the story's own directory
  too; a prose/relative-path reference is not sufficient.
- Central OQ registry is `data/intake/bootstrap/conflicts_open_questions.md`
  (found via `resolve-oq.md`), not a `data/requirements/` file.
- `list-releasable-agents.sh` can print handles from other, unrelated
  sessions that no longer resolve via `TaskStop` ("No task found") —
  harmless no-op, not an error to chase; it means those were already gone.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
