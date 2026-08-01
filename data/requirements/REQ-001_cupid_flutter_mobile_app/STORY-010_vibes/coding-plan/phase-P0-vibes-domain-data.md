# Phase P0 – Vibes Domain And Data Contract

## 1. Objective

Own the story's shared contract: the 5-value mood mapping, the `VibeEntry`
model, and the `VibesRepository` that is the only code aware of `/vibes*` paths
and JSON keys.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-vibes-domain-data.md`
- Owner: Mobile Developer
- Lane: Contract / Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/vibes/domain/vibe_mood.dart`
  - `mobile/lib/features/vibes/domain/vibe_entry.dart`
  - `mobile/lib/features/vibes/data/vibes_repository.dart`
  - `mobile/test/features/vibes/domain/vibe_mood_test.dart`
  - `mobile/test/features/vibes/data/vibes_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `VibeMood` (display id ↔ wire value, `fromWire`)
  - `VibeEntry` (`fromJson`)
  - `VibesRepository` (4 methods, throws `CupidApiFailure`)
- Shared Interfaces Consumed:
  - `mobile/lib/core/network/cupid_api.dart` (`CupidApi`, `CupidApiFailure`)
- Risk Surfaces:
  - Mood wire mapping (A1 frozen enum)
  - REST read path (`Response<void>` bypass)
  - Local-date bucketing / timezone
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §2 and
    §4 D-010-2, D-010-3; `mobile/lib/features/auth/data/auth_repository.dart`
    lines 88-112 for the `CupidApi.dio` + failure-rethrow precedent
  - consumer contract: P1 `VibeCubit`
- Primary Inputs Summary:
  - requirements: `../story_master.md` (AC1, AC2, Out of Scope A1)
  - architecture: `../architecture/solution.md` §2, §4 D-010-2, D-010-3
  - OQ constraints: OQ4 — no Drift/local persistence in this phase
  - upstream phase outputs: none
  - UX constraints, if truly required: `../ux/uiux-spec.md` §3 (5-value set,
    `spicy → horny`) only
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: mood contract + entry model + REST access
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, §4 (D-010-2, D-010-3), §6
- `mobile/lib/features/auth/data/auth_repository.dart` lines 88-112 (precedent)
- `mobile/lib/core/network/cupid_api_failure.dart` (failure types)

## 3. Tasks

- Add `VibeMood` with the 5 frozen wire values (`happy`, `sad`, `angry`,
  `horny`, `tired`), the `spicy` display id for `horny`, and
  `VibeMood.fromWire(String)` returning `null` for unknown values (R-010-5).
  No mood string literal may exist outside this file.
- Add `VibeEntry` with `id`, `mood` (`VibeMood`), `note` (nullable, parsed but
  unused in v1), `createdAt` (`DateTime`, parsed then `.toLocal()` at the
  bucketing boundary), and `fromJson`. Skip entries whose `mood` is unknown.
- Add `VibesRepository` taking the injected `CupidApi`:
  - `fetchMyToday()` → `dio.get<Object?>('/vibes/today')`; treat `null`, an
    empty body, or an empty map as "no entry today" (R-010-3), not a parse error.
  - `fetchMyHistory()` → `GET /vibes/history?days=8` (D-010-3: 8, not 7).
  - `fetchPartnerHistory()` → `GET /vibes/partner?days=8`; an empty list is a
    valid unpaired/no-data result, never an error (AC3 defensive path).
  - `submitMood(VibeMood)` → `POST /vibes` with body `{"mood": wireValue}` and
    no `note` key.
  - On `DioException`, rethrow `e.error as CupidApiFailure` (falling back to
    `UnexpectedFailure`), exactly like `AuthRepository`.
- Add a `bucketByLocalDay` helper (repository or domain, this phase's choice)
  that maps a DESC-ordered entry list to the last 7 local calendar days,
  newest-wins per day, `null` for a day with no entry.

## 4. Acceptance Criteria

- Every backend `Mood` value round-trips through `VibeMood`; `spicy` resolves to
  wire `horny`; an unknown wire value yields `null` and is skipped, not thrown.
- `fetchMyToday()` returns `null` for an empty/`null` response body.
- `fetchPartnerHistory()` returns `[]` (not an error) when the backend returns
  an empty array.
- All four methods throw only `CupidApiFailure` subtypes, never `DioException`.
- `bucketByLocalDay` produces exactly 7 slots, oldest→newest, newest entry wins
  per day, and tolerates a `days=8` window containing an 8th older day.
- No file outside `domain/vibe_mood.dart` contains a mood string literal.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/vibes/domain/`,
  `mobile/lib/features/vibes/data/`
- Contracts or schemas: `VibeMood`, `VibeEntry`, `VibesRepository` as declared
  in `../architecture/solution.md` §2
- Requirement configuration guide updates: none
- Notes or evidence: unit test results recorded in P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/` package
- Required levels:
  - unit: `VibeMood` mapping (all 5 values + unknown), `VibeEntry.fromJson`,
    `VibesRepository` with a mocked/stubbed `Dio` (today object, today null,
    today empty body, partner `[]`, submit body shape, failure rethrow),
    `bucketByLocalDay` (DESC input, missing days, duplicate same-day, 8-day
    window)
  - mobile build/type-check/static-analysis: `flutter analyze` clean for the
    touched files
- Required checks: no mood literal outside `vibe_mood.dart`; no `Dio` or
  `cupid_api` import outside `data/`
- Mobile discoverability / navigation integration: N/A for this phase
- Minimum gates by risk surface:
  - Mood wire mapping → unit test over all values, else `MOOD_CONTRACT_UNVERIFIED`
  - REST read path → mocked-`Dio` unit tests, else `VIBES_REPO_UNVERIFIED`
  - Bucketing/timezone → unit test, else `BUCKETING_UNVERIFIED`
- Required regression or contract coverage: existing
  `mobile/test/core/network/**` tests must still pass
- Evidence format: concise rows in `coding-plan/test-results.md` (written in P4)
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes`
  - Build/type-check/lint command when required:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze`
  - Required assertion evidence: mapping table assertions, parsed model fields,
    request path/body assertions, thrown failure types

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence:
  - `mobile/lib/features/vibes/domain/vibe_mood.dart`,
    `mobile/lib/features/vibes/domain/vibe_entry.dart`,
    `mobile/lib/features/vibes/data/vibes_repository.dart` implemented per
    §2/§4 D-010-2/D-010-3.
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes`
    — 15/15 passed (mood round-trip incl. unknown-value skip, `fetchMyToday`
    null/empty-string/empty-map handling, unknown-mood skip in
    `fetchMyHistory`, `fetchPartnerHistory` empty-list-not-error,
    `submitMood` body shape, `CupidApiFailure` rethrow for all 4 methods incl.
    `UnexpectedFailure` fallback, `bucketByLocalDay` 7-slot/newest-wins/8-day
    tolerance).
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze` — 34
    pre-existing issues outside the vibes feature (realtime/auth
    `prefer_initializing_formals` info, generated `openapi/` unused-import
    warnings); zero issues in the 3 touched files.
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/core/network`
    — 8/8 still passing (regression).
  - No mood string literal outside `vibe_mood.dart`; no `Dio`/`cupid_api`
    import outside `data/`.
