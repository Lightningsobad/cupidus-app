# Scrum Master Checkpoint — Retro Audit / Rework Tracking

## REQ-001 hardening cycle — CLOSED

STORY-017/018/019/020/021 all DONE, Reviewer CLEAN each. Final commit
`c562fe83b4deeda90631dc14fcdab21e0c5b3299` on `main`. `req_master.md` Status
`DONE`, `master_requirements_list.md` REQ-001 row `DONE`. No further action.

## REQ-002 retro-hardening cycle — IN PROGRESS

`req_master.md` Status `IN_PROGRESS` (reopened 2026-08-16 from DONE per
`retro-audit/audit-report.md` RED-PATCH verdict). Stays `IN_PROGRESS` until
all `RWB-20260816-*` items resolve, then returns to `DONE` (REQ-001 pattern).
26 of 28 RWB items resolved (denominator grew via split-out findings).
RWB-001..026 RESOLVED. RWB-027 and RWB-028 remain `PENDING`, deliberately
excluded from the 2026-08-18 "fix all in one turn" sweep (needs fresh UI/UX
Designer + Tech Lead scoping first) — do not start either without a fresh
user decision/session. Full remediation text for each PENDING item is in
`rework-backlog.md`'s own `## RWB-20260816-0NN` detail section — read there,
do not re-derive from this checkpoint or req_master.md.

### RWB-001..026 — RESOLVED (compact pointers; full detail in each story's own artifacts + rework-backlog.md)

- **001**->STORY-034 `e28a6c2`. **002**->STORY-035 `691f4b5`.
  **003**->STORY-036 `a32c96e`. **004**->STORY-037 `c7e9d2f`.
  **005**->STORY-038 `0f0969a`. **006**->STORY-039 `9da5d2c` (split 014/015).
  **007**->STORY-040 `e1e6f01` (N2->`BUG-20260817-001`).
  **008**->STORY-041 `d709b3f` (split 018/019). **009**->STORY-042
  `7e5ab1f` (tooling gap->020). **010**->STORY-044 `46f8dc7`.
  **011**->STORY-043 `ff5d069` (split->021). **012**->STORY-045 `524434c`
  (new regression->022). **013**->STORY-046 `e3f90cf` (DEF-2->023,
  DEF-3->024). **024**->STORY-047 `696c1aa` (AC2 folded into REQ-004,
  user decision 2026-08-18). **022**->STORY-048 `77946e4`. **014**->
  STORY-049 `d58da5f` (DEF-1->025). **015**->STORY-050 `e68fe43`
  (F-1/F-2/F-3 elevated to standing REQ-002-wide token-vs-source policy).
  **016**->STORY-051 `0d8b9bc`/`692fced`/`33bfa9f`. All DONE, `CLEAN` or
  `DEFERRED_ONLY`, story-scoped Reviewer approved each.
- **017**->STORY-052 DONE, final-synthesis `DEFERRED_ONLY` (Tier 3 slice
  pattern — see "Standing operational notes"). D-1 (`↔` emoji-tile)+D-S1->
  new **026** (now resolved, see below). Commits `22e4a0d`/`ecf1303`/
  `6b71078`/`bcfeba7`/`98abea0`/`c8a01b3`.
- **018/019**->STORY-053 DONE, Reviewer `Iris-QC-21` `CLEAN` (9 ACs, AC6 =
  RWB-019 fold-in). New persisted `publicCountdown` field+l10n. Boundary
  needed manual repair (plain `git commit` bypassed script's `commit`
  action): `repair-boundary --commit-sha <sha> --branch main --worktree
  <repo-root> --merge-target main` -> `merge` -> `complete` — reuse directly
  whenever `complete` doesn't recognize a Scrum-Master-authored commit.
  Commits `59b130c6`, `ef35d81` (portfolio sync).
- **020**->STORY-054 DONE/`CLEAN` `cd3f468` (impl `18cbc7c`, waived-smoke
  `207f971`). Screen-less devops story; guard-fix pattern in "Standing
  operational notes" below. Portfolio sync `7de8394`.
- **021**->STORY-055 DONE, Reviewer final completion/resume pass
  `Outcome: DEFERRED_ONLY` `218e6c5` (D-1/D-2/M-1 all closed; new F-2/D-4
  finding — `CupidAddAction` clamped 60x56 by `CupidHeader`'s Material
  `AppBar` — split to new **RWB-20260816-027**, owner UI/UX Designer + Tech
  Lead, out of this story's write scope). Portfolio sync `fe95457`.
- **023**->STORY-056 DONE, Reviewer `Iris-QC-24` `Outcome: DEFERRED_ONLY`
  `feff42f` (impl `4820e4f`). Fresh same-state `contract` evidence pair
  supersedes STORY-046's AC3 content-column verdict. DEF-1 (undisclosed
  decorative particle dots)->new **RWB-20260816-028**. Portfolio sync
  `61bdbd0`.
- **025**->STORY-057 DONE, Reviewer `Iris-QC-25` `Outcome: CLEAN`
  `46d76fa` (impl `8ec507e`). Corrected `app_vi.arb`
  `loveContractAddClauseAction` to match design verbatim, matching
  test-literal update, fresh same-state `contract` evidence pair (design
  hash-identical to STORY-039/049/056). 0 blocking, 0 deferred findings.
  Portfolio sync `d645457`.
- **026**->STORY-058 DONE, Reviewer `Iris-QC-26` `Outcome: DEFERRED_ONLY`
  (impl `62feaf7`, doc-fix `46a780a`, rework `a4239d0`, DONE-state `47aeee5`).
  Glyph swap U+2194->U+27F7 in `chat_strings.dart` (Path A; Path B
  structurally unavailable, bundled Roboto also lacks U+2194 coverage, per
  Step-0 `cmap` check). `cupid_header.dart` title contract + 16 other call
  sites untouched. D-S1 folded in as AC6 (STORY-052 §7 stale
  `NOT_APPLICABLE` corrected). First-pass `PATCH_REQUIRED` on 3
  evidence/gate-record findings only (no source change) — B-1 real
  production `lib/main.dart` cold boot smoke, B-2 `VISUAL_FIDELITY: PASS`
  token, B-3 `## Entry Point Reachability` section, all supplied in `a4239d0`
  and independently re-verified. Re-review `DEFERRED_ONLY` — 0 blocking, all
  7 ACs PASS, D-1 (iOS render of `⟷` unverified, Android-only audited
  config) + D-2 (filename cosmetic nit) deferred, neither gates closure.
  Portfolio sync (this checkpoint + `req_master.md` + `rework-backlog.md`) ->
  `git-story-boundary.sh complete`.

## Next Valid Step

**"Fix all in one turn" sweep (user decision 2026-08-18) CLOSED**:
RWB-023/STORY-056, RWB-025/STORY-057, RWB-026/STORY-058 all DONE,
Reviewer-approved, portfolio-synced. User then said plain **"continue
retro"** (2026-08-19) — per `retro-review/case-resume-execute.md` this is
the exact resume phrase, and its per-item confirmation gate fires only
*between* completed items, not before starting the next `PENDING` item, so
no `AskUserQuestion` gate applies before starting RWB-027.

**Active item: RWB-027 -> STORY-059** (`cupid_header_action_slot_sizing_hardening`,
standard/shared, RED-PATCH, Fixes: STORY-028). Scrum Master created the
story shell (`story_master.md` `Status: RETRO_PENDING`) and the Git Story
Boundary (`start --inline`, `BaseHead d243864`, `Branch/MergeTarget main`).
`rework-backlog.md` RWB-20260816-027 table row + detail section set to
`Status: IN_PROGRESS`, `req_master.md` STORY-059 row added
(`Status: RETRO_PENDING`).

`Andy-PO-25` delivered `requirements/requirements.md` (Requirements artifact
box checked) but Scrum Master's independent disk-verification found a
factual error: AC2 + the "confirmed call sites" bullet claimed
`expense_history_screen.dart:159` as a second `CupidHeader.actions`-clamped
site. Direct read of that file (lines 147-160) shows `CupidHeader(title:...,
onBack:...)` with NO `actions:` param — `CupidAddAction` there is wired to
`Scaffold.floatingActionButton` instead, matching the ORIGINAL RWB-027 text's
own prior "renders correctly... unconstrained overlay" description of that
screen. Only `dream_jar_list_screen.dart:68-82` is a genuine
`CupidHeader.actions` call site. Sent a `SendMessage` continuation (builder
`handoff-build.sh continue`, Git-Boundary fields included) to `Andy-PO-25`
2026-08-19 asking it to: drop AC2, move
`expense_history_screen.dart:159` into the confirmed-unaffected bucket
alongside `gallery_empty_view.dart:78`, and update AC4 + Scope
in/out-of-scope lists to match. Awaiting `Andy-PO-25`'s corrected
`requirements.md` and a fresh `PRODUCT_OWNER_COMPLETE: YES` before accepting
Requirements as done.

`Andy-PO-25` round 1 fix (2026-08-19): Scope section corrected right (single
confirmed call site = Dream Jar list; `expense_history_screen.dart:159`
moved to confirmed-unaffected). Round 2 fix (2026-08-19, independently
re-verified by direct Read — CONFIRMED CORRECT): AC2 dropped, renumbered
AC2=regression-pin-flip, AC3=no-new-unaffected-case-regression (now lists
BOTH `gallery_empty_view.dart:78` and `expense_history_screen.dart:159`),
AC4=no-unrelated-CupidHeader-regression. `requirements/requirements.md` now
internally consistent end to end. `story_master.md` artifact checklist
`[x] Requirements (Product Owner)` already checked. PO stage CLOSED.

**UX Designer dispatched** 2026-08-19: `Pink-Designer-6` (fresh spawn,
`Mode: story-ux`), asked to decide `CupidAddAction` sizing/treatment inside
`CupidHeader.actions` at the single confirmed call site (Dream Jar list).

`Pink-Designer-6` round 1 (resize-based decision, access-gap claim proven
false by Scrum Master `find`) superseded by round 2, which DID open
`cupid-app-design-system/project/Cupid Screens.dc.html` and found a bigger
finding: the design's shared header template (`showHeader`, lines 49-64) has
**no icon-action slot at all**; the Jar List screen's literal "create jar"
CTA (design source line 923) is a body pill button, already correctly
implemented independently in `dream_jar_list_screen.dart` (`_EmptyJarsView`
lines 197-200, `_JarListBody` lines 228-234, both `CupidPrimaryButton` ->
`_openCreateSheet`). Scrum Master independently re-verified every citation
(design source lines 49-64/889-930, both screen-file line ranges) by direct
Read — CONFIRMED CORRECT. Revised decision: PRIMARY fix = remove
`CupidAddAction` from `CupidHeader.actions` at
`dream_jar_list_screen.dart:70-81` (both switch arms), not resize.
SECONDARY (still in scope, unaffected by this revision) = harden
`cupid_header.dart`'s Material toolbar band to 60pt conditionally, for AC2's
pinned test which composes `CupidHeader(actions:[CupidAddAction])` directly.
Full spec: `ux/uiux-spec.md`. `UX_COMPLETE: YES`, `story_master.md` `UX
Design` checked.

**Scope-routing decision (Scrum Master, 2026-08-19):** accepted
`dream_jar_list_screen.dart:70-81` into this story's write scope — it is the
exact call site the original Gap already named in-scope, only the remedy
changed. Added `story_master.md` `## Revised Gap / Remediation (UX finding,
2026-08-19)` section superseding the original "resize" framing (original Gap
section left intact for audit trail); updated `Implementation Lane` to name
both files. Routed back to `Andy-PO-25` (continuation, NOT a fresh spawn)
`Mode: story-requirements` to rewrite AC1 (was: "FAB renders at correct
size inside header"; now: "CupidAddAction no longer renders inside
CupidHeader.actions; existing body CTAs remain sole entry point") and update
Scope's in-scope bullets to name both the screen-file removal (primary) and
`cupid_header.dart` hardening (secondary). AC2/AC3/AC4 unaffected, PO told
not to touch them. Awaiting fresh `PRODUCT_OWNER_COMPLETE: YES`.

`Andy-PO-25`'s round-3 AC1 rewrite CONFIRMED on disk by Scrum Master direct
Read of `requirements/requirements.md` (119 lines, full file): AC1 now reads
"CupidAddAction no longer renders inside CupidHeader.actions ... header
renders only the back chevron and title, matching the design source's
literal showHeader template"; Scope section now names both the primary
screen-file removal (`dream_jar_list_screen.dart:70-81`) and secondary
`cupid_header.dart` hardening as in-scope; AC2/AC3/AC4 untouched and still
internally consistent with `ux/uiux-spec.md`. `story_master.md` `Requirements
(Product Owner)` and `UX Design (UI/UX Designer)` both `[x]`. PO stage fully
CLOSED for STORY-059.

`Alan-Techlead-7` `TECH_LEAD_COMPLETE` outputs CONFIRMED on disk by Scrum
Master direct Read (architecture/solution.md 219 lines, master-plan.md,
phase-P1-cupid-header-oversized-action-contract.md, all cross-verified
against the real `cupid_header.dart` and `dream_jar_list_screen.dart`
source):
- Path correction caught: real path is
  `mobile/lib/design_system/adaptive/cupid_header.dart` (handoff had guessed
  `features/design_system/widgets/`) — verified real by Scrum Master find.
- Key new finding, independently verified true: `dream_jar_list_screen.dart:72-77`
  wraps `CupidAddAction` in `Semantics(button: true, ...)`, which defeats a
  marker/type-inspection (`is CupidAddAction`) detection approach — confirmed
  by direct Read.
- Decision: explicit opt-in `hasOversizedAction` constructor param (default
  `false`) on `CupidHeader`, not type inspection. `preferredSize` and
  `_MaterialHeader`'s `AppBar.toolbarHeight` both track it; iOS unaffected
  (no param threaded to `_IosHeader`). Band value exactly 60 (not 56, not
  >60 — `AppBar` uses `CrossAxisAlignment.stretch`).
- Single phase P1 (mobile-dev), 4 write-scope files: `cupid_header.dart`,
  `dream_jar_list_screen.dart`, `adaptive_widgets_test.dart` (AC2 pin flip +
  new AC4 default-band test), new
  `dream_jar_list_screen_test.dart` (new AC1 regression test, both
  empty/ready states). Verification:
  `cd mobile && flutter analyze && flutter test test/design_system/adaptive_widgets_test.dart test/features/dream_jar/ test/features/account/presentation/screens/profile_edit_screen_test.dart`.
  Forbidden touches: `cupid_add_action.dart`, `gallery_empty_view.dart`,
  `expense_history_screen.dart`, `profile_edit_screen.dart`. No e2e/emulator
  gate in phase test scope.
`story_master.md` `Architecture (Tech Lead)` now `[x]`.

Dispatched `Alex-Mobile-Dev` (fresh spawn) `Mode: mobile-implementation` for
phase P1, 2026-08-19. Visual-fidelity exception applies (UI-bearing,
`cupid-app-design-system/project/Cupid Screens.dc.html` configured as design
source) — no pre-rendered design-reference PNG exists for this story (UX
cited literal HTML blocks, not a screenshot), so mobile-dev renders/captures
itself per `.claude/skills/mobile-dev/references/visual-fidelity.md`, using
device id `emulator-5560` (established convention from STORY-058's
`visual-fidelity/implemented-chat-*-emulator-5560.png`) and design-source
anchors `showHeader` lines 49-64 + `isJarList` line 923 in place of a PNG.

`Alex-Mobile-Dev-24` P1 first pass CONFIRMED on disk by Scrum Master direct
Read (`test-results.md`, `visual-fidelity-report.md`, full files): static
analysis clean on the 4 touched files; `flutter test` 115 passed / 0 failed;
AC1-AC4 all evidenced by widget test (AC1 via two new
`dream_jar_list_screen_test.dart` cases asserting `CupidAddAction` absent +
body CTA present in both empty/ready states; AC2 via the flipped
`Size(60,60)` pin; AC3 via untouched `cupid_add_action.dart` tests; AC4 via
new default-band test + `profile_edit_screen_test.dart` passing unmodified).
BUT visual fidelity returned `FAIL` / `BLOCKER:
MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` (not a device-availability
blocker — `emulator-5560` worked) — honest report, no fabricated PASS:
`_buildJarlist` in `main_preview.dart` needs a live authenticated
`DreamJarRepository.fetchJars`, no `PREVIEW_JARLIST_FIXTURE` exists, so both
AC1 states resolve to `DreamJarListFailed` in the preview build and can't be
captured. Only the header-chrome-matches-design fact was proven by capture;
AC1 itself rests on widget-test evidence only pending this. Mobile-dev
correctly did NOT unilaterally touch `main_preview.dart` (outside P1 write
scope) and named the precedented unblock itself: STORY-020
`architecture/solution.md` §7 "Authorized Write-Scope Extension — Preview
Harness", mirroring the existing `PREVIEW_EXPENSE_FIXTURE`/
`PREVIEW_TIMELINE_FIXTURE` pattern already in that file.

**Scrum Master routing decision, 2026-08-19:** authorized a narrow write-scope
extension to `mobile/lib/main_preview.dart` ONLY (add
`PREVIEW_JARLIST_FIXTURE=empty|ready` + a `fetchJars`-only repository
override, same pattern as the existing fixtures) rather than the credential
alternative (not something Scrum Master can supply). Sent via
`handoff-build.sh continue` + `SendMessage` to the SAME `Alex-Mobile-Dev-24`
(not a fresh spawn) — full header/Git-Boundary included. Awaiting fresh
`MOBILE_COMPLETE: YES` with both new-state captures and an accurate (not
forced) visual-fidelity verdict.

Mobile-dev's visual-fidelity unblock CONFIRMED on disk (2026-08-19, this
session): `test-results.md` PASS (115/115, static analysis clean),
`visual-fidelity-report.md` `VISUAL_FIDELITY: PASS` with both AC1 states
captured on `emulator-5560`. Scrum Master committed the implementation via
`git-story-boundary.sh commit` -> `fe124f3` (23 files: 5 source/test +
story artifacts + portfolio docs), then `refresh-base` -> BaseHead now
`fe124f3` (== HEAD). Dispatched `Iris-QC-27` (fresh spawn, `Mode:
compact-story-review`, `Flow: story`) with explicit instruction to diff via
`git show d243864..fe124f3` since BaseHead==HEAD makes `git diff <BaseHead>`
empty. Awaiting `REVIEW_COMPLETE: YES` + `Outcome:` line.

`Iris-QC-27` returned (2026-08-19): `Outcome: PATCH_REQUIRED`, one blocker
(`review/review-report.md`, `## Blocking findings`):
- **BLK-1**: all this story's visual-fidelity captures used
  `-t lib/main_preview.dart` (the preview harness with
  `PREVIEW_JARLIST_FIXTURE`); the SHIPPED `lib/main.dart` entrypoint has never
  actually been launched for this story. Needs a registry-backed runtime
  startup smoke on `lib/main.dart`. Reviewer's own note: "Owner: devops (or
  mobile-dev...)". Cross-checked against
  `data/devops/system/runtime-command-registry.json` `runtimes.mobile-app`:
  this is devops-owned (`buildCommand: flutter build apk --debug`,
  `readiness.command` adb `am start -W` + `dumpsys activity activities`
  poll, `readiness.shutdownCommand`). `emulator-5560` already running, reuse
  it.
Plus 3 deferred, non-blocking: DEF-1 (add `## Entry Point Reachability` to
`test-results.md` — substance already verified by Reviewer, transcription
only), DEF-2/DEF-3 (pre-existing out-of-scope `jarlist` deviations, recommend
a future RWB item — not this story's problem).

**BLOCKED — needs a user decision, do not keep retrying the same handoff
shape.** Two routing attempts both failed:
1. `Target: mobile-dev` (`Mode: completion/resume`) for BLK-1 — blocked by
   `guard-broad-handoff.sh` (`BROAD HANDOFF GUARD BLOCKED [GENERIC]`):
   mobile-dev may not own emulator/simulator/e2e-style runtime work in
   ordinary `continue` flow. Correctly re-routed to devops per the registry
   + Reviewer's own note above.
2. `Target: devops` (`Mode: story-runtime-smoke`, `Flow: story`,
   `Checkpoint: data/retro-audit/scrum-master-checkpoint.md`) — blocked
   4x identically by `guard-broad-handoff.sh` GENERIC on the literal
   `retro-audit` substring in `Checkpoint:`. Resolved 2026-08-20: user chose
   "retry avoiding literal string" — attempt #5 uses `Checkpoint: NONE` and a
   prompt body with zero occurrences of the literal substring, since devops's
   actual required inputs for this mode (story_master.md, coding-plan/*,
   runtime-command-registry.json) live entirely under
   `data/requirements/REQ-002.../STORY-059.../` and never needed the
   retro-labeled checkpoint path in the first place.

**2026-08-20 progress**: Dispatched `Frank-Devops` `Mode: shared-infra-adopt`
first (precondition — `mobile-app` depends on `backend-api`, which depends on
`postgres`/`redis`, neither provisioned per this session's SessionStart
check). Returned `DEVOPS_COMPLETE: YES`: tenant provisioned (postgres db
`cupid_apps`, redis db 1), ports reserved (api=21020, wired into scripts;
docs/mobile-metro/ws reserved but not wired — not applicable to this stack,
see registry `sharedInfra.reservedPortsNote`), `devstack use --check`/`port
check`/`doctor` all clean, `start-dev.sh`/`start-prod.sh` live smoke both
passed (1317/1317 Flutter tests, readiness 200 on 21020). Noted but NOT yet
actioned: `mobile-app`'s compiled `CUPID_API_BASE_URL` default still targets
the old port; devops flagged this as mobile-dev scope, not fixed here. Does
not block BLK-1's readiness check (device launch + `ResumedActivity`, no
network call required to reach the first screen).

**2026-08-20 progress (cont'd)**: Dispatched `Frank-Devops` `Mode:
story-runtime-smoke` (attempt #5, same `Checkpoint: NONE` workaround).
Returned `DEVOPS_COMPLETE: YES`. Verified directly (Read) that
`coding-plan/test-results.md` genuinely contains both new sections with all
required fields: `## Story Runtime Startup Smoke` (Runtime Id `mobile-app`,
registry-backed adb `am start -W` + `dumpsys` readiness poll on the shipped
`lib/main.dart` entrypoint via `flutter build apk --debug`, `Result: PASS`,
`Shutdown: PASS`) and `## Entry Point Reachability` (documents the surviving
`CupidPrimaryButton` create-jar CTA per reviewer's DEF-1, doc-only, no
re-capture). BLK-1 and DEF-1 are genuinely closed, not just self-reported.

Dispatched fresh `Iris-QC` (`Mode: compact-story-review`, `Flow: story`,
`Checkpoint: NONE` same workaround, `Scope:
REQ-002_screen_flow_and_design_fidelity_audit/STORY-059_cupid_header_action_slot_sizing_hardening`)
for a narrow re-verification pass: confirm BLK-1/DEF-1 evidence in
`test-results.md` is sufficient, do NOT re-check AC1-4 or re-open DEF-2/DEF-3,
append a `## Re-Verification` section to the existing
`review/review-report.md` and flip the literal `Outcome:` line (expect
`DEFERRED_ONLY` if sufficient). Waiting on `REVIEW_COMPLETE: YES`.
`agent_id: Iris-QC@session-4df004a7`.

Next once Reviewer returns: if `Outcome: DEFERRED_ONLY`/`CLEAN`, file DEF-2/
DEF-3 as a new RWB item (reviewer's own recommendation, not rework in this
story), check `story_master.md` Review box, mark STORY-059 DONE, run
`git-story-boundary.sh complete --req REQ-002_screen_flow_and_design_fidelity_audit
--story STORY-059_cupid_header_action_slot_sizing_hardening` (this performs
its OWN commit of the dirty tree — do not `git commit` manually first), update
`rework-backlog.md` RWB-027 row+detail to RESOLVED, update `req_master.md`
STORY-059 row to DONE, compact this checkpoint's RWB-001..026 pointer list to
add 027, then ask user before RWB-028 (still PENDING, needs fresh UI/UX
Designer scoping) or close the requirement per the open disposition question
below. If Reviewer instead keeps `PATCH_REQUIRED`, stop and report the exact
remaining gap.

**RWB-028 remains `PENDING`**, still excluded — it needs a separate fresh
UI/UX Designer scoping decision at the REQ-002 requirement-level
`integration-review/mobile-visual-audit.md` (cross-screen ambient-particle
question), distinct from RWB-027's single-story scope. Pick it up next only
after RWB-027/STORY-059 closes, per the Execute Loop's PENDING-priority
order (no explicit priority tiebreak needed — it is the only remaining item).

**Open disposition question carried forward**: whether `req_master.md`'s
top-level `Status: IN_PROGRESS` can return to `DONE` only after both
RWB-027 and RWB-028 close, or some other disposition — unresolved, revisit
once RWB-027/STORY-059 lands. Left `IN_PROGRESS` for now.

**Guard pattern confirmed for inline-story Reviewer dispatch** (reuse for
future PENDING items): ordinary-flow `guard-git-story-boundary.sh` requires
declared `BaseHead == live Worktree HEAD` for every handoff including
Reviewer (no ancestor-BaseHead exception — that's `guard-parallel-spawn.sh`
only). Resolution: run `refresh-base` AFTER the implementation commit lands,
then in the Reviewer handoff name the implementation commit sha + its parent
and instruct `git show <impl_sha>` / `git show <parent_sha>..<impl_sha>`
instead of `git diff <BaseHead>` (empty when BaseHead==HEAD). Confirmed
working end to end on STORY-054/Iris-QC-22 and STORY-058/Iris-QC-26.

**`git-story-boundary.sh complete` semantics confirmed** (STORY-034/058):
it performs its OWN commit of whatever is currently uncommitted in the
working tree — it does not just verify a pre-existing commit diff against
`base_head`. Do NOT manually `git commit` the final portfolio-sync edits
(story review-report/story_master.md already-committed + req_master.md +
rework-backlog.md + this checkpoint) before calling `complete`; leave them
uncommitted and let `complete` bundle them into one "complete story
boundary" commit, matching precedent commit `0808f71`. Manually committing
first then calling `complete` on a clean tree fails with "GIT STORY
BOUNDARY BLOCKED: no story changes to commit" regardless of BaseHead state.

**Guard fix confirmed for any future screen-less devops-lane story**: if
`guard-story-done-evidence.sh [DONE_WITHOUT_VISUAL_EVIDENCE]` blocks a story
with `Screen: NONE`, add/confirm `UI-Fidelity-AC: WAIVED` +
`Visual-Fidelity-Evidence: NOT_APPLICABLE` alongside it in `story_master.md`
— `.claude/hooks/lib/visual_fidelity.py`'s `_story_declares_no_ui_surface()`
(local-only, gitignored, not a repo commit) now exempts `review`/`done` on
that triple-AND. Do not re-patch; do not re-ask the user — this was a
one-time authorized fix, already applied and durable on this machine.

Do Not Re-read: REQ-001 cycle detail; STORY-034..058's own artifacts (already
summarized above); RWB-001..026 detail sections in `rework-backlog.md`
(already summarized above); STORY-054/055/056/057/058 review-report.md files
(already independently verified `CLEAN`/`DEFERRED_ONLY`, captured above).

## Standing operational notes

- Never write literal "retro-audit" in a non-reviewer handoff prompt
  (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase or use
  `Checkpoint: NONE`.
- Platform `Grep`/`Glob` unavailable in this session's runtime; shell `grep`
  is also blocked for `data/**` artifact content (`SHELL_GREP_SOURCE`). Use
  platform `Read` (full read under 20KB and not already read whole; ranged
  `offset`/`limit` otherwise) — never `Bash wc -l`/`ls`/`cat`/`grep` on
  `data/**`, blocked by `guard-query-first-bash-read.sh`. For locating a
  `## RWB-...` detail section in the 1000+ line `rework-backlog.md`,
  binary-search with ranged `Read offset` calls — detail sections are NOT in
  strict table order.
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
