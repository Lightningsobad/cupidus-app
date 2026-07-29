# Story 2.3: Typing Ghost Mechanics

**Epic:** 2. Radical Transparency Communication
**Story ID:** 2.3
**Status:** In Progress
**Owner:** Alan

## Description
As a User, I want to see *exactly* what my partner is typing as they type it (ghost text), so that I feel an intimate, real-time connection. Unlike standard "typing..." indicators, this feature streams the actual characters being typed in real-time.

## Acceptance Criteria
- [ ] **Given** the user is typing in the chat input
  - [ ] **When** they press a key
  - [ ] **Then** the character should be emitted immediately to the partner via WebSocket

- [ ] **Given** the partner is in the chat
  - [ ] **When** they receive a typing event
  - [ ] **Then** they should see the "Ghost Text" appear in a special ephemeral bubble or area
  
- [ ] **Given** the user stops typing or clears text
  - [ ] **When** the input is empty
  - [ ] **Then** the ghost text should disappear

- [ ] **Given** strict privacy control (Story 2.4 - Future)
  - [ ] **Then** this feature should respect the toggle (for this story, assume enabled or simple on/off)

## Technical Tasks
- [ ] **Backend: WebSocket Events**
  - [ ] Update `ChatGateway` to handle `typing` event (payload: `{ content: string, senderId: string }`)
  - [ ] Broadcast `typing` event to receiver room
  
- [ ] **iOS: Value Observation**
  - [ ] Update `ChatInputBar` to stream text changes to ViewModel
  - [ ] Update `ChatViewModel` to emit `typing` event via Socket (or `ChatService` mock/polling fallback doesn't work well here - **NEED Socket.IO Client**)
  
- [ ] **iOS: Rendering Ghost Text**
  - [ ] Create `GhostMessageBubble` component (translucent, distinct style)
  - [ ] Listen for `typing` events and update a local `ghostMessage` state variable
  - [ ] Display `ghostMessage` at the bottom of the chat list if present

## Dependencies
- Socket.IO Client (Critical for this feature)
- `ChatGateway`

## Risks
- High network traffic overlapping with poor connection
- Socket latency making the experience "jumpy"
