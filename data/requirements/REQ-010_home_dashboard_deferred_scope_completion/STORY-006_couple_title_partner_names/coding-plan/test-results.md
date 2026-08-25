# Test Results — STORY-006 Couple Title Shows Both Partner Names

# Phase P0 (Backend: `partnerDisplayName` contract lock)

## Scope

Phase P0 — `phase-P0-users-me-partner-name-contract-lock.md`. Adds
`MeProfileResponseDto` (Swagger-only), `@ApiOkResponse` annotation on
`UsersController.getProfile`, and a new controller-level regression spec.
`users.service.ts` and `users.service.spec.ts` were not modified.

## Commands And Results

### Targeted unit tests

Command: `cd backend && npx jest src/modules/users`

```
PASS src/modules/users/users.service.spec.ts
PASS src/modules/users/users.controller.spec.ts

Test Suites: 2 passed, 2 total
Tests:       10 passed, 10 total
Snapshots:   0 total
Time:        0.988 s
```

- `users.service.spec.ts`: 7 pre-existing tests, unmodified, all pass —
  confirms `getProfileWithPartner` paired/unpaired/dangling-`partnerId`/null-
  `displayName` coverage is untouched.
- `users.controller.spec.ts`: 3 new tests, all pass — delegation to
  `getProfileWithPartner` (not `findByFirebaseUid`), `partnerDisplayName`
  present on the result, caller identity keys (`id`, `displayName`,
  `partnerId`, `isGhostModeEnabled`) preserved alongside it.

### Build / type-check

Command: `cd backend && npm run build`

```
> backend@0.0.1 build
> nest build
```

Exit code: 0. No TypeScript errors.

## Files Changed

- `backend/src/modules/users/dto/me-profile-response.dto.ts` (new) —
  `MeProfileResponseDto`, Swagger schema type only.
- `backend/src/modules/users/users.controller.ts` — added
  `@ApiOkResponse({ type: MeProfileResponseDto })` on `getProfile`; method body
  unchanged (still delegates to `usersService.getProfileWithPartner`).
- `backend/src/modules/users/users.controller.spec.ts` (new).

## Acceptance Criteria Verification

- `GET /users/me` documented in Swagger with `partnerDisplayName` and its
  nullable contract — DTO declares `partnerDisplayName: string | null` with
  the section-3 nullable semantics in its `@ApiProperty` description.
- Runtime response body unchanged — no interceptor, `plainToInstance`,
  `@Exclude`/`@Expose`, or serialization option introduced; `getProfile` still
  returns `this.usersService.getProfileWithPartner(req.user.uid)` directly.
- Controller-level spec fails if `getProfile` stops delegating to
  `getProfileWithPartner` or if `partnerDisplayName` disappears — asserted via
  `serviceMock.getProfileWithPartner` call check and `result.partnerDisplayName`
  assertion.
- `users.service.ts` and `users.service.spec.ts` untouched — confirmed by not
  editing either file; their existing 7 tests still pass unmodified.

# Phase P1 (Mobile: Home couple title + partner initial)

## Scope

Phase P1 — `phase-P1-home-couple-title-partner-name.md`. Maps
`partnerDisplayName` into `CupidProfile` and renders the `"<self> & <partner>"`
title plus the partner avatar initial in the Home couple-presence header, with
an honest self-name-only degraded state and an ellipsis overflow affordance.

Run date: 2026-08-25. Worktree:
`.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-006`.
BaseHead: `d124f68bcfb79530cb003dd55b2be1393f5d2ad7`.

## Commands And Results

### Targeted tests

Command:

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test \
  test/features/home/home_screen_test.dart \
  test/features/account/domain/cupid_profile_test.dart
```

Result: **17 passed, 0 failed** (`00:00 +17: All tests passed!`).

Breakdown — 14 widget tests in `home_screen_test.dart` (8 pre-existing, 6 new)
and 3 unit tests in `cupid_profile_test.dart` (2 pre-existing and extended,
1 new):

| Test | Phase AC | Result |
| --- | --- | --- |
| `maps every profile field` (extended: `partnerDisplayName: 'Linh'`) | Task 1 | pass |
| `tolerates null optional fields` (extended: explicit `null`) | AC3 | pass |
| `an absent partnerDisplayName key reads as null` (new) | AC3 | pass |
| `STORY-006 AC1/AC2: a resolved partner name renders the "A & B" couple title and the partner avatar initial` (new) | AC1, AC2 | pass |
| `STORY-006 AC3: a null partner name degrades …` (new) | AC3 | pass |
| `STORY-006 AC3: an empty partner name degrades …` (new) | AC3 | pass |
| `STORY-006 AC3: a partnerDisplayName key absent from the response degrades …` (new) | AC3 | pass |
| `STORY-006: an unpaired caller keeps the single-avatar, single-name layout` (new) | unpaired-unchanged AC | pass |
| `STORY-006: a long combined name truncates with an ellipsis on the narrowest supported width instead of overflowing` (new) | ellipsis AC | pass |
| 8 pre-existing `home_screen_test.dart` cases (Dream Jar edge, no-AppBar, couple-presence, days counter, milestone pill, hero degradation, unresolved profile, Gallery edge) | regression | pass, unmodified assertions |

Required check "no fabricated placeholder string appears in any degraded case;
no `&` renders with a single resolved name" is asserted directly: the three
AC3 cases each assert `find.textContaining('&')` finds nothing inside the hero
and that the partner initial `'L'` is absent.

### Static analysis

Command (changed files only):

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter analyze --no-pub \
  lib/features/account/domain/cupid_profile.dart \
  lib/features/home/presentation/home_screen.dart \
  test/features/account/domain/cupid_profile_test.dart \
  test/features/home/home_screen_test.dart
```

Result: **`No issues found!`** — 0 errors, 0 warnings, 0 infos across all four
changed files.

Command (whole app baseline):

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter analyze --no-pub lib test
```

Result: exit 1, **75 issues found, all severity `info`, none in a file this
phase touched** — 74 `prefer_initializing_formals` plus one
`use_null_aware_elements` in `gallery_api.dart` and one `deprecated_member_use`
(`SemanticsService.announce`) in `reminder_firing_overlay.dart`. This is the
pre-existing repository baseline and is unchanged by P1.

Scoping note: the plain `flutter analyze` form from the phase file's §6 also
walks `build/ios/SourcePackages/checkouts/flutterfire/**`, vendored Pub
checkouts that are gitignored and not source. It reports hundreds of errors
there regardless of this change, so analysis was narrowed to `lib test` for the
baseline and to the four changed files for the gate. `--no-pub` only skips the
redundant re-resolve; `flutter pub get` already ran as part of the test command
above.

## Files Changed

- `mobile/lib/features/account/domain/cupid_profile.dart` — added the optional
  `partnerDisplayName` constructor field and its `fromJson` mapping
  (`json['partnerDisplayName'] as String?`, so a missing key reads `null`).
- `mobile/lib/features/home/presentation/home_screen.dart` — `_CoupleHero`
  passes `profile.partnerDisplayName` to `_PresenceRow`; `_PresenceRow`
  composes the title, derives the partner initial, wraps its text `Column` in
  `Flexible`, sets the title `Text` to `maxLines: 1` +
  `TextOverflow.ellipsis`, and its stale doc comment was replaced.
- `mobile/test/features/account/domain/cupid_profile_test.dart` — extended two
  cases, added one.
- `mobile/test/features/home/home_screen_test.dart` — added six cases plus a
  `partnerDisplayName` parameter on the `_pairedProfile` fixture.

`_Avatar` was not modified, and no spacing, sizing, color, or type token
changed, per phase tasks 4 and 5.

## Acceptance Criteria Verification

- **AC1** — with both names resolved the title reads `"Minh & Linh"` as one
  `Text` node, self name first. Asserted with an exact-string
  `find.text('Minh & Linh')` scoped to the `home_couple_hero` key.
- **AC2** — the partner disc shows `'L'`, computed with the same
  `substring(0, 1).toUpperCase()` rule as the self initial.
- **AC3** — `null`, `''`, and an absent JSON key each render `'Minh'` alone.
  Each case asserts no `&` and no `'L'` inside the hero, and no error, toast,
  banner, or retry affordance is introduced — the degraded branch simply passes
  `null` to the existing partner `_Avatar`.
- **Unpaired caller unchanged** — with `partnerId == null` the hero still
  renders one avatar and the self name; the partner disc and the `&` are both
  absent.
- **Long combined name truncates** — at 320x640 @dpr 1 the title
  `RenderParagraph` reports `didExceedMaxLines == true` with `maxLines: 1` and
  `TextOverflow.ellipsis`, and its width stays within the presence row.

### Pre-existing 320px overflow (not introduced by P1)

The long-name widget test drains one `RenderFlex overflowed by 84 pixels on the
right` before asserting. That exception is pre-existing and unrelated: a control
run of the same 320x640 viewport with the short `Minh`/`Linh` names — and with
`partnerDisplayName` left `null` entirely — fires the identical 84px overflow,
so it originates elsewhere in the dashboard layout at the narrowest width, not
in the couple title. Ruling it in scope would mean re-laying-out surfaces this
phase's Write Scope forbids. Truncation is therefore asserted on the title
paragraph itself (`didExceedMaxLines`), which is the behavior the AC actually
names. Flagged for the Reviewer, and a candidate follow-up bug for the Home
dashboard's narrow-width layout.

## Visual Fidelity

Rendered captures and the fidelity verdict are in
`../visual-fidelity/visual-fidelity-report.md`.
