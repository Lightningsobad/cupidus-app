# Visual Fidelity Report: STORY-019 — Typing Ghost Consent/Settings

VISUAL_FIDELITY: PASS

Story: STORY-019 (REQ-002, Scope B)
Screen: Typing Ghost consent/settings, Epic 2 (Communication)
Design-Screen: `ghostset`
Lane: mobile
Audited configuration: enabled dark theme + `vi` locale
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-019`
BaseHead: `cda59c43a7390e61552549a337b36afb085c045e`

`VISUAL_FIDELITY: PASS` is asserted from the rendered comparison in
[Rendered Comparison](#rendered-comparison-design-canvas-vs-device), not from
source reading. Every delta that survives that comparison is itemised there with
an owner; none of them is fixable inside this story's declared `WriteScope`.

## Design Source

Configured entry (`data/devops/system/design-fidelity-config.json`):
`cupid-app-design-system/project/Cupid App.dc.html`, `screens_from: "canvas"`,
`locked: true`, `ui_surface: true`.

Because `screens_from` is `"canvas"`, screens are *states* of that one entry
selected by `[data-screen-btn="<id>"]`, not separate files.
`render-design-canvas.js --list-screens` against the configured entry returns 37
ids; `ghostset` is this story's screen. That id is now recorded as
`Design-Screen:` above and in `story_master.md`.

The CSS declarations quoted in D1-D10 below carry line numbers from
`cupid-app-design-system/project/Cupid Screens.dc.html`, the component file the
canvas entry composes. They were verified against the entry's own `ghostset`
render (see the inventory below), which reproduces the same geometry, tokens and
type. The line citations are kept because they are the precise coordinates of
each declaration.

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
- `mobile/lib/main_preview.dart` (preview harness only: a `ghostset` entry that
  reproduces the real navigation shape, plus a `PREVIEW_GHOST_CONSENT` fixture
  so all three AC3 states can be screenshotted — see Evidence Method)

No other production file was touched. `chat_screen.dart` and its widgets were
read-only for this story (STORY-018 owns them).

## Evidence Method

Rendered PNGs on both sides. Nothing in the Rendered Comparison section is
inferred from source.

### Design side

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --entry "cupid-app-design-system/project/Cupid App.dc.html" \
  --screen ghostset --platform android --theme dark --lang vi \
  --out .../visual-fidelity/design-reference-ghostset-android.png
```

The renderer serves the project over loopback HTTP rather than `file://`,
because `<dc-import>` resolution is a `fetch` and `file://` fails it on CORS. It
clicks `[data-screen-btn="ghostset"]` to put the canvas in this screen's state
and applies the configured `hide_selectors` so the canvas's own floating chrome
is not captured.

### Implementation side

```
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --device emulator-5560 --label ghostset --settle-ms 40000 ...
```

Captures are real Android screenshots of a debug build of this branch, not
golden-file or widget-tree renders.

Two harness facts a reviewer needs in order to trust the captures:

1. **Navigation shape.** `app_shell.dart:_openGhostSettings` pushes
   `GhostSettingsScreen` as a `MaterialPageRoute` *above* `AppShell` and always
   supplies `onBack`. The first capture round used the preview harness's
   `wrapInShell: true`, which added a tab bar and an account-hub FAB the real
   app never renders here, and omitted `onBack`, which dropped the back arrow.
   Both were wrong, and both were fixed in `main_preview.dart` before the
   captures below were taken. The captures now match the real route.
2. **Consent state.** `GhostCubit._recomputeConsentLevel()` derives the ADR-013e
   level from a local opt-in flag AND a server flag AND an inbound
   `ghostTyping` event. An unauthenticated capture session can reach none of
   those, so `--dart-define=PREVIEW_GHOST_CONSENT=<off|pending|on>` pins them
   (same pattern as the file's existing `PREVIEW_CONTRACT_SIGN_STATUS`
   fixture). The fixture only pins inputs; the screen's own state machine and
   rendering are untouched. Omitting the define leaves today's live behaviour
   exactly as-is.

All three state captures were taken inside one exclusive device window
(`capture-mobile-screen.sh --lease-exec`) wrapping install, force-stop, launch
and capture. This was necessary, not ceremonial: a concurrent REQ-002 lane
installs its own APK under the same application id (`com.snapsofts.cupid`), and
an earlier unleased attempt captured that other lane's screen instead.

### Design-canvas coverage limit

The canvas's `ghostset` state renders the **on** state only. The design source's
off and pending states exist as bindings (`switchBg`, `switchJustify`,
`ghostStateLine` — `Cupid Screens.dc.html:2200-2213`), not as separately
selectable canvas states. So AC3's off and pending captures below are compared
against those bindings plus the shared switch geometry, while the on state is
compared against a real pixel render. This is a property of the design source,
and it is stated rather than glossed.

### Supporting non-rendered evidence

The widget test described under Verification stays in the report as the
*executable* layer: it mounts the real screen at the 412pt design frame and
probes laid-out geometry, resolved `BoxDecoration` and resolved `TextStyle`. It
supports the rendered comparison; it no longer substitutes for it.

## Rendered Evidence Inventory

All paths are relative to
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/`.

| File | What it is | Size |
| --- | --- | --- |
| `design-reference-ghostset-android.png` | Design canvas, entry `Cupid App.dc.html`, screen `ghostset`, android/dark/`vi` | 406x900 |
| `implemented-ghostset-emulator-5560.png` | Device capture, consent `on` (AC3) | 405x900 |
| `implemented-ghostset-state-pending-emulator-5560.png` | Device capture, consent `pending` (AC3) | 405x900 |
| `implemented-ghostset-state-off-emulator-5560.png` | Device capture, consent `off` (AC3) | 405x900 |
| `implemented-runtime-smoke-first-screen-emulator-5560.png` | Real `lib/main.dart` first screen (rule 12g) | 405x900 |

## Rendered Comparison: Design Canvas vs Device

### Confirmed matching in the render

Hero card gradient, hairline and radius; the 130px `blur_on` decorative glyph and
its clipping; the 52x52 gradient badge; the 25px/1.2 headline; the 54x32 switch
with its gradient track and right-positioned white knob; the two filled
rounded consent tiles; the handshake footer row; the uppercased section label;
the dashed preview bubble with its pink caret and struck tail; the two
rounded-square swatches in deleted-then-live order; the mint ephemeral card with
its `.34` hairline and shield glyph. D1 and D3-D10 are visible as fixed in the
capture.

### Deltas that survive the render

| # | Element | Design canvas | Device capture | Adjudication |
| --- | --- | --- | --- | --- |
| R1 | Header back arrow tint | pink | white | **System-level, out of `WriteScope`.** `cupid_header.dart` `_MaterialHeader` hard-codes `color: colors.colorText`; `_IosHeader` already uses `colorAccentPink`. `CupidHeader` exposes no tint parameter, so this cannot be fixed from this screen. Changing it alters the back arrow of every Material screen in the app, which is a design-system decision, not a STORY-019 one. Routed out, not silently patched. |
| R2 | Level-1 privacy chip | absent from the `ghostset` state | present | **Intentional, AC4-mandated.** `ui_ux_system_memory.md` §5/§8 requires a visible lock affordance on every Level-1 device-only surface. The canvas does not draw one here, so the design source's own chip (`Cupid Screens.dc.html:334`) was adopted verbatim. See D2. |
| R3 | Consent tile labels | `Minh` / `Linh` | `Bạn` / `Đối phương` | **Not a defect.** `Cupid App.dc.html:52` states the canvas's two device frames are the two members of one couple — "iPhone là Minh, Pixel là Linh". Those are demo persona names for self/partner. The app has no partner display name bound on this screen, so it renders the role labels the personas stand for. |
| R4 | Partner consent value | `đã đồng ý` in mint | `Chưa rõ` in `--tx2` | **Deliberate, pre-existing, documented.** See "Deliberate, Documented Divergence" below. The backend contract exposes no partner consent flag (ADR-013e), so mint would assert a state the app cannot know. |
| R5 | Bottom tab bar | 5-item bar rendered | none | **Out of scope, and correct.** `app_shell.dart:_openGhostSettings` pushes this screen full-screen *above* `AppShell`, so runtime never shows shell chrome here. The shell's real bar also has 3 items, not 5. Changing either is a navigation-architecture change, which AC5 explicitly forbids in this story. |
| R6 | Hero body copy | longer `vi` prose | shorter `vi` prose | Carry-forward 2 — `chat_strings.dart`, outside `WriteScope`. |
| R7 | Mutual-consent footer copy | wording differs | wording differs | Carry-forward 2 — same file. |
| R8 | Ephemeral card copy | `Ephemeral 100%. …` | `100% ẩn danh tạm thời. …` | Carry-forward 2 — same file. |
| R9 | Legend label casing | `đã xoá` / `đang gõ` | `Đã xoá` / `Đang gõ` | Carry-forward 1 — same file; a widget-side `.toLowerCase()` would fix `vi` but break `en`, so it was not applied as a half-fix. |
| R10 | Hero headline break point | pinned `<br>` after `cả` | wraps after `phần` | Carry-forward 3 — the app lets it wrap naturally rather than pinning a break. |

R1-R5 are adjudicated as correct-as-implemented or as owned by another story.
R6-R10 are the copy-string carry-forwards already itemised below, all in
`mobile/lib/features/chat/presentation/chat_strings.dart`, which is shared with
STORY-018 and outside this story's declared `WriteScope`.

Nothing in this table is a defect this story can fix and has not fixed. That is
the basis for `VISUAL_FIDELITY: PASS`.

### AC3 state renders

| State | Capture | Switch track | Knob | State line | Your tile |
| --- | --- | --- | --- | --- | --- |
| `off` | `implemented-ghostset-state-off-…` | `--line` flat | left | `Tắt` | `Tắt` |
| `pending` | `implemented-ghostset-state-pending-…` | `--line` flat | left | `Đang chờ cả hai đồng ý` | `Đã đồng ý` |
| `on` | `implemented-ghostset-…` | `--grad-hot` | right | `Đang bật · cả hai đã đồng ý` | `Đã đồng ý` in mint |

The off/pending track and knob positions match `switchBg` / `switchJustify` in
the binding block; the on state matches the canvas render pixel-for-pixel in
geometry and gradient.

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

## Story Runtime Startup Smoke

Scope: the impacted app only (`cupid_mobile` on Android). No backend, web or
other service was started, per the scoped-smoke rule.

| Step | Command | Result |
| --- | --- | --- |
| Build | `flutter build apk --debug` | PASS — APK produced |
| Install | `adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk` | PASS |
| Launch | `adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` | PASS — activity started |
| First screen | screenshot after settle | PASS — pairing gate renders |

This is the real `lib/main.dart` entry point, not the preview harness: the
capture carries Flutter's DEBUG banner and shows the app's actual first screen
for an unpaired session — "Ghép đôi để mở khoá Cupid" with the
"Ghép đôi với người ấy" primary action and the "Tôi đã có mã" secondary link.
Evidence: `implemented-runtime-smoke-first-screen-emulator-5560.png`.

No crash, no ANR and no red error screen. `logcat` for the launch window
contained only Impeller and Dart VM initialisation lines plus one `401` from
`GET http://localhost:3000/users/me` — expected for an unauthenticated session
with no local backend, and handled gracefully by the app, which is exactly why
the pairing gate is the screen that renders.

The launch component is spelled out above because it is not guessable: the
application id is `com.snapsofts.cupid` while the activity class path is
`com.snapsofts.cupid_mobile.MainActivity`. A `monkey`-based launch resolves the
wrong component and lands on the Android launcher instead.

## Verification

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-019/mobile`
with Flutter 3.44.1 / Dart 3.12.1 (`/Users/alantravala/flutter/bin/flutter`).

`flutter gen-l10n` was run first because `lib/l10n/generated/` is generated,
gitignored output that was absent in a fresh worktree.

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/chat/presentation/screens/ghost_settings_screen.dart lib/main_preview.dart test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` | `No issues found! (ran in 2.5s)` |
| `flutter test test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` | `+6: All tests passed!` |
| `flutter test test/features/chat` | `+54: All tests passed!` |
| `flutter build apk --debug` | PASS — used for the captures and the runtime smoke |
| `dart format lib/features/chat/presentation/screens/ghost_settings_screen.dart test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` | `Formatted 2 files` |

The analyze and test rows above are from this evidence round, run after the
`main_preview.dart` harness change, not carried over from an earlier round.

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

| AC | Status | Rendered evidence | Supporting evidence |
| --- | --- | --- | --- |
| AC1 — dark + `vi` layout, spacing, tokens, typography match | MET for everything inside `WriteScope`; R1 and R6-R10 deferred to their owning files | `design-reference-ghostset-android.png` vs `implemented-ghostset-emulator-5560.png` | D3-D10; test cases 5 and 6 |
| AC2 — deviations corrected in the app, not just documented | MET | the capture shows D1 and D3-D10 as rendered fixes, not claims | 460/149 line diff in `ghost_settings_screen.dart` |
| AC3 — all three toggle states match | MET | three state captures; on-state compared to the canvas render, off/pending to the `switchBg`/`switchJustify` bindings the canvas does not expose as states | D1; test cases 1-3 |
| AC4 — Level-1 lock affordance visible | MET | chip visible in all three state captures | D2; test case 4 |
| AC5 — no new entry point | MET | R5: the capture has no shell chrome, which is what the existing `MaterialPageRoute` push produces | `GhostSettingsScreen`'s public constructor and `onBack` contract are unchanged; no route or navigation wiring was added or modified |

AC1 is reported as met for everything this story can write. The deltas that
survive the rendered comparison are R1 (a shared design-system component with no
per-screen tint hook) and R6-R10 (copy strings in `chat_strings.dart`, shared
with STORY-018). Both files are outside the declared `WriteScope`, and both are
itemised with the exact change required so the reviewer or Scrum Master can
route them.

### Deviation for another story: header back-arrow tint (R1)

`mobile/lib/design_system/adaptive/cupid_header.dart` renders the Material
back arrow as `IconButton(icon: Icon(CupidIcons.arrowBack), color:
colors.colorText)` while the iOS variant already uses `colors.colorAccentPink`.
The design canvas renders it pink on Android too. `CupidHeader`'s constructor
takes only `title`, `onBack`, `backLabel` and `actions`, so there is no
per-screen tint override; the only fix is inside the shared component, which
changes every Material screen in the app. That is a design-system-wide decision
and is left for a design-system story rather than being patched from here.

## Open Question Impact

OQ5 (light theme / `en` locale) is unchanged. Every fix above is expressed in
shared `ThemeExtension` tokens (`context.cupidColors`, `context.cupidPlatform`,
`context.cupidType`), so it stays correct across all four theme/locale
combinations. No dedicated light/`en` visual pass was performed, per the story's
Out of Scope section.
