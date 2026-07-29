# Story 2.1: Chat Interface & History

**Epic:** 2. Radical Transparency Communication
**Story ID:** 2.1
**Status:** In Progress
**Owner:** Alan

## Description
As a User, I want to view my chat history and interface so that I can see past conversations and start new ones. This story establishes the core chat UI and the mechanism to load/cache messages.

## Acceptance Criteria
- [ ] **Given** the user is on the dashboard
  - [ ] **When** they tap the Chat tab
  - [ ] **Then** they should see the chat interface with their partner
  - [ ] **And** load the last 20 messages from local cache/backend

- [ ] **Given** there is no history
  - [ ] **When** the chat opens
  - [ ] **Then** show a friendly empty state "Start the conversation!"

- [ ] **Given** the chat is active
  - [ ] **When** new messages arrive
  - [ ] **Then** the UI should update in real-time (WebSocket integration foundation)

## Technical Tasks
- [ ] **Backend: Messages Module**
  - [ ] Create `MessagesModule`, `MessagesController`, `MessagesService`
  - [ ] Define `Message` entity (id, senderId, receiverId, content, type, status, createdAt)
  - [ ] Implement `GET /messages` with pagination
  - [ ] Implement WebSocket Gateway foundation (`ChatGateway`)

- [ ] **iOS: Chat UI**
  - [ ] Create `ChatView` with `CupidTheme`
  - [ ] Implement `MessageBubble` component (styled for sender/receiver)
  - [ ] Implement `ChatViewModel` with `MessageService` integration
  - [ ] Add "Empty State" view

- [ ] **iOS: Real-time & Caching**
  - [ ] Integrate `SocketIO` client (if not already present, or use dummy for now)
  - [ ] Implement basic local caching (SwiftData/CoreData or simple PersistenceController)

## Dependencies
- `CupidTheme.swift` (Styles)
- Auth Module (User ID)
- Socket.io (Backend)

## Risks
- WebSocket connection stability
- Pagination performance with large history
