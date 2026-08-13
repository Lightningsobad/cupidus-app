# Visual Fidelity Report: STORY-019 — Typing Ghost Consent/Settings

Story: STORY-019 (REQ-002, Scope B)
Screen: Typing Ghost consent/settings (`ghostset`), Epic 2 (Communication)
Lane: mobile
Audited configuration: enabled dark theme + `vi` locale
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-019`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`

## Design Source

Locked source: `cupid-app-design-system/project/Cupid Screens.dc.html`

- `<sc-if value="{{ isGhostSet }}">` block, lines 391-431 — the authoritative
  geometry, colour and typography for this screen.
- Binding block, lines 2200-2213 — `ghostStateLine`, `switchBg`,
  `switchJustify`, `consentA/B`, `consentAColor/consentBColor`.
- Level-1 privacy chip, line 334 — reused verbatim for AC4 (see D2).

Supporting specs:

- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-007_chat/ux/uiux-spec.md`
  §4 (`ghostset`), §3b (Level-1 chip), §8 (accessibility / tap target).
- `data/ux/system/ui_ux_system_memory.md` §5 and §8 — Level-1 device-only
  surfaces must visibly show a lock affordance at all times.

## Files Changed

- `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart`
  (rewritten; 460 insertions, 149 deletions vs BaseHead)
- `mobile/test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart`
  (new)

No other production file was touched. `chat_screen.dart` and its widgets were
read-only for this story (STORY-018 owns them).

## Evidence Method And Its Limits

Rendered-PNG evidence was **not** produced. The design-canvas renderer
(`.ai-team-bundle/runtime/render-design-canvas.js`) is not provisioned in this
worktree, and the single attached device (`emulator-5554`) is shared across the
concurrent REQ-002 parallel wave, so a screenshot run from this lane would not
be reproducible or safely isolated.

Evidence in this report is therefore:

1. **Declaration-level comparison** — each design-source CSS declaration is
   quoted with its line number and paired with the Flutter declaration that now
   implements it.
2. **Executable assertions on the rendered widget tree** — a new widget test
   mounts the real screen at the design frame width (412pt) in dark theme +
   `vi` and probes the *laid-out* result: geometry through `tester.getRect`,
   fills/gradients/borders through the resolved `BoxDecoration`, and type
   through the resolved `TextStyle`. This is stronger than reading the source
   back, because it exercises token resolution and layout.

This limitation is called out for the reviewer rather than papered over.

## Deviations Found And Corrected

All ten were corrected in `ghost_settings_screen.dart`. "Before" is the state
at BaseHead.

### D1 — The consent control was not a switch at all (AC3, highest severity)

- Design source (403-404): `width:54px;height:32px;border-radius:999px;`
  `background:{{ switchBg }};padding:3px` with a
  `width:26px;height:26px;border-radius:50%;background:#fff;`
  `box-shadow:0 2px 6px rgba(60,20,80,.28)` knob, positioned by
  `justify-content:{{ switchJustify }}`.
- Before: a rounded pill rendering a **text glyph** — `'···'` when pending,
  otherwise `ChatStrings.ghostToggleGlyph(...)` — on `--surf2` / purple `.24`,
  force-squared to `tapTarget` in both axes by a `ConstrainedBox`. That glyph
  pill is the *in-chat composer* affordance (`ghostBtnLabel`), not the
  `ghostset` switch; it had been reused on the wrong screen.
- After: `_ConsentSwitch` — a real 54x32 track with 3px inset and a 26px white
  knob carrying the exact `rgba(60,20,80,.28)` shadow. Track is
  `colors.gradientHot` when on and `colors.colorLine` otherwise; the knob is
  `Alignment.centerRight` when on and `Alignment.centerLeft` otherwise, which
  is the Flutter equivalent of `switchJustify`.
- Three-state handling: `pending` shares the off-position `--line` track, per
  the binding block, and is distinguished by `ghostStateLine` and the
  accessible label only. That is the design source's own behaviour, not a
  simplification.

### D2 — Level-1 device-only lock affordance was absent (AC4)

- Before: nothing on this screen.
- Required by `ui_ux_system_memory.md` §5/§8: every Level-1 device-only surface
  must show a lock affordance at all times. Typing Ghost content is Level-1.
- The `ghostset` block in the design source does not itself draw one, so the
  design source's own Level-1 chip (line 334) was adopted verbatim for geometry
  and copy and placed at the top of the scroll region, mirroring §3b's
  placement in chat: `padding:5px 12px`, `--surf` fill, 999 radius, 13px soft
  `lock` glyph in `--mint`, 10.5px label in `--tx2`.
- After: `_PrivacyChip`, rendered unconditionally in all three consent states.

### D3 — Hero card

| Aspect | Design source (393-397) | Before | After |
| --- | --- | --- | --- |
| Fill | `linear-gradient(145deg, rgba(183,140,245,.32), rgba(255,127,182,.2))` | `colors.gradientDream` | 145deg `LinearGradient`, purple `.32` → pink `.2` |
| Border | `1px solid rgba(183,140,245,.45)` | none | `Border.all(purple @ .45)` |
| Radius | `var(--r-card)` | hard-coded `20` | `platformTokens.radiusCard` |
| Padding | `24px 20px` | `EdgeInsets.all(16)` | `symmetric(horizontal: 20, vertical: 24)` |
| Decorative glyph | 130px `blur_on` in `--purple` at `opacity:.2`, `top:-24;right:-16`, clipped by `overflow:hidden` | absent | `Positioned` + `Opacity(0.2)` inside `Clip.antiAlias` |
| Badge | 52x52, radius 18, `--grad-hot`, `--glow`, 30px white glyph | 28px flat icon | matches |
| Headline | Nunito 900, 25px, `line-height:1.2` | `type.cardTitle` (22) | 25 / 1.2 |
| Body | 13.5px, `line-height:1.6`, `--tx2` | `type.body` (17), `--tx` @ .9 | 13.5 / 1.6, `--tx2` |

The 145deg CSS angle is converted with the project's existing rule
(`cupid_color_tokens.dart`): `begin = (-sin θ, cos θ)`, `end = (sin θ, -cos θ)`,
expressed as the file-level `_gradient145Begin` / `_gradient145End` constants.

### D4 — Scroll padding

- Design source (392): `padding:14px 16px 40px`.
- Before: `EdgeInsets.all(CupidSpacing.md)` (16 on all sides).
- After: `EdgeInsets.fromLTRB(16, 14, 16, 40)`.

### D5 — Inter-card gap

- Design source (392): `gap:13px`.
- Before: `CupidSpacing.md` (16) between every card.
- After: 13.

### D6 — Toggle card chrome

- Design source (400, 402, 407, 412).
- Before: `EdgeInsets.all(16)`, hard-coded radius `20`, no shadow; title in
  `type.body`/w600 (17px); state line tinted `--mint` when on; no divider; the
  mutual-consent footer was a bare caption.
- After: `padding: 17`, `--r-card`, `--shadow`; title 16.5/w800; state line
  12px always `--tx2` with a 3px gap; a 1px `--line` divider with `margin:15px 0`;
  footer is a 7px-gap row with a 15px `handshake` glyph in `--pink` and 11.5px
  `--tx2` text.

### D7 — Consent tiles

- Design source (409-410): `flex:1;padding:12px;border-radius:var(--r-sm);`
  `background:var(--surf2);text-align:center`, label 11px `--tx2`, value 13px
  w800 with `margin-top:4px`, `gap:10px` between the two.
- Before: bare left-aligned `Column`s with no fill, no radius, no padding, no
  gap; label at `type.caption` (13) and value at `type.body` (17)/w600.
- After: `_ConsentTile` matching every declaration above, in an
  `IntrinsicHeight` row so the two tiles stay equal height like the CSS flex
  row when one value wraps.

### D8 — Legend card

- Design source (415-423).
- Before: no section label; the sample was the literal string `he` + struck
  `llo` with no bubble around it; two 10px **circular** swatches ordered
  live-then-deleted; `CupidSpacing` gaps throughout.
- After:
  - Card: `padding:17`, `--r-card`, `--shadow` (was `EdgeInsets.all(16)` /
    radius 20 / no shadow).
  - Section label: `Nhìn như thế nào` uppercased, 12px w700,
    `letter-spacing:.05em` → `letterSpacing: 0.6` at 12px, `--tx2`,
    `margin-bottom:12px`.
  - Preview bubble: `padding:12px 15px`, asymmetric radius `22 22 22 7`,
    `rgba(183,140,245,.12)` fill and a `1px dashed rgba(183,140,245,.6)` border
    drawn by a local `_DashedRRectBorderPainter` (same technique as
    `ghost_bubble.dart`; no dashed-border package is a project dependency).
  - Sample text: 15px / 1.5, `anh ăn cơm chưa` + a `--pink` `▌` caret + the
    `--ghost` struck tail `anh ơi em nhớ`.
  - Swatches: 11x11 with `border-radius:4px` (rounded squares, not circles),
    7px gap, 11.5px labels, `gap:16px`, **deleted listed before live**.

### D9 — Ephemeral footer card

- Design source (426-428): `padding:15px 16px`, `--r-card`,
  `rgba(121,226,205,.12)` fill, `1px solid rgba(121,226,205,.34)` border,
  `gap:11px`, 20px `shield_moon` glyph in `--mint`, body 12.5/1.55 in `--tx2`
  with the lead sentence in `<strong style="color:var(--tx)">`.
- Before: `EdgeInsets.all(16)`, radius 20, mint `.14`, **no border**, a
  default-size `Icons.shield_outlined`, and the whole body in `--tx` at
  `type.caption` (13).
- After: all of the above. The `<strong>` lead is reproduced by splitting the
  single `ChatStrings` entry on its first `'. '` and styling the lead span
  `--tx`/w700 — the copy stays one string because `chat_strings.dart` is
  outside this story's write scope.

### D10 — Switch hit area vs. visual size (§8)

- Before: `ConstrainedBox(minWidth: tapTarget, minHeight: tapTarget)` forced the
  *visual* pill to ~48x48. Tap target was compliant, but only by deforming the
  control.
- After: the visual switch is exactly 54x32 while the `GestureDetector` sits in
  a `SizedBox(width: 54, height: context.cupidPlatform.tapTarget)` with
  `HitTestBehavior.opaque`, so §8's minimum tap target is met without changing
  the rendered geometry.

## Defect Found By The New Test

The first run of the new widget test failed at layout with
`BoxConstraints forces an infinite height` from the consent-tile `Row`:
`CrossAxisAlignment.stretch` inside a `ListView`'s unbounded-height column
propagates `h=Infinity` to the children. Fixed by wrapping that row in
`IntrinsicHeight`, which is also the correct model for the design source's
equal-height 2-column flex row. This would have crashed the screen at runtime;
`flutter analyze` alone did not catch it.

## Carried-Forward Deviations (not fixed here — out of write scope)

These are real deviations from the locked design source. All of them live in
`mobile/lib/features/chat/presentation/chat_strings.dart`, which is **not** in
this story's declared `WriteScope` and is shared with STORY-018.

1. **Legend label casing/wording.** Design source (421-422) renders `đã xoá` /
   `đang gõ` and `deleted` / `live`. `ChatStrings.ghostSetLegendDeleted` /
   `ghostSetLegendLive` return `Đã xoá` / `Đang gõ` and `Deleted text` /
   `Live text`. A `.toLowerCase()` in the widget would fix `vi` but not `en`
   (`live text` ≠ `live`), so it was deliberately not applied as a half-fix.
   Correct fix: change the two `ChatStrings` entries. Both are referenced only
   from `ghost_settings_screen.dart`.
2. **Hero body and mutual-consent footer copy.** Design source (397, 412) uses
   longer `vi` prose than `ghostSetHeroBody` / `ghostSetMutualConsentFooter`.
   Semantically equivalent, wording differs.
3. **Hero headline line break.** Design source (396) forces
   `Đối phương thấy cả<br>phần bạn đã xoá`. The app lets it wrap naturally; at
   the 412pt frame it breaks at the same point, but the break is not pinned.
4. **`ChatStrings.privacyChip` lacks the `Level 1 · ` prefix** that the design
   source's chip (line 334) has. `ghost_settings_screen.dart` therefore carries
   the full design-source copy inline via `context.viEn(...)` rather than
   reusing the truncated shared string. The shared string is consumed by
   `chat_screen.dart`, so correcting it belongs to STORY-018.

## Deliberate, Documented Divergence

The partner consent tile renders `Chưa rõ` in `--tx2`, not the design source's
`consentBColor` mint. The backend contract exposes no partner consent flag
(ADR-013e; `coding-plan/phase-P3-typing-ghost.md` §6 required checks forbid
rendering a definite partner state). Tinting "unknown" copy mint would assert a
partner state the app cannot know. Pre-existing behaviour, preserved
intentionally.

## Verification

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-019/mobile`
with Flutter 3.44.1 / Dart 3.12.1 (`/Users/alantravala/flutter/bin/flutter`).

`flutter gen-l10n` was run first because `lib/l10n/generated/` is generated,
gitignored output that was absent in a fresh worktree.

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/chat/presentation/screens/ghost_settings_screen.dart test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` | `No issues found! (ran in 1.4s)` |
| `flutter test test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` | `+6: All tests passed!` |
| `flutter test test/features/chat` | `+54: All tests passed!` |
| `dart format lib/features/chat/presentation/screens/ghost_settings_screen.dart test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` | `Formatted 2 files` |

No `--no-fatal-infos` was needed; the analyzer is clean at default severity.

The whole `test/features/chat` directory was run to confirm the shared chat
suite still passes; only the ghost-settings test file was added by this story.

### Test coverage added

`mobile/test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart`
mounts the real screen at 412x1600 in dark + `vi`:

1. `AC3 off` — track is `--line`, no gradient, knob inset 3px at flex-start,
   knob is 26x26.
2. `AC3 pending` — track stays the off-position `--line`, state line reads
   `Đang chờ cả hai đồng ý`, and the accessible label is
   `Typing Ghost: đang chờ cả hai đồng ý` on a `button: true` node.
3. `AC3 on` — track is `gradientHot` with no flat colour, knob inset 3px at
   flex-end, `Đã đồng ý` resolves to `--mint`, `Chưa rõ` stays `--tx2`.
4. `AC4` — the Level-1 chip renders, its label is 10.5px `--tx2`, and its glyph
   is `CupidIcons.lock` at 13px in `--mint`.
5. `AC1 geometry` — scroll padding, the hero gradient stops / hairline /
   `--r-card`, the 25px headline, `--surf2` + `--r-sm` consent tiles with the
   11px label, the uppercased section label, 11x11 radius-4 swatches with
   deleted before live, and the ephemeral card's mint `.12` fill plus `.34`
   hairline.
6. `AC1/§8` — the switch hit area is at least `platformTokens.tapTarget` tall.

The three consent states are driven through the real `GhostCubit`: the local
opt-in flag via `SharedPreferences`, the server flag via a fake Dio adapter on
`GET /users/me`, and the `pending → on` transition by firing a real
`ChatEvents.ghostTyping` event through a fake `RealtimeCoordinator`.

## Acceptance Criteria Verification

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — dark + `vi` layout, spacing, tokens, typography match | MET, with 4 documented copy-level carry-forwards | D3-D10 above; test cases 5 and 6 |
| AC2 — deviations corrected in the app, not just documented | MET | 460/149 line diff in `ghost_settings_screen.dart`; no audit-only findings except the out-of-write-scope `chat_strings.dart` items, which are listed with their exact fix |
| AC3 — all three toggle states match | MET | D1; test cases 1-3 |
| AC4 — Level-1 lock affordance visible | MET | D2; test case 4 |
| AC5 — no new entry point | MET | `GhostSettingsScreen`'s public constructor and `onBack` contract are unchanged; no route or navigation wiring was added or modified |

AC1 is reported as met for everything this story can write. The four
carried-forward items are copy strings in a file outside the declared
`WriteScope`; they are itemised above with the exact change required so the
reviewer or Scrum Master can route them.

## Open Question Impact

OQ5 (light theme / `en` locale) is unchanged. Every fix above is expressed in
shared `ThemeExtension` tokens (`context.cupidColors`, `context.cupidPlatform`,
`context.cupidType`), so it stays correct across all four theme/locale
combinations. No dedicated light/`en` visual pass was performed, per the story's
Out of Scope section.
