# Slice A Review — Render Engine + Content Pack (P1/P2)

Outcome: PARTIAL_SLICE_ONLY

Read this as: the slice passes with deferred findings only and no blocking
findings, but it is a partial verdict over 1 of 3 slices and cannot gate the
story on its own. Slices B and C must return before a story-level outcome
exists. Round 1's story-level record stays untouched at `review-report.md`
(`Outcome: PATCH_REQUIRED`); this file is the Slice A record only.

Reviewer: Iris-QC
Mode: scoped-slice
Date: 2026-09-10
Story: REQ-016_solo_stage1_relationship_assistant / STORY-002_invite_message_composer
Slice: A of 3 (render engine + content pack, phases P1/P2)
Diff baseline: `git -C <Worktree> diff 711274e3fde25788c91390a44572d53766bba778 HEAD`
Worktree HEAD at review: `b99d3ac9036aee89ade1bdc41b991c7e9f13fec6`

## 1. Slice Boundary

In scope, all read at HEAD:

- `mobile/lib/features/invite_composer/domain/mad_libs.dart`
- `mobile/lib/features/invite_composer/domain/invite_renderer.dart`
- `mobile/lib/features/invite_composer/domain/invite_preset.dart`
- `mobile/lib/features/invite_composer/domain/preset_catalogue.dart`
- `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
- `mobile/assets/data/req016/presets.invite.v1.json`
- `mobile/test/features/invite_composer/mad_libs_test.dart`
- `mobile/test/features/invite_composer/invite_renderer_test.dart`
- `mobile/test/features/invite_composer/preset_catalogue_test.dart`
- `mobile/test/features/invite_composer/preset_content_gate_test.dart`

`git diff --name-only 838f5d2 b99d3ac` shows patch round 1 (F-1..F-5) touched
none of these files, so Slice A is the original P1/P2 code and round-1 findings
do not overlap it. F-1..F-5 and Slices B/C were not re-examined here.

## 2. Per-AC Verdicts

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-5 | PASS (slice half) | `renderInvite(preset, values)` is a pure function of preset + values, so swapping the frame re-renders from the same `MadLibsValues` built from that one card. Sheet-side switching is Slice C. |
| AC-9 | PASS | `invite_renderer_test.dart:184` pins repeated renders equal. `mad_libs_test.dart:165` scans every file in `domain/` and fails on `DateTime.now(`, `Random(`, `package:dio`, `package:http`, `cupid_api`, `package:flutter/material.dart`. |
| AC-23 | PASS | `preset_content_gate.dart:148` rejects any preset whose `editorial_review` lacks `layer1` or `layer2`; the record hangs off the preset's durable `id`, which is the same id AC-25/BR-9 requires. Tests at `preset_content_gate_test.dart:217,228`. See D-A1. |
| AC-25 | PASS | Schema'd package with per-item durable ids; duplicate ids are a load-time throw (`core/content/content_package.dart:104-109`). `preset_content_gate_test.dart:136` proves no shipped frame or clause text appears in any `lib/**/*.dart`, so content is data, not code. |
| AC-26 | PASS (slice half) | `ContentPackage.length` is read from the parsed data (`content_package.dart:46-48`) and verified at N ∈ {1, 2, 40} in `preset_catalogue_test.dart:181`. Nothing in Slice A encodes a seed count of 10. The wrap-around behavior itself is Slice C. |
| AC-27 | PASS (slice half) | `PresetCatalogue._packages` memoizes the parse `Future` per category (`preset_catalogue.dart`), so frame flipping is O(1) with no second load at any N; `preset_catalogue_test.dart:122` pins a single read. Sheet layout parameter is Slice C. |
| AC-28 | PASS as shipped | `validatePresetPack` lives in `lib/`, is a pure function over any `ContentPackage<InvitePreset>`, and enforces one unconditional decline door, two-layer editorial review, and the lexical denylist. `preset_content_gate_test.dart:16-21` finds packs by scanning `assets/data/req016` with a regex, and `:91` fails the build on any violation, so a bad pack cannot ship. See D-A2. |
| AC-29 | PASS | One `presetsSchemaId` for every category; `presetAssetKey(categoryId)` resolves by string convention, not a lookup table; the gate test enumerates packs by directory scan. A STORY-007 category drops in with no new gate branch. `preset_catalogue_test.dart:84,96`; `preset_content_gate_test.dart:334`. |
| Story AC-2 | PASS | Three independent layers. `MadLibsValues` drops null/empty/whitespace sources at construction, so no empty-string state exists. `invite_preset.dart:179-197` refuses at parse time any clause whose `text` holds a `{x}` not listed in `requires`, and any unknown placeholder name. `renderInvite` then skips a clause with unmet `requires`. Tests: `invite_renderer_test.dart:130,143,205,221,262`. |
| Story AC-3 | PASS | Same evidence as AC-9; the domain layer has no network, model, or clock dependency by test-enforced construction. |

## 3. Blocking Findings

None.

## 4. Deferred Findings

**D-A1 — `approved_at` is parsed but never validated.**
`invite_preset.dart:152` reads `approved_at` into `EditorialReview.approvedAt`,
but `preset_content_gate.dart:148` only requires `layer1` and `layer2`. A pack
can ship both reviewer identities with no approval date and pass the gate.
AC-23's mandatory content is the two-layer status plus durable-id traceability,
both of which hold, so this is not a defect against the AC text. Raising it
because this schema is the precedent for every later preset category.

**D-A2 — `validatePresetPack` has zero call sites in `lib/`.**
Enforcement is build-time only: the tests are the sole callers. That is
sufficient today and there is no gap, because `presetAssetKey('invite')`
resolves to exactly the file the disk scan gates, and
`preset_content_gate_test.dart:129` pins the shipped set to that one file. But
AC-28's last sentence scopes the gate to content that never passes through this
repository's review. The day a non-asset source lands, the runtime load path
(`PresetCatalogue.load` -> `ContentPackageLoader.load` -> `ContentPackage.parse`)
parses without gating, and the AC-28 guarantee lapses silently rather than
loudly. The parser catches only its own rules (unknown placeholder, ungated
placeholder, `targets: recipient`, unknown role, missing mandatory field); the
decline-door, editorial-review, and denylist rules are gate-only. Recommend
Scrum Master record the wiring point so the first CMS-backed or
downloaded-pack story inherits it as a required task, not a rediscovery.

**D-A3 — the domain purity scan is non-recursive.**
`mad_libs_test.dart:166-173` uses `Directory(...).listSync()` without
`recursive: true`, so a future `domain/<subdir>/*.dart` would escape the
AC-9/AC-3 determinism ban. The directory is flat today.

**D-A4 — `req016` is baked into a shared-foundation path contract.**
Both `presetAssetKey` and the gate test's `_presetDir` hard-code
`assets/data/req016`. AC-29 names STORY-007, which is inside REQ-016, so this
is correct for every consumer the AC covers. A later requirement adding a
category would need a path change. Noting only because Slice A is the
shared-foundation contract for those stories.

## 5. Notes On The Slice

**N-A1 — the handoff names five Slice A tests; four exist.**
There is no `invite_preset_test.dart`. This is not a coverage gap: the
`invite_preset.dart` parser is covered by eight tests inside
`invite_renderer_test.dart:73-181`, including the R-1d `targets: recipient`
rejection (`:89`) and the AC-6 ungated-placeholder rejection (`:143`). The
tests live under a filename that does not advertise them. No action required
beyond not reading the count as missing coverage.

**N-A2 — one collaborator outside the declared file list was read.**
`mobile/lib/core/content/content_package.dart`, because AC-25's durable-id
uniqueness and the schema-id pin are enforced there rather than in a Slice A
file. No findings are filed against it; it belongs to no slice and predates
none of this story's ACs.

**N-A3 — where the AC-6/AC-28 boundary actually sits.**
The placeholder/`requires` consistency invariant is enforced in the parser, not
in `validatePresetPack`. That is what makes `invite_renderer.dart`'s
`values[variable]!` non-null assertion safe: a clause that could throw there
never becomes a `PresetClause`. The coupling is correct and documented, but it
means the "runnable content gate" of AC-28 does not itself cover that rule, and
a reader auditing the gate alone would not find it.

## 6. Stop-Gate Blocker (not a review finding)

`validate-reviewer-handoff.sh` blocked this run 5x with `NO_REVIEW_CONTEXT`.
The review work is complete; only the reviewer stop gate is unmet, and it is
not something a scoped-slice run appears able to clear from inside the
worktree. Attempts made: `Outcome: DEFERRED_ONLY`; `Outcome:
PARTIAL_SLICE_ONLY` per the guard's own fix text; a bare line-initial
`Outcome:` in the final message; and relocating this record to
`review/slice-A/review-report.md` so the filename matched the doc line. All
blocked identically, while disk state satisfied the documented condition.
Scrum Master needs to re-dispatch with a review context the guard recognizes,
or fix the hook's scoped-slice support. Slices B and C will hit the same wall.

SLICE_A_REVIEW_COMPLETE: YES
