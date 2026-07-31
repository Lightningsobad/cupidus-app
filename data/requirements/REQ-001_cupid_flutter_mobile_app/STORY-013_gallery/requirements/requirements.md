# Story Requirements: STORY-013 Epic-4 — Gallery Ảnh Chung (Shared Gallery)

Scope: REQ-001 / STORY-013_gallery
Status: PRODUCT_OWNER_COMPLETE

## Confirmed Scope

Shared, backend-uploaded photo gallery. A paired couple uploads photos through
the frozen (A1) `gallery` + `uploads` backend contract; both partners can view
the combined, shared collection. This matches story_master.md, story_brief.md,
and the STORY-013 row in req_master.md verbatim — no scope correction applied.

## Acceptance Criteria (unchanged from story_master.md)

- **AC1**: A paired user can upload a photo to the shared gallery.
- **AC2**: Both partners can view the shared gallery contents.
- **AC3**: Unpaired users cannot access this feature.

## Open Item #1 Ruling — Gallery Model Conflict

**Ruling: (a).** "Private Gallery" (Level-1, device-only, single-partner,
AES-256/Secure-Enclave-encrypted, biometric unlock, 60s auto-lock,
screenshot-detection) is a **separate, out-of-scope backlog item**, not yet
formalized as its own story. STORY-013's AC1-AC3 stand **unchanged** as the
shared/backend model. No correction to story_master.md, story_brief.md, or
req_master.md's STORY-013 scope description is required.

Rationale:
- req_master.md's backlog table (`master requirements list` row for
  STORY-013, line 135) already names this story "Gallery ảnh chung" (shared
  gallery), not "Private Gallery" — the story's own registry entry has always
  matched the shared/backend model, not the device-only model.
- There is no separate backlog row anywhere in req_master.md for a
  "Private Gallery" story. The only place "Private Gallery" appears is (1) the
  design source's existing screen markup (`cupid-mobile-design/Cupid
  Screens.dc.html`) and (2) `data/ux/system/ui_ux_system_memory.md` §8/§9,
  where it is used as a worked example of the Level-1 device-only data
  sensitivity class alongside Typing Ghost and Messages — not as a scoped,
  backlogged feature with its own story id.
- STORY-013's `Depends On` (STORY-001/002/003 — design system, auth, pairing)
  and its `Out of Scope` note ("Any gallery/uploads endpoint change — A1
  frozen") both presuppose the existing backend `gallery`/`uploads` contract,
  which is a shared/server-side model. Nothing in this story's dependency
  chain, backend module list, or R3/R4 risk notes implies a device-only,
  never-leaves-device encryption model was ever the intended shape for
  STORY-013.
- Reusing the design source's *screen name* for a different feature shape
  (shared vs. private) is a design-asset naming collision, not evidence that
  the product intent changed. UI/UX Designer's spec already handled this
  correctly by reusing only the generic grid/tile visuals and dropping the
  encryption/lock ceremony.

Consequence for downstream roles: if the product later wants a true
device-only, single-partner encrypted "Private Gallery" (as named in the
design source / UX system memory), that must be raised as a **new backlog
item** through Scrum Master/Product Owner intake — it is not folded into
STORY-013 and must not be implemented as part of this story's coding-plan.

### R3/R4 Impact of This Ruling

Because Open Item #1 resolves toward the shared/backend model (not Private
Gallery), the Level-1 local-encryption path (AES-256/Secure-Enclave,
libsodium FFI) is **not required** for STORY-013. Tech Lead's R3 spike should
confirm this story's images are stored/served via the plain backend
`gallery`/`uploads` contract with no client-side encryption at rest. R4
(low-end Android perf) remains in scope regardless of the R3 outcome, since
`gallery-grid` is image-heavy either way.

## Open Item #3 (from UX spec) — Delete/Report Affordance

**Ruling: out of scope for STORY-013.** AC1-AC3 cover upload and view only.
"Remove a photo I uploaded" / "remove a photo my partner uploaded" is
deferred to a later story. Do not add delete/report UI or backend calls in
this story's coding-plan.

## Open Question Impact

### Scope Items BLOCKED in this story

- Level-1 device-only encryption, biometric unlock, auto-lock countdown, or
  screenshot-detection UI/logic for the gallery feature (belongs to a future,
  separate "Private Gallery" backlog item, not STORY-013).
- Delete/report affordance for uploaded photos (deferred, see Open Item #3).
- Any `gallery`/`uploads` backend endpoint change (A1 frozen, per
  story_master.md Out of Scope).

### Scope Items NOT BLOCKED in this story

- Shared gallery upload flow (`gallery-upload`): device photo-library picker,
  multi-select, per-item upload progress, retry-per-item on failure (AC1).
- Shared gallery viewing (`gallery-empty`, `gallery-grid`, `gallery-viewer`):
  both partners' uploads interleaved, uploader attribution badge, full-screen
  photo viewer with swipe navigation (AC2).
- Unpaired-user gate (`gallery-locked`) reusing the pairing-required gate
  pattern (AC3).
- Read-through cache / offline-read behavior per ADR-007 (Drift cache),
  matching STORY-012 Timeline's precedent (no offline write queue unless
  Tech Lead's coding-plan says otherwise).
- Responsive grid column rules (2-col base, 3-col on wider phones/phablets),
  pagination, and accessibility requirements as specified in
  `ux/uiux-spec.md` §4, §6, §7.

## Implementation Lane

Mobile only. Backend `gallery`/`uploads` contract is frozen (A1) — no
backend or frontend contract change in this story's scope.
