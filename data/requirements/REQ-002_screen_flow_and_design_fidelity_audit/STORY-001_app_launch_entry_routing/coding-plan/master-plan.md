# Master Coding Plan – STORY-001 App Launch / Session-Based Entry Routing

## 1. Planning Metadata

- Story ID: STORY-001_app_launch_entry_routing
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration change. Every plugin ADR-7 needs is already
  declared in `mobile/pubspec.yaml` and Firebase is already initialized in
  `mobile/lib/main.dart`.

## 2. Planning Goal

- Shared contract owner: `AuthHistoryStore` (mobile lane) — written by
  `AuthRepository`, cleared by `CupidSession.signOut()` teardown, read by
  `SessionGateCubit`.
- Contract-first phase required: NO. All three consumers are the same
  specialist in the same lane in sequence, so a standalone contract phase is
  forbidden by the contract-phase condition. The store ships inside P1 with its
  writer and reader.
- Parallel execution possible: NO — one mobile lane, and P0/P1 both register
  into `mobile/lib/core/di/service_locator.dart`.
- Critical path: P0 → P1 → P2 → P3.
- Parallelism notes: none.

## 3A. Risk Surface To Phase Mapping

> Authoritative risk table: `../architecture/solution.md` section 4.

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| R1 Initial-route swap | P2 |
| R2 AC2/AC3 split correctness | P1 |
| R3 AC4 no premature navigation | P2 |
| R4 AC5 resume invariant | P2 |
| R5 `AuthRepository` reachability | P0 |
| R6 Splash visual overlap with STORY-003 | P2, P3 |

## 3B. Acceptance Criteria To Phase Mapping

| AC | Phase that proves it |
|---|---|
| AC1 valid session → home (authenticated app root) | P2 |
| AC2 expired/invalid prior session → login | P1 (resolution), P2 (destination) |
| AC3 no session at all → welcome | P1 (resolution), P2 (destination) |
| AC4 no navigation before dwell AND resolution | P2 |
| AC5 foreground resume does not re-route | P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    `data/devops/system/runtime-command-registry.json` → `mobile-app`
    (`testCommand: flutter test`). Flutter is not on PATH on this machine;
    resolve via `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter` per the
    registry's `sdk.resolutionOrder`.
- No backend, frontend, or devops lane work.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | NOT_STARTED |
| P1 | Mobile Developer | Mobile | None | NO | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P0, P1 | NO | NOT_STARTED |
| P3 | Mobile Developer | Mobile | P2 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-auth-repository-reachability.md` |
| P1 | `phase-P1-session-resolution-split.md` |
| P2 | `phase-P2-entry-route-wiring.md` |
| P3 | `phase-P3-visual-fidelity-evidence.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Mobile implementation phases must fit one specialist lifecycle (roughly six
  source/test files) or be split; each phase records its own `Phase Sizing`
  block.
- P0/P1/P2 each own their tests and the static-analysis gate. There is no
  trailing unit-test phase.
- P3 is an evidence phase, not a code phase — see section 6.
- Implementation phase test scopes exclude e2e, Playwright, emulator/simulator
  lifecycle, and signing.

## 6. Why P3 Is A Separate Phase

REQ-002 has `ui_surface: true` and a locked `design_source`
(`data/devops/system/design-fidelity-config.json`), so every UI-bearing story
must produce visual-fidelity evidence before Review regardless of complexity.
P3 stays separate from P2 rather than folded into it because it is not source
work: it needs a running emulator/simulator and three separately manufactured
real session states (valid, expired, none), which is a different execution
mode from `flutter test` and can fail for device/environment reasons that must
not be confused with an implementation failure.

The story cannot go to Review until `visual-fidelity/visual-fidelity-report.md`
exists and records `VISUAL_FIDELITY: PASS`.

## 7. Notes And Cross-Story Coordination

- P0 implements ADR-7, flagged in `../architecture/solution.md` section 3 as a
  SCOPE DISCOVERY requiring Scrum Master / Product Owner acknowledgement.
  `FirebaseSignInGateway` has no concrete implementation in `lib/` today, so
  AC2 and AC3 cannot be delivered without it. Do not start P0 before that
  acknowledgement.
- P2 removes the splash tap-to-continue affordance (ADR-6). That is a visible
  splash change and splash visual fidelity belongs to STORY-003. STORY-003 must
  be told it is gone by design and must not reinstate it.
- No phase may modify `pair_gate_shell.dart`, `app_shell.dart`,
  `home_screen.dart`, or any screen layout. Those belong to STORY-002 and the
  Scope B design-fidelity stories.
