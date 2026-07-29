# Story 1.5: Fingerprint Vow (Pairing Confirmation)

**Epic:** 1 - Core Connection Foundation
**Status:** done

## User Story
As a User,
I want to confirm pairing via biometrics,
So that the commitment feels official and secure.

## Acceptance Criteria

- [ ] **Biometric Validation**
    - **Given** both users have signed the contract and are on the pairing screen
    - **When** they place their finger on the fingerprint icon (biometric prompt)
    - **Then** the system should validate the biometric via Local Authentication

- [ ] **Success Animation**
    - **Given** biometric validation is successful
    - **When** the vow is confirmed
    - **Then** trigger a "Boom" success animation

- [ ] **Dashboard Unlock**
    - **Given** the animation completes
    - **When** the vow is fully taken
    - **Then** unlock the main Dashboard

## Tasks/Subtasks

### Backend
- [x] Add `vowTaken` field to `User` entity
- [x] Create `markVowTaken` method in `UsersService`
- [x] Expose `POST /users/vow` endpoint

### iOS
- [x] Create `BiometricService` using `LocalAuthentication`
- [x] Implement `FingerprintButton` and biometrics logic in `PairingConfirmationView`
- [x] Create `VowSuccessView` with "BOOM" animation
- [x] Update `AuthenticationService` to call backend `markVowTaken`
- [x] Handle transition to Dashboard after success

## Dev Agent Record

### File List
- `backend/src/modules/users/entities/user.entity.ts`
- `backend/src/modules/users/users.service.ts`
- `backend/src/modules/users/users.controller.ts`
- `ios/CupidApp/App/Core/Services/BiometricService.swift`
- `ios/CupidApp/App/Features/Pairing/VowSuccessView.swift`
- `ios/CupidApp/App/Features/Pairing/PairingConfirmationView.swift`
- `ios/CupidApp/App/Core/Services/AuthenticationService.swift`

### Implementation Notes
- Used `LocalAuthentication` context for biometrics.
- Added a simple boolean `vowTaken` to User entity.
- Success view uses a Lottie-like full screen overlay (implemented as SwiftUI View with basic animation for now).
