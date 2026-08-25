# Phase P3 – Zodiac Red Flag Screen, Route And Preview Entry

## 1. Objective

Render the three-card Zodiac Red Flag screen and its honest degraded state to
design fidelity in dark + `vi`, and make it reachable through a named route and
the preview canvas (AC4, AC5).

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-mobile-zodiac-screen-route.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: YES (with P1)
- Write Scope:
  - `mobile/lib/features/zodiac/presentation/zodiac_red_flag_screen.dart`
  - `mobile/lib/features/zodiac/presentation/widgets/zodiac_conflict_index_card.dart`
  - `mobile/lib/features/zodiac/presentation/widgets/zodiac_daily_tips_card.dart`
  - `mobile/lib/app/cupid_app.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/test/features/zodiac/presentation/**`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` — not run by this phase
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ZodiacRedFlagScreen.routeName`, consumed by STORY-002's Home quick-grid entry
- Shared Interfaces Consumed:
  - P2 `ZodiacRedFlagToday` union and `ZodiacCubit`
- Risk Surfaces:
  - Degraded payload honesty (AC3), render half
  - Design fidelity, dark + `vi` (AC4)
  - Reachability (AC5)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/ux-spec.md` §2 and §5; `Cupid Screens.dc.html` lines 601-635
  - consumer contract: STORY-002 pushes `ZodiacRedFlagScreen` by route name
- Primary Inputs Summary:
  - requirements: AC3, AC4, AC5
  - architecture: `../architecture/solution.md` section 4 Mobile Lane guardrails and Risk Surfaces rows for AC3/AC4/AC5
  - OQ constraints: none open
  - upstream phase outputs: P2 models, cubit, DI registration
  - UX constraints, if truly required: `../ux/ux-spec.md` §2 (three cards + state 2c) and §5 (tokens)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen, its two composed cards, and its entry points
  - Source/Test File Count: 3 source + 2 edits + 1 test
  - Split Required: NO
  - Split Rationale: the route and preview entry are 2-3 line edits inside the same screen behavior cluster; splitting them out would be a phase whose whole output is one map key.

## 2. Required Reads

- `../requirements/` (AC3, AC4, AC5)
- `../ux/ux-spec.md` §2 and §5
- `../architecture/solution.md` section 4 Mobile Lane and Risk Surfaces rows for AC3/AC4/AC5
- P2 outputs under `mobile/lib/features/zodiac/`

## 3. Tasks

- Build Card 1 (eyebrow date from `contentDate` — never `DateTime.now()` — plus headline and body), Card 2 (score, `/scoreMax` suffix, bar fill = `score / scoreMax` with no hardcoded `10` or `70%`, and both partners' `CupidZodiacIcon` discs), and Card 3 (exactly the 3 tip rows in wire order).
- Color-code each zodiac icon by element: Fire peach/orange, Earth mint, Air lilac, Water pink. Use `CupidZodiacIcon` for every sign; never a Unicode zodiac glyph.
- Fall back to the sign's `viLabel` when `partners[].displayName` is `null`; never a placeholder name.
- Render the neutral single-card state 2c for every non-`ready` status, naming no partner, and mount none of Card 1/2/3 in that state.
- Render the generic error state on `CupidApiFailure`.
- Add `ZodiacRedFlagScreen.routeName` to the `routes:` map in `cupid_app.dart`, keeping `home:` intact and adding no `'/'` key.
- Add the `'zodiac'` canvas entry to `main_preview.dart` and remove `'zodiac'` from `_notImplementedCanvasIds`.
- Use design-system tokens only; no raw hex, no ad-hoc spacing constants.

## 4. Acceptance Criteria

- In dark + `vi`, layout, spacing, token usage, and typography match the design reference for the corresponding screen.
- Every sign renders through `CupidZodiacIcon` with the element color mapping above; no Unicode zodiac glyph exists anywhere under `mobile/lib/features/zodiac`.
- In the incomplete-profile state the widget tree contains the 2c card and contains no score, bar, partner disc, or tip widget.
- `ZodiacRedFlagScreen.routeName` resolves via `Navigator.pushNamed` in a pumped `CupidApp`, and `'zodiac'` is absent from `_notImplementedCanvasIds`.
- The bar fill is computed from `scoreMax`; the eyebrow date comes from `contentDate`.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/zodiac/presentation/` screen and widgets, plus the `cupid_app.dart` route and `main_preview.dart` canvas edits
- Contracts or schemas: `ZodiacRedFlagScreen.routeName` published for STORY-002
- Notes or evidence: results appended to `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter widget tests, no device, no emulator)
- Required levels:
  - unit: bar-fraction and date-formatting helpers if extracted
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile`
  - visual inspection: deferred to the requirement-level mobile visual audit
- Required checks: no Unicode zodiac glyph and no raw hex color under `mobile/lib/features/zodiac`
- Mobile discoverability / navigation integration: widget test pumping `CupidApp` and asserting `Navigator.pushNamed(ZodiacRedFlagScreen.routeName)` lands on the screen; assertion that `'zodiac'` is not in `_notImplementedCanvasIds`
- Minimum gates by risk surface: as specified in `../architecture/solution.md` section 4 for Degraded payload honesty (AC3) render half, Design fidelity, dark + `vi` (AC4), and Reachability (AC5)
- Required regression or contract coverage: the incomplete-profile widget test asserts absence of every content widget
- Evidence format: `flutter test` summary plus `flutter analyze` exit status recorded in `coding-plan/test-results.md`
- Requirement mobile visual audit: YES — `implemented-zodiac-*.png` against the design reference pair, captured at the requirement level, not in this phase
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/zodiac`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: the reachability assertion and the degraded-state absence assertions, each named in the test output

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
