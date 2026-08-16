---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-14
reviewed_by: Reviewer
---

# Review Report: STORY-019 — Typing Ghost Consent/Settings Design Fidelity

Outcome: DEFERRED_ONLY

Latest round: 3 (see `## Round 3` below). Round 2 is preserved at `## Round 2`,
round 1 at `## Round 1 History`.

---

## Round 3 — 2026-08-14, `compact-story-review`

Outcome: DEFERRED_ONLY
Review round: 3
Story: STORY-019 (REQ-002, Scope B) — lane `mobile`, UI-facing YES
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-019`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
HEAD at review: `cd5e3f244d78967df32281d06e0de698dfaa190b`
Evidence commit: `cd5e3f2` — `fix(REQ-002/STORY-019): produce rendered design-fidelity evidence`
Recommended story status: `DONE`

### Reviewed Inputs

- Review gate: `compact-story-review`
- Scope Gate: `inline`
- Requirements: `.../STORY-019_typing_ghost_settings_design_fidelity/story_master.md`
- UX: `data/ux/system/ui_ux_system_memory.md` §5/§8 (cited, not re-read in full)
- Architecture / Coding Plan: `N/A` — trivial-classified story, `SKIPPED:trivial`
- Test Results: `visual-fidelity/visual-fidelity-report.md` § Verification
- Previous review findings: rounds 1 and 2 in this file (F1, F2, F3 open)
- Run state: `data/runtime/parallel-runs/RUN-...-STORY-019-mobile-dev.json`

### Reviewed Scope

- Story complexity: `trivial` per `story_master.md`; `standard` per run state and
  handoff — unreconciled, see P1
- Code scope reviewed: 3 source/test paths and 6 evidence paths vs BaseHead,
  within the compact 8-file budget
- Diff since the round-2 review (`cda59c4..cd5e3f2`): `story_master.md`,
  `visual-fidelity/` (5 PNGs + report), `mobile/lib/main_preview.dart`.
  `ghost_settings_screen.dart` and its test are **byte-identical to the
  implementation rounds 1 and 2 already examined**, so D1-D10, V1 and V2 stand
  without re-litigation.
- Critical gates reviewed: rendered design-fidelity evidence (12e2/12e3), story
  runtime startup smoke (12g), entry-point reachability (12e1), static analysis,
  targeted and suite tests, write-scope compliance
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `PASS`
- Requirement mobile visual audit: `PASS`
- Story runtime startup smoke: `PASS`

### Round-3 blocking-finding verification

All three round-1/round-2 blocking findings are resolved. Each was verified
against the rendered artifact, not against the report's claim about it.

**F1 — mandatory rendered design-fidelity evidence — RESOLVED.**
Five PNGs now exist under `visual-fidelity/`, and I opened every one of them:

| Artifact | What I saw |
| --- | --- |
| `design-reference-ghostset-android.png` | The Typing Ghost consent/settings screen rendered from the design canvas — hero card with the `blur_on` glyph, `Typing Ghost` toggle card with the 54x32 switch, two consent tiles, legend card, mint ephemeral card |
| `implemented-ghostset-emulator-5560.png` | Real device capture, consent `on`: gradient track, knob right, `Đang bật · cả hai đã đồng ý` |
| `implemented-ghostset-state-pending-emulator-5560.png` | Flat `--line` track, knob left, `Đang chờ cả hai đồng ý`, `Bạn: Đã đồng ý` |
| `implemented-ghostset-state-off-emulator-5560.png` | Flat track, knob left, `Tắt`, `Bạn: Tắt` |
| `implemented-runtime-smoke-first-screen-emulator-5560.png` | Real `lib/main.dart` first screen with Flutter's DEBUG banner |

`VISUAL_FIDELITY: PASS` is present as a top-level line
(`visual-fidelity-report.md:3`). The declaration-level substitute that round 1
refused is gone; the widget test is now positioned as the executable supporting
layer, not as the proof.

**F2 — unverified design referent — RESOLVED.**
`Design-Screen: ghostset` is recorded in `story_master.md:14` and
`visual-fidelity-report.md:7`. The reference was rendered from the configured
entry `cupid-app-design-system/project/Cupid App.dc.html` via
`render-design-canvas.js --screen ghostset`, not from a hand-picked file. I
confirmed the rendered reference depicts this screen and not a neighbour, and
that the CSS coordinates quoted in D3-D10 resolve: `Cupid Screens.dc.html:391`
is `<sc-if value="{{ isGhostSet }}">`, and lines 392-429 carry exactly the
`padding:14px 16px 40px`, `gap:13px`, 145deg hero gradient, 54x32 switch with
26px knob, `flex:1` consent tiles and mint `.34` ephemeral card the report
cites.

**F3 — story runtime startup smoke (rule 12g) — RESOLVED.**
`story_master.md:24-30` and `visual-fidelity-report.md:368-395` record the
scoped `cupid_mobile`-only smoke: `flutter build apk --debug` → `adb install -r`
→ `am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` on
`emulator-5560`. The capture shows the real entry point (DEBUG banner, pairing
gate `Ghép đôi để mở khoá Cupid`), not the preview harness. This gate mattered
here rather than being ceremonial: this story fixed a layout exception that
crashed this very screen (V1).

### Round-3 critical gates

| Gate | Required | Result |
| --- | --- | --- |
| A patch exists to review | yes | PASS — `cd5e3f2`, 8 files |
| Rendered design-fidelity evidence (12e2/12e3) | yes | PASS — F1, F2 resolved |
| Story runtime startup smoke (12g) | yes | PASS — F3 resolved |
| Entry point reachability (12e1) | yes | PASS — `app_shell.dart:91-103` unchanged |
| Static analysis / targeted tests / chat suite | yes | PASS — re-run after the `main_preview.dart` change, per report §Verification |
| Write-scope compliance | yes | PASS — see below |
| Configuration guide | no | not applicable |

**Write-scope compliance, checked rather than assumed.** The run's
`write_scope` is `ghost_settings_screen.dart`, `main_preview.dart`, the story's
test file, `visual-fidelity/`, and `story_master.md`. Every path in
`git diff --name-only bf80848..cd5e3f2` falls inside it. In particular
`main_preview.dart` **is** in scope for this run (it was not in round 1's), so
the harness change is authorised, not a scope breach.

**The preview harness does not alter production behaviour.**
`_ghostConsentFixture` is `String.fromEnvironment('PREVIEW_GHOST_CONSENT')`,
which is empty unless the define is passed; `_buildGhostset` then takes the
unchanged live branch. `main_preview.dart` is a separate entry point from
`lib/main.dart`, and the three fixture classes are private to it. Dropping
`wrapInShell` for `ghostset` edits a preview registry entry only. Nothing here
reaches a shipped build.

### Round-3 adjudication of the deferrals the handoff asked me to test

The handoff asked whether R1 and R6-R10 are legitimately outside **this
story's** AC scope or silently dropped in-scope findings. I checked the owning
source directly rather than accepting the report's characterisation.

**R1 (header back-arrow tint) — genuinely out of this story's scope, but must
not die here.** `mobile/lib/design_system/adaptive/cupid_header.dart:21-27`
shows `CupidHeader`'s constructor takes only `title`, `onBack`, `backLabel` and
`actions` — there is no tint parameter. Line 168 hard-codes
`color: colors.colorText` in `_MaterialHeader`, while `_IosHeader` line 111
already uses `colors.colorAccentPink`. The deviation is real and visible (design
render: pink arrow; device capture: white arrow), and it is an AC1
colour/token dimension. But the file is outside `write_scope`, the design canvas
renders that header for **every** screen, and the only real fix — making the
Material arrow pink — changes every Material screen in the app while six other
REQ-002 stories are mid-flight on the same integration branch. That is a
design-system decision, not a STORY-019 one. Deferred here, and routed to the
requirement level in D-1 below.

**R6-R10 (copy strings) — genuinely out of scope, and mostly outside AC1's
enumerated dimensions.** All five need
`mobile/lib/features/chat/presentation/chat_strings.dart`, absent from
`write_scope` and shared with `chat_screen.dart`. AC1 enumerates layout,
spacing, colour/token usage and typography; wording is not among them, so
R6-R8 are not AC1 deviations at all, only design-source copy drift. R9 (casing)
and R10 (headline break) are closer to typography, but both are string-owned:
the `.toLowerCase()` half-fix would correct `vi` and break `en`
(`live text` ≠ `live`), and the pinned `<br>` at `Cupid Screens.dc.html:396`
would have to become a `\n` in the shared string. Declining both half-fixes was
the right call.

**R2, R3, R4, R5 — correct as implemented, verified independently.**

- R2 (Level-1 chip present in the app, absent from the canvas `ghostset` state)
  is AC4-mandated. I confirmed the chip the app adopted is the design source's
  own: `Cupid Screens.dc.html:334` carries `padding:5px 12px`, `--surf` fill,
  999 radius, a 13px soft `lock` glyph in `--mint`, a 10.5px `--tx2` label, and
  the exact string `Level 1 · chỉ nằm trên máy hai người` that the captures
  show. Adopted verbatim, not invented.
- R3 (`Minh`/`Linh` → `Bạn`/`Đối phương`) is correct. `Cupid App.dc.html:52`
  reads "hai người trong một cặp — iPhone là Minh, Pixel là Linh": those are
  demo persona names for self and partner, and the tile labels are hard-coded
  in the canvas, not bound. Rendering role labels is the right translation.
- R4 (partner tile `Chưa rõ` in `--tx2` rather than mint) is the round-1 DEF-5
  divergence, unchanged and still correctly reasoned — ADR-013e exposes no
  partner-consent flag, so mint would assert a state the app cannot know.
- R5 (no bottom tab bar) is correct and is what AC5 requires.
  `app_shell.dart:91-103` `_openGhostSettings` pushes `GhostSettingsScreen` in a
  `MaterialPageRoute` above `AppShell` with `onBack` wired, so runtime never
  renders shell chrome here. Fixing round 1's harness (`wrapInShell` dropped,
  `onBack` supplied) made the capture match the real route rather than
  flattering it.

### Outcome Summary

- Review outcome: `DEFERRED_ONLY`
- Rationale: all three round-1/round-2 blocking findings are resolved against
  rendered artifacts I opened myself; every remaining delta lives in a file
  outside this story's declared write scope and is itemised with an owner. The
  outcome is `DEFERRED_ONLY` rather than `CLEAN` because R1 and R9/R10 are real
  deviations from a locked design source that no story currently owns.
- Blocking findings: 0
- Deferred findings: 3
- Dismissed observations: 4 (R2, R3, R4, R5 — adjudicated correct above)

### Deferred Findings

| ID | Finding | Owner / routing |
| --- | --- | --- |
| D-1 | Material back-arrow tint is `colorText` where the design canvas renders it pink; `CupidHeader` exposes no per-screen tint hook (`cupid_header.dart:21-27`, `:168`) | Needs a **design-system story** covering `cupid_header.dart`. This affects every Material screen in the REQ-002 audit, so the REQ-002 **requirement integration review should treat it as blocking at requirement level** even though it is not blocking for STORY-019. |
| D-2 | Five `chat_strings.dart` copy deviations vs the locked design source: legend casing (`đã xoá`/`đang gõ`), hero body, mutual-consent footer, ephemeral card copy, and the unpinned headline break | Needs a **new follow-up story owning `chat_strings.dart`**. See P2 — the current routing to STORY-018 is stale. |
| D-3 | Partner consent tile renders `Chưa rõ` in `--tx2` instead of the design's mint `consentBColor` | Accept as-is. Backend exposes no partner-consent flag (ADR-013e). Revisit only if that contract changes. |

### Process Observations (non-blocking, Scrum Master owned)

- **P1** — `story_master.md:4-5` still reads `Complexity: trivial` /
  `Story-Class: trivial`, while the run state and this handoff both declare
  `standard`. Round-1 action item 5 remains open. It does not change the
  verdict (12g and 12e2/12e3 were applied under either reading) but it should be
  reconciled before the story is closed.
- **P2** — Stale routing, in two places: the mobile-dev run state `notes` and
  `visual-fidelity-report.md:357` both route the `chat_strings.dart`
  carry-forwards to STORY-018. **STORY-018 is already DONE and merged**, so
  that routing drops the work. Round 2 flagged this; it is still uncorrected.
  D-2 needs a new story.
- **P3** — `visual-fidelity-report.md:350-352` still claims the hero headline
  "breaks at the same point" at 412pt. The rendered captures contradict it: the
  design breaks after `cả`, the app after `phần`. The authoritative
  rendered-comparison table (R10, line 167) states it correctly, so this is a
  stale sentence in the older carry-forward section rather than a false PASS.
- **P4** — `mobile/lib/main_preview.dart` is in the ACTIVE write scope of
  `RUN-...-STORY-017-mobile-dev` and `RUN-...-STORY-021-mobile-dev`. This commit
  touches only the `ghostset` registry entry and appends private classes at the
  end of the file, so conflicts should be localised, but the integration merge
  should expect them.
- **P5** — The run state carries
  `completion_error: "Missing completion marker in SubagentStop transcript"`
  alongside `mobile_complete: true` and `visual_fidelity: PASS`. The durable
  state is complete; only the transcript marker was missed.
- **P6** — The handoff's declared `Checkpoint`
  (`.../STORY-019_typing_ghost_settings_design_fidelity/scrum-master-checkpoint.md`)
  still does not exist; `git ls-files` shows the story directory holds no
  checkpoint. The run state points at the requirement-level checkpoint instead,
  which does exist. Same observation as round 2, still open.

### Round-3 Traceability

| AC | Reviewer status | Basis |
| --- | --- | --- |
| AC1 — dark + `vi` layout, spacing, tokens, typography match | MET for everything inside `WriteScope` | Rendered canvas-vs-device comparison; D3-D10 visible as fixed in the capture; residual deltas are D-1 and D-2 |
| AC2 — deviations corrected in the app, not merely documented | MET | The captures show D1 and D3-D10 as rendered fixes, not claims |
| AC3 — all three toggle states match | MET | Three device captures opened and checked against the `switchBg`/`switchJustify` bindings at `Cupid Screens.dc.html:403-404`; on-state compared to the canvas render |
| AC4 — Level-1 lock affordance visible | MET | Chip visible in all three state captures; geometry and copy match `Cupid Screens.dc.html:334` |
| AC5 — no new entry point | MET | `app_shell.dart:91-103` unchanged; `GhostSettingsScreen`'s constructor and `onBack` contract unchanged; no route wiring added |

- OQ discipline: OQ5 (light theme / `en`) correctly non-blocking; all fixes are
  expressed in shared `ThemeExtension` tokens, so no in-scope AC was withheld
  and no blocked scope was implemented.
- Git boundary: reviewed with `git -C <Worktree> diff bf80848` only; no Git
  state was mutated.

### Round-3 Workflow Recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status `DONE`
- The story branch is merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`; expect a
  localised `main_preview.dart` conflict against STORY-017 / STORY-021 (P4)
- Before REQ-002 itself is marked `DONE`, D-1 and D-2 must be owned by real
  stories, and P1 reconciled

---

## Round 2 — 2026-08-13, `compact-story-review`

Outcome: PATCH_REQUIRED
Review round: 2
Story: STORY-019 (REQ-002, Scope B) — lane `mobile`, UI-facing YES
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-019`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
HEAD at review: `cb23710c13de185ced36812b0c6a9621d27317d5`
Recommended story status: `IN_PROGRESS` — return to `mobile-dev`

### R2-F0 — No patch round exists on this branch (supersedes all other round-2 analysis)

The round-2 handoff states that mobile-dev returned a patch round. It did not.
The branch contains no work of any kind after the round-1 review. Verified three
independent ways in the declared worktree:

| Check | Result |
| --- | --- |
| `git log bf80848..HEAD` | exactly 2 commits: `b8129de` (round-1 implementation), `cb23710` (round-1 review report) |
| `git diff --name-only b8129de..cb23710` | one file: `review/review-report.md` — my own round-1 report. No source, test, or evidence file changed |
| `git reflog show codex/...-STORY-019` | `@{2}` created from main, `@{1}` = `b8129de`, `@{0}` = `cb23710`. No amend, no reset, no discarded tip |

`git status --porcelain` is clean, so there is no uncommitted patch either.

The handoff's premise appears to come from reading the mobile-dev run state
`RUN-...-STORY-019-mobile-dev.json` as a fresh return. It is not — it is the
**round-1** run, and it never re-ran:

- `spawned_at: 2026-08-13T08:14:01Z`, `completed_at: 2026-08-13T08:44:22Z`
- Round-1 review report was committed at `2026-08-13T10:05:08Z`, i.e. 81 minutes
  *after* that run finished
- `worktree_head: bf80848...` — the run's own recorded head is BaseHead itself

The `evidence_note`, the `runtime_defect_fixed` note, and the four
`deferred_items` quoted in the handoff are all verbatim round-1 fields that
round 1 already adjudicated (as F1/F2, V1, and V3/DEF-1..4 respectively). The
handoff's own aside — "mobile-dev's own base_head was also bf808483..., i.e.
this was its first and only patch round" — is the tell: it is the same run, not
a second one.

Consequence: **every round-1 blocking finding stands unmodified, because nothing
was attempted against any of them.** F1, F2, and F3 remain open verbatim. There
is no new artifact to review, so this round adds no new findings against the
implementation.

### Round-2 answers to the questions the handoff asked

These would have been the round-2 judgments had a patch existed. They are
recorded so the next round does not re-litigate them.

**Q1 — Is the declaration-level substitute acceptable given the stated blocker?
No.** The judgment is unchanged from round 1, and the stated blocker is now
demonstrably not a blocker. I re-verified both halves of it at round-2 time:

- *"`.ai-team-bundle/runtime` is unprovisioned in this worktree
  (render-design-canvas.js unavailable)"* — `render-design-canvas.js` and
  `capture-mobile-screen.sh` are both present right now at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/`.
  `.ai-team-bundle/` is gitignored, which is exactly why it is absent from a
  fresh worktree. Absent-because-gitignored is a per-worktree provisioning step
  (invoke by control-checkout absolute path, or run
  `.ai-team-bundle/runtime/ensure-runtime.sh`), not an unavailable tool.
- *"the single emulator-5554 is shared across the REQ-002 parallel wave"* —
  `adb devices` now reports **two** attached devices, `emulator-5554` and
  `emulator-5560`. Even on one device, contention is a scheduling constraint
  that serializing resolves; it is not an impossibility.

Independently of the blocker being false, the substitute does not satisfy the
gate on its own terms. Rule 12e3 names "verified by source/code inspection" as
the specific excuse it refuses, and offers no prose-waiver path while a design
source is configured and `locked: true`. AC1's "no visible deviation" is a pixel
claim. Six widget-tree assertions can prove a `TextStyle` resolves to 25px; they
cannot prove the screen looks like the design, and they cannot detect the class
of defect the gate exists to catch — overflow, clipping, wrong stacking, a
mis-resolved theme at real device metrics. F2 compounds it: the comparison was
made against a hand-picked canvas file (`Cupid Screens.dc.html`) rather than the
configured entry (`Cupid App.dc.html` with `screens_from: "canvas"`), so even
the declaration-level comparison has an unverified referent.

The disclosure was honest and is why this is `PATCH_REQUIRED` rather than a
trust finding. It is still not waivable.

**Q2 — `IntrinsicHeight` defect: confirmed good, unchanged.** Re-affirmed from
round-1 V1; the code is byte-identical to what round 1 examined. The consent-tile
`Row` (`CrossAxisAlignment.stretch`) inside the screen's unbounded-height
`ListView` threw `BoxConstraints forces an infinite height`; `IntrinsicHeight`
is the correct fix, not a suppression, and it matches the design source's
equal-height 2-column flex row. The new test mounts the real `GhostSettingsScreen`
at 412x1600 and lays out the actual `ListView`, so the crash path is genuinely
executed. Real defect, correctly found, correctly fixed, correctly covered.

**Q3 — The four `chat_strings.dart` deferrals: reasonable, do not require
STORY-019 to touch them.** Re-affirmed from round-1 V3 and DEF-1..4. All four
need `mobile/lib/features/chat/presentation/chat_strings.dart`, which is absent
from this run's `write_scope` and is shared with STORY-018. Declining the
`.toLowerCase()` half-fix (correct for `vi`, breaks `en`) was the right call.
Deferral is genuinely write-scope-bound, not author preference. One correction
to carry forward: DEF-4 cannot be routed to STORY-018 — STORY-018 is already
DONE and merged — so all four need a new follow-up story that owns
`chat_strings.dart`.

### Round-2 critical gates

| Gate | Required | Result |
| --- | --- | --- |
| A patch exists to review | yes | **FAIL — R2-F0** |
| Rendered design-fidelity evidence (12e2/12e3) | yes | **FAIL — round-1 F1, F2 untouched** |
| Story runtime startup smoke (12g) | yes | **FAIL — round-1 F3 untouched** |
| Static analysis / widget tests / chat suite | yes | PASS — unchanged from round 1, no code moved |

### Round-2 action items

Round-1 action items 1-6 carry forward **verbatim and unstarted**. Ahead of
re-dispatching them:

1. `[scrum-master]` Establish why the round-1 patch dispatch produced no work.
   No mobile-dev run was spawned against this story after
   `2026-08-13T08:44:22Z`, so the round-1 action items were very likely never
   delivered to a worker. Re-dispatching a reviewer before re-dispatching
   mobile-dev will loop.
2. `[scrum-master]` When re-dispatching mobile-dev, pass the provisioning fix
   explicitly, since round 1 stalled on it: either the control-checkout
   absolute tool path
   (`/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/`)
   or a `.ai-team-bundle/runtime/ensure-runtime.sh` step inside the worktree,
   plus a named device (`emulator-5560` is free of the 5554 wave contention).
3. `[scrum-master]` Round-1 items 5 and 6 are still open and are scrum-master
   owned, not mobile-dev owned: reconcile `Complexity`/`Story-Class`
   (`story_master.md` says `trivial`; handoff and run state say `standard`), and
   open the follow-up story for DEF-1..4.

### Round-2 process observations (non-blocking)

- `story_master.md` still reads `Status: PENDING` with
  `[x] Implementation (Development)` already checked — inconsistent with a story
  that has been through a review round. Scrum-master owned.
- The handoff declares
  `Checkpoint: data/requirements/REQ-002_.../STORY-019/scrum-master-checkpoint.md`,
  but no `STORY-019/` directory exists — the story directory is
  `STORY-019_typing_ghost_settings_design_fidelity/`, and it contains no
  checkpoint file. The declared checkpoint path resolves to nothing. Flagging
  because the same wrong path is recorded in both run-state files and may be why
  round-1 outcomes did not propagate.

### Round-2 workflow recommendation

- Leave `Review (Reviewer)` unchecked; uncheck `Implementation (Development)`
- Story status `IN_PROGRESS` — return to `mobile-dev`, **not** to Reviewer
- Do not merge to `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
- Do not spawn a round-3 reviewer until `git log bf80848..HEAD` shows a commit
  touching `visual-fidelity/` with the two PNGs present

---

## Round 1 History

Outcome: PATCH_REQUIRED

Review type: `compact-story-review` (first review)
Story: STORY-019 (REQ-002, Scope B) — lane `mobile`, UI-facing YES
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-019`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
Implementation commit: `b8129de3673b5248ebc12f096454000c57deb8ac`
Recommended story status: `IN_PROGRESS` — return to `mobile-dev`

## Scope Gate

Source/test files in scope (4 changed vs BaseHead, within the 8-file compact budget):

- `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart` (+460/-149)
- `mobile/test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` (new, +378)
- `.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `.../STORY-019_typing_ghost_settings_design_fidelity/story_master.md` (+2/-1)

Evidence files in scope:

- `.../STORY-019_typing_ghost_settings_design_fidelity/story_master.md`
- `.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/visual-fidelity-report.md`
- `data/runtime/parallel-runs/RUN-...-STORY-019-mobile-dev.json`
- `data/devops/system/design-fidelity-config.json` (exemption check for rules 12e2/12e3)

Query keys: AC1-AC5; `IntrinsicHeight`; `GhostSettingsScreen` call sites;
`design_source` / `ui_surface`; `VISUAL_FIDELITY`; `Story Runtime Startup Smoke`.

Touched risk surfaces: mobile interaction, mobile navigation/discoverability,
app lifecycle (layout crash path).

## Verdict Rationale

The code change itself is genuine, well-scoped and well-tested — the ten
recorded deviations are really implemented, the crash fix is real, and the
entry point verifies in code. It fails the gate on **evidence**, not on
implementation: the one artifact that proves "matches the design with no
visible deviation" was never produced, and the two exemptions that would
excuse it do not apply to this project.

## Critical Gates

| Gate | Required | Result |
| --- | --- | --- |
| Static analysis (`flutter analyze`, 2 files) | yes | PASS — `No issues found!` |
| Targeted widget tests (6 cases) | yes | PASS — `+6: All tests passed!` |
| Chat suite regression (`flutter test test/features/chat`) | yes | PASS — `+54: All tests passed!` |
| Entry point reachability (12e1) | yes | PASS — verified in code, see below |
| Rendered design-fidelity evidence (12e2/12e3) | yes | **FAIL — F1, F2** |
| Story runtime startup smoke (12g) | yes | **FAIL — F3** |
| Configuration guide | no | not applicable — no setup/config surface touched |

## Blocking Findings

### F1 — Mandatory rendered design-fidelity evidence is absent, and no exemption applies

`data/devops/system/design-fidelity-config.json` records `"ui_surface": true`
and a `design_source` that is `"locked": true`
(`cupid-app-design-system`, `type: claude-design`, detected by
ui-ux-designer 2026-08-11). Both audited scope-outs in rule 12e3 are therefore
closed for this story, and `story_master.md:10` states the same lock.

What is missing under
`.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/`:

- no `implemented-ghostset-<device>.png`
- no `design-reference-ghostset-<device>.png`
- no `VISUAL_FIDELITY:` verdict line anywhere in `visual-fidelity-report.md`
  (not `PASS`, not `FAIL` — the token is simply absent)

The report is candid about this and substitutes a declaration-level comparison
plus widget-tree assertions. That substitution is the specific thing rule 12e3
refuses: "verified by source/code inspection" is named there as an excuse the
gate does not accept, and there is no prose waiver path when a design source is
configured. AC1's "no visible deviation" is a pixel claim; a widget test can
prove a `TextStyle` resolves to 25px, but it cannot see the screen. The honesty
of the disclosure is why this is `PATCH_REQUIRED` and not a trust problem —
but the gap is not waivable.

**This is `PATCH_REQUIRED`, not `BLOCKED`** — I verified the capture path is
available right now, so no environment/dependency actually prevents the gate:

- `capture-mobile-screen.sh` and `render-design-canvas.js` are present at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/`.
  `.ai-team-bundle/` is gitignored, which is why it is not inside the story
  worktree — that is a per-worktree provisioning gap, not the install defect
  `VISUAL_RUNTIME_MISSING`. Invoke via the control-checkout absolute path or
  provision with `.ai-team-bundle/runtime/ensure-runtime.sh`.
- `adb devices` reports `emulator-5554  device` — attached and usable.
- A preview entrypoint for exactly this screen already exists:
  `mobile/lib/main_preview.dart:325` `_buildGhostset`. The hard part of a
  mobile capture is already built.

Emulator contention across the parallel wave is a scheduling constraint, not an
impossibility; serialize the capture.

### F2 — Which design was compared is unverified, and no `Design-Screen: <id>` is recorded

The config declares `entry: "Cupid App.dc.html"` with `screens_from: "canvas"`,
and instructs rendering per screen via `render-design-canvas.js --screen=<id>`.
The implementation compared instead against
`cupid-app-design-system/project/Cupid Screens.dc.html` lines 391-431, a
different canvas file selected by hand-reading HTML. The renderer's own screen
resolution was never exercised, and the story records no resolved
`Design-Screen: <id>`.

This is the failure mode rule 12e2 calls out by name: a story compared against
the wrong screen yields a confident PASS that certifies nothing and is
indistinguishable from a correct one in prose. I cannot close this by reading,
because the only thing that settles it is the rendered reference image. The
re-render must record the resolved screen id and produce the reference from the
configured entry.

### F3 — No `## Story Runtime Startup Smoke` evidence (rule 12g)

Lane is `mobile`; `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>`.
No startup-smoke section exists in any story artifact.

This gate is unusually load-bearing here rather than ceremonial: this very story
fixed a layout exception that crashed this screen at runtime (see V1). A widget
test proves the tree lays out in a test harness; the smoke proves the built app
launches on `emulator-5554` and reaches its first screen without a crash or an
error screen. Both the reviewer gate and the DONE gate enforce it independently.
The emulator is attached, so this is supplyable now.

Note: `story_master.md` records `Complexity: trivial` / `Story-Class: trivial`
while the handoff and run state both declare `standard`. Under either reading
this story is not a safe trivial single-lane change — it is a 460-line screen
rewrite that fixed a crash — so 12g applies. Scrum Master should reconcile the
classification; it does not change the verdict.

## Verified (non-blocking, recorded because the handoff asked)

### V1 — The `IntrinsicHeight` crash fix is real, and the test does exercise the path

Confirmed in the diff: the consent-tile `Row` (`CrossAxisAlignment.stretch`)
now sits inside `IntrinsicHeight` in `_ToggleCard`. Inside the screen's
unbounded-height `ListView` column, `stretch` propagated `h=Infinity` and threw
`BoxConstraints forces an infinite height`. The new test mounts the real
`GhostSettingsScreen` (test file line 126) at 412x1600 and lays out the actual
`ListView`, so the crash path is genuinely executed — not asserted around.
`IntrinsicHeight` is also the correct model for the design source's equal-height
2-column flex row, so this is a fix rather than a suppression. Real defect,
correctly found and correctly fixed; static analysis would not have caught it.

### V2 — Entry point independently verified in code (12e1)

Not taken on trust: `mobile/lib/core/navigation/app_shell.dart:94` mounts
`GhostSettingsScreen`, and `mobile/test/core/navigation/app_shell_test.dart:185`
asserts "the ghostset action opens GhostSettingsScreen from Chat". Reachable
through a real in-app action, not URL-only. AC5 (no new entry point) holds —
the constructor and `onBack` contract are unchanged.

### V3 — The four carried-forward items are genuinely write-scope blocked

Confirmed, not author preference. All four require editing
`mobile/lib/features/chat/presentation/chat_strings.dart`, which does not appear
in the run's `write_scope`
(`ghost_settings_screen.dart`, `ghost_cubit.dart`, `mobile/test/features/chat`,
and two story-artifact paths), and the file is shared with STORY-018. The
implementer also declined a `.toLowerCase()` half-fix that would have corrected
`vi` while breaking `en` — the right call.

## Deferred Findings

| ID | Finding | Disposition |
| --- | --- | --- |
| DEF-1 | `ChatStrings.ghostSetLegendDeleted` / `ghostSetLegendLive` casing/wording vs design source lines 421-422 | Route to a follow-up story owning `chat_strings.dart`; both entries are referenced only from `ghost_settings_screen.dart` |
| DEF-2 | `ghostSetHeroBody` / `ghostSetMutualConsentFooter` wording differs from design source lines 397/412 (semantically equivalent) | Same follow-up |
| DEF-3 | Hero headline forced `<br>` at design source line 396 not pinned in app | Same follow-up; breaks at the same point at 412pt today |
| DEF-4 | `ChatStrings.privacyChip` lacks the `Level 1 · ` prefix; STORY-018 owns the shared string (already DONE/merged) | Needs a new follow-up story — STORY-018 has closed |
| DEF-5 | Partner consent tile renders `Chưa rõ` in `--tx2` instead of the design source's mint `consentBColor` | Accept. Backend exposes no partner-consent flag (ADR-013e); tinting would assert a state the app cannot know. Pre-existing and correctly reasoned |
| DEF-6 | STORY-032 app-shell `skyGradient` background gap | Not observed in this diff — this screen's changes are inside the scroll region and do not touch the shell background |

## Action Items

1. `[mobile-dev]` Render the design reference for this screen from the
   configured entry using the control-checkout renderer
   (`/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/render-design-canvas.js --screen=<id>`),
   capture the implemented screen on `emulator-5554` via
   `capture-mobile-screen.sh` using the existing `main_preview.dart`
   `_buildGhostset` entrypoint, and write both PNGs to
   `.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/`
   as `design-reference-ghostset-<device>.png` and
   `implemented-ghostset-<device>.png`. (F1)
2. `[mobile-dev]` Record the resolved `Design-Screen: <id>` in the story and
   confirm the rendered reference depicts the Typing Ghost consent/settings
   screen — not a neighbouring canvas screen. (F2)
3. `[mobile-dev]` Add a top-level `VISUAL_FIDELITY: PASS|FAIL` line to
   `visual-fidelity-report.md`, backed by the image comparison and naming the
   AC3 states actually captured (off / pending / on) and the AC4 lock chip.
   Any visible delta is `FAIL` with the concrete delta recorded. (F1)
4. `[mobile-dev]` Add a `## Story Runtime Startup Smoke` section proving the
   built app launches on the emulator and reaches its first screen without a
   crash or error screen — or have Scrum Master record
   `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`. (F3)
5. `[scrum-master]` Reconcile `Complexity`/`Story-Class` between
   `story_master.md` (`trivial`) and the handoff/run state (`standard`).
6. `[scrum-master]` Open a follow-up story for the four `chat_strings.dart`
   carry-forwards (DEF-1 to DEF-4); STORY-018, the previous owner, is closed.

## Traceability

| AC | Reviewer status | Basis |
| --- | --- | --- |
| AC1 — dark + `vi` layout/spacing/tokens/typography match with no visible deviation | UNVERIFIED | Declaration-level comparison only; the pixel claim has no rendered evidence (F1, F2) |
| AC2 — deviations corrected in the app, not merely documented | MET | D1-D10 are present in the +460/-149 diff; re-verification against the design source still pending (F1) |
| AC3 — three toggle states match | UNVERIFIED | `_ConsentSwitch` (54x32 track, 26px knob, `gradientHot`/`colorLine`, alignment-based `switchJustify`) is implemented and asserted by tests 1-3, but the state styling is not visually compared (F1) |
| AC4 — Level-1 lock affordance visible | UNVERIFIED | `_PrivacyChip` is implemented and asserted by test 4; placement/styling not visually compared (F1) |
| AC5 — no new entry point | MET | V2 |

- Requirements: `story_master.md` (trivial story — UX and architecture recorded
  `SKIPPED:trivial`, so `coding-plan/` is not required per rule 9)
- UX: `data/ux/system/ui_ux_system_memory.md` §5/§8 cited for the mandatory
  Level-1 lock affordance; implemented as `_PrivacyChip`, rendered
  unconditionally in all three consent states
- OQ discipline: OQ5 (light theme / `en` locale) correctly triaged as
  not-blocking; fixes are expressed in shared `ThemeExtension` tokens, so no
  in-scope AC was withheld and no blocked scope was implemented
- Git boundary: reviewed via `git -C <Worktree> diff bf80848` only

## Workflow Recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status `IN_PROGRESS`; return to `mobile-dev` with action items 1-4
- Do not merge the story branch to
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` until the
  rendered evidence and startup smoke are present
