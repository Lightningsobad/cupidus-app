# Visual Fidelity Report — STORY-012 Join / Enter Pairing Code

Story: STORY-012 (REQ-002, Scope B, trivial, mobile lane)
Screen: `joincode` (Epic 1, NO_TABS)
Implementation file: `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`
Design source (locked): `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isJoinCode }}">` block, lines 1550-1570
Configuration audited: dark theme + `vi` locale (the enabled combination)

Token mapping used throughout (design CSS var -> Flutter token):

| Design var | Flutter token |
| --- | --- |
| `--bg` | `CupidColorTokens.colorBackground` |
| `--surf` | `CupidColorTokens.colorSurface` |
| `--line` | `CupidColorTokens.colorLine` |
| `--tx2` | `CupidColorTokens.colorTextMuted` |
| `--pink` | `CupidColorTokens.colorAccentPink` |
| `--purple` | `CupidColorTokens.colorAccentPurple` |
| `--glow` | `CupidColorTokens.glowShadow` |
| `16px` input radius | `CupidPlatformTokens.radiusSmall` (16) |
| `Nunito 900` | `CupidTypographyTokens.display` |
| `13px` sub-copy | `CupidTypographyTokens.caption` (13) |
| `'Roboto Mono'` | `CupidTypographyTokens.labelMono` |

## Deviations found and fixed

### D1 — Screen heading missing (design line 1553)

Design source renders an in-body heading `Nhập mã của người ấy` /
`Enter their code` at `font-family:Nunito;font-weight:900;font-size:25px;
line-height:1.25`, centered. The app rendered no in-body heading at all — only
the `CupidHeader` app-bar title.

Fix: added a centered `Text` using
`type.display.copyWith(fontSize: 25, height: 1.25, color: colors.colorText)`.
The app-bar title stays `Nhập mã ghép đôi` / `Enter pairing code`, which matches
the design source's own `t_joincode` chrome label (line 1770/1782) — the two
strings are intentionally distinct in the design source.

### D2 — Sub-copy missing (design line 1554)

Design source renders `font-size:13px;line-height:1.6;color:var(--tx2);
margin-top:9px;max-width:280px`, centered. The app rendered nothing.

Fix: added a centered `Text` in a `ConstrainedBox(maxWidth: 280)` using
`type.caption.copyWith(height: 1.6, color: colors.colorTextMuted)`, preceded by
`SizedBox(height: CupidSpacing.sm)` (8; nearest token to the design's 9px on the
8pt grid documented in `CupidSpacing`).

Copy adaptation: the design source string says `mã 8 ký tự` / `8-character
code`. The shipped app issues and accepts **6-character** codes
(`JoincodeScreen` `maxLength: 6`; `InviteScreen` renders `Mã 6 ký tự`; the
repository test asserts a 6-hex code). Code length is pairing business logic and
is explicitly out of this story's scope, so the sub-copy was transcribed with
`6` instead of `8` to stay truthful to the shipped behaviour. Flagged below as
an open item for the Product Owner rather than silently changed either way.

### D3 — Code entry rendered as a bare underline field (design lines 1555-1562)

Design source renders the code slots as boxes: `background:var(--surf)`,
`border:1.5px solid var(--line)`, `border-radius:16px`, with the active slot
switching to `border:1.5px solid var(--pink)` plus `box-shadow:var(--glow)`.
The app used a default Material 3 `InputDecoration`, i.e. a filled-grey
underline field with a floating label and the stock `primary` focus underline —
no surface fill, no 16px rounded outline, no `--line` border.

Fix: `InputDecoration` now sets `filled: true`, `fillColor: colors.colorSurface`
and an `OutlineInputBorder` at `platformTokens.radiusSmall` with a 1.5px side
per state, built once by the new `_codeFieldBorder` helper:

- `enabledBorder` / `disabledBorder`: `colors.colorLine`
- `focusedBorder`: `colors.colorAccentPink`
- `errorBorder` / `focusedErrorBorder`: `colors.colorRed`

`contentPadding` is `CupidSpacing.md` (16) on both axes, which lands the field
at roughly the design's 56px slot height.

### D4 — Code entry typography off the design source (design line 1556)

Design source: `font-family:'Roboto Mono';font-weight:500;font-size:21px`.
The app used `labelMono` (weight 400) at `fontSize: 28`.

Fix: `type.labelMono.copyWith(fontWeight: FontWeight.w500, fontSize: 21, ...)`.
`letterSpacing: 8` is retained from the pre-existing implementation — it is the
single-field stand-in for the design's 9px inter-slot gap and is not a design
value being changed by this story.

### D5 — Floating label chrome absent from the design source

With D3/D4 applied, the Material floating `labelText`
(`Mã ghép đôi (6 ký tự)`) was chrome the design source's slot row does not have.

Fix: `labelText` removed. The field's accessible name is now carried by
`hintText` (`Mã ghép đôi` / `Pairing code`), styled in muted mono so it reads as
placeholder rather than as a label, and the D1 heading names the field visually.
The inline rejection line stays attached to the field through `errorText`
(uiux-spec §9: error tied to the field by description, not colour alone), now
styled `type.caption.copyWith(color: colors.colorRed, height: 1.6)` instead of
inheriting the stock Material error style.

### D6 — Uniform 24px page padding vs the design's bottom-weighted padding

Design source container: `padding:20px 20px 40px`. The app used
`EdgeInsets.all(CupidSpacing.lg)` (24 on all four sides).

Fix: `EdgeInsets.fromLTRB(lg, lg, lg, xl)` — 24/24/24/32, the nearest
`CupidSpacing` values preserving the design's larger bottom inset. Exact 20/40
values are off the documented 8pt token scale and were not hard-coded.

### D7 — Busy spinner inherited the stock indicator colour

The in-CTA `CircularProgressIndicator` had no colour, so it resolved to the
theme `primary` (`colorAccentPink`) on top of the pink CTA — effectively
invisible.

Fix: `color: colors.colorText`, matching `CupidPrimaryButton`'s
`foregroundColor`. The `Stack` layout is unchanged, so the existing
no-layout-shift assertion still holds.

## Code-entry state audit (AC3)

| State | Design source | Rendered after fix |
| --- | --- | --- |
| Empty | Not rendered as a distinct state in the mock; slot boxes are `--surf` + `--line` | `--surf` fill, 1.5px `--line` outline at radius 16, muted-mono hint |
| Partial / focused | Active slot: `--pink` border + `--glow` | Focused border `colorAccentPink` 1.5px; mono w500 21 retained |
| Error / invalid | Not rendered in the mock | `errorBorder` / `focusedErrorBorder` `colorRed` 1.5px + caption-role `colorRed` message, derived from the same token family |

Empty and error slot states have no dedicated render in the locked design
source, so they are derived from the mock's box treatment plus the shared token
roles rather than invented.

## Confirmed already matching (no change needed)

- `Scaffold.backgroundColor` = `colors.colorBackground` = design `--bg`.
- App-bar title copy matches the design source's `t_joincode` for both locales.
- Back target: design `BACK_TO.joincode = 'invite'` (line 1853); the screen pops
  to its pusher, which is `invite`. Navigation correctness is Scope A's.
- `NO_TABS` (design line 1952): screen has no tab bar.
- Gap between the code entry and the primary CTA: `CupidSpacing.lg` (24) already
  matched the design's stacked 24px rhythm.

## Deviations NOT fixed — outside this story's write scope

These are real, still-visible deviations. They could not be corrected inside
`joincode_screen.dart` alone and are reported for Scrum Master routing rather
than silently worked around.

1. **Hero icon badge missing** (design line 1552): `78x78`, `border-radius:28px`,
   `background:rgba(183,140,245,.2)` (= `--purple` at 20%), containing the
   Material Symbols `link` glyph at `38px` in `--purple`.
   Blocker: `CupidIcons` has no `link` constant, and
   `mobile/lib/design_system/icons/cupid_icons.dart` is outside this story's
   declared `WriteScope`. The design-system contract also requires the codepoint
   be read from the bundled `MaterialSymbolsRounded-Variable.ttf` cmap, not
   asserted from memory. Declaring an inline `IconData` in feature code would
   fork the icon layer. Needs a design-system-layer change.
2. **Primary CTA styling is design-system-wide, not screen-local** (design line
   1567): design specifies `height:54px`, `background:var(--grad-hot)`,
   `color:#fff`, `font-size:16.5px`, `font-weight:800`, `box-shadow:var(--glow)`.
   `CupidPrimaryButton` currently renders a solid `colorAccentPink` fill at
   `tapTarget` height (48) with `type.body` (17 / w400) and `elevation: 2`, and
   no glow. Changing it affects every screen that uses the shared CTA, so it
   belongs to a design-system-level story, not to this trivial single-screen fix.
3. **Secondary actions absent** (design lines 1564-1565): `Dán` / `Paste` and
   `Quét QR` / `Scan QR` outline buttons. These require clipboard and camera
   capability, i.e. new interactions — out of scope per this story's Out of Scope
   and the handoff's "do not touch business logic".
4. **`Tôi mới là người tạo mã →` cross-link absent** (design line 1568): an
   inter-screen navigation affordance to `invite`. Scope A (STORY-001/STORY-002)
   owns inter-screen navigation.
5. **Code length copy 8 vs 6** (design line 1554, and `CPD-8F2K` on the waiting
   screen at line 1583): the design source assumes an 8-character code; the app
   issues 6. Product Owner decision needed on which is canonical. No visual fix
   applied here beyond the truthful `6` in the sub-copy (see D2).

## Verification evidence

Flutter SDK: `/Users/alantravala/flutter/bin/flutter` (not on the default
`PATH`; invoked with an explicit `PATH` prefix).

- `flutter analyze lib/features/pairing test/features/pairing` — 9 issues, all
  pre-existing `prefer_initializing_formals` **info** lints in files this story
  did not change in that respect; **0 errors, 0 warnings, 0 new issues**.
  A whole-project `flutter analyze` additionally reports pre-existing
  `uri_does_not_exist` / `AppL10n` errors from the un-generated
  `lib/l10n/generated/app_l10n.dart`; that baseline failure is unrelated to this
  story and untouched by it.
- `flutter test test/features/pairing test/design_system` — **+106 All tests
  passed**, including:
  - `test/features/pairing/presentation/joincode_screen_test.dart` (7
    pre-existing behavioural tests, unmodified, still green)
  - `test/design_system/no_fork_guard_test.dart` (confirms the screen still
    contains no raw colour literal or platform branch)
  - `test/features/pairing/presentation/screens/joincode_screen_design_test.dart`
    (new, 4 tests: heading/sub-copy typography roles, empty-state box tokens,
    partial-entry mono treatment, error-state danger tokens)

No device install, emulator, or release configuration was involved.
