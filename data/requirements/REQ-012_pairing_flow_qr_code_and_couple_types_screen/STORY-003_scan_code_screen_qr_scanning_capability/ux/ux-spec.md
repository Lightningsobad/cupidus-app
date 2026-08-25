# UX Spec: STORY-003 Scan-Code Screen QR Scanning Capability

Screen: Join/scan-code screen (`sc` state `joincode`, `isJoinCode` block),
design source `cupid-app-design-system/Cupid Screens.dc.html` lines 1617-1637.
Locale: `vi` primary (`en` secondary, same copy pattern as existing screen).
Theme: existing dark theme tokens only — no new tokens introduced.

## OQ1 Resolution (final — not deferred further)

**Mechanism: full-screen camera overlay, presented on top of the existing
join-code screen (not an inline scanner panel).**

Rationale:
- The join-code screen is already visually dense (icon, title, subtitle,
  6-box code row, Paste/Scan row, Pair up CTA, switch link). There is no
  room to fit a live camera preview inline at a size usable for QR framing
  without pushing existing elements off-screen or shrinking the code boxes.
- A full-screen camera view gives maximum frame area for reliable QR
  recognition, matches conventional scanner UX (native camera / QR apps),
  and is the least surprising pattern for users.
- Presenting it as an overlay (not a full navigation/route change) keeps the
  underlying join-code screen state (any manually-typed characters, scroll
  position) intact and instantly resumable when the user dismisses the
  overlay or falls back to manual entry — no data loss, no re-navigation.

**Permission-prompt timing/copy: requested at the moment of tap, no earlier
soft pre-ask screen.** Business rule (story_brief.md) is explicit that
camera permission must not be requested before the user initiates a scan.
Tapping "Quét QR" immediately opens the full-screen overlay in a brief
"opening camera" state while the OS-native permission dialog (if not yet
decided) is triggered on top of it. This avoids adding an extra custom
"why we need your camera" screen that the story does not ask for and that
would add a step before every scan attempt once permission is already
granted.

## Entry Point (unchanged)

The existing "Quét QR" / "Scan QR" button in the Paste/Scan action row
(`cupid-app-design-system/Cupid Screens.dc.html:1632`) is the only entry
point. No visual change to this button, its icon (`qr_code_scanner`), label,
or position in the row. Tapping it opens the full-screen scan overlay
described below. The "Dán" / "Paste" button, the 6-box code row, "Ghép đôi"
/ "Pair up" CTA, and "Tôi mới là người tạo mã →" switch link are unchanged
and remain exactly as in the current design.

## Scan Overlay — State Machine

The overlay is a full-screen modal (covers the entire viewport, dark
scrim/background consistent with the app's dark theme) presented above the
join-code screen. It always exposes two persistent exit affordances:

- Top-left: a close/back icon (`arrow_back` or `close`, `var(--tx2)`,
  24px hit target ≥44x44px) — dismisses the overlay and returns to the
  join-code screen unchanged, in every state.
- A "Nhập mã thủ công" / "Enter code manually" text link — visible in every
  non-live-camera state (see below), and always reachable within one tap
  from the live-scanning state via the close icon — dismisses the overlay
  and returns focus to the 6-box code row on the join-code screen.

### State 1 — Opening (transient)
- Triggered immediately on tap of "Quét QR".
- Overlay fades in over ~150ms with a centered camera icon placeholder
  (`photo_camera`, `var(--tx2)`, 40px) and small loading spinner beneath it
  while the app requests/reads the current camera permission state.
- Duration: as short as possible; if permission is already granted this
  state is skippable/near-instant and should transition straight to State 2.

### State 2 — Live Scanning (permission granted)
- Full-viewport live camera preview.
- Centered square/rounded-square viewfinder frame (border using
  `var(--pink)`, matches the existing pink accent used for the active code
  box border at line 1627) sized to roughly 70% of the shorter screen
  dimension, to guide QR framing.
- Subtle animated scan-line or pulsing frame border (reuses existing
  `popIn`/pulse-style animation conventions already present in this design
  system, e.g. the `popIn` keyframe used at line 1619) — no new animation
  primitive needed, a simple opacity/border pulse is sufficient.
- Helper text below the frame, `var(--tx2)`, ~13px, matching existing body
  copy size on this screen: "Đưa camera vào mã QR của người ấy" / "Point
  your camera at their QR code".
- "Nhập mã thủ công" link pinned near the bottom of the overlay, same pink
  (`var(--pink)`) weight-700 13px treatment as the existing "Tôi mới là
  người tạo mã →" switch link (line 1635), so it reads as a clear secondary
  action, not a camera control.
- Top-left close icon as described above.

### State 3 — Recognized (transient success)
- On successful QR decode, the viewfinder frame briefly flashes/solidifies
  in a success tone (reuse `var(--mint)`, the existing success/lock-icon
  color from this design file, line 1610) for ~300-400ms with a checkmark
  icon, then the overlay hands off directly into the existing
  accept-invitation/pairing flow (same flow manual entry triggers via
  "Ghép đôi") — no separate confirmation screen, no re-typing.
- If the pairing flow itself has its own loading/processing UI already
  (existing capability, not introduced by this story), that existing UI
  takes over immediately after this transient success flash; this story
  does not define new pairing-processing UI.

### State 4 — Invalid/Unreadable/Expired Code
- Triggered when a QR is decoded but does not resolve to a valid, current
  pairing code (malformed payload, expired code, wrong code type).
- The overlay stays full-screen; camera preview keeps running behind a
  message card so the user isn't forced to re-open the scanner to retry.
- Message card: centered, `var(--surf)` background, `var(--line)` border,
  rounded corners matching `var(--r-btn)` radius convention used elsewhere
  on this screen, containing:
  - Warning icon (`error_outline` or `qr_code`, colored to signal failure —
    reuse the app's existing error/destructive tone if one exists in the
    shared token set; otherwise `var(--tx2)` with the icon shape itself
    communicating the failure state).
  - Copy: "Mã QR không hợp lệ hoặc đã hết hạn" / "This QR code is invalid or
    has expired" — honest, specific, no fabricated success.
  - Two actions: "Thử lại" / "Try again" (primary, dismisses card, resumes
    live scanning — State 2) and "Nhập mã thủ công" / "Enter manually"
    (secondary text link, same treatment as in State 2, closes overlay to
    join-code screen).
- Auto-dismiss the card back to State 2 after a short duration (e.g. ~3s) if
  the user takes no action, so a misread/partial frame doesn't permanently
  block re-scanning — "Thử lại" remains available for an explicit retry at
  any time before that.

### State 5 — Permission Denied (first ask)
- Triggered when the user denies the OS camera-permission prompt.
- Overlay collapses the camera preview area to a static message state
  (no live camera view, since none is available):
  - Icon: `no-photography` / `videocam_off` style icon, `var(--tx2)`.
  - Title/copy: "Cupid cần quyền camera để quét mã QR" / "Cupid needs
    camera access to scan QR codes".
  - Primary button (same visual weight as the existing "Ghép đôi" CTA
    pattern — `var(--grad-hot)` background, white text, `var(--r-btn)`
    radius): "Nhập mã thủ công" / "Enter code manually" — this is the
    primary action here, not a permission re-prompt, since re-prompting is
    an OS-level decision outside app control in this state on most
    platforms.
  - Top-left close icon still present as an equivalent exit.

### State 6 — Permission Permanently Denied ("Don't ask again" / blocked)
- Triggered when the OS reports permission as blocked/restricted (cannot
  re-prompt in-app).
- Same visual layout as State 5, with copy adjusted to point at Settings:
  "Cupid cần quyền camera trong Cài đặt để quét mã QR" / "Camera access is
  off in Settings — turn it on to scan QR codes".
- Primary button: "Mở Cài đặt" / "Open Settings" (deep-links to the OS app
  settings page, existing platform capability, not new UI).
- Secondary text link beneath it, same pink text-link treatment as
  elsewhere on this screen: "Nhập mã thủ công" / "Enter manually" — always
  gives the user a working path to pair without leaving the app.

### State 7 — Camera Unavailable (no hardware / hardware error)
- Triggered when the device reports no usable camera (rare; e.g. hardware
  fault) rather than a permission decision.
- Same visual layout as State 5/6, copy: "Không thể mở camera trên thiết bị
  này" / "Camera isn't available on this device".
- Only action offered: "Nhập mã thủ công" / "Enter code manually" (no
  Settings deep-link, since this isn't a permission issue).

## Fallback Guarantee

Every state above (2 through 7) exposes a "Nhập mã thủ công" / "Enter
manually" path reachable in at most one tap, and the top-left close icon is
present in all states as a universal escape. Dismissing the overlay by any
route returns the user to the join-code screen exactly as it was — code
boxes, Paste/Scan row, Pair up CTA, and switch link all unchanged and
usable, satisfying AC3 and AC5's "preserve existing manual UI unchanged"
requirement.

## Reused vs. New Visual Tokens

Reused only (no new tokens/colors introduced):
- `var(--pink)` — active/focus accent (viewfinder frame, manual-entry link).
- `var(--mint)` — success/recognized state accent (already used for the
  lock icon at line 1610).
- `var(--tx2)` — secondary text/icon color throughout.
- `var(--surf)` / `var(--line)` — card background/border (message states).
- `var(--r-btn)` — button/card corner radius.
- `var(--grad-hot)` — primary CTA gradient (permission-denied fallback
  button), matching the existing "Ghép đôi" button treatment.

## Accessibility

- Every icon-only control (top-left close icon) has a minimum 44x44px
  touch target and an accessible label ("Đóng" / "Close", "Quay lại" /
  "Back").
- Camera-preview states must not rely on color alone to signal
  success/failure: State 3 pairs the mint color with a checkmark icon,
  State 4's card pairs its tone with explicit copy and a warning icon.
- All permission/error copy is literal and honest — no "scanning..." or
  success indication is shown unless a real successful decode occurred
  (directly satisfies AC4's "not a fabricated success" requirement).
- Overlay must trap focus while open (keyboard/screen-reader users cannot
  tab to the join-code screen underneath) and return focus to the "Quét QR"
  button (or the manual entry code boxes, if the user chose manual fallback)
  on dismiss.

## Responsive Behavior

- Full-screen overlay fills the viewport at all supported mobile widths;
  the viewfinder frame sizing (~70% of shorter dimension) keeps it
  centered and proportionate on both narrow and larger phone screens.
- Message-card states (4-7) cap card width consistently with other
  dialog/card patterns already in this design system rather than
  stretching edge-to-edge, preserving readability on wider devices.

## Handoff Notes for Tech Lead / Development

- Reuses the existing accept-invitation/pairing capability already invoked
  by the manual "Ghép đôi" button — a decoded QR value must be normalized
  to the same code format/casing expected by that existing capability
  before invoking it, so success/failure handling doesn't diverge between
  manual and scanned entry (AC2).
- No new pairing outcome states are introduced; this story only adds the
  scan overlay in front of the existing capability.
- Camera/QR-decoding library selection is a Tech Lead/Development decision,
  out of UX scope.
