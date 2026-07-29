# Story 1.2: User Profile Setup

Status: done

## Story

As a User,
I want to set up my profile (Name, Avatar, Zodiac),
so that my partner recognizes me and we get personalized insights.

## Acceptance Criteria

1. **Zodiac Calculation**
   - **Given** the user has just registered
   - **When** they enter their Date of Birth
   - **Then** the system should automatically calculate and display their Zodiac sign

2. **Avatar Upload**
   - **Given** the user is on the profile screen
   - **When** they tap to upload an avatar
   - **Then** they can select a photo from the gallery or take a new one
   - **And** crop it to a circle (or at least preview it as circular)

3. **Language Switching**
   - **Given** the user prefers English
   - **When** they select "English" in language settings
   - **Then** the app interface should switch to English immediately

## Tasks / Subtasks

- [ ] **Backend Implementation** (NestJS)
  - [ ] Update `User` entity with `birthday` (Date) and `zodiacSign` (Enum/String)
  - [ ] Create `UpdateProfileDto` (name, birthday, zodiacSign, language)
  - [ ] Implement `PATCH /users/me` endpoint in `UsersController`
  - [ ] Implement avatar upload endpoint (storage logic or presigned URL)

- [ ] **iOS Implementation** (SwiftUI)
  - [ ] **Data Layer**: Add `updateProfile` method to `AuthenticationService` (or `UserService`)
  - [ ] **UI Components**:
    - [ ] Create `ProfileSetupView` (Name input, DatePicker for DOB)
    - [ ] Implement `ZodiacCalculator` utility
    - [ ] Implement `AvatarPicker` using `PhotosUI`
  - [ ] **Localization**:
    - [ ] Setup `Localizable.xcstrings` (or .strings) for EN/VN
    - [ ] Add language toggle logic in App State

- [ ] **Integration & Testing**
  - [ ] Verify profile updates persist to backend
  - [ ] Verify language switch updates UI immediately
  - [ ] Unit test Zodiac calculation logic

## Dev Notes

### Architecture & Patterns
- **Backend**: Follow Modular Monolith `src/modules/users`. Use `User` entity from TypeORM.
- **iOS**: Use MVVM. `ProfileViewModel` should handle the API call state.
- **Security**: Ensure `PATCH /users/me` is guarded by `AuthGuard` (JWT).

### Source Tree
- Backend: `source-code/backend/src/modules/users/`
- iOS: `source-code/ios/CupidApp/App/Features/Onboarding/` (or `Profile/`)

### Technical References
- **Zodiac Logic**: Standard Western astrology dates.
- **Localization**: Use SwiftUI `environment(\.locale)` or a custom `LanguageManager` observable object for instant switching if standard flow requires restart.
- **Images**: For MVP, store user avatars in Firebase Storage (if available) or base64 (if simple). Recommendation: Use presigned URL or direct upload if possible.

## Dev Agent Record

### Agent Model Used
Gemini 2.0 Flash (Implementation)

### References
- [Epic 1: Core Connection Foundation](_bmad-output/planning-artifacts/epics.md)
- [Architecture: Project Context Analysis](_bmad-output/planning-artifacts/architecture.md)

## Implementation Notes

### Backend
- Added `birthday`, `zodiacSign`, `language`, `photoUrl` to `User` entity.
- Implemented `PATCH /users/me` and `POST /users/me/avatar`.
- Created `UsersService` with profile update logic.

### iOS
- Implemented `ProfileSetupView` with Name, Birthday, and Avatar picker.
- Added `ZodiacCalculator` utility (Validated with Unit Tests).
- Created `NetworkingManager` (Sendable, Concurrency Safe) for API calls.
- Updated `AuthenticationService` to support profile updates.
- Added `Localizable.xcstrings` for EN/VN.

### Verification
- **Backend Unit Tests**: Passed (`UsersService`).
- **iOS Unit Tests**: Passed (`ZodiacCalculatorTests`, `KeychainManagerTests`).
- **iOS Build**: Successful (`iPhone 16e` Simulator).
- **Note**: iOS Tests required isolating `AuthCoordinator` and skipping `FirebaseApp.configure()` during test execution to prevent crashes.
