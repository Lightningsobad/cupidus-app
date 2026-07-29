# Story 4.4: Love Timeline

Status: done

## Story

As a **Couple**,
We want a **timeline of our relationship milestones**,
So that **we can look back on our journey together**.

## Acceptance Criteria

1. **Given** the couple reaches a milestone (first message, 1 week, 1 month, etc.)
   - **When** they open the Love Timeline
   - **Then** the milestone should appear automatically with a timestamp

2. **Given** the user wants to add a custom memory
   - **When** they tap "Add Memory"
   - **Then** they can add a title, description, and optional photo
   - **And** it appears on both partners' timelines

## Tasks / Subtasks

- [x] Backend: Timeline module (AC: #1, #2)
  - [x] Entity: `TimelineEvent` (id, coupleId, type, title, description, photoUrl, createdAt)
  - [x] Enum: `TimelineEventType` (MILESTONE, MEMORY, SYSTEM)
  - [x] Service: create event, list couple timeline, auto-generate milestones
  - [x] Controller: `POST /timeline`, `GET /timeline`
- [x] Backend: Unit Tests
- [x] iOS: Timeline UI (AC: #1, #2)
  - [x] `TimelineViewModel`: load + add events
  - [x] `TimelineView`: vertical scrolling timeline with cards
  - [x] `AddMemorySheet`: form to add custom memories (with optional photo URL)
