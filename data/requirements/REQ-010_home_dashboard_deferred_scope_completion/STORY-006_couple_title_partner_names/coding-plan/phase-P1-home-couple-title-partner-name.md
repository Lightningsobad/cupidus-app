# Phase P1 – Render Both Partner Names In The Home Couple Title

## 1. Objective

Map `partnerDisplayName` into the Home dashboard's profile read model and
render the design's `"<self> & <partner>"` title plus the partner avatar
initial, degrading to the self name alone when the partner name is absent.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-home-couple-title-partner-name.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES
- Write Scope:
  - `mobile/lib/features/account/domain/cupid_profile.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/test/features/account/domain/cupid_profile_test.dart`
  - `mobile/test/features/home/home_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Consumed:
  - `GET /users/me` `partnerDisplayName` (`../architecture/contract-summary.md` §1-§3)
- Risk Surfaces:
  - Fabricated partner name (AC3)
  - Combined-title overflow in the header row
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md`
  - consumer contract: none downstream
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1-AC3
  - architecture: `../architecture/solution.md` §4 Mobile Lane
  - upstream phase outputs: none — the key already ships at `BaseHead`
  - UX constraints: `../ux/uiux-spec.md` §6.4 (degraded state), §6.5
    (component changes), §6.6 (overflow), §6.7 (anti-patterns)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one read-model field plus its single rendering site
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md`
- `../architecture/solution.md` §4 Mobile Lane
- `../ux/uiux-spec.md` §6.4, §6.5, §6.6, §6.7
- `mobile/lib/features/account/domain/cupid_profile.dart`
- `mobile/lib/features/home/presentation/home_screen.dart` (`_CoupleHero`,
  `_PresenceRow`, `_Avatar` — roughly lines 267-480)

## 3. Tasks

1. Add `partnerDisplayName` (`String?`) to `CupidProfile` as an optional
   constructor field, and map `json['partnerDisplayName'] as String?` in
   `fromJson`. A missing key must read as `null`, not throw.
2. Add a `partnerDisplayName` input to `_PresenceRow` and pass
   `profile.partnerDisplayName` from `_CoupleHero`. Leave `displayName`,
   `coupleTypeLabel`, and `isPaired` semantics untouched.
3. Compose the title inside `_PresenceRow`: when `partnerDisplayName` is
   `null` or empty, render the self name exactly as today; otherwise render
   `'<selfName> & <partnerDisplayName>'` as one `Text` node, self name first.
   Never emit a trailing or leading `&`.
4. Compute the partner initial with the same rule already used for the self
   initial (`substring(0, 1).toUpperCase()`) and pass it to the partner
   `_Avatar` instance only when the partner name is non-null and non-empty;
   otherwise keep passing `null`. Do not modify the `_Avatar` class.
5. Apply the §6.6 overflow affordance: allow the name/couple-type `Column` to
   shrink within the header row (`Flexible`) and set the title `Text` to
   `maxLines: 1` with `TextOverflow.ellipsis`. Change no spacing, sizing,
   color, or type token.
6. Replace the now-stale doc comment above `_PresenceRow` (the one claiming
   `GET /users/me` exposes only `displayName` and `partnerId`) with an accurate
   one-line note.
7. Extend the two named test files, then run targeted tests and analysis.

## 4. Acceptance Criteria

- AC1: with both names resolved, the title reads `"<self> & <partner>"`.
- AC2: the partner avatar disc shows the partner's uppercased first letter.
- AC3: with `partnerDisplayName` `null`, `""`, or absent from the JSON, the
  title shows the self name alone with no `&` and the partner disc renders
  gradient-only, with no error, toast, banner, or retry affordance.
- An unpaired caller (`partnerId == null`) still renders the existing
  single-avatar, single-name layout unchanged.
- A long combined name truncates with an ellipsis instead of overflowing.

## 5. Planned Outputs

- Code files: `cupid_profile.dart`, `home_screen.dart`
- Test files: `cupid_profile_test.dart`, `home_screen_test.dart`
- Notes or evidence: results recorded in `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, Home dashboard couple-presence header
- Required levels:
  - unit: `cupid_profile_test.dart` — `partnerDisplayName` parses from JSON,
    a missing key and an explicit `null` both read as `null`
  - integration: `home_screen_test.dart` widget tests — combined title,
    partner initial, degraded (`null` / `""` / missing) rendering, unpaired
    layout unchanged, long-name ellipsis at the narrowest supported width
  - mobile build/type-check/static-analysis: `flutter analyze`
  - visual inspection: compare the rendered header against
    `../ux/uiux-spec.md` §6.8's design anchor
- Required checks: no fabricated placeholder string appears in any degraded
  case; no `&` renders with a single resolved name
- Mobile discoverability / navigation integration: NOT_APPLICABLE — the
  couple-presence header is an already-mounted, already-reachable surface on
  the Home dashboard (`../story_master.md` System Integration And
  Discoverability); this phase extends it and adds no new screen or route.
- Minimum gates by risk surface:
  - Fabricated partner name (AC3) -> the three degraded-state widget cases green
  - Combined-title overflow -> the long-name case pumps with no overflow exception
- Required regression or contract coverage: existing `home_screen_test.dart`
  cases must still pass unmodified
- Required runtime signals: `flutter test` assertion output; zero overflow
  exceptions in the widget-test console
- Evidence format: exact command + pass/fail counts in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests:
    `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/features/home/home_screen_test.dart test/features/account/domain/cupid_profile_test.dart`
  - Static analysis: `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter analyze`
  - Required assertion evidence: the AC1/AC2/AC3 assertions named above
- Do not run the full `flutter test` suite, an emulator/simulator lifecycle, or
  an APK build for this phase.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
