# REQ-001 Cupid Flutter Mobile App — Requirement Integration Review

Reviewer: Iris-QC
Requirement: REQ-001_cupid_flutter_mobile_app
Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
BaseHead: `df8d5097f89ab6c556a7e5b7269f45929b42f6a5`
Worktree HEAD reviewed: `727677d93c2b0d00695653e4a88691735ac770ed`
Scope gate: `integration-review/scope-gate.md` (query-first targeted inspection,
508 files / 79,718 insertions changed — see gate for grouping/rationale)

## 1. Story merge coverage

All 16 stories (STORY-001..016) have a corresponding artifact subtree and
feature-code diff present against `BaseHead`, confirming all 16 story
branches are merged into this integration branch. `lib/features/*` touch
counts and per-story `story_master.md`/`review/review-report.md` presence
are listed in the scope gate.

## 2. Finding F1 (PATCH_REQUIRED) — req_master.md / STORY-015 bookkeeping not synced

The handoff's stated precondition — "all 16 stories DONE in `req_master.md`"
— does not hold against the canonical control-checkout file:

- `main:data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`:
  requirement `Status: IN_PROGRESS`; `STORY-015` row = `BLOCKED`.
- `main:.../STORY-015_expenses/story_master.md`: `Status: PARKED ... P2-P6
  NOT_STARTED` (stale by several sessions).
- The requirement-level checkpoint that does exist on `main`
  (`data/requirements/REQ-001_cupid_flutter_mobile_app/scrum-master-checkpoint.md`)
  independently states: "15/16 stories DONE and merged ... only STORY-015
  remains ... Requirement integration review NOT YET RUN (blocks REQ-001
  DONE)" and lays out an explicit sequence — STORY-015 review, merge, mark
  DONE in both `story_master.md` and `req_master.md`, **then** run this
  integration review.
- The handoff's `Checkpoint:` field
  (`.../INTEGRATION/scrum-master-checkpoint.md`) does not exist on `main` —
  `git ls-files` confirms no `INTEGRATION/` subtree is tracked for this
  requirement.

This is bookkeeping drift, not missing/unreviewed code: the worktree's own
copy of `STORY-015_expenses/story_master.md` shows `Status: IN_PROGRESS ...
Implementation DONE — all phases P1-P6 DONE`, and
`STORY-015_expenses/review/review-report.md` (present in this worktree,
Tier-3 final synthesis, 5/5 slices CLEAN, AC1-AC4 PASS) records a clean
`Outcome: CLEAN` with `MergeTarget: codex/REQ-001_cupid_flutter_mobile_app-integration`.
The `expenses` feature code (14 touched files) and all of STORY-015's
review/coding-plan artifacts are present in this diff, confirming the merge
actually happened.

**Action required before REQ-001 can be marked `DONE`:** Scrum Master must
sync `req_master.md` (`STORY-015` row -> `DONE`, requirement `Status` update)
and `STORY-015_expenses/story_master.md` (`Status` -> `DONE`) on `main`, and
either create the referenced `INTEGRATION/scrum-master-checkpoint.md` or
correct the checkpoint pointer used for this scope. This is a documentation/
state-sync fix, not a rework of implementation or test evidence.

## 3. Database schema consistency (STORY-007/011/012/015 shared owner)

`mobile/lib/core/database/cupid_database.dart`: single `@DriftDatabase`
class `CupidDatabase`, `schemaVersion => 2`, tables `[Messages,
TimelineEntries, TimelineSyncState, Expenses, ExpenseSyncMetadata]`, daos
`[MessageDao, TimelineDao, ExpenseDao]`. `migration` is additive-only
(`onCreate: m.createAll()`; `onUpgrade` creates only the two new v2 tables
when `from < 2`).

`cupid_database.g.dart` generated `_$CupidDatabase.allSchemaEntities` lists
exactly `[messages, timelineEntries, timelineSyncState, expenses,
expenseSyncMetadata]` — matches the annotation's table list one-to-one.
`$CupidDatabaseManager` exposes a table-manager getter for each of the same
5 tables. DAO getters (`messageDao`, `timelineDao`, `expenseDao`) match the
3 declared DAOs. No orphaned table, no missing manager/DAO wiring, no drift
between the annotation and the generated code.

R-015.1 (escalated in `STORY-015/story_master.md` Tech Lead output: "two
competing Drift owner classes are in flight in this wave — STORY-007
`cupid_database.dart`, STORY-012 `app_database.dart`") is resolved in the
merged code: exactly one `@DriftDatabase` class exists. STORY-015's own
review report independently confirms this same resolution.

**Result: CLEAN.**

## 4. Finding F2 (PATCH_REQUIRED, minor) — stale `app_database.dart` reference in configuration guide

`data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`,
"Timeline Photos & Local Storage (STORY-012)" section, line 319: "the
`drift`-backed local database, see
`mobile/lib/core/database/app_database.dart`". That file does not exist —
`find mobile/lib/core/database` shows only `cupid_database.dart` (+ `.g.dart`)
and the `daos/`/`tables/` subdirectories. This is the pre-canonicalization
name referenced by the R-015.1 escalation (§3 above); the guide was never
updated after the Drift owner was consolidated to `CupidDatabase`. Low risk
(doc-only, no runtime effect) but should be corrected to avoid misleading a
future setup pass.

## 5. DI composition root (`service_locator.dart`)

Full read, 324 lines. Every feature that needs a repository/cubit/DAO has a
registration: pairing, account, gallery (api+cache+repo), backend-user-id
store, pending-event store, notification-prefs, timeline DAO+repository,
**`CouplePairingStore`** (registered as a session-scoped lazy singleton,
line 147-154 — this was flagged as a possible pre-existing gap in an earlier
STORY-015 slice review pass, but is present and correctly wired at this
integration HEAD), dream jar, realtime coordinator (socket+FCM), vibes,
reminders (prefs/repo/schedule bloc/firing cubit), anti-ghosting, the Drift
database + its 3 DAOs, chat (partner store/repository), pet, love contracts
(+ default `PartnerDisplayName` provider), and expenses (DAO/repository/
pairing-state-reader/history cubit/add cubit). No duplicate registration, no
missing dependency observed by inspection (every `getIt<T>()` call site
inside this file resolves to a registration present earlier in the same
function or a type registered in this file).

**Result: CLEAN.**

## 6. Cross-story navigation / entry-point wiring

`home_screen.dart` (324 lines, full read) mounts, in order: anti-ghosting
entry card (STORY-008), vibe entry card (STORY-010), reminder entry card
(STORY-009), dream jar entry card (STORY-014), pet preview card (STORY-011),
love contract entry tile (STORY-006), timeline entry-point gate (STORY-012,
paired-only), expenses entry card (STORY-015). The pre-existing
`Key('home_screen_ready_signal')` boot-smoke marker is intact, nested
verbatim inside the new `SingleChildScrollView` wrapper.

Stories not mounted on `home_screen.dart` are wired at the shell level:
`cupid_app.dart` -> `PairGateShell` (STORY-005 pairing: invite/joincode
flow when unpaired; `ReminderOverlayHost` mounted once for the firing
overlay) -> `AppShell` when paired, which renders a 3-destination tab bar
(Home / Chat gated by `ChatEntryGate` (STORY-007) / Gallery (STORY-013))
plus a floating action button opening `MeScreen` (STORY-016 account hub).
STORY-016's own doc comment in `app_shell.dart` self-documents that this is
"exactly one entry point into the account hub ... without building the
5-tab shell ... a separate Scrum Master routing item" — a known, explicitly
flagged scope limitation, not a hidden defect.

STORY-001-004 are foundation/infra stories (design tokens, API client, auth,
realtime-coordinator DI wiring) with no dedicated UI entry point expected.

Every one of the 16 stories' user-facing surface is reachable from the
composed root widget tree. **Result: CLEAN.**

## 7. Root boot smoke test

`mobile/test/widget_test.dart` pumps `CupidApp` with a fake paired
`PairGateCubit` and a fake `ChatPartnerStore`/`Dio`, then asserts
`find.byKey(const Key('home_screen_ready_signal'))` — consistent with the
key confirmed intact in §6. This test's own inputs are constructed
correctly for the current `CupidApp`/`PairGateShell`/`AppShell`/`HomeScreen`
constructor signatures observed above. (Whether it currently passes is a
runtime/build-verification question out of scope for this read-only code
review; Scrum Master's separate integration build/runtime smoke pass covers
that.)

## 8. Out-of-scope items carried forward from story reviews (not re-litigated here)

Per STORY-015's own review report §6 and the requirement checkpoint's "Known
pre-existing, out-of-scope issues" section — recorded for Scrum Master
tracking, not gating this review since they were already triaged as
pre-existing/unrelated to the stories that surfaced them:
- `pair_gate_cubit_test.dart` passes `AppShell(createPairGateCubit: ...)`,
  but that parameter belongs to `PairGateShell` — a test-only constructor
  mismatch.
- `reminder_copy_guard_test.dart` failure, described as an unrelated
  generated-l10n scan issue.
- ~76 `prefer_initializing_formals` info-lints scattered across feature
  lanes.
These are pre-existing per prior review evidence; this pass did not
independently re-run `flutter test`/`flutter analyze` (read-only review, no
build/boot per the handoff's explicit constraint).

## 9. Conclusion

Code-level integration is sound: the Drift schema owner is canonical and
internally consistent across all four schema-touching stories, the DI
composition root wires every feature without gaps, and every one of the 16
stories' UI surface is reachable from the composed navigation tree with no
dropped entry point.

**F1/F2 re-verification (2026-08-01):** Scrum Master applied both fixes on
`main` at commit `d448014`. Re-checked by reading both files directly out of
that commit (`git show d448014:<path>`):

- **F1 — resolved.** `STORY-015_expenses/story_master.md` at `d448014` now
  reads `Status: DONE — Implementation (Development) DONE, all phases P1-P6
  DONE ... Reviewer gate: ... Outcome: CLEAN. Merged into
  codex/REQ-001_cupid_flutter_mobile_app-integration at merge commit
  727677d93c2b0d00695653e4a88691735ac770ed`. `req_master.md`'s STORY-015 row
  is `DONE`. (`req_master.md`'s top-level requirement `Status:` remains
  `IN_PROGRESS` at `d448014`, which is expected — per this project's DONE
  gate, the requirement flips to `DONE` only after this integration review
  records `CLEAN`/`DEFERRED_ONLY`, a Scrum-Master-owned step that follows
  this report, not a gap in this fix.)
- **F2 — resolved.** `deployment/configuration-guide.md` line 319 at
  `d448014` now reads "...\`mobile/lib/core/database/cupid_database.dart\`)
  for offline timeline caching." — the stale `app_database.dart` reference
  is gone.

Both findings that previously gated `DONE` are now closed. No open findings
remain from this review. Recommend Scrum Master proceed to the separate
integration build/runtime smoke pass, then mark REQ-001 `DONE`.

## Integration Build & Runtime (Scrum Master, post-bugfix evidence gate)

Registry: `data/devops/system/runtime-command-registry.json` `runtimes.mobile-app`.
Verified directly in the integration worktree
(`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app/mobile`)
at HEAD `2efa148` (after all 5 REQ-001 integration bugs — BUG-20260801-001
through -005 — were fixed and independently re-verified CLEAN).

- **Build:** `flutter build apk --debug` -> exit 0, `✓ Built
  build/app/outputs/flutter-apk/app-debug.apk`.
- **Test:** `flutter test` (full suite, no path filter, unfiltered/no shell
  pipe) -> `880 passed, 2 failed`. Both failures are the pre-existing,
  already-triaged, out-of-scope items named in the bug queue (not caused by
  or related to any of the 5 fixes): `pair_gate_cubit_test.dart`'s
  constructor-mismatch and `reminder_copy_guard_test.dart`. Zero new or
  unexpected failures. The readiness gate itself
  (`Key('home_screen_ready_signal')`, exercised via `widget_test.dart`)
  passes.

Integration Build & Runtime evidence gate: **CLEAN** (build + test, modulo
the two pre-existing out-of-scope failures already triaged and excluded from
scope by the bug queue). This closes the last blocker on REQ-001 `DONE`.

Outcome: CLEAN
