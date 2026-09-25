# Scrum Master Checkpoint

Scope:
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Story: STORY-012_phase_status_and_widget
- Bug: NONE
- Workflow: parallel-story (continue parallel)

Current State:
- Requirement Status: IN_PROGRESS
- Story Status: IN_PROGRESS — P9 DONE (MOBILE_COMPLETE: YES, sealed). P10
  BLOCKED (not in flight): Alex-Mobile-Dev opened the P10 run, made ZERO
  edits, and returned `p10_blocker` in the run file
  (`RUN-...-mobile-dev.json`) code `PHASE_SPEC_CONTRADICTS_CODE` — see "P10
  blocker (new, 2026-09-25)" below. D-13 Design Ruling Log row committed in
  control-checkout `req_master.md` (`ecade7ad`). Andy-PO `Mode: ac-patch`
  RETURNED `PRODUCT_OWNER_COMPLETE: YES` — patched `requirements.md` (AC-9,
  AC-16..19 area, AC-37/BR-15 phrasing) + `ux/uiux-spec.md` §2/§4 wording from
  "chấm màu riêng của pha" to shape-neutral "chỉ báo pha", documenting the
  `date_day` glyph exception; deferred the technical token-shape definition to
  `contract-summary.md` §3a as instructed. Verified (3-part protocol) and
  committed `e04157b4`; BaseHead resealed to
  `e04157b42400ee7119235a4a3395c9ffbbc0cde5`; Andy-PO released (`TaskStop`).
  Alan-Techlead `Mode: architecture-solution` RETURNED `TECH_LEAD_COMPLETE:
  YES`. Verified (3-part protocol): run file `COMPLETED`; `git diff
  e04157b4.. --stat` touched only `architecture/contract-summary.md` (matches
  declared WriteScope); read the diff directly — §3a renamed to "Chỉ báo pha",
  added the Hình dạng (D-13) column (3 tokens keep chấm màu đặc, `--dot-today`
  becomes glyph tia chớp, name unchanged so D-12 mapping is untouched, glyph is
  a shipped native asset not content-pack/payload), and a new §7 records the
  P10 decision: **option (a)** — add `bool journalAvailable = true` to
  `EveningCheckInSheet`/`.show`, gate the "write a sentence" block on that flag
  (not `openJournal`), leaving `_openFromPayload` and existing P6/P8 test seams
  untouched; (b)/(c) rejected with rationale. Sealed and committed (see
  Boundary status). Andy-PO's separate `PRODUCT_OWNER_COMPLETE: NO` message
  (arrived after the run file already showed `YES`) was reconciled: the actual
  `requirements.md`/`uiux-spec.md` patch content was independently verified
  correct and stands as committed; the "NO" was Andy-PO flagging two
  Scrum-Master-owned `story_master.md` Stop-hook gate gaps outside its own
  WriteScope (`Target: scrum-master, Mode: ac-patch`), not a defect in its own
  patch. Both gaps fixed directly by Scrum Master this round (see "story_master.md
  gate fix" below) and committed together with the Tech Lead seal. Also
  corrected an off-by-one in the control-checkout `req_master.md` D-13 row
  ("4 token màu còn lại" -> "3") to match `contract-summary.md` §3a's actual
  3-dot + 1-glyph split; committed on `main` separately (control-checkout
  commit, not part of this worktree's history). Fresh Alan-Techlead-2
  `Mode: coding-plan` RETURNED `TECH_LEAD_COMPLETE: YES`. Verified (3-part
  protocol): run file `COMPLETED`, `base_head`/`worktree_head` both
  `7ceaec66be0728c51ccf259dfd59b4fb354912b6` (no self-commit, as instructed);
  `git status --porcelain` + `git diff 7ceaec66.. --stat` confined to exactly
  `coding-plan/master-plan.md` (modified), `coding-plan/phase-P10-checkin-degrade-parity.md`
  (modified, 116 lines), `coding-plan/phase-P11-widget-date-day-bolt-glyph.md`
  (new), `coding-plan/phase-P12-widget-native-capture.md` (new) — matches
  declared WriteScope; read all four files directly and confirmed: P10 now
  gates the "write a sentence" block on `widget.journalAvailable` (default
  `true`), not `openJournal`, leaves `_openFromPayload`/`_save()` untouched,
  adds one AC-18 test case asserting `findsNothing` via `find.text` on the two
  chip labels (no `_Chip` export); P11 adds `dot_today_bolt.xml` (Android
  vector, one closed path) rasterized in `CupidPhaseWidgetProvider.kt` via
  `ContextCompat.getDrawable(...).mutate()` + `setTint` + `GLYPH_PX = 48`,
  reusing the shipped `DOT_TODAY` Kotlin constant for color (NOT a new
  `@color/dot_today` resource — see FYI below), and adds `CupidPhaseBolt: Shape`
  in Swift branched on `entry.isDateDay`, forbids SF Symbols/new `.swift`
  files, keeps the 4 existing `DOT_*`/`dot[A-Z]` name-set assertions and 3
  `native_copy_scan_test.dart:476-491` assertions unmodified; P12 is a
  Write-Scope-`visual-fidelity/`+`test-results.md`-only evidence phase
  (Depends-On P11) that builds `--split-per-abi`, seeds the 6 §2 payload keys
  via `run-as`+broadcast, places the widget on a real launcher, captures
  `implemented-widget-date-day.png` via `adb exec-out screencap`, mandates
  human eyeball verification, forbids Dart-redrawn stand-ins, and defines
  blockers `NO_ANDROID_TARGET`/`WIDGET_PLACEMENT_BLOCKED`; `master-plan.md`
  Phases Overview/mapping/§3A updated correctly (P10/P11/P12 all
  `Parallelizable: NO`, sequential P10→P11→P12, single Mobile lane). Sealed and
  committed (see Boundary status); Alan-Techlead-2 released (`TaskStop`).
  **FYI (non-blocking, flagged by Alan-Techlead-2, not yet actioned):**
  `contract-summary.md` §3a's prose still says the Android glyph tint mechanism
  is a color resource `@color/dot_today`; the actually-shipped mechanism (P4/P9)
  and P11's new phase file both use the Kotlin `DOT_TODAY` constant instead — a
  one-line `contract-summary.md` wording patch, outside coding-plan WriteScope,
  not required to unblock P11/P12 implementation. Leave for Reviewer or a future
  architecture touch; do not fix opportunistically mid-implementation.

- **story_master.md gate fix (this round, Scrum-Master-owned, per Andy-PO's
  routed blocker):** (1) added AC-9 covering design-screen visual match for
  all 7 `Design-Screen` ids against surface `cupid-ch-ng-1`
  (`validate-story-ac-coverage.sh` gap); (2) changed `Implementation Lane:
  mobile` to `Implementation Lane: shared (backend + mobile)` with a note that
  only mobile-dev actually executes code, no backend lane runs — reconciles
  `Complexity: complex` with the lane field per `validate-lane-consistency.sh`,
  and matches the exact handoff wording Tech Lead's own `architecture/
  solution.md` §1 Key Discovery already cites ("Handoff ghi Implementation
  Lane: shared (backend + mobile)... Không có lane backend trong story này"),
  verified directly at `architecture/solution.md:30` before editing. Both
  fixes are uncommitted alongside the Tech Lead seal; committed together this
  round.
- Completed Checklist: Requirements [x] (D-13 ac-patch commit `e04157b4`),
  UX [x] (same commit), Architecture [x] (contract-summary.md §2/§3/§3a/§4/§6/§7
  for D-10 + D-13 shape + P10 decision, this round's Tech Lead output pending
  commit below), Implementation [ ] (P9 DONE and sealed; P10 BLOCKED pending
  the coding-plan rewrite per Tech Lead's §7 decision; D-13 glyph and R-5
  native-capture phases not yet added to the coding plan — all three will be
  mobile-dev, cannot run concurrently: MAX_CODE_WRITERS_PER_STORY=1), Review
  [ ] (last committed review: final-synthesis Outcome: PATCH_REQUIRED,
  commit `322c4276`, superseded)
- Current Phase: P10 DONE (`phase-P10-checkin-degrade-parity.md`, AC-18
  `journalAvailable` gate in `evening_check_in_sheet.dart`, `flutter test
  test/features/phase_status` `+246 ~6`, 0 regressions). P11
  (`phase-P11-widget-date-day-bolt-glyph.md`, D-13 dot->bolt glyph) is the
  next dispatch, fresh Alex-Mobile-Dev spawn.
- Phase Statuses: see `coding-plan/master-plan.md` in this worktree — P1-P10
  DONE, P11/P12 PENDING
- Open decisions raised by Alex-Mobile-Dev's P9 report (recorded in
  `visual-fidelity/visual-fidelity-report.md` "Tồn dư cập nhật sau P9", not
  yet resolved, owner Scrum Master unless noted):
  - R-5: widget `implemented-*.png` still `NOT_COMPARED` — phase-P9 §6
    contradicts itself (requires capture, forbids native build); OS-widget
    surface (RemoteViews/WidgetKit) is outside the Flutter render tree so the
    RepaintBoundary harness cannot reach it. Alex substituted a canvas↔code
    attribute table backed by `native_copy_scan_test.dart` (34 cases green)
    instead of fabricating a Flutter-drawn stand-in. Decision needed: accept
    that substitute evidence and mark row 7 `NOT_APPLICABLE` for automated
    capture, or open scope for a real native-build+device capture pass.
  - D-13 (owner UI/UX + Tech Lead, Scrum Master cannot spawn Pink-Designer
    directly per role-map — only brainstormer can): `--dot-today` (`#FF7FB6`,
    contract-summary.md §3a) sits on the D-12 pink→purple gradient background
    for `date_day`, near-zero contrast; design canvas draws a lightning-bolt
    glyph there instead of a plain dot. Also a naming-only note: the widget's
    "PHA n" numbering intentionally does NOT match the canvas's 4 card-status
    labels (2 of which name the partner, forbidden by AC-11/AC-12/BR-11) —
    Alex used the correct `ux/uiux-spec.md` §1 phase names instead; flagged
    only for traceability, not a defect.
  - R-3 (owner Tech Lead/Scrum Master, pre-existing, not new): Android
    widget's large countdown digits (D-11) still need a `SpannableString` fix
    in `CupidPhaseWidgetProvider.kt`; P9 only opened that file for the
    eyebrow/dot, not digit sizing.
  - VISUAL_FIDELITY overall verdict stays FAIL after P9 (R-1 hub-waiting
    chips + R-5 above); not a P9 regression, both pre-existing/newly-scoped
    gaps.

**P10 blocker (new, 2026-09-25, from `RUN-...-mobile-dev.json` `p10_blocker`,
files_changed: NONE — do not treat as P10 progress):** phase-P10 §3 gates the
"write a sentence" block on `widget.openJournal != null` as a proxy for
"STORY-003 not yet delivered". In this codebase that proxy is inverted on the
only production path: `_openFromPayload` (evening_check_in_sheet.dart:562-568)
calls `.show()` WITHOUT `openJournal`, so `openJournal == null` is the
production default even though STORY-003 IS delivered; `_save()`
(line 368) uses `openJournal ?? _openJournal`, proving it is a test seam, not
an availability signal; `journal_entry_point.dart:57`'s `openJournalComposer`
is unconditional with no absent state to detect; `requirements.md:195`'s
AC-18 Given ("STORY-003 chưa được giao") is counterfactual today. Alex's own
options: (a) lift §3's "no new parameter" ban, add an explicit availability
flag defaulting to delivered; (b) have `_openFromPayload` pass `openJournal`
explicitly (widens WriteScope beyond this phase); (c) record AC-18 as
`NOT_APPLICABLE` for this build (no absent state exists to gate on). This is a
Tech Lead call (how to implement/rescope AC-18 given the real caller graph),
not a design-vs-AC ruling — no Design Ruling Log row needed, no
AskUserQuestion needed unless Tech Lead itself gets stuck. Route to the same
upcoming Tech Lead dispatch as D-13 (see "Next resume action" below).

**USER DECISIONS (2026-09-25, both resolved — route as soon as the worktree
is clean, i.e. after P10 seals):**
- R-5: **Mở scope chụp thật.** Add a new mobile-dev phase that runs an actual
  native build, installs to a device/emulator, places the widget, and
  captures a real `implemented-widget-*.png` for row 7 of
  `visual-fidelity-report.md` — this supersedes phase-P9 §6's "no native
  build" restriction for this specific evidence gap only.
- D-13: **Đổi sang glyph tia chớp như canvas.** Replace the `date_day`
  (`--dot-today`) dot with a lightning-bolt glyph matching design canvas
  `sb-84-widget-bon-pha`, instead of a color swap. This is a
  `contract-summary.md` §3a change — Tech Lead must update the contract
  (shape, not just color, so likely a new asset/SF-Symbol/vector-path
  decision) before mobile-dev implements it.
- Next resume action: on Alan-Techlead's `TECH_LEAD_COMPLETE` (architecture-
  solution only), verify (3-part protocol: agent idle/gone, `git diff
  e04157b4.. --stat` matches WriteScope `architecture/` only, read
  `contract-summary.md` directly to confirm both the D-13 shape-contract patch
  AND a stated P10 (a)/(b)/(c) decision + rationale are present), seal via
  `git-story-boundary.sh refresh-base`, commit. THEN build a SECOND handoff
  (same agent, `SendMessage` continuation if still addressable, else fresh
  spawn) `Mode: coding-plan` — separate dispatch, guard
  `TECHLEAD_MODE_MIXED_OUTPUTS` forbids combining architecture-solution and
  coding-plan outputs in one handoff — to: (1) revise
  `phase-P10-checkin-degrade-parity.md` in place per Tech Lead's chosen
  (a)/(b)/(c) option, (2) add a D-13 glyph-swap implementation phase
  (`CupidPhaseWidgetProvider.kt` + `CupidPhaseWidget.swift`, Depends-On NONE),
  (3) add an R-5 native build+device capture phase for the widget row-7
  screenshot (Depends-On the D-13 implementation phase). All three are
  `code-writer` phases — cannot run concurrently with each other under
  `MAX_CODE_WRITERS_PER_STORY: 1`.
- Confirmed constraint (still applies): a fresh spawn attempt into this
  worktree while it is dirty from an in-flight/uncommitted phase is BLOCKED by
  `git-story-boundary.sh start` ("worktree is dirty") REGARDLESS of
  concurrency class (`planning` included) — always seal/commit the current
  phase before spawning the next, even a planning-only one. Applied again this
  round: committed the PO ac-patch + checkpoint drift as `e04157b4` and
  resealed BaseHead before dispatching Alan-Techlead.
- ALSO NOTE (this round): `list-releasable-agents.sh` printed all three prior
  agents (Alan-Techlead, Alex-Mobile-Dev, Andy-PO) as releasable once their
  runs went terminal — all were `TaskStop`-ed. This means Alex-Mobile-Dev's
  P10 re-dispatch (after Tech Lead resolves the blocker) will need a FRESH
  spawn, not a `SendMessage` continuation of the earlier instance.

Story Git Boundary:
- Git-Boundary: REQUIRED
- Story-Class: standard
- Depends-On: NONE
- Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget
- Branch: codex/REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget
- MergeTarget: codex/REQ-016_solo_stage1_relationship_assistant-integration
- BaseHead: 721a6e570a810d30f2301685141084c8d1431eee
- BoundaryState: /Users/alantravala/workspace/snapsofts/cupid-apps/.git/ai-team-story-boundaries/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget.json
  (this is the authoritative live value; inline BaseHead text above may lag by
  one checkpoint-only commit — trust BoundaryState at spawn time)
- Boundary status: COMMITTED. (Older history through Tech Lead coding-plan
  round 2 collapsed — see git log if needed; last recorded commit before this
  round was `9db07af1`/checkpoint `98b595f8`.) P10 implementation
  (Alex-Mobile-Dev, `journalAvailable` gate) returned `MOBILE_COMPLETE: YES`,
  verified (3-part protocol: run file COMPLETED, diff confined to declared
  WriteScope + 2 OutputPaths, source diff read directly and matches spec),
  committed `721a6e57`, resealed -> BaseHead
  `721a6e570a810d30f2301685141084c8d1431eee`. Next dispatch: fresh
  Alex-Mobile-Dev for P11 (D-13 glyph, Depends-On P10 — now satisfied).

Last Delegation:
- Role: tech-lead (Alan-Techlead-2, fresh spawn — prior Alan-Techlead instance
  already released after architecture-solution)
- Mode: coding-plan (ONLY)
- RunId: RUN-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget-tech-lead
- Scope of this run: revise `phase-P10-checkin-degrade-parity.md` per §7
  option (a); add new `phase-P11-widget-date-day-bolt-glyph.md` (D-13 glyph
  implementation); add new `phase-P12-widget-native-capture.md` (R-5 native
  build+capture); update `master-plan.md`. WriteScope: `coding-plan/` only.
- Result: COMPLETED (`Alan-Techlead-2@session-e7df910a`), `TECH_LEAD_COMPLETE:
  YES` — verified per 3-part protocol above (agent terminal, diff confined to
  WriteScope, all 4 output files read directly and content confirmed).
  Released (`TaskStop`) this round.
- Next dispatch to build: fresh Alex-Mobile-Dev (prior P9/P10-blocker instance
  already released), sequential P10 → P11 → P12 — see "Next Resume Action"
  below.
- Prior specialists (Andy-PO ac-patch, original Alan-Techlead
  architecture-solution, Alex-Mobile-Dev P9/P10-blocker runs, Alan-Techlead-2
  coding-plan): all COMPLETED/terminal, verified, sealed, and released via
  `TaskStop` — every future dispatch for any of these roles needs a FRESH
  spawn, not a continuation.

Validation Result:
- Gate: N/A (design-ruling-required guard satisfied this round: D-13 row
  added to req_master.md + Andy-PO ac-patch dispatched; not yet re-verified
  after Andy-PO returns)
- Outcome: N/A
- Missing Exact Paths: N/A

Waiting Reason:
- None right now — P10 implementation verified and committed; next action is
  Scrum-Master-owned: release Alex-Mobile-Dev, dispatch fresh Alex-Mobile-Dev
  for P11.
- P11/P12 are PENDING, not in flight yet — dispatch strictly sequentially
  (P11 next, then P12) since all are `code-writer` phases in the single
  Mobile lane (`MAX_CODE_WRITERS_PER_STORY: 1`).
- R-3 (Android countdown digit `SpannableString` sizing) still open,
  pre-existing, not part of P10/P11/P12 scope — tracked for the review gate,
  not blocking this dispatch.

Next Resume Action:
1. DONE: Tech Lead coding-plan round 2 (P10 rewrite + P11/P12 new phases)
   verified, committed `9db07af1`/checkpoint `98b595f8`. P10 implementation
   (`journalAvailable` gate) verified (3-part protocol) and committed
   `721a6e57`, resealed -> BaseHead `721a6e570a810d30f2301685141084c8d1431eee`.
2. Run `list-releasable-agents.sh`, `TaskStop` the now-terminal
   Alex-Mobile-Dev P10 instance, then dispatch a FRESH Alex-Mobile-Dev for
   P11 (`phase-P11-widget-date-day-bolt-glyph.md`: D-13 glyph, Android vector
   drawable + Kotlin rasterize + iOS `CupidPhaseBolt` Shape). Verify (3-part
   protocol), commit, reseal.
3. Dispatch Alex-Mobile-Dev (fresh spawn) for P12
   (`phase-P12-widget-native-capture.md`: R-5 native build + device capture,
   Depends-On P11). Verify, commit, reseal.
4. Once all three phases are DONE and sealed, tick `story_master.md`
   Implementation checkbox, then route to Iris-QC (Story-Class `standard` —
   story owes rendered visual-fidelity evidence, review must assess R-1/R-5
   directly).
5. Once merged, reconcile the control-checkout `story_master.md` Architecture
   and Implementation checkboxes (currently stale `[ ]` there — real state
   lives in this worktree).

Files Updated:
- data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md (control checkout, D-13 Design Ruling Log row, commit `ecade7ad`; token-count typo "4"->"3" corrected this round, pending commit on `main`)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/architecture/contract-summary.md (Tech Lead architecture-solution: §3a D-13 glyph shape + new §7 P10 decision, this round, pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/story_master.md (this round: added AC-9 design-match, changed Implementation Lane to `shared`, pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/scrum-master-checkpoint.md (this file, in the story worktree; committed in worktree as `820d1912` (pre-PO drift) and `e04157b4` (PO ac-patch + checkpoint); this round's edits pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/requirements/requirements.md, ux/uiux-spec.md (Andy-PO ac-patch for D-13, commit `e04157b4`)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/master-plan.md (P9/P10 rows added; P9 -> DONE; this round: P11/P12 rows added, P10 Parallelizable -> NO, pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/phase-P9-widget-phase-label-and-dot.md (DONE, sealed)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/phase-P10-checkin-degrade-parity.md (this round: rewritten to gate on `journalAvailable` per §7 option (a), pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/phase-P11-widget-date-day-bolt-glyph.md (NEW this round, D-13 glyph implementation, pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/phase-P12-widget-native-capture.md (NEW this round, R-5 native capture, pending commit)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/test-results.md (P9 evidence appended, sealed)
- data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/visual-fidelity/visual-fidelity-report.md (P9 patch round #3 appended, sealed)
- mobile/lib/features/phase_status/domain/phase_content.dart, mobile/lib/features/phase_status/data/home_widget_bridge.dart, mobile/assets/data/req016/phase_content.v1.json, mobile/android/.../cupid_phase_widget.xml, mobile/android/.../CupidPhaseWidgetProvider.kt, mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift, and their tests (P9 implementation, sealed)

Test Evidence:
- P9, sealed: `flutter test test/features/phase_status` -> `+245 ~6` (P8 was
  `+235 ~6`, +10 cases, 0 regressions); `native_copy_scan_test.dart` `+34`;
  `phase_content_gate_test.dart` `+18`; `home_widget_bridge_test.dart` `+22`;
  `flutter analyze lib/features/phase_status test/features/phase_status` ->
  5 info-only issues, 0 error/warning, none in P9-touched files. Full text in
  `coding-plan/test-results.md` §P9.
- P10, sealed: `flutter test test/features/phase_status/evening_check_in_sheet_test.dart`
  -> `+20 ~1` (1 skip = photo capture case); full suite
  `test/features/phase_status` -> `+246 ~6` (P9 was `+245 ~6`, +1 case, 0
  regressions); `flutter analyze lib/features/phase_status
  test/features/phase_status` -> 5 info-only issues (pre-existing, none in
  P10-touched files), 0 error/warning. Full text in
  `coding-plan/test-results.md` §P10.
- P11, P12: none yet, not dispatched.

Next Valid Step:
- Role: Alex-Mobile-Dev (fresh spawn, P11 next) -> Alex-Mobile-Dev (fresh
  spawn, P12) -> Iris-QC
- Mode: mobile-implementation (sequential, one phase at a time) ->
  full/scoped review per Story-Class standard (visual-fidelity evidence owed)
- Required Inputs: none outstanding — P10 DONE and sealed. P11/P12 phase
  files are the required inputs for each corresponding mobile-dev dispatch.
- Output Paths:
  - data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/master-plan.md
  - data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/test-results.md
  - data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/visual-fidelity/visual-fidelity-report.md

Do Not Re-read:
- STORY-005/008/009/010/013 completed run files (resolved, merge-scope only)
- prior scoped-slice reviewer runs S1-S6a (superseded by final-synthesis
  PATCH_REQUIRED commit 322c4276)
- requirements.md / uiux-spec.md full bodies (already landed; query only by
  AC-37/BR-15 and §2 anchors)

Large Files Query Keys:
- req_master.md D-10/D-6 Design Ruling Log rows (query: "D-10" / "D-6")
- architecture/contract-summary.md §2 (widget payload contract)
