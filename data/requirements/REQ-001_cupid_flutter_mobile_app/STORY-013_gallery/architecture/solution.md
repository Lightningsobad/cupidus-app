# 013_gallery-solution.md

## 0. Metadata

- User Story ID: STORY-013
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/story_master.md`
- Complexity: M (`standard`)
- Referenced Inputs: `story_master.md`; `requirements/requirements.md` (AC1-AC3, Open Question Impact, R3/R4 ruling); `ux/uiux-spec.md` §2-§7; `req_master.md` (STORY-013 row, R3/R4 rows); backend `gallery`/`uploads`/`users` modules; `mobile/` Flutter app
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md` (not updated by this story)
- Solution Number: 013
- Version: v0.1
- Date: 2026-07-31
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: Scan Architecture (mobile lane has no gallery feature yet; backend contract read directly from source)
- Architecture Drivers: frozen backend contract (A1), image-heavy low-end Android screen (R4), encryption question (R3), pairing gate (AC3).
- Architectural invariants / non-goals:
  - No backend, DTO, entity, or OpenAPI change in this story (A1).
  - No client-side encryption, biometric unlock, auto-lock, or screenshot detection.
  - No delete/report affordance (`DELETE /gallery/{id}` exists but stays unused).
  - No offline write queue.
- Proposed technical direction: add a `mobile/lib/features/gallery/` vertical slice (data + Cubit + presentation) over the existing shared `Dio` client, a two-call upload (`POST /uploads` then `POST /gallery`), a `shared_preferences` read-through snapshot for offline grid reads, and a pairing gate driven by `GET /users/me.partnerId`.
- Why this fits: mirrors the existing `features/auth/{data,presentation}` slice shape, the `get_it` service locator, `flutter_bloc` Cubit state, and the `design_system/adaptive/*` platform-branching widgets already in the app.

## 2. Downstream Contract Summary

- Backend contract: **unchanged**. Consumed as-is:
  - `POST /uploads` — multipart field `file`, hard limit 10 MB, JWT (`firebase-jwt`). Returns `{ url, filename, originalName, mimeType, size }`.
  - `POST /gallery` — body `CreateGalleryItemDto { filename: string, mimeType?: string }`. Returns the created `GalleryItem`.
  - `GET /gallery?limit=&offset=` — returns `GalleryItem[]`, ordered `createdAt DESC`. Backend default `limit=50`.
  - `GET /users/me` — returns the `User` row; `id` and `partnerId` are the fields this story uses.
  - `GalleryItem` shape: `{ id, userId, filename, thumbnailUrl|null, isEncrypted, encryptionKeyId|null, mimeType|null, createdAt }`.
  - Static media: `ServeStaticModule` serves `serveRoot: '/uploads'`, so display URL is derived client-side as `${CupidApiConfig.baseUrl}/uploads/${filename}`. `thumbnailUrl` is never populated by the backend; treat it as optional and fall back to the derived URL.
- Frontend contract: not applicable (mobile-only lane).
- DevOps / environment contract: no new env var or secret. Platform manifest entries for the photo-library picker are required (see §4 Infrastructure).
- Requirement configuration guide impact: REQUIRED — new mobile permission entries must be documented in `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`.
- Data model / migration contract: none.
- API / event / worker queue contract: none added.
- Test and verification expectations: `flutter test` unit + widget tests per phase; `flutter analyze`; `flutter build apk --debug` once in the final verification phase. No mobile e2e, emulator lifecycle, signing, or store gates.
- Risk surfaces and verification contract: see §4 Risk Surfaces.
- OQ constraints downstream lanes must preserve: Level-1 device-only encryption / biometric / auto-lock / screenshot-detection UI is BLOCKED; delete/report is BLOCKED; any `gallery`/`uploads` endpoint change is BLOCKED.

## 3. Scope And Assumptions

- In Scope: shared gallery grid, empty state, pairing-gated state, multi-select upload with per-item progress and retry, full-screen viewer, responsive columns, accessibility, offline grid read.
- Out Of Scope: encryption, delete/report, backend changes, offline upload queue.
- Assumptions affecting design:
  - A-1: `/uploads/<filename>` is publicly readable static content (no auth header on image GETs). Confirmed in `backend/src/app.module.ts`.
  - A-2: `GET /users/me` returns `partnerId` (nullable) and is the only pairing-status source available to mobile in this worktree.
  - A-3: STORY-001/002/003 supply auth, session, and the shared authenticated `Dio` instance already present in `mobile/lib/core/`.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| A1 | Frozen (accepted) | Any `gallery`/`uploads` endpoint, DTO, entity, or OpenAPI change | Mobile-side consumption of the existing endpoints | Mobile adapts to the contract as-is; see BLOCKER-1 |
| Open Item #1 | Resolved (Product Owner) | Level-1 device-only encrypted "Private Gallery" model | Shared backend-uploaded gallery per AC1-AC3 | Shared model only |
| Open Item #3 | Deferred | Delete/report affordance and `DELETE /gallery/{id}` calls | Upload and view only | No delete UI or call |
| R3 | **Closed by this solution — NO** | libsodium FFI, AES-256 at rest, key management | Plain TLS-in-transit upload/view | See D-1 |
| R4 | **Closed by this solution — budget set** | — | Image-heavy grid with the §5 budget | See D-2 |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/gallery/` (new). Backend `gallery`/`uploads` modules are read-only dependencies.
- New boundaries: `GalleryRepository` is the single mobile owner of gallery network + cache access; presentation never touches `Dio`.
- Shared patterns reused: `get_it` registration in `core/di/service_locator.dart`; `CupidApiClient` shared `Dio` (auth + error interceptors already attached); `flutter_bloc` Cubit; `design_system/adaptive/cupid_add_action.dart` for the iOS-pill / Android-FAB branch; `design_system/tokens/*` for radius, spacing, color.

### Affected Components And Layers

- Backend: none.
- Frontend: none.
- Mobile (new unless noted):
  - `features/gallery/data/gallery_api.dart`, `gallery_repository.dart`, `gallery_local_cache.dart`
  - `features/gallery/domain/gallery_item.dart`
  - `features/gallery/presentation/gallery_cubit.dart`, `gallery_state.dart`, `gallery_upload_cubit.dart`, `gallery_upload_state.dart`
  - `features/gallery/presentation/screens/gallery_screen.dart`, `gallery_viewer_screen.dart`
  - `features/gallery/presentation/widgets/*` (tile, grid, empty, locked, upload sheet, upload item)
  - Edited: `core/di/service_locator.dart`, `core/navigation/app_shell.dart`, `mobile/pubspec.yaml`
- Data: local only — `shared_preferences` key `gallery.snapshot.v1` holding the first page as JSON.
- Infrastructure: `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` need photo-library picker entries (`NSPhotoLibraryUsageDescription`; Android 13+ `READ_MEDIA_IMAGES` as declared by `image_picker`).

### Contracts And Integrations

- Contract owner: backend (frozen). Mobile is a pure consumer.
- Connection pattern: mobile -> HTTPS/HTTP REST via the shared authenticated `Dio`. Dependency direction is one-way.
- **Generated-client constraint (D-3)**: `mobile/openapi/cupid_api` exposes `Epic4PrivateGalleryApi` but every method returns `Response<void>` (no typed response models generated), and `/uploads` is absent from `mobile/openapi/cupid-api.json` entirely. The generated class is therefore unusable for reads and for upload. `gallery_api.dart` must call the shared `Dio` directly and map JSON by hand. Do not regenerate the OpenAPI client (A1 forbids spec changes).
- Upload sequence (per selected photo, sequential per item, max 2 in flight):
  1. `POST /uploads` with `FormData` field `file`, `onSendProgress` drives the per-item progress ring.
  2. On 2xx, take `filename` and `mimeType` from the response and `POST /gallery` with `CreateGalleryItemDto`.
  3. On 2xx, insert the returned `GalleryItem` optimistically at grid head.
- Error / retry / timeout / idempotency / empty state:
  - Failure at either step marks only that item `failed`; retry restarts that item from step 1. There is no idempotency key, so a retry after a step-2 failure can orphan an uploaded file on disk — accepted, no user-visible duplicate.
  - `401` is already handled by `CupidAuthInterceptor`; the Cubit surfaces it as a generic auth failure.
  - Offline: `gallery_upload_sheet` disables the picker with an inline "no connection" message (UX §5) instead of queueing.
  - Empty list from `GET /gallery` renders `gallery-empty`, not an error.
- Compatibility posture: additive on the client only.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Gallery read contract | `backend/src/modules/gallery/gallery.controller.ts` | `GET /gallery` -> `GalleryItem[]` | Repository unit test against recorded JSON fixture | Cannot verify AC2 rendering |
| Upload contract + 10 MB limit | `backend/src/modules/uploads/uploads.controller.ts` | `POST /uploads` multipart `file` | Unit test asserting downscale params keep payload under 10 MB | Uploads fail at runtime with 413 |
| Media URL derivation | `backend/src/app.module.ts` `serveRoot: '/uploads'` | `${baseUrl}/uploads/${filename}` | Unit test on the URL builder | Broken thumbnails |
| Pairing gate (AC3) | `GET /users/me.partnerId` | null -> `gallery-locked` | Cubit unit test for both branches | AC3 unverifiable |
| Low-end Android image memory (R4) | §5 budget below | Decode-constrained tiles | Widget test asserts `memCacheWidth`/`cacheWidth` is set on every tile | R4 unmitigated |
| Shared visibility (AC2) | `gallery.service.ts` `findAll` | See BLOCKER-1 | Deferred to backend follow-up | **AC2 cannot pass** |

### Backend Lane Handoff

- Backend responsibilities: none in this story. BLOCKER-1 must be routed as a separate backlog item.

### Frontend Lane Handoff

- Not applicable.

### DevOps Lane Handoff

- DevOps responsibilities: none beyond reviewing the permission entries added by the mobile lane.
- Requirement configuration guide update: REQUIRED (photo-library permission entries), owned by the upload phase.

## 5. Non-Functional Impact

- Security / privacy:
  - **D-1 (R3 resolved: NO client-side encryption).** Evidence: `uploads.controller.ts` writes plaintext files to `./uploads` via multer `diskStorage`; `app.module.ts` serves them as unauthenticated static content; `UploadsService.getUpdloadUrl` returns a plain URL; `GalleryItem.isEncrypted` defaults to `true` and `encryptionKeyId` is never written, so both fields are vestigial from the abandoned Private Gallery concept. A shared, partner-viewable, server-hosted gallery cannot use device-only keys. libsodium FFI is therefore **not** a STORY-013 dependency and must not be added. Mobile must ignore `isEncrypted`/`encryptionKeyId` and must not display any encryption or lock affordance.
  - Note for the requirement owner (not this story's scope): gallery media is served without authentication and filenames are UUIDs, so access control is obscurity-only.
- Reliability / performance / scalability — **D-2 (R4 budget)**:
  - Page size 30 (`GET /gallery?limit=30&offset=n*30`); prefetch the next page when the last 6 tiles enter the viewport.
  - Every grid thumbnail decodes at tile pixel width, not source resolution: `cached_network_image` with `memCacheWidth = tileWidthDp * devicePixelRatio` (never above 640 px). Full-resolution decode happens only in `gallery_viewer_screen`, one image at a time.
  - `GridView.builder` with `addAutomaticKeepAlives: false` and `addRepaintBoundaries: true`; no `shrinkWrap`.
  - Upload-side downscale via `image_picker` `maxWidth: 2048, maxHeight: 2048, imageQuality: 85` so a photo stays well under the 10 MB multer limit; upload concurrency capped at 2.
  - Target on a 2 GB-RAM Android 10 device: grid scroll holds >= 55 fps with < 5% janky frames over a 60-tile scroll, and image cache memory stays under 100 MB. Measured by the mobile visual/perf pass, not by an automated gate in an implementation phase.
- Observability / operations: no new telemetry.
- Migration / rollout: none. Feature is additive behind the gallery tab.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Use generated `Epic4PrivateGalleryApi` | Would be the conventional path | Rejected | All methods return `Response<void>`; `/uploads` not in the spec; regenerating requires a spec change blocked by A1 |
| Drift read-through cache per ADR-007 / UX §5 | UX cites Timeline's precedent | Deferred | `drift` is not in `mobile/pubspec.yaml` in this worktree; adding it plus `build_runner` for one screen is disproportionate and risks conflicting with whatever STORY-012 lands. Use a `shared_preferences` first-page JSON snapshot (server-authoritative read-through, no write queue) — same behavioral contract, smaller footprint. Revisit at requirement integration if Drift lands. |
| Client-side encryption (R3) | Named in `req_master.md` risk table | Rejected | See D-1 |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| **BLOCKER-1: AC2 not satisfiable.** `GalleryService.findAll` filters `where: { userId }` and `GalleryItem` has no `coupleId`, unlike `timeline`/`expenses` which use `common/utils/couple.util.ts`. `GET /gallery` returns only the caller's own photos, so a partner's uploads are never visible. A1 forbids fixing this in this story. | AC2 fails at review | Mobile is built to render whatever `GET /gallery` returns as the shared feed and derives the uploader badge by comparing `item.userId` to `GET /users/me.id`, so **zero mobile change is needed** once the backend becomes couple-scoped. Scrum Master must route a backend story (couple-scope `gallery_items` + `findAll`) or accept AC2 as deferred for STORY-013. |
| Two-step upload has no transaction | Orphaned file on disk if step 2 fails | Accepted; retry restarts from step 1, no duplicate gallery row |
| Unauthenticated static media | Photos readable by URL | Out of scope here; recorded above for the requirement owner |
| Drift divergence at integration | Cache implementation differs from STORY-012 | Cache is one class behind `GalleryRepository`; swap is localized |

## 8. Handoff Notes

- Implementation guardrails: no backend/OpenAPI edits; no `DELETE /gallery/{id}` call; no encryption, biometric, auto-lock, or screenshot UI; do not read or trust `isEncrypted`/`encryptionKeyId`; all network access goes through `GalleryRepository`.
- OQ-driven constraints to preserve: A1, Open Item #1, Open Item #3 (see §3 table).
- Shared contract-first work required: YES — phase P0 owns the mobile-side data contract that every later phase consumes.
- Shared coding plan required: YES — `coding-plan/master-plan.md`.
- Memory updates required: none.
- Open questions / blockers: **BLOCKER-1 (AC2 shared visibility)** must be decided by Scrum Master / Product Owner before this story can be reviewed `CLEAN` against AC2.
