# UX Spec: STORY-002 Home Dashboard Quick Grid — Zodiac Red Flag Tile

Requirement: REQ-011 · Story: STORY-002 · Depends on: STORY-001 (`DONE`,
route `ZodiacRedFlagScreen.routeName = '/zodiac/red-flag'`, registered in
`mobile/lib/app/cupid_app.dart:69-70`).

## 1. Current-state audit (code, not the mock)

`mobile/lib/features/home/presentation/home_screen.dart` does **not**
implement the design's literal CSS 2-column grid anywhere today. Every
Home quick-access feature — Vibe, Synced Alarm/reminder, Dream Jar, Love
Contract, Timeline, Expenses, Gallery, Anti-Ghosting — renders as a
**full-width stacked "entry card"** (icon left, title+subtitle right,
optional trailing chevron, `Column` with `_cardGap = 13` between them,
lines 194-257). `_ReminderEntryCard` (lines 870-924) is what the story
calls "the Synced Alarm tile"; it has no colored icon container and no
grid-tile shape — plain icon + two-line text in a `Row`.

The design source (`cupid-app-design-system/Cupid Screens.dc.html`,
lines 305-326) specifies a real `display:grid;grid-template-columns:1fr
1fr` row containing **4** square tiles: Synced Alarm, Zodiac Red Flag,
Dream Jar, Anti-Ghosting (icon-in-rounded-square top, 14px/800 title,
11.5px colored subtitle). Only 2 of those 4 are this story's concern —
Dream Jar and Anti-Ghosting already ship as their own full-width entry
cards and are explicitly out of scope for this story (per
`story_master.md` Out of Scope); do not touch them or fold them into a
grid.

## 2. Scope clarification (flag for Scrum Master / PO before build)

AC1 requires the quick grid to show **both** `Synced Alarm` and `Zodiac
Red Flag` "in the design's 2-column layout with no visible deviation."
Story Out of Scope separately says "Any change to the Synced Alarm tile
itself" is excluded. These are in tension: satisfying AC1 literally
requires reshaping the Synced Alarm entry from a full-width row into a
half-width grid tile with a new colored icon container — a presentation
change, even though its copy, icon glyph, and navigation target stay
identical.

**Resolution used below (Option A):** treat "no change to the Synced
Alarm tile" as no change to its *content/behavior/identity* (copy,
icon, tap target), and treat the container reshape as required scope to
satisfy AC1's explicit, testable "2-column layout" wording. If Scrum
Master/PO instead intended Option B (leave the existing full-width
Synced Alarm row untouched and add Zodiac Red Flag as an 8th full-width
`EntryCard` matching the established stacked pattern — consistent with
every other Home feature, but not literally 2-column), flag that back
before implementation; it is a smaller, lower-risk change but does not
satisfy AC1's literal wording.

## 3. Component: `_QuickGridRow` (new, replaces the current
   `_ReminderEntryCard` list position)

Insert this row at the exact list position `_ReminderEntryCard`
currently occupies (`home_screen.dart:210-217`, between `VibeEntryCard`
and `DreamJarEntryCard`), with the same `_cardGap = 13` spacing above
and below. It replaces the single full-width `_ReminderEntryCard` call
with one row holding two half-width tiles.

- Layout: horizontal row, two equal-width tiles, `12px` gap between them
  (`Cupid Screens.dc.html:305`, `gap:12px`) — matches existing `Row` +
  `Expanded` idiom already used elsewhere in this file (no `GridView`
  precedent exists in this codebase; do not introduce one for two
  items).
- Each tile: `Material` + `InkWell`, `padding: 16`,
  `borderRadius: context.cupidPlatform.radiusCard`,
  `color: colors.colorSurface`, `boxShadow`/elevation consistent with
  other Home cards (`Cupid Screens.dc.html:306,311` — `box-shadow:
  var(--shadow)`).
- Tile internal layout (top to bottom, left-aligned):
  1. Icon container: `38x38`, `borderRadius:
     context.cupidPlatform.radiusSmall` (13px in the design), background
     = tile accent color at `alpha 0.2`, icon glyph centered at
     `size: 22`, icon color = tile accent color (full opacity).
  2. `SizedBox(height: 11)`.
  3. Title: `type.body`-equivalent at `14px / FontWeight.w800`,
     `color: colors.colorText`.
  4. `SizedBox(height: 3)`.
  5. Subtitle: `11.5px`, `maxLines: 1`, `overflow: ellipsis`.
- Minimum tap target: each whole tile is tappable
  (`context.cupidPlatform.tapTarget` minimum height), not just the icon.

### 3.1 Left tile — Synced Alarm (existing entry, reshaped only)

- Icon: `CupidIcons.notificationsActive` (unchanged from current
  `_ReminderEntryCard`).
- Accent color: `colors.colorAmber` (matches design `--amber` on the
  Synced Alarm mock tile, `Cupid Screens.dc.html:307`).
- Title: `context.reminderNotificationsRowTitle` (unchanged — ADR-002
  wording, do not revert to the design mock's literal "Synced Alarm").
- Subtitle: `context.reminderNotificationsRowSubtitle` (unchanged).
- Tap target: unchanged — pushes `ReminderScheduleScreen`
  (`home_screen.dart:212-215`).
- Keep the existing `Key('home_reminder_entry_card')` on this tile so
  existing widget tests keyed to it still resolve.

### 3.2 Right tile — Zodiac Red Flag (new)

- Icon: new `CupidIcons` entry for the Material Symbol `auto_awesome`
  (matches design `Cupid Screens.dc.html:312`, `icon: 'auto_awesome'`,
  same glyph family/pattern as the other `CupidIcons` entries in
  `mobile/lib/design_system/icons/cupid_icons.dart`).
- Accent color: `colors.colorPeach` (design `--peach`; token already
  exists in `mobile/lib/design_system/tokens/cupid_color_tokens.dart`,
  matches the design mock's Zodiac tile hex).
- Title: literal string `'Zodiac Red Flag'`, same in both `vi` and
  `en` — do not add a translated l10n key. This mirrors the existing
  precedent set by `zodiac_red_flag_screen.dart:40-42`
  (`_screenTitle = 'Zodiac Red Flag'`, documented there as "the same
  literal in `vi` and `en`" per the design source's locale maps).
- Subtitle: **static, non-personalized teaser copy** — do not fetch or
  render live `ZodiacConflictIndex` data (score/headline) here. Backend
  wiring and personalization are STORY-001's owned surface and are
  explicitly out of scope for this story; the design mock's "Xung đột
  7/10 hôm nay" / "Conflict 7/10 today" is illustrative sample content,
  not a literal requirement to reproduce dynamic data. Add two new
  l10n keys:
  - `home_zodiac_tile_subtitle` (vi): "Xem chỉ số xung đột hôm nay"
  - `home_zodiac_tile_subtitle` (en): "See today's conflict index"
- Tap target: navigate via
  `Navigator.of(context).pushNamed(ZodiacRedFlagScreen.routeName)`
  (named route already registered in `cupid_app.dart:69-70` — use the
  named-route form here, not a direct `MaterialPageRoute` import, since
  this is the only Home entry point using a route-name lookup rather
  than a screen import; either is acceptable to Tech Lead, but prefer
  the named route to avoid a new cross-feature import into
  `home_screen.dart` for a screen already registered globally).
- New `Key('home_zodiac_entry_tile')` for test targeting (no prior key
  exists to preserve).

## 4. Acceptance criteria mapping

- AC1 (2-column layout, no visible deviation): satisfied by §3's
  `_QuickGridRow` — verify visually against `Cupid Screens.dc.html`
  Home node in dark theme + `vi` locale, per the story's stated
  comparison conditions.
- AC2 (tap navigates to STORY-001's screen): satisfied by §3.2's
  `pushNamed(ZodiacRedFlagScreen.routeName)`.
- AC3 (no new top-level entry point): satisfied — the tile lives inside
  the existing Home dashboard's already-reachable card list; nothing
  added to `app_shell.dart` or tab navigation.

## 5. Accessibility

- Wrap each tile in `Semantics(button: true, excludeSemantics: true,
  label: '<title>. <subtitle>')`, matching the pattern already used in
  `_AntiGhostEntryCardChrome` (`anti_ghost_entry_card.dart:121-126`).
- Preserve minimum tap target sizing (`context.cupidPlatform.tapTarget`)
  on both tiles even though the design mock's `16px` padding alone may
  fall under platform minimums at small type scales — apply the same
  `BoxConstraints(minHeight: tapTarget)` guard `AntiGhostEntryCard`
  already uses.
- Subtitle `maxLines: 1` + `TextOverflow.ellipsis` so Vietnamese and
  English text of different lengths never wrap and break the fixed
  square tile height.

## 6. Explicitly out of scope for this story (do not implement)

- Dream Jar or Anti-Ghosting tiles staying as full-width entry cards —
  unchanged, not folded into any grid.
- Any live/dynamic Zodiac subtitle content, score, or personalization.
- Any change to `ZodiacRedFlagScreen` itself, its cubit, or its data
  layer — STORY-001's surface, already `DONE`.
- Any change to navigation/tab-bar structure.
