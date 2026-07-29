# Story 3.3: Anti-Ghosting Configuration

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **Couple**,
We want **to set rules for response time**,
so that **we avoid silent treatment and maintain communication standards**.

## Acceptance Criteria

1. **Given** the couple is in settings
   - **When** they select "Anti-Ghosting Protocol"
   - **Then** they can set a "Ghost Timeout" (e.g., 10 mins after 'Seen')
   - **And** choose a "Penalty" (Emoji Storm, Noise, None)

2. **Given** one partner changes the config
   - **When** they save
   - **Then** the other partner must approve the change

## Tasks / Subtasks

- [x] Backend: Create `GhostConfigModule` (AC: #1, #2)
  - [x] Entity: `GhostConfig` (id, coupleId, timeoutMinutes, penalty, proposedBy, approvedBy, status, createdAt, updatedAt)
  - [x] Enum: `Penalty` (EMOJI_STORM, NOISE, NONE)
  - [x] Enum: `ConfigStatus` (ACTIVE, PENDING_APPROVAL, REJECTED)
  - [x] DTOs: `CreateGhostConfigDto`
  - [x] Service: Create/update config, approval flow, get active config
  - [x] Controller: `POST /ghost-config`, `PATCH /ghost-config/:id/approve`, `PATCH /ghost-config/:id/reject`, `GET /ghost-config`, `GET /ghost-config/pending`
- [x] Backend: Partner Approval Flow (AC: #2)
  - [x] New config changes set status to PENDING_APPROVAL
  - [x] Push notification stub to partner
  - [x] Partner approves → status = ACTIVE (deactivates previous); rejects → status = REJECTED
  - [x] ForbiddenException if approving/rejecting own config
- [x] Backend: Unit Tests
  - [x] `ghost-config.service.spec.ts`: 12 tests — create, approve, reject, getActive, getPending
- [x] iOS: Anti-Ghosting Settings UI (AC: #1)
  - [x] ViewModel: `GhostConfigViewModel` (state, API calls, form state)
  - [x] Screen: `GhostConfigView` (timeout slider 1-120 min, penalty picker, propose button)
  - [x] Component: `PendingApprovalBanner` with approve/reject buttons
- [x] iOS: Partner Approval UX (AC: #2)
  - [x] Inline approval banner in settings view
  - [x] Success alerts for approve/reject/propose actions

## Dev Agent Record

### Completion Notes List

- `GhostConfigModule` with `GhostConfig` entity, `Penalty` enum, `ConfigStatus` enum.
- `coupleId` derived from sorted pair of userId+partnerId for consistent couple identification.
- Service has authorization checks: cannot approve/reject own config, must be in couple.
- Previous active config deactivated on new approval.
- 12 unit tests covering all flows including auth edge cases.
- iOS `GhostConfigView` with slider (1-120 min), penalty picker with selection animation, and pending approval banner.

### File List

#### Backend
- `src/modules/ghost-config/entities/ghost-config.entity.ts`
- `src/modules/ghost-config/dto/create-ghost-config.dto.ts`
- `src/modules/ghost-config/ghost-config.service.ts`
- `src/modules/ghost-config/ghost-config.controller.ts`
- `src/modules/ghost-config/ghost-config.module.ts`
- `src/modules/ghost-config/ghost-config.service.spec.ts`
- `src/app.module.ts` (modified — added GhostConfigModule)

#### iOS
- `CupidApp/App/Features/GhostConfig/GhostConfigViewModel.swift`
- `CupidApp/App/Features/GhostConfig/GhostConfigView.swift`
