# Master Plan: STORY-019 — Love Contract Partner Visibility

Story: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-019_love_contract_partner_visibility/story_master.md`
Architecture: `../architecture/solution.md`
Cross-lane contract (authoritative): `../architecture/contract-summary.md`
Complexity: standard | Lane: shared (backend + mobile) | Phases: 3

## Phase Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|---|
| P1 | backend-dev | backend | NONE | Yes (with P2, contract is frozen in `contract-summary.md`) | `backend/src/modules/love-contracts/love-contracts.service.ts`, `.../love-contracts.controller.ts`, `.../love-contracts.module.ts`, `.../dto/love-contract-response.dto.ts`, `.../love-contracts.service.spec.ts` | `../architecture/contract-summary.md`, ADR-019a/b/e/f | Partner-resolving `findContractForUser`, `partnerId` population + lazy backfill, role-branched idempotent `sign()`, 409 create guard, `viewerRole` response DTO | `cd backend && npm test -- love-contracts` + `npm run build` | DONE |
| P2 | mobile-dev | mobile | P1 (contract only; may start in parallel from `contract-summary.md`) | Yes (with P1) | `mobile/lib/features/love_contracts/data/love_contract.dart`, `.../data/love_contract_repository.dart`, `.../presentation/love_contract_bloc.dart`, `.../presentation/love_contract_state.dart`, `mobile/test/features/love_contracts/data/love_contract_repository_test.dart`, `mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart`, plus compile-keeping switch arms only in `.../screens/love_contract_screen.dart` | `../architecture/contract-summary.md` §Client Derivation Rule, ADR-019c/d/e | Viewer-aware `ContractSignStatus` + `ContractViewerRole`, timestamp-derived state, partner sign-only bloc branch | `cd mobile && flutter test test/features/love_contracts/data test/features/love_contracts/presentation/love_contract_bloc_test.dart` | DONE |
| P3 | mobile-dev | mobile | P2 | No | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`, `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`, `mobile/lib/l10n/arb/app_en.arb`, `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/generated/**` (regenerated), `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart` | `../ux/uiux-spec.md` §2 table + §3, ADR-019e, Assumption A-1 | "Partner-already-signed" state, both-signed status line, clause affordances hidden for the partner, entry-point reachability re-asserted for the partner viewer | `cd mobile && flutter test test/features/love_contracts` | DONE |

## Sequencing Notes

- P1 and P2 may run in parallel: `contract-summary.md` freezes the response
  shape, so mobile does not wait on backend code. P2 must not invent fields
  beyond it.
- P3 is strictly after P2 — it consumes the new `ContractSignStatus` values and
  the viewer role on `LoveContractReady`.
- P1's `create()` 409 guard and P2's partner sign-only branch are two halves of
  ADR-019e. Neither phase may be marked complete citing the other as coverage.
- P2 and P3 both touch `love_contract_screen.dart`, and that is deliberate, not
  a split to undo: removing the `awaitingPartner` enum value breaks the screen's
  exhaustive switch, so P2 makes the two-line arm fix that keeps the tree
  compiling and P3 owns all copy, CTA, and affordance work in that file.

## Entry Point (skill rule 13a)

The capability's discoverable surface already exists
(`love_contract_entry_tile.dart` on `Me`, plus `LoveContractGateRoute`). P3 is
the entry-point phase: it must prove the surface is reachable and correct for
the **partner** viewer, not just the requester, and must not weaken the AC4
hide-not-disable gate that the same files implement.

## Acceptance Criteria Coverage

| AC | Phases |
|---|---|
| AC1 `partnerId` populated, no schema change | P1 |
| AC2 partner can view and acknowledge/accept | P1 (sign branching) + P2 (sign-only path) + P3 (CTA) |
| AC3 both partners view, role-correct sign state | P1 (`viewerRole`) + P2 (mapping) + P3 (copy/CTA) |
| AC4 unpaired users still blocked | P1 (unpaired-caller test) + P3 (gate tests unchanged and green) |

## Build / Verification Gate

- Backend: `cd backend && npm test -- love-contracts && npm run build`
  (registry id `backend-api`).
- Mobile: `cd mobile && flutter test test/features/love_contracts` and
  `flutter analyze` (registry id `mobile-app`; the Flutter SDK is resolved via
  `FLUTTER_SDK_PATH`, it is not on `PATH`).
- Backend e2e, Playwright, and runtime startup smoke are out of scope for these
  phases.
- Each phase records its own evidence in `coding-plan/test-results.md` before
  claiming its `*_COMPLETE: YES` marker.

## Out of Scope Guardrails

- No new `ContractStatus` enum value, no migration, no new persisted field.
- No partner-side clause editing or renegotiation.
- No change to the AC4 pairing gate contract.
- No change to `POST /love-contracts` / `PATCH /love-contracts/sign` paths,
  methods, or request bodies — the generated `mobile/openapi` client is not
  regenerated.
