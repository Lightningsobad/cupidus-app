# Master Coding Plan – STORY-003 Auth

## 1. Planning Metadata

- Story ID: REQ-001 / STORY-003_auth
- Complexity: M, Story-Class `standard`
- Planning Owner: Tech Lead (`Alan-Techlead-3`, `Mode: compact-story-plan`,
  RunId `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-tech-lead`)
- Source Requirements: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/story_master.md`
- Source UX: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/ux/uiux-spec.md` (§3, §4, §5, §9)
- Source Architecture: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/architecture/solution.md`
- OQ Constraints Source: none open for this story
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`

Note: this file was created by Scrum Master lifting solution.md §8's
"Embedded Coding Plan" verbatim into the canonical `coding-plan/master-plan.md`
location, per that run's own flagged note ("Scrum Master can lift it verbatim
into `coding-plan/master-plan.md` if the standard-story gate requires that
file — this is a flagged Scrum Master decision, not a silent skip") and per
`AGENTS.md`'s "Standard and complex stories require shared implementation
planning through `coding-plan/master-plan.md`" rule. No new Tech Lead run was
performed; content is unchanged from solution.md §8/§4/§2.

## 2. Planning Goal

- Shared contract owner: Tech Lead (solution.md §2 Downstream Contract Summary)
- Contract-first phase required: NO — P1 (DevOps) and P2 (Mobile) both start
  from the existing STORY-002 contract; neither produces a contract the other
  consumes.
- Parallel execution possible: YES for P1 (DevOps) + P2 (Mobile) only — no
  shared write paths, no dependency between them. P3, P4, P5 are strictly
  sequential mobile-lane phases.
- Critical path: (P1 | P2) -> P3 -> P4 -> P5
- Parallelism notes: P1's write scope (`mobile/android/app/`,
  `mobile/ios/Runner/`, `mobile/lib/firebase_options.dart`,
  `deployment/configuration-guide.md`) does not overlap P2's write scope
  (`mobile/lib/core/auth/**`, `mobile/pubspec.yaml`). P3 needs `firebase_core`/
  `firebase_auth` (P2 output) present before compiling the interceptor.

## 3. Cross-Lane Contract Summary

See solution.md §2 Downstream Contract Summary (`CupidSession`,
`SessionScopedStore`, `AuthRepository`, `CupidAuthFailure`) — authoritative for
this story and for STORY-004's Socket.IO forward-compat (R8:
`idToken()`/`idTokenStream`).

## 3A. Risk Surfaces And Verification Contract

See solution.md §4 "Risk Surfaces And Source Of Truth" table verbatim —
covers refresh-on-401 (AC2), refresh storm, token leak, session persistence
(AC3), sign-out teardown (AC4), Firebase project match, R8 token exposure, and
app build gates.

## 4. Lane Summary

- Backend required: NO (read-only, A1 frozen)
- Frontend required: NO
- Mobile required: YES
- DevOps required: YES (P1 only — Firebase project config)
- Initial implementation owners: DevOps (P1), Mobile Developer (P2)
- Final verification owner: Mobile Developer (P5)
- Shared contract owner: Tech Lead (`architecture/solution.md` §2)
- Impacted runtime services/apps:
  - `mobile-app`: mobile, startup smoke per P5 gate (`flutter build apk --debug`
    + one real sign-in path on device/emulator), command/source
    `data/devops/system/runtime-command-registry.json` -> `mobile-app`

## 5. Phases Overview

(Lifted verbatim from `architecture/solution.md` §8.)

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|---|
| P1 | DevOps | devops | — | yes (with P2) | `mobile/android/app/`, `mobile/ios/Runner/`, `mobile/lib/firebase_options.dart`, `deployment/configuration-guide.md` | §2 DevOps contract, ADR-011b | Firebase config for both platforms; `project_id` match confirmed; configuration guide updated | `flutter build apk --debug` compiles with Firebase initialized | PENDING |
| P2 | Mobile | mobile | — | yes (with P1) | `mobile/lib/core/auth/**`, `mobile/pubspec.yaml` | ADR-011a/b/c, §2 | `cupid_session.dart`, `firebase_id_token_provider.dart`, `cupid_auth_failure.dart`, `cupid_auth.dart` | Unit: token read/force-refresh, session state transitions | PENDING |
| P3 | Mobile | mobile | P2 | no | `mobile/lib/core/auth/cupid_auth_interceptor.dart`, `mobile/lib/core/network/cupid_interceptor_slots.dart`, `mobile/lib/core/di/service_locator.dart` | ADR-011c/d/g | Interceptor in the `auth` slot; diagnostics redaction; `get_it` registrations | Unit: refresh-on-401, single retry, single-flight, no token in debug log | PENDING |
| P4 | Mobile | mobile | P3 | no | `mobile/lib/features/auth/**` | UX §3/§4b/§6, §2 `AuthRepository` | Repository, three Cubits, `splash`/`welcome`/`login`/`register`/`forgot` wiring incl. session-expired heading variant and inline error mapping | Widget: splash gate branches; unit: `CupidAuthFailure` mapping | PENDING |
| P5 | Mobile | mobile | P1, P4 | no | `mobile/test/**` | all ACs | Sign-out confirm + teardown; AC1-AC4 verification | `flutter analyze` clean, `flutter test` green, `flutter build apk --debug`, one real sign-in path exercised on device/emulator | PENDING |

Phase sizing: each phase is at or under six source/test files.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | inline — `architecture/solution.md` §4 "DevOps Lane Handoff" + ADR-011b |
| P2 | inline — `architecture/solution.md` ADR-011a/b/c, §2 |
| P3 | inline — `architecture/solution.md` ADR-011c/d/g |
| P4 | inline — `architecture/solution.md` UX §3/§4b/§6, §2 `AuthRepository` |
| P5 | inline — `architecture/solution.md` §4 Risk Surfaces table (all rows) |

This run used `Mode: compact-story-plan` and a declared WriteScope of
`architecture/**` only, so phase detail is inline in `architecture/solution.md`
(ADR-011a..h, §4 Mobile/DevOps Lane Handoff, §4 Risk Surfaces table) rather
than in separate `coding-plan/phase-*.md` files. Each phase id maps to exactly
one architecture section; there are no duplicate phase definitions. Do not
re-run Tech Lead for phase detail — read the named `architecture/solution.md`
sections directly per phase.

## 6. Phase Detail

Not duplicated here — see "Phase file mapping" above. Each phase owner reads
the named `architecture/solution.md` section(s) directly rather than a
separate phase file.

## 7. Result Log

(Dated notes appended here as each phase completes.)
