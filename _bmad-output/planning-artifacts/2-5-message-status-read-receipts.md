# Story 2.5: Message Status (Read Receipts)

**Epic:** 2. Radical Transparency Communication
**Story ID:** 2.5
**Status:** Done
**Owner:** Alan

## Description
As a User, I want to know when my message has been delivered and read by my partner, so that I can feel connected and reassured that they are receiving my thoughts (part of "Radical Transparency").

## Acceptance Criteria
- [ ] **Given** a user sends a message
  - [ ] **Then** the local message status should initially be "sending", then "sent" (single checkmark).

- [ ] **Given** the partner's app receives the message (via socket or poll)
  - [ ] **Then** the sender should see the status change to "delivered" (double checkmark).

- [ ] **Given** the partner opens the chat screen
  - [ ] **Then** all unread messages should be marked as "seen" (blue double checkmark).
  - [ ] **And** the sender should be notified in real-time of this status change.

- [ ] **Given** the user is offline
  - [ ] **When** they come online and open chat
  - [ ] **Then** "seen" receipts should be batched and sent for any messages read while offline (or just read now).

## Technical Tasks
- [x] **Backend: Message Entity**
  - [x] Ensure `status` field exists (sent, delivered, seen).
  - [x] Add `readAt` timestamp (optional but good for data).

- [x] **Backend: API/Socket**
  - [x] `ChatGateway`: Add `markSeen` event handler.
  - [x] `ChatGateway`: Broadcast `messageSeen` event to sender.
  - [x] `MessagesService`: Update message status in DB.
  - [x] `ChatGateway`: Add Delivery Receipts (Review Fix).

- [x] **iOS: Chat Logic**
  - [x] `ChatViewModel`: Send `markSeen` event when entering chat or receiving message while in chat.
  - [x] `ChatViewModel`: Listen for `messageSeen` event and update local message list.
  - [x] `ChatView`: Visual indicators for status (Checkmarks).
  - [x] `SocketService`: Handle Delivery Events & Event Queue (Review Fix).

## Dependencies
- Story 2.1 (Chat Basics)
- Story 2.3 (Socket Infrastructure)

## Risks
- Race conditions if multiple devices (future).
- "Seen" logic needs to be careful not to spam DB if scrolling through history.
