# Bugfix Review Report: BUG-20260817-001 Chat FAB Occludes Send Button

Outcome: CLEAN

Review type: bugfix-review
Reviewer: Iris-QC
Date: 2026-08-23
Bug: `BUG-20260817-001_chat_fab_occludes_send_button`
Scope gate: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/review/scope-gate.md`
Repo state reviewed: branch `main`, HEAD `a11959d`
Blocking findings: 0
Deferred findings: 1

## Rationale

The reported defect was real at intake and is genuinely absent from current
source. Every load-bearing claim in the diagnosis and fix evidence was
independently re-verified against git history, current source, the rendered
captures, and a fresh test run — none of it was accepted on trust. The delivered
change is exactly one regression test, with a mutation check that proves the
guard discriminates: it fails when the original occluder is restored and passes
when it is not. No production source change, no product scope added, no
navigation/IA decision taken.

## Independent Verification

| Claim under review | How I verified it | Result |
|---|---|---|
| The FAB existed at the cited anchor when filed | Extracted `app_shell.dart` at `3d74a75^` (`970784c`); found `floatingActionButton: FloatingActionButton(` at line 199 and `heroTag: 'account-hub-entry'` at 200 | CONFIRMED — matches `bug_master.md`'s cited `:199-206` exactly |
| No `floatingActionButtonLocation` override, so default `endFloat` applied | Same extracted pre-fix file: no `floatingActionButtonLocation` match | CONFIRMED — root cause mechanism holds |
| `3d74a75` (STORY-061, 2026-08-20) removed it, after the 2026-08-17 intake | `git show --no-patch --date=short 3d74a75` → 2026-08-20; `git log -S'FloatingActionButton' -- app_shell.dart` → introduced by `fb20d90` (STORY-016, 2026-07-31), last touched by `3d74a75` | CONFIRMED — incidental fix by a later story, not by this bug entry |
| No FAB remains on HEAD | Grep for `floatingActionButton\|account-hub\|heroTag` in `mobile/lib/core/navigation/app_shell.dart` → no matches; read lines 189-201: `Scaffold` has only `body` + `bottomNavigationBar` | CONFIRMED — also confirms the residual note about stale line numbers |
| `app_shell.dart` and `chat_composer.dart` unmodified; mutation fully reverted | `git diff` on both paths → empty | CONFIRMED |
| Only 1 file changed | `git diff --stat -- mobile/` → `app_shell_test.dart` +52 (see D-1 for the two unrelated pre-existing `ios/` entries) | CONFIRMED |
| The new test pumps `AppShell` + `ChatScreen` in one tree — the gap the report named | `_harness` at `app_shell_test.dart:126` builds `home: AppShell(` at :185; the test selects the `Chat` destination through it | CONFIRMED |
| The finder targets the real send button | `chat_composer.dart:301-310` — `IconButton(onPressed: enabled ? onPressed : null, ... Icons.arrow_upward)`; the only other composer `IconButton` (:206, ghost toggle) carries a different icon, and the test asserts `findsOneWidget` | CONFIRMED — unambiguous |
| The suite passes with the guard present | Re-ran `flutter test test/core/navigation/app_shell_test.dart` myself | CONFIRMED — `+10: All tests passed!`, new guard listed at `+5`, matching the evidence verbatim |

## Gate Verification

| Gate | Status | Evidence |
|---|---|---|
| `## Pre-Fix Reproduction Gate` present in `diagnosis.md` | PASS | Result `NOT_REPRODUCIBLE_ON_HEAD`, same modality (on-device shell-wrapped capture), with both a current capture and the historical pre-fix capture cited |
| Reproduction conclusion sound | PASS | See below — accepted on verified evidence, not on the absence of a literal `REPRODUCED` token |
| `## Original Failure Recheck Gate`, `Same modality as original: YES` | PASS | Rendered on-device capture + real `adb input tap`, not unit-test-only/build-only/startup-only |
| Regression test gate | PASS | Independently re-run by this review |
| Static analysis of touched file | PASS | `flutter analyze test/core/navigation/app_shell_test.dart` → `No issues found!` |
| Build gate | PASS | `flutter build apk --debug` via registry `runtimes.mobile-app.buildCommand` |
| Runtime startup gate | PASS | Registry `runtimes.mobile-app.readiness` probe exit 0, shutdown exit 0 |
| Mutation check proves the guard catches the original defect | PASS | Guard FAILs with the pre-`3d74a75` `endFloat` FAB restored; mutation reverted (verified by empty `git diff`) |
| Configuration guide | NOT REQUIRED | Test-only change; no setup, env, dependency, or runtime-configuration surface touched |

### On the `NOT_REPRODUCIBLE_ON_HEAD` conclusion

Verified rather than waived. Three independent lines agree: (1) git history
shows the occluder introduced by STORY-016 and deleted 2026-08-20, three days
after intake; (2) HEAD source contains no FAB of any kind in the shell; (3) the
current on-device capture shows the shell chat tab with the send button clear.
The historical capture cited by the diagnosis
(`STORY-040/visual-fidelity/implemented-chat-emulator-5560.png`) is correctly
identified as the shelled render that evidences the original defect, and the
evidence file correctly notes the supplementary
`implemented-chat-composer-draft-emulator-5560.png` was captured
`wrapInShell: false` and therefore never showed the FAB. The bug was real; it
was superseded, not misfiled.

### Rendered evidence — read, not counted

I opened all three captures rather than checking that the files exist.

- `recheck-chat-shell-empty-draft.png` — real device render of the shell-wrapped
  chat tab. Shows the 5-tab bar `Nhà / Trò chuyện / Pet / Ví chung / Tôi` with
  `Trò chuyện` selected, exactly as the diagnosis states, no FAB anywhere, and
  the `arrow_upward` send button visible and unobstructed at the composer's
  trailing edge in its disabled style. Not a placeholder, error screen, or blank
  frame.
- `recheck-chat-shell-enabled-send.png` — non-empty draft present; the send
  button is in its enabled pink-gradient state, clear of any overlay. Its
  rendered centre sits at approximately (985, 875) in the 1080-wide capture,
  which matches the `adb shell input tap 985 875` coordinate recorded in the
  evidence — the tap demonstrably targeted the send button, not an approximation
  of it.
- `recheck-chat-shell-after-send-tap.png` — the composer has returned to its
  hint state `Đối phương thấy từng chữ…` with the send button back in its
  disabled style, i.e. the draft was consumed. That state transition is a direct
  consequence of the send handler firing, which is the exact property the bug
  denied. Note for precision: no new outgoing bubble appears in the transcript,
  as expected for the scripted preview harness
  (`main_preview.dart`, `PREVIEW_CHAT_GHOST=on`) — the fix evidence claims only
  that the draft was consumed and does not overstate this.

### Proportionality and scope discipline

- The delivered change is proportionate. Patching `app_shell.dart` would mean
  re-adding and re-removing a widget that is already gone; the real remaining
  gap was the absent regression guard, and that is what was delivered.
- The guard is a genuine improvement over the pre-existing STORY-061 assertion,
  not a duplicate. `find.byType(FloatingActionButton), findsNothing`
  (`app_shell_test.dart:345-362`) rules out one widget *class*; the new test
  asserts the *property* the bug was about, by checking that a pointer at the
  send button's centre reaches the send button's `RenderBox` in the hit-test
  path. A future `Positioned`/`Stack`/banner/bottom-sheet occluder, or an
  `AbsorbPointer` above the composer, fails the new test and passes the old one.
- No STORY-016 DEC-4 re-litigation. Confirmed against git: DEC-4's
  3-tab-plus-FAB chrome was already replaced by STORY-061's shipped 5-tab shell
  in `3d74a75` before this bug was picked up. The diagnosis treats that as
  inherited fact and takes no shell/IA decision of its own, which is correct —
  the decision surface named in `bug_master.md` (hide/relocate/inset) was
  already closed by delivered work.

## Traceability

| Input | Path |
|---|---|
| Bug report | `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/bug_master.md` |
| Diagnosis | `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/diagnosis.md` |
| Fix evidence | `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/fix-evidence.md` |
| Changed file (1) | `mobile/test/core/navigation/app_shell_test.dart` |
| Read-only confirmation | `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` |
| Recheck captures (3) | `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/evidence/recheck-chat-shell-{empty-draft,enabled-send,after-send-tap}.png` |
| Historical pre-fix capture | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-040_chat_typing_ghost_design_fidelity_hardening/visual-fidelity/implemented-chat-emulator-5560.png` |
| Incidental-fix commit | `3d74a75` (STORY-061, 2026-08-20); occluder introduced by `fb20d90` (STORY-016, 2026-07-31) |

## Touched Risk Surfaces

| Surface | Touched | Critical gate | Verdict |
|---|---|---|---|
| Mobile navigation/shell chrome | Read-only | `git diff` empty on `app_shell.dart` | PASS |
| Mobile interaction (chat primary action) | Behaviour unchanged, newly guarded | Same-modality on-device recheck + hit-test guard | PASS |
| Test/regression coverage | Yes (sole change) | Suite pass + falsifying mutation check | PASS |
| Mobile build | Indirect | `flutter build apk --debug` | PASS |
| App lifecycle / runtime startup | Indirect | Registry readiness + shutdown probes | PASS |

Not applicable: persistence/schema, migration, external integration, async job,
security/auth, permissions/device API, local storage/offline, deep link/push,
data backfill, operational command, typed/generated contract.

## Blocking Findings

None.

## Deferred Findings

**D-1 — Unrelated pre-existing working-tree changes must not enter the bugfix
commit.** `git status` shows `mobile/ios/Runner.xcodeproj/project.pbxproj` and
`mobile/ios/Runner/Base.lproj/Main.storyboard` modified, plus untracked
`backend/.env.example` and `docs/production-readiness-checklist.md`. All four
predate this bugfix and are outside its scope. Owner: `scrum-master` — stage
only `mobile/test/core/navigation/app_shell_test.dart` and the
`data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/**` artifacts when
committing this fix. Not attributable to Bug Fixer; recorded so a broad
`git add` does not sweep them in at closure.

## State Recommendation

- Keep `Diagnosis (Bug Fixer)` and `Fix Evidence (Bug Fixer)` checked.
- Check `Review (Reviewer)`.
- Recommend bug status `DONE`.
- `scrum-master` owns the actual status update; this report does not apply it.
