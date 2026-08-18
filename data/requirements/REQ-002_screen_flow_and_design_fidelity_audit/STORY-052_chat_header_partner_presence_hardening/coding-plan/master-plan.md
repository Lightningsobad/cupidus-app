# Master Coding Plan – Chat Header Partner Pairing + Presence Chip

## 1. Planning Metadata

- Story ID: STORY-052_chat_header_partner_presence_hardening
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: Backend Developer (P0), per
  `../architecture/contract-summary.md`.
- Contract-first phase required: YES — the contract's consumer sits in a
  different lane *and* a different deploy unit (NestJS service vs. Flutter app).
- Parallel execution possible: NO
- Critical path: P0 -> P1 -> P2
- Parallelism notes: P1 cannot start before P0 because the partner name has no
  other source (`../architecture/solution.md` §1 Key Discovery). P2 cannot start
  before P1 because its header composition reads P1's new store getters.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| `GET /users/me` `partnerDisplayName` | Backend Developer | P0 | P1 | `../architecture/contract-summary.md` sections 2-3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Partner identity sourcing | P0 |
| Self-vs-partner name plumbing (latent defect, Key Discovery item 3) | P0, P1 |
| Shared-component backward compatibility (16 other consumers) | P2 |
| ADR-004 raw-color-literal guard | P2 |
| Design fidelity of the `chat` screen | P0, P1, P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `backend-api`: `backend`, startup smoke `OPTIONAL` (not run by an
    implementation phase), command/source runtime registry `devCommand`
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `buildCommand`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|-------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Backend Developer | Backend | None | NO | `backend/src/modules/users/` (service, controller, service spec) | `../architecture/contract-summary.md` §2-3; `../architecture/solution.md` §4 Backend Lane | `partnerDisplayName` on `GET /users/me` | unit (paired/unpaired/dangling/null-name) + `npm run build` | NOT_STARTED |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/chat/data/`, `.../chat/presentation/screens/chat_screen.dart`, `mobile/lib/core/di/`, `mobile/lib/main_preview.dart`, `mobile/test/features/chat/` | `../architecture/contract-summary.md`; P0 response | `ChatPartnerStore.selfDisplayName` + `.partnerDisplayName`; repointed `GhostBubble`/`ChatComposer` args | store unit (distinct-key mapping, sign-out) + `flutter analyze` | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/design_system/adaptive/cupid_header.dart`, `.../tokens/partner_chip_palette.dart`, `.../chat/presentation/widgets/partner_presence_chip.dart`, `chat_screen.dart`, chat ARB, `mobile/test/design_system/adaptive_widgets_test.dart` | `../ux/uiux-spec.md` §1-4; `../architecture/solution.md` §4; P1 getters | `CupidHeader.trailing`; gradient token; presence chip; composed header | unset-`trailing` tree identity (both platform branches), `no_fork_guard_test.dart`, `flutter analyze`, `visual-fidelity/` pair | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-users-me-partner-display-name.md` |
| P1 | `phase-P1-partner-identity-plumbing.md` |
| P2 | `phase-P2-header-slot-and-presence-chip.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- Backend/frontend/mobile implementation phases must fit one specialist
  lifecycle (roughly six source/test files max) or be split.
- No trailing verification/testing phase exists; each phase owns its own
  targeted tests and build/type-check.

## 6. Notes

- P1 and P2 are split because together they are ~11 source/test files, over one
  mobile lifecycle — not because they both touch `chat_screen.dart`. They are
  two distinct behavior clusters: identity plumbing (P1) and design-system slot
  plus chip render (P2). Both edit `chat_screen.dart` in sequence in the same
  lane, which is ordering, not contention.
- No API-client regeneration phase exists. `../architecture/solution.md` §3
  "Generated API Client" records why regeneration would be a byte-identical
  no-op for this endpoint.
- This story's own `visual-fidelity/` evidence pair is owned by P2's test scope
  (it is the phase that first renders the finished header), not by a separate
  phase.
