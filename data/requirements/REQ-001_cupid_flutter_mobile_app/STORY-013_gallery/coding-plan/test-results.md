# STORY-013 Shared Gallery — Verification Results (Phase P5)

- Phase: P5 (`phase-P5-verification.md`)
- Owner: Mobile Developer
- Worktree: `story-REQ-001_cupid_flutter_mobile_app-STORY-013`
- BaseHead: `526ea65feb32c458113a0d16b5a875b8c489fe03`
- Date: 2026-07-31
- Overall outcome: **BLOCKED** — 3 blockers (see §6).

## 1. Command Evidence

| Command (from `mobile/`) | Result |
|---|---|
| `flutter analyze lib test` | **PASS** — 0 errors, 0 warnings, 18 `info` lints |
| `flutter test` (full suite) | **FAIL** — 158 passed, **1 failed** |
| `flutter build apk --debug` | **PASS** — exit 0 |

### 1.1 `flutter analyze`

Scoped to `lib` and `test`. Zero errors and zero warnings, so P5's acceptance
criterion "no errors for `mobile/lib/features/gallery/`" is met.

18 `info`-level lints remain, 17 of which are pre-existing outside this story
(`prefer_initializing_formals` in `core/realtime/*`, `features/auth/*`). One
is inside this story's scope:

- `lib/features/gallery/data/gallery_api.dart:88` — `use_null_aware_elements`

Informational only, matching the codebase's existing tolerance for `info`
lints. Left unchanged: `gallery_api.dart` is outside P5's write scope.

Note: bare `flutter analyze` (no path argument) reports ~10,989 issues, but
every error originates in checked-in build artifacts under
`mobile/build/ios/SourcePackages/checkouts/flutterfire/`, not in project
source. Scoping the run to `lib test` is what gives a meaningful signal.

### 1.2 `flutter test`

158 tests pass. One test fails:

```
test/design_system/no_fork_guard_test.dart:
  AC 4 no-fork guard: features/app/core never fork on a raw color literal
  or Platform.is*/defaultTargetPlatform
```

See §6 BLOCKER-2. This is a STORY-013 regression against STORY-001's design
system contract, introduced by P2/P3/P4. Result reproduced twice against a
clean worktree at `BaseHead` (`git status` clean, HEAD unchanged).

### 1.3 `flutter build apk --debug`

Succeeds (exit 0), confirming P0's two new dependencies (`image_picker`,
`cached_network_image`) and P3's platform manifest edits
(`READ_MEDIA_IMAGES`, `NSPhotoLibraryUsageDescription`) compile and package
correctly.

## 2. Acceptance Criteria Mapping

| AC | Statement | Status | Evidence |
|---|---|---|---|
| AC1 | A paired user can upload a photo to the shared gallery | **BLOCKED** | §2.1 |
| AC2 | Both partners can view the shared gallery contents | **BLOCKED** | §2.2 |
| AC3 | Unpaired users cannot access this feature | **PASS** | §2.3 |

### 2.1 AC1 — BLOCKED (wiring gap, mobile-side, fixable in this story)

Every upload building block exists and is tested:

- `GalleryUploadCubit` — picker seam at the R4/D-2 downscale budget
  (2048x2048, quality 85), bounded 2-worker upload pool, per-item retry,
  connectivity seam.
- `GalleryRepository.uploadPhoto` — two-step `POST /uploads` then
  `POST /gallery`, with step-1 failure proven never to issue step 2
  (`gallery_repository_test.dart`).
- `GalleryUploadSheet` / `GalleryUploadItem` — `r-sheet` modal, per-item
  queued/uploading/done/failed states with text equivalents.
- `gallery_upload_cubit_test.dart` — 11 tests, all passing.

**But the flow is unreachable from the running app.** In
`mobile/lib/features/gallery/presentation/screens/gallery_screen.dart`, both
add-photo entry points still call the P4 placeholder:

- line 120 — `GalleryEmpty() => GalleryEmptyView(onAddPhoto: () => _showUploadFlowUnavailable(context))`
- line 139 — `GalleryGridView(... onAddPhoto: () => _showUploadFlowUnavailable(context) ...)`

`_showUploadFlowUnavailable` (line 69) shows an "Adding photos will be
available here soon." snackbar. `GalleryUploadSheet.show` is never called
from any screen, and `GalleryUploadCubit` is never constructed outside tests.

Root cause: P4 owned `gallery_screen.dart` and shipped the placeholder while
P3 had not landed; P3 then delivered the sheet but `gallery_screen.dart` was
outside P3's write scope, so nobody closed the loop. This is the same class
of gap as the P2 wiring gap that P4 was extended to fix — recreated one phase
later for the upload lane.

Remediation (mobile-only, no backend dependency): wire
`GalleryUploadSheet.show` into both `onAddPhoto` callbacks, construct
`GalleryUploadCubit` from `getIt<GalleryRepository>()`, and route its
`onUploaded` into `GalleryCubit.insertOptimistic` per UX §3's optimistic
insert. Requires adding `gallery_screen.dart` to a phase write scope.

### 2.2 AC2 — BLOCKED (backend scoping gap, not fixable in this story)

Pointer: `../architecture/solution.md` §7 BLOCKER-1.

`GET /gallery` is **user-scoped, not couple-scoped** — `gallery.service.ts`
`findAll` filters by the requesting user's id, so a partner's photos are
never returned. Both partners therefore see only their own uploads, which is
precisely what AC2 requires not to happen.

**No client-side workaround was implemented, and none is possible.** The
mobile client cannot synthesize the partner's rows: there is no
partner-scoped list endpoint, and A1 freezes the `gallery`/`uploads`
contract. Confirmed by reading `lib/features/gallery/data/gallery_api.dart` —
the only read path is a single `GET /gallery?limit=&offset=` call, with no
second partner-scoped fetch, no client-side merge, and no id-substitution
hack.

What *is* verified and will work unchanged once the backend is couple-scoped:

- `GalleryTile`'s uploader-attribution badge derives purely from
  `item.userId == currentUserId` (self = pink, partner = purple), so
  interleaved two-partner data renders correctly the moment it arrives.
  Asserted by `gallery_grid_test.dart` badge-variant tests using fixture
  items from two distinct user ids.
- `GalleryViewerScreen`'s caption resolves "You" / "Partner" from the same
  comparison.

AC2's *client* half is implemented and tested against two-uploader fixtures;
only the server's scoping blocks the end-to-end criterion. Escalated to Scrum
Master — requires a backend story or an explicit deferral, per master-plan
§3A ("AC2 blocked — escalate before review").

### 2.3 AC3 — PASS

| Evidence | Detail |
|---|---|
| `gallery_cubit_test.dart` | `GalleryCubit.load` emits `GalleryLocked` when `GET /users/me` returns `partnerId == null`, and proceeds to `GalleryEmpty`/`GalleryLoaded` when non-null — both branches asserted |
| `gallery_cubit_test.dart` | `AppShell gallery destination` widget test taps the gallery tab and asserts `GalleryScreen` mounts, so the gate is reachable end-to-end from real app navigation |
| `gallery_cubit_test.dart` | `GalleryLockedView` renders the `link_off` glyph (not `lock`/`fingerprint`, per UX §4.5 access-state-vs-encryption-state rule) and exposes the CTA screen-reader label "Go to the pairing screen" |
| Code | `gallery_screen.dart:118` renders `GalleryLockedView` for `GalleryLocked()`; no gallery data path is reachable in that state |

Residual (pre-existing, documented in master-plan §6, not an AC3 failure):
the locked view's CTA has no pairing screen to navigate to in this worktree
because STORY-002's invite/joincode screens are not merged here.
`GalleryScreen` ships a documented placeholder snackbar rather than a silent
no-op. The gate itself — "unpaired users cannot access this feature" — is
fully satisfied; only the CTA's onward destination is pending STORY-002's
merge onto the integration branch.

## 3. Mobile Visual Audit

Method: code-level composition audit against `../ux/uiux-spec.md` §4/§6/§7 at
360 dp and 430 dp, cross-checked against the P2/P3/P4 widget tests. Device
screenshots were not captured — no emulator lifecycle is in scope for this
story (`phase-P5-verification.md` §1B: startup smoke OPTIONAL, readiness is
the `Key('home_screen_ready_signal')` widget-test signal).

| Screen | 360 dp | 430 dp | Verdict |
|---|---|---|---|
| `gallery-empty` | Centered column, 96px `add_photo_alternate` at 0.2 opacity, headline + support copy + `CupidAddAction` | Same (width-independent) | **PASS** — matches §4.1 incl. the 12-20% accent-opacity rule; `CupidAddAction` supplies §4.1's pill-vs-FAB adaptive CTA from the design system |
| `gallery-grid` | `galleryColumnCount(360) = 2` | `galleryColumnCount(430) = 3` | **PASS** — matches §6 exactly (2-col base, 3-col at >=430 dp, width-based not orientation-based) |
| `gallery-upload` | `r-sheet` 28px modal, 88px horizontal thumbnail strip, offline message disables the pick button | Same (sheet is width-fluid) | **PASS as a component**, but **unreachable in the app** — see §2.1 |
| `gallery-viewer` | Chromeless `PageView`, `BoxFit.contain` letterbox, `InteractiveViewer` 1x-4x pinch-zoom, platform-positioned close, always-visible prev/next, 2s auto-hide caption | Same | **PASS with 2 deviations** — see §3.1 |
| `gallery-locked` | Centered `link_off` + headline + support copy + `CupidPrimaryButton` | Same | **PASS** — matches §4.5 |

### 3.1 `gallery-viewer` spec deviations (non-blocking, recorded for review)

1. **No swipe-down-to-dismiss.** UX §3 and §4.4 specify "swipe down or tap
   close". Only the tap-close control is implemented. Accessibility is
   unaffected (§7 only requires a non-gesture equivalent, which exists), but
   this is a missing gesture affordance versus the spec.
2. **Viewer renders the thumbnail URL, not a full-resolution image.**
   `GalleryViewerPhoto._resolvedImageUrl()` prefers `item.thumbnailUrl` and
   falls back to `galleryMediaUrl(item.filename)`, identical to
   `GalleryTile`. Today this is inert — `gallery_api.dart:29` documents that
   the backend never populates `thumbnailUrl`, so both paths resolve to the
   full-size `/uploads/<filename>`. It becomes a fidelity regression the
   moment the backend starts returning real thumbnails, because the
   full-screen viewer would then show a grid-sized image.

### 3.2 Grid tile composition (§4.2)

Verified present in `gallery_tile.dart`: fixed `3/4` aspect ratio,
`platform.radiusSmall` corners, `colors.glowShadow`, bottom caption chip over
an `rgba(23,17,41,.6)` scrim matching the spec's exact scrim value, 24px
uploader-initial badge top-right (pink for self, purple for partner). In
`gallery_grid_view.dart`: the dashed add-photo tile is pinned as the **last**
grid cell (built after photos and shimmer skeletons), pull-to-refresh via
`RefreshIndicator`, and next-page shimmer skeleton tiles rather than a
full-screen spinner, per §4.2.

### 3.3 R4 observation — grid scroll and image cache memory (§5 D-2)

Measured statically, not via an automated perf harness (per
`phase-P5-verification.md` §3: "report the measurement; do not gate the phase
on an automated perf harness").

- Every tile passes a non-null `memCacheWidth = min(640, tileWidth * dpr)`.
  Asserted for every rendered tile by `gallery_grid_test.dart`'s "every
  rendered tile passes a non-null memCacheWidth no greater than 640" test, so
  the D-2 decode cap cannot silently regress.
- Worst-case decode footprint per tile: 640 x 853 px (3:4) at 4 bytes/px
  = **~2.1 MB**. A 2-column 360 dp viewport holds roughly 8 tiles on screen
  plus `GridView`'s cache extent, so the resident decode set stays in the
  ~17-25 MB range — comfortably inside D-2's budget on low-end Android.
- Scroll smoothness safeguards in `gallery_grid_view.dart`:
  `addRepaintBoundaries: true`, `addAutomaticKeepAlives: false` (off-screen
  tiles are not retained), and a `_loadMoreRequestedAtLength` latch
  guaranteeing exactly one `onLoadMore()` per page instead of one per frame
  near the tail — directly asserted by two `gallery_grid_test.dart` tests.
- Not measured: real-device frame timings. No physical low-end Android device
  or emulator was exercised in this phase.

### 3.4 Accessibility (§7)

| §7 requirement | Status |
|---|---|
| Grid tile accessible label (date + uploader) | **PASS** — `GalleryTile._semanticsLabel` → "Photo from you, <date>" / "Photo from your partner, <date>"; location omitted because `GalleryItem` has no location field at P0's scope |
| Viewer gestures have non-gesture equivalents | **PASS** — always-visible close and prev/next `_ViewerIconButton`s, each `Semantics`-labelled and independent of the caption fade |
| Upload progress announced via live region, not colour alone | **PASS** — `GalleryUploadItem` wraps every state in `Semantics(liveRegion: true)` with a text label, and renders the same text in the visible caption strip |
| Minimum tap targets 44pt/48dp | **PASS** — viewer controls sized to `platformTokens.tapTarget`; add-photo tile and upload retry targets are full tiles (>=88 px) |
| Locked gate CTA labelled as navigating to pairing | **PASS** — "Go to the pairing screen" / "Đi đến màn hình ghép đôi" |

## 4. Blocked-Scope Confirmation

Confirmed by reading all 18 source files under `mobile/lib/features/gallery/`:

| Forbidden scope | Result |
|---|---|
| Device-only encryption / AES / libsodium | **ABSENT** |
| Biometric unlock, 60s auto-lock, screenshot detection | **ABSENT** |
| Delete / report affordance, `DELETE /gallery/{id}` | **ABSENT** |
| `Epic4PrivateGalleryApi` usage | **ABSENT** — `gallery_api.dart:43-46` documents why the generated client is unusable and calls the shared `Dio` directly |
| Backend or `mobile/openapi/` change | **NONE** — A1 respected |
| Lock affordance driven by `isEncrypted` / `encryptionKeyId` | **ABSENT** — fields ignored per R3=NO |

## 5. Configuration Guide Confirmation

P3's update landed: `../../deployment/configuration-guide.md` contains the
"Photo Library Permissions (STORY-013)" section documenting
`android.permission.READ_MEDIA_IMAGES`
(`mobile/android/app/src/main/AndroidManifest.xml`) and
`NSPhotoLibraryUsageDescription` (`mobile/ios/Runner/Info.plist`). Both
platform files carry the entries, and `flutter build apk --debug` succeeding
confirms the Android manifest is well-formed.

## 6. Blockers For Scrum Master

### BLOCKER-1 — AC2 backend user-scoping (pre-existing, escalated)

Scope: backend. `GET /gallery` is user-scoped; AC2 needs couple-scoping.
Source: `../architecture/solution.md` §7; master-plan §3A last row.
Action: route a backend story, or accept AC2 as deferred at the review gate.
No mobile change is required or possible — the client is already written so
couple-scoped data renders correctly with zero client edits.

### BLOCKER-2 — design-system no-fork guard failure (new, found in P5)

Scope: mobile, this story, small and fully fixable.
`test/design_system/no_fork_guard_test.dart` fails because STORY-013 code
introduced 5 raw `Colors.*` literals into guarded directories, violating
STORY-001's AC4 contract (`architecture/solution.md` D3/ADR-004: screens must
consume the design system through `ThemeExtension` tokens):

| File | Line | Literal |
|---|---|---|
| `lib/features/gallery/presentation/screens/gallery_viewer_screen.dart` | 128 | `Colors.black` |
| `lib/features/gallery/presentation/screens/gallery_viewer_screen.dart` | 256 | `Colors.white24` / `Colors.white` |
| `lib/features/gallery/presentation/screens/gallery_viewer_screen.dart` | 302 | `Colors.white` |
| `lib/features/gallery/presentation/widgets/gallery_tile.dart` | 135 | `Colors.white` |
| `lib/features/gallery/presentation/widgets/gallery_upload_item.dart` | 118 | `Colors.white` |

The guard's forbidden patterns are `Color(0x`, `Colors.`, `Platform.is`, and
`defaultTargetPlatform`. The neighbouring `Color.fromRGBO(23, 17, 41, 0.6)`
scrims do **not** trip it, so the fix is narrow: replace each `Colors.*` with
the appropriate `CupidColorTokens` member (or `Color.fromRGBO` for the
deliberately photo-neutral black/white overlay values). No design decision is
required.

These files are outside P5's write scope, so the fix was not applied here.

### BLOCKER-3 — AC1 upload flow unreachable (new, found in P5)

Scope: mobile, this story, fully fixable. See §2.1. `gallery_screen.dart`
must call `GalleryUploadSheet.show` instead of `_showUploadFlowUnavailable`
at lines 120 and 139. `gallery_screen.dart` is outside P5's write scope.

## 7. Phase Status Roll-Up

| Phase | Status |
|---|---|
| P0 | DONE |
| P1 | DONE |
| P2 | DONE (P5 follow-up: BLOCKER-2 colour literal in `gallery_tile.dart`) |
| P3 | DONE (P5 follow-up: BLOCKER-2 colour literal in `gallery_upload_item.dart`; BLOCKER-3 sheet never wired into a screen) |
| P4 | DONE (P5 follow-up: BLOCKER-2 colour literals in `gallery_viewer_screen.dart`; BLOCKER-3 upload placeholder left in `gallery_screen.dart`) |
| P5 | BLOCKED — `flutter test` red (BLOCKER-2), AC1 not reachable (BLOCKER-3), AC2 not satisfiable (BLOCKER-1) |

`phase-P5-verification.md`'s own `## 7. Status` section was **not** updated:
that file is outside this dispatch's declared write scope, which covers
`test-results.md` and the `## 7. Status` sections of P0-P4 only. Scrum Master
should set it to `BLOCKED`.
