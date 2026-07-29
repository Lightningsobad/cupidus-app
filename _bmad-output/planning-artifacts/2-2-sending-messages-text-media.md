# Story 2.2: Sending Messages (Text/Media)

**Epic:** 2. Radical Transparency Communication
**Story ID:** 2.2
**Status:** In Progress
**Owner:** Alan

## Description
As a User, I want to send text and images so that I can express myself to my partner. This story focuses on the media capability and robust message sending.

## Acceptance Criteria
- [ ] **Given** the user types a message
  - [ ] **When** they tap Send
  - [ ] **Then** the message should appear immediately (optimistic UI) and sync to server

- [ ] **Given** the user selects an image
  - [ ] **When** they send it
  - [ ] **Then** it should upload to storage and appear in the chat as a preview
  - [ ] **And** be visible to the partner

- [ ] **Given** an image message
  - [ ] **When** displayed in chat
  - [ ] **Then** it should respect the bubble styling and have proper aspect ratio

## Technical Tasks
- [ ] **Backend: Uploads Module**
  - [ ] Create `UploadsModule`, `UploadsController`, `UploadsService`
  - [ ] Implement `POST /uploads` to handle `multipart/form-data`
  - [ ] Configure `ServeStaticModule` to serve files from `./uploads`
  
- [ ] **iOS: Media Selection**
  - [ ] Integrate `PhotosPicker` in `ChatInputBar`
  - [ ] Implement `ImageCompressor` helper

- [ ] **iOS: Sending Logic**
  - [ ] Create `MediaUploadService` (multipart request)
  - [ ] Update `ChatViewModel.sendImage` to: 1. Upload Image -> 2. Send Message with URL
  - [ ] Ensure Optimistic UI for images (show local image while uploading)

- [ ] **iOS: Rendering**
  - [ ] Update `MessageBubble` to support `type: .image` using `AsyncImage`

## Dependencies
- Backend file system permissions
- iOS Photo Library permissions

## Risks
- Image size upload limits
- Network failure during upload
