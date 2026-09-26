# Review Slice S6a — phase-P3 bộ đếm, cột mốc J12, nhịp nhỏ giọt

Review type: `scoped-slice`
Slice: S6a (per `review/scope-gate.md` §Source/Test Files In Scope → S6a)
Story: STORY-012_phase_status_and_widget
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
BaseHead: `b58afbe073eff4e1ebb9151735221532a9cf5a82`

REVIEW_SLICE_COMPLETE: YES

## Files Reviewed (7, all in slice scope)

| File | Diff vs BaseHead |
| --- | --- |
| `mobile/lib/features/phase_status/domain/wealth_counter.dart` | +25, new |
| `mobile/lib/features/phase_status/domain/milestone_resolver.dart` | +94, new |
| `mobile/lib/features/phase_status/domain/drip_cadence_policy.dart` | +71, new |
| `mobile/test/features/phase_status/wealth_counter_test.dart` | new |
| `mobile/test/features/phase_status/milestone_resolver_test.dart` | new |
| `mobile/test/features/phase_status/drip_cadence_policy_test.dart` | new |
| `mobile/lib/l10n/arb/app_vi.arb` | +41, zero S6a keys — see N-1 |

Governing text read: `story_master.md` AC-5/AC-6 + `## Out of Scope`;
`requirements/requirements.md` AC-22..AC-29 (L196-232) and BR-1..BR-17 (L289-361),
ranged reads only (file is 30.9 KB).

## Verdicts

| Item | Verdict | Evidence |
| --- | --- | --- |
| AC-5 (bộ đếm phản ánh đúng số kỷ niệm, tăng khi thêm) | PASS (domain layer) | `wealth_counter.dart:23-24` returns `countsByStatus[ActivityCardStatus.memory] ?? 0`; `memory` is the *Đã thành kỷ niệm* status (`activity_cards/domain/activity_card.dart:12`). `wealth_counter_test.dart:33-42` asserts growth, `:44-53` asserts a drop only on set shrink (AC-29). The on-screen rendering of the value is S6b scope, not verified here. |
| AC-6 (không streak / chuỗi ngày / bảng xếp hạng) | PASS (within slice) | No time parameter exists anywhere in the counter API (`wealth_counter.dart:23`), enforced by a source-level guard (`wealth_counter_test.dart:104-124`) that is non-vacuous: a top-level function taking a clock would match its regex. `MilestoneResolver` exposes no target, no remaining distance, no next threshold (AC-27/BR-7). `DripCadencePolicy` exposes no remaining count and no progress. The app-wide sweep AC-6 literally asks for is a final-synthesis item, not a slice item. |
| BR-2 (suy giảm êm là hành vi đúng) | PASS | `milestone_resolver.dart:67-70` returns `null` when the pack holds no milestone item and — verified at `:72`, ordering — does *not* burn the threshold, so a later good pack still announces (`milestone_resolver_test.dart:151-156`). `drip_cadence_policy.dart:56` returns `null` on an empty/exhausted pack with no cursor write (`drip_cadence_policy_test.dart:171-181`), and `:63-71` treats an unparseable cursor as "no record" rather than permanent silence. No error state and no inviting empty slot is produced anywhere in the slice. |
| BR-4 (pha "đang đợi" nói về VIỆC, không nói về NGƯỜI) | PASS (nothing in slice can violate it) | The three domain files emit no waiting-phase content: the counter returns an `int`, the resolver returns an authored `NudgeItem`, the policy returns an authored `DripItem`. The 41 ARB lines in the diff are S5 chrome (evening check-in sheet + notification rows); none names or describes the other party. Authoring of the phase-content strings themselves is S1 scope (`phase_content_gate.dart`). |
| BR-9 (trần nhỏ giọt: tối đa một lần/tuần, không bao giờ hằng ngày) | PASS | `drip_cadence_policy.dart:11` `dripMinimumDaysBetweenShows = 7` is a file-level constant, explicitly not derived from pack size, matching BR-16's "trần tần suất BR-9 không phải N". Gate at `:41` (`elapsedDays < 7 → null`) gives day+6 silent / day+7 eligible (`drip_cadence_policy_test.dart:62-74`). An 8-week daily-open simulation holds the ≥7-day spacing (`:76-97`). Civil-day arithmetic is done at UTC midnight (`:63-71`), so a DST week still counts seven days (`drip_cadence_policy_test.dart:99-111`). An exhausted pack does not widen the window (`:183-195`). |
| BR-14 (nội dung story này nói về tài sản/việc của chính người dùng) | PASS | No string in the three domain files reaches a user; all display text is authored data carried through (`MilestoneResolution.item`, `DripItem`). The only drip-adjacent user-facing string in the diff, `notifs_row_quiet_drip_sub` = "Tối đa một lần mỗi tuần.", describes the user's own cadence setting and is factually consistent with `dripMinimumDaysBetweenShows = 7` — no drift between the promise and the enforcement. |

## Test Evidence

Command run in `<Worktree>/mobile`, full output read (not filtered):

    flutter test test/features/phase_status/wealth_counter_test.dart \
      test/features/phase_status/milestone_resolver_test.dart \
      test/features/phase_status/drip_cadence_policy_test.dart

Result: `00:00 +33: All tests passed!` (8 + 12 + 13). Worktree `git status --porcelain`
after the run shows no modified tracked file, so the run dirtied no sibling
story's evidence.

## Findings

### F-1 (non-blocking here; cross-slice verification required) — consume-on-resolve

Both stateful resolvers commit their durable cursor *before* the caller has
drawn anything:

- `milestone_resolver.dart:72` — `await _prefs.setMilestoneLastShownValue(crossed);`
  runs on the same path that returns the resolution.
- `drip_cadence_policy.dart:51-52` — `setDripLastShownOn` + `markDripSeen` run
  before the item is returned.

A call that resolves but never paints (disposed screen, discarded rebuild, a
speculative resolve on a surface that then decides not to show) permanently
swallows that milestone or that drip line; for the milestone there is no second
chance, which is what AC-28 ("app dừng ở chỗ hiển thị cột mốc đó") actually asks
for. This is not provable as a defect inside S6a — the call sites are
`phase_status_cubit.dart` (S2) and `gift_progress_block.dart` /
`wealth_counter_line.dart` (S6b). Route to final synthesis: confirm every caller
paints whatever `resolve`/`nextItem` returns in the same frame and never
resolves speculatively.

Related doc inaccuracy in the same area: `drip_cadence_policy.dart:26-28` claims
the result is "identical for two surfaces resolving seconds apart". It is not —
the first caller consumes and the second gets `null` from the cadence gate at
`:41`. The behaviour is correct (it is what prevents a double show); the comment
describes a different guarantee than the code provides.

### N-1 (scope note, no action) — `app_vi.arb` carries no S6a keys

`app_vi.arb` is listed in the S6a inventory, but its whole diff vs BaseHead is
41 lines of S5 content (`notifs_row_*`, `evening_check_in_*`). There is no
wealth-counter, milestone, or drip *content* string in the ARB at all, which is
the correct outcome under BR-15/R-15a (content is authored data with durable
ids, not strings in code). Reviewed here only for the BR-9 consistency check
recorded above; S5 owns these keys for AC-32/BR-10 purposes. S6b should still
confirm that `wealth_counter_line.dart` / `gift_progress_block.dart` draw their
labels from the content packages rather than from hard-coded strings, since the
ARB gives them no key to use.

### N-2 (scope boundary) — inputs not verified in this slice

`thresholds` reaches `MilestoneResolver` from the `nudges.v1.json` package root
and the drip pack from `drip.v1.json`; both packages and their schema gate are
S1 scope. The notification/drip on-off toggle (AC-7/AC-32) is enforced by the
caller, not by `DripCadencePolicy`, and is S5 scope.

## Slice Recommendation

All six named items PASS within the slice boundary; no blocking finding
originates in S6a. Carry F-1 into the final synthesis as a call-site check
against AC-28, and N-1 into S6b as a hard-coded-string check against BR-15.
