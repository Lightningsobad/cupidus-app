---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "UNCHECK"
reviewed_at: 2026-09-08
reviewed_by: Reviewer
review_mode: "final-synthesis"
---

# Review Report: STORY-003 Nhật ký riêng

Outcome: PATCH_REQUIRED

This supersedes the prior `BLOCKED` / `REVIEW_SCOPE_TOO_BROAD` record. That
block was a review-dispatch refusal, not a defect verdict; the re-dispatch it
asked for (slices A–E) is complete and this pass issues the story-level verdict.

## Scope Gate (inline)

- Review type: `final-synthesis` (pass F of the A–E + F split recommended by the
  prior compact refusal).
- `review/scope-gate.md` exists with `Phase: SCOPE_GATE` /
  `SCOPE_GATE_COMPLETE: YES`, but it describes the superseded compact pass and
  its `Scope status: STOP`. It is outside this run's `WriteScope`, so it was not
  refreshed; this inline section is the scope of record for pass F.
- Inputs read: slice reports A–E, `visual-fidelity/visual-fidelity-report.md`,
  `story_master.md` (AC list), the prior `review-report.md`, three
  `visual-fidelity/*.png` frames, and two `coding-plan/test-results.md` presence
  queries (§"Missing gates"). No `mobile/lib` or `mobile/test` source file was
  opened in this pass.
- Every finding below is adjudicated from file:line evidence already recorded in
  a slice report. No slice report left an item `UNVERIFIED` that required
  re-opening implementation source.

## Verdict rationale

Three delivered defects and two missing mandatory gates keep this story out of a
passing outcome. The implementation quality is otherwise high and unusually well
evidenced — every AC has an executable assertion behind it, absences are enforced
by tests rather than asserted in prose, and two failure paths are fault-injected
rather than reasoned about. Nothing here suggests rework of the design; the
blocking set is a bounded patch round.

The two blocking data defects share one shape: the story protects entries
correctly at the DB row layer (owner-filtered DAO, no `deletedAt`, not a
`SessionScopedStore`) and then loses that protection at the layer above it —
once in the file system (F-B1) and once in the save gate (F-D1). Both destroy
user content the story exists to keep, without confirmation and without undo,
which is the exact inverse of AC-4's deliberate-deletion contract.

## Finding adjudication

| Id | Source | Verdict | Basis |
|---|---|---|---|
| F-B1 | slice B | **MUST-FIX** | Cross-account file deletion; breaks AC-2 and AC-5 |
| F-D1 | slice D | **MUST-FIX** | Silent overwrite of a saved entry; untested window |
| F-B3 | slice B | **MUST-FIX** | iOS journal text still reaches iCloud; Out-of-Scope line violated |
| F-VF1 | this pass | **MUST-FIX** | `VISUAL_FIDELITY` PASS token not supportable for P3 as written |
| F-G1 | this pass | **MUST-FIX** | No `## Story Runtime Startup Smoke` evidence (rule 12g) |
| F-G2 | this pass | **MUST-FIX** | No `## Entry Point Reachability` evidence section (rule 12e1) |
| F-B2 | slice B / R-D4 | DEFERRED | Reconciled below; F-D1 is its only live trigger |
| RA-9 | slice A | DEFERRED | Severity call accepted |
| D-B1 | slice B | DEFERRED | Cannot be closed until an iOS build is possible |
| F-C1 | slice C | DEFERRED | Hardening; row-count tests fail first |
| F-D2 + F-C3 | slice D / C | DEFERRED | Traceability only, no behaviour impact |
| R-D2 residual | slice D | DEFERRED | Composer lacks the import gate slice C's files have |
| O-E2 | slice E | DEFERRED | Pre-existing test drift, suite still green |
| contract-summary §2 | prior report | DEFERRED | Doc drift, tech-lead |
| R-D3 residual | slice D | DISMISSED | OS text-selection is a platform control, not an app affordance |
| RA-8 | slice A | NOT A STORY-003 DEFECT | Known cross-story merge item |
| RA-7 | slice A | CLOSED | Fixed at `fcc5066`, verified 15/15 green |
| F-C2 | slice C | CLOSED | Independently confirmed by slice E R-E3 |

## Blocking findings

### F-B1 — journal media root is not owner-scoped (owner: mobile-dev)

`journal_media_store.dart:80-91` + `journal_repository.dart:148-165`. The media
root is a flat device-wide `journal_media/<entryId>/`, with no owner segment,
while `sweepOrphans()` and `deleteAll()` receive owner-filtered input. Account B
opening the journal deletes account A's photo files; account B's "xoá toàn bộ
nhật ký" deletes account A's photos while leaving A's rows.

Blocking because the story asserts the opposite invariant in two places and
depends on it: `journal_entry.dart:57` names `ownerUserId` "the only isolation
between two accounts sharing one device", and `service_locator.dart:438-443`
deliberately declines session-scoped clearing so the journal survives sign-out
"because clearing it on sign-out would be permanent data loss". The file layer
reintroduces exactly that loss. AC-2 ("mục được giữ lại") fails for account A
after account B merely opens the feature; AC-5's reach is confirmed
independently by slice C.

Fix: put the owner in the path (`journal_media/<ownerUserId>/<entryId>/`) or
scope `sweepOrphans`/`deleteRoot` to the owner subtree. Add the two-owner test
slice B found missing — no current case exercises two owners at all.

### F-D1 — `isReady` never gates save (owner: mobile-dev)

`journal_composer_cubit.dart:52-53`, `:128`, `:130`;
`journal_composer_screen.dart:187`. `isReady` exists to mark that an edit-mode
entry has not been read back yet, and nothing consumes it — not `canSave`, not
the screen. With `autofocus: true` and an un-awaited `_loadExisting()`, one
keystroke before the readback emits enables save; the resulting `saveEntry`
overwrites the stored entry with the typed fragment.

Blocking on the loss, not the probability. AC-4 makes removal deliberate and
confirmed; this removes a kept entry with neither, and no test covers the window
(`journal_composer_cubit_test.dart` awaits `settle()` in every edit case,
`:101`, `:170`, `:200`). Slice D's suggested one-expression fix (`isReady &&
!isSaving && ...`) is accepted; it must land with a cubit test that calls
`bodyChanged` + `save()` before `settle()` and asserts the stored entry is
unchanged.

### F-B3 — iOS `cupid.sqlite` is not excluded from iCloud backup (owner: tech-lead decision, then mobile-dev)

`cupid_database.dart:75-76` places the DB in `NSDocumentDirectory`, which iOS
backs up by default. The story's iOS exclusion covers only the directories
`JournalMediaStore` creates (`journal_media_store.dart:93-97`), so journal
*text* — the primary private content of this story — still leaves the device.
Android excludes both halves (`backup_rules.xml:21-22`).

Blocking, and deliberately not deferred as legacy. `story_master.md:46-47` puts
"bất kỳ hình thức ... backup ra ngoài thiết bị mà người dùng không chủ động bật"
explicitly out of scope, and the same story treats the DB as in scope for the
Android side of this gate. Rule 7 (pre-existing → deferred) does not apply: the
DB file predates the story, but this story is what put private journal content
into it, so the story made it worse.

Accepted minimal fix: extend the already-delivered
`com.snapsofts.cupid/backup_exclusion` channel to tag `cupid.sqlite` plus its
`-wal`/`-shm` sidecars at DB open. Relocating the DB to Application Support is
the cleaner long-term shape but is cross-requirement and stays deferred. Apple's
"should not be used on user documents" guidance quoted at
`test-results.md:290-294` does not bar the minimal fix — `cupid.sqlite` is
app-internal state that happens to live in `Documents`, not a user document —
but Tech Lead should record that reading before mobile-dev applies it.

### Handoff correction on F-B3

The dispatch describes F-B3 as "carried forward per the compact review's own
instruction, not a new gap this pass created". Slice B contradicts this on
evidence and slice B is right: the carried-forward
`OS_BACKUP_EXCLUSION_UNVERIFIED` item concerned the iOS *media* mechanism, which
slice B records RESOLVED (`test-results.md:212-307`, vendor sources plus a
negative-controlled `swiftc -typecheck`). F-B3 is a different, newly visible
coverage asymmetry in the delivered configuration. It is adjudicated as a live
finding, not absorbed as carried-forward.

### F-VF1 — the P3 `VISUAL_FIDELITY` PASS token is not supportable as written (owner: mobile-dev + ui-ux-designer)

I opened `design-reference-s1:diary-ios.png` and `implemented-s1:diary-ios.png`
(rule 12e3 — verify by reading the images, not the verdict token). Both are real
frames of the same screen, the reference is the right screen, and the report's
three `DESIGN_SPEC_CONFLICT` items are correctly typed: each quotes the binding
clause (`uiux-spec.md:20-21`, `architecture/solution.md` §4) against the design
element, and the implementation is on the correct side of all three. That part
of the verdict holds, and those three must not be "fixed" toward the canvas.

What does not hold is `PASS` over the four remaining deltas, which are visible in
the two frames and carry no spec clause making the design wrong: the relative
date format, the missing privacy footnote card, single-vs-multiple thumbnails,
and the header background wash. Rule 12e2 admits no "cosmetic, non-AC-bearing"
tier — a visible difference with no conflict citation is a delta the verdict must
carry, and the report's own delta 1 shows the distinction is workable (compose
button placement IS spec-authorized, `uiux-spec.md:25` permitting both readings,
and is therefore fine).

One of the four is also an evidence ambiguity, not just a delta. The report
attributes the flat background to the implementation, but the P4 section records
that the composer frames were "wrapped in the app's own `CupidAppBackground` so
the frame carries the real shell background" while the P3 harness was not — and
the P5 device capture shows the real shell gradient. So the P3 frame cannot
distinguish "the list screen has a flat background" from "the P3 capture omitted
the shell wrapper". That has to be resolved before any background verdict means
anything.

Resolution (either is acceptable): ui-ux-designer records explicit spec
authorization for each of the four, after which the verdict stands as written;
or mobile-dev closes them toward the reference. Re-capture P3 with the same
`CupidAppBackground` wrapper P4 used, so the background question is answered
rather than inherited.

P4 and P5 are accepted as recorded. P4's `DESIGN_SOURCE_NOT_DETECTED` is an
honest detection outcome with no borrowed frame, and the P4 dispatch correction
(`s1:diary` is the Stage-1 solo family, re-derived from both canvases) is
sound. I opened `implemented-me-tab-private-journal-row-emulator-5554.png`: a
real device frame of the Tôi tab, "Kho riêng của tôi" block with the mint lock
badge and the "Nhật ký riêng" row, positioned under the profile card and above
the settings card exactly as the design markup places it. No error screen, no
splash frame, no wrong screen.

### F-G1 — no story runtime startup smoke evidence (owner: mobile-dev)

Rule 12g makes registry-backed runtime startup smoke a mandatory story-level gate
for a `mobile` lane story, waivable only by a `Runtime-Smoke: WAIVED` line in
`story_master.md`. `coding-plan/test-results.md` contains no `Smoke` and no
`Runtime` heading (queried directly this pass, 0 matches each), and
`story_master.md` carries no waiver. For mobile the gate is that the app
LAUNCHES and reaches its first screen without a crash or error screen.

The P5 device capture does not satisfy it: that build is `lib/main_preview.dart`
with `--dart-define=PREVIEW=me --dart-define=PREVIEW_ME_FIXTURE=true`, which is
the preview entry point with a faked profile, not the real `main()`. A `main()`
that fails to initialize is precisely the failure mode a preview-entrypoint
capture cannot see. Supply the real-app launch evidence.

### F-G2 — no entry point reachability evidence section (owner: mobile-dev)

Rule 12e1 requires `coding-plan/test-results.md` to record an
`## Entry Point Reachability` section with `Reachable: YES` and the concrete
path; the file has no such heading (queried this pass, 0 matches).

The entry point itself is real and independently verified — slice E confirmed
`me_screen.dart:560` → `openJournalScreen(context)` →
`MaterialPageRoute` (`journal_entry_point.dart:81-89`), with
`me_screen_journal_row_test.dart` asserting `find.byType(JournalScreen)` after
the tap and `find.byType(TabBar), findsNothing` on the pushed route. So this is
the evidence section missing, not the capability. Cheap to close, but 12e1 makes
a missing section `PATCH_REQUIRED` on its own.

## Deferred findings

- **F-B2 / R-D4 reconciliation.** These describe one defect class from two
  angles, and they reconcile cleanly: the store/repository layer does leak files
  on photo replacement (`journal_repository.dart:117-122` replaces photo rows
  without deleting files; `sweepOrphans` is directory-granular only,
  `journal_media_store.dart:86-90`), and the composer compensates at the call
  site (`journal_composer_cubit.dart:176`, `:240`, `:255-263`) with a test that
  asserts the dropped file is gone from disk, not merely dereferenced
  (`journal_composer_cubit_test.dart:182-208`). Slice D's `PASS` is correct for
  the normal edit path. The residue is bounded (recursive `deleteEntryDir`
  reclaims it when the entry is deleted) and its only live trigger is F-D1, which
  is must-fix above. Deferred as hardening: the invariant currently lives in the
  caller, so a second future caller of `saveEntry` re-introduces it. Worth moving
  into `saveEntry` or into a file-granular sweep when that second caller appears
  (STORY-007/008 are the likely ones).
- **RA-9** — missing indexes on `watchEntries` and `journal_photos.entryId`.
  Severity call accepted: an on-device single-user journal has no row count where
  this is measurable. Revisit only if bulk import or a photo-heavy history lands.
- **D-B1** — the iOS exclusion path has been type-checked, never executed, because
  `flutter build ios` cannot exit 0 on this project. Failure mode would be loud
  (`MissingPluginException` out of `importPhoto`), not silent. Re-verify with
  F-B3's fix once an iOS build is possible; the two should be closed together.
- **F-C1** — both popup menus discard the `_JournalMenuAction` they receive
  (`journal_screen.dart:362`, `:393`). Inert today (one row each, pinned by
  `journal_screen_test.dart:338,351`), but the failure mode if a row is ever added
  is destructive rather than inert. A `switch` on the value is the cheap
  hardening.
- **F-D2 + F-C3** — AC-id namespace drift. Source comments cite `AC-6`/`AC-13`
  (`journal_composer_screen.dart:23-24, 115, 285`;
  `journal_composer_cubit.dart:21, 233`) against a `story_master.md` list that
  numbers 1–5. Both namespaces are live: the requirement-level expansion in
  `architecture/solution.md:11-12` and the story's own list. The invariants map
  correctly (AC-6 → story AC-3, AC-13 → story AC-2/AC-4); only the numbers
  mislead a future reader. One reconciliation pass, not a rename under pressure.
- **R-D2 residual** — the composer's no-egress property is asserted by review and
  prose only. Slice C's files carry an executable import gate
  (`journal_list_cubit_test.dart:193-223`); the composer files do not, and the
  composer is the surface most likely to grow a share affordance later. Extend the
  same gate to cover `journal_composer_cubit.dart` and
  `journal_composer_screen.dart`.
- **O-E2** — two non-fatal `warnIfMissed` warnings in the pre-existing
  `me_screen_test.dart` "non-interactive rows" case, caused by the new block
  adding height above them. Suite still `+12`. Pre-existing-test drift.
- **contract-summary §2 identifier table** — `contract-summary.md` §2 calls
  `openJournalComposer` the "Điểm nhận duy nhất" while `phase-P5-...md` §3 makes
  the same file the sole external opener of `JournalScreen`. Add the navigation
  symbol to §2's table. Owner: tech-lead. Carried from the prior report,
  unchanged.

## Dismissed and closed

- **R-D3 residual (dismissed).** The body `TextField` does not set
  `enableInteractiveSelection: false`, so the OS selection menu (Share…/Copy on
  iOS) is reachable on body text. AC-3 binds what the *app* provides ("app
  **không** cung cấp bất kỳ chức năng chia sẻ/xuất nào"); an OS text-selection
  affordance is a platform control, and suppressing it would break ordinary text
  editing. Slice D's call is correct and the decision is recorded as explicit.
- **RA-8 (not a STORY-003 defect).** STORY-001 also bumps `schemaVersion` 2→3 in
  the same region of `cupid_database.dart`. This is a tracked cross-story merge
  collision owned by Scrum Master at integration-merge time; it did not influence
  this verdict. Slice A's four merge notes (single version branch for both
  stories' `createTable` calls; move the `if (from < 3)` guard and both
  `expect(..., 3)` assertions together if the merge advances to v4; preserve
  `beforeOpen` `PRAGMA foreign_keys = ON`; re-run `build_runner` post-merge) are
  the operative checklist and should ride with the merge.
- **RA-7 (closed).** Stale `schemaVersion` literals in `timeline_dao_test.dart`
  and `expense_dao_test.dart` were fixed directly at `fcc5066`, outside every
  lane's `WriteScope`, and verified green (15/15). Not re-verified this pass, per
  the dispatch.
- **F-C2 (closed).** The list's compose CTA was a live no-op at the P3 head;
  slice E confirmed by execution at the story head that
  `journal_entry_point.dart:83-87` is the only production construction of
  `JournalScreen` and always supplies `onCompose`
  (`journal_entry_point_test.dart:313-323` taps it and finds
  `JournalComposerScreen`). Not re-opened.

## Risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Persistence / schema / migration | Additive v2→v3 on a real on-disk v2 file, data survives | PASS (slice A, RA-1/RA-2) |
| Local storage / offline | Owner-isolated DAO reads, writes, deletes | PASS (slice A, RA-3/RA-4) |
| Local storage — media files | Per-owner file scoping | **FAIL — F-B1** |
| Security / privacy — egress | No share/export/copy/network on any journal surface | PASS (slice C RC-4, slice D R-D3), executable import gate on the P3 files only |
| Security / privacy — OS backup | Journal text + media excluded on both platforms | Android PASS; iOS media PASS; **iOS DB FAIL — F-B3** |
| Data destruction | Delete-one and delete-all irreversible, one operation, no hidden copy | PASS at the row layer (slice A RA-4, slice C RC-2/RC-3); **FAIL at the file layer via F-B1** |
| Mobile interaction — save path | Save gated on a valid state | **FAIL — F-D1** |
| Mobile navigation / discoverability | Reachable menu entry point, own route | Code + test PASS (slice E R-E2); **evidence section missing — F-G2** |
| App lifecycle | Real-app launch smoke | **MISSING — F-G1** |
| Typed / generated contract | No new cross-story symbol beyond the settled one | PASS (slice E R-E1; the `openJournalScreen` question is settled and was not re-opened) |
| Permissions / device API | iOS backup-exclusion channel executes at runtime | Type-checked only — D-B1, deferred |
| Design fidelity (mobile lane, 12e3) | Images opened and read, not counted | P4/P5 PASS; **P3 verdict not supportable — F-VF1** |

Test evidence across the five phases is present and green as recorded: 21/21
(P1), 30/30 (P2), +19~2 (P3), +10 and +13 (P4), +9 / +3 / +79~4 / +12 (P5), with
slice E re-running two P5 suites in-worktree. Static analysis is 0 errors across
every phase scope. No gate below was failed for want of running tests.

Configuration guide (rule 12a): NOT_REQUIRED. The configuration this story
delivers is in-repo build config (manifest backup rules, an iOS platform
channel, DI registration) verified by the P2 APK build and merged-manifest
read-back. It introduces no env var, secret, external service, or manual
operator step that a deployment configuration guide would carry.

## Reviewed inputs

- Slice reports A–E under `review/` (the sole implementation-evidence source for
  this pass, per the `final-synthesis` contract)
- `visual-fidelity/visual-fidelity-report.md`, plus three PNG frames opened and
  read: `design-reference-s1:diary-ios.png`, `implemented-s1:diary-ios.png`,
  `implemented-me-tab-private-journal-row-emulator-5554.png`
- `story_master.md` — AC-1..AC-5, In/Out of Scope, `Open Question Impact: NONE`
  (confirmed, no OQ triage owed under rule 12)
- Prior `review-report.md` — the settled P5 contract adjudication, cited not
  re-litigated
- `coding-plan/test-results.md` — presence queries only (`Smoke`, `Runtime`,
  `Entry Point Reachability`, `Reachable:`), 0 matches, supporting F-G1/F-G2
- No `mobile/lib` or `mobile/test` file was opened in this pass

## Outcome summary

- Verdict: PATCH_REQUIRED
- Blocking findings: 6 (F-B1, F-D1, F-B3, F-VF1, F-G1, F-G2)
- Deferred findings: 8
- Dismissed: 1 (R-D3 residual); closed: 2 (RA-7, F-C2); merge-owned: 1 (RA-8)
- Acceptance criteria: AC-1 and AC-3 PASS. AC-2, AC-4, AC-5 are correct at the
  row layer and fail at the file/save layer through F-B1 and F-D1 — the fixes are
  bounded and do not disturb the passing evidence.

## Workflow State Recommendation

- Story status: `IN_PROGRESS`
- `Implementation (Development)`: `UNCHECK`
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Route to `mobile-dev` for F-B1, F-D1, F-G1, F-G2 and the P3 re-capture half of
  F-VF1. Route F-B3 to `tech-lead` for the record-the-reading decision first,
  then `mobile-dev` for the channel extension. Route the authorization half of
  F-VF1 to `ui-ux-designer`; F-VF1 closes when either half lands.
- Re-review scope: a `scoped-slice` pass over the patched files plus the two new
  evidence sections is sufficient. Slices A, C and E need no re-review — nothing
  in the blocking set touches their scope. Slice B and slice D scope must be
  re-verified, including the two tests this report requires (two-owner media
  isolation; save-before-readback).
- RA-8 stays with Scrum Master at integration-merge time and must not gate this
  patch round.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
