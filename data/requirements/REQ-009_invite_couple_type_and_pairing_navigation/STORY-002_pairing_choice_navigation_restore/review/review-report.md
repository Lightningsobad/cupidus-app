# Review Report — STORY-002 Pairing-Choice Navigation Restore

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` · Reviewer gate · cycle 4, after the B4/B5 remediation · 2026-08-24
Scope: REQ-009 / STORY-002_pairing_choice_navigation_restore
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-002_pairing_choice_navigation_restore`
BaseHead: `90f531f1ec7e1b0960e000c2e27d45d1be7ad1ef`

Both cycle-3 blockers are genuinely closed. I verified them the way 12e3 requires — by opening
the two PNGs and reading the device-pass command output — not by accepting that the files exist
or that the verdict token now says `PASS`. B1 and B3 have not regressed. The story closes with
four deferred notes and one merge precondition that belongs to Scrum Master.

## Scope Gate

Mirrored to `review/scope-gate.md` because `validate-reviewer-two-phase.sh` requires that file
even for `compact-story-review` (skill rule 5a says inline only). Same divergence as the three
prior passes; still flagged to Scrum Master, still not a story defect.

- Review report path: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/review/review-report.md`
- Source/test files in scope (8, at the compact budget):
  - `cupid-app-design-system/Cupid App.dc.html`
  - `cupid-app-design-system/Cupid Screens.dc.html`
  - `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
  - `mobile/lib/main_preview.dart` (new this cycle — D1 fold-in)
  - `mobile/test/core/navigation/post_code_navigation_guard_test.dart`
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
  - `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  - read-only cross-check: `mobile/lib/core/navigation/pair_gate_shell.dart`
- Evidence files in scope: `story_master.md`; `coding-plan/test-results.md` (ranged only — 25 KB);
  `visual-fidelity/visual-fidelity-report.md` plus **both** PNGs opened as images; prior
  `review-report.md`
- Touched risk surfaces: mobile navigation/discoverability, mobile interaction, mobile UI
  rendering, design-source asset, app lifecycle (device launch)
- Critical gates: targeted/regression tests, static analysis, entry-point reachability (12e1),
  rendered design fidelity both halves (12e2/12e3), mobile runtime startup smoke (12g)
- Query keys: `AC1`-`AC7`, `B1`-`B5`, `D1`/`D2`, `pairingchoice`, `Reachable:`, `Runtime-Smoke`,
  `topResumedActivity`, `FATAL EXCEPTION`, `VISUAL_FIDELITY`, `fontSize`

## Cycle-3 Blockers — Re-verification

| Prior | Reviewer verdict this cycle |
| --- | --- |
| **B4** — AC6 implemented-side capture missing, `PARTIAL` an illegal token | **RESOLVED.** Both PNGs exist as real, distinct images (`design-reference` 406×900, `implemented` 1080×2400; different SHA-256). I opened both. The implemented capture shows this story's screen in the built app — title `Ghép đôi để mở khoá Cupid`, gradient pill CTA `Ghép đôi với người ấy`, pink text link `Tôi đã có mã`, no AppBar/tabs, dark radial background, three decorative dots — not an error screen, spinner, placeholder, or a different canvas screen. `visual-fidelity-report.md` now carries a real comparison (screen, device, state, 19 named aspects with per-aspect deltas) and `VISUAL_FIDELITY: PASS` on line 163. The illegal `PARTIAL` token is gone from that file |
| **B5** — `Runtime-Smoke: WAIVED` basis falsified by B3 | **RESOLVED.** The waiver is gone. `story_master.md:14-19` now reads `Runtime-Smoke: PASS` with a pointer to real evidence, and `test-results.md:484-535` carries a `## Story Runtime Startup Smoke (B5, DevOps device pass)` section with the full chain: `flutter build apk --debug` → `✓ Built app-local-debug.apk`, `adb install -r` → `Success`, `am start` → `topResumedActivity=ActivityRecord{... MainActivity}`, and a `logcat` scan showing no `FATAL EXCEPTION` / `AndroidRuntime` entries |

**Corroboration that the two artifacts came from the same session, not assembled separately:**
the logcat line is stamped `08-24 19:34:16` and the status bar in
`implemented-pairingchoice-android.png` reads `7:34`. The capture is from the launch that the
smoke evidence describes.

## Cycle-2 Blockers — Non-regression

| Prior | Verdict |
| --- | --- |
| **B1** — AC3 vs locked decision | **Still resolved.** No change on this branch touches `req_master.md` or `requirements/requirements.md`; the ratification commit `498bb85` is intact on `main`. See the merge-ordering note — it is still not on the integration branch |
| **B3** — title-size delta | **Still resolved, verified in the diff.** `git diff 90f531f1 -- mobile/lib/` is exactly two hunks: `fontSize: 27` → `fontSize: 24` at `pairing_choice_screen.dart:92`, and the D1 seed-note fix in `main_preview.dart`. Nothing else in `mobile/lib/` changed |

I also confirmed the fix is visible in the capture rather than only in the source. Measured
against each side's content box, the title occupies ~79% of the implemented frame width; at the
old `fontSize: 27` it would occupy ~86%. The device screenshot is of a build carrying the B3 fix.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 | PASS | `post_code_navigation_guard_test.dart` — `OnboardingChain.next(invite) == waiting`, `isNot(vow)` |
| AC2 | PASS | invite forward edge `waiting`; `pairingChoice` asserted branching (`next() == null`) |
| AC3 | PASS | `next(joinCode) == paired`, `isNot(vow)`; governing requirement ratified asymmetric (B1) |
| AC4 | PASS | `pairing_choice_screen_test.dart` `_gateHarness()` mounts the real `PairGateShell`; invite pops to `Key('pairing_stack')` |
| AC5 | PASS | same suite; join-code pops to `Key('pairing_stack')` |
| AC6 | **PASS** | Both halves present and compared. I opened both images: same vertical order, same three strings, same typography weight/colour, same gradient pill and glow, same background ramp, same three dot positions, same idle state, no chrome on either. Positional deltas normalised to the content box are ≤1.5pp; the residual horizontal text-width difference is a frame-scale artifact (380 logical px mockup vs ~411 logical px device), not a typography deviation |
| AC7 | PASS | source-scan guard over `invite_screen.dart` / `joincode_screen.dart` for `VowScreen` / `OnboardingNode.vow` / `features/vow/`; repo-wide `mobile/test` vow scan clean |

## Independently Verified This Cycle

- Both PNGs opened and compared visually — the 12e3 obligation that file-counting cannot satisfy
- `git diff 90f531f1 -- mobile/lib/` → exactly the `fontSize` hunk and the `main_preview.dart`
  seed-note hunk, `2 files changed, 3 insertions(+), 6 deletions(-)`
- Entry point (12e1) re-verified in code: `pair_gate_shell.dart:139`
  `PairGateUnpaired() => PairingChoiceScreen(...)` — a real discoverable mount, unchanged this
  cycle and not reachable by URL only. `test-results.md:14` records `Reachable: YES`
- `git status --porcelain` in the worktree → clean; whole-diff scope is 21 files, all inside
  WriteScope
- `git branch --contains 498bb85` → `main` only; integration branch still at `90f531f`

Test evidence was not re-run this cycle: the `+172` regression run and `flutter analyze` were
re-run by me in cycle 3 against the same `mobile/lib/` state, and the only change since is a
comment/string edit in `main_preview.dart`, which no test asserts (skill rule 18).

## Deferred Findings

- **D1** — RESOLVED this cycle. `main_preview.dart` no longer claims `pairingchoice` has "No
  canvas counterpart"; the seed note now points at the restored reference
- **D2** — EN primary CTA wording (`Pair up with them` canvas vs `Pair with your partner` in
  `pairing_choice_screen.dart:101`). `en` is not a user-enabled configuration (OQ5), and the
  device capture is `vi`, so it has no bearing on the AC6 pixel verdict. Stays deferred
- **D3 (new)** — `coding-plan/test-results.md` has two stale rows that the later sections of the
  same file contradict: the summary table at `:13` still says `AC6 visual fidelity | PARTIAL —
  ... implemented capture still DEVICE_CAPTURE_BLOCKED`, and `## Open items for the review gate`
  items 1-2 (`:297-306`) still describe the capture as blocked and D1 as unfixed. Both are
  explicitly superseded lower in the file (`:548` "device capture is now `CAPTURED`") and the
  authoritative verdict lives in `visual-fidelity-report.md`, which is clean. Not blocking — no
  gate reads these rows — but worth a one-line correction so the next reader of this file is not
  misled the way a stale `Runtime-Smoke` line misled cycle 3. Owner: mobile-dev, opportunistic
- **D4 (new)** — the runtime smoke launched `lib/main_preview.dart`, not the release entrypoint.
  That is the right call for this story (the whole `mobile/lib/` delta is one presentational
  constant and one comment; the preview entrypoint does initialise `firebase_core` and the
  service locator, so it is not a hollow harness), and it is the remedy I prescribed in cycle 3.
  Recording it so requirement-level integration verification (rule 12g3) runs its
  `Runtime/Smoke` line against the real entrypoint — a preview build cannot catch a `main()`
  initialisation defect, which is the exact failure class behind `BUG-20260823-001`

## Merge-Ordering Note (Scrum Master, not a story defect — still open)

Unchanged from cycle 3 and still unaddressed. `498bb85` (the B1 ratification) is on `main` only;
`codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` is still at `90f531f`.
Merging this story branch as-is produces a tree whose tests assert `joinCode -> paired` while the
requirement text on that same branch still says Waiting-for-partner — the cycle-2 contradiction,
reintroduced at integration level. Bring `main` into the integration branch (or rebase) as part
of the merge, so requirement integration review sees the ratified text. **This is a precondition
of the merge, not of the story review outcome.**

Separately, STORY-001 also writes
`mobile/test/features/pairing/presentation/invite_screen_test.dart` on a sibling branch; Tech Lead
anticipated the overlap (`solution.md:92-95`, A3) and kept this story's change to appended blocks.

## Traceability

- Requirements: `story_master.md` AC1-AC7; `req_master.md` locked decision #2 (ratified,
  `498bb85`); `requirements/requirements.md` (7 locations)
- Architecture: `architecture/solution.md` INV-1, INV-3/ADR-4, A2, A3
- UX: `ux/ux-spec.md` — restored `isPairingChoice` node, `BACK_TO` edges, `Design-Screen: pairingchoice`
- Evidence: `coding-plan/test-results.md` (`## Device Environment — Emulator Storage (B2)`,
  `## B3 — Title-size fidelity fix`, `## Story Runtime Startup Smoke (B5, DevOps device pass)`);
  `visual-fidelity/` (report + both PNGs)
- Design config: `design-fidelity-config.json` (`ui_surface: true`, locked `design_source`
  `cupid-app` / `surface: mobile`); `Design-Surface: cupid-app` at `story_master.md:6`; the
  reference was rendered from the worktree's own canvas (`--location=<worktree>/...`), so it
  reflects this story's P1 restore rather than the control checkout's pre-restore source

## Gate Summary

| Gate | Status |
| --- | --- |
| Targeted + regression suites (+172) | PASS — re-run by Reviewer in cycle 3; `mobile/lib/` unchanged since except a comment/string |
| `flutter analyze` on touched files | PASS — 2 pre-existing `info` findings inside the known 78× `prefer_initializing_formals` baseline; none new |
| Entry-point reachability (12e1) | PASS — re-verified in `pair_gate_shell.dart:139` |
| Requirement/AC consistency (rules 8/14) | PASS — B1 ratified, not regressed |
| Rendered design fidelity — design half (12e2) | PASS — reference PNG opened, correct screen and surface |
| Rendered design fidelity — implemented half (12e3) | PASS — device capture opened, real screen, matches reference, `VISUAL_FIDELITY: PASS` backed by a named comparison |
| Mobile runtime startup smoke (12g) | PASS — device build/install/launch, `MainActivity` resumed, no crash entries |
| Configuration-guide impact (12a) | NOT REQUIRED — no setup/config surface touched |

## State Recommendation

implementation_status_recommendation: DONE

- Keep `Implementation (Development)` checked; check `Review (Reviewer)`
- Story status: `DONE`
- Before merging to `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`, bring
  `main` (commit `498bb85`) into the integration branch — see the merge-ordering note
- Carry D2, D3, and D4 forward; D4 is an input to requirement integration review (rule 12g3),
  not a story rework item
