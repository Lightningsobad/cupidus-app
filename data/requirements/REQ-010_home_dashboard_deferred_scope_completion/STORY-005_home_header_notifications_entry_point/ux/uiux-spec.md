# UX Spec: STORY-005 Home Header — Notifications Quick Access

Story-Class: trivial | Scope: new header action icon + conditional indicator
dot, both wired to an already-shipped destination screen. No new screen, no
new navigation graph node, no new notifications inbox/feed.

## Literal Design Source

`cupid-app-design-system/Cupid Screens.dc.html`, `isHome` block, header row
(lines 248-251), read directly:

```html
<div style="display:flex;align-items:center;gap:2px">
  <div onClick="{{ goShareDays }}" style="width:var(--tap);height:38px;display:flex;align-items:center;justify-content:center;cursor:pointer">
    <span data-icon="line" style="font-size:23px;color:var(--tx2)">{{ shareIcon }}</span>
  </div>
  <div onClick="{{ goNotifs }}" style="width:var(--tap);height:38px;display:flex;align-items:center;justify-content:flex-end;position:relative;cursor:pointer">
    <span data-icon="line" style="font-size:24px;color:var(--tx2)">notifications</span>
    <div style="position:absolute;top:4px;right:1px;width:8px;height:8px;border-radius:50%;background:var(--pink);box-shadow:0 0 9px var(--pink)"></div>
  </div>
</div>
```

This icon row sits at the right edge of the header, opposite the partner
avatar pair + couple label block (`_PresenceRow` in
`mobile/lib/features/home/presentation/home_screen.dart`). Today that block
renders alone inside a `Row(mainAxisSize: MainAxisSize.min, ...)` with no
trailing slot — the outer `space-between` row that hosts both the presence
content on the left and this action-icon row on the right does not exist yet.
This story only needs the `goNotifs` icon; `goShareDays` is STORY-004's scope
and must not be added, blocked on, or assumed present by this spec —
`goNotifs` must render correctly whether it is the row's only child or sits
next to a later-added share icon (`Depends-On: NONE`, per `story_master.md`).

## Placement & Composition

1. Header content becomes a two-side layout: presence block (avatars +
   couple label) on the left, action-icon row on the right, `space-between`
   across the existing header horizontal padding (no new outer padding —
   reuse the hero block's current horizontal inset).
2. Action-icon row: `Row`, `gap: 2px` between icons if more than one is
   present (matches design `gap:2px`); today, with only `goNotifs`
   implemented, this is a one-child row.
3. Notifications icon tap target: width = platform tap-target token
   (`--tap` → iOS 44 / Android 48, i.e. `context.cupidPlatform`'s existing
   tap-size value — do not hardcode a new constant), height `38`.
4. Content alignment inside the tap target: right-aligned
   (`justify-content:flex-end` in source) — icon (and its dot) sit flush to
   the tap target's trailing edge, not centered. This matches the source
   exactly and must not be changed to centered even though the sibling share
   icon (when it exists) is centered — the two icons use different internal
   alignment by design.
5. Icon glyph: Material "notifications" (outline/line style,
   `data-icon="line"`), `font-size: 24`, color = existing muted text token
   (`colors.colorTextMuted`, the same token used for `--tx2` elsewhere in
   this header, e.g. the couple-type label).

## Indicator Dot — Visual Spec

- Shape: 8×8 circle, `border-radius: 50%`.
- Position: absolute within the icon's tap-target box, `top: 4`, `right: 1`.
- Color: existing accent-pink token (`colors.colorAccentPink`, same token as
  `--pink`).
- Glow: `box-shadow: 0 0 9px` the same accent-pink color (matches source's
  `box-shadow:0 0 9px var(--pink)`).
- No animation, no badge count/number — dot only, per the locked source (no
  numeric badge markup exists in the design block).

## Indicator Dot — Show/Hide Rule (AC3)

The design source renders this dot unconditionally, but the story requires it
to reflect a real state and explicitly forbids inventing a new backend
notification-tracking system. The only "unread/unconfigured" signal already
available to the Notifications feature is local, on-device, and already
read by `notification_settings_screen.dart` today:

- `NotificationPreferencesStore` (`mobile/lib/features/account/data/
  notification_preferences_store.dart`) persists the user's toggle choices
  to on-device storage. When no value has ever been persisted for the
  signed-in user, `load()` currently falls back to `defaults` silently — the
  screen cannot today distinguish "user explicitly reviewed and kept
  defaults" from "user has never opened this screen."
- **Dot show condition ("unconfigured")**: no preference value has ever been
  persisted for the signed-in user (the store's raw persisted value is
  absent) — i.e., this user has never saved a change on the Notifications
  screen.
- **Dot hide condition ("configured")**: at least one preference has been
  explicitly saved (raw persisted value present), regardless of which
  toggles are on/off. Saving "no changes, all defaults" still counts as
  configured once persisted.
- Evaluate this condition each time the Home header renders (fresh read on
  Home build/refresh), so the dot clears the next time Home is shown after
  the user visits Notifications and saves a toggle.
- This is an existing on-device read, not a new tracking system, new API, or
  new server-side field — Tech Lead owns the exact accessor
  (e.g. exposing a boolean alongside `load()`) but must not add a remote
  call or new persisted "seen" flag beyond what `NotificationPreferencesStore`
  already tracks.
- AC3 explicitly requires: when no such unconfigured state exists for the
  signed-in user, the dot does not render (not just visually hidden —
  omitted, matching how the rest of this design system treats conditional
  markup, e.g. `sc-if` blocks elsewhere in the same design source).

## Navigation (AC2)

Tap target action: push to the existing
`NotificationSettingsScreen` (`account/presentation/screens/
notification_settings_screen.dart`), the same destination already reachable
from the Me/Account tab (shipped by REQ-002 STORY-031, `Status: DONE`). No
new route, no new screen, no change to that screen's own content — this
story only adds a second entry point to it.

## Accessibility

- Tap target meets the platform minimum via the existing `--tap` token (44pt
  iOS / 48dp Android) — do not shrink the semantic/touch bounds to the
  visual icon's smaller footprint.
- Semantic label: "Thông báo" (vi) / "Notifications" (en) — add these under
  the existing home-header l10n key namespace, matching neighboring header
  labels' naming convention (do not reuse `notifs_title`, which is the
  destination screen's own title, not this entry point's label).
- When the indicator dot is visible, the semantic label should communicate
  the unconfigured state (e.g. append "· chưa xem" / "· unread" to the base
  label) so the state is not sighted-only.

## Locale & Theme (AC1)

Verify enabled dark theme + `vi` locale rendering per AC1: icon color, dot
color, and tap-target sizing must match the tokens above with no
locale-specific layout shift (icon/dot position does not depend on string
length, unlike the couple label to its left).

## Acceptance Criteria Mapping

| AC | Spec section satisfying it |
|----|------------------------------|
| AC1 (icon appears, correct position/style, dark theme + `vi`) | Placement & Composition, Indicator Dot — Visual Spec, Locale & Theme |
| AC2 (tap navigates to existing Notifications screen, no new screen) | Navigation |
| AC3 (dot hidden when no unread/unconfigured state) | Indicator Dot — Show/Hide Rule |

## Out of Scope (carried from story_master.md)

- `goShareDays` icon and any new notifications inbox/feed/list screen.
- Any change to `notification_settings_screen.dart` content, toggles, or
  copy.

## Status

UX_COMPLETE: YES
