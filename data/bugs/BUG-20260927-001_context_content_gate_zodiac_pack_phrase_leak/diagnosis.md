# Diagnosis: BUG-20260927-001 `context_content_gate_test.dart` BR-16 Zodiac Pack-Phrase Leak

Bug: BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak
Bug Master: `data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/bug_master.md`
Checkpoint: `data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/scrum-master-checkpoint.md`
Mode: fix-bug
Date: 2026-09-28

## Input Anchors

- Failing command: `cd mobile && flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact`
- Failing case: `shipped packs pass the gate from disk (AC-35/AC-36/BR-18) > no pack wording is written into any Dart or l10n file (BR-16)`
- Assertion site: `mobile/test/features/context_notebook/context_content_gate_test.dart:159`
- Reported offender: `lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` contains `"Cà phê sáng"`
- Root-cause file owner: REQ-016/STORY-011 P2 (commit `27700367`), outside both surfacing runs' write scope

## Pre-Fix Reproduction Gate

- Original failure anchor: `mobile/test/features/context_notebook/context_content_gate_test.dart:159`, BR-16 case, `Expected: empty`
- Reproduction method and modality: same modality as the report — direct `flutter test` execution of the named suite
- Exact command:
  `cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact`
- Expected failure: BR-16 fails with a non-empty offender list naming `zodiac_shell_resolver.dart`
- Actual result: exit code 1, `+27 -1: Some tests failed.`
  ```
  Expected: empty
    Actual: [
              'lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart contains "Cà phê sáng"'
            ]
  test/features/context_notebook/context_content_gate_test.dart 159:7  main.<fn>.<fn>
  ```
  Exactly one case fails; the other 27 cases in the suite pass.
- Result: REPRODUCED
- Blocker type: N/A

## Expected vs Observed Behavior

- Expected: BR-16 reports an empty offender list — no shipped Dart or `.arb` file under `mobile/lib/**` duplicates a prompt, seed chip, or skill label literal from a shipped context pack JSON.
- Observed: `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` contains the literal `Cà phê sáng`, which is also a seed chip in a shipped pack, so the offender list is non-empty.

## Root Cause

### Hypothesis

Either (a) a display-form pack literal was authored into `lib/**` source, or
(b) the BR-16 scan is over-broad because it also reads Dart comments.

### Confirmed Root Cause

(a). The offending occurrence is a **doc comment**, but the collision is real
authored wording, not a scanner defect.

- `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart:157` (at
  the pre-fix state) documented `zodiacNotebookTagsIn` with two illustrative
  display-form examples of free-typed notebook text: `"Cà phê sáng"` and
  `"Đi bộ"`.
- `Cà phê sáng` is simultaneously a shipped seed chip in **two** packs:
  - `mobile/assets/data/req016/ask_questions.v1.json:11` `"chips"`
  - `mobile/assets/data/req016/portrait_questions.v1.json:11` `"chips"`
- BR-16 (`context_content_gate_test.dart:134-160`) builds `authored` from every
  shipped question `prompt`, every `chip`, and every skill-seed `label`, then
  walks `Directory('lib')` recursively and flags any `.dart`/`.arb` file whose
  whole file text `contains` one of those strings. It deliberately does not
  strip comments — it is a plain whole-file `String.contains` scan.
- The second example, `"Đi bộ"`, was never flagged: it is not a shipped pack
  chip. So exactly one literal, in one file, produced the single offender.

### Why the gate is correct and was not changed

BR-16's contract is that pack wording lives in the JSON packs only, so a CMS can
replace content without a code change (the same rationale `_maxTagWords` states
at `zodiac_shell_resolver.dart:150-153`). Excluding comments from the scan would
weaken a control another story owns, and would need comment-stripping logic that
is fragile against Dart string literals containing `//`. The smallest safe fix
is therefore on the authored side: remove the display-form literal from the doc
comment.

## Patch Decision

Reworded the `zodiacNotebookTagsIn` doc comment to describe the input class
("free Vietnamese with its diacritics") and to keep only the ASCII slug form
(`di_bo`), which BR-16 never scans for because slugs are not pack wording. Added
one sentence naming BR-16 and the gate test path so the constraint is visible at
the site that violated it — this prevents recurrence without touching the gate.

No executable code, no public API, and no behavior changed: the edit is confined
to a `///` documentation block.

## Root-Cause Family And Cluster Boundary

- Family: "shipped pack wording duplicated into `lib/**` source", detected by
  BR-16.
- Same-family members present at this HEAD: exactly one (`Cà phê sáng` in
  `zodiac_shell_resolver.dart`). A repository-wide check for the phrase found
  only that one `lib/**` hit plus the two legitimate `assets/data/` pack files.
  The cluster is therefore closed by this single patch.
- Distinct, explicitly NOT part of this family (observed while preparing the
  adjacent-suite run in the control checkout, resolved as environment state, not
  code): stale `.dart_tool` package resolution and missing generated l10n made
  `flutter test test/features/context_notebook` fail to compile with
  `Couldn't resolve the package 'flutter_local_notifications'`/`'timezone'`/
  `'home_widget'` and ~100 `AppL10n` getter errors. Different failure signature,
  different remediation (`flutter pub get`), no shared source of truth with
  BR-16. Cleared by `flutter pub get`; `git status` confirms neither `pubspec.lock`
  nor any tracked file changed as a result.

## Touched Risk Surfaces

- Typed/generated contract: NO (no signature, no generated code)
- Persistence/schema/migration: NO
- Runtime/configuration: NO
- External integration: NO
- Async job/workflow: NO
- Frontend interaction: NO (documentation-only edit)
- Security/auth: NO
- Data migration/backfill: NO
- Operational command: NO

Selected minimum proof: the BR-16 suite itself (the gate is the regression test),
plus both suites that own the touched file's feature, plus the registry build and
runtime startup gates.

## Scope Classification

mobile — narrow, single-file, documentation-only patch.

## Context Ledger

Anchors used: BR-16 test name, `context_content_gate_test.dart:159`, the literal
`Cà phê sáng`, symbol `zodiacNotebookTagsIn`.

| Artifact | Access |
| --- | --- |
| `data/bugs/BUG-20260927-001_.../bug_master.md` | full read (122 lines) |
| `data/bugs/BUG-20260927-001_.../scrum-master-checkpoint.md` | full read (47 lines) |
| `.claude/skills/bug-fixer/SKILL.md` | full read, once (own skill) |
| `mobile/test/features/context_notebook/context_content_gate_test.dart` | ranged read, lines 100-169 only |
| `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` | ranged read, lines 143-170 only |
| `mobile/assets/data/req016/*.json` | Grep hit lines only, never full-read |
| `data/devops/system/runtime-command-registry.json` | full read (17.7 KB, under the 20 KB bar; needed the `mobile-app` build/readiness/shutdown commands verbatim for two gates) |

No source or test file was read twice, and no directory was scanned broadly.

## Risk Notes

None for contracts, data, auth, concurrency, or deployment: the shipped Dart
output is byte-identical apart from comment text.

One residual, for Scrum Master routing rather than for this patch: BR-16 stays
recurrence-prone by construction, because any new pack chip can retroactively
collide with an existing source literal (including one in a comment). The added
in-file note mitigates it for this file only.

