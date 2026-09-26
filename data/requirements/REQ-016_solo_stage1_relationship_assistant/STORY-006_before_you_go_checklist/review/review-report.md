---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-09-11
reviewed_by: Reviewer
---

# Review Report: STORY-006 "Trước giờ đi" — checklist tất định (SB-211)

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `full-story-review`
- Scope Gate:
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-006_before_you_go_checklist/review/scope-gate.md`
- Requirements: `requirements/requirements.md` — AC-1..AC-31, BR-1..BR-17,
  `## Open Question Impact`
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: `ux/uiux-spec.md` not re-read; its two divergences from the shipped pack
  are already logged in `test-results.md` `### Lệch cần ghi nhận` and are
  AC-governed (AC-29/BR-15), not defects.
- Architecture: `architecture/solution.md` §1 Key Discovery 1-3 (mount point,
  absent pay-on-site field, region derivation)
- Coding Plan: `coding-plan/phase-P2-detail-screen-block-and-dismissal.md`
  (§6 verification scope, queried not re-read)
- Test Results: `coding-plan/test-results.md` `## Phase P1`, `## Phase P2`
- Previous review findings: `N/A` — first review pass.

## Reviewed Scope

- Story complexity: `standard`
- Bug status: `N/A`
- Code scope reviewed: the 12 handoff-named files. Diff baseline
  `git -C <Worktree> diff 1837a6b8` confirms only `story_master.md` and
  `activity_card_detail_screen.dart` are modifications (+26 lines, mount point
  only); the `before_you_go` module, the shipped pack, and the four test files
  are new and untracked.
- Evidence reviewed: `test-results.md` P1/P2 command tables and coverage
  tables; `visual-fidelity/visual-fidelity-report.md`; all three PNGs opened
  and inspected.
- Risk surfaces reviewed: mobile interaction, mobile
  navigation/discoverability, local storage/offline, typed content-pack
  contract + `BeforeYouGoPhase` handoff to STORY-012, permissions/device API
  (OS Share Sheet), app lifecycle.
- Critical gates reviewed: static analysis, targeted unit/widget tests, host-
  screen regression, content-gate negative control, no-hardcoded-label scan,
  determinism / no-clock-read, no-network, visual fidelity, entry-point
  reachability, runtime startup smoke.
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `PASS`
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `PASS`
- Requirement mobile visual audit: `NOT_APPLICABLE` at story level — the
  requirement-level `integration-review/mobile-visual-audit.md` is a separate
  gate at requirement closure (rule 12g2). Per-story visual fidelity is
  present and passes.
- Story artifacts reviewed: `story_master.md`, `requirements/requirements.md`,
  `architecture/solution.md` §1, `coding-plan/test-results.md`,
  `visual-fidelity/`
- OQ context reviewed: `## Open Question Impact` — OQ-3 closed 2026-09-06 by
  D-15 → R-15. No open question blocks this story.

## Outcome Summary

- Review outcome: DEFERRED_ONLY (round 2; round 1 was PATCH_REQUIRED)
- Rationale: the implementation was already correct and well-traced in round 1
  — every AC group resolves to real code and a real assertion, the content-gate
  negative control is genuinely non-vacuous, and the visual-fidelity evidence
  holds up when the images are opened rather than counted. The only two
  blocking findings were missing evidence sections, and both are now present
  and substantive (see `## Round 2 Re-verification`). No code defect was ever
  found, and no source file changed between the two rounds. What remains is two
  non-blocking deferred items, neither of which belongs to this story's write
  scope.
- Blocking findings: 0 (2 in round 1, both closed)
- Deferred findings: 2
- Dismissed observations: 1

## Traceability Summary

- Requirements: AC-1/AC-2/AC-3 resolve in `BeforeYouGoState.isVisible` and
  `BeforeYouGoPhase.fromCard` (status `scheduled` AND `scheduledOn ==` today's
  civil date), asserted by the `when the block does not apply` group including
  the non-scheduled-status sweep. AC-4/AC-5/AC-6 hold structurally: the diff
  mounts `BeforeYouGoSection` at `activity_card_detail_screen.dart:455`,
  immediately after `_primaryAction(...)` inside the existing column, adding
  no route; the block's own action is an outline pill, never `gradientHot`.
  AC-7/AC-8/AC-9/BR-4 come from `_clauseHolds` returning false on any `null`
  fact — the sparse-card and indoor cases are asserted against the pack read
  off disk. AC-10 holds because `today` is a parameter threaded from the
  detail screen and `resolveHints` reads no clock and no I/O. AC-11 resolves
  the region by normalised whole-token alias match with `rainySeason == null`
  on a miss, never a default. AC-12/AC-13/AC-14: an empty resolve renders
  `SizedBox.shrink()`, hiding the title too, and no prompt to fill more fields
  exists anywhere in the module. AC-15/AC-16/AC-17 map to
  `dismiss`/`reopen` plus the collapsed one-line row with `Mở lại`; closing
  writes one key and touches no card status. AC-18/AC-19/AC-20:
  `SharePlus.instance.share` fire-and-forget, result discarded, and the
  regression test asserts `prefs.getKeys()` stays empty after a share.
  AC-21 holds because nothing observes whether the share row was tapped.
  AC-22/AC-23: the only external read is `rootBundle.loadString` on the
  shipped asset — no HTTP client, no model call. AC-24/BR-11:
  `BeforeYouGoPhase` is a plain value object with no widget code.
  AC-25/AC-26/AC-27 are enforced by the gate's shared invariant lexicon plus
  the family-specific `completionCount` / `partnerDirectedTone` rules, and the
  block ships no checkbox, no tally, no mint done-state.
  AC-29/AC-30/AC-31/BR-15..BR-17 are the strongest part of the story: labels,
  icons, conditions and the distance threshold all live in
  `before_you_go.v1.json`, the closed DSL rejects unknown facts/ops/keys at
  load rather than degrading, and 17 violating-row cases plus one clean
  positive control prove the gate actually fires.
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: OQ-3 closed; R-15 applies and is satisfied by the content
  pack plus the runnable gate. No unresolved OQ affects this story, and no
  scope was over- or under-applied on OQ grounds.
- UX: the two `uiux-spec.md` §2 wording/icon divergences (`ev_station` vs
  `local_gas_station`; three label variants) are correct as shipped — AC-29
  puts label ownership in the pack, so the spec prose is what is stale.
- Architecture: `solution.md` §1 Key Discovery 2 already adjudicated that
  "hình thức trả tại chỗ" has no column on the STORY-001 card model and that
  BR-10 forbids adding one, so the AC-7 cash row collapses to `priceVnd > 0`
  as a data clause. Implementation matches that ruling exactly.
- Testing evidence: P1 — analyze clean, 64 tests, plus the two cross-module
  content-gate suites (65 tests) that scan all of `lib/` and are genuine
  regressions for a new module. P2 — analyze clean on
  `before_you_go`, 6 + 15 tests, and the §6 regression run
  `flutter test test/features/before_you_go/ test/features/activity_cards/`
  → `+298 ~4` with no regression, which is the right gate given a new block
  adds column height to the host screen.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Mobile interaction | AC-15..AC-21 | `before_you_go_block_test.dart` widget tests (15) + `flutter analyze` | PASS | dismiss/reopen/share/skip all asserted on the real detail screen |
| Mobile navigation & discoverability | AC-1/AC-5/AC-6 | `## Entry Point Reachability` + in-code confirmation | PASS | 4-step path recorded; code verified at `activity_card_detail_screen.dart:455` |
| Local storage / offline | AC-15/AC-16/AC-22 | `before_you_go_dismissal_store_test.dart` (6) | PASS | only `before_you_go.dismissed_on.<cardId>` written; `reopen` removes the key |
| Content-pack contract | AC-29/AC-30/AC-31, BR-15..BR-17 | `before_you_go_content_gate_test.dart` negative control (17 + 1 control) | PASS | non-vacuous; violating rows named by id |
| Determinism / no external call | AC-10/AC-11/AC-22/AC-23 | resolver purity tests + module clock scan | PASS | `today` is a parameter; only `rootBundle` asset read |
| Permissions / device API | AC-18/AC-19/AC-20 | one-tap share test asserting empty prefs | PASS | fire-and-forget, nothing recorded |
| Downstream contract (STORY-012) | AC-24/BR-11 | `BeforeYouGoPhase` value object + key naming test | PASS | no widget drawing in this story |
| Visual fidelity (mobile lane) | rule 12e2/12e3 | RepaintBoundary capture + design reference | PASS | see below |
| App boot | rule 12g | `## Story Runtime Startup Smoke` | PASS | shipped `main()` on emulator-5554; capture opened and verified |

### Visual fidelity verification

I opened all three PNGs rather than counting them.
`design-reference-sb-211-truoc-gio-di-ios.png` genuinely depicts the
`sb-211-truoc-gio-di` frame — the "Trước giờ đi" checklist screen recorded as
this story's `Design-Screen` — not a neighbouring frame or a placeholder.
`implemented-sb-211-truoc-gio-di-ios.png` shows the real
`ActivityCardDetailScreen` with the card-level `Chuẩn bị cho tươm tất`
gradient CTA above and the block below it: five rows, correct Vietnamese
diacritics throughout, every icon rasterised, no tofu, no error frame, no
spinner. The collapsed capture shows the muted `Trước giờ đi ✓` line with
`Mở lại` and no empty frame, which is AC-14/AC-16/AC-17 visible rather than
asserted. Nothing I see contradicts `VISUAL_FIDELITY: PASS`.

The RepaintBoundary-in-widget-test harness is the correct fallback here and I
verified it rather than re-capturing: the block only exists on a `scheduled`
card whose date equals the device's civil date, so no navigation path reaches
it without seeding a card and moving the device clock. The harness pumps the
real screen with the real theme, the shipped pack off disk, and the four
pubspec font families plus the framework `MaterialIcons-Regular.otf`, and is
skipped behind `--dart-define=CAPTURE_VISUALS` so the ordinary suite stays
hermetic.

All six `DESIGN_SPEC_CONFLICT` items check out against the images and against
the AC text I read directly. Each one is visible in the reference frame
(standalone screen chrome, per-row checkboxes with a mint tick and
strikethrough, full-width gradient CTA reading `Xong hết rồi, đi gặp Cún
thôi`, four hardcoded labels, the `4 việc nhỏ...` subtitle, the `CÒN 2 TIẾNG
15 NỮA LÀ GẶP` chip) and each cites a real, correctly-quoted binding AC
(AC-6/AC-5, AC-27, AC-4/AC-5, AC-29+BR-15+AC-30, AC-27+AC-30, AC-10). Under
this requirement's standing anchor decision — the canvas outranks
`uiux-spec.md` prose, never an AC — these six stay as built. They are not
re-litigated here and must not be patched toward the canvas.

## Round 2 Re-verification

Re-review date: 2026-09-11. Scope: the two round-1 blocking findings only, per
the re-review handoff. No source file changed in this round, which I confirmed
rather than accepted: `git -C <Worktree> diff --stat <BaseHead> -- mobile/`
still reports exactly one file changed, `activity_card_detail_screen.dart`,
`26 insertions(+)` — byte-identical in size to round 1 — and `git status
--porcelain` shows the same untracked set with no new source path.

**F-1 CLOSED.** `coding-plan/test-results.md` now carries
`## Story Runtime Startup Smoke` with `Status: PASS`, and it runs the shipped
`main()` rather than `main_preview.dart`, which is the distinction that makes
this gate meaningful. The build/install/launch chain is recorded end to end
with real signals: build exit 0 on
`app-arm64-v8a-local-debug.apk`, `adb install` → `Success`, `am start -W` →
`Status: ok` / `LaunchState: COLD` / `TotalTime: 7791`, a `dumpsys` readiness
probe naming the correct activity
(`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`), and 0
`FATAL EXCEPTION` / 0 `E/flutter` in logcat. The device is the registry's own
`mobile-app` entry target.

I opened `visual-fidelity/runtime-smoke-main-first-screen-emulator-5554.png`
myself rather than counting it. It is a genuine device capture, not a widget
render — the DEBUG ribbon, status bar and home indicator are all present — and
it shows screen (1) on the `Muốn làm` tab fully painted, not a splash or an
error frame: the heading `Bắt đầu từ một điều nhỏ nhé.`, both action cards,
the three chips `Gợi ý quà` / `Mồi chuyện` / `Vỏ hoàng đạo`, and all four
bottom-nav items. Vietnamese diacritics are correct in every string and no
glyph falls back to tofu.

The report is honest about the one thing the smoke does not prove: the card
list is empty on that device, so the run stops at screen (1) and never reaches
the block itself. That is the correct scope for a startup smoke — the block's
own behaviour is covered by the 15 widget tests that pump the real
`ActivityCardDetailScreen` and by the RepaintBoundary captures. The two
obstacles hit along the way (host disk full, then an all-ABI debug APK too
large for the device, worked around with `--split-per-abi`) are documented,
are machine/device infrastructure rather than product regressions, and neither
was worked around by changing code.

**F-2 CLOSED.** `## Entry Point Reachability` is present with `Reachable: YES`
and a 4-step table ending at `activity_card_detail_screen.dart:455`, placed
after `_primaryAction(...)` at line 450 and before the trailing spacer at 460
— which matches what I verified in the source myself in round 1 and what the
unchanged diff still shows. It states plainly that no route, menu entry or
toggle was added and that the `SizedBox.shrink()` branch on non-today cards is
AC-2/AC-3 behaviour rather than a broken entry point, which is the confusion
this section exists to prevent. It also notes the path is test-enforced: the
15 behaviour tests pump the real detail screen, so removing the mount point
turns them red.

## Blocking Findings

None. Both round-1 findings are closed and verified above; they are retained
below as the review record.

**F-1 (CLOSED in round 2) — `## Story Runtime Startup Smoke` was absent and
unwaived (rule 12g).**
`coding-plan/test-results.md` records analyze, unit, widget and regression
evidence but never proves the app boots with this change in it. For a mobile
lane the gate is that the app launches on the provided device/emulator and
reaches its first screen without a crash or an error screen. `story_master.md`
has no `Runtime-Smoke: WAIVED — <reason>` line and `req_master.md` has no
waiver either. This is not an environment blocker: the sibling mobile story in
this same requirement, `STORY-003_private_journal`, carries both the
`## Story Runtime Startup Smoke` section and
`runtime-smoke-main-first-screen-emulator-5554.png`. Every mount of this story
is a widget-test render; nothing in the evidence set has ever started the real
app. The DONE gate enforces this independently, so it will stop the story
again later if it passes here.

**F-2 (CLOSED in round 2) — `## Entry Point Reachability` was absent (rule
12e1).**
`story_master.md` records `UI-facing story: YES`, which makes this section
mandatory and non-waivable, and `test-results.md` does not contain it or a
`Reachable: YES` line. I verified the entry point independently in code and it
is correct — `BeforeYouGoSection` is mounted at
`activity_card_detail_screen.dart:455`, directly after `_primaryAction(...)`,
inside the existing detail column, so the block is reached by the ordinary
discoverable path of tapping a card on screen (1) and opens itself with no
extra gesture (AC-1), adding no route (AC-6). The finding is therefore the
missing evidence record, not a missing capability; the fix is to write down
the path that already works, with the second condition the block needs
(status `scheduled` AND `scheduledOn` = today) stated explicitly so a future
reader does not mistake the `SizedBox.shrink()` on every other card for a
broken entry point.

## Deferred Findings

**D-1 — `contract-summary.md` §1 documents the envelope key as `schemaId`
while the shipped JSON and `core/content/content_package.dart` both use
`schema_id`.** Documentation-only inaccuracy; the Dart property
`ContentPackage.schemaId` still equals `req016.before_you_go.v1` as AC-29
requires, and every other `req016` pack uses `schema_id` too. Already logged
in `test-results.md` `### Ghi chú hợp đồng`. Correct the contract summary
whenever that file is next in a write scope.

**D-2 — `test/features/activity_cards/activity_card_detail_screen_test.dart`
fixtures use `scheduledOn: '2026-10-01'`.** On that calendar date those
pre-existing tests begin exercising this story's block, because the detail
screen reads the real clock via `DateTime.now()` when
`BeforeYouGoOptions.today` is null and those fixtures pass no options. The
file is outside this story's write scope and the tests pass today, so this is
a dormant date-dependent fragility rather than a defect this story
introduced — but it is this story's block that will appear in them. Worth
pinning the clock in that suite before 2026-10-01.

## Implementation Action Items

None outstanding. Both round-1 action items were completed and verified in
round 2. No code change was required at any point, and none was made.

Do not patch the six `DESIGN_SPEC_CONFLICT` items toward the design canvas:
they are AC-compliant as built and were re-confirmed in both rounds.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: the story is merge-eligible. Run the story boundary `complete`
  step so `commit_sha` / `merge_sha` / `MERGE_COMPLETE` are recorded, then mark
  `DONE`. The two deferred items above are not gated on this story: D-1 is a
  documentation correction in `architecture/contract-summary.md`, and D-2 is a
  dormant date-dependent fixture in another story's test file that becomes
  active on 2026-10-01 — both are worth carrying into the requirement backlog
  rather than the merge.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
