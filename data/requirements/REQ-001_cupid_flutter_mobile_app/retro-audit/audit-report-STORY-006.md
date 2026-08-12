# Retro Audit Report — STORY-006 love_contracts

Story: STORY-006 Epic-1 Love Contracts / Nghi Thức Cam Kết
Requirement: REQ-001_cupid_flutter_mobile_app
Run Key: 2026-08-12:REQ-001:STORY-006:retro-audit
Reviewer: Iris-QC (retro-audit)
Story-Class: standard, Implementation Lane: mobile, UI-bearing

## Scope And Method

Independent re-verification of current code (control checkout `main`,
`f7d06fd`), not a re-read of prior review conclusions. Evidence sources:
`story_master.md`, `req_master.md`, `architecture/solution.md` (ADR-006a/b/c),
`coding-plan/test-results.md`, `review/review-report.md`,
`data/intake/bootstrap/conflicts_open_questions.md`,
`data/devops/system/design-fidelity-config.json`, and direct reads of:
- `backend/src/modules/love-contracts/love-contracts.service.ts`
- `backend/src/modules/love-contracts/love-contracts.controller.ts`
- `backend/src/modules/love-contracts/entities/love-contract.entity.ts`
- `backend/src/modules/love-contracts/dto/create-contract.dto.ts`
- `mobile/lib/features/love_contracts/data/love_contract_repository.dart`
- `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`
- `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`

## Substantive Findings - STORY-006

Run Key: 2026-08-12:REQ-001:STORY-006:retro-audit
Story: STORY-006

### AC-by-AC Traceability

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — A paired user can create/propose a love contract | PASS | `love_contract_repository.dart:43-53` `saveClauses()` posts `{'clauses': [...]}` to `/love-contracts`; backend `love-contracts.controller.ts:18-23` → `love-contracts.service.ts:14-44` `create()` persists `requesterId`, `clauses`, `status: CREATED` (upserts on repeat call). Confirmed independently, not just via `love_contract_repository_test.dart` claims. |
| AC2 — The partner can view and acknowledge/accept it per the backend's supported flow | **FAIL** | Independently verified deeper than the story's own framing. `love-contracts.service.ts:14-44` `create()` sets only `requesterId`; `CreateContractDto` (`dto/create-contract.dto.ts`) has no `partnerId` field and nothing else in the module ever writes `partnerId`. `getMyContract()` (`love-contracts.service.ts:67-75`) queries `{requesterId: userId} OR {partnerId: userId}`; since `partnerId` is always `null` on every row, the `partnerId` branch can never match any user. The partner's own `GET /love-contracts/my-pending` call (mobile `love_contract_repository.dart:27-38` `fetchCurrent()`) therefore returns `null` unconditionally — the partner cannot even **see** the creator's contract, let alone acknowledge or accept it. This is a stronger failure than the story artifacts document: `test-results.md` and `review/review-report.md` describe this as "creator can sign; app renders awaiting-partner" (implying the partner still sees an awaiting-signature view), but no such partner-visible view exists anywhere in the client (`love_contract_state.dart:44-119` `LoveContractReady` is driven entirely by the current user's own `fetchCurrent()` result, with no partner/requester distinction and no second data source). |
| AC3 — Both partners can view the list/detail of active love contracts | **FAIL** | Same root cause as AC2. `fetchCurrent()` → `GET /love-contracts/my-pending` only ever returns the creator's own row for the creator; for the partner it returns `null` (empty state), rendered by the screen as if no contract exists at all. "Both partners can view" is unmet — only the creator can view anything. The story's own AC3 verification (`test-results.md` line ~50-57: "AC3 at the ADR-006c capability... rendered as one current contract... PASS at the stated capability limit") is inaccurate: it was verified against the creator's own fetch path only, not against what the partner actually receives. |
| AC4 — Unpaired users cannot access this feature | PASS | `love_contract_entry_tile.dart:43-68` `resolvePairingState()`-gated `FutureBuilder`: tile renders `SizedBox.shrink()` unless `state.isPaired`; fails closed on null/error state per the widget doc comment ("hidden is safer than broken"). Consistent with prior review's confirmation that the gate is asserted twice (entry tile + `LoveContractGateRoute`). |

### Design Fidelity

`data/devops/system/design-fidelity-config.json` names a locked
`design_source` (`claude-design`, `cupid-app-design-system/project`) and
`ui_surface: true`, so Design Fidelity is in scope for this mobile,
UI-bearing story.

| Screen | Design Reference | Implemented Capture | Result | Deviation |
| --- | --- | --- | --- | --- |
| Love Contract / ceremony screen group | none captured | none captured | UNVERIFIED | No dedicated render exists. The reused `integration-review/mobile-visual-audit.md` (Result: FAIL, 10/37 screens) does not include any love-contracts screen among its 10 captured screens. A missing render is not a PASS; no rendered-evidence comparison was possible. |

### Open Question Relevance

| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ-006A (story-local only; no central OQ id) | Yes — directly gates AC2/AC3 | Partner sign (AC2) **and** partner view (AC3, broader than the story records) | None found. No row in `data/intake/bootstrap/conflicts_open_questions.md` (read in full, 158 lines — no "love contract", "dual signature", or "OQ-006A" match). No `## Open Question Triage` or `## Approved Scope Change` section in `req_master.md` (read in full, 166 lines). The only place this is recorded is downstream story-local artifacts: `story_master.md` Open Items, `architecture/solution.md` ADR-006c, `coding-plan/master-plan.md` §6, `coding-plan/test-results.md`, `review/review-report.md` — none of which are an authoritative approval source per the reviewer's Open Question And Scope Authority rule. | RED-PATCH |

### OQ Discipline Findings

- OQ-006A is real (confirmed independently from `love-contracts.service.ts`), but it is **self-declared and self-approved within the story's own artifact chain**. Every artifact that labels it "non-blocking" (`story_master.md`, `architecture/solution.md`, `master-plan.md`, `test-results.md`, `review/review-report.md`) is a downstream/implementation artifact, not a central Open Question registry row, not a Product Owner-owned `## Open Question Triage` / `## Approved Scope Change` section, and not a cited explicit user decision. Per the reviewer's authority rule, none of these can approve a scope change on their own.
- This is an **unapproved scope cut**, and it is materially larger than what the story itself represents: the story frames it as "AC2/AC3 ship at creator-only capability" (implying the partner can at least see an awaiting-signature state); independent verification of `getMyContract()`'s query condition against `create()`'s field-set shows the partner cannot see the contract at all. The feature as shipped is a private, single-user clause checklist, not a "shared… mutually agreed record" between partners as the User Story states.
- No existing central OQ (OQ4, OQ5, R8, D1 copy conflict, VPS ambiguity, backend/service-account items) covers this AC/contract drift; it needs Product Owner triage or an explicit user decision — either (a) accept the reduced/private scope and correct AC2/AC3 wording accordingly, or (b) escalate for a narrow A1 backend exception so `partnerId` can actually be populated and consumed.
- The prior story-scoped review (`review/review-report.md`, `Outcome: CLEAN`, 2026-07-31) accepted OQ-006A as "confirmed, not re-raised" and treated it purely as a recorded product decision point rather than testing whether the AC2/AC3 wording was actually satisfied at the capability the backend allows. That review did not independently trace `getMyContract()`'s `partnerId` matching logic against `create()`'s field set, so it did not catch that the partner-visibility gap is broader than "no sign affordance."

Story-level Substantive Verdict: SIGNIFICANT_GAPS
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
