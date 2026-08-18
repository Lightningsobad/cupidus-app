# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
18 of 25 RWB items resolved (denominator grew via split-out findings:
original 15 + RWB-016..021 -> 21, RWB-012's review split RWB-022 -> 22,
RWB-013's review split RWB-023/RWB-024 -> 24, RWB-014's review split
RWB-025 -> 25): RWB-001..016, RWB-022, RWB-024 RESOLVED. RWB-017..021,
RWB-023, RWB-025 (all LOW) remain `PENDING`.

### RWB-001..013 — RESOLVED (compact history; full detail in each story's own artifacts)

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
- **RWB-013** (6 sibling screens occlude shared `--sky` backdrop, from
  RWB-004's DEF-1) -> `STORY-046` DONE, Reviewer 2 cycles (cycle 1
  `PATCH_REQUIRED`: BLK-1 rendered design-fidelity evidence is mandatory for
  a UI-lane locked-`design_source` story and is not waivable by scope
  relaxation even when `trivial`; BLK-2 probe-only evidence didn't verify
  content/layout-unchanged. Cycle 2 `DEFERRED_ONLY`, both blockers resolved
  via 12 rendered PNGs + a decisive pre-change A/B per screen against each
  screen's own prior hardening story). Deferred: DEF-2 (`contract` pair
  compares mismatched states) split to RWB-023; DEF-3 (`VISUAL_FIDELITY:
  PASS` is backdrop-scoped only, `joincode`'s structural deviation is
  largest) split to RWB-024. DEF-1 needed no split (self-contained doc fix).
  Closure commit `e3f90cf`.
- **RWB-024** (STORY-046 `VISUAL_FIDELITY: PASS` backdrop-scoped only,
  `joincode` structural deviation, from STORY-046's DEF-3) -> opened as
  `STORY-047_pairing_chain_deviation_triage`, DONE, Reviewer `CLEAN` (0
  blocking, 0 deferred). Product Owner triage set 5 ACs; `joincode`'s
  6-vs-8-char question resolved as a design-source content error, not a
  backend/contract mismatch. Mobile-dev delivered AC1 (`profile` CTA copy),
  AC3 (6-slot segmented entry), AC4 (paste), AC5 (creator cross-link) with
  rendered visual-fidelity evidence (8 PNGs, `VISUAL_FIDELITY: PASS`). AC2
  (`permissions` "Synced Alarm" copy) hit STORY-021's approved ADR-002 copy
  guard (`reminder_copy_guard_test.dart`) — same guard/ADR conflict class
  already tracked in `REQ-004_notifications_dnd_banner_copy_reconciliation`
  for a different token; user decision 2026-08-18 folded AC2 into REQ-004
  rather than litigate separately, so STORY-047 closed on AC1/AC3/AC4/AC5
  only. `Quét QR` (§3d) remains an unregistered future story needing Tech
  Lead solutioning. Closure commit `696c1aa`.
- **RWB-022** (`pairing_choice` short-viewport overflow, from RWB-012's DF1)
  -> `STORY-048_pairing_choice_viewport_regression_hardening` DONE, Reviewer
  `CLEAN`. `SingleChildScrollView` wrap under retained `Align(topCenter)`
  (`joincode_screen.dart:138` precedent); AC1 test reproduced 72dp overflow
  (> ~38dp estimate), passes post-fix. AC2 portrait geometry proven
  pixel-identical pre/post by implementer + reviewer independently, so
  STORY-045's evidence untouched. DONE gate still required STORY-048's own
  `visual-fidelity/` pair (UI-lane, locked design source) despite AC2's
  no-redo instruction — satisfied via narrow capture-and-record Mobile
  Developer follow-up. Found `capture-mobile-screen.sh`/
  `render-design-canvas.js` (cited by prior REQ-002 stories) don't exist in
  repo history; worked around via `mobile/lib/main_preview.dart`, documented
  as a reproducible 6-step sequence — tooling gap flagged, not story scope.
  Closure commit `77946e4`.
- **RWB-014** (`contract` D-7/D-8/D-10/D-13 no in-scope render path) ->
  `STORY-049_contract_unsigned_state_render_coverage` DONE, `Iris-QC` 2
  cycles (cycle 1 `PATCH_REQUIRED` on a false "render tooling does not
  exist" premise inherited from STORY-048, corrected in this story and
  below; cycle 2 `DEFERRED_ONLY`, all 3 ACs PASS). AC-1 (D-7/D-8) closed by
  a real rendered `requesterUnsigned` vs. design `myUnsigned` comparison,
  superseding STORY-039's structure-only re-confirmation. AC-2 (D-10/D-13)
  closed by disposition: D-10 now rests on the renderer's own recorded
  output (`mySigned` branch confirmed structurally unreachable in the
  design source — no `hint-placeholder-val` — via 3 forcing `--click`
  attempts all byte-identical to the `myUnsigned` baseline); D-13
  unaffected. DEF-1 (add-clause label copy delta) split to RWB-025.
  Closure commit `d58da5f`.
- **RWB-015** (`contract` clause-counter row unclassified app-vs-design
  delta) -> `STORY-050_contract_clause_counter_disposition` DONE, Reviewer
  `DEFERRED_ONLY`. PO triage: keep-and-exclude both — CC-1 (own id,
  re-affirms STORY-015's A-1) for the counter row, and F-1/F-2/F-3 elevated
  from a STORY-039-local exclusion to a standing REQ-002-wide token-vs-source
  policy (pointer propagated into `req_master.md`). DONE gate required its
  own `contract`-screen evidence despite the documentation-only disposition
  (STORY-047/049 precedent); Mobile Dev reused STORY-049's capture
  byte-for-byte after confirming the screen unchanged since. Two
  justification-text corrections applied, not carried forward: Reviewer's
  V-1 ("gapped F-series" — F-4 is defined, resolved by STORY-049) and a
  Scrum-Master-caught misquote ("Scope A screen" -> correct "Scope B story").
  Closure commit `e68fe43`.
- **RWB-016** (`chat` missing `colorOnAccent`/inverse-text token, real in
  light theme, imperceptible in dark) -> `STORY-051_chat_inverse_text_token_hardening`
  DONE, `Iris-QC` 2 cycles (cycle 1 `PATCH_REQUIRED` B1 — unguarded
  `colorOnAccent` leaked onto the partner bubble, white-on-white in light
  theme; cycle 2 `DEFERRED_ONLY`, AC2 flipped to PASS, AC1/AC3/AC4 held).
  PO: implement now, not blocked on OQ5 (token infra, not enablement). Fix:
  `message_bubble.dart:99` guarded `isMine ? colorOnAccent : colorText`;
  2 non-tautological light-theme regression tests added and revert-checked;
  `visual-fidelity-report.md`'s invalid "control region" inference withdrawn
  and corrected. D2 (no `Design-Screen:` line) carried, non-blocking.
  Commits `0d8b9bc`/`692fced`/`33bfa9f`.

### RWB-017..021, RWB-023, RWB-025 — PENDING (split-out deferred findings, mobile lane except RWB-018/019/020/023, LOW)

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
- **RWB-023**: `contract` STORY-046 evidence pair compares mismatched
  states (implemented `partnerAlreadySigned` vs reference's unsigned
  state); AC3 content-column `MATCH` rests on structural correspondence
  only. Needs a same-state re-render/re-capture. Anchor: STORY-015, split
  from Iris-QC-11's STORY-046 cycle-2 review (DEF-2).
- **RWB-025**: `contract` add-clause label copy delta — implementation
  renders `Thêm điều khoản riêng`, design paints `Thêm điều khoản của riêng
  tụi mình`; same class as RWB-019. Anchor: STORY-015,
  `mobile/lib/l10n/arb/`, split from Iris-QC-15's STORY-049 cycle-2 review
  (DEF-1).

## Next Valid Step

**User decision 2026-08-18 (explicit, given twice via AskUserQuestion):
"fix all of them in just one turn."** This overrides the standing
one-item-at-a-time/ask-before-each-item gating rule for the remaining
`PENDING` RWB items (RWB-017/018/019/020/021/023/025). Process them
sequentially, single-scope-at-a-time (one active story at a time), through
the full RED-PATCH pipeline (Product Owner story-requirements triage -> UX/
Tech Lead as needed -> implementation lane -> Reviewer gate -> DONE -> git
story boundary complete -> req_master.md/rework-backlog.md/this checkpoint
sync), WITHOUT stopping for `AskUserQuestion` confirmation between items.
All other standing discipline stays in force: disk-verification-before-trust
for every specialist result, canonical agent names, Git Story Boundary
first, checkpointing after every step.

RWB-016 (STORY-051) closed this batch: DONE, Reviewer `DEFERRED_ONLY`,
commits `0d8b9bc`/`692fced`/`33bfa9f`. See compact history above.

**RWB-017 / STORY-052 in progress** (`chat` header missing partner pairing +
presence chip, Anchor STORY-018). Shell opened, Git Story Boundary started
(`Worktree` = repo root, `Branch`/`MergeTarget` = `main`, `BaseHead` =
`25b92d884c555124e87ff7f1cd7d1cf3eb641c6b`), shell-opening commit `25b92d8`.
Pipeline so far (all disk-verified, not trusted from notifications):
- Product Owner (`Andy-PO-18`): `- [x] Requirements` — triage found 17
  `CupidHeader` call sites, in/out-of-scope, 5 ACs. Uncommitted.
- UI/UX Designer (`Pink-Designer-3`): `- [x] UX Design` — new
  `ux/uiux-spec.md` (193 lines), full populated/unset visual spec, new
  gradient token needed (`#00C9A7→#7B2FBE`, not in any existing token file),
  a11y spec. Uncommitted.
- Tech Lead (`Alan-Techlead-4`, `compact-story-plan`): wrote
  `architecture/solution.md` (167 lines) but is **BLOCKED** on `BLK-052-1`,
  NOT complete — `coding-plan/` bundle withheld. Finding: both PO's and UX's
  data-source premise was inverted — `ChatPartnerStore.displayName` is
  mislabeled and actually returns the caller's own name (from
  `GET /users/me`), not the partner's; no backend field returns another
  paired user's name anywhere in the app. Decision Owner: Product Owner,
  choose R1 (narrow to self-name only, RWB-017 stays open)/R2 (Tech Lead
  recommended: add `partnerDisplayName` to existing `GET /users/me`, expand
  story to `shared` backend+mobile lane)/R3 (block, split into prerequisite +
  dependent story). Uncommitted.
- **PO disposition (2026-08-18, disk-verified)**: chose **R2**. Full
  `story_master.md` re-read confirms: `### BLK-052-1 Disposition` section
  added under Product Owner Triage (R1/R3 explicitly rejected, reasoning
  recorded); `Implementation Lane` now ui-ux-designer -> tech-lead ->
  backend-dev (`partnerDisplayName` field expansion on `GET /users/me`) ->
  mobile-dev (client regen + `ChatPartnerStore` split); `## In Scope`/`## Out
  of Scope` updated; `## Acceptance Criteria` now 7 ACs (AC1 backend
  contract, AC2-AC4 real partner identity in title+chip, AC5/AC6
  backward-compat, AC7 unchanged navigation). PO explicitly did NOT add an AC
  for `GhostBubble`/`ChatComposer` visual re-audit (out of scope per Tech
  Lead), only flagged their `partnerDisplayName:` args should be repointed at
  the new correct getter as a byproduct of the store split — noted for
  Scrum Master as a possible future separate LOW item, not requested now.
- **Architecture complete (2026-08-18, disk-verified, not trusted from
  Tech Lead's idle notification alone)**: full `coding-plan/` bundle exists
  and passes the completion gate — `master-plan.md` (§5 Phases Overview,
  critical path P0->P1->P2, no parallelism), `coding-agent-guide.md`,
  `phase-P0-users-me-partner-display-name.md` (Backend Developer, 3 files,
  unit+build test scope), `phase-P1-partner-identity-plumbing.md` (Mobile
  Developer, 5 files, unit+analyze), `phase-P2-header-slot-and-presence-chip.md`
  (Mobile Developer, 6 files, unit+integration+analyze+`no_fork_guard_test.dart`
  +required `visual-fidelity/` pair). Plus a new
  `architecture/contract-summary.md` (cross-lane `GET /users/me`
  `partnerDisplayName` contract, exact key spelling, null-handling rules,
  rollout order). No trailing verification-only phase; no e2e/Playwright/
  emulator test-scope gates. Scrum Master checked `story_master.md`'s
  `- [x] Architecture (Tech Lead)` after this verification (Tech Lead itself
  had not ticked its own box — idle notification only, not a completion
  report — but the artifacts independently satisfy the gate).

Immediate next action: dispatch `Abert-BE` (fresh spawn, no existing handle
for this story) for phase P0 (`GET /users/me` `partnerDisplayName` field
expansion) with the Git Story Boundary block and exact P0 phase file path.
Then P1/P2 to `Alex-Mobile-Dev-17` (continuing existing handle), each
depending on the prior phase per master-plan.md. Then Reviewer
(`Iris-QC-17`, continuing existing handle), then
`git-story-boundary.sh complete`, then portfolio sync
(`req_master.md`/`rework-backlog.md`/this checkpoint) mirroring STORY-051's
closure commit pattern, matching RWB-017 RESOLVED in both the summary table
and detail section of `rework-backlog.md`. Commit the current uncommitted
PO/UX/Tech-Lead artifacts (`story_master.md`, `ux/`, `architecture/`,
`coding-plan/`) plus this checkpoint refresh in one
`docs(REQ-002/STORY-052): record architecture + coding plan` commit before
dispatching backend-dev.

Remaining after RWB-017: RWB-018 (antighost Public countdown row, new
setting+backend+l10n, largest remaining item), RWB-019 (antighost l10n label
fix), RWB-020 (devops `render-design-canvas.js` --scroll flag, no screen
story), RWB-021 (shared `CupidAddAction`/`CupidPrimaryButton` fix, exact
remediation already known), RWB-023 (contract same-state re-render/
re-capture), RWB-025 (contract add-clause l10n copy decision). Full
remediation text for each is in `rework-backlog.md`'s own
`## RWB-20260816-0NN` detail sections — do not re-derive from req_master.md
or story history. Process all 6, sequentially, without further
`AskUserQuestion` gating (still-standing "fix all in one turn" override),
once RWB-017/STORY-052 closes.

18 of 25 RWB items resolved (RWB-001..016, RWB-022, RWB-024); REQ-002 stays
`IN_PROGRESS` until all 25 resolve, including the remaining 7 in this batch.

Do Not Re-read: REQ-001 cycle detail; STORY-034..051's/STORY-018's/022's/025's/
028's own artifacts (carried forward into each hardening story's own
`## Background` or this checkpoint's compact history above); RWB-012/RWB-013/
RWB-014/RWB-015/RWB-016/RWB-022 detail sections in `rework-backlog.md`
(already summarized above); STORY-052's `ux/uiux-spec.md` (full, 193 lines)
and `architecture/solution.md` (full, 167 lines) — already loaded and
summarized above, do not re-Read whole; the RWB-018/019/020/021/023/025
detail-section full text (already captured in this file's "Remaining after
RWB-017" bullet and each new story's own `## Background` section once
created).

## Standing operational notes

- Never write literal "retro-audit" in a non-reviewer handoff prompt
  (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase or use
  `Checkpoint: NONE`.
- Platform `Grep`/`Glob` unavailable in this session's runtime; shell `grep`
  is also blocked for `data/**` artifact content (`SHELL_GREP_SOURCE`). Use
  `Bash wc -l`/`find` for sizing/listing plus platform `Read` (full read
  under 20KB and not already read whole; ranged `offset`/`limit` otherwise).
- `Agent(subagent_type: "fork")` BLOCKED — delegate only to named
  specialists. `list-releasable-agents.sh` printing other-session handles
  is a harmless no-op.
- `guard-story-done-evidence.sh` requires a UI-lane story's OWN
  `visual-fidelity/` dir with a same-screen `implemented-*`/
  `design-reference-*` PNG pair + `visual-fidelity-report.md`
  (`VISUAL_FIDELITY: PASS`) — not waivable by scope relaxation, confirmed
  by STORY-046's cycle-1 review (BLK-1).
- Central OQ registry: `data/intake/bootstrap/conflicts_open_questions.md`.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every
  write; do not re-accumulate round-by-round history.
