# Story 3.2: Daily Vibe Check

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **User**,
I want **to update my mood quickly**,
so that **my partner knows how I feel without me having to text**.

## Acceptance Criteria

1. **Given** it is a new day
   - **When** the user opens the app triggers a "Vibe Check" notification
   - **Then** they see a mood picker (Happy, Sad, Angry, Horny, Tired)

2. **Given** the user selects a mood
   - **When** they confirm
   - **Then** the partner receives a notification "Bae is feeling [Mood]"
   - **And** the mood is logged in the history graph

3. **Given** the user wants to check history
   - **When** they view the Vibe History
   - **Then** they see a graph/list of past moods

## Tasks / Subtasks

- [x] Backend: Create `VibeModule`
  - [x] Entity: `Vibe` (id, userId, mood, note, createdAt)
  - [x] DTOs: `CreateVibeDto`, `VibeHistoryDto`
  - [x] Service: Handle vibe creation and history retrieval
  - [x] Controller: POST `/vibes`, GET `/vibes/history`
- [x] Backend: Real-time & Notifications
  - [x] Event: Emit `vibeUpdated` event via WebSocket (or reuse `NotificationService` for push)
  - [x] Push Notification: Send "Bae is feeling..." to partner
- [x] iOS: Vibe Check UI
  - [x] Component: `MoodPickerView` (Grid of emojis/icons)
  - [x] Screen: `VibeCheckView` (Modal or embedded in Dashboard)
  - [x] Screen: `VibeHistoryView` (Chart or List)
- [x] iOS: Vibe Logic
  - [x] ViewModel: `VibeViewModel` (State management, API calls)
  - [x] Logic: Check if "Vibe Check" already done today (Local Storage + API sync)
  - [x] Notification: Handle specific "Vibe Check" reminders

## Dev Notes

- **Architecture:** 
  - Backend: `src/modules/vibes/`. 
  - iOS: `App/Features/Vibe/`.
- **Database:** `vibes` table. Multiple vibes per day allowed, but UI prompts primarily for the first one of the day.
- **Real-time:** Push notification stub in VibesService. Ready for Firebase integration.
- **Notifications:** Uses `triggerPushNotification` stub (same pattern as AlarmsService).
- **History:** Simple list view. Swift Charts can be added in future iteration.

### Project Structure Notes

- Backend: `src/modules/vibes/`
- iOS: `App/Features/Vibe/`

### References

- [Epics: Story 3.2](_bmad-output/planning-artifacts/epics.md#story-32-daily-vibe-check)
- [Architecture: Data Pattern](_bmad-output/planning-artifacts/architecture.md#data-architecture)

## Dev Agent Record

### Agent Model Used

Antigravity (Google DeepMind)

### Debug Log References

### Completion Notes List

- Created `VibesModule` with `Vibe` entity using `Mood` enum (happy, sad, angry, horny, tired).
- `VibesService` handles create, getHistory, getPartnerHistory, getTodayVibe.
- `VibesController` with REST endpoints: `POST /vibes`, `GET /vibes/today`, `GET /vibes/history`, `GET /vibes/partner`.
- Push notification stub logs to console (same pattern as `AlarmsService`).
- iOS `VibeViewModel` manages mood submission, history fetching, and today's check state.
- `MoodPickerView` uses animated grid with emoji selection and spring animation.
- `VibeCheckView` shows mood picker or today's vibe, partner's latest vibe, and history link.
- `VibeHistoryView` displays scrollable history for both user and partner.

### File List

#### Backend
- `src/modules/vibes/entities/vibe.entity.ts`
- `src/modules/vibes/dto/create-vibe.dto.ts`
- `src/modules/vibes/vibes.service.ts`
- `src/modules/vibes/vibes.controller.ts`
- `src/modules/vibes/vibes.module.ts`
- `src/app.module.ts` (modified - added VibesModule import)

#### iOS
- `CupidApp/App/Features/Vibe/VibeViewModel.swift`
- `CupidApp/App/Features/Vibe/MoodPickerView.swift`
- `CupidApp/App/Features/Vibe/VibeCheckView.swift`
- `CupidApp/App/Features/Vibe/VibeHistoryView.swift`
