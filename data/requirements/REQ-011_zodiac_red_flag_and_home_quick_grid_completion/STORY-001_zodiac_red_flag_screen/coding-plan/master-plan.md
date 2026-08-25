# Master Coding Plan – Zodiac Red Flag Today

## 1. Planning Metadata

- Story ID: STORY-001_zodiac_red_flag_screen
- Complexity: complex
- OQ Constraints Source: `../requirements/requirements.md` "Open Question Triage" (OQ1, OQ2 both RESOLVED; no blocked scope)
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret, or third-party integration changes; the endpoint reuses the existing `JwtAuthGuard` and the existing profile `zodiacSign` field.

## 2. Planning Goal

- Shared contract owner: Backend Developer (`backend/src/modules/zodiac`), published as `../architecture/contract-summary.md`.
- Contract-first phase required: NO — the cross-lane contract is already fully specified in `../architecture/contract-summary.md`; no code artifact is shared between the TypeScript and Dart lanes, so no implementation phase produces it.
- Parallel execution possible: YES
- Critical path: P0 -> P1 (backend) runs concurrently with P2 -> P3 (mobile); the story completes when P3 lands.
- Parallelism notes: the mobile lane depends on the *contract document*, not on merged backend code. P2 may start immediately. Backend-first only matters at runtime rollout (`../architecture/contract-summary.md` section 5), not at implementation time. Write scopes of the two lanes are disjoint (`backend/**` vs `mobile/**`).

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| `GET /zodiac/red-flag/today` response union | Backend Developer | P1 | P2 | `../architecture/contract-summary.md` sections 1-4 |
| Sign / tint / icon identifier vocabularies | Backend Developer | P0 | P2, P3 | `../architecture/contract-summary.md` section 2 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Content-table completeness (AC1) | P0 |
| Per-day determinism (AC2) | P0 |
| Tip-row-count guarantee (AC2/UX §2 Card 3) | P0 |
| Free-string `zodiacSign` normalization (AC3) | P0 |
| Degraded payload honesty (AC3) | P1 (payload half), P3 (render half) |
| Design fidelity, dark + `vi` (AC4) | P3 |
| Reachability (AC5) | P3 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `backend-api`: `backend`, startup smoke `NOT_APPLICABLE` (no phase-level startup smoke; requirement-level integration verification owns runtime evidence), command/source runtime registry `runtimes.backend-api.buildCommand` = `npm run build`
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source runtime registry `runtimes.mobile-app.testCommand` = `flutter test`, static analysis via `flutter analyze`

## 5. Phases Overview

Each row below is a summary. The authoritative values stay in the matching
`phase-Px-*.md` (`## 1B`, `## 5`, `## 6`); on any conflict, the phase file wins.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|-------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Backend Developer | Backend | None | YES (with P2) | `backend/src/modules/zodiac/content/` (`zodiac-sign.ts`, `conflict-index.content.ts`, `daily-tips.content.ts`, `daily-tip.selector.ts`, `*.spec.ts`) | AC1-AC3; `../architecture/solution.md` §4; `../architecture/contract-summary.md` §2; OQ1 RESOLVED; `../ux/ux-spec.md` §2 Card 3 (tip row count only) | 4 content/domain modules + specs; sign, tint, and icon vocabularies | Jest unit: content-table completeness, selector determinism, tip-pool size, sign normalization; `npm run build` | DONE |
| P1 | Backend Developer | Backend | P0 | YES (with P2, P3) | `backend/src/modules/zodiac/{zodiac.module,zodiac.controller,zodiac.service,zodiac.service.spec}.ts`, `backend/src/modules/zodiac/dto/zodiac-red-flag-today.dto.ts`, `backend/src/app.module.ts` | AC1-AC3; `../architecture/contract-summary.md` §1, §3, §4; `../architecture/solution.md` §4 Backend Lane; OQ2 RESOLVED; P0 outputs | `GET /zodiac/red-flag/today` + `ready`/`incomplete_profile` response union + `ZodiacModule` registration | Jest service-level: `ready` path and all three `incomplete_profile` reasons, key-absence assertion, pinned clock; `npm run build` | DONE |
| P2 | Mobile Developer | Mobile | None | YES (with P0, P1) | `mobile/lib/features/zodiac/{domain,data,presentation}` state layer, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/zodiac/**` | AC1-AC3; `../architecture/contract-summary.md` §1-§4, §6; `../architecture/solution.md` §4 Mobile Lane; OQ2 RESOLVED | `ZodiacRedFlagToday` union models, `ZodiacRepository`, `ZodiacCubit`/`ZodiacState`, DI registration | Flutter unit: parsing (`ready`, `incomplete_profile`, unknown `status`, unknown `tint`/`icon`, missing required key) and cubit transitions; `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P2 | YES (with P1) | `mobile/lib/features/zodiac/presentation/zodiac_red_flag_screen.dart`, `mobile/lib/features/zodiac/presentation/widgets/*`, `mobile/lib/app/cupid_app.dart`, `mobile/lib/main_preview.dart`, `mobile/test/features/zodiac/presentation/**` | AC3-AC5; `../ux/ux-spec.md` §2 and §5; `../architecture/solution.md` §4 Mobile Lane and the AC3/AC4/AC5 risk rows; P2 outputs | Three-card screen + neutral 2c degraded state + error state; `ZodiacRedFlagScreen.routeName`; preview canvas entry | Flutter widget: reachability via `Navigator.pushNamed`, degraded-state absence assertions; `flutter analyze`; per-story visual fidelity performed at story level (superseding the deferral originally recorded here) — see `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS` | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-zodiac-content-domain.md` |
| P1 | `phase-P1-zodiac-api-surface.md` |
| P2 | `phase-P2-mobile-zodiac-data-state.md` |
| P3 | `phase-P3-mobile-zodiac-screen-route.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file; no duplicates exist.
- Backend/mobile phases fit one specialist lifecycle (roughly six source/test files max) or are split. P0/P1 and P2/P3 are the splits of two chunks that would otherwise be ~13 and ~10 files.
- No two phases are separated only because they would write the same file; the two lane splits are behavior-layer splits (pure content/domain vs HTTP surface; data/state vs screen/route), not file-collision splits.
- No standalone contract phase exists.
- No trailing verification/testing phase exists; each phase owns its own targeted tests and build/type-check.
- Implementation phase test scopes exclude backend e2e/test_e2e, Playwright/browser e2e, mobile e2e, emulator/simulator lifecycle, traces, and scenario reruns.

## 6. Notes

- Rollout order is backend-before-mobile at deploy time only (`../architecture/contract-summary.md` section 5). It does not constrain implementation order, and P2/P3 must not be blocked waiting for P0/P1 to merge.
- P3 is the reachability phase for AC5: the named route plus the `main_preview.dart` canvas entry are its deliverables, not optional extras.
