# Review Slice S2: phase-P2 + phase-P7 — resolver, phase line, countdown

Phase: SCOPED_SLICE
REVIEW_SLICE_COMPLETE: YES
Slice: S2 (`review/scope-gate.md` → `## Source/Test Files In Scope` → S2 bullet)
Story: STORY-012_phase_status_and_widget
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
BaseHead: `b58afbe073eff4e1ebb9151735221532a9cf5a82`

## Files Reviewed (8, all added in this diff)

`git diff --stat b58afbe0 -- <the 8 paths>` → `8 files changed, 1972 insertions(+)`,
zero deletions, i.e. every file below is new in this story.

| File | Lines added |
|---|---|
| `mobile/lib/features/phase_status/domain/solo_phase.dart` | 79 |
| `mobile/lib/features/phase_status/domain/solo_phase_resolver.dart` | 115 |
| `mobile/lib/features/phase_status/data/phase_status_prefs.dart` | 120 |
| `mobile/lib/features/phase_status/presentation/phase_status_cubit.dart` | 345 |
| `mobile/lib/features/phase_status/presentation/phase_status_line.dart` | 80 |
| `mobile/test/features/phase_status/solo_phase_resolver_test.dart` | 520 |
| `mobile/test/features/phase_status/phase_status_line_test.dart` | 541 |
| `mobile/test/features/phase_status/phase_status_prefs_test.dart` | 172 |

No file outside the S2 inventory was read. Other slices' files were not opened.

## Test Evidence

Command (run from `<Worktree>/mobile`, full unfiltered output):

```
flutter test test/features/phase_status/solo_phase_resolver_test.dart \
             test/features/phase_status/phase_status_line_test.dart \
             test/features/phase_status/phase_status_prefs_test.dart
```

Result: `All tests passed!` — `00:01 +58 ~4`, exit code 0.
58 passed, 0 failed, 4 skipped. The 4 skips are the `rendered evidence` group in
`phase_status_line_test.dart:526-540`, gated by
`const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS')` and
therefore skipped whenever the capture define is absent. They write PNGs, they
assert nothing, so their skip removes no assertion from this slice.

`git status --porcelain` in the worktree after the run shows only the untracked
`review/slice-S1.md` — the run did not rewrite any tracked
`visual-fidelity/*.png` or any other artifact.

## AC Verdicts

### AC-2 (`story_master.md` §Acceptance Criteria 2 — SB-84, four widget phases) — PASS

- `solo_phase.dart:10-14` defines exactly the four phases with the ASCII wire
  values `waiting · upcoming · date_day · quiet`; asserted in
  `solo_phase_resolver_test.dart:53-58`.
- `solo_phase_resolver.dart:31-68` is the single "which phase is the nearest
  card in" answer, and `phase_status_cubit.dart:153` is its only production call
  site, so the drawn line and the widget payload cannot be derived twice.
- `phase_status_cubit.dart:162` publishes that same `PhaseResolution` object
  through `PhaseWidgetPublisher.pushWidgetPayload`; the payload and the sentence
  share one resolution by construction, not by convention.
- `upcoming → date_day` is covered on both sides: a card dated today resolves to
  `dateDay` (`solo_phase_resolver_test.dart:68-84`), a future card to `upcoming`
  (`:86-106`), and each publishes its own resolution
  (`phase_status_line_test.dart:438-455`, `:481-491`).
- `fromWireValue` returns `null` for an unknown identifier instead of defaulting
  to a member (`solo_phase.dart:22-29`, test `:60-64`), so a native-boundary typo
  surfaces rather than silently becoming `quiet`.

Scope caveat, not a defect of this slice: whether the Android/iOS widget actually
*renders* four distinct contents for those four wire values is S3/S4 code and is
not verifiable here. S2 establishes the model and the publish seam only.

### AC-3 (`story_master.md` §Acceptance Criteria 3 — SB-86 countdown) — PASS

Same behaviour as AC-14 below; see that entry. Verified through
`civilDaysUntil` plus the per-card countdown assertions in
`phase_status_line_test.dart:367-434`.

### AC-14 (`requirements/requirements.md:162-163`, Nhóm D — đếm ngược) — PASS

- `phase_status_line.dart:19-26` `civilDaysUntil` normalises both sides to UTC
  midnight before subtracting, so the answer is a calendar-day count and a
  23h/25h DST day still counts as one day.
- Unit assertions (`phase_status_line_test.dart:417-434`): `2026-09-20` from
  `2026-09-16` → `4`; same day → `0`; a past date → `-15`; a 23:59 clock time on
  the same civil day still → `4`; an unparseable string → `null`.
- Rendered assertions: the phase line for `upcoming` fills the package
  placeholder with `4` and never leaves `{n}` visible (`:292-307`); the per-card
  countdown reads `còn 4 ngày` and no `:` (clock time) appears anywhere in the
  tree (`:368-378`); the date day itself reads `Hôm nay`, not `0 ngày`
  (`:404-415`).
- `phase_status_cubit.dart:185-188` computes `days` **only** for
  `SoloPhase.upcoming` with a non-null `scheduledOn`, so no other phase can
  reach a number. Confirmed for `dateDay` by the "no digit at all" assertion
  (`phase_status_line_test.dart:309-317`).

Scope caveat: the widget that owns the `activity_card_countdown_<id>` key —
`activity_card_tile.dart` — is S6b. This slice asserts its output through a
widget test but cannot review its source or the origin of the literal
`còn 4 ngày` / `Hôm nay` strings (R-15a hard-coded-copy question). Routed to S6b
/ final synthesis as **RSK-S2-3**.

### AC-15 (`requirements/requirements.md:165-167`, Nhóm D — ngày hẹn đã qua) — PASS

- `solo_phase_resolver.dart:80` skips any `scheduled` card whose
  `scheduled_on < today` rather than folding it into `upcoming`. A missed date
  therefore matches no branch and the story falls to `quiet`.
- Asserted three ways: a single past card → `quiet`, `cardId` and `scheduledOn`
  both `null` (`solo_phase_resolver_test.dart:390-405`); a past date loses to a
  future one instead of winning as "nearest" (`:407-427`); and at the rendered
  layer, a past date draws no countdown, keeps the plain date on the card, and
  produces no phase line at all (`phase_status_line_test.dart:380-402`).
- No reproach surface can exist because no negative `days` value ever reaches
  copy: `civilDaysUntil` is only called on the `upcoming` branch, where
  `scheduledOn > today` by construction, so `days >= 1` always.
- Structural guard: `solo_phase_resolver_test.dart:457-477` scans the stripped
  source of `solo_phase.dart` + `solo_phase_resolver.dart` for `Duration`,
  `inDays`, `inHours`, `.difference(`, `daysUntil`, `daysLeft`, `elapsed` and
  requires all absent, so the phase types have nowhere to put an elapsed count.

## Invariant R-1b (cấm đo lường hành vi người kia)

PASS within slice scope.

- `solo_phase_resolver.dart:98-115` reads only `invited` + `replyState ==
  notAnswered`, the user-set flag STORY-001 AC-17 defines. No other-party field
  is read.
- The `waiting` branch is constructed with no `scheduledOn`
  (`solo_phase_resolver.dart:64`), so the type itself cannot report how long a
  wait has lasted. Asserted at `solo_phase_resolver_test.dart:429-455`: waiting
  is byte-identical whether the invite is 1 day or 8 months old.
- Rendered: the waiting line and its secondary carry no digit anywhere, and no
  countdown key exists for a waiting card (`phase_status_line_test.dart:350-364`).
- `solo_phase_resolver_test.dart:483-510` scans for 15 forbidden
  partner-behaviour identifiers (`partnerSeenAt`, `openedCount`, `replyLatency`,
  `responseRate`, `lastSeen`, `viewedAt`, …) and requires all absent.

Weakness recorded, not a blocker: that scan is a substring match on identifier
*names*. It cannot catch a partner-behaviour quantity introduced under a name
not on the list. It is non-vacuous today only because `ActivityCard` exposes no
such field. See **RSK-S2-2**.

## Symbol Checks From The Handoff

| Symbol | Found | Where |
|---|---|---|
| `PhaseStatusCubit` | YES | `phase_status_cubit.dart:113` |
| `PhaseStatusState` | YES | `phase_status_cubit.dart:35` |
| `civilDaysUntil` | YES | `phase_status_line.dart:19`, used at `phase_status_cubit.dart:187` |
| `WIDGET-STALE` | YES | named at `phase_status_cubit.dart:23`; enforced by the publish-once-per-resolution test `phase_status_line_test.dart:437-479` |
| `_anchorIndex` | **NO** | absent from all five S2 lib files |

`_anchorIndex` does not exist anywhere in the S2 inventory. It is most likely a
member of `activity_card_hub_view.dart` (S6b). The handoff's query-key list is
wrong for this slice, or the symbol belongs to another slice. Recorded as
**F-S2-3** so final synthesis re-routes it rather than treating it as verified.

`WIDGET-STALE` verification detail: the publisher is called exactly once per
mount (a list rebuild does not re-publish — `phase_status_line_test.dart:438-455`),
and once more after a full background/foreground lifecycle cycle
(`:457-479`). A phase with no screen line still publishes (`:481-491`), so the
widget never goes unfed because the screen had nothing to say.

## Findings

### F-S2-1 — `resolveSoloPhase`'s `beforeYouGo` parameter has no production caller (SHOULD_FIX)

`solo_phase_resolver.dart:34` accepts `BeforeYouGoPhase? beforeYouGo` and
`:46-51` uses it to override `cardId` and to carry `isBeforeYouGoDismissed`.
The only production call site, `phase_status_cubit.dart:153`, is:

```dart
resolution = resolveSoloPhase(cards: cards, today: today);
```

— no `beforeYouGo` argument, and `PhaseStatusCubit`'s constructor
(`phase_status_cubit.dart:114-129`) takes no before-you-go dependency at all.
Consequence: in production `PhaseResolution.isBeforeYouGoDismissed` is
permanently `false` and `cardId` is always the card's own id. The enrichment
path is exercised only by
`solo_phase_resolver_test.dart:188-279`.

Why this matters: `requirements.md:108-110` (Group A AC-2) permits the
date-derived fourth phase as the **degraded** path taken when STORY-006 has not
been delivered. `before_you_go/domain/before_you_go_resolver.dart` exists and
compiles in this worktree (it is imported by
`solo_phase_resolver_test.dart:5` and that test passes), so STORY-006 appears
delivered — yet the app is running the degraded path.

Why it is not a FAIL of AC-2 here: the *phase* is still correct on date day, and
whether any surface consumes `isBeforeYouGoDismissed` is S3/S4/S6b code this
slice may not open. If no consumer exists, the field is merely dead and this is
cosmetic; if the Android/iOS widget branches on it, AC-1/AC-2 reflection is
broken in production. **Final synthesis must resolve this against the S3/S4/S6b
reports before the story outcome is set.**

### F-S2-2 — `_scanLimit` doc claim is stronger than the code guarantees (SHOULD_FIX)

`phase_status_cubit.dart:132-134` states that a deeper page "cannot change the
answer for any realistic store", and `:301-309` reads the first 50 `scheduled`
and first 50 `idea` cards. That claim holds only if
`ActivityCardRepository.cardsByStatus` orders `scheduled` cards by
`scheduled_on`. If it orders by `updated_at` or `created_at`, a user with more
than 50 scheduled cards can have the nearest future date fall outside the window,
and the countdown (AC-14) would then point at the wrong card or vanish.

`activity_card_repository.dart` is STORY-001 code and is in no slice inventory,
so the ordering could not be checked here. Recorded rather than asserted.

### F-S2-3 — handoff query key `_anchorIndex` does not exist in S2 (INFO)

See the symbol table above. No action inside this slice; final synthesis should
confirm the symbol was verified by whichever slice actually owns it.

### F-S2-4 — `phase_status_prefs.dart` carries no S2 acceptance criterion (INFO)

The file is in the S2 inventory but every key it owns belongs to P3/P6 surfaces
(drip cursor, milestone cursor, evening check-in / quiet-drip toggles). It is
correct on its own terms — 17 assertions pass, key strings are asserted
literally (`phase_status_prefs_test.dart:17-49`), `clearReminded` removes the key
rather than writing a sentinel (`:63-70`), both notification toggles default to
`true` without a first-run write (`:120-137`), and `dripSeenIds` returns an
unmodifiable list (`:98-103`). Its *behavioural* verdicts against AC-16/AC-17,
AC-22 and BR-9 belong to S5 and S6a, which own the consumers.

## Residual Risks

- **RSK-S2-1** — F-S2-1: the before-you-go reflection is wired in the resolver
  but not in the cubit. Blast radius depends on S3/S4 widget content.
- **RSK-S2-2** — the two source-scanning guards
  (`solo_phase_resolver_test.dart:457-477` and `:483-510`) are literal
  substring scans over stripped source. They are strong against the named
  regressions and blind to an unnamed one.
- **RSK-S2-3** — the literal strings `còn 4 ngày` and `Hôm nay` are asserted
  from this slice but produced by S6b code. Whether they come from the l10n ARB
  or from a Dart literal (R-15a) is an S6b question.
- **RSK-S2-4** — F-S2-2: `_scanLimit = 50` correctness depends on STORY-001
  repository ordering that no slice inventory covers.
- **RSK-S2-5** — the 4 visual-capture tests skip by default, so the four
  `implemented-hub-*.png` files under `visual-fidelity/` were produced by an
  earlier capture run and are not re-proven by this pass. The gate-level
  visual-fidelity gap (zero `design-reference-*.png`, no
  `visual-fidelity-report.md`) is already finding G-1..G-3 in
  `review-report.md`; this slice adds nothing to it and does not close it.

## Not Reviewed In This Slice

Widget rendering (S3 Android, S4 iOS), evening check-in (S5), counter /
milestone / drip behaviour (S6a), quiet surfaces and hub/card integration
(S6b), content packages and the invariant gate (S1), build/static-analysis,
runtime startup smoke, entry-point reachability, and the story-level outcome.
No `Outcome:` is set here by design — that belongs to `final-synthesis`.
