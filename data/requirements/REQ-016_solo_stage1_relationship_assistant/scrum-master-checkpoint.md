# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-08 (session 798d014f, continue parallel wave, STORY-001 rule-12g
real-DI startup smoke RAN and found a genuine cold-start defect —
`BackendUserIdStore` has no persistence, blocking checks 2 (migration) and 4
(P6 detail reachability). Evidence COMMITTED (`f7ab1ad`). P9 itself confirmed
working (check 3 PASS). Routing to Tech Lead for an architecture ruling on
backendUserId rehydration.)
Requirement Status: IN_PROGRESS.

**STORY-003 is DONE and merged** (`69b3690` into
`codex/REQ-016_solo_stage1_relationship_assistant-integration`, review
`Outcome: DEFERRED_ONLY`, `story_master.md Status: DONE` committed `d0fca25`
on the integration branch). STORY-001 is the only story still in flight.

All phase-by-phase history through STORY-001 P7 and STORY-003 P5 is DONE,
committed, and superseded by artifacts — do not replay it here. Closed bugs:
`BUG-20260907-002` (DONE). Open, non-blocking bugs:
`BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
`BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
warnings) — cite either instead of re-running the repo-wide command.

## Story Graph (from `requirements/requirements.md` -> `## Story Order And Dependencies`)

| Story | Depends On | Story-Class |
|---|---|---|
| STORY-001 | NONE | shared-foundation |
| STORY-002 | STORY-001 | standard |
| STORY-003 | NONE | standard (DONE, merged) |
| STORY-004 | STORY-001 | standard |
| STORY-005 | STORY-001, STORY-004 | standard |
| STORY-006 | STORY-001 | standard |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | standard |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | standard |
| STORY-009 | STORY-004 | standard |
| STORY-010 | STORY-004 | standard |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | standard |
| STORY-012 | STORY-001 | standard |
| STORY-013 | STORY-001, STORY-004 | standard |

STORY-001 is shared-foundation: must reach `MERGE_COMPLETE` before
STORY-002/004/006/012 (and transitively 005/007/008/009/010/011/013) become
schedulable. Only STORY-001 is currently in flight; all others wait on it.

## KNOWN MERGE COLLISION (hits when STORY-001 merges — STORY-003 already merged clean first)

Two things to reconcile at STORY-001's merge into
`codex/REQ-016_solo_stage1_relationship_assistant-integration`, both in
`mobile/lib/core/database/cupid_database.dart`. Scrum Master resolves both
directly at merge time (Git-orchestration rule — do not delegate):

1. **Migration branch**: STORY-001 P1 and STORY-003 P1 each independently
   bump `schemaVersion` 2->3 with their own additive `onUpgrade` branch.
   Combine both `if (from < 3)` branches into one, keep schemaVersion at 3,
   re-run each story's own migration test against the combined schema.
   (STORY-003's hardcoded-literal fix already in `fcc5066`; STORY-001's
   worktree copies already assert `3`, confirmed no fix needed there.)
2. **Constructor signature**: STORY-003's patch2 (`1c32341`, merged in
   `69b3690`) added a SECOND positional constructor parameter to
   `CupidDatabase` — `BackupExclusion? excludeFromBackup`. STORY-001 does
   not know about this. Reconcile STORY-001's own `CupidDatabase`
   constructor edits (if any) against this signature, and check
   `service_locator.dart`'s call site on both sides.

Non-blocking: STORY-001 P5 and STORY-003 P5 both touch
`mobile/lib/l10n/app_vi.arb`/`app_en.arb` for different keys — fine, just
don't collapse their arb edits into one commit at merge.

## STORY-003 (DONE, reference only)

Merged `69b3690`. Full history in `STORY-003_private_journal/review/` and
`coding-plan/` artifacts — do not replay it here or re-litigate any item.

## STORY-001 — review DONE, now in patch round

The 8-pass slice review (S1-S8, `story-state:STORY-001` lock) is fully
complete and committed. **Do not re-read `review/slice-1..7-*.md` or
re-litigate any slice finding** — the canonical, complete, cross-checked
synthesis is `review/review-report.md` (committed `e3a504f`,
`Outcome: PATCH_REQUIRED`). That file is the single source of truth for
all findings, owners, and the patch/re-review plan. Read it directly for
any finding detail; do not reconstruct from this checkpoint.

**Summary for routing purposes only** (full detail in `review-report.md`):
6 blocking findings — B-1 (mobile-dev: hub mounts neither P5 nor P6,
FLAG-2, confirmed independently by 4 slices), B-2 (mobile-dev + tech-lead:
no post-creation field-write path, FLAG-1, AC-15 violated), B-3 (sequencing
constraint: B-1+B-2 must land together), B-4 (mobile-dev: 3 red tests this
story caused, misfiled as pre-existing), B-5 (mobile-dev: visual-fidelity
FAIL stands, quick-entry strip renders empty boxes — same root as B-1),
B-6 (product-owner + mobile-dev: occasion content expires 2027-12-24,
dead invitation affordance after — cheapest closure is a PO durable
refresh-owner record, OR mobile-dev adds a conditional render in the
patch). Two rulings needed: R-1 (product-owner: is the inert *Đã hẹn ngày*
CTA acceptable under AC-11 — does NOT block current patch sizing, only
adds scope if PO later requires more) and R-2 (scrum-master + tech-lead:
is rule 12g real-DI startup smoke required or `NOT_APPLICABLE`).

**Scrum-Master routing decision (role-boundary constraint)**: Product
Owner and UI/UX Designer are backlog-shaping roles this session may not
spawn directly (`role-map.md` — only `brainstormer` spawns them). R-1 is
therefore left OPEN/deferred (does not block B-1..B-5's patch — see
above); B-6 is being closed via mobile-dev's offered code alternative
(conditional render) instead of the PO durable-record path, to stay
within role boundaries. R-2 is routed to Tech Lead (a normal delivery
role) together with B-2's contract-design amendment, per `review-report.md`
routing instructions.

**Tech Lead patch-plan DONE** (committed `4940e26`). R-2 ruling:
**REQUIRED** — real-DI startup smoke (`scripts/run-mobile.sh`, real
`main.dart`, DB v2->v3 upgrade on an installed schema, unpaired session ->
solo hub -> P6 detail) must run once at the end of this patch round;
`master-plan.md` §4/§6 old `NOT_APPLICABLE` was wrong, now fixed. B-2
contract design: new **P8** phase (`Depends On: P2, P6`, ~7 files, full
spec in `master-plan.md` §7) — `updateCardDetails(cardId, ActivityCardEdit
edit)` full-snapshot write (never touches id/owner_key/status/origin/
created_at, bumps updated_at, returns row count); `ActivityCardEdit` (11
fields) + `.from(card)` factory; `updateStatus`/`clearScheduledDate` change
`Future<void>`->`Future<int>` (closes S2-F2-3). Two existing tests
(`card_lifecycle_ui_test.dart:266-278`, `:127-138`) currently certify the
AC-15 defect as correct and must be rewritten as part of P8, not treated as
optional. Tech Lead explicitly did NOT bundle S2-F2-1 (photos) into P8 —
reassigned to STORY-007 (§7.8: no STORY-001 AC needs photos, table+DAO
already exist from P1, keeps P8 to one specialist lifecycle). B-3
constraint is now a hard line in `master-plan.md` §5: P8 and the P4/P6
patches must merge together, not separately.

**mobile-dev patch round 2 DONE and COMMITTED** (`c92fd1b`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-mobiledev-patch1`,
`Alex-Mobile-Dev-2@session-798d014f`, `completion_marker:
MOBILE_PATCH_COMPLETE: NO` because one item is open — see blocker below;
all 6 bundled findings otherwise CLOSED). Evidence: `flutter analyze lib
test`: 0 errors; scoped suite (`activity_cards`, `home`, `core/navigation`):
+230 ~3, 3 skipped, 0 red; full suite: +1880 ~4 -21, all 21 failures
IDENTICAL to baseline `4940e26`'s known-failure set (net -3 red fixed, 0
new red); `app_shell_test.dart`: 11/11 (was +8 -3 at BaseHead); `flutter
build apk` v3: exit 0. WriteScope extensions granted this round (recorded
as `scope_extension_1`/`scope_extension_2` in the RunState file):
`minute_one_empty_state.dart`+test (B-6's real host widget), plus 5 more
`ActivityCardRepository` implementer files forced by P8's interface change
(verified via grep: exactly 8 implementers exist). Do not re-read the full
dispatch prompt or RunState scope-extension detail — already verified and
folded in here.

**`SOLO_HUB_UNREACHABLE_IN_REAL_DI` — Tech Lead ruling DONE and COMMITTED**
(`a6ec7fa`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-techlead-patch2`,
`Alan-Techlead@session-798d014f`, `completion_marker:
TECHLEAD_PATCH_COMPLETE: YES`). Ruling: **IN_SCOPE for STORY-001** — new
phase **P9** (`phase-P9-unpaired-root-to-solo-surface`) spec'd in
`master-plan.md` §8. R-2 stays REQUIRED; the prior on-device rule-12g run
is relabelled `INVALID-FOR-GATE (pre-P9)` (must re-run after P9 lands, does
not count against the story as-is).

**P9 spec summary** (full detail in `master-plan.md` §8, do not re-read in
full — this is the complete routing summary): single source file
`mobile/lib/core/navigation/pair_gate_shell.dart`. In `_AppShellView.build`,
change exactly one switch arm: `PairGateUnpaired() =>
HomeScreen(resolvePairingStatus: _soloPairingStatus)` with a new static
`_soloPairingStatus() async => PairingStatus.unpaired` in the same file.
The other three arms (`PairGateChecking`, `PairGateNetworkError`,
`PairGatePaired`) stay untouched. Must pin the value (not let `HomeScreen`
self-resolve via `CouplePairingStore`) because that store is a second,
independent source of truth that can return `PairingStatus.unknown` and
would incorrectly route to the couple dashboard inside an unpaired session
(`home_screen.dart:406-409`) — this is the exact bug class P9 must add a
regression test for. After the switch, clean up now-dead
`_router`/`_createInviteCubit`/`_createJoincodeCubit` fields strictly
following `flutter analyze` output (don't pre-emptively remove). Required
test changes: `mobile/test/core/navigation/chain_tail_edges_test.dart` and
`mobile/test/app/cupid_app_entry_routing_test.dart` must assert
`Key('solo_stage_one_shell')` `findsOneWidget` and
`Key('home_screen_ready_signal')` `findsNothing`; add one new regression
test for the `CouplePairingStore.unknown`-fallback hazard;
`pair_gate_cubit_test.dart` and `pairing_choice_screen_test.dart` stay
unchanged (onboarding's pairing entry point is untouched — P9 removes only
the *second*, redundant wall at app-root re-entry, not the pairing
onboarding node itself). Forbidden: touching `home_screen.dart`'s solo
branch/tab bar/`ActivityCardHubView` (D-3 visual fidelity is locked),
`schemaVersion`/migrations, `onboarding_chain.dart`, or
`PairGateNetworkError` behavior (a known separate gap, not in scope — see
§8.10: unpaired+offline still can't reach the local card store, that's a
future requirement-level item, not P9's). ~5 files total. Non-blocking OQ
for PO (not a P9 blocker): should new-install users be able to skip
`OnboardingNode.pairingChoice`.

**mobile-dev P9 partial DONE and COMMITTED** (`cfde25c`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-mobiledev-p9`,
`Alex-Mobile-Dev-3@session-798d014f`, `completion_marker:
MOBILE_PATCH_COMPLETE: NO`). §8.4/§8.5 destination pin implemented exactly
as spec'd (verified against real diff: `pair_gate_shell.dart`,
`cupid_app_entry_routing_test.dart`, new `pair_gate_shell_test.dart` —
matches WriteScope). Evidence: `flutter analyze` clean (11 pre-existing
info-level items only); `pair_gate_shell_test.dart` 2/2,
`cupid_app_entry_routing_test.dart` 7/7, `chain_tail_edges_test.dart` 3/3
(left unedited, confirmed not required), `app_shell_test.dart` 11/11
(required check, no regressions). `service_locator.dart` also left
unedited (confirmed not required).

**BLOCKED on a P9 spec self-conflict, routed to Tech Lead**
(`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-techlead-patch3`,
`Mode: compact-story-plan`, BaseHead `cfde25c` = worktree HEAD after the
P9-partial commit) — IN FLIGHT. `mobile/test/features/pairing/presentation/
pair_gate_cubit_test.dart`'s `PairGateShell gate (AC4)` widget group
(forbidden to touch by §8.7 rule 4) hard-asserts the OLD `pairing_stack`
destination that §8.4 intentionally changes to `HomeScreen`; that group
plus 2 dependent JoincodeScreen tests now fail as a direct, unavoidable
consequence (the 7 pure `PairGateCubit` state tests in the same file are
unaffected and still pass). §8.4/§8.5 (change destination) and §8.7 rule 4
(forbid touching the one file hard-asserting the pre-change destination)
contradict each other for this one test group. Tech Lead asked to either
(1) carve out that group from rule 4 and specify the new
assertion/WriteScope extension, or (2) find an alternative production
approach if the AC4 group encodes a still-required invariant. Completion
marker: `TECHLEAD_PATCH_COMPLETE`. WriteScope: `master-plan.md` only.

**Tech Lead §8.11 ruling DONE and COMMITTED** (`29bc54f`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-techlead-patch3`,
`completion_marker: TECHLEAD_PATCH_COMPLETE: YES`). Ruling: narrow §8.7
rule 4, keep §8.4/§8.5 as-is. Full re-audit of the AC4 group found 5 broken
tests (mobile-dev's report only found 3), plus a second broken group in a
different file mobile-dev's report never touched. Full detail in
`master-plan.md` §8.11 — do not re-read in full, this is the complete
routing summary:

- `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`,
  group `PairGateShell gate (AC4)` (lines 202-348 pre-patch): the 7 pure
  `PairGateCubit` state tests (lines 112-200) stay untouched. Within the
  AC4 group: **fix** "unpaired routes into the pairing stack..." (203-228)
  and "a non-network failed check falls back to the pairing stack"
  (338-347) to assert `find.byKey(const Key('solo_stage_one_shell'))`
  `findsOneWidget` + `find.byKey(const Key('home_screen_ready_signal'))`
  `findsNothing` instead (drop the `createCodeRowKey` -> `InviteScreen` tap
  in the first one; rename the second to match, e.g. "...falls back to the
  solo surface (fail-safe)"). **Delete outright** (not fix): "They already
  have a code..." (230-246), "Scan the QR..." (248-264), "accepting a code
  via '...' navigates through to PairedScreen" (266-293) — all three
  depend on the PairingChoiceScreen/InviteScreen/JoincodeScreen path
  through `PairGateShell`, which §8.6's dead-code removal makes not just
  unreachable but non-compiling; their coverage already exists directly in
  `pairing_choice_screen_test.dart:99-121`. **Keep unchanged**: "paired
  routes..." (295-308), "network error..." (310-336).
- `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  (newly found, not in mobile-dev's original report): **delete** the
  group `'AC4/AC5 back edges from the unpaired pair gate'` (154-190) and
  its helper `_gateHarness()` (200-223) entirely — same structural failure
  (builds `PairGateShell` against the old destination/dead keys). No
  product coverage lost: `PairingChoiceScreen`'s own `_harness()`
  (85-121) already covers all three create/enter/scan edges directly.
  Remaining gap (back-edges when entered via the onboarding chain) is a
  real but out-of-P9-scope item (§8.8 forbids touching
  `onboarding_chain.dart`) — recorded like §8.10, not a blocker.

**`BACKEND_USER_ID_STORE_COLD_START` — rule-12g smoke BLOCKED, routed to
Tech Lead** (evidence committed `f7ab1ad`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-mobiledev-p9b`
carried the dispatch; smoke itself ran via `Alex-Mobile-Dev` teammate
continuation, not a fresh RunId — see full evidence at `coding-plan/
test-results.md`, do not re-read in full, 74KB, this is the routing summary).
Ran on a real device, real `main.dart`, real backend, freshly-registered
account, seeded v2 SQLite DB, at HEAD `93ff105`. Check 1 (no startup
exceptions) PASS. Check 3 (unpaired session lands on solo hub, 4-tab bar)
PASS — **confirms P9's own fix is effective in production routing; this is
NOT a P9 regression**. Check 2 (v2->v3 migration observed) FAIL — DB never
opened. Check 4 (P6 detail reachable) FAIL — hub stuck in Minute-1
permanently, card creation throws unhandled.

Root cause (observed via stack trace, not inferred):
`core/realtime/backend_user_id_store.dart`'s `BackendUserIdStore` holds
`_backendUserId` in memory only, populated solely at login time
(`AuthRepository.signInWithEmail`/`verifyOtp`/`_syncBackendProfile`, and
`chat_partner_store.dart:57`). Nothing rehydrates it on cold start.
`ActivityCardRepositoryImpl._requireOwnerKey()`
(`activity_card_repository_impl.dart:164`) throws `StateError` on an empty
key, so every repository call fails for a returning user:
`ActivityCardListCubit.load()` always sees 0 cards (hub always renders
Minute-1 regardless of stored data), `createCard` throws unhandled
(`minute_one_empty_state.dart:167`), and Drift never opens `cupid.sqlite` —
which is why the v2->v3 migration is unmeasurable, not because the
migration branch itself (`cupid_database.dart:46/60`) is wrong. This
reproduces the identical state of a normal app relaunch after login, not a
fixture artifact — every returning user hits this today.

Not patched (verification-only round, `backend_user_id_store.dart` and the
session-restore path are outside WriteScope). Fix requires an architecture
decision: hydrate from `GET /users/me` at startup, persist `backendUserId`
directly, or reuse the `cupid_user_id` already in SharedPreferences. Routed
to Tech Lead (`Mode: compact-story-plan`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-techlead-patch4`)
for that ruling plus a spec for whichever approach it picks — IN FLIGHT.

**Note for future mobile-dev rounds on this story**: the `Alex-Mobile-Dev`
teammate that ran this smoke got wedged in its own build-evidence Stop gate
afterward (`flutter analyze lib test` exits non-zero on a proven pre-existing
repo-wide lint baseline — zero-diff at BaseHead, not caused by this
verification-only round; already tracked by `BUG-20260907-001`/
`BUG-20260908-001`, do not open a new bug for it). All findings were already
delivered via mailbox before the lock, so nothing was lost; the wedged
teammate was released via `TaskStop`. Dispatch the next mobile-dev round
(implementing Tech Lead's P10 spec) as a fresh spawn, not a continuation of
that name.

**mobile-dev final P9 patch round DONE and COMMITTED** (`93ff105`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-mobiledev-p9b`,
`Alex-Mobile-Dev-2@session-798d014f`, `completion_marker:
MOBILE_PATCH_COMPLETE: YES`). Both diffs independently verified line-by-line
against Tech Lead's §8.11 ruling before commit (not just trusted from the
self-report): `pair_gate_cubit_test.dart` — all 7 AC4-group dispositions
matched exactly (2 fixed with `solo_stage_one_shell`/
`home_screen_ready_signal` assertions, 3 deleted, 2 kept unchanged), plus the
new `_registerActivityCardRepository()` helper; `pairing_choice_screen_test.dart`
— confirmed the `'AC4/AC5 back edges from the unpaired pair gate'` group and
`_gateHarness()` helper were deleted with no other changes (73 removed, 0
added). **P9 (phase-P9-unpaired-root-to-solo-surface) is now fully CLOSED.**
Specialist-reported evidence (not yet independently re-run by Scrum Master):
`pair_gate_cubit_test.dart` scoped suite pass, `pairing_choice_screen_test.dart`
pass, `flutter analyze` clean. Two out-of-scope gaps recorded for later
requirement-level triage, not blockers: unpaired+offline still can't reach
the local card store (§8.10), and back-edges entered via the onboarding
chain (vs. via `PairGateShell`) lost direct test coverage after the AC4/AC5
group deletion (§8.11 second finding).

**Next immediate step: re-run rule-12g's real-DI startup smoke**
(`scripts/run-mobile.sh`, real `main.dart`, DB v2->v3 upgrade on an installed
schema, unpaired session -> solo hub -> P6 detail) at worktree HEAD `93ff105`
— the prior on-device run is `INVALID-FOR-GATE (pre-P9)` per Tech Lead's
ruling and must be redone now that the hub is actually reachable. After it
passes, dispatch the scoped-slice re-review with BaseHead = `93ff105`.

**Do not trust a RunState `status` field without checking the actual
worktree diff first** for any code-writer completion. Wait for the real
teammate mailbox/SubagentStop notification, then verify `git status`/`git
diff` matches the declared WriteScope before committing or trusting a
completion marker.

## Next Step On Resume

1. STORY-003: DONE, merged. No further action.
2. STORY-001: P9 fully CLOSED (`93ff105`). rule-12g smoke RAN and found a
   genuine cold-start defect (`BACKEND_USER_ID_STORE_COLD_START`, evidence
   `f7ab1ad`) — NOT a P9 regression, P9's own fix verified working. Dispatch
   Tech Lead (`Mode: compact-story-plan`) for a ruling + spec on
   `backendUserId` rehydration, then dispatch mobile-dev to implement it,
   then re-run the rule-12g smoke a third time at the new HEAD before
   treating R-2 as closed.
3. After rule-12g/R-2 is fully closed (pass or explicitly re-scoped),
   dispatch a **scoped-slice** re-review (NOT a
   full 8-pass re-run — `review-report.md`'s own recommendation: the patch
   touches `activity_card_hub_view.dart`, the repository contract pair,
   the P6 cubit, `app_shell_test.dart`'s DI helper, two lifecycle tests,
   plus now the P9 navigation/test changes; S1, S3, and P7-half-of-S2 need
   no re-review). New BaseHead = `93ff105`.
4. If that re-review returns `CLEAN`/`DEFERRED_ONLY` -> mark STORY-001
   `DONE` **inside the integration worktree**
   (`.ai-team-worktrees/cupid-apps/integration-REQ-016_solo_stage1_relationship_assistant`,
   not the control checkout — evidence guard needs the merged
   visual-fidelity report, which only exists there), run
   `git-story-boundary.sh complete`, then `git-story-boundary.sh merge`
   into the integration branch, resolving the KNOWN MERGE COLLISION above
   directly and re-running both stories' migration tests against the
   combined result.
6. Deferred/non-blocking: after STORY-001 merges, consider a
   `foundation`-mode Tech Lead pass to amend `system_architecture_memory.md`
   for ADR-007/ADR-010 discoveries, and to document `ContentPackage<T>`
   in `contract-summary.md` §2 (S3-F-3, bundled as tech-lead-owned deferred
   item in `review-report.md`).

## Do Not Re-read

- req_master.md, requirements/requirements.md (already loaded in full this
  session; reuse facts above).
- STORY-001 and STORY-003 story_master.md (already loaded/edited in full
  this session).
- `review/slice-1..7-*.md` — fully superseded by `review-report.md`, do not
  re-read any of them.
- Full phase-by-phase P1-P4/P7 history for either story, and STORY-003's
  full patch/re-review history — DONE, committed, captured by artifact
  pointers above, not restated here.
