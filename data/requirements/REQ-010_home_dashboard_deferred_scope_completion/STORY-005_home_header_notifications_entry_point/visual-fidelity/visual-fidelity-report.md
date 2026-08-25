VISUAL_FIDELITY: PASS

# Visual Fidelity — STORY-005 Home Header Notifications Entry Point

## Scope Of This Comparison

Story-scoped: the Home dashboard header's `goNotifs` action only (icon glyph,
variant, size, colour, trailing alignment inside the tap target, and the unread
indicator dot). The rest of the Home screen is pre-existing surface delivered by
earlier stories and is not re-litigated here.

## Design Screen Resolution

- `Design-Screen: home`
- Resolved from `data/devops/system/design-fidelity-config.json`
  (`design_source.location: cupid-app-design-system`, `screens_from: dom`).
- Confirmed by the `isHome` block in `Cupid Screens.dc.html` lines 247-250,
  which is the exact `goNotifs` markup quoted in this story's
  `ux/uiux-spec.md`. The rendered canvas for that id reproduces the same
  header (overlapping avatar pair, `Minh`, couple-type line, days counter,
  milestone pill), so the id maps to the screen under change.

## Artifacts

- Design reference: `design-reference-home-android.png` (406x900)
- Implemented: `implemented-home-android.png` (405x900)
- Device: `emulator-5554` (Android), display width capped by the capture tool.
- Implemented state was faked, not driven: launched from
  `lib/main_preview.dart` with `--dart-define=PREVIEW=home` and
  `--dart-define=PREVIEW_HOME_FIXTURE=true`, which pins the dark theme, the
  `vi` locale, and the authored profile fixture (Minh / 247 days /
  `SAME_CITY` / paired). No login, no navigation, no live network.

## Compared Deltas

| Property | Design source | Implemented | Verdict |
| --- | --- | --- | --- |
| Glyph | `notifications`, line/outline weight | `CupidIcons.notifications`, `CupidIconVariant.line` | match |
| Icon size | `font-size:24px` | `24` logical px | match |
| Icon colour | `var(--tx2)` (muted text) | `colors.colorTextMuted` | match |
| Tap target | `width:var(--tap); height:38px` | `SizedBox(width: context.cupidPlatform.tapTarget, height: 38)` | match |
| Glyph alignment in target | `justify-content:flex-end` | `Stack(alignment: Alignment.centerRight)` | match |
| Header axis | header becomes `space-between` | `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)` | match |
| Dot size | `8px`, `border-radius:50%` | `8` logical px, `BoxShape.circle` | match |
| Dot position | `top:4px; right:1px` | `Positioned(top: 4, right: 1)` | match |
| Dot colour | `var(--pink)` | `colors.colorAccentPink` | match |
| Dot glow | `box-shadow: 0 0 9px var(--pink)` | `BoxShadow(color: colorAccentPink, blurRadius: 9)` | match |
| Theme / locale | dark, `vi` | dark, `vi` | match |

Both crops of the header's trailing region show the same outline bell with the
same pink indicator disc tucked against its top-right corner and the same soft
pink halo around that disc.

## Known Non-Deltas (out of this story's scope)

- The design reference also shows the `goShareDays` share glyph immediately
  left of the bell. That action is STORY-004's scope and is deliberately absent
  here; adding it would put this story outside its declared write scope.
- The design reference is rendered inside a mocked device frame and therefore
  carries a simulated status bar, so absolute vertical offsets between the two
  images differ by the frame's chrome. Comparison was made against the header
  block, not against image-absolute coordinates.
- The Anti-Ghosting card's subtitle/chevron state differs between capture runs
  because the emulator's backend `GET /users/me` call fails offline. That is
  pre-existing Home behaviour, untouched by this story.

## Capture Note

The first capture of this story rendered the header without the bell. Root
cause was an APK on the device that predated the change, not a layout or font
defect: the local build artifact had been rebuilt but never reinstalled. The
capture script now runs `adb install -r` from this worktree's
`app-local-debug.apk` inside the same device-lease window as the screenshot,
which is what the artifact above was produced with.
