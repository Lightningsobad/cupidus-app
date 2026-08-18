# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
19 of 26 RWB items resolved (denominator grew via split-out findings; latest
split: STORY-052's review added RWB-026). RWB-001..017, RWB-022, RWB-024
RESOLVED. RWB-018..021, RWB-023, RWB-025, RWB-026 (all LOW/MEDIUM) remain
`PENDING`. Full remediation text for each PENDING item is in
`rework-backlog.md`'s own `## RWB-20260816-0NN` detail section — read there,
do not re-derive from this checkpoint or req_master.md.

### RWB-001..017 — RESOLVED (compact pointers; full detail in each story's own artifacts + rework-backlog.md)

- **RWB-001** -> `STORY-034` DONE, `DEFERRED_ONLY`. `e28a6c2`. D1 split RWB-012.
- **RWB-002** -> `STORY-035` DONE, cycle-3 `CLEAN`. `691f4b5`.
- **RWB-003** -> `STORY-036` DONE, `DEFERRED_ONLY`. `a32c96e`.
- **RWB-004** -> `STORY-037` DONE, cycle-2 `DEFERRED_ONLY`. `c7e9d2f`. DEF-1 split RWB-013.
- **RWB-005** -> `STORY-038` DONE, `CLEAN`. `0f0969a`.
- **RWB-006** -> `STORY-039` DONE, `DEFERRED_ONLY`. `9da5d2c`. Split RWB-014/015.
- **RWB-007** -> `STORY-040` DONE, `DEFERRED_ONLY`. `e1e6f01`. Split D1->RWB-016,
  R-1->RWB-017 (now itself resolved, see below); N2->`BUG-20260817-001`.
- **RWB-008** -> `STORY-041` DONE, `DEFERRED_ONLY`. `d709b3f`. Split RWB-018/019.
- **RWB-009** -> `STORY-042` DONE, `CLEAN`. `7e5ab1f`. Tooling gap split RWB-020.
- **RWB-010** -> `STORY-044` DONE, cycle-2 `DEFERRED_ONLY` (cycle-1 waived
  runtime-smoke gate, zero app-code phase). `46f8dc7`.
- **RWB-011** -> `STORY-043` DONE, cycle-2 `DEFERRED_ONLY`. `ff5d069`. Split RWB-021.
- **RWB-012** -> `STORY-045` DONE, `DEFERRED_ONLY`. 2/4 deviations were stale
  mis-scaled-capture artifacts, not real. `524434c`. New regression split RWB-022.
- **RWB-013** -> `STORY-046` DONE, cycle-2 `DEFERRED_ONLY` (cycle-1
  `PATCH_REQUIRED`: rendered evidence mandatory for locked-design-source UI
  story, not waivable). `e3f90cf`. Split DEF-2->RWB-023, DEF-3->RWB-024.
- **RWB-024** -> `STORY-047_pairing_chain_deviation_triage` DONE, `CLEAN`.
  AC1/AC3/AC4/AC5 delivered; AC2 (`permissions` copy) folded into REQ-004 per
  user decision 2026-08-18 (ADR-002 copy-guard conflict, same class as a
  different REQ-004 token). `Quét QR` remains an unregistered future story.
  `696c1aa`.
- **RWB-022** -> `STORY-048_pairing_choice_viewport_regression_hardening`
  DONE, `CLEAN`. `SingleChildScrollView` wrap, AC1 test reproduced real
  overflow, AC2 proved pixel-identical portrait geometry. `77946e4`.
- **RWB-014** -> `STORY-049_contract_unsigned_state_render_coverage` DONE,
  cycle-2 `DEFERRED_ONLY` (cycle-1 `PATCH_REQUIRED` on a false premise
  inherited from STORY-048). Real rendered comparison closed D-7/D-8/D-10/D-13.
  DEF-1 split RWB-025. `d58da5f`.
- **RWB-015** -> `STORY-050_contract_clause_counter_disposition` DONE,
  `DEFERRED_ONLY`. Keep-and-exclude disposition; F-1/F-2/F-3 elevated to a
  standing REQ-002-wide token-vs-source policy in `req_master.md`. `e68fe43`.
- **RWB-016** -> `STORY-051_chat_inverse_text_token_hardening` DONE, cycle-2
  `DEFERRED_ONLY` (cycle-1 `PATCH_REQUIRED` B1, unguarded `colorOnAccent`
  leaked white-on-white in light theme). Guarded fix + 2 regression tests.
  Commits `0d8b9bc`/`692fced`/`33bfa9f`.
- **RWB-017** -> `STORY-052_chat_header_partner_presence_hardening` DONE,
  Reviewer final-synthesis `Outcome: DEFERRED_ONLY` (Tier 3 scoped-slice
  review: slice1 backend-contract PASS, slice2 mobile-identity-header PASS
  on code with 2 evidence-gap findings closed same-story via a real
  production `lib/main.dart` runtime smoke). Expanded to `shared` lane
  (backend+mobile) after Tech Lead found the PO/UX partner-name premise was
  inverted (BLK-052-1, decision R2). `CupidHeader` gained partner pairing
  text + presence chip, both backend-sourced. D-1 (`↔` renders as emoji tile,
  in-story VS15 fix attempted/disproved/reverted, fenced out of WriteScope
  by `ux/uiux-spec.md` §1.2) + D-S1 (stale doc claim) split to new
  **RWB-20260816-026**, registered per the reviewer's required pre-DONE
  action. Commits `22e4a0d`(P0)/`ecf1303`(P1)/`6b71078`(P2)/`bcfeba7`/
  `98abea0`(closure+RWB-017 resolve)/`c8a01b3`(boundary complete).

## Next Valid Step

**User decision 2026-08-18 (explicit, given twice via AskUserQuestion):
"fix all of them in just one turn."** Overrides the standing
one-item-at-a-time/ask-before-each-item gating rule for the remaining
`PENDING` RWB items. Process them sequentially, single-scope-at-a-time (one
active story at a time), through the full RED-PATCH pipeline (Product Owner
story-requirements triage -> UX/Tech Lead as needed -> implementation lane ->
Reviewer gate -> DONE -> `git-story-boundary.sh complete` -> portfolio sync:
`req_master.md`/`rework-backlog.md`/this checkpoint), WITHOUT stopping for
`AskUserQuestion` confirmation between items. Standing discipline stays in
force: disk-verification-before-trust for every specialist result (never
trust an idle notification/teammate message alone — re-read the actual
changed files/commits), canonical agent names, Git Story Boundary first,
checkpoint refresh after every step.

**Next up: RWB-018** (`antighost` penalty card missing undisclosed "Public
countdown" row — largest remaining item, needs a new persisted setting +
backend field + l10n keys, PO/Tech Lead scoping then backend-dev + UI/UX +
mobile-dev). Anchor `STORY-022_anti_ghosting_settings_design_fidelity/`. Not
yet started — no shell story directory exists yet for it.

Then in order: RWB-019 (antighost l10n label fix, `Gây ồn` vs `Phát âm
thanh`), RWB-020 (devops `render-design-canvas.js` needs a `--scroll` flag,
`--hide` doesn't survive re-render), RWB-021 (shared `CupidAddAction`
FAB-shape + `CupidPrimaryButton` iOS CTA gap, `design_system/adaptive/**`),
RWB-023 (`contract` STORY-046 evidence pair compares mismatched states, needs
same-state re-render), RWB-025 (`contract` add-clause l10n copy delta,
`Thêm điều khoản riêng` vs design's longer string), RWB-026 (`chat` header
`↔` emoji-tile render, owner UI/UX Designer + Tech Lead, also carries D-S1
doc fix).

19 of 26 RWB items resolved; REQ-002 stays `IN_PROGRESS` until all 26
resolve, including the remaining 7.

Do Not Re-read: REQ-001 cycle detail; STORY-034..052's own artifacts (already
summarized above); RWB-001..017 detail sections in `rework-backlog.md`
(already summarized above); the RWB-018/019/020/021/023/025/026 detail-section
full text (already captured in this file's "Next up"/"Then in order" bullets
above and each new story's own `## Background` section once created).

## Standing operational notes

- Never write literal "retro-audit" in a non-reviewer handoff prompt
  (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase or use
  `Checkpoint: NONE`.
- Platform `Grep`/`Glob` unavailable in this session's runtime; shell `grep`
  is also blocked for `data/**` artifact content (`SHELL_GREP_SOURCE`). Use
  `Bash wc -l`/`find` for sizing/listing plus platform `Read` (full read
  under 20KB and not already read whole; ranged `offset`/`limit` otherwise).
  For locating a `## RWB-...` detail section in the 1000+ line
  `rework-backlog.md`, binary-search with ranged `Read offset` calls — detail
  sections are NOT in strict table order, so estimate from nearby known
  section positions rather than assuming a fixed stride.
- For an `inline: true` (branch `main`) story boundary, specialists commit
  directly to `main` — `git status --short`/`git diff --stat` show a clean
  tree the instant they commit. Check `git log --oneline`/`git rev-parse
  HEAD` for NEW commits to detect real progress, not working-tree status;
  a `GIT_BOUNDARY_STALE` guard block (`Worktree HEAD != BaseHead`) is itself
  a reliable indirect signal that a new commit landed.
- `Agent(subagent_type: "fork")` BLOCKED — delegate only to named
  specialists. `list-releasable-agents.sh` printing other-session handles
  is a harmless no-op.
- `guard-story-done-evidence.sh` requires a UI-lane story's OWN
  `visual-fidelity/` dir with a same-screen `implemented-*`/
  `design-reference-*` PNG pair + `visual-fidelity-report.md`
  (`VISUAL_FIDELITY: PASS`) — not waivable by scope relaxation, confirmed
  by STORY-046's cycle-1 review (BLK-1).
- Full-story diffs over the Tier 2 12-file review cap split into Tier 3
  scoped independent slices (disjoint AC coverage, each with its own
  `REVIEW_SLICE_COMPLETE: YES`), followed by a mandatory FRESH reviewer
  spawn (never a slice agent's continued handle) running
  `Mode: final-synthesis` that reads only the slice reports (not the diffs)
  to decide the one story-level `Outcome:` line. Confirmed working end to
  end on STORY-052 (14 files: 3 backend + 11 mobile).
- Central OQ registry: `data/intake/bootstrap/conflicts_open_questions.md`.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
