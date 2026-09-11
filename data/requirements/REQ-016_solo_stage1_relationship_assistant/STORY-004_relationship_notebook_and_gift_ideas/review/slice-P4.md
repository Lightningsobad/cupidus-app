# STORY-004 — Scoped slice review P4

Outcome: PARTIAL_SLICE_ONLY

Slice: phase P4 "Màn (2) Sổ tay, màn (3) Hồ sơ kỹ năng, và hai lối vào menu"
(`coding-plan/phase-P4-notebook-and-skill-screens-and-menu-entry.md`).
Diff base: `e5b3741743744241cd8cfb60543cf6d37f0ec946` → HEAD `cc6ef4e`.
Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`.

This is a partial review of one phase. It is not a story-level gate decision.

## Source of truth consulted

- `requirements/requirements.md` lines 100-136, 192-213 (AC-5..AC-9, AC-11,
  AC-12, AC-25, AC-29)
- `ux/uiux-spec.md` Phần 0, B, C, E
- `coding-plan/phase-P4-notebook-and-skill-screens-and-menu-entry.md`
- `coding-plan/test-results.md` lines 5-98 (this phase's evidence — see F5)
- `visual-fidelity/visual-fidelity-report.md` + all six P4 PNGs, opened and read

## Per-AC verdicts

| AC / gate | Verdict | Evidence |
| --- | --- | --- |
| AC-5 — no prefill/onboarding flow at any entry point | PASS | `notebook_screen.dart:134-161` and `skill_profile_screen.dart:109-172` build a bare `ListView` straight from the repository read; no intro route, no wizard, no gate before the list. `context_notebook_entry_point.dart:62-81` pushes each screen directly. Captures `implemented-2-so-tay-nguoi-yeu-ios-empty.png` and `implemented-3-ho-so-ky-nang-phien-ban-toi-ios-empty.png` show first-open state with no onboarding. |
| AC-6 — only interests and events; note lives inside an item | PASS | Closed group list `notebook_screen.dart:13-16`; grouping `:29-41`; the free-text note renders as a caption inside the row, `:327-331`, and is written as `ContextInlineAddResult.detail`, `context_inline_add_row.dart:27-33,157-171`. No "nhận xét về người ấy" field and no app-assigned personality label anywhere in the tree. Test `notebook_screen_test.dart:169-194` pins exactly two group Columns; `:380-411` pins the note as an item field. |
| AC-7 — no share / copy-all / export / Share Sheet | PASS | The row menu is a closed two-value enum on both screens (`notebook_screen.dart:21`, `skill_profile_screen.dart:18`), and its `itemBuilder` emits exactly two items (`notebook_screen.dart:347-362`, `skill_profile_screen.dart:229-244`). `expectNoBannedSurfaces()` (`notebook_screen_test.dart:45-66`, `skill_profile_screen_test.dart:99-120`) runs in every state including with the "..." menu open (`notebook_screen_test.dart:220-243`) and rules out share/ios_share/copy/download glyphs and the matching copy. Confirmed by reading all six captures. |
| AC-8 — list (possibly empty) + "+ tự thêm", neutral | PASS | Both groups render header + add button even when empty (`notebook_screen.dart:138-159,257-268`); skill screen `:155-171`. `notebook_screen_test.dart:152-167` asserts no `TextField` is present on arrival and no inviting copy. Empty captures show a neutral screen with no banner and no urging line. Tension resolved: the skill screen's empty state additionally mounts `AskOnTheSpotSlot` (`skill_profile_screen.dart:113-124`) — that is required by AC-10/AC-11 and `uiux-spec.md` Phần C, so it is the prescribed empty state, not an AC-8 violation. |
| AC-9 — edit/delete take effect immediately, undramatic | PASS | `notebook_screen.dart:99-106` and `skill_profile_screen.dart:81-86` delete on the tap and reload; no confirmation state, no soft-delete, no undo. Edit is in place via `ContextInlineAddRow` (`notebook_screen.dart:223-233`, `skill_profile_screen.dart:128-137`). Tests assert `AlertDialog` and `SnackBar` are both absent after delete and after edit (`notebook_screen_test.dart:245-295`, `skill_profile_screen_test.dart:281-331`). |
| AC-11 — ≥4 everyday soft-skill seed chips before any input, visually equal | PASS | The ask slot is mounted first in the list while the profile is empty (`skill_profile_screen.dart:113-124`). `skill_profile_screen_test.dart:163-183` asserts every id in `requiredSkillSeedIds` renders, that the set is ≥4, and that `find.byType(TextField)` finds nothing on arrival. Independently confirmed in `implemented-3-ho-so-ky-nang-phien-ban-toi-ios-empty.png`: ten identical full-width pills, including "Nhớ dai", "Biết chỗ ăn ngon", "Gói quà đẹp", "Chọn nhạc hợp cảnh", at the same fill/opacity/size, with no sub-group divider and no dimming, above the "Khác..." row and the "+ tự thêm" button. |
| AC-12 — no level, star, score or rank on a skill | PASS | `skill_profile_screen.dart:209-216`: the row is one `Expanded(Text(label))` plus the "..." menu, nothing else. `skill_profile_screen_test.dart:212-233` asserts exactly one `Text` descendant of the row; `:235-257` asserts no sub-group heading once the list has entries; the banned-icon list `:64-84` covers star/grade/military_tech/emoji_events/workspace_premium. Confirmed in `implemented-3-ho-so-ky-nang-phien-ban-toi-md.png` — four name-only rows. |
| AC-25 — no partner behavioural quantity, no count read | PASS | No count is rendered anywhere: the header is title-only (`notebook_screen.dart:113-118`) and the group header is the group name alone (`notebook_screen.dart:212-218`). The screens read no partner-behaviour data — the schema has no such column (`context_notebook_tables.dart:11-15` closed allowlist, enforced by `context_notebook_migration_test.dart`). A pending read renders as the empty list rather than a progress indicator (`notebook_screen.dart:127-133`), and both tests assert `LinearProgressIndicator`/`CircularProgressIndicator`/`Slider` are absent. The design reference's count subtitle and "SỞ THÍCH · 21" headers are recorded as deliberate `DESIGN_SPEC_CONFLICT` items 1, 2, 8, 11 rather than implemented. |
| AC-29 — no streak, badge, leaderboard or paywall | PASS | Banned-copy lists cover "chuỗi ngày", "Huy hiệu", "Nâng cấp", "Mở khoá" and banned-icon lists cover `local_fire_department`, `military_tech`, `emoji_events` (`notebook_screen_test.dart:15-43`, `skill_profile_screen_test.dart:64-97`); both run in every asserted state. No gating branch exists in either screen. |
| Phase AC — two menu rows reachable from the "Tôi" tab | PASS | `me_screen.dart` adds both `_MenuRow`s inside `_PrivateStorageBlock` beside "Nhật ký riêng", with `showDivider: false` moved to the new last row. `me_screen_context_rows_test.dart:177-229` asserts both rows exist in the "My private storage" block and that each pushes its own screen as a route over `MeScreen` with no `TabBar`, and pops back. |
| Phase gate — l10n for chrome, asset packs for content | PASS | All fourteen new UI strings go through `app_vi.arb`/`app_en.arb` with descriptions; the seed chips and question prompt come from `req016.skill_seeds`/`req016.ask_questions` via `ContentPackageLoader` (`skill_profile_screen.dart:116-123`), not from l10n. |
| Phase gate — visual fidelity for screens (2) and (3) | PASS | Six PNGs present at 415x900 against same-viewport references. I opened all six. Vietnamese diacritics render correctly at every weight ("Sổ tay người yêu", "Những gì bạn giỏi", "Chọn nhạc hợp cảnh", "Cà phê sữa đá"); no glyph rasterises as a notdef box; `Icons.more_horiz` draws as the three-dot glyph, not a box. The two disclosed harness artifacts (blank iOS title band from `BackdropFilter`, no device chrome) are real and correctly attributed — the `-md.png` pair evidences both titles. The twelve `DESIGN_SPEC_CONFLICT` entries are each traceable to a binding AC or spec clause and none of them is an implementation gap. |

No BLOCKING or PATCH_REQUIRED finding in this slice.

## Findings

### F1 — LOW, P1-owned, carry to final synthesis. The carried tie-break note is wrong as written; the underlying flake is real in a different form.

Adjudication of the carried note: **not blocking for P4**, and its stated premise
does not hold at HEAD.

- The premise "`ContextNotebookRepository.entries()` has no stable tie-break on
  equal `createdAt`" is false at HEAD. `context_notebook_dao.dart:29-32` orders
  `desc(createdAt), desc(id)`, and `:67-70` orders `asc(createdAt), asc(id)`.
  Both queries are fully deterministic.
- The stated symptom is also not reproducible in the committed evidence. I read
  `implemented-2-so-tay-nguoi-yeu-ios.png` and `implemented-2-so-tay-nguoi-yeu-md.png`
  side by side: both render the interests in the identical order (Phim kinh dị
  Hàn / Đi bộ ven hồ / Cà phê sữa đá) and the events in the identical order
  (Sinh nhật / Ngày quen nhau). There is no cross-capture divergence to see.

What is real: the tie-break key is a `Random.secure()` UUID
(`context_notebook_repository.dart:265-278`), and `DateTimeColumn` on this
database is stored at Drift's default one-second granularity — `cupid_database.dart:41-65`
declares no `storeDateTimeAsText`/options override. So rows written inside the
same second are ordered **arbitrarily but stably**, not by insertion order. That
is visible inside a single capture: the same `implemented-2-...-ios.png` shows
interests newest-first while its events read oldest-first, and
`implemented-3-...-md.png` shows the four skills as Chọn nhạc hợp cảnh / Gói quà
đẹp / Nhớ dai / Nấu bữa sáng, which is neither the insertion order nor
alphabetical.

This contradicts the repository's own documented contract —
`context_notebook_entry_point.dart:31` ("Newest first") and `:35` ("Oldest
first, so a seed tapped early keeps its place"). User reachability is narrow but
not zero: tapping two seed chips in the ask card within one second writes two
rows in the same second, after which their relative order is arbitrary and then
frozen.

Not blocking for P4 because no cited AC and no clause of `uiux-spec.md` Phần B
or C imposes an ordering requirement on either screen. Recommend carrying to
final synthesis as a P1-owned follow-up: either store the timestamp at
sub-second precision or make the tie-break a monotonic sequence, and align the
two doc comments with whatever is chosen.

### F2 — LOW. Write-scope deviation: three files beyond the declared eight. Disclosed.

The phase declares 8 files; the P4 commit `4388b9f` also touches:

- `mobile/test/features/context_notebook/visual_capture_test.dart` (new) — the
  `RepaintBoundary` capture harness the phase's own Test Scope requires as the
  fallback when the screens are unreachable by navigation.
- `mobile/test/features/account/me_screen_context_rows_test.dart` (new) — the
  navigation-integration test the phase's Test Scope requires; it could not go
  in either declared test file because it needs the `MeScreen` DI harness.
- `mobile/test/features/account/presentation/screens/me_screen_test.dart`
  (edited, +7/-1) — pure test-fixture repair: the two new rows push lower
  content past the fold of the default 800x600 test frame, so three `tap()`
  calls needed `ensureVisible` and one scroll widened from -400 to -800.

All three are test-only, all three are disclosed in `coding-plan/test-results.md`
lines 37-40 and 45-57, and each is required by the phase's own Test Scope
section, which the declared Write Scope simply failed to enumerate. No product
file outside the declared scope was touched. Accepting as a disclosed deviation
rather than a defect; the Write Scope list is what was wrong.

### F3 — INFO. The visual-fidelity report's "Observation for the reviewer" is stale.

`visual-fidelity/visual-fidelity-report.md` lines 136-144 state that the ios and
md notebook captures disagree on interest order and that `entries()` "appears to
have no stable tie-break". Neither holds against the committed files at HEAD
(see F1). Recommend Scrum Master have that paragraph rewritten to the F1
characterisation before the story's final synthesis, so the follow-up is filed
against the right cause. This does not affect the `VISUAL_FIDELITY: PASS` line —
every other claim in the report checked out against the images.

### F4 — INFO. `eventOn` is written by nothing and rendered by nothing.

`_NotebookRow` renders `value` and `detail` only (`notebook_screen.dart:316-334`),
and the inline add row has no date field, so an event's `eventOn` is neither
shown nor editable; `_update` passes it through unchanged
(`notebook_screen.dart:87-97`). Harmless today: no writer populates it — the ask
flow calls `addEntry` without `eventOn` for both notebook targets
(`ask_on_the_spot_cubit.dart:151-165`), and the capture harness stores dates in
`detail`, not `eventOn`. Flagging only because the field would become silently
invisible and uneditable the moment a later story starts writing it, which would
put it at odds with AC-4's "sửa được và xoá được". P1/P3-owned schema question,
not a P4 screen defect.

### F5 — INFO. Evidence-path correction in the handoff does not apply to P4.

The handoff warned that test evidence lives in the story-root `test-results.md`
rather than `coding-plan/test-results.md`. For P4 the opposite is true. I checked
both: the story-root file carries P1, P2, P3 and P5 and has no P4 section;
`coding-plan/test-results.md` line 3 states it was created by the P4 run, and its
P4 section is lines 5-98. Cite `coding-plan/test-results.md` for P4, P6 and P7.

## Residual risks

- **Repo-wide `flutter analyze lib test` still exits 1.** The phase's declared
  build/type-check command is `flutter analyze lib test`, which fails on a
  pre-existing 217-issue `info` baseline (`prefer_initializing_formals`,
  `deprecated_member_use` for `withOpacity`, `unnecessary_import`). The
  implementer recorded the scoped analyze over exactly this phase's files as
  `No issues found!` and the repo-wide run with `--no-fatal-infos
  --no-fatal-warnings` as exit code 0 (`coding-plan/test-results.md` lines
  59-86). The baseline predates the story, but it means the phase's literal gate
  command is red and will stay red for every later phase and for the requirement
  integration review. Requirement-level decision, not a P4 defect.
- **Visual evidence is a widget-test `RepaintBoundary` render, not a device
  screenshot.** Legitimate under the phase's own Test Scope, which authorises
  exactly this fallback when a screen is not reachable by navigation during the
  capture run. Consequence: layout is evidenced, but nothing here proves the
  screens behave on a real device — no `MOBILE_RUNTIME_UNAVAILABLE` blocker was
  raised, and no device or simulator run exists for this story. Worth one
  end-to-end device pass at requirement integration.
- **AC-11's four required labels are pinned by P2's `requiredSkillSeedIds`, not
  by this slice.** `skill_profile_screen_test.dart` asserts the ids render, with
  fixture labels ("Mồi <id>"), so the literal Vietnamese strings AC-11 names are
  guaranteed by the P2 content gate. I confirmed the shipped labels visually in
  `implemented-3-ho-so-ky-nang-phien-ban-toi-ios-empty.png`; there is no widget
  test in this slice that would go red if the pack's labels changed.
- **The ask card's height on screen (3).** The full-width stacked option buttons
  fill nearly the whole viewport with ten seeds, pushing "+ tự thêm" to the
  fold. Compliant with Phần A and AC-11 as written, and the same observation is
  already recorded against screen (5) in the P7 half of the visual-fidelity
  report. Flagging as one component-level question for final synthesis, not two.

REVIEW_SLICE_COMPLETE: YES
