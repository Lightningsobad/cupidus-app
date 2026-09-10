# Review Slice S4 — P4 Hub List, Status Buckets, Entry Point

- Review type: `scoped-slice`
- Slice: S4 of the 8-pass plan in `review/scope-gate.md` → `## Prescribed Slice Plan`
- Subject: P4 hub list, status buckets, entry point — owns **FLAG-2**
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline: `git -C <Worktree> diff 9207f7296a64cd37ca60e432939469ca96860762 HEAD`
- slice_outcome: `FAIL`
- SLICE_COMPLETE: YES

This pass records findings only. It issues no story-level verdict; S8
`final-synthesis` owns the canonical `Outcome:` line. Two findings are
classified BLOCKING and one of them is the FLAG-2 verdict.

## Files Reviewed (9 — matches the S4 inventory exactly)

| File | Δ | Read |
|---|---|---|
| `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart` | +258 / −0 | whole (new) |
| `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` | +289 / −0 | whole (new) |
| `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart` | +382 / −0 | whole (new) |
| `mobile/lib/features/activity_cards/presentation/widgets/activity_status_filter.dart` | +156 / −0 | whole (new) |
| `mobile/lib/features/home/presentation/home_screen.dart` | +162 / −0 | diff hunks (file is 47 KB) |
| `mobile/lib/main_preview.dart` | +147 / −0 | diff hunks (file is 86 KB) |
| `mobile/test/features/activity_cards/activity_card_hub_view_test.dart` | +871 / −0 | whole (ranged) |
| `mobile/test/features/home/presentation/home_header_notifications_test.dart` | +4 / −2 | diff hunk only |
| `mobile/test/features/home/presentation/timeline_entry_point_test.dart` | +46 / −0 | diff hunk only |

Evidence read: `coding-plan/phase-P4-hub-list-and-entry-point.md` (whole),
`coding-plan/test-results.md` → Phase P4 rounds 1–3 (lines ~300–592, ranged).

## Governing AC Set — Corrected

The handoff and `scope-gate.md` → `## Query Keys` label S4 as *"AC-3, AC-4,
AC-5, SC-4, SC-5"*. Verified directly against `requirements/requirements.md`,
that labelling is wrong for the **fourth consecutive slice**. In the
authoritative file AC-3 is the occasion-suggestion criterion, AC-4 is the
60-second Minute-1 criterion, and AC-5 is the no-runtime-AI rule — all three
belong to S3/S5, none to P4.

The ACs that actually govern P4:

| AC (authoritative `requirements/requirements.md`) | Text in scope | Applies to P4 |
|---|---|---|
| **AC-10** (D-1) | *"đúng 5 ngăn lọc: một ngăn 'Tất cả' dẫn đầu ... và mỗi ngăn trạng thái chỉ liệt kê thẻ đúng trạng thái đó"*; "Tất cả" is a **view**, not a fifth status | primary |
| **AC-11** (D-2, SC-4) | *"đúng một hành động chính (CTA) ... và tối đa một ô tràn '…' đặt cạnh CTA"*, four fixed labels | primary |
| **AC-13** (SC-5) | *"ngăn có ít nhất một đường đi tiếp ... hoặc đường xoá — không ngăn nào ... là ngõ cụt"* | primary |
| **AC-22** (D-3) | the four-item stage-1 tab bar *Muốn làm · Ý tưởng · Sổ tay · Nhật ký*, "Muốn làm" default and this story's list screen | primary |
| **AC-21** (SC-1') | exactly one card store; no second parallel list | primary |
| **AC-18 / AC-20** | no partner-behaviour indicator, no streak/badge | primary |
| **BR-2 / BR-3 / BR-10** | SC-4 restated · SC-5 restated · direct entry from the main menu | primary |
| AC-12 / AC-14 | transitions and two-way manual status change — implemented in P6, but **only reachable through P4's surface** | boundary → see S4-F-1 |

`phase-P4-hub-list-and-entry-point.md` §1B *Primary Inputs Summary* names
*"AC-10, AC-11, AC-13, AC-22, BR-2, BR-3, BR-10"* — i.e. **the phase file is
right and the scope gate is wrong**, the same shape S1–S3 recorded. S8 should
carry this correction and not re-derive S4 scope from the gate's AC list.

## Gate Results

| Gate | Rule source | Verdict | Evidence |
|---|---|---|---|
| Five panes, full labels, "Tất cả" leading | AC-10, D-1 | **PASS** | `ActivityCardPane` (5 values, `all` first, `status == null`); `activity_status_filter.dart:68` iterates `values`; 1 widget test + 1 cubit test |
| "Tất cả" is a view, not a fifth status | AC-10, D-1 | **PASS** | `ActivityCardPane.all(null)`; `ActivityCardStatus` still 4-valued and untouched; no card is stored with a pane |
| Each status pane lists that status only | AC-10 | **PASS** | `_fetchPage` issues one bounded `cardsByStatus`; test asserts the query strings `idea:20:0` … , not just rendered output |
| Bounded reads, never the whole store | phase §3 | **PASS** | paging test asserts `['idea:2:0','idea:2:2','idea:2:4']` |
| Exactly one primary CTA per status, label matches SC-4 | AC-11, BR-2 | **PASS** | one `_PrimaryActionPill` per tile; 4 parametrised widget tests also assert the other three labels are **absent** |
| At most one "…" overflow, collapsed, visually one tier below | AC-11, D-2 | **PASS** | single `_OverflowButton`, `colorSurfaceAlt`, no `gradientHot`; test asserts no menu entry is mounted until opened |
| No dead-end bucket, incl. *Đã thành kỷ niệm* | AC-13, SC-5, BR-3 | **PASS (narrow)** | satisfied by the **delete path only** — see S4-F-8 |
| Four-item tab bar, "Muốn làm" default → hub | AC-22, D-3 | **PASS** | `_SoloStageOneShell`, `SoloStageOneTab.muonLam` default, labels exact |
| No second card store on the other three tabs | AC-21, SC-1' | **PASS** | `_SoloTabPlaceholder`; test taps all three and asserts the card title is absent |
| No streak / badge / partner-behaviour metric | AC-18, AC-20 | **PASS** | plain `· $count` text, `find.byType(Badge)` findsNothing, forbidden-substring test |
| **Rule 12e1 — entry point reachable, verified in the wiring itself** | 12e1, BR-10 | **PASS** | verified in code, not on trust — see below |
| **FLAG-2 — hub mounts neither P5 nor P6** | 12e1, `## System Integration And Discoverability` | **FAIL** | **S4-F-1** |
| AC-12 / AC-14 exercisable end-to-end from the entry point | AC-12, AC-14 | **FAIL** | **S4-F-1** |
| AC-1 / AC-2 / AC-3 / AC-6 / AC-7 exercisable end-to-end | AC-1…AC-7 | **FAIL** | **S4-F-1** |
| Reply flag persists (AC-17 surface) | AC-17 | **FINDING** | **S4-F-4** |
| No regression in adjacent suites | 12f | **FAIL** | **S4-F-2** |
| Declared write scope conformance | phase §1B | **FINDING** | **S4-F-7** |
| Static analysis: no new errors | phase §6 | **PASS** | rounds 1–3 all record `error count: 0`; 2 new `info` (`prefer_initializing_formals`, unfixable as the lint suggests) |

### Rule 12e1 — entry-point reachability, read from the wiring

Not accepted on trust and not accepted from a `Reachable: YES` line. Traced in
`home_screen.dart` itself: `HomeScreen.build` now returns `_SoloHomeGate`,
which resolves `PairingStatus` and, on `PairingStatus.unpaired`, builds
`_SoloStageOneShell(muonLamBuilder: … ActivityCardHubView(…))`. The shell's
`IndexedStack` opens at `_tab = SoloStageOneTab.muonLam`, whose child is the
hub. Every other pairing outcome keeps `_buildCoupleHome`, which is the prior
dashboard moved unchanged into its own method (+162 / −0 on the file confirms
nothing was deleted).

`HomeScreen` was already the app's home destination before this story, so the
chain from app launch to the hub is complete and needs no new route. The
widget test at `activity_card_hub_view_test.dart:737` exercises this through
`HomeScreen`, not by mounting `ActivityCardHubView` directly, so the gate has a
real assertion behind it.

**The screen is reachable. What it reaches is the problem — see S4-F-1.**

## Findings

### S4-F-1 — BLOCKING — FLAG-2 CONFIRMED: the hub mounts neither P5 nor P6, so most of the story's ACs are unreachable end-to-end

Confirmed directly in the code, not inherited from the scope gate.
`activity_card_hub_view.dart` imports exactly five local modules
(`activity_card.dart`, `activity_card_repository.dart`,
`activity_card_list_cubit.dart`, `activity_card_tile.dart`,
`activity_status_filter.dart`). It imports **no** P5 widget and **no** P6
screen, and contains no `Navigator` call of any kind.

The three concrete mounting/routing gaps:

1. **Minute-1 empty state is an empty box.** `_EmptyPane` returns, for an empty
   store:
   ```dart
   if (state.storeCount == 0) {
     return const SizedBox(key: Key('activity_card_hub_minute1_slot'));
   }
   ```
   `MinuteOneEmptyState` is never mounted. A first-run user landing on "Muốn
   làm" sees three blank grey rectangles, a filter reading `· 0`, and nothing
   else. The widget test at line 677 asserts precisely this emptiness as the
   intended behaviour.
2. **Quick capture is a decorative frame.** The hub mounts a *private*
   `_QuickEntryStrip` — three `SizedBox`es inside a `DecoratedBox`, with no
   label, no icon and **no `onTap`** — not P5's
   `quick_entry_strip.dart`/`quick_capture_sheet.dart`. There is no "+" button
   anywhere on the surface.
3. **Every write path answers with a snackbar.** The primary CTA is wired to
   `onPrimaryAction: () => _showComingSoon(context)`, and the overflow's
   "Chuyển trạng thái" and "Sửa" fall through to the same `_showComingSoon`.
   Only `ActivityCardOverflowAction.delete` reaches the repository.

Applying the test this slice was given — *if an AC can be exercised only by a
widget test mounting the widget directly, and never by a user arriving from the
main menu, it is unverifiable end-to-end*:

| AC | Reachable from "Muốn làm"? | Blocked by |
|---|---|---|
| AC-1 exactly two one-tap invitations | **No** | `_EmptyPane` renders an empty `SizedBox` |
| AC-2 paste link → creates an *Mới nghĩ ra* card | **No** | no capture affordance mounted |
| AC-3 occasion suggestion → creates a card | **No** | no capture affordance mounted |
| AC-4 1–2 cards within 60 seconds | **No** | no creation path exists at all |
| AC-6 create a card with title as the only required field | **No** | no "+" button on the surface |
| AC-7 pasted link survives a failed preview | **No** | no capture affordance mounted |
| AC-12 set a date → card moves to *Đã hẹn ngày* | **No** | CTA is `_showComingSoon` |
| AC-14 two-way manual status change | **No** | overflow entry is `_showComingSoon` |
| AC-8 / AC-15 / AC-16 / AC-17 (detail screen) | **No** | no route to `ActivityCardDetailScreen`; "Sửa" is `_showComingSoon` |

The only behaviours a real user can perform are: view panes, switch panes,
toggle the reply chip (not persisted — S4-F-4), and delete a card.

`test-results.md` records this as a deliberate deferral (*"Hành động chính tạm
thời: bốn nút chính mở luồng thuộc story sau"*). That justification does not
hold for this story's own ACs: AC-1, AC-2, AC-6, AC-7, AC-12 and AC-14 are
STORY-001 criteria, and In-Scope items 4, 5, 6 and 7 of
`requirements/requirements.md` are exactly the paths that terminate in a "Sắp
có" snackbar. Only the four **later-story** flows (STORY-002's invitation
export, STORY-006's pre-outing block, etc.) are legitimately deferrable behind
that message.

Per rule 12e1 this is **`PATCH_REQUIRED`**, not an acceptable staged-rollout
gap. The patch is integration, not new feature work — P5 and P6 both exist and
are separately tested; nothing mounts or routes to them.

- Owner: mobile-dev
- Scope of the patch: mount `MinuteOneEmptyState` in `_EmptyPane`'s
  `storeCount == 0` branch, mount the real quick-entry/capture affordance in
  place of the private `_QuickEntryStrip`, and route `onPrimaryAction` /
  overflow `changeStatus` / `edit` to `ActivityCardDetailScreen`.
- Cross-slice: S5 and S6 should confirm their widgets expose the entry points
  this patch needs; neither slice can close this finding on its own.

### S4-F-2 — BLOCKING — three tests in `app_shell_test.dart` are red because of this story and were never repaired

`test-results.md` (round 2, line ~499) records
`mobile/test/core/navigation/app_shell_test.dart` — 3 tests failing with
`Bad state: ... not registered inside GetIt`, because the now-solo `unpaired`
branch of `HomeScreen` resolves `getIt<ActivityCardRepository>()` and that
file's DI helper registers five singletons without it. The entry is filed under
*"Đỏ có sẵn cần Scrum Master định tuyến"* (pre-existing red) on the grounds that
it was *"đỏ sẵn ở BaseHead"*.

That claim is **round-local and false against the story baseline**. It is true
only relative to round 3's own `BaseHead 98e865d`, which already contained P4
rounds 1–2. Verified against the story diff baseline `9207f72`:

- `git diff --name-only 9207f72 HEAD -- mobile/test/core/navigation/` → empty;
  the test file was never touched.
- `home_screen.dart` is **+162 / −0** across the whole story diff, and
  `git show 9207f72:…/home_screen.dart` is 1099 lines against 1261 now — the
  entire solo branch, and therefore the new `ActivityCardRepository`
  dependency, is introduced by this story.

So these are regressions this story caused, correctly diagnosed but misfiled as
inherited debt, and left unfixed. The other two red tests named in that table
(`shared_backdrop_occlusion_guard_test` at
`reminder_schedule_screen.dart:79`, and the chat `pumpAndSettle` timeout) are
genuinely unrelated to STORY-001 and are correctly routed.

- Owner: mobile-dev
- Fix: register an `ActivityCardRepository` in `app_shell_test.dart`'s DI
  helper — the same one-line repair round 1 already applied to
  `home_header_notifications_test.dart` and `timeline_entry_point_test.dart`.

### S4-F-3 — MEDIUM — an unpaired session renders the couple dashboard for one frame before the solo surface

`_SoloHomeGate` uses a `FutureBuilder` with no `initialData` and branches on
`snapshot.data == PairingStatus.unpaired`. While the future is pending
`snapshot.data` is `null`, so the **couple dashboard** is built and then
replaced once the status resolves. `activity_card_hub_view_test.dart:854` and
the `home_screen_ready_signal pumps immediately` test both confirm the pending
frame renders the couple branch.

The doc comment's claim — *"a paired session never flashes the solo surface"* —
is accurate, but the converse now happens: a solo user sees the couple
dashboard flash on every Home mount, and its side-effect work (profile resolve,
Dream Jar fetch, pet repository) is started for a user who will never see it.
Before this story `unpaired` and `paired` rendered the same dashboard, so no
branch swap and no flash existed.

AC-22 calls the solo surface *"màn mặc định khi mở app ở chế độ 1 người"*. A
one-frame couple dashboard is a visible contradiction of that, though not a
hard AC failure.

- Owner: mobile-dev
- Fix: render a neutral placeholder (or nothing) while the status is
  unresolved, rather than defaulting to the couple branch.

### S4-F-4 — MEDIUM — the "đã rủ" flag is in-memory only and is lost on dispose

`ActivityCardListState.replyOverrides` is a `Map<String, ActivityCardReplyState>`
held in cubit state; `toggleReplyState` writes only to it. The file says so
plainly:

```dart
/// `ActivityCardRepository` exposes no writer for the `reply_state` column,
/// so the "đã rủ" chip's two values are toggled here and are not persisted.
```

`ActivityCardHubView` creates the cubit in its own `BlocProvider`, so the map
dies whenever the hub is disposed — and `_SoloStageOneShell` uses an
`IndexedStack`, so it survives tab switches but not a Home rebuild, a pairing
re-resolve, or app restart. The user's tap is silently discarded.

This is the *same root cause as FLAG-1* (the P2 repository exposes
`createCard` / `updateStatus` / `clearScheduledDate` / `deleteCard` and no
general field writer) surfacing a second time, on a second screen. In-Scope
item 8 and AC-17 are STORY-001 scope, and the `reply_state` column exists in
the P1 schema, so the data has somewhere to go — only the write path is
missing.

`test-results.md` is candid about it (*"Test chỉ khẳng định chip đổi giữa đúng
hai giá trị, không khẳng định nó sống qua restart"*), and the test suite
matches that description exactly.

- Owner: tech-lead (contract) + mobile-dev (write path)
- **Cross-slice:** S6 owns FLAG-1's second half. S8 must classify S4-F-4
  together with S6's FLAG-1 verdict — they are one contract gap with two
  symptoms, not two independent findings.

### S4-F-5 — LOW — "Tất cả" paging can order cards wrongly across page boundaries

`_fetchPage` serves the `all` pane by running four bounded per-status queries in
parallel and merging them sorted by `updatedAt` descending. Within one page
that is correct. Across pages it is not: each status is offset independently, so
a card in status A's *second* page may be newer than cards already emitted from
status B's *first* page, and it will still be appended below them. `hasMore` is
`pages.any(...)`, so paging terminates correctly and no card is lost or
duplicated — only relative order beyond the first 80 cards can be wrong.

The workaround is deliberate and documented (the repository exposes no
cross-status read, and `activity_card_repository.dart` is outside P4's write
scope). No AC constrains "Tất cả" ordering. Recording it so a later story that
adds a cross-status query knows why this exists.

- Owner: tech-lead (repository contract), deferrable

### S4-F-6 — LOW — the preview fixture's pane counts do not match its rows (affects S7's capture)

`_PreviewActivityCardRepository` in `main_preview.dart` hard-codes
`countsByStatus()` to `idea: 8, scheduled: 2, done: 3, memory: 1` (total 14, to
match the design canvas' "14") while `_cards` holds only **four** rows (3 idea,
1 scheduled). The `man-goc-muon-lam` capture therefore shows a filter reading
`Tất cả · 14` above a list of 4 tiles.

That is a fixture-authoring inconsistency, not a product defect — the shipped
app derives both numbers from the same store. But S7 compares that capture
against the design reference, and this internal mismatch is visible in the
frame.

- Owner: mobile-dev (fixture)
- **For S7:** treat any count-vs-row discrepancy in
  `implemented-man-goc-muon-lam-*.png` as this fixture artefact, not as an
  implementation delta.

### S4-F-7 — INFO — three files changed outside the phase's declared write scope

`phase-P4-hub-list-and-entry-point.md` §1B lists six files. The diff also
touches `main_preview.dart`, `home_header_notifications_test.dart` and
`timeline_entry_point_test.dart`. Each is disclosed and justified in
`test-results.md` → *"Thay đổi ngoài write scope đã khai báo"*: the preview
entry is required by the §6 visual-fidelity gate the phase itself mandates, and
the two test edits are forced repairs from the AC-22 branch change (the same
class of repair S4-F-2 shows was *not* completed for `app_shell_test.dart`).

Disclosed, proportionate, and defensible. Recorded for completeness only.

### S4-F-8 — INFO — the AC-13 rationale in code and tests overstates what is wired

`activity_card_tile.dart:77-80` states *"AC-13's 'or' branch is already
satisfied by the primary action and the status change"*, and the widget test at
line 461 repeats it. In the wired hub both of those are `_showComingSoon`
no-ops. AC-13 is satisfied — but by the **delete path alone**, which is the one
overflow entry that reaches the repository.

The gate verdict above is PASS on that narrower ground. The comment should be
corrected when S4-F-1 is patched, at which point the stated rationale becomes
true.

### S4-F-9 — INFO — scope-gate AC labelling for S4 is wrong (no code impact)

Recorded above under `## Governing AC Set — Corrected`. Fourth consecutive
slice affected. Correction only; no patch to any file.

### S4-F-10 — INFO — stale "Nhà" tab wording in two places

`main_preview.dart`'s `_buildManGocMuonLam` doc comment says *"the gate is
whether the 'Nhà' tab reaches the hub"*, and
`phase-P4-hub-list-and-entry-point.md` §1/§3/§4 still describe *"nhánh solo của
tab 'Nhà'"*, *"4 ngăn"*, and *"Không route mới, không tab mới"*. All predate
D-1/D-3; the patched AC-10/AC-22 require five panes and a dedicated stage-1 tab
bar, and the implementation correctly follows `requirements.md`. Documentation
drift in the phase file, not an implementation defect — §1B's AC list is
already correct.

## Test Evidence Assessment

`coding-plan/test-results.md` → Phase P4 rounds 1–3 (lines ~300–592). The
suite itself is strong: 25 tests in `activity_card_hub_view_test.dart`, all
green at round 3, and the assertions are substantive rather than decorative —
the AC-10 test asserts the emitted repository query strings, not just rendered
rows; the AC-11 tests assert the *absence* of the other three CTA labels and
that no overflow entry is mounted until opened; the AC-22 tests drive
`HomeScreen` rather than mounting the hub directly.

Two credibility observations for S8:

- Round 2 self-reported and self-fixed two guard regressions it had caused
  (`no_fork_guard_test` AC-4, `shared_backdrop_occlusion_guard_test` AC2). Gates
  that bite.
- Round 3's scope was a single test file (25 tests). The broader round-2 figure
  (`test/features/activity_cards` 58/58, `test/features/home` 47 pass + 1 skip)
  was not re-run after the icon and preview-harness changes. Those changes are
  low-risk, but no full-suite green is recorded at HEAD, and S4-F-2's three red
  tests sit in a suite (`test/core/navigation/`) that no P4 round ever ran.

Per-story visual fidelity: **not this slice's verdict** — S7 owns it. Noting
only that all three rounds record `VISUAL_FIDELITY: FAIL`, reduced to D-4 and
D-5 by round 3, and that S4-F-6 bears on how S7 reads the capture.

## Residual Risk Carried To S8

- **S4-F-1 is the story's central defect** and drives the recommendation for
  this slice: `PATCH_REQUIRED`. P4 built a correct, well-tested shell around a
  surface that cannot perform this story's own acceptance criteria. Every
  individual P4 gate passes; the integration does not exist.
- **S4-F-2** is a concrete red-test regression attributable to this story and
  is a one-line fix. It must not be carried forward as inherited debt.
- **S4-F-4 must be merged with S6's FLAG-1 verdict** before S8 classifies
  either. One missing write path, two symptoms.
- **S4-F-3** is a real but bounded UX defect in the new entry-point gate.
- S4-F-5 through S4-F-10 are deferrable; S4-F-6 changes how S7 should read the
  `man-goc-muon-lam` capture.
- FLAG-1 is not judged here beyond its S4-F-4 symptom; S2 and S6 own it.

## Unverified Items

None. Every gate assigned to S4 was evaluated against the code, and the
entry-point gate was traced through `home_screen.dart`'s actual branch wiring
rather than accepted from a `Reachable: YES` claim. FLAG-2 was confirmed by
reading `activity_card_hub_view.dart`'s imports and callbacks directly, not
inherited from `scope-gate.md`.

The one bound worth stating: this slice can only prove that **no route to
`ActivityCardDetailScreen` exists from the hub**, which is sufficient for
S4-F-1 because the hub is the sole surface the entry point reaches. Whether any
other file in the repository routes to that screen is outside S4's nine files;
S8 may confirm globally if it wishes.
