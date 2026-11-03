---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-09-08
reviewed_by: Reviewer
review_mode: "scoped-slice"
---

# Review Report: STORY-003 Nhật ký riêng

Outcome: DEFERRED_ONLY

This supersedes the `PATCH_REQUIRED` verdict of the `final-synthesis` pass
(committed `d88a298`). All six blocking findings from that pass are closed
against patch commit `1c32341`. The earlier `BLOCKED` /
`REVIEW_SCOPE_TOO_BROAD` record and the A–E slice reports remain historical
context only; this file is the story-level verdict of record.

## Scope Gate (inline)

- Review type: `scoped-slice` — narrow re-review of one patch round, not a
  fresh full-story review.
- `review/scope-gate.md` exists with `Phase: SCOPE_GATE` /
  `SCOPE_GATE_COMPLETE: YES` from the A–E dispatch; it is outside this run's
  `WriteScope` and was not refreshed. This inline section is the scope of
  record for the patch pass.
- Diff baseline: `git -C <Worktree> diff 6a08474 HEAD` = `1c32341`, 20 files,
  +718/−61. Nothing outside that diff was re-reviewed.
- Source/test files in scope: `mobile/lib/core/journal/journal_media_store.dart`,
  `mobile/lib/core/database/cupid_database.dart`,
  `mobile/lib/core/di/service_locator.dart`,
  `mobile/lib/features/journal/presentation/journal_composer_cubit.dart`,
  `mobile/lib/features/journal/presentation/screens/journal_screen.dart`,
  `mobile/lib/l10n/arb/app_vi.arb`, `app_en.arb`, and the eight touched test
  files. Read outside the diff for verification only:
  `journal_composer_cubit.dart:240` (`save()` guard),
  `journal_composer_screen.dart:121`, `journal_screen.dart:374-412`
  (`_JournalThumbnail`), `ios/Runner/AppDelegate.swift`,
  `journal_screen_test.dart:296-329` (AC-6 gate), `architecture/solution.md`
  §7.1–7.4.
- Evidence files in scope: `coding-plan/test-results.md` new sections
  (`F-B1`, `F-D1`, `F-B3`, `Story Runtime Startup Smoke`,
  `Entry Point Reachability`, `F-VF1`, `Verification for this round`);
  `visual-fidelity/visual-fidelity-report.md` "Deltas" + "Re-capture";
  four PNGs opened and read, not counted.
- Query keys: F-B1, F-D1, F-B3, F-G1, F-G2, F-VF1.
- Not re-litigated per dispatch: the settled deferred/dismissed/closed set
  (F-B2/R-D4, RA-9, D-B1, F-C1, F-D2+F-C3, R-D2, O-E2, contract-summary §2,
  R-D3, RA-7, RA-8, F-C2), and slices A/C/E, which the patch does not touch.

## Patch adjudication

| Id | Verdict | Basis at `1c32341` |
|---|---|---|
| F-B1 | **CLOSED** | Media root is owner-scoped; `sweepOrphans`/`deleteRoot`/`entryDir`/`resolvePhoto` all descend from it; two-owner tests added at both layers |
| F-D1 | **CLOSED** | `canSave` gates on `isReady`, `save()` gates on `canSave`; the pre-readback keystroke window is now an executable test |
| F-B3 | **CLOSED** | `cupid.sqlite` + sidecars tagged over the existing channel at DB open; tech-lead reading recorded in `solution.md` §7.1–7.5 first, as the finding required |
| F-G1 | **CLOSED** | Real-`main()` build + install + `am start -W` on `emulator-5554`, with a fully-painted first-screen capture |
| F-G2 | **CLOSED** | `## Entry Point Reachability` present with `Reachable: YES` and a three-step file:line path, independently re-verified in code |
| F-VF1 | **CLOSED** | P3 re-captured through the product's own background wrapper; deltas 2/3/4/5 closed against the reference, delta 3's variance carries a verified AC citation |

No finding is `STILL_OPEN`. No `NEW_ISSUE` of blocking severity.

## Verification detail

**F-B1.** `journal_media_store.dart:69-83` splits the shared
`journal_media/` parent (`mediaRootDir`) from the per-owner
`journal_media/<ownerSegment>/` (`rootDir`), and every other path method
descends from `rootDir`, so the two destructive operations named in the
finding are now owner-bounded by construction rather than by argument
filtering. `ownerSegment` (`:46-49`) hex-encodes the backend id, which both
blocks a separator/`..` in an id and keeps the mapping injective; a test
covers the escape case explicitly. Absent-owner throws rather than falling
back to a device-wide root (`:55-64`), and the only ungated caller
(`_JournalThumbnail`, `journal_screen.dart:390-406`) resolves a null
`snapshot.data` to a neutral square, so the throw degrades rather than
crashes. Wiring at `service_locator.dart:459-464` reads the id per call, so an
account switch is picked up. The two-owner coverage the finding demanded now
exists at both layers: `journal_media_store_test.dart` (B's `sweepOrphans` and
B's `deleteRoot` leave A's files; same entry id under two owners resolves
apart) and `journal_repository_test.dart` (B's sweep and B's "xoá toàn bộ
nhật ký" leave A's rows *and* files; B cannot read A's entry by id).

**F-D1.** `journal_composer_cubit.dart:56-59` adds `isReady` to `canSave`;
`save()` at `:241` returns early on `!state.canSave`, and
`journal_composer_screen.dart:121` disables the button from the same getter,
so both entry paths are covered by one condition. `:190` and `:204` set
`isReady` on the success and the error readback path, so a failed load does
not lock save permanently. The new test drives exactly the finding's repro —
`bodyChanged` then `save()` with no `settle()` — and asserts the stored entry
and its photo are unchanged, then that saving works after the readback lands.

**F-B3.** `cupid_database.dart:79-107` creates the file empty if absent, tags
it, then best-effort tags `-journal`/`-wal`/`-shm` when present, inside the
`LazyDatabase` opener on the root isolate — matching `solution.md` §7.4's
constraint that a MethodChannel cannot run in `createInBackground`'s isolate
setup. `AppDelegate.swift:29-59` accepts any path string and sets
`isExcludedFromBackup`, making no directory assumption, so no native change
was needed. The tag re-applies on every open, so an install that predates the
patch is covered at next launch. The finding required tech-lead to record the
Apple-guidance reading before the fix landed; `solution.md` §7.3 does that,
and §7.1 additionally corrects the finding's own file list (the DB runs in
rollback-journal mode, so `-wal`/`-shm` do not exist today). `_openConnection`
is reached only through `service_locator.dart:311`; `main_preview.dart:736`
passes its own executor and needs no tag.

**F-G1.** `test-results.md` §"Story Runtime Startup Smoke" runs
`flutter build apk --debug --flavor local -t lib/main.dart` — the real entry
point, which is the specific thing the finding said the P5 preview capture
could not prove — then installs and cold-starts on `emulator-5554`:
`Status: ok`, `LaunchState: COLD`, `topResumedActivity=MainActivity`,
`Fully drawn +12s425ms`, zero `FATAL EXCEPTION` and zero `E/flutter`. I opened
`runtime-smoke-main-first-screen-emulator-5554.png`: a fully painted
signed-out welcome screen (Cupid wordmark, tagline, "Tiếp tục với Google",
"Dùng email"), debug banner present. Not a splash frame, not an error screen,
not a spinner.

**F-G2.** `## Entry Point Reachability` records `Reachable: YES` with the tap →
helper → route push chain. Verified independently rather than on trust:
`me_screen.dart:560` calls `openJournalScreen(context)`,
`journal_entry_point.dart:80-89` pushes a `MaterialPageRoute`, and
`me_screen_journal_row_test.dart` covers the row. Discoverable menu row, not
direct-URL-only.

**F-VF1.** The finding had two halves and both are answered. (1) The
background ambiguity is resolved as a capture artifact, not a product defect:
`iosHarness()` in `journal_screen_test.dart` moved from an opaque
`ColoredBox` to the product's own `MaterialApp.builder` +
`CupidAppBackground(enableEffectsOverride: false)`, the same wrapper the
accepted P4 frames use, and the re-captured `implemented-s1-diary-ios.png`
shows the purple wash behind the header. `scaffoldBackgroundColor` and
`CupidHeader.backgroundColor` are both transparent, so the wrapper reports
what the pushed route really sits on. (2) The four uncited deltas: I opened
the re-captured implemented frame and `design-reference-s1-diary-ios.png` side
by side. Dates now read `Thứ Năm 3/9` / `Thứ Tư 2/9` in the reference's warm
relative form (`journalEntryDateLabel`, `journal_screen.dart`), against the
reference's `Thứ Bảy 16/8` / `Thứ Ba 12/8`. The muted `colorSurfaceAlt`
footnote card closes the list in the same position and treatment as the
reference's. The thumbnail cap is `entry.photos.take(_maxThumbnails)` with
`_maxThumbnails = 2`, matching the reference's two squares. Delta 1 (compose
pill vs pencil FAB) stays open as a designer call and was already adjudicated
spec-authorized under `uiux-spec.md:25`; it is not re-opened. `Design-Screen:
s1:diary` remains recorded and the reference is that screen.

The footnote's *wording* differs from the reference on purpose, and the
citation is real: I read `journal_screen_test.dart:310-313`, whose AC-6
absence gate fails the build on `chia sẻ|xuất|…` anywhere in visible text —
the reference's literal "Nhật ký không xuất ra được, không có nút chia sẻ"
contains two of those words. Shipping it verbatim would have required
weakening a passing acceptance gate so the screen could name an affordance it
does not have. The shipped line states the same two facts positively. This is
the same shape as the three `DESIGN_SPEC_CONFLICT` items the prior pass
accepted under the `VISUAL_FIDELITY: PASS`, and it is handled the same way:
recorded as a cited variance and a designer call (D-VF-1), not a patch order.
No `BLOCKED: DESIGN_SPEC_CONFLICT` is raised, because no patch is being
ordered and the build is on the acceptance side of the conflict.

## Patch scope discipline

Every edit in `1c32341` maps to one of the six assigned findings. No unrelated
change was found. The dispatch's `WriteScope` did name paths that do not exist
(`features/journal/journal_media_store.dart`) and omitted `journal_screen.dart`
and the two ARB files that closing the F-VF1 deltas necessarily requires; the
implementer flagged this in `test-results.md` §"Write-scope path corrections".
That is a handoff-authoring defect for Scrum Master to fix in the next
dispatch, not scope creep by the implementation lane, and it carries no
finding against the story.

## Deferred findings — new this pass

- **D-VF-1 (ui-ux-designer).** Privacy-footnote wording variance against the
  design reference, cited against the AC-6 absence gate above. Either the
  designer authorizes the shipped phrasing in the spec, or the reference card
  is restated without the gated vocabulary. Non-blocking; the build is correct
  under the AC either way.
- **D-P2-1 (mobile-dev).** `journalEntryDateLabel` has four branches
  (today / yesterday / <7 days / absolute fallback) and no unit test. The
  captured frame exercises only the weekday and fallback branches. It is a
  pure function taking `now` as a parameter, so four cheap cases close it.
- **D-P2-2 (mobile-dev).** The `_maxThumbnails = 2` cap has no assertion; the
  P3 capture fixture is text-only, so neither the test suite nor the frame
  proves the cap. Cosmetic risk only.
- **D-P2-3 (mobile-dev / devops).** No migration for media written by a
  pre-patch build: files at the old flat `journal_media/<entryId>/` become
  unreachable and are never swept under the new owner-scoped root. There is no
  installed base — the feature is unreleased — so this affects developer and
  QA devices only. Note it before any pre-release build is distributed.
- **D-P2-4 (accepted residual, recorded in `solution.md` §7.5).** Sidecar
  backup tagging is best-effort: `cupid.sqlite-journal` is created and deleted
  per transaction and a recreated file carries no extended attribute. The main
  DB file, which holds the journal text, is tagged and stays tagged because
  SQLite writes it in place rather than by atomic replace.

## Deferred findings — carried forward unchanged

F-B2/R-D4 (photo-replacement file residue; the invariant lives in the caller,
revisit when a second `saveEntry` caller appears — its only live trigger,
F-D1, is now closed), RA-9 (missing indexes; not measurable at on-device
scale), D-B1 (the iOS exclusion path is type-checked but never executed
because `flutter build ios` cannot pass here — now covers the DB path of F-B3
as well as media, and both should be re-verified together once an iOS build is
possible), F-C1 (both popup menus discard their action value), F-D2/F-C3
(AC-id namespace drift between source comments and `story_master.md`), R-D2
residual (extend the executable no-egress import gate to the composer files),
O-E2 (pre-existing `me_screen_test.dart` `warnIfMissed` drift), and
contract-summary §2 identifier table (tech-lead doc drift). Dismissed and
closed items from the prior pass — R-D3 residual, RA-8 (cross-story
`schemaVersion` merge collision, with slice A's four merge notes riding with
the merge), RA-7, F-C2 — stand as recorded.

## Risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Persistence / schema (Drift v3) | Additive migration, no destructive recreate | PASS (slice A) |
| Local storage — media files | Per-owner file scoping | PASS — F-B1 closed, two-owner tests at store and repository layer |
| Security / privacy — OS backup | Journal text + media excluded on both platforms | Android PASS; iOS media PASS; iOS DB PASS in code — execution deferred as D-B1 |
| Data destruction | Delete-one and delete-all irreversible, one operation, no hidden copy | PASS at row and file layer |
| Mobile interaction — save path | Save gated on a valid state | PASS — F-D1 closed with the race test |
| Mobile navigation / discoverability | Reachable menu entry point, own route | PASS — code, test, and evidence section |
| App lifecycle | Real-app launch smoke | PASS — real `main()` cold start, first screen painted |
| Design fidelity (mobile lane, 12e3) | Images opened and read, not counted | PASS — P3 re-captured, P4/P5 unchanged |
| Static analysis / build | 0 errors, 0 warnings in story scope; debug APK builds | PASS |
| Targeted test suites | Journal core + feature + entry-point row | PASS — `+92 ~4`, plus `+11` on the capture run |

Configuration-guide impact: none. The patch adds no env var, no service, no
manual setup step; the backup-exclusion channel and its Android rules already
existed.

## Workflow state recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Deferred items above carry forward; none gates closure. D-VF-1 is the only
  one wanting a decision rather than code, and it is a designer call, not a
  release gate.
- Merge note: STORY-001 also bumps `schemaVersion` 2→3 in the same region of
  `cupid_database.dart`, and this patch adds a second positional constructor
  parameter to `CupidDatabase` in that same file. Slice A's merge checklist
  applies at integration-merge time.
