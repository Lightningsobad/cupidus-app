# Story 1.4: Partner Invitations & Linking

Status: done

## Story

As a User,
I want to invite my partner via a link,
so that we can be paired in the app.

## Acceptance Criteria

1. **Invite Partner**
   - **Given** the user has signed the contract
   - **When** they tap "Invite Partner"
   - **Then** the system should generate a unique dynamic link (e.g., cupid://pair?code=XYZ)
   - **And** open the native share sheet to send it via messaging apps

2. **Accept Invitation**
   - **Given** the partner clicks the invite link
   - **When** they open the app
   - **Then** they should be taken directly to the Pairing Confirmation screen linked to the inviter
   - **And** see the inviter's profile details

3. **Couple Type Selection**
   - **Given** the couple is pairing
   - **When** they select "Couple Type" (Long Distance / Same City)
   - **Then** the app should configure initial default settings based on that type

## Tasks / Subtasks

- [x] **Backend Implementation** (NestJS)
  - [x] Implement `InvitationsModule` (Generate/Validate codes)
  - [x] Update `UsersService` to handle pairing (`partnerId`)
  - [x] Create `CoupleProfile` entity (optional, or just link users)
  - [x] API `POST /invitations/generate`
  - [x] API `POST /invitations/accept` (with code)

- [x] **iOS Implementation** (SwiftUI)
  - [x] Implement `InvitePartnerView` (Generate Link + Share Sheet)
  - [x] Implement Deep Link Handling (`onOpenURL`)
  - [x] Implement `PairingConfirmationView` (Show Inviter + Accept)
  - [x] Implement `CoupleTypeView` (Select Relationship Type)
  - [x] Update `AuthCoordinator` to handle `invitePartner` and `pairing` steps

- [x] **Integration & Verification**
  - [x] Verify Link Generation
  - [x] Verify Link Opening acts as "Accept" (or pre-fills code)
  - [x] Verify Users are linked in DB
  - [x] Manual Walkthrough

## Dev Notes
- **Deep Linking**: Use Custom URL Scheme `cupid://pair?code=...` for MVP simplicity in Simulator.
- **Database**:
  - `Invitation` entity: `code`, `inviterId`, `status`, `expiresAt`.
  - `User` entity: `partnerId`, `coupleType`.
- **Couple Type**: Enum `LONG_DISTANCE`, `SAME_CITY`.

## Dev Agent Record
- Agent: Gemini 2.0 Flash

### File List
- `backend/src/modules/invitations/entities/invitation.entity.ts`
- `backend/src/modules/invitations/invitations.service.ts`
- `backend/src/modules/invitations/invitations.controller.ts`
- `backend/src/modules/invitations/invitations.module.ts`
- `backend/src/modules/users/users.service.ts`
- `backend/src/modules/users/dto/update-profile.dto.ts`
- `backend/src/app.module.ts`
- `ios/CupidApp/App/Core/Services/InvitationService.swift`
- `ios/CupidApp/App/Features/Pairing/InvitePartnerView.swift`
- `ios/CupidApp/App/Features/Pairing/PairingConfirmationView.swift`
- `ios/CupidApp/App/Features/Pairing/CoupleTypeView.swift`
- `ios/CupidApp/App/Features/Auth/AuthCoordinator.swift`

### Change Log
- 2026-02-14: Code review fixes — re-pairing guard, typed validateCode, response contract fix, File List added
