# Phase P6 – BLOCKER-2 / BLOCKER-3 Fix

## 1. Objective

Clear the two in-story mobile blockers recorded in `test-results.md` §6 by
P5's verification pass: BLOCKER-2 (design-system fork-guard failure) and
BLOCKER-3 (AC1 upload flow unreachable). BLOCKER-1 (backend `GET /gallery`
AC2 scoping gap) is out of this phase's scope and stays open, tracked by
Scrum Master as a backend/deferral decision.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-blocker-fix.md`
- Owner: Mobile Developer
- Lane: Mobile

## 2. BLOCKER-2 — design-system fork-guard failure (RESOLVED)

`test/design_system/no_fork_guard_test.dart` was failing because 5 raw
`Colors.*` literals had been introduced into guarded directories, violating
STORY-001's AC4 contract (`architecture/solution.md` D3/ADR-004: screens must
consume the design system through `ThemeExtension` tokens, never a raw color
literal).

All five call sites render on top of `gallery-viewer`'s chromeless overlay or
a caption chip that is deliberately dark regardless of the active app theme
(`ux/uiux-spec.md` §4.2/§4.4: "dark scrim background consistent with the
`--sky` nebula theme"). The existing scrim backgrounds already hard-code the
dark theme's `colorBackground` RGB value (`Color.fromRGBO(23, 17, 41, 0.6)`,
matching `CupidColorTokens.dark().colorBackground` = `0xFF171129`), so the fix
keeps that same "always dark theme" intent for the foreground/background
`Colors.*` literals by replacing each with the matching
`CupidColorTokens.dark()` member instead of a themed `context.cupidColors`
lookup (which would flip to a light background/dark text in light mode and
break the chromeless-viewer visual). No new token was added and no visual
redesign was performed — this is a literal-to-token substitution only.

| File | Line | Before | After |
|---|---|---|---|
| `lib/features/gallery/presentation/screens/gallery_viewer_screen.dart` | 128 | `Colors.black` | `CupidColorTokens.dark().colorBackground` |
| `lib/features/gallery/presentation/screens/gallery_viewer_screen.dart` | 256 | `Colors.white24` (disabled) / `Colors.white` (enabled) | `CupidColorTokens.dark().colorGhost` (disabled) / `CupidColorTokens.dark().colorText` (enabled) |
| `lib/features/gallery/presentation/screens/gallery_viewer_screen.dart` | 302 (now 303-305) | `Colors.white` | `CupidColorTokens.dark().colorText` |
| `lib/features/gallery/presentation/widgets/gallery_tile.dart` | 135 | `Colors.white` | `CupidColorTokens.dark().colorText` |
| `lib/features/gallery/presentation/widgets/gallery_upload_item.dart` | 118 | `Colors.white` | `CupidColorTokens.dark().colorText` |

Token rationale:

- `colorBackground` (dark) — near-black nebula background, visually
  equivalent to the previous `Colors.black`, but sourced from the design
  system.
- `colorText` (dark) — near-white (`0xFFF7EEFB`) theme-axis text color;
  correct role for legible text/icons over an always-dark overlay.
- `colorGhost` (dark) — `CupidColorTokens`'s documented "Muted/inactive role",
  the correct semantic token for the viewer's disabled prev/next button state
  (previously `Colors.white24`).

No changes were made to the pre-existing `Color.fromRGBO(23, 17, 41, 0.6/0.35)`
scrim backgrounds in `gallery_tile.dart` / `gallery_upload_item.dart` — those
are not `Colors.*`/`Color(0x` literals and do not trip the guard; they already
carry the exact `rgba(23,17,41,.6)` value from `ux/uiux-spec.md` §4.2.

## 3. BLOCKER-3 — AC1 upload flow unreachable (RESOLVED)

`gallery_screen.dart`'s two add-photo entry points (`GalleryEmpty` and
`GalleryLoaded`/`GalleryGridView`) called the P4 placeholder
`_showUploadFlowUnavailable`, which only showed a snackbar. `GalleryUploadSheet`
(built in P3) was never invoked from any screen and `GalleryUploadCubit` was
never constructed outside tests.

Fix: removed `_showUploadFlowUnavailable` and added `_openUploadFlow`, which:

1. Reads the enclosing `GalleryCubit` from context (same pattern already used
   for `onRefresh`/`onLoadMore`).
2. Constructs a `GalleryUploadCubit` from `getIt<GalleryRepository>()`, with
   `onUploaded` wired to `galleryCubit.insertOptimistic` — matching UX §3's
   "optimistic insert at grid start, replaced by server data on next sync" and
   `GalleryUploadCubit`'s own documented "caller owns the cubit's lifetime and
   `onUploaded` wiring" contract.
3. Calls `GalleryUploadSheet.show(context, cubit: uploadCubit)`.

Both `onAddPhoto` call sites (`GalleryEmptyView` and `GalleryGridView`) now
call `_openUploadFlow(context)` instead of the placeholder. No redesign of the
upload flow itself — only wiring the already-built P3 classes into the
screen, per this dispatch's scope.

## 4. Test Evidence

Commands run from `mobile/` in this worktree, `PATH` including the local
Flutter SDK (`~/flutter/bin`):

| Command | Result |
|---|---|
| `flutter analyze lib/features/gallery test/design_system/no_fork_guard_test.dart test/features/gallery` | **PASS** — 0 errors, 0 warnings, 1 pre-existing `info` lint (`gallery_api.dart:88`, unrelated to this fix) |
| `flutter test test/design_system/no_fork_guard_test.dart` | **PASS** — 1/1 (previously failing; BLOCKER-2 confirmed cleared) |
| `flutter test test/features/gallery` | **PASS** — 40/40 |
| `flutter test` (full suite) | **PASS** — 159/159, 0 failures |

Full details recorded in `test-results.md` §7 (P6 addendum).

## 5. Scope Confirmation

- No backend or `mobile/openapi/` changes.
- No new design-system tokens added; only existing `CupidColorTokens.dark()`
  members consumed.
- No redesign of the upload sheet, upload cubit, or gallery repository — only
  the screen-level wiring call sites changed.
- BLOCKER-1 (AC2 backend user-scoping) is untouched and remains open, per this
  dispatch's explicit instruction not to touch it.

## 6. Status

- BLOCKER-2: RESOLVED
- BLOCKER-3: RESOLVED
- BLOCKER-1: OPEN (out of mobile scope, tracked separately by Scrum Master)
- Last updated: 2026-07-31
