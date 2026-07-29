# Story 2.4: Typing Ghost Controls & Consent

**Epic:** 2. Radical Transparency Communication
**Story ID:** 2.4
**Status:** In Progress
**Owner:** Alan

## Description
As a User, I want to control whether my typing is streamed in real-time, so that I can maintain some privacy if needed, while still participating in the radical transparency experiment.

## Acceptance Criteria
- [ ] **Given** the user is in their Profile/Settings
  - [ ] **When** they toggle "Ghost Mode" (Real-time Typing)
  - [ ] **Then** the preference should be saved to the backend

- [ ] **Given** Ghost Mode is DISABLED
  - [ ] **When** the user types in chat
  - [ ] **Then** NO `typing` events should be sent to the partner
  - [ ] **And** the partner should see nothing (or standard "typing..." if we fallback, but for now nothing)

- [ ] **Given** Ghost Mode is ENABLED
  - [ ] **When** the user types
  - [ ] **Then** `typing` events are broadcasted as per Story 2.3

## Technical Tasks
- [ ] **Backend: User Entity**
  - [ ] Add `isGhostModeEnabled` (boolean, default true) to `User` entity
  - [ ] Update `UsersController` / `UsersService` to allow toggling this flag
  - [ ] Update `ChatGateway`: Check sender's `isGhostModeEnabled` before broadcasting (or rely on client not sending) - *Better to check on server for security*

- [ ] **iOS: Settings UI**
  - [ ] Add "Ghost Mode" toggle to `ProfileView` (or new Settings section)
  - [ ] Bind toggle to `AuthViewModel` or `ProfileViewModel` update logic
  
- [ ] **iOS: Chat Logic**
  - [ ] Update `ChatViewModel` to check `currentUser.isGhostModeEnabled` before emitting `typing` events
  - [ ] (Optional) Visual indicator in Chat that "Ghost Mode is Off"

## Dependencies
- Story 2.3 (Typing Mechanics)

## Risks
- Users might disable it permanently, reducing the "Radical Transparency" value proposition.
