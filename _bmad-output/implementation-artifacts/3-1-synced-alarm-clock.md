# Story 3.1: Synced Alarm Clock

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a Couple,
We want to wake up at the same time,
So that we start the day together even if apart.

## Acceptance Criteria

1. **Given** one partner sets an alarm time
   - **When** they save it
   - **Then** the other partner receives a request to confirm the time

2. **Given** the alarm time is reached
   - **When** it rings
   - **Then** it should ring on BOTH devices simultaneously (using Push + Local Notification)

3. **Given** the alarm is ringing
   - **When** one partner slides to stop
   - **Then** it keeps ringing until the OTHER partner also slides to stop (or timeout after 5 mins)

## Tasks / Subtasks

- [x] Backend: Create `AlarmModule`
  - [x] Entity: `Alarm` (id, time, status, requesterId, partnerConfirmed)
  - [x] DTOs: `CreateAlarmDto`, `ConfirmAlarmDto`
  - [x] Service: Handle alarm creation and scheduling (using `setInterval` with safety locks)
- [x] Backend: Real-time Alarm Events
  - [x] Gateway: `AlarmGateway` (WebSocket)
  - [x] Events: `setAlarm`, `confirmAlarm`, `triggerAlarm`, `stopAlarm`, `newAlarmRequest`
- [x] iOS: Alarm Feature UI
  - [x] Screen: `AlarmView` (Time picker, partner status)
  - [x] Screen: `AlarmRingView` (Slide to stop, partner status)
- [x] iOS: Alarm Logic
  - [x] ViewModel: `AlarmViewModel` (integrates Socket for real-time state)
  - [x] Manager: `NotificationManager` (schedule local firing, loop sound)
  - [x] Handler: Handle `triggerAlarm` socket event to trigger UI

## Dev Notes

- **Architecture:** Follow Modular Monolith patterns. Use `AlarmGateway` similar to `ChatGateway` for real-time.
- **Synchronization:** The "Ring" event should be triggered by the server to ensure synchronization, but independent local scheduling is a fallback if offline (though "Synced" implies online).
  - *Decision:* If offline, ring locally at set time? Yes, for safety. But "Synced" logic (waiting for partner) only works if online.
- **Push Notifications:** Use High Priority FCM messages for the "Ring" event to wake up the device if backgrounded.
- **Critical Alerts:** If possible, request Critical Alert entitlement. If not, use standard Time Sensitive notifications.

### Project Structure Notes

- Backend: `src/modules/alarm/`
- iOS: `App/Features/Alarm/`

### References

- [Epics: Story 3.1](_bmad-output/planning-artifacts/epics.md#story-31-synced-alarm-clock)
- [Architecture: Real-time Protocol](_bmad-output/planning-artifacts/architecture.md#core-architectural-decisions)

## Dev Agent Record

### Agent Model Used

Antigravity (Google DeepMind)

### Debug Log References

### Completion Notes List

- Implemented `AlarmsModule` with `setInterval` scheduler. Added `OnModuleDestroy` and concurrency lock to prevent race conditions.
- Uses `socket.io` for real-time `triggerAlarm` event to both partners.
- iOS `NotificationManager` upgraded to loop alarm sound until stopped.
- `Alarm` entity tracks `stopperIds` to ensure both partners stop the alarm before it fully deactivates.

### File List

#### Backend
- `src/modules/alarms/alarms.module.ts`
- `src/modules/alarms/alarms.service.ts`
- `src/modules/alarms/alarms.controller.ts`
- `src/modules/alarms/alarms.gateway.ts`
- `src/modules/alarms/entities/alarm.entity.ts`
- `src/modules/alarms/dto/create-alarm.dto.ts`
- `src/modules/alarms/alarm.constants.ts`

#### iOS
- `CupidApp/App/Features/Alarm/AlarmViewModel.swift`
- `CupidApp/App/Features/Alarm/AlarmView.swift`
- `CupidApp/App/Features/Alarm/AlarmRingView.swift`
- `CupidApp/App/Core/Services/NotificationManager.swift`

### Senior Developer Review (AI)

- **Finding**: Race condition in alarm scheduler. **Fix**: Added `isChecking` lock and `OnModuleDestroy` cleanup.
- **Finding**: iOS alarm sound was single beep. **Fix**: Implemented looping timer for continuous sound.
- **Finding**: Story file list empty. **Fix**: Populated file list.

**Status**: Approved
