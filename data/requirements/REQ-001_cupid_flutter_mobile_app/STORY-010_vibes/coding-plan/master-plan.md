# Master Coding Plan – STORY-010 Vibes / Cảm Xúc Hằng Ngày

## 1. Planning Metadata

- Story ID: STORY-010
- Complexity: S (Story-Class: standard)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md`
- Source UX: `../ux/uiux-spec.md` §3-§9
- Source Architecture: `../architecture/solution.md`
- OQ Constraints Source: `../../req_master.md` OQ4 (Drift scoped to
  chat/timeline/expenses — no local DB for vibes), A1 (backend frozen)
- Review Input: none yet
- Requirement Configuration Guide: `../../deployment/configuration-guide.md` —
  **no update required** (no env var, secret, or dependency change)

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P0 owns `VibeMood` + `VibeEntry` +
  `VibesRepository`, consumed by every later phase)
- Contract-first phase required: YES (P0)
- Parallel execution possible: NO (single mobile lane, one specialist)
- Critical path: P0 → P1 → P3 → P4 (P2 is independent of P1)
- Parallelism notes: P1 (cubit) and P2 (props-only widgets) both depend only on
  P0 and may be executed in either order by the same owner; they are not
  dispatched to separate agents.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|----------------------|-------|--------------------|----------------|----------------|----------------------------|
| `VibeMood` display id ↔ wire value | Mobile | in-process enum, single mapping site | P0 | P1, P2, P3 | `spicy` → `"horny"` |
| `VibeEntry` | Mobile | JSON → model | P0 | P1, P2 | `{id, userId, mood, note?, createdAt}` |
| `VibesRepository` | Mobile | `CupidApi.dio` REST, throws `CupidApiFailure` | P0 | P1 | `POST /vibes {"mood":"happy"}` |
| `VibeState` | Mobile | Bloc state stream | P1 | P3 | today, myWeek, partnerWeek, submitting, failure |
| Props-only widgets | Mobile | constructor params, no cubit lookup | P2 | P3 | `MoodGrid(selected:, onPick:, enabled:)` |
| `VibeEntryCard` mount | Mobile | widget mounted in `HomeScreen` | P3 | requirement integration | tap → `VibeScreen` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|--------------|---------------------|----------------------------|
| Mood wire mapping (A1 frozen enum) | `backend/src/modules/vibes/entities/vibe.entity.ts` | `VibeMood.wireValue` / `fromWire` | unit test over all 5 values + unknown value | none | `MOOD_CONTRACT_UNVERIFIED` |
| REST read path (`Response<void>` bypass) | `../architecture/solution.md` §2 | `VibesRepository` | unit tests with a mocked `Dio` incl. null/empty `today` body and `[]` partner | none | `VIBES_REPO_UNVERIFIED` |
| Local-date bucketing / timezone | `../architecture/solution.md` §4 D-010-3 | 7-day strip buckets | unit test: `days=8` window, DESC input, missing days, newest-wins | none | `BUCKETING_UNVERIFIED` |
| Optimistic submit + revert | `../ux/uiux-spec.md` §4 | `VibeCubit` | `bloc_test` state sequence incl. failure revert and in-flight lock | none | `SUBMIT_UNVERIFIED` |
| Accessibility semantics | `../ux/uiux-spec.md` §8 | mood cell semantics | widget test: accessible name, selected state, `--tap` size | none | `A11Y_UNVERIFIED` |
| Entry-point discoverability | `../architecture/solution.md` §4 D-010-5 | `HomeScreen` → `VibeScreen` | widget test: tap card, `VibeScreen` pushed, `home_screen_ready_signal` intact | none | `ENTRYPOINT_UNVERIFIED` |

## 4. Lane Summary

- Backend required: NO (A1 frozen; `vibes` module consumed unchanged)
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer (P0)
- Final verification owner: Mobile Developer (P4)
- Shared contract owner: Mobile Developer (P0)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (readiness is the
    `home_screen_ready_signal` widget test, not an HTTP probe), command/source
    runtime registry `mobile-app` — Flutter is not on PATH; use
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter"`

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Contract / Mobile | None | NO | `mobile/lib/features/vibes/domain/**`, `mobile/lib/features/vibes/data/**`, `mobile/test/features/vibes/domain/**`, `mobile/test/features/vibes/data/**` | `../architecture/solution.md` §2, §4 D-010-2, D-010-3 | `VibeMood`, `VibeEntry`, `VibesRepository` | unit + `flutter analyze` | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/vibes/presentation/vibe_cubit.dart`, `mobile/lib/features/vibes/presentation/vibe_state.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/vibes/presentation/vibe_cubit_test.dart` | `../architecture/solution.md` §4 D-010-3, `../ux/uiux-spec.md` §4 | `VibeCubit`, `VibeState`, DI registration | unit (`bloc_test`) + `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/vibes/presentation/widgets/**`, `mobile/lib/features/vibes/presentation/vibe_strings.dart`, `mobile/test/features/vibes/presentation/widgets/**` | `../ux/uiux-spec.md` §3, §5, §6, §8, §9 | mood face, mood grid, partner card, history strip, strings | widget + `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | `mobile/lib/features/vibes/presentation/vibe_screen.dart`, `mobile/lib/features/vibes/presentation/widgets/vibe_entry_card.dart`, `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/lib/design_system/icons/cupid_icons.dart`, `mobile/test/features/vibes/presentation/vibe_screen_test.dart` | `../architecture/solution.md` §4 D-010-4, D-010-5, `../ux/uiux-spec.md` §2, §7 | `VibeScreen`, `VibeEntryCard`, mounted entry point | widget + `flutter analyze` | DONE |
| P4 | Mobile Developer | Mobile Verification | P0, P1, P2, P3 | NO | `mobile/test/features/vibes/**`, `coding-plan/test-results.md` | implementation phase `## 6. Test Scope` sections | `test-results.md` | `flutter test` + `flutter analyze` | DONE |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-vibes-domain-data.md` |
| P1 | `phase-P1-vibe-cubit.md` |
| P2 | `phase-P2-vibe-widgets.md` |
| P3 | `phase-P3-vibe-screen-entrypoint.md` |
| P4 | `phase-P4-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Mobile implementation phases fit one specialist lifecycle (max 6 source/test
  files each); no phase needs a further split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, mobile e2e, emulator/simulator lifecycle, signing,
  store upload, traces, or scenario reruns.

## 6. Risks And Notes

- Risks: R-010-1 (AC3 needs the paired route gate that is absent at BaseHead —
  verified at requirement integration, escalated to Scrum Master), R-010-2
  (duplicate same-day submits), R-010-3 (empty `today` body), R-010-4
  (parallel-wave conflict on `service_locator.dart` / `cupid_icons.dart` —
  append-only edits), R-010-5 (unknown server mood value). Full text in
  `../architecture/solution.md` §6.
- OQ-driven constraints: OQ4 — no Drift/local persistence for vibes; A1 — no
  `vibes` endpoint, DTO, or Swagger change in any phase.
- Migration / rollout notes: none. No new dependency, env var, or secret.
- Notes: A-1 (drop the `soft` cell) and A-2 (accurate strip copy) are Product
  Owner confirmations pending; both ship a backend-accurate default and block
  no phase. Only `VibeMood` changes if PO reverses A-1.
