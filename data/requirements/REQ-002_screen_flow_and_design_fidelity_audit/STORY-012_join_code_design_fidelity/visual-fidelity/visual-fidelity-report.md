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

## Rendered evidence and side-by-side verdict (F1)

Round 1 asserted fidelity from widget-tree metrics only. Both sides have now
been rendered and visually compared.

| Artifact | File | How produced |
| --- | --- | --- |
| Design source | `visual-fidelity/design-reference-joincode-android.png` | `Cupid App.dc.html` served over `http://127.0.0.1` (the `dc-import` of `Cupid Screens` fetches `./Cupid Screens.dc.html`, which a `file://` origin blocks), driven headless with Playwright/Chromium: click `[data-screen-btn="joincode"]`, then element-screenshot `[data-plat="md"]` — the `AndroidDevice` frame, Pixel 6 412x915, `theme=dark`, `lang=vi`, DPR 2.625. |
| Implemented | `visual-fidelity/implemented-joincode-emulator-5554.png` | `flutter build apk --debug -t lib/main_preview.dart`, installed on `emulator-5554`, deep link `cupidpreview://screen/joincode`, `adb exec-out screencap -p`. 1080x2400, dark, `vi`, debug banner off. |

The two renders are directly comparable: 412x915 logical vs 411x914 logical.

### Verdict

**The screen does not yet match the design source.** The typography and colour
tokens are exact, but three of the design's five content blocks are absent and
the page's vertical composition differs. Under AC1 ("match exactly") this
screen is NOT MET at requirement level; it is met only for the subset the
story's `WriteScope` could reach.

| Design element | Design render | Implemented render | Verdict |
| --- | --- | --- | --- |
| App bar (back + `Nhập mã ghép đôi`) | pink back chevron, title sits on the page's own gradient, no seam | white back chevron on a flat surface bar with a hard bottom edge | DEVIATION — see N3 |
| Page background | vertical gradient (purple top -> near-black bottom) plus faint drifting particles | flat `--bg`, no gradient, no particles | DEVIATION — see N2 |
| Vertical composition | content flows from the top (line 1551 sets `padding:20px 20px 40px` with no `justify-content`) | column is vertically centred; ~27% of the viewport is empty between the app bar and the heading | DEVIATION — see N1 |
| Hero icon badge 78x78 r28 + `link` glyph | present | absent | NOT FIXED — item 1 |
| Heading (Nunito 900 / 25 / 1.25 / `--tx`) | present | present, visually identical | MATCH |
| Sub-copy (13 / 1.6 / `--tx2`, one line) | `...mã 8 ký tự...` | `...mã 6 ký tự...`, one line, same size/colour/leading | MATCH except the 8-vs-6 count (item 5) |
| Code entry | 5 slot boxes 46x56 r16 + `–` separator, active slot pink + `--glow`, caret slot | one full-width rounded field with a letter-spaced `Mã ghép đôi` hint | ACCEPTED DEVIATION — item 6 |
| `Dán` / `Quét QR` row | two outlined pill buttons with icons | absent | NOT FIXED — item 3 |
| Primary CTA | full-width 54px pill, `--grad-hot` pink->purple gradient, `--glow`, 16.5/800 white | full-width pill, flat `--pink`, no gradient, no glow, lighter weight | NOT FIXED — item 2 |
| `Tôi mới là người tạo mã ->` cross-link | present, pink 13/700 | absent | NOT FIXED — item 4 |

The grid button floating bottom-right of the design render is the DesignCode
canvas navigator, not part of the screen.

N1, N2 and N3 are new findings that the metric-only round-1 audit could not
have surfaced; they are recorded in "Deviations NOT fixed" below.

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

## Deviations NOT fixed

These are real, still-visible deviations, each carrying an explicit ask for
Scrum Master routing. Items 1-5 were filed in round 1; items 6-9 were added in
round 2 after the renders above. Most need a file outside this story's
`WriteScope`; item 7 (N1) is the exception — it sits in `joincode_screen.dart`
and is unfixed only because round 2 forbade touching that file.

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
3. **Secondary actions absent — ESCALATION ASK, not an out-of-scope exclusion**
   (design lines 1564-1565): the `Dán` / `Paste` and `Quét QR` / `Scan QR`
   outline buttons (`flex:1`, `height:48px`, `--r-btn`, `1.5px --line`, 14/700).
   Round 1 filed these as "out of scope per this story's Out of Scope". That
   framing was wrong and is withdrawn: AC1 asks this screen to match the design
   source, and two of the source's five content blocks are missing, so AC1
   cannot be closed by declaring them out of scope. What is true is narrower —
   they cannot be built inside this story's `WriteScope`, because the buttons
   are only shells without clipboard read and a camera/QR scanner, which means
   new plugin dependencies, `pubspec.yaml`, and Android/iOS permission manifest
   entries. `ux/uiux-spec.md` §9 already assumes they exist ("All tap targets
   (Share, Copy, **Paste, Scan QR**, Pair up) meet the existing `--tap`
   minimum"), so the UX contract expects them too.
   **Ask:** Scrum Master to route a follow-up story (mobile + devops lanes,
   clipboard + camera capability) before REQ-002 integration review closes, or
   to have Product Owner record an explicit decision that `joincode` ships
   without them — in which case the design source should be amended so it stops
   being the standing reference for a screen nobody intends to build.
4. **`Tôi mới là người tạo mã →` cross-link absent — ESCALATION ASK, not an
   out-of-scope exclusion** (design line 1568): 13/700 `--pink`, `margin-top:14px`,
   navigating to `invite`. Round 1 filed this as owned by Scope A
   (STORY-001/STORY-002) and stopped there. Ownership is a routing fact, not a
   closure: the affordance is still missing from the delivered screen, so AC1
   stays open on it. It is also the only in-app path back to `invite` for a user
   who opened `joincode` by mistake, which makes it a flow gap and not only a
   fidelity gap.
   **Ask:** Scrum Master to confirm which REQ-002 story owns this link and to
   verify it actually lands there. If Scope A's navigation stories have already
   passed review without it, this needs its own story rather than being assumed
   covered.
5. **Code length copy 8 vs 6** (design line 1554, and `CPD-8F2K` on the waiting
   screen at line 1583): the design source assumes an 8-character code; the app
   issues 6. Product Owner decision needed on which is canonical. No visual fix
   applied here beyond the truthful `6` in the sub-copy (see D2).
6. **Segmented code row rendered as one field — ACCEPTED DEVIATION** (design
   lines 1555-1561). The design source draws the entry as a `gap:9px` row of
   `46x56` boxes, `border-radius:16px`, `--surf` fill, `1.5px --line` border,
   `'Roboto Mono' 500 21px`, with a `–` separator mid-row, the active box
   switching its border to `--pink` and gaining `box-shadow:var(--glow)`, and a
   trailing caret box at weight 400 in `--pink`. The implementation renders a
   single full-width `TextField` carrying those same tokens.
   This one is accepted rather than escalated. `ux/uiux-spec.md` §9 (REQ-001
   STORY-005 pairing spec) is explicit: the code "must be exposed to assistive
   tech as a single accessible string ... not as visually-fragmented
   per-character elements — this applies both to the `invite` screen's code
   display and the `joincode` screen's digit-entry boxes, **which should be
   backed by a single accessible text field rather than six independently-
   focusable visual boxes**." Six real input widgets would violate that
   directly, and would also break the paste path §9 assumes.
   Two things are worth being precise about, because the round-1 D3 entry read
   as if the design intent had been fully delivered:
   - §9 constrains the *semantics*, not the *painting*. A faithful
     implementation would paint the six slots over the single accessible field
     (a custom `TextField` decoration or a `Stack` of slot boxes driven by the
     controller). That is a real, buildable option and it was not attempted.
     What shipped is the cheaper reading of §9, so the visual gap is a genuine
     shortfall against AC1, merely one with an accessibility justification for
     deferring rather than a blocker.
   - Two token-level details are consequently unimplemented and were not listed
     in round 1: the active slot's `box-shadow:var(--glow)`
     (`CupidColorTokens.glowShadow`, mapped in the table above but never
     applied), and the caret slot's `font-weight:400` in `--pink` against the
     `500` used by filled slots.
   **Ask:** treat this as accepted for STORY-012, and let requirement
   integration review decide whether the painted-slot version is worth a
   follow-up story. It must not be read as "the code row matches the design".
7. **N1 — Content is vertically centred instead of top-aligned** (design line
   1551). The source container is
   `padding:20px 20px 40px;display:flex;flex-direction:column;align-items:center;text-align:center`
   — no `justify-content`, so content starts at the top of the scroll area. The
   implementation wraps the column in `Center` inside the scroll view, which on
   a 411x914 device leaves roughly a quarter of the viewport empty between the
   app bar and the heading (visible in both renders). This is the single most
   noticeable difference between the two images.
   Not fixed because `joincode_screen.dart` is outside the round-2 patch
   mandate ("no code change to `joincode_screen.dart` is required or
   permitted"). The fix itself is small — top-align the column and keep the
   scroll view for small viewports.
   **Ask:** Scrum Master to decide whether this is a follow-up story or a
   lightweight amendment to STORY-012's own scope. Note that the empty gap is
   partly a consequence of items 1, 3 and 6: with the hero badge, the segmented
   row and the secondary-action row restored, top alignment is what the design
   actually depends on.
8. **N2 — Page background gradient and particles absent** (design source page
   background, shared across screens). The design render shows a vertical
   gradient from a purple-tinted top to near-black at the bottom, plus faint
   drifting particle dots. The implementation paints flat `--bg`.
   This is a design-system-level surface, not a `joincode` concern — every
   REQ-002 screen inherits it. Fixing it inside one feature screen would fork
   the background layer.
   **Ask:** route to the same design-system story that owns item 2
   (`CupidPrimaryButton` gradient/glow); both are `--grad-*`/backdrop concerns.
9. **N3 — App bar is a flat opaque bar with a hard seam** (design source header
   band). In the design the header blends into the page background and the back
   chevron is `--pink`; the implementation uses an opaque surface `AppBar` with
   a visible bottom edge and a white chevron.
   Same ownership as N2 — the app-bar theme is shared, not screen-local.
   **Ask:** fold into the design-system story with N2 and item 2.

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
- `flutter test test/features/pairing test/design_system` — **+107 All tests
  passed** (round 1: +106; +1 from the new sub-copy width case), including:
  - `test/features/pairing/presentation/joincode_screen_test.dart` (7
    pre-existing behavioural tests, unmodified, still green)
  - `test/design_system/no_fork_guard_test.dart` (confirms the screen still
    contains no raw colour literal or platform branch)
  - `test/features/pairing/presentation/screens/joincode_screen_design_test.dart`
    (5 tests: heading/sub-copy typography roles, sub-copy width against the
    design's 280px column, empty-state box tokens, partial-entry mono
    treatment, error-state danger tokens)

### Round-2 correction: the test harness now renders the audited configuration

Round 1 claimed a dark + `vi` audit but its `_harness()` pinned neither, so
`MaterialApp` fell back to `en` and the assertions ran against English copy —
the audited configuration was never actually exercised. The harness now sets
`locale: const Locale('vi')` **and** `supportedLocales: [Locale('vi'),
Locale('en')]` (`WidgetsApp` resolves `locale` against `supportedLocales`, so
the locale alone would still have fallen back), plus
`GlobalMaterialLocalizations.delegates` from `flutter_localizations`, which
`DefaultMaterialLocalizations` cannot supply for a non-`en` locale. All copy
assertions were flipped to the Vietnamese strings the screen really renders.

`AppL10n.localizationsDelegates` was deliberately *not* used here: importing it
would pull `lib/l10n/generated/app_l10n.dart` into this test's analysis, and
that generated file is absent, which is the pre-existing whole-project
`flutter analyze` failure noted above. `pairing_strings.dart` resolves its copy
from `Localizations.localeOf(context).languageCode` rather than from the ARB
pipeline, so the ambient locale is the only input that matters.

One assertion was deliberately *not* tightened. The vi sub-copy line count is
not asserted, because `flutter test` substitutes a fixed-advance test font
where every glyph is `fontSize` wide; that font measures this string at ~3 line
boxes, while `implemented-joincode-emulator-5554.png` shows it on one line at
411dp with the real font. Only the 280px width bound and the absence of an
overflow are font-independent, so only those are pinned.

### Device evidence

Round 1 reported "no device install, emulator, or release configuration was
involved". That is no longer true and was the reason AC1 could not be judged.
Round 2 built and installed a debug preview APK on `emulator-5554` and captured
the screen; see "Rendered evidence and side-by-side verdict" above for both
artifacts and the method. Release configuration and signing were not involved.
