# Master Coding Plan – Create-Code (Couple Types) Screen QR Display

## 1. Planning Metadata

- Story ID: STORY-002_create_code_couple_types_screen_qr_display
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party service credential changes; the new dependency is a pure
  client-side encoder with no configuration.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`../architecture/contract-summary.md`).
- Contract-first phase required: NO — the only in-story consumer of the QR
  payload contract is P1, same lane and same specialist as P0, executed in
  sequence. The cross-story consumer (STORY-003) reads
  `contract-summary.md`, not a phase output.
- Parallel execution possible: NO — single mobile lane, P1 depends on P0.
- Critical path: P0 → P1.
- Parallelism notes: none.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Pairing QR payload (bare code string, EC level H) | Mobile Developer | P0 | P1 (in-story); STORY-003 (cross-story) | `../architecture/contract-summary.md` sections 1 and 3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| QR library availability/API | P0 |
| Payload identity (AC2) | P0 (widget contract), P1 (screen wiring) |
| Badge occlusion vs scannability | P0 |
| No-fork color guard (INV-3) | P0 |
| CTA destination (AC4, INV-1) | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` for implementation
    phases, command/source runtime registry `mobile-app`
    (`installCommand: flutter pub get`, `testCommand: flutter test`,
    `buildCommand: flutter build apk --debug`). The Flutter SDK is not on PATH
    on this machine; the registry resolves it via
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | NOT_STARTED |
| P1 | Mobile Developer | Mobile | P0 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-qr-foundation.md` |
| P1 | `phase-P1-invite-screen-mount-and-cta.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- Backend/frontend/mobile implementation phases must fit one specialist
  lifecycle (roughly six source/test files max) or be split. P0 and P1 are
  split because together they touch nine files, not because they share a file
  — their write scopes are disjoint.
- No standalone contract phase exists; the payload contract is folded into P0,
  its first consumer.
- No trailing verification/testing phase exists.
- Implementation phase test scopes exclude backend e2e, Playwright/browser e2e,
  mobile e2e, emulator/simulator lifecycle, signing, store upload, and runtime
  startup smoke.

## 6. Notes

- P0 must complete `flutter pub add qr_flutter` + `flutter analyze` before any
  widget code is written; the ACCEPTED library row in
  `../architecture/solution.md` section 6 is marked UNVERIFIED and that command
  is the verification. Stop with `QR_DEPENDENCY_UNRESOLVABLE` rather than
  substituting a different package silently.
- P1 is the entry-point/discoverability phase: it mounts `InviteQrFrame` into
  the already-reachable invite screen and wires the Continue CTA to its
  destination, so nothing built in P0 is left orphaned.
