# REQ-016 Requirement Integration Review

Review type: requirement-integration-review
Requirement: REQ-016_solo_stage1_relationship_assistant
Scope gate: `data/requirements/REQ-016_solo_stage1_relationship_assistant/integration-review/scope-gate.md`
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-integration`
HEAD reviewed: `e9519243047baa59a2703496b37912a8b71a5848`
Diff baseline: `eb4898c61427bf78572915ee80459e48ed6b30e3`
Reviewed: 2026-09-26

Outcome: PATCH_REQUIRED

## Verdict rationale

The 13 story branches integrate cleanly at the level each story was reviewed at:
the Drift ladder, the generated client, DI, the navigation shell and the native
widget host are all mutually consistent (see Cross-story contracts below). The
patch is required for one cross-story data defect that no single story review
could own, plus two requirement-level closure gates that have no evidence yet.

The blocking defect is the one item every story review deferred as
"pre-existing / another story's table": at requirement level there is no other
story to defer it to, and STORY-013 AC-26 names the affected data by name.

## Merged story inventory

| Story | Latest merge commit | Story verdict recorded |
|---|---|---|
| STORY-001 | `4c18bd31` | DEFERRED_ONLY |
| STORY-002 | `844487bc` | DEFERRED_ONLY |
| STORY-003 | `69b36905` | DEFERRED_ONLY |
| STORY-004 | `fa30737f` | DEFERRED_ONLY |
| STORY-005 | `518d2453` | CLEAN |
| STORY-006 | `b58afbe0` | DEFERRED_ONLY |
| STORY-007 | `73cbdbfe` | DEFERRED_ONLY |
| STORY-008 | `e636b303` | DEFERRED_ONLY |
| STORY-009 | `84a3c4b4` | DEFERRED_ONLY |
| STORY-010 | `32f6a085` | DEFERRED_ONLY |
| STORY-011 | `e346e147` | DEFERRED_ONLY |
| STORY-012 | `e9519243` | DEFERRED_ONLY |
| STORY-013 | `ca811a29` | DEFERRED_ONLY |

All 13 carry a passing story-level verdict. No story verdict is reopened here.

## Cross-story contracts verified PASS

| Contract | Evidence | Result |
|---|---|---|
| Drift schema ladder | `mobile/lib/core/database/cupid_database.dart:86,112-167` — `schemaVersion = 10`, one additive step per story version, sibling (not chained) `if`s for the v3/v4/v5 column groups, STORY-013's v7→v9 renumber documented at lines 104-106 | PASS — 19 tables, every table reachable from exactly one `from < N` branch; no two stories claim one version |
| Generated client parity | `cupid_database.g.dart:8665-8687` `allSchemaEntities` lists the same 19 tables + 2 indexes as the `@DriftDatabase` annotation at `cupid_database.dart:48-79` | PASS — codegen is current with the merged table set |
| Foreign-key integrity | `cupid_database.dart:172-174` `beforeOpen` sets `PRAGMA foreign_keys = ON` | PASS |
| DI registration | `service_locator.dart` — 78 registrations, all distinct types; every REQ-016 repository/service/cubit registered once | PASS — no duplicate or conflicting registration across the 13 stories |
| Navigation shell | `pair_gate_shell.dart:84-97,133-147` — one `SessionTerminationListener` + one `ReminderOverlayHost` wrap the gated tree; unpaired branch resolves to solo `HomeScreen` with `_soloPairingStatus` pinned (lines 127-138) | PASS — single mount point, no double-mount from parallel stories |
| Android widget host | `AndroidManifest.xml` receiver `com.snapsofts.cupid.CupidPhaseWidgetProvider` + `@xml/cupid_phase_widget_info`; backup attributes added alongside | PASS |
| Vector drawable validity | `res/drawable/dot_today_bolt.xml` — valid XML, no `--` inside the comment body, single closed path, no hard-coded tint | PASS — the earlier build-breaking form is gone from this branch |
| Notification permission surface | `local_notification_scheduler.dart:19-20` uses `AndroidScheduleMode.inexactAllowWhileIdle`, so no `SCHEDULE_EXACT_ALARM`; manifest diff adds no new `<uses-permission>` | PASS — deliberate inexact scheduling, no undeclared permission |
| Content pack assets | 23 `*.v1.json` under `mobile/assets/data/req016/`, declared as a directory in `pubspec.yaml:104-105` | PASS — directory form covers every story's pack, no per-file omission possible |

## Blocking findings

### F-I1 — BLOCKING: leaving stage 1 does not delete the portrait or the compatibility results (STORY-013 AC-26)

`Stage1WipeRegistry.tables` (`mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart:67-137`) registers **11** tables. The schema holds **14** REQ-016 tables (19 total − 5 server-authoritative caches). Unregistered:

- `portrait_answers` — STORY-009, owner column `ownerKey` (`tables/portrait_answers_table.dart:18`)
- `relationship_labels` — STORY-010, owner column `ownerKey` (`tables/relationship_labels_table.dart:29`)
- `calendar_event_state` — owner column `ownerKey` (`tables/calendar_event_state_table.dart:14`)

Why this is an AC violation, not a style gap:

1. `Stage1WipeService.wipeAll()` iterates **only** `_registry.tables` (`stage1_wipe_service.dart:51-56`). There is no second deletion path for these three tables anywhere in the service.
2. STORY-013 **AC-26** (`STORY-013_graceful_exit_and_return/requirements/requirements.md:248-251`) enumerates what must be deleted and names `chân dung` and `kết quả ăn khớp` explicitly. Those are exactly `portrait_answers` (STORY-009 "Chân dung theo cách BẠN nhìn") and `relationship_labels` (STORY-010 "Bảng tra ăn khớp").
3. **AC-27** (lines 253-255) forbids any residue on the device after the wipe. All three tables are described as device-authoritative in the migration notes (`cupid_database.dart:101-104`) — there is no server copy and no other cleanup path, so the rows simply survive.
4. The registry's own doc comment (lines 47-53) claims completeness and points at the parity test as the tripwire.

Static confirmation that the tripwire is red (no test run needed — the counts are arithmetic): `stage1_wipe_registry_parity_test.dart:52-65` compares `registeredTables()` against `expected` and separately asserts `expect(expected, hasLength(14))`. Registered is 11.

Per reviewer rule 14, exact AC text controls: for `portrait_answers` and `relationship_labels` this is an AC-26 `FAIL`, **not** an open design question. The earlier "needs a cross-story PO/Tech-Lead decision" framing (`STORY-007/review/review-report.md:129-137`, `scrum-master-checkpoint.md:99-105`) was correct at story level and is now resolved by AC-26's own wording for two of the three tables. Only `calendar_event_state` remains genuinely undecided, because AC-26's `trạng thái bộ đếm` does not unambiguously refer to it.

This is NEW evidence relative to the handoff's "confirmed non-blocking" note: the non-blocking finding was scoped per story, and no story review checked the registry against AC-26's enumerated list.

Action items:

1. **[mobile-dev]** Register `portrait_answers` and `relationship_labels` in `Stage1WipeRegistry.tables` using the existing `_ownedBy(...ownerKey)` helper. Both are parentless, so ordering is unconstrained. Mechanical change, ~6 lines.
2. **[product-owner OR tech-lead]** Decide `calendar_event_state`: register it, or add it to `nonReq016Tables()` in the parity test with the one-line reason the test's own comment (lines 35-39) requires. Do not leave it unregistered and unexcluded.
3. **[mobile-dev]** Re-run `flutter test test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` and record the result; after (1)+(2) the `hasLength(14)` assertion and the set comparison must agree.
4. **[mobile-dev]** Re-label the residue evidence in `STORY-013/coding-plan/test-results.md` to cover the newly registered tables, so AC-26/AC-27 coverage names all 14.

### F-I2 — BLOCKING: requirement-level closure gates have no evidence

`data/requirements/REQ-016_solo_stage1_relationship_assistant/integration-review/` held no files before this review, and `req_master.md` records no `Integration-Verify: WAIVED` line.

- Reviewer rule 12g3: the merged branch needs `## Integration Build & Runtime` with both `- Build: PASS — <command + result>` and `- Runtime/Smoke: PASS — <command + result>` in one file. Absent.
- Reviewer rule 12g2: the requirement-level `integration-review/mobile-visual-audit.md` cross-screen check remains separately blocking before closure. Absent.

This is expected at this point in the sequence — the handoff states a separate integration-verification pass follows, and this review is read-only by instruction. It is recorded as blocking because the DONE gate enforces both independently and the requirement cannot close until they exist.

Action items:

5. **[devops or mobile-dev, integration-verification pass]** Produce `## Integration Build & Runtime` in the integration-review directory with a real build command + result and a real app-launch smoke result on the merged branch. `Runtime: NOT_APPLICABLE` is not a pass.
6. **[mobile-dev]** Produce `integration-review/mobile-visual-audit.md` for cross-screen navigation/shell/consistency. Per-story `visual-fidelity/` evidence does not substitute.

### F-I3 — BLOCKING (low severity): configuration guide is incomplete and one statement is now inaccurate

`deployment/configuration-guide.md` documents STORY-012's widget host configuration thoroughly, but the requirement added three dependencies (`pubspec.yaml` diff base..HEAD): `home_widget`, `flutter_local_notifications`, `timezone`. Only `home_widget` is covered.

- No section covers the local-notification setup this requirement introduced: `local_notification_scheduler.dart` initialization (`:65-67`), the iOS permission request path (`:111`), or the `timezone` database usage (`:150-153`, scheduling in `tz.UTC`).
- Lines 120-125 state the three `<uses-permission>` entries predate the requirement and that `POST_NOTIFICATIONS` is "the Android 13+ runtime permission the reminder surface uses, not the widget." The permission does predate REQ-016, but this requirement added a second consumer of it in `features/phase_status/` — the same feature the guide is about. A reader following this guide would conclude no notification setup belongs to REQ-016.

Per reviewer rule 12a, stale or missing setup guidance for delivered scope is `PATCH_REQUIRED`.

Action item:

7. **[devops]** Add a local-notification section (init, iOS permission request, timezone init, the deliberate `inexactAllowWhileIdle` choice and why no `SCHEDULE_EXACT_ALARM` is declared) and correct lines 120-125 to name `features/phase_status/` as a `POST_NOTIFICATIONS` consumer added by this requirement.

## Deferred findings and residual risks

- **D-I1 — integration branch is behind `main` by 20+ commits, and its `req_master.md` registry is stale.** `git merge-base --is-ancestor main HEAD` is false; `main` carries `4882303b`, `b9827099`, `323f4666`, `0d824386`, `4108ac86`, `d7137e1e` and others that never synced in (last sync was `5fba81eb`, before the STORY-011/STORY-012 merges). Consequently this branch's `req_master.md:251-263` still shows STORY-005/007/008/010/011/012/013 as `TODO` while merge-boundary state says all 13 are `MERGE_COMPLETE: true`. The registry table is a mirror, so this is not a code defect — but Scrum Master should sync `main` into the integration branch **before** the final merge so the registry-sync commits already on `main` are not re-conflicted or reverted. Not fixed here: `req_master.md` is outside this review's write scope.
- **D-I2 — the v3→v10 migration ladder has no green migration-test evidence at integration level.** `BUG-20260923-001` tracks 11 reds in `test/core/database/`. The ladder reads correct on inspection (see Cross-story contracts), but the persistence gate's primary proof is owed. The integration-verification pass should confirm these 11 reds are version-number lag only, not a real migration break, before closure.
- **D-I3 — STORY-007 AC-3 wording question** (`ThankYouBlockCubit.resolve()` consumes at `initState` rather than at scroll-into-view) stays open for PO as recorded; not re-litigated, no new evidence found.
- **D-I4 — STORY-013 F2**: the three J13 return destinations all land on `PairGateShell` (`return_screen.dart:67-78`) rather than the three distinct destinations in `ux/uiux-spec.md` §6. Confirmed unchanged on the merged branch; stays deferred per the story review's AC-22 reasoning.
- **Open bugs confirmed still non-blocking for closure**: `BUG-20260907-001`, `BUG-20260908-001`, `BUG-20260923-001` (see D-I2), `BUG-20260923-002`, `BUG-20260924-001`. None of them touches the F-I1 defect, and none was made worse by the integration merges.
- `stage1_wipe_registry_parity_test.dart` is no longer classified as a benign pre-existing red at this level — it is the tripwire for F-I1 and must go green as part of that patch.

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Status |
|---|---|---|
| persistence/schema/migration | additive monotonic ladder to v10, generated client parity | PASS on inspection; migration-test proof owed (D-I2) |
| data migration/backfill (deletion) | stage-1 wipe deletes everything stage 1 owns (AC-26/AC-27) | **FAIL — F-I1** |
| typed/generated contract | `.g.dart` matches merged table set | PASS |
| runtime/configuration | DI completeness, no conflicting registration | PASS |
| mobile navigation/discoverability | single shell mount, solo entry point | PASS |
| package-dependencies | merged `pubspec.yaml` resolvable, no undeclared platform requirement | PASS |
| operational command / platform build | Android widget receiver + resources, iOS extension contract documented | PASS |
| requirement closure — build + runtime | `## Integration Build & Runtime` | **MISSING — F-I2** |
| requirement closure — cross-screen visual | `mobile-visual-audit.md` | **MISSING — F-I2** |
| setup/configuration documentation | configuration guide matches delivered scope | **STALE — F-I3** |

## Traceability

- Merged stories and merge refs: table above; ground truth is `git-story-boundary.sh status` per the handoff, not `req_master.md` (see D-I1)
- Story review reports: all 13 read for their verdict line; STORY-007 (`:125-149`, `:205-223`) and STORY-013 (`:105-199`) read in detail for the cross-story wipe-registry history
- Requirement artifacts: `req_master.md` (`## User Stories`, `Integration-Verify` query), `scrum-master-checkpoint.md` (`:94-126` open items), `STORY-013/requirements/requirements.md:248-277` (AC-26..AC-32)
- Cross-story source inspected: `cupid_database.dart`, `cupid_database.g.dart` (ranged), `service_locator.dart` (registration query), `pair_gate_shell.dart`, `stage1_wipe_registry.dart`, `stage1_wipe_service.dart` (query), `local_notification_scheduler.dart` (query), 3 table definitions (query), `pubspec.yaml`, `AndroidManifest.xml` diff, `dot_today_bolt.xml`
- Test evidence: `stage1_wipe_registry_parity_test.dart` read in full and evaluated statically; no test was executed by this review (read-only by handoff instruction)
- Configuration: `deployment/configuration-guide.md` read in full (169 lines)

## Requirement state recommendation

- Requirement status: `IN_PROGRESS` — do NOT mark `DONE`
- Route action items 1-4 (F-I1) to the mobile lane, with item 2 needing a PO/Tech-Lead decision first
- Route action items 5-6 (F-I2) to the integration-verification pass already planned
- Route action item 7 (F-I3) to DevOps
- Sync `main` into the integration branch before the final merge (D-I1)
- Re-review scope after the patch: `stage1_wipe_registry.dart`, the parity test result, the configuration guide section, and the two new integration-review evidence files. The nine PASS rows above do not need re-verification unless the patch touches the schema or DI.
