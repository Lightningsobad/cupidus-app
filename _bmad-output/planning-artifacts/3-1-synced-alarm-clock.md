# Story 3.1: Synced Alarm Clock

**Epic:** 3. Daily Engagement & Habits
**Story ID:** 3.1
**Status:** In Progress
**Owner:** Alan

## Description
As a Couple, we want to wake up at the same time, so that we start the day together even if apart. The alarm should be synchronized, requiring both parties to "Stop" it effectively.

## Acceptance Criteria
- [ ] **Given** one partner sets an alarm time
  - [ ] **Then** the other partner receives a request to confirm the time.
  - [ ] **And** the alarm is only "Scheduled" when both confirm.

- [ ] **Given** the alarm time is reached
  - [ ] **Then** it should ring on BOTH devices simultaneously (via Local Notification if background, or In-App if foreground).

- [ ] **Given** the alarm is ringing
  - [ ] **When** one partner slides to stop
  - [ ] **Then** it keeps ringing until the OTHER partner also slides to stop (or timeout after 5 mins).
  - [ ] **And** the first partner sees a "Waiting for [Name]..." status.

## Technical Tasks
- [x] **Backend: Alarms Module**
  - [x] Create `Alarm` entity (`time`, `isActive`, `isPending`, `requesterId`, `partnerId`).
  - [x] Create `AlarmsGateway` for real-time events (`REQUEST`, `CONFIRM`, `RINGING`, `STOPPED`).
  - [x] Implement Push Notification trigger for the alarm time (reliability fall-back) - *Implemented as stub in AlarmsService*.

- [ ] **iOS: Notification Manager**
  - [ ] Request Critical Alert permissions (if possible) or standard Time Sensitive permissions.
  - [ ] Implement ability to schedule local notifications based on server time.

- [ ] **iOS: Alarm UI**
  - [ ] `AlarmSetupView`: DatePicker and "Propose Time" button.
  - [ ] `AlarmRingView`: Full-screen overlay with "Slide to Stop".
  - [ ] Socket integration to listen for `STOPPED` event from partner to clear the "Waiting" state.

## Dependencies
- Epic 1 (Pairing)
- Epic 2 (Socket Infrastructure)

## Risks
- **Network Latency:** If one user is offline, the "Stop" signal might not reach the other.
  - *Mitigation:* Local timeout of 5 minutes max.
- **Background Execution:** iOS limits background socket execution.
  - *Mitigation:* Use APNs (Push Notifications) to wake up the app/device at alarm time.

## Code Review Fixes
- **Backend**: Secured `AlarmsGateway` payload handling.
- **Backend**: Added `triggerPushNotification` stub in `AlarmsService`.
- **iOS**: Fixed `AlarmViewModel` to use dynamic `alarmId`.
