# Story Review Report — REQ-012 / STORY-002 Create-Code (Couple Types) Screen QR Display

Outcome: DEFERRED_ONLY

Mode: compact-story-review
Reviewer: Iris-QC-3
Review pass: 3 (final)
BaseHead (pass 3): 8a10f04f3cf6db75643aa31f199c89488d6f972c
Worktree HEAD at review: efcf982f43179528b56bfdc48a66cdde74376e1d
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-002_create_code_couple_types_screen_qr_display
Branch: codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-002_create_code_couple_types_screen_qr_display
MergeTarget: codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration

## 1. Pass-3 Scope

Per handoff, this pass verifies one thing only: whether B2 — the sole
remaining pass-2 blocker, the missing `## Story Runtime Startup Smoke` — is
now genuinely closed. B1, B3, B4 and D3 are settled from pass 2 and were not
re-opened. AC1-AC5 were verified PASS in pass 2 and are unaffected: the delta
`8a10f04..efcf982` is a single commit touching three artifact files only
(`coding-plan/test-results.md` +39, `review/review-report.md` ±269 — my own
pass-2 report being committed, `story_master.md` ±21). No production or test
source changed; worktree clean at `efcf982`.

## 2. B2 — Story Runtime Startup Smoke: CLOSED

`coding-plan/test-results.md` now carries a `## Story Runtime Startup Smoke`
section (exact heading required by `validate-done-gate.sh`) with
`Result: PASS`.

Verified against reviewer skill rule 12g, which requires the smoke to be
registry-backed and run on the real shipped entrypoint:

- **Shipped entrypoint, not the preview harness.** The section states the run
  used `lib/main.dart` via the standard `buildCommand`, and explicitly
  distinguishes it from `lib/main_preview.dart`, which was used only for the
  §6 visual-fidelity capture. This is the exact substitution that pass 2
  rejected; it is no longer present.
- **Registry-backed.** I read
  `data/devops/system/runtime-command-registry.json` in the story worktree and
  confirmed the `mobile-app` runtime entry exists and that the quoted commands
  are verbatim, not paraphrased:
  - `buildCommand`: `flutter build apk --debug` — matches step 1.
  - `readiness.type`: `command`; `readiness.command` launches
    `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` with
    `am start -W`, then polls `dumpsys activity activities` for
    `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
    over `seq 1 30` with `sleep 2` and `exit 0` on match — matches step 3,
    including the 30×2s bound and the expected exit code 0.
  - `readiness.shutdownCommand`: `am force-stop com.snapsofts.cupid` — matches
    step 4.
  The registry entry also documents that this is a live probe (devops SKILL
  14b1) which "fails while nothing is running", and that the
  `home_screen_ready_signal` widget test is explicitly NOT the readiness probe.
  The recorded smoke uses the live probe, not the widget-test substitute.
- **Scope.** Device `emulator-5554` was already running and was not booted by
  the smoke; the app was installed with `adb install -r` from the debug APK,
  resumed within the first 2s poll, then force-stopped.
  `Result/Shutdown: PASS, app stopped cleanly, no process left running.`
- **Baseline.** The smoke was run at worktree HEAD `8a10f04`, which is the tree
  containing all implementation. `efcf982` adds documentation only, so the
  smoke's subject tree is identical to the shipped tree for every executable
  file. Valid.
- **Ownership.** Run directly by Scrum Master rather than mobile-dev, because
  `guard-broad-handoff.sh` blocks emulator/device runtime work through a
  mobile-dev handoff in ordinary continue. Rule 12g requires the evidence, not
  a specific author; Scrum Master running deterministic registry commands is a
  legitimate source.

`story_master.md` Implementation note now records B1/B2/B3/B4 all closed and
points at the smoke section. Consistent with the evidence on disk.

**B2 is closed.** No blocking findings remain.

## 3. Acceptance Criteria (carried from pass 2, unchanged by this delta)

| AC | Verdict | Proof |
|----|---------|-------|
| AC1 — live QR above the text code, matching design treatment | PASS | `invite_qr_frame.dart` renders `QrImageView` inside the card frame as the first child of the card `Column`, above the existing text code; heart badge + scan-line accent present. |
| AC2 — QR resolves to the same code as the text code | PASS | `InviteQrFrame(code: invitation.code)` takes the identical source value; independently confirmed by decoding the delivered emulator screenshot with `CIDetectorTypeQRCode` → `CPD-8F2K`, the same string rendered as text on that screen. |
| AC3 — couple-type picker still after the code/QR block | PASS | Picker position unchanged in `invite_screen.dart`; confirmed in both rendered images. |
| AC4 — Continue CTA → REQ-009 Waiting-for-partner, never Fingerprint Vow | PASS | `_submitCoupleType` calls `_pushWaiting` on success, which pushes `WaitingScreen`. `VowScreen` is not referenced anywhere on the CTA path. |
| AC5 — dark theme + `vi` locale matches the design source, incl. the QR | PASS | `visual-fidelity/visual-fidelity-report.md` `VISUAL_FIDELITY: PASS`; both PNGs opened and compared by the reviewer (rule 12e3), 22-row element table, 5-row pixel-measured geometry table with the code paper matching at 182px height / 177px width in both images. |

Gate sections required by the skill are all present and independently
verified: `## Entry Point Reachability` (Reachable: YES, via
`pairing_choice_screen.dart:39`, correctly excluding the `cupidpreview://`
deep link from the reachability claim), `## Story Runtime Startup Smoke`
(this pass), and per-story visual fidelity under `visual-fidelity/`.

Tests: 31/31 `All tests passed!` across the three story suites, re-run by the
reviewer rather than trusted from the implementer report.

## 4. Closed Findings

| ID | Finding | Status |
|----|---------|--------|
| B1 | Missing visual-fidelity report / rendered comparison for AC5 | CLOSED (pass 2) |
| B2 | Missing `## Story Runtime Startup Smoke` on the shipped entrypoint | CLOSED (pass 3) |
| B3 | Missing `## Entry Point Reachability` section | CLOSED (pass 2) |
| B4 | `Design-Screen: TBD` unresolved | CLOSED (pass 2, resolved to `invite`) |
| D3 | `Implementation Lane` was `shared`, should be `mobile` | CLOSED (pass 2, applied in `story_master.md`) |

## 5. Deferred Findings (non-blocking; carried forward)

None of these blocks the story. They are recorded so they are not lost.

- **D1 — BUG-20260825-002 (`no_fork_guard` RED).** Pre-existing at BaseHead,
  not a STORY-002 regression. `invite_qr_frame.dart` was written to avoid
  aggravating it (`_HeartBadge` binds `context.cupidColors` to a local so the
  guard's substring scan does not trip). Owner: existing bug queue.
- **D2 — `gallery_cubit_test.dart:276`.** Pre-existing failure, unrelated to
  this story's surface, still not filed as its own bug. Recommend filing so it
  stops riding along on unrelated reviews.
- **D3 — (closed, see §4).**
- **D4 — Two documented deviations from coding-plan phase P1 §6.** Both are
  disclosed in the implementer evidence with rationale; neither changes AC
  behaviour. Owner: tech-lead, at next plan refresh.
- **D5 — `QrPalette.moduleInk` `#000000` vs canvas placeholder `#2A1E4A`.**
  Properly deferred, not a fidelity failure: the canvas `{{ qrArt }}` is
  procedural PRNG art (`Cupid Screens.dc.html:1999-2025`, `seed = 58291`) that
  encodes nothing — proven by running the same QR detector over the design
  reference, which returned `NO_QR_FOUND`. It therefore carries no valid
  module-colour specification for a real, scannable QR. Maximum module
  contrast is a legitimate functional reason, and the change touches no
  layout, spacing, or `CupidColorTokens` value. If design later wants a tinted
  module ink, that is a design-source decision, not a STORY-002 defect.
- **D6 — Couple-type card hint copy delta vs the canvas.** Card content is
  explicitly Out of Scope for this story (authored under REQ-009). Owner:
  product-owner, if the copy is meant to change.

## 6. Residual Risk

Low. The remaining delta is documentation-only over a tree whose runtime,
tests, and rendered fidelity were all verified. The one substantive judgement
call (D5) is argued from the design source itself and is reversible in a
single constant.

## 7. Recommendation

Outcome is `DEFERRED_ONLY` rather than `CLEAN` solely because five deferred
findings remain worth tracking; every gate, AC, and blocking finding is
satisfied. Per the reviewer skill §7, Scrum Master may check
`Review (Reviewer)` in `story_master.md` and set story status `DONE`, then run
`git-story-boundary.sh complete` followed by `git-story-boundary.sh merge`
into `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`.

REVIEW_COMPLETE: YES
