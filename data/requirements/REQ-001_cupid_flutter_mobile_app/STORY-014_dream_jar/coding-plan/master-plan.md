# Master Coding Plan – STORY-014 Dream Jar / Hũ Ước Mơ Chung

## 1. Planning Metadata

- Story ID: STORY-014
- Complexity: S (Story-Class `standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md` (AC1-AC3, In/Out of Scope, R3 note)
- Source UX: `../ux/uiux-spec.md` §0.1-0.3, §1.1-1.8, §2, §3, §4
- Source Architecture: `../architecture/solution.md` (ADR-014a..g)
- OQ Constraints Source: `../architecture/solution.md` §3 `Open Question Constraints`
- Review Input: none yet
- Requirement Configuration Guide: `../../deployment/configuration-guide.md` — NOT_APPLICABLE for every phase (no env var, secret, port, or dependency change)

## 2. Planning Goal

- Shared contract owner: Mobile Developer, phase P1 (`DreamJarRepository` + domain models + failure contract + VND formatting)
- Contract-first phase required: YES (P1)
- Parallel execution possible: NO — single mobile lane, and P2-P5 all append to the shared `app_en.arb` / `app_vi.arb` and (P5) `service_locator.dart`
- Critical path: P1 → P2 → P3 → P4 → P5 → P6
- Parallelism notes: P3 and P4 are logically independent once P2 exists, but they share the ARB files and one owner, so they run sequentially to avoid write conflicts.
- AC mapping onto the confirmed feature (UX §0.1: the story's "wish list" wording is wrong, the feature is a shared monetary savings jar):
  - AC1 "add an entry to the shared jar" → create a jar (P3) and add a preset contribution to it (P2)
  - AC2 "both partners can view the jar's contents" → jar list + detail progress (P2, P3) and paginated contribution history + per-partner split (P4)
  - AC3 "unpaired users cannot access" → `DreamJarUnpairedFailure` from the backend 404 (P1) rendered as an unpaired notice (P2), reachable only from the Home entry point (P5)

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|----------------------|-------|--------------------|----------------|----------------|----------------------------|
| `dream-jar` REST routes (frozen, A1) | Backend (no work) | `CupidApi.dio` over TLS with Firebase bearer slot | none (pre-existing) | P1 | `GET /dream-jar?limit=50&offset=0` |
| `DreamJar` / `Contribution` / `DreamJarStatus` models | Mobile P1 | Dart classes with tolerant `fromJson` | P1 | P2, P3, P4 | `targetAmount` arrives as `"50000000.00"` (string) |
| `DreamJarRepository` | Mobile P1 | injected via `getIt`, throws `CupidApiFailure` | P1 | P2, P3, P4, P5 | `Future<List<DreamJar>> fetchJars({limit, offset})` |
| `DreamJarUnpairedFailure` (AC3) | Mobile P1 | 404 whose message contains `not paired` | P1 | P2, P3, P4 | `HttpStatusFailure(404, 'User not found or not paired')` |
| `DreamJarAmountFormat` (VND) | Mobile P1 | static `intl` helper | P1 | P2, P3, P4 | `12.000.000 ₫` |
| `DreamJarUnpairedNotice` widget | Mobile P2 | shared presentation widget | P2 | P3, P4 | rendered on unpaired cubit state |
| Home Money entry card → jar list route | Mobile P5 | `Navigator.push` from `HomeScreen` | P5 | user-facing | discoverable card, not direct-route-only |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|--------------|---------------------|----------------------------|
| Decimal-as-string JSON decoding | `backend/src/modules/dream-jar/entities/*.entity.ts` column types | tolerant `fromJson` accepting `num` and `String` | P1 unit tests over both fixture shapes | none | amounts render 0/NaN or throw; progress wrong |
| Unpaired access (AC3) | `dream-jar.service.ts` `getCoupleIdForUser()` 404 | `DreamJarUnpairedFailure` → unpaired notice state | P1 repository test on the 404 message split + P2 cubit/widget test | P1 | AC3 unverifiable |
| Entry-point discoverability | `home_screen.dart`, `app_shell.dart` | Home Money card pushes the jar list | P5 widget test asserting card presence + navigation | P2, P3 | orphaned, unreachable feature |
| Progress / liquid-fill bounds | UX §1.1 formula + entity `computeProgress()` | clamp 0..100, no divide-by-zero | P1/P2 unit tests for `target=0`, `current>target`, `current=0` | P1 | visual overflow or crash |
| Double contribution submission | non-idempotent `POST /:id/contributions` | quick-add disabled while in flight | P2 cubit test ignoring a second tap during submission | P1 | duplicated shared contributions |
| ARB key parity | `mobile/test/l10n/arb_parity_test.dart` | every new key in both `app_en.arb` and `app_vi.arb` | existing `flutter test` parity gate | P2-P5 | l10n gate fails, story blocked |
| Design-system compliance | `mobile/lib/design_system/**`, `no_fork_guard_test.dart` | tokens/adaptive widgets only, no forked styling | existing design-system guard tests in `flutter test` | P2-P5 | token drift, guard test failure |

## 4. Lane Summary

- Backend required: NO (A1 frozen — `dream-jar` endpoints are consume-only)
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer (P1)
- Final verification owner: Mobile Developer (P6)
- Shared contract owner: Mobile Developer (P1)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (registry note: `flutter run` needs a connected device and is interactive; readiness is the `flutter test` widget-test signal), build command `flutter build apk --debug`, test command `flutter test`

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | `mobile/lib/features/dream_jar/data/**`, `mobile/test/features/dream_jar/data/**` | `../architecture/solution.md` §2, §4 `Contracts And Integrations` | `DreamJar`/`Contribution` models, `DreamJarRepository`, `DreamJarUnpairedFailure`, `DreamJarAmountFormat` | unit tests (JSON decoding both numeric shapes, failure mapping, progress clamp), `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/dream_jar/presentation/dream_jar_detail_cubit.dart`, `.../screens/dream_jar_detail_screen.dart`, `.../widgets/dream_jar_hero_card.dart`, `.../widgets/dream_jar_unpaired_notice.dart`, `mobile/lib/l10n/arb/*.arb`, `mobile/test/features/dream_jar/presentation/**` | P1 outputs; `../ux/uiux-spec.md` §1.1, §1.8, §2, §3 | jar detail screen with hero progress + 3 preset quick-add + unpaired notice | cubit unit tests, widget test, `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | `mobile/lib/features/dream_jar/presentation/dream_jar_list_cubit.dart`, `.../create_dream_jar_cubit.dart`, `.../screens/dream_jar_list_screen.dart`, `.../widgets/create_dream_jar_sheet.dart`, `mobile/lib/l10n/arb/*.arb`, `mobile/test/features/dream_jar/presentation/**` | P1, P2 outputs; `../ux/uiux-spec.md` §1.2, §1.3, §1.5 | jar list with empty state, single-jar shortcut, archived filter, create-jar sheet | cubit unit tests, widget test, `flutter analyze` | DONE |
| P4 | Mobile Developer | Mobile | P1, P2 | NO | `mobile/lib/features/dream_jar/presentation/contribution_history_cubit.dart`, `.../screens/contribution_history_screen.dart`, `.../widgets/partner_split_card.dart`, `mobile/lib/l10n/arb/*.arb`, `mobile/test/features/dream_jar/presentation/**` | P1, P2 outputs; `../ux/uiux-spec.md` §1.6, §1.1 partner comparison | paginated contribution history + client-derived per-partner split card | cubit unit tests, widget test, `flutter analyze` | DONE |
| P5 | Mobile Developer | Mobile | P2, P3, P4 | NO | `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/lib/l10n/arb/*.arb`, `mobile/test/features/dream_jar/presentation/dream_jar_entry_card_test.dart` | P1-P4 outputs; `../ux/uiux-spec.md` entry-point paragraph before §1.1, §4 | discoverable Home Money entry card + navigation route + `getIt` registration | widget test asserting card presence and navigation, `flutter analyze` | DONE |
| P6 | Mobile Developer | Mobile Verification | P1, P2, P3, P4, P5 | NO | `mobile/test/features/dream_jar/**`, `coding-plan/test-results.md` | P1-P5 outputs; each implementation phase `## 6. Test Scope` | verified AC1-AC3 evidence in `test-results.md` | full `flutter analyze` + `flutter test` + `flutter build apk --debug` | DONE |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-data-contract.md` |
| P2 | `phase-P2-jar-detail.md` |
| P3 | `phase-P3-jar-collection.md` |
| P4 | `phase-P4-contribution-history.md` |
| P5 | `phase-P5-entry-point.md` |
| P6 | `phase-P6-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Risks And Notes

- Risks: see §3A. Highest-value guards are the decimal-as-string decoding tests (P1) and the entry-point reachability test (P5).
- OQ-driven constraints: ADR-014a — no client-side encryption, no `libsodium`/FFI, no new pubspec dependency, and no "end-to-end encrypted" copy, lock, or shield affordance on any Dream Jar surface. R3 needs no spike for this story.
- Deferred out of v1 (do not implement): edit/archive/delete jar, the 4th custom-amount tile and `note` field, multi-currency selector, "show archived" toggle, realtime push freshness, server-side per-partner aggregate. Reasons in `../architecture/solution.md` §3.
- Migration / rollout notes: none. Mobile-only additive change; rollback is deleting `features/dream_jar/` plus the P5 integration edits.
- Notes: no backend, OpenAPI (`mobile/openapi/**`), or `pubspec.yaml` file may be modified by any phase. If a phase appears to need one, stop and escalate to Scrum Master — A1 freeze makes it a separate story.
- Follow-ups owned outside this story: correct the Privacy / "My data" screen tier and copy for Dream Jar (now Level 3), reclassify Dream Jar in `ui_ux_system_memory.md` §8, note in `system_architecture_memory.md` that Dream Jar no longer depends on R3, and Product Owner corrections to the STORY-014 wording and epic tag.
