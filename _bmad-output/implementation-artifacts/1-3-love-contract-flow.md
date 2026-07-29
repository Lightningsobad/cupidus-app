# Story 1.3: Love Contract Flow

Status: done

## Story

As a User,
I want to review and sign the Love Contract,
so that we establish our relationship rules in a fun way.

## Acceptance Criteria

1. **Review Rules**
   - **Given** the user is in the onboarding flow
   - **When** they reach the Love Contract step
   - **Then** they should see a predefined list of humorous clauses (e.g., "No going to bed angry")

2. **Customize Rules**
   - **Given** the user wants to customize
   - **When** they tap "Edit Clauses"
   - **Then** they can add a new custom rule or remove an existing one

3. **Signing**
   - **Given** the user is ready to commit
   - **When** they sign (tap and hold) the contract
   - **Then** the contract should be marked as "Signed by User" and waiting for Partner

## Tasks / Subtasks

- [x] **Backend Implementation** (NestJS)
  - [x] Create `LoveContract` entity (clauses, status, requesterId)
  - [x] Create `LoveContractsController` (GET, POST, PATCH)
  - [x] Implement service logic for creating/updating contract
  - [x] Unit Tests

- [x] **iOS Implementation** (SwiftUI)
  - [x] Create `LoveContract` model and `LoveContractViewModel`
  - [x] Implement `LoveContractView` (List of clauses)
  - [x] Implement "Hold to Sign" button animation
  - [x] Integrate API to create/sign contract
  - [x] Implement Edit Clauses UI (Add/Remove)

- [x] **Integration & Verification**
  - [x] Verify contract creation on backend
  - [x] Verify signed status
  - [x] Manual walkthrough

## Dev Notes

### Implementation Details
- **Backend**: Implemented `LoveContractsModule` with `LoveContract` entity. Statuses: `CREATED`, `SIGNED_REQUESTER`, `SIGNED_PARTNER`.
- **iOS**: Used `MainActor` for ViewModels and Services. Implemented "Hold to Sign" using `Task.sleep` for smooth animation compatible with Swift 6 concurrency.
- **Navigation**: Refactored `AuthCoordinator` to intelligently route based on `userProfile` completeness and contract status.

### Verification
- Backend Unit Tests passed.
- iOS Unit Tests passed (ViewModel logic).
- Build successful.

## Dev Agent Record
- Agent: Gemini 2.0 Flash

## Senior Developer Review (AI)
- **Date**: 2026-02-14
- **Reviewer**: Helper Agent

### Findings
1.  **CRITICAL**: `LoveContractsService.create` allowed updating clauses even if the contract was `SIGNED_REQUESTER`. This would violate the immutability of signed contracts.
    -   **Fix**: Added check to reset status to `CREATED` and clear `signedAtRequester` if a signed contract is modified. Added regression test.
2.  **MEDIUM**: Missing input validation for `clauses`.
    -   **Fix**: Added `ArrayMaxSize(20)` and `IsString` validation to `CreateContractDto`.
3.  **LOW**: Lint error regarding `Date` vs `Date | null` in `LoveContract` entity.
    -   **Fix**: Updated entity type definition.

### Outcome
- **Status**: Approved (with fixes applied)
- **Tests**: Verified with `npm test`. All passed.
