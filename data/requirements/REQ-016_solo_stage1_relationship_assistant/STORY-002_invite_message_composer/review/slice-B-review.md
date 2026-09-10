# Slice B Review — Schema v5 + Payload Store (P3/P4)

Outcome: DEFERRED_ONLY

Reviewer: Iris-QC
Mode: scoped-slice
Date: 2026-09-10
Story: REQ-016_solo_stage1_relationship_assistant / STORY-002_invite_message_composer
Slice: B of 3 (schema v5 + payload store, phases P3/P4)
Diff baseline: `git -C <Worktree> diff 711274e3fde25788c91390a44572d53766bba778 HEAD`
Worktree HEAD at review: `b99d3ac9036aee89ade1bdc41b991c7e9f13fec6`

Scope note: this is a partial verdict over 1 of 3 slices. It does not gate the
story on its own; Slice C is still outstanding.

## 1. Slice Boundary

The handoff asked me to name the exact table/migration files I found. There is
no separate migration file — Drift keeps the migration inline in
`cupid_database.dart`'s `MigrationStrategy`, and the two table files are:

- `mobile/lib/core/database/tables/invite_messages_table.dart` (new table)
- `mobile/lib/core/database/tables/activity_cards_table.dart` (`location` column, +5 lines)

Also in scope, all read at HEAD:

- `mobile/lib/core/database/cupid_database.dart` (schemaVersion 4 -> 5, `onUpgrade`)
- `mobile/lib/core/database/daos/invite_message_dao.dart`
- `mobile/lib/features/invite_composer/data/invite_payload_repository_impl.dart`
- `mobile/lib/features/invite_composer/domain/invite_payload.dart`
- `mobile/lib/features/invite_composer/domain/invite_payload_repository.dart`
- `mobile/lib/core/di/service_locator.dart` (4 additive registrations)
- `mobile/test/core/database/migration_v5_test.dart`
- `mobile/test/features/invite_composer/invite_payload_repository_test.dart`

Generated `.g.dart` files were not reviewed as authored code. F-1..F-5, Slice A
files, and Slice C were not re-examined.

## 2. Per-AC Verdicts

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-16 | PASS (slice half) | The data layer adds no send path: no messaging import, no HTTP client, no channel column. `invite_payload_repository_test.dart:407` pins the physical column set via `PRAGMA table_info` and rejects `channel`, `sent`, `delivered`, `share_result` and 8 more. The Share Sheet invocation itself is Slice C. |
| AC-17 | PASS | All five required elements are their own columns, not a blob: `preset_id` (template id), `category_id`, `pack_version`, `filled_values`, `card_id`. Only `filled_values` is JSON, because it is the only variable-key field. `invite_payload_repository_test.dart:312` asserts the stored columns hold the input, never the rendered sentence. |
| AC-18 | PASS | `renderStored` rebuilds from `userEditedText ?? renderInvite(preset, values)`. The AC's "even after app restart" clause is tested honestly: the round-trip group opens a real on-disk SQLite file through a fresh `CupidDatabase` connection per call (`:239-247`), so `:260` and `:288` are genuine relaunch tests rather than same-instance reads. |
| AC-19 | PASS | The table is a closed allowlist with no reply, response, link, or web-surface column, and the test at `:407` enforces that physically rather than by inspection. `InvitePayload`'s own doc records the absence of any send/open/seen timestamp as deliberate. Nothing here builds a stage-1.5 channel, and nothing blocks one. |
| Story AC-5 | PASS | Storage is the structured render input (template id + filled values), never flattened text. Same evidence as AC-17/AC-18. |

## 3. Blocking Findings

None.

## 4. Deferred Findings

**D-B1 — the migration test covers `from` 3 and 4, not 1 and 2.**
`migration_v5_test.dart:89` parametrises over `const <int>[3, 4]`. Those are the
two upgrade paths this story restructured, and covering v4 is the important one
(see N-B1). But the v5 change also rewrote the `from < 3` branch's surrounding
shape, and a v1/v2 machine now takes a path no v5 test exercises: it gets
`activity_cards` created from the current definition (already including
`location`), then falls through to the trailing `if (from < 5)
createTable(inviteMessages)`. I traced that path by hand and it is correct - the
new table is not created inside the `from < 3` branch, so there is no duplicate
`CREATE TABLE`. Extending the loop to `[1, 2, 3, 4]` would make that structural
guarantee enforced rather than reasoned. Whether v1/v2 devices still exist in
the field is a release-history question I cannot answer from the worktree.

**D-B2 — `savePayload` does not validate `filledValues` keys at write time.**
The wire-level `Map<String, String>` is stored as given; an out-of-set key is
dropped later at render (`madLibsValuesFrom`). That is deliberate and
documented as forward compatibility, and it is the right default. The cost is
that a caller bug writing wrong keys produces no error at the write, and only
surfaces as a quietly shorter sentence at render. Acceptable as designed;
noting because the write API is the shared-foundation surface later categories
will call.

## 5. Notes On The Slice

**N-B1 — the migration fix is the most valuable thing in this slice.**
The previous `else if (from < 4)` chain would have skipped the v5 step for
every device sitting on v4, which is the largest real installed group. The new
code uses sibling `if`s inside the `else`, and the reasoning is written into
the source at `cupid_database.dart:104-106` rather than left for the next
reader to rediscover. `migration_v5_test.dart` covers v3 and v4 separately,
asserts the pre-upgrade row survives with `location` null, and adds a fresh
install `onCreate` case plus two `ON DELETE CASCADE` cases. This is the part of
the story most likely to destroy user data and it is the part with the most
careful evidence.

**N-B2 — the DI registrations carry no stale-handle risk.**
I checked specifically, because a lazy singleton wrapping
`getIt<CupidDatabase>().inviteMessageDao` would break if the database were
re-registered on sign-out. `CupidDatabase` is registered once at
`service_locator.dart:321` and never unregistered or reset anywhere in that
file, and the new entries follow the existing `ActivityCardDao` precedent at
`:331` exactly. No finding.

**N-B3 — the counting-surface scan strips only whole-line comments.**
`invite_payload_repository_test.dart:453-459` filters lines whose trimmed form
starts with `//`, so a trailing inline comment containing "count" would fail
the test. That direction is safe: it produces a false red, never a false green.
No action.

**N-B4 — the read surface is deliberately narrow and that is enforced twice.**
`InvitePayloadRepository` exposes exactly three members, and the ban on
count/rank/aggregate queries is enforced by a source scan over all three
payload files rather than by a type check, because a `countForCard` would
compile fine against the interface. The DAO doc gives the reason: a count API
is what a "you sent 5 invites" surface gets built on later.

SLICE_B_REVIEW_COMPLETE: YES
