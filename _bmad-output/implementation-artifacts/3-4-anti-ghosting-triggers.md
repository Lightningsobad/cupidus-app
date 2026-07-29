# Story 3.4: Anti-Ghosting Triggers (Emoji Storm)

Status: done

## Story

As a **User**,
I want to **trigger an Emoji Storm when my partner ghosts me**,
so that **I get their attention in a playful, slightly toxic way**.

## Acceptance Criteria

1. **Given** the "Ghost Timeout" has passed since the last message was 'Seen'
   - **When** the timer expires
   - **Then** the "Storm" button becomes active for the sender

2. **Given** the sender taps "Storm"
   - **When** the action is sent
   - **Then** the partner's screen should be covered in falling emojis (e.g., 👻 or 🔪) for 5 seconds
   - **And** play a sound effect override (if permission granted)

## Tasks / Subtasks

- [ ] Backend: Storm event handling via ChatGateway (AC: #1, #2)
  - [ ] Add `EMOJI_STORM` and `EMOJI_STORM_RECEIVED` to chat.constants.ts
  - [ ] Handle `emojiStorm` event in ChatGateway — relay to partner via WebSocket
  - [ ] Add `GET /ghost-config/storm-status/:partnerId` endpoint to check if storm is eligible
- [ ] Backend: Unit Tests
  - [ ] Test storm eligibility logic (timeout calculation)
- [ ] iOS: Storm Trigger UI (AC: #1)
  - [ ] `StormViewModel` — timer logic, eligibility check, trigger action
  - [ ] `StormButton` — appears in chat when storm is eligible, animated
- [ ] iOS: Emoji Storm Overlay (AC: #2)
  - [ ] `EmojiStormOverlay` — falling emojis animation for 5 seconds
  - [ ] Handle `emojiStormReceived` socket event in SocketService
  - [ ] Sound effect playback (AudioServicesPlaySystemSound)

## Dev Notes

- **Real-time:** Uses existing ChatGateway WebSocket. New events: `emojiStorm` (sender→server→partner), `emojiStormReceived` (server→partner).
- **Storm eligibility:** Backend checks last 'seen' message timestamp against GhostConfig timeout.
- **Emojis:** Based on penalty type — `emoji_storm` uses 👻🔪💀, `noise` uses 📢🔊🔔.
- **Animation:** SwiftUI Canvas or ForEach with randomized positions + fall animation, 5-second duration.
- **Sound:** Uses `AudioServicesPlaySystemSound` for haptic/sound feedback.
