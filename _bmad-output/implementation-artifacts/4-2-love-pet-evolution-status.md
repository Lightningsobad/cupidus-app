# Story 4.2: Love Pet Evolution & Status

Status: done

## Story

As a **User**,
I want the **pet to react to our relationship status**,
So that **I can visualize our connection health**.

## Acceptance Criteria

1. **Given** the couple interacts frequently (chat, vibe check)
   - **When** they open the app
   - **Then** the pet should be "Happy" and perform a dance animation

2. **Given** the couple ignores each other for > 24 hours
   - **When** they open the app
   - **Then** the pet should have "Sad" or "Sick" appearance

3. **Given** they reach a milestone (e.g., 1000 interactions)
   - **When** it happens
   - **Then** the pet should "Level Up" visually (grow bigger, new accessories)

## Tasks / Subtasks

- [x] Backend: Pet happiness decay + mood endpoint (AC: #1, #2)
  - [x] Add `GET /pets/status` endpoint with computed mood
  - [x] Add happiness decay logic: -2/hour when idle > 12 hours
  - [x] Add mood calculation (happy/content/sad/sick based on happiness + last interaction)
- [x] Backend: Milestone system (AC: #3)
  - [x] Track interaction milestones (50, 100, 500, 1000)
  - [x] Return milestone events in pet status
- [x] iOS: Animated pet moods (AC: #1, #2)
  - [x] Add mood-based animations to PetDashboardView
  - [x] Dance animation for happy, droopy for sad
- [x] iOS: Level up celebration (AC: #3)
  - [x] Level up overlay with confetti
