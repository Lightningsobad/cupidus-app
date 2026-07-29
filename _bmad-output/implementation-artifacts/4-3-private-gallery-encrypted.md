# Story 4.3: Private Gallery (Encrypted)

Status: done

## Story

As a **User**,
I want to **store intimate photos securely**,
So that **only I can see them on my device**.

## Acceptance Criteria

1. **Given** the user is in Private Gallery
   - **When** they add a photo
   - **Then** the app should encrypt it with AES-256 using a local key stored in the Secure Element
   - **And** show a "Locked" indicator

2. **Given** the user wants to view the photo
   - **When** they tap it
   - **Then** the app must prompt for Biometric Authentication (FaceID/TouchID) before decrypting and displaying

3. **Given** the user tries to take a screenshot
   - **When** the photo is open
   - **Then** the app should detect it and show a "Naughty!" overlay

## Tasks / Subtasks

- [x] Backend: Gallery metadata storage (AC: #1)
  - [x] Entity: `GalleryItem` (id, userId, filename, encryptionKeyId, thumbnailUrl, createdAt)
  - [x] Service: Upload metadata, list user's gallery
  - [x] Controller: `POST /gallery`, `GET /gallery`, `DELETE /gallery/:id`
- [x] iOS: Encrypted photo storage (AC: #1, #2)
  - [x] `GalleryViewModel`: photo management, encryption/decryption
  - [x] `PrivateGalleryView`: grid of locked thumbnails
  - [x] AES-256 encryption using Keychain-stored key
  - [x] Biometric auth prompt before decryption
- [x] iOS: Screenshot detection (AC: #3)
  - [x] NSNotification for screenshot detection
  - [x] "Naughty!" overlay
