# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements `## Open Question Impact`
section before coding and do not implement blocked scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. STORY-013 Standing Constraints

These apply to every phase and override convenience:

- No backend, DTO, entity, or `mobile/openapi/` change (A1 frozen).
- Do not call `DELETE /gallery/{id}`; no delete or report affordance.
- No encryption, biometric unlock, auto-lock countdown, or screenshot-detection
  UI or logic. Ignore `isEncrypted` and `encryptionKeyId` on `GalleryItem`.
- Do not use the generated `Epic4PrivateGalleryApi`; its methods return
  `Response<void>` and `/uploads` is not in the spec. Use the shared `Dio` from
  `CupidApiClient` with hand-written JSON mapping, behind `GalleryRepository`.
- Presentation code must never touch `Dio` directly.
- No offline write queue. Offline means read-from-cache plus a disabled picker
  with an explanatory message.
- **AC2 is blocked** by a backend user-scoping gap (see `master-plan.md` §6
  BLOCKER-1). Do not attempt a client-side workaround; build against
  `GET /gallery` as the shared feed and escalate if asked to prove AC2.
