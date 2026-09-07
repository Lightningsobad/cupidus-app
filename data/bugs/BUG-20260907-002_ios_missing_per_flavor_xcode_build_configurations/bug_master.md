# Bug Master: BUG-20260907-002 iOS Missing Per-Flavor Xcode Build Configurations

Status: IN_PROGRESS
Severity: blocking to any mobile-dev run whose story requires a passing
`flutter build ios` verification; non-blocking to Android-only verification
Source: Alex-Mobile-Dev (mobile-dev), REQ-016/STORY-003 `Mode:
mobile-implementation` run, reported as `BLOCKER: PREEXISTING_TEST_FAILURE`
Created: 2026-09-07
Linked Requirement: N/A (pre-existing defect unrelated to REQ-016; first
surfaced during REQ-016_solo_stage1_relationship_assistant delivery)
Linked Story: surfaced by REQ-016/STORY-003_private_journal (Phase P2); may
also surface independently on any other story/branch that runs
`flutter build ios`

## Report

Observed behavior:
`PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign` exits
non-zero.

Failing assertion:
- Without a flavor it stops with: "You must specify a --flavor option to
  select one of the available schemes."
- With `--flavor Runner` it stops with: "The Xcode project defines build
  configurations: Debug, Release, Profile / Flutter expects a build
  configuration named Debug-Runner or similar."

Expected behavior:
`flutter build ios --debug --no-codesign --flavor <flavor>` succeeds for each
configured flavor (matching the Android `local`/`prod` flavor setup), or, if
iOS is intentionally unflavored, the project stops requiring `--flavor` at
all.

Reproduction steps or command:
```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign --flavor Runner
xcodebuild -list -project mobile/ios/Runner.xcodeproj
```

Proof this is pre-existing, not introduced by the surfacing story:
- `xcodebuild -list -project mobile/ios/Runner.xcodeproj` shows Build
  Configurations `Debug`, `Release`, `Profile` only — there is no
  `Debug-<flavor>` configuration for ANY flavor, so no `--flavor` value can
  make this command pass.
- `git diff --name-only b081f408509c48d5fbc023ab1c4a3e36568b081a -- mobile/ios`
  returns only `mobile/ios/Runner/AppDelegate.swift`, so
  `mobile/ios/Runner.xcodeproj/project.pbxproj` is byte-identical to BaseHead,
  and the failure is emitted during Xcode project inspection before any Swift
  is compiled.
- Android has `local`/`prod` flavors; iOS was never given matching build
  configurations — a repo-wide gap, not a regression introduced by this
  story's Swift changes.

Substitute evidence that the story's changed Swift compiles despite this gap:
`xcrun swiftc -typecheck` against the real Flutter iOS engine framework plus
the project bridging header, clean, with a negative control proving the check
is not a no-op (captured by Alex-Mobile-Dev in
`data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-003_private_journal/coding-plan/test-results.md`).

Out-of-scope path that owns the fix:
`mobile/ios/Runner.xcodeproj/project.pbxproj` (add `Debug-<flavor>` /
`Release-<flavor>` / `Profile-<flavor>` build configurations per flavor,
mirroring the Android `local`/`prod` flavor scheme, or an Xcode scheme change
removing the `--flavor` requirement for iOS if iOS is meant to stay
unflavored). This is outside any story's normal write scope
(`mobile/ios/Runner`, not the sibling `.xcodeproj`).

Why not fixed inline by the reporting agent:
Editing `project.pbxproj` (Xcode build configuration/scheme wiring) is
project-configuration work outside the reporting story's declared write scope
and outside a single story's review boundary; it is a repo-wide iOS build
tooling gap that should be fixed and verified once, not per-story.

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, via `fix bugs`
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (complete, `Result: REPRODUCED`)
- Fix Evidence: `fix-evidence.md` (complete, `BUG_FIX_COMPLETE: YES`)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016/STORY-003_private_journal mobile-dev run
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-mobile-dev.json`,
  status `BLOCKED`)
- Related but distinct: `BUG-20260907-001_mobile_repo_wide_preexisting_test_failures`
  covers `flutter test` unit/widget failures; this bug covers a separate
  root-cause family (`flutter build ios` Xcode build-configuration/scheme
  gap) and must not be merged into that row.

## Resolution (not yet started)

- STORY-003 P2 is otherwise COMPLETE and already committed
  (`040d53bf0f4b6725608747b0c767c5ee492e3820`) on
  `codex/REQ-016_solo_stage1_relationship_assistant-STORY-003`. Per the
  `PREEXISTING_TEST_FAILURE` escalation procedure, this bug should land (on
  the branch STORY-003 builds from) before STORY-003's next mobile-dev phase
  is treated as gate-clean on iOS build verification. Android-only
  verification for STORY-003 may proceed without waiting on this bug.
- Queue this bug through `fix bugs` for `Justin-BugFixer` dispatch.

## Blockers

- N/A
