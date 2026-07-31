# UX Spec: STORY-013 Epic-4 — Gallery Ảnh Chung (Shared Gallery)

Scope: REQ-001 / STORY-013_gallery
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html` (screen id
`gallery`, epic-4 group) plus system UX memory
(`data/ux/system/ui_ux_system_memory.md` §1-§4, §8-§9).
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`)
— no new tokens introduced.

**Read this spec together with Open Item #1 below before coding-plan.** The
design source's only existing screen for this epic-4 slot is named "Private
Gallery" and is modeled as Level-1, device-only, single-partner encrypted
storage — a different feature shape than this story's confirmed scope. This
spec designs for STORY-013's actual scope (shared, backend-synced, both
partners view) and reuses only the visually generic parts of the existing
screen; it does not carry over the encryption/lock ceremony. See Open Item #1
for why, and for what Tech Lead/Product Owner must confirm before coding.

## 1. Scope Confirmation (from story_master.md / story_brief.md)

- Backend contract: `gallery` + `uploads` modules (frozen, A1 — no endpoint
  changes).
- AC1: a paired user can upload a photo to the shared gallery.
- AC2: both partners can view the shared gallery contents.
- AC3: unpaired users cannot access this feature.
- Business intent (story_brief.md): "shared photo memory storage,
  complementary to the text/event-based Timeline (STORY-012)" — a jointly
  built, jointly viewable collection, not a private-per-partner vault.

This spec treats "shared, both-partners-view, backend-uploaded" as the
authoritative scope for STORY-013, per the story artifacts above.

## 2. Screen Inventory

| Screen id (new, under existing `gallery` tab slot) | Purpose | Chrome |
|---|---|---|
| `gallery-empty` | First-run state, no photos yet | Main app chrome (5-tab bottom nav, epic-4 tab) |
| `gallery-grid` | Shared photo grid, both partners' uploads interleaved | Main app chrome |
| `gallery-upload` | Photo picker + upload progress (device photo library) | Main app chrome, modal/sheet over grid |
| `gallery-viewer` | Full-screen single-photo viewer (tap a grid tile) | Chromeless overlay, swipe-to-dismiss |
| `gallery-locked` (unpaired gate) | Access-denied state for unpaired users | Main app chrome |

Reused visual primitives from the existing `gallery` screen markup (2-col
`aspect-ratio:3/4` tile grid, rounded `image-slot` tiles, bottom-left
date/location caption chip, dashed "add photo" tile) — these are generic
layout components, independent of the encryption model, and carry over as-is
per system UX memory §1 (design tokens/spacing) and §3 (adaptive platform
rules).

**Explicitly not reused** from the existing `gallery` screen: the
lock/fingerprint-unlock gate, the "unlocked · auto-locks in 60s" countdown
banner, and the "screenshots are detected" notice. Those are part of the
Level-1 device-only "Private Gallery" model (system UX memory §8, Level 1),
which conflicts with this story's shared/backend scope — see Open Item #1.

## 3. Flow Map

```
Main app, epic-4 gallery tab tapped
  -> paired user, gallery has 0 photos -> gallery-empty
  -> paired user, gallery has >=1 photo -> gallery-grid
  -> unpaired user (any state) -> gallery-locked

gallery-empty
  -> tap "Add first photo" -> gallery-upload

gallery-grid
  -> tap dashed "add photo" tile -> gallery-upload
  -> tap any existing photo tile -> gallery-viewer

gallery-upload
  -> pick photo(s) from device library -> show per-item upload progress
       - success -> dismiss sheet, new tile(s) appear in gallery-grid
         (optimistic insert at grid start, replaced by server data on next
         sync per §5)
       - failure (network/server error) -> inline retry affordance per
         item, sheet stays open until user retries or cancels
  -> cancel -> dismiss sheet, return to gallery-empty/gallery-grid unchanged

gallery-viewer
  -> swipe left/right -> next/previous photo (chronological order matching
     grid order)
  -> swipe down / tap close -> dismiss, return to gallery-grid at same
     scroll position
```

## 4. Screen Detail

### 4.1 `gallery-empty`

- Centered empty-state composition (consistent with other epic-4/5 "start
  from zero" moments, e.g. Dream Jar's "Tạo Dream Jar mới" dashed CTA):
  large soft-icon illustration (`add_photo_alternate`, 20-22% opacity fill
  per design-principle "accents at 12-20% opacity"), headline + one-line
  supporting copy, single primary CTA.
- Headline: "Chưa có ảnh nào" / "No photos yet".
- Supporting copy: "Thêm khoảnh khắc đầu tiên của hai bạn" / "Add your
  first moment together".
- CTA: full-width pill (iOS) / FAB (Android) per §3 adaptive pattern —
  same `isMD`/`isIOS` branch already used for Shared Expenses' add action
  (system UX memory §3/§9) — opens `gallery-upload`.

### 4.2 `gallery-grid`

- 2-column grid, `aspect-ratio: 3/4` tiles, `r-sm` (16px) corner radius,
  `--shadow` token — matches existing `gallery` screen markup exactly.
- Each tile: photo thumbnail (`image-slot`-equivalent), bottom-left caption
  chip showing date + optional location, semi-transparent dark scrim
  (`rgba(23,17,41,.6)`) behind caption text for legibility over bright
  photos.
- Uploader attribution: add a small avatar-initial badge (24px circle,
  partner's initial + accent color per existing avatar treatment used on
  Me/profile screens) in the tile's top-right corner, so each partner can
  see who added which photo — this is new relative to the source screen
  (which only showed one implicit uploader) and is required by AC2's
  "both partners" framing; both partners' contributions must be visually
  distinguishable in a shared grid, not just aggregated.
- Dashed "add photo" tile stays pinned as the **last** grid cell (not
  first), so newly-added photos and existing content read chronologically
  without the add-affordance interrupting the flow.
- Pull-to-refresh at the top of the grid to re-sync from the backend
  (paired-device photos may have been added by the partner since last
  open).
- Infinite scroll / pagination: load in pages of ~30 (align with whatever
  page size Tech Lead sets for the `gallery` list endpoint); show a
  lightweight skeleton-tile shimmer (`shimmer` keyframe, already in the
  design source's animation vocabulary per system UX memory §2) while
  the next page loads, not a full-screen spinner.

### 4.3 `gallery-upload`

- Bottom sheet (`r-sheet` 28px token), opened from either the empty-state
  CTA or the grid's add tile.
- Device photo-library picker (native picker chrome — out of this spec's
  visual scope, platform-native).
- Multi-select supported (couples commonly batch-upload from an event);
  show a horizontal strip of selected thumbnails with per-item progress
  ring overlay during upload.
- Per-item states: queued -> uploading (progress ring 0-100%) -> done
  (checkmark, ring fades) -> failed (red `--red` ring + retry icon,
  tapping retries just that item, not the whole batch).
- Sheet is dismissible mid-upload (uploads continue in background;
  returning to `gallery-grid` shows the same in-progress tiles with a
  small progress indicator overlay until each completes).

### 4.4 `gallery-viewer`

- Full-screen, chromeless (no tab bar/header), dark scrim background
  consistent with `--sky` nebula theme but dimmed further for photo
  contrast.
- Single photo at a time, swipe horizontally to move through the grid's
  chronological order, swipe down or tap an explicit close (`X`, top-left
  per iOS convention / top-right per Android convention — mirror the
  existing chevron-vs-arrow back convention in system UX memory §3) to
  dismiss.
- Caption overlay (date + location + uploader initial badge) fades in on
  tap, fades out after ~2s of no interaction, to keep the photo
  unobstructed by default.
- No edit/delete affordance specified here (not in this story's AC scope —
  delete/report handling, if needed, is an open item, see Open Item #3).

### 4.5 `gallery-locked` (unpaired gate, AC3)

- Reuses the general "feature requires pairing" gate pattern: centered
  icon (`link_off` or similar, not the `lock`/Secure-Enclave iconography
  used by the Level-1 Private Gallery concept — this is an access-state,
  not an encryption-state, and must look visually distinct from a
  locked-encryption screen so users don't confuse "not paired yet" with
  "authenticate to unlock").
- Headline: "Ghép đôi để mở Gallery chung" / "Pair up to unlock the shared
  gallery".
- Supporting copy: one line explaining the feature is only available once
  paired, plus a CTA routing to the existing invite/joincode pairing flow
  (`goInvite`/`goJoincode` per system UX memory §4 onboarding screens).
- This same pattern (icon + headline + CTA-to-pairing) should be reused for
  any other epic-3/4/5 feature gated on pairing status (e.g. STORY-012
  Timeline's matching AC4) rather than re-designed per story — flagging
  here as a reusable pattern candidate for system UX memory (see Open Item
  #4).

## 5. Data Freshness / Offline Behavior

- Per ADR-007 (ADS Drift resolution, same pattern as STORY-012 Timeline):
  read-through cache, server-authoritative, no offline write queue for
  this story unless Tech Lead's coding-plan says otherwise.
- `gallery-grid` should be readable from the Drift cache when offline
  (last-synced state), matching Timeline's AC3 precedent. New uploads
  require connectivity — `gallery-upload` should surface a clear
  "no connection" state (not a silent failure) if attempted offline,
  and offer to queue-locally-and-retry only if Tech Lead's plan supports
  that; otherwise disable the picker with an explanatory inline message.

## 6. Responsive Behavior

- Base layout: 2-column grid at standard phone widths (~360-430dp), per
  the design source's default. Tile `aspect-ratio:3/4` is fixed regardless
  of column count, so column count is the only responsive variable.
- Larger phones / phablets (>=430dp logical width) may render 3 columns to
  avoid oversized tiles; this is the same rule Tech Lead should apply
  consistently to any grid-based epic-4/5 screen (Timeline photo entries,
  Gallery) — not a bespoke Gallery-only breakpoint.
- `gallery-viewer` full-screen photo view must letterbox (not crop) photos
  that don't match the device aspect ratio; pinch-to-zoom is expected
  baseline behavior for a photo viewer and should be included even though
  the design source doesn't show it explicitly (standard platform gallery
  affordance, not a new design decision).
- Landscape orientation: grid reflows to more columns following the same
  device-width rule above (treat as width-based, not orientation-based,
  so a landscape phone and a similarly-wide portrait phablet behave the
  same).

## 7. Accessibility Requirements

- Every grid tile needs an accessible label combining date + location +
  uploader (e.g. "Photo from Minh, February 14, Đà Lạt") for screen reader
  users — the visual caption chip is not sufficient on its own since it's
  rendered as decorative overlay text over an image.
- `gallery-viewer`'s swipe-to-dismiss and swipe-between-photos gestures
  must have a non-gesture equivalent (visible close button; screen reader
  users get "next photo"/"previous photo" custom actions or on-screen
  buttons, not gesture-only navigation).
- Upload progress states (queued/uploading/done/failed) must be announced
  via live region updates, not conveyed by ring color/icon alone (failed
  state especially needs a text-equivalent, not just red color, matching
  standard color-contrast/color-alone-is-not-a-signal practice).
- Minimum tap targets: 44pt (iOS) / 48dp (Android) per system UX memory
  §2 structural tokens — applies to the add-photo tile, retry icons, and
  viewer close/nav controls.
- `gallery-locked` gate CTA must be reachable and clearly labelled for
  screen readers as navigating to the pairing flow, not just "action
  button".

## 8. Open Items For Downstream Roles

1. **Gallery model conflict — "shared" (this story) vs. "Private Gallery"
   (design source) — needs Tech Lead + Product Owner confirmation before
   coding-plan.** The only epic-4 gallery screen in
   `cupid-mobile-design/Cupid Screens.dc.html` and in system UX memory
   (§8-§9) is named "Private Gallery": Level-1, device-only, AES-256 with
   a Secure-Enclave-class key, biometric unlock, 60s auto-lock,
   screenshot-detection banner. That is a single-partner, never-leaves-
   device model. STORY-013's story_master.md, story_brief.md, and
   req_master.md row all instead describe a **shared** gallery uploaded
   through backend `gallery`/`uploads` modules and viewable by **both**
   partners (AC2) — which requires server-side storage, directly
   contradicting "never leaves device." This spec designs for the
   shared/backend model (per story_master's explicit scope, which is this
   story's authoritative contract), reusing only the design source's
   generic grid/tile visuals and dropping the encryption-lock ceremony.
   Before coding-plan, Tech Lead and Product Owner must confirm one of:
   (a) "Private Gallery" is a distinct, separate future feature/story not
   yet in the backlog, and STORY-013 is correctly the shared/backend
   gallery as scoped — this spec stands as-is; or (b) STORY-013 was meant
   to *be* the Level-1 Private Gallery and story_master/story_brief have
   the wrong scope description — in which case this spec needs rework
   around the lock/unlock/encryption flow instead. Do not silently pick a
   direction during implementation (same escalation precedent as system
   UX memory §7's DND/Critical-Alerts conflict).
2. **R3 (libsodium FFI) / R4 (Android low-end perf) spike outcome**
   (story_master.md's own Open Item, restated here for downstream
   visibility): Tech Lead must confirm whether this story's images
   require local encryption at rest (only relevant if Open Item #1
   resolves toward the Private Gallery model) and must include this
   image-heavy grid in the low-end Android performance pass before
   coding-plan is finalized. This spec's grid/pagination/skeleton-loading
   design (§4.2) assumes a plain, unencrypted list-fetch; it will need
   Tech Lead input if encryption changes the fetch/decrypt cost per tile.
3. **Delete/report affordance for uploaded photos** — not in this story's
   AC scope (upload + view only). Product Owner should confirm whether
   "remove a photo I uploaded" or "remove a photo my partner uploaded" is
   in/out of scope for STORY-013 or deferred to a later story; this spec
   intentionally omits a delete UI pending that confirmation.
4. **Reusable "pairing-required gate" pattern candidate for system UX
   memory** — §4.5's icon+headline+CTA-to-pairing pattern should apply
   uniformly to every epic-3/4/5 AC of the form "unpaired users cannot
   access this feature" (e.g. STORY-012 Timeline AC4). Recommend
   promoting this pattern into `data/ux/system/ui_ux_system_memory.md` the
   next time a story's UX work actually touches it, rather than each
   story re-describing it independently.

## 9. Sources

- `cupid-mobile-design/Cupid Screens.dc.html` — existing `gallery` screen
  markup (grid/tile/caption-chip layout, lock/unlock ceremony — the latter
  excluded per Open Item #1).
- `data/ux/system/ui_ux_system_memory.md` §1-§4 (tokens, platform
  adaptation, screen inventory), §8-§9 (data sensitivity model / Private
  Gallery classification — source of the Open Item #1 conflict), §11
  (destructive-confirm and accessibility conventions referenced for
  future delete-affordance work per Open Item #3).
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/story_master.md`,
  `story_brief.md` — authoritative scope (shared/backend model, AC1-AC3).
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-012_timeline/story_master.md`
  — sibling epic-4 story, cross-checked for the matching ADR-007
  offline/Drift-cache pattern (§5) and matching unpaired-access AC (Open
  Item #4).
- `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md` — R3/R4
  risk table entries (Open Item #2).
