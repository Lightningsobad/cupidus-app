# Visual Fidelity Report: STORY-015 Love Contract

Story: STORY-015 Design Fidelity — Love Contract (REQ-002, Scope B)
Screen: `contract` (Love Contract), NO_CHROME / NO_TABS
Implementation file: `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
Configuration audited: enabled dark theme + `vi` locale

## Design Source

Locked reference: `cupid-app-design-system`
Exact block: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isContract }}">` at lines 121-166.
Design CSS variables read from the same file: `[data-plat]` (line 23),
`[data-plat="md"]` (line 25), `body[data-theme="dark"]` (line 26).

## Token Mapping Policy Used

The Flutter token layer (`CupidSpacing`, `CupidTypographyTokens`,
`CupidPlatformTokens`, `CupidColorTokens`) is the codified form of the design
source. Where the design source's raw CSS px falls between token steps, the
implementation snaps to the nearest token step. Where the design source
specifies a structural property that has no token (gradient header fill,
dashed separators, single-card composition, alpha values, alignment, icon
presence), the implementation reproduces the design source value directly.

## Deviations Found And Fixed

### D-1 — Screen was three loose blocks, design is one unified card
- Design source (line 123): a single `background:var(--surf);
  border-radius:var(--r-card); overflow:hidden; box-shadow:var(--shadow)`
  card that contains header, clause list, and sign section.
- Before: a header `Container` card, then clause rows rendered bare on the
  screen background, then the sign section bare on the background.
- Fix: all three sections now live inside one `Container` with
  `colors.colorSurface`, `platformTokens.radiusCard`,
  `platformTokens.elevationShadow` (`--shadow`), and
  `clipBehavior: Clip.antiAlias` (`overflow:hidden`).

### D-2 — Missing dashed section separators
- Design source (lines 124, 144): `border-bottom:1px dashed var(--line)` under
  the header and `border-top:1px dashed var(--line)` above the sign section.
- Before: no separators at all; sections were visually detached instead.
- Fix: added `_DashedRule`, a 1px dash/gap run painted with
  `colors.colorLine`, between header/clause list and clause list/sign section.
  Flutter has no dashed `BorderSide`, so the rule is painted directly.

### D-3 — Header had no gradient wash
- Design source (line 124): `background:linear-gradient(135deg,
  rgba(255,75,140,.18), rgba(123,47,190,.18))`.
- Before: header used the flat card surface colour.
- Fix: `LinearGradient(topLeft -> bottomRight)` from
  `colorAccentPink.withValues(alpha: 0.18)` to
  `colorAccentPurple.withValues(alpha: 0.18)`, i.e. the design's 135deg
  pink/purple wash expressed through the accent tokens so it stays correct in
  all 4 theme x platform combinations.

### D-4 — Sequence label rendered at the wrong size, tracking and case
- Design source (line 125): `font-family:'Roboto Mono'; font-size:10px;
  letter-spacing:.18em; text-transform:uppercase; color:var(--pink)`.
- Before: `type.labelMono` with `letterSpacing: 1.2` and no `fontSize`.
  `labelMono` intentionally carries no size, so the label inherited the
  ambient ~14px body size — visibly larger than the design's 10px micro-label,
  with the wrong tracking and no uppercase transform.
- Fix: `fontSize: 10`, `letterSpacing: 1.8` (`.18em` of 10px), and
  `.toUpperCase()` on the rendered string. Colour was already
  `colorAccentPink` and is unchanged.

### D-5 — Contract title had no line-height compression
- Design source (line 126): `font-weight:900; font-size:30px; line-height:1.1`.
- Before: `type.display` with default line height.
- Fix: added `height: 1.1`. Size/weight stay on the `display` token
  (Nunito w900), which is the design system's codified contract-title role.

### D-6 — Header inner rhythm was half the design's
- Design source (lines 126-127): `margin-top:8px` under the sequence label and
  `margin-top:7px` under the title.
- Before: `CupidSpacing.xs` (4) after both.
- Fix: `CupidSpacing.sm` (8) after both.

### D-7 — Duplicated plus glyph on the add-clause affordance
- Design source (line 142): one `+` span at 18px followed by the label text.
- Before: `TextButton.icon` with `Icon(CupidIcons.add)` *plus* the localized
  label, which already embeds a leading plus in both locales
  (`vi`: `+ Thêm điều khoản riêng`, `en`: `+ Add our own clause`). The screen
  therefore rendered two plus marks side by side.
- Fix: dropped the redundant icon and kept the localized label alone, so a
  single leading plus renders. Weight raised to `w600` per the design's
  `font-weight:600`. Enabled/disabled colours (`colorAccentPink` /
  `colorGhost`) are unchanged, and the widget stays a `TextButton` with the
  same key so the existing 20-clause cap test keeps passing.

### D-8 — Add-clause row sat outside the clause list block
- Design source (lines 129-143): the add-clause row is the last child of the
  `padding:8px 8px 4px` clause list block, not a detached control.
- Before: it was separated from the clause rows by an extra `xs` spacer and
  rendered outside any container.
- Fix: it is now the final child of the clause list section, whose padding is
  `fromLTRB(sm, sm, sm, xs)` = 8/8/8/4, matching the design exactly.

### D-9 — Sign caption was only shown in the unsigned states
- Design source (line 145): the caption `Giữ ngón tay để ký — cam kết thì phải
  nặng tay một chút` sits *outside* the `mySigned` / `myUnsigned` `sc-if`
  pair, so the design renders it for the signed states as well.
- Before: the caption lived inside `_SignPromptSection` and disappeared once
  the viewer had signed, leaving the signed card flush against the separator.
- Fix: the caption is hoisted into the shared sign section above the
  state-specific control, with `margin-bottom:14px` mapped to
  `CupidSpacing.md`. This is a deliberate match to the locked design source,
  not an added element.

### D-10 — Signed card used the wrong tint, border and layout
- Design source (lines 147-150): `background:rgba(0,201,167,.12);
  border:1px solid rgba(0,201,167,.4); height:64px;
  flex-direction:column; align-items:center; justify-content:center; gap:2px`,
  first line `font-size:15px; font-weight:700; color:var(--green)` prefixed
  with `✓`, second line `font-size:11.5px; color:var(--tx2)`.
- Before: `colorGreen.withValues(alpha: 0.16)` fill, a full-opacity
  `colorGreen` border, a left-aligned `Row` with a `check_circle` glyph, and a
  `cardTitle` (22px) heading painted `colorText` instead of green.
- Fix: fill `alpha: 0.12`, border `colorGreen.withValues(alpha: 0.4)`,
  `BoxConstraints(minHeight: 64)`, centred `Column` with a 2px gap, heading
  switched to `type.body` + `w700` + `colorGreen`, and the glyph switched to
  the shared `CupidIcons.check` at 18px in `colorGreen` inline with the
  heading. `minHeight` is used instead of a fixed height so long partner
  display names wrap instead of overflowing.

### D-11 — Footer lock note had no lock glyph
- Design source (line 164): `<span data-icon style="font-size:15px;
  color:var(--mint)">lock</span>` with `gap:7px`, centred, next to the note.
- Before: the note rendered as a bare centred `Text`.
- Fix: centred `Row` with `Icon(CupidIcons.lock, size: 16,
  color: colors.colorMint)`, `CupidSpacing.sm` gap, and the note in a
  `Flexible` so it still wraps.

### D-12 — Screen padding did not follow the design's asymmetric block
- Design source (line 122): `padding:18px 16px 40px`.
- Before: uniform `EdgeInsets.all(CupidSpacing.md)` (16 on all sides), so the
  scroll body ended flush against the bottom edge.
- Fix: `fromLTRB(md, md, md, xl)` = 16/16/16/32, the nearest token snap to the
  design's 16/18/16/40 block.

### D-13 — Sign-action error banner floated outside the card
- Design source: has no equivalent element (see A-3 below).
- Before: the banner rendered between the add-clause row and the sign control
  on the bare background.
- Fix: moved inside the card's sign section, above the caption, so the card
  chrome stays unbroken in the error case. Its own styling
  (`colorSurfaceAlt`, `radiusCard`) is unchanged.

## Per-State Fidelity (AC3)

Design source models two viewer sign states (`mySigned` at line 146,
`myUnsigned` at line 152). The app carries the REQ-001 STORY-019 four-way
`ContractSignStatus`, which maps onto them as follows.

### Unsigned (`ContractSignStatus.unsigned`)
Maps to the design's `myUnsigned` branch. Renders the shared sign caption
(D-9) followed by `HoldToSignButton`. Card chrome, separators, header wash and
footer lock row all match. Verified by
`unsigned state shows the sign caption above the hold control`.

### Self-signed / awaiting partner (`ContractSignStatus.signedByMe`)
Maps to the design's `mySigned` branch. Renders the corrected green card
(D-10): `colorGreen` @ 12% fill, `colorGreen` @ 40% hairline,
`radiusCard`, 64px minimum height, centred check + `Bạn đã ký` heading in
`colorGreen`/`w700`, `Đang chờ đối tác ký` status line in `caption` /
`colorTextMuted`. No sign control is offered. Verified by
`self-signed state renders the signed card with the design source green tint,
40% green hairline, card radius and 64px minimum height`.

### Both signed (`ContractSignStatus.bothSigned`)
Also maps to the design's `mySigned` branch — the design swaps only the second
line (`partnerSignStatus`). Card treatment is byte-identical to the self-signed
state; only the status line changes to `Cả hai đã ký`. Verified by
`both-signed state reuses the same signed-card treatment and swaps only the
status line`.

### Partner already signed (`ContractSignStatus.partnerAlreadySigned`)
App-only fourth state from REQ-001 STORY-019 (ADR-019e); the design source has
no separate branch for it. It renders the design's `myUnsigned` control, with
the acknowledgment line above the shared caption in `type.caption` /
`colorAccentPink`. Unchanged behaviour, re-homed into the card's sign section.

## Assumptions And Retained App-Only Elements

- A-1 — Clause counter (`{n}/20 điều khoản`) and the empty-selection hint are
  not in the design source. They are shipped REQ-001 affordances covered by
  existing tests; removing them would be a functional change, which this
  story's Out of Scope section excludes. They were kept and re-homed inside the
  clause list block, styled with `type.caption` / `colorTextMuted`.
- A-2 — The loading skeleton and the load-failure body have no design source
  counterpart and were left as delivered.
- A-3 — The sign-action error banner has no design source counterpart; only its
  placement changed (D-13).

## Deferred — Outside This Story's Write Scope

These are real fidelity gaps against the design source, but the files that own
them are not in STORY-015's declared `WriteScope`. Flagging for Scrum Master.

- DF-1 — `mobile/lib/features/love_contracts/presentation/widgets/clause_toggle_row.dart`:
  the design (lines 131-139) puts a 24x24 rounded checkbox (radius 9,
  `--grad-hot` fill when on, `1.5px solid var(--line)` when off) on the
  **left**, clause text in the middle at 15.5px/1.4, and the `§N` mono id on
  the **right** at 9.5px with 4px top padding. The current row renders `§N`
  first at the inherited mono size, then a circular check/radio glyph, then the
  text. AC4's mono *type treatment* is satisfied (`type.labelMono` +
  `colorTextMuted`), but the size and position do not match.
- DF-2 — `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`:
  the design (line 153) uses `height:64px`, `border-radius:var(--r-card)`, and
  `box-shadow:var(--glow)`. The widget uses `tapTarget + sm` height,
  `radiusButton` (pill), and no glow. It also draws a left-to-right fill plus a
  trailing `CircularProgressIndicator`, where the design draws a right-to-left
  dim overlay plus a conic-gradient touch puck.
- DF-3 — Design source line 162 adds a both-signed CTA
  (`Cả hai đã ký → Ghép đôi`, `--green` fill, `#04231E` label, 52px,
  `--r-btn`) that navigates to `invite`. Out of scope here: inter-screen
  navigation belongs to REQ-002 Scope A (STORY-001/STORY-002).

## Verification

Toolchain: Flutter at `$HOME/flutter/bin` (not on the default PATH in this
environment).

- `flutter gen-l10n` — required once in this fresh worktree; the generated
  `lib/l10n/generated/` tree is gitignored and absent on checkout.
- `flutter analyze lib/features/love_contracts test/features/love_contracts`
  — `No issues found!`
- `flutter test test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
  — 7/7 passed (new file).
- `flutter test test/features/love_contracts` — 76/76 passed, including the 12
  pre-existing `love_contract_screen_test.dart` cases and the
  `hold_to_sign_button_test.dart` signing integration case, so the restructure
  caused no regression.

No device install, no toolchain setup, no release configuration was performed
(out of this story's verification scope).

## New Test Coverage

`mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
renders the screen in dark theme + `vi` locale and asserts:

1. Sequence label mono family, 10px size, 1.8 tracking, uppercase, pink (D-4).
2. Clause id mono family and muted colour (AC4).
3. Exactly one plus on the add-clause affordance (D-7).
4. Mint lock glyph next to the footer note (D-11).
5. Unsigned state: caption present, hold control present, no signed card.
6. Self-signed state: green tint 12%, 40% green hairline, `radiusCard`,
   64px minimum height, green `w700` heading, awaiting-partner line (AC3).
7. Both-signed state: identical card treatment, swapped status line, no hold
   control, 18px green check glyph (AC3).

## Acceptance Criteria Status

- AC1 (layout/spacing/colour/typography match) — MET for the screen file;
  DF-1/DF-2 remain in shared widgets outside this story's write scope.
- AC2 (deviations corrected, not just documented) — MET, 13 fixes applied.
- AC3 (per-partner sign-status states match) — MET, all three states verified.
- AC4 (clause ids use the mono treatment) — MET at the type-treatment level;
  size/position refinement deferred as DF-1.
- AC5 (no new entry point, navigation unchanged) — MET, no navigation code
  touched.
