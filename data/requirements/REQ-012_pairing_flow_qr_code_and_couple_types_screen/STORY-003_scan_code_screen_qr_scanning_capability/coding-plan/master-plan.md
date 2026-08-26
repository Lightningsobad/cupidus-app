# Master Coding Plan – Scan-Code Screen QR Scanning Capability

## 1. Planning Metadata

- Story ID: STORY-003_scan_code_screen_qr_scanning_capability
- Complexity: complex
- OQ Constraints Source: `../requirements/` OQ table (OQ1 RESOLVED in `../ux/ux-spec.md`)
- Requirement Configuration Guide impact: REQUIRED — two new third-party
  packages plus a first-ever OS camera permission on both platforms are
  deployment/store-facing facts; `../../deployment/configuration-guide.md` does
  not exist yet and P1 creates it.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (single owner for every phase).
- Contract-first phase required: NO — the same specialist implements the
  permission gate, the parser, the cubit, and all of their consumers back to
  back in one lane. P1 is a platform/dependency foundation phase (pubspec,
  Android manifest, iOS Info.plist, permission implementation), not a contract
  isolation phase.
- Parallel execution possible: NO — one lane, strictly sequential.
- Critical path: P1 → P2 → P3 → P4.
- Parallelism notes: none. P2's headless logic could in principle start before
  P1 resolves packages, but `ScanCodeCubit` consumes `CameraPermissionGate` and
  cannot compile or be analyzed until P1 lands.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Scanned vs typed outcome divergence (AC2) | P2, P4 |
| Malformed/URL payload sent to backend (AC4) | P2 |
| Permission dead-end (AC1/AC3) | P1, P2, P3 |
| Join-code screen mutated by a dismissed scan | P4 |
| Design fidelity of new pill + states (AC5) | P3, P4 |
| Platform permission declarations missing | P1 |
| `pubspec.yaml` collision with STORY-002 | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `REQUIRED` (story-level gate run by
    Scrum Master after P4, not inside any implementation phase),
    command/source runtime registry `mobile-app`
    (`buildCommand`: `flutter build apk --debug`).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | COMPLETE |
| P2 | Mobile Developer | Mobile | P1 | NO | COMPLETE |
| P3 | Mobile Developer | Mobile | P2 | NO | COMPLETE |
| P4 | Mobile Developer | Mobile | P3 | NO | COMPLETE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-camera-permission-foundation.md` |
| P2 | `phase-P2-scan-decode-logic.md` |
| P3 | `phase-P3-scan-screen-states.md` |
| P4 | `phase-P4-scan-entry-point-and-preview.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Mobile implementation phases fit one specialist lifecycle (roughly six
  source/test files max) or are split.
- No trailing verification/testing phase exists; each phase owns its own
  targeted tests and `flutter analyze` / build check.

## 6. Notes

- P1 carries the open assumption A1 from `../architecture/solution.md` section
  3: `WebSearch`/`WebFetch` were disabled when the solution was written, so
  package versions are unconfirmed. P1's first task closes it with
  `flutter pub add` + `flutter analyze` **before** any scan logic is written. If
  either package fails to resolve or is discontinued, P1 stops and escalates
  rather than substituting a package.
- P1 touches `mobile/pubspec.yaml`, which STORY-002 also edits on a sibling
  branch. Append the two dependencies to the existing block; do not reorder or
  reformat it, or the integration merge conflicts on a whitespace change.
- A1 closed in P1: `mobile_scanner` `^7.4.0` and `permission_handler` resolved
  and analyze-clean. `permission_handler` was subsequently held at `^12.0.1`
  rather than 13.x, because `permission_handler_android` 14.0.0 pins
  `compileSdk = 37` and no `platforms;android-37` package exists to build
  against. Same package, one major back — not a substitution. Rationale and
  lift condition: `../deployment/configuration-guide.md`.
