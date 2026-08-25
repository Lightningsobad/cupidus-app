# UX Spec: STORY-004 Home Header — Share Days-Together Action

## What was verified in the current design source before writing this spec

- `cupid-app-design-system/Cupid Screens.dc.html`, `isHome` block, header row
  (lines 238-252): the header top row is
  `display:flex;align-items:center;justify-content:space-between` containing
  the avatar/label group on the left and an actions group on the right
  (`display:flex;align-items:center;gap:2px`). The share action (line 249):
  `<div onClick="{{ goShareDays }}" style="width:var(--tap);height:38px;display:flex;align-items:center;justify-content:center;cursor:pointer"><span data-icon="line" style="font-size:23px;color:var(--tx2)">{{ shareIcon }}</span></div>`.
  `goNotifs` (line 250, STORY-005 scope, not this story) sits immediately
  after it in the same actions group with `justify-content:flex-end` (not
  `center` — do not copy that alignment onto the share icon).
- `shareIcon` binding (line 2052): `shareIcon: isIOS ? 'ios_share' : 'share'`
  — platform-conditional glyph, same token also used by the `waiting`
  screen's share-sheet trigger (line 1285).
- `[data-icon="line"]` (line 16): `font-variation-settings:'FILL' 0,'wght'
  350,'GRAD' 0,'opsz' 24` — the outline (unfilled) glyph variant, not solid.
- Tokens: `--tap` = 44 (`data-plat="ios"`, line 24) / 48
  (`data-plat="md"`, line 25). `--tx2` (dark theme, line 26) = `#B4A6CE`.
- `mobile/lib/design_system/tokens/cupid_platform_tokens.dart`: `tapTarget`
  field already carries the same 44 (`.ios()`) / 48 (`.material()`) values —
  `context.cupidPlatform.tapTarget` is the existing Flutter source for
  `--tap`, already consumed the same way by `CupidHeader`'s back button and
  `CupidAddAction` (`ConstrainedBox(minWidth/minHeight: platformTokens.tapTarget)`).
- `mobile/lib/design_system/tokens/cupid_color_tokens.dart` line 88 (dark):
  `colorTextMuted = Color(0xFFB4A6CE)` — the existing Flutter source for
  `--tx2`.
- `mobile/lib/design_system/icons/cupid_icons.dart` already declares both
  glyphs needed here, pre-existing before this story: `CupidIcons.iosShare`
  (0xe6b8) and `CupidIcons.share` (0xe80d, doc comment: "The non-iOS half of
  the design source's `shareIcon: isIOS ? 'ios_share' : 'share'` branch") —
  no new icon constants need adding.
- `mobile/lib/features/home/presentation/home_screen.dart`: `_PresenceRow`
  (lines 337-341, class at 368+) currently renders only the overlapping
  avatars + couple label inside the hero `Column`; there is no action-icons
  row today, confirming the story's "currently absent" framing. `days` is
  computed as `int?` (line 296-298, `null` when `profile.relationshipStartDate`
  is `null`) and the days-counter/caption/milestone block only renders
  `if (days != null)` (line 342). String pairs in this file use the local
  `_viEn(context, vi, en)` helper (line 56) inline, not ARB keys — matching
  convention to follow for this story's new copy.
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` lines
  56-59, 163-176: the "share-sheet integration pattern" the story/requirement
  names as reuse precedent does **not** invoke an OS native share sheet. Its
  own comment states: *"No `share_plus`-style native-share dependency exists
  in this phase's write scope ... so 'Share invite' and 'Copy code' both
  perform the accessible copy-to-clipboard action."* `mobile/pubspec.yaml`
  confirms no native-share package (`share_plus` or otherwise) is a
  dependency today. See "Known constraint" section below — this is a Tech
  Lead decision, not resolved by this spec.

## 1. Icon placement, sizing, and tokens

Restructure the hero header's top row (currently just `_PresenceRow`) into a
`justify-content:space-between`-equivalent row: `_PresenceRow` on the left,
a new trailing actions row on the right, matching the design source's
`display:flex;align-items:center;justify-content:space-between` container
(line 242). In Flutter terms: wrap the existing `_PresenceRow` and the new
actions row in a `Row` with `mainAxisAlignment: MainAxisAlignment.spaceBetween`
(`_PresenceRow` does not need `Expanded` — the design's avatar/label group is
intrinsically sized, not flex-grown).

Share action button (this story's only header icon):

| Property | Value | Source |
|---|---|---|
| Tap-target width | `context.cupidPlatform.tapTarget` (44 iOS / 48 Android) | `--tap`, line 249 |
| Height | `38` (fixed, both platforms — off `CupidSpacing` scale, literal design px, same precedent as `_trailingGap`/`_avatarOverlap` constants already in this file) | line 249 |
| Content alignment | centered (`justify-content:center`) | line 249 — note this differs from the adjacent `goNotifs` box, which is `flex-end` |
| Icon glyph | `CupidIcons.iosShare` on iOS, `CupidIcons.share` on Android/Material, selected via `CupidPlatform.of(context)` (same pattern as `CupidAddAction`) | line 2052 `shareIcon` binding; both constants pre-exist in `cupid_icons.dart` |
| Icon size | `23` | line 249 `font-size:23px` |
| Icon color | `colors.colorTextMuted` | `--tx2`, line 249 |
| Row gap to the (future, STORY-005) notifications icon | `2` (literal px, off-scale — do not round up to `CupidSpacing.xs` (4)) | line 248 `gap:2px` |
| Tap behavior | `onTap` triggers the share action (§2 below) | — |

The actions row must be structured so STORY-005 can append its notifications
icon as a second child with the same `2`px gap and no rework of this story's
share-icon subtree (e.g. a small reusable row/list rather than a single
bespoke widget hard-coded to exactly one child) — a layout-contract note for
Tech Lead/mobile-dev, not a request to build STORY-005's icon now.

**Accessibility note (recommendation, not a design-source-literal value):**
the icon carries no visible text label. Existing `IconButton` usages in this
codebase (`CupidHeader` back button, `CupidAddAction`) do not set an explicit
`tooltip`/`Semantics` label either, but this is the first *icon-only, no
adjacent title* header action in the app — recommend setting an accessible
label (e.g. `Semantics(label: _viEn(context, 'Chia sẻ số ngày bên nhau',
'Share days together'), button: true, ...)` or `IconButton(tooltip: ...)`) so
screen-reader users can identify the action. This is additive to the visual
spec above, not a substitute for any token value in the table.

**Accessibility trade-off, informational only:** the design source's own
`38`px fixed height is below both platforms' minimum recommended touch
target height (44pt iOS HIG / 48dp Material) even though the *width* meets
it via `--tap`. This exact shortfall already exists identically for the
adjacent `goNotifs` icon in the same design source and is not something this
story introduces or is asked to fix — matching this codebase's established
precedent of literal design-source fidelity (deviations get recorded, not
silently "improved" past the locked source). Flagging for awareness only; no
action required by this spec.

## 2. Share-sheet content

Text is derived directly from data already rendered on Home — no new copy
invented beyond reusing the existing day-count and its existing label
(`ux` in scope per story `In Scope` item 2; `req_master.md`/`story_master.md`
Out of Scope bars custom share-image/card generation, not plain text reuse).

- vi: `"$days ngày bên nhau rồi 💕"`
- en: `"$days days together 💕"`

Where `$days` is the same `int days` already computed and displayed by
`home_screen.dart` (line 296-298), and the label wording ("ngày bên nhau" /
"days together") is copied verbatim from the same file's existing hero label
(line 520), not newly authored.

**Edge case not covered by the story's ACs — UX decision:** `days` is `null`
when `profile.relationshipStartDate` is `null`, and in that state the
counter/caption/milestone pill already do not render at all (`if (days !=
null)`, line 342). There is nothing valid to share in that state. This spec
requires the header share icon to **not render** when `days` is `null`,
matching how the rest of the days-together hero content already conditions
on that same value — rather than rendering a tappable icon that would need
to fabricate or crash on missing data. This keeps AC2 well-defined (the icon
is only ever tappable when a valid day count exists to share) and needs no
separate empty-state design.

## 3. Known constraint — flag for Tech Lead, not resolved here

AC2 requires "the OS share sheet opens" with the shareable text. The story's
own precedent citation (`invite_screen.dart`'s share-sheet integration
pattern) does **not** actually open an OS-native share sheet today — per its
own code comment (quoted above), it performs a clipboard-copy substitute
because no native-share dependency (`share_plus` or a platform channel) is
in that story's write scope, and `pubspec.yaml` confirms none exists in the
app yet. Reusing that *exact* pattern verbatim for STORY-004 would not
satisfy AC2 as literally written (no share sheet actually opens).

This spec provides content for both paths so neither blocks on the other,
but does not choose between them — that is a dependency/scope decision for
Tech Lead (adding a package is outside UX Design's remit):

- **If a native share capability is added** (e.g. `share_plus`, or a
  platform channel invoking `UIActivityViewController` / Android's
  `ACTION_SEND`): pass the §2 vi/en text as the shared plain-text payload,
  selected via the existing `AuthLocaleText(context).viEn(...)` /
  `_viEn(context, ...)` locale mechanism already used in this file. No
  subject line, link, or image — matches Out of Scope's "no custom share
  image/card" bar.
- **If Tech Lead instead scopes this story to the same clipboard-copy
  substitute `invite_screen.dart` uses** (no share sheet actually opens):
  the same §2 text is the clipboard payload, and the accessible-announcement
  copy should read `_viEn(context, 'Đã sao chép để chia sẻ',
  'Copied to share')` — reusing `invite_screen.dart`'s own announcement copy
  verbatim (line 175) for consistency. In that case AC2's literal "OS share
  sheet opens" wording would not be met as written, and Tech Lead/Scrum
  Master should decide whether to escalate an AC wording correction to
  Product Owner rather than silently reinterpreting it during
  implementation.

Either path satisfies AC3 (dismiss/cancel without selecting a target must
not error or crash): `share_plus`'s `Share.share()` future resolves silently
on dismiss, and the clipboard-copy substitute path has no cancellable
system UI at all.

## 4. Scope boundary — what this spec does NOT cover

- The `goNotifs` icon, its badge dot, and its own tap behavior — STORY-005,
  a separate story per `req_master.md`'s Product Owner Story Breakdown
  Decision.
- Adding `share_plus` (or any) native-share dependency to `pubspec.yaml`,
  or a platform-channel implementation — Tech Lead/dev decision per §3.
- Any custom share-image/card rendering — explicitly Out of Scope in
  `story_master.md`.
- The `invite_screen.dart` "Share invite" flow itself — read only as
  precedent context, not modified by this story.
