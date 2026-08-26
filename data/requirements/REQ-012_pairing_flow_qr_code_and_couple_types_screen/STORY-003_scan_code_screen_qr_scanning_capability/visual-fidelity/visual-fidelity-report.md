VISUAL_FIDELITY: FAIL

# Visual Fidelity — STORY-003 Scan-Code Screen QR Scanning (P4)

Design-Screen: `joincode` (entry point) + `scanlive`, `scaninvalid`,
`scandenied`, `scanblocked`, `scanunavailable` (scan overlay States 2, 4, 5, 6,
7). All six now render from the canvas and all six are compared against a real
paired image below.
Platform: android (`emulator-5554`)
Theme/locale compared: dark theme + `vi` — the enabled configuration; light and
`en` are out of scope per `../story_master.md` "Out of Scope".

## 1. Artifacts

| Role | Implemented capture | Design reference | Size |
| --- | --- | --- | --- |
| Entry point (AC5) | `implemented-joincode-two-pill-row-emulator-5554.png` | `design-reference-joincode-android.png` | 405x900 / 406x900 |
| State 2 — live scanning | `implemented-scan-live-emulator-5554.png` | `design-reference-scanlive-android.png` | 405x900 / 406x900 |
| State 4 — invalid/expired | `implemented-scan-invalid-emulator-5554.png` | `design-reference-scaninvalid-android.png` | 405x900 / 406x900 |
| State 5 — permission denied | `implemented-scan-denied-emulator-5554.png` | `design-reference-scandenied-android.png` | 405x900 / 406x900 |
| State 6 — permission blocked | `implemented-scan-blocked-emulator-5554.png` | `design-reference-scanblocked-android.png` | 405x900 / 406x900 |
| State 7 — camera unavailable | `implemented-scan-unavailable-emulator-5554.png` | `design-reference-scanunavailable-android.png` | 405x900 / 406x900 |

Every design reference was produced from the canvas with

```
render-design-canvas.js --surface=mobile --screen=<id> \
  --platform=android --theme=dark --lang=vi --label=<id>
```

for `<id>` in `joincode`, `scanlive`, `scaninvalid`, `scandenied`,
`scanblocked`, `scanunavailable`. `--surface=mobile` is mandatory:
`data/devops/system/design-fidelity-config.json` declares two design sources
(`cupid-app`, `cupid-web`) and the tool refuses to guess.

An earlier pass of this audit could not render the five scan states — the design
blocks existed at `Cupid Screens.dc.html:1682-1743` but `renderVals()` never
assigned their `sc-if` flags and `Cupid App.dc.html` advertised no matching
`data-screen-btn` id, so the renderer answered `DESIGN_CANVAS_SCREEN_MISSING`
for every candidate. `ui-ux-designer` closed both halves of that gap on
2026-08-26 (`9dbad43`); `--list-screens` now returns 42 ids including the five
above, and all five rendered cleanly. No reference in this directory is a
placeholder, a re-label of another screen, or a DOM-injected state.

## 2. How the captures were produced

Every state was FAKED through the preview harness, never navigated to. No camera
permission was ever granted on the emulator and no live camera frame was needed:
`main_preview.dart` registers a `scan` entry whose `_PreviewScanSurface` selects
the state from a compile-time `String.fromEnvironment`, and injects a fake
`CameraPermissionGate`. So each capture depends on no login, no pairing, no
real camera and no OS permission dialog.

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=scan --dart-define=PREVIEW_SCAN_STATE=<state> \
  --target-platform android-arm64
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am start -a android.intent.action.VIEW \
  -d "cupidpreview://screen/scan" com.snapsofts.cupid
capture-mobile-screen.sh --out=<story>/visual-fidelity --label=scan-<state> \
  --device=emulator-5554 --settle-ms=20000
```

`PREVIEW_SCAN_STATE` took `live`, `invalid`, `denied`, `blocked`, `unavailable`.
The entry-point capture used `--dart-define=PREVIEW=joincode` and the existing
`joincode` registry entry, which now renders the two-pill row.

### Three capture lessons that cost real attempts

1. **No `--width`.** `capture-mobile-screen.sh --width=<px>` temporarily
   *resizes the device display* (`wm size`); it is not an image resize —
   `--max-edge` (default 900) is. An early pass ran `--width=540` with no
   matching `--density`, which put the emulator at roughly a 206dp logical
   viewport and produced (a) a spurious `…BY 9.8 PIXELS` RIGHT-overflow banner
   with clipped pills on the join-code screen and (b) an invalid-state card that
   filled the screen edge to edge with no viewfinder behind it. All six final
   captures were retaken with no `--width` at all, at the emulator's native
   1080x2400 / density 420 (≈411.4 x 914.3 dp), letting `--max-edge=900` do the
   shrinking. That is why every file is 405x900.

   The overflow banner was disproved three independent ways before the cause was
   found: a raw `adb exec-out screencap -p` seconds apart showed a clean layout;
   a throwaway widget-test probe pumping `JoincodeScreen` at true device metrics
   reported no `RenderFlex` overflow; and a full 79285-line `adb logcat` dump
   contained no overflow entry. No source change was made to
   `joincode_screen.dart` layout as a result — there was nothing to fix.

2. **~20s settle.** Three captures came back as the Flutter splash logo
   (17-27 KB files). The preview `main()` runs Firebase init plus
   `bootstrapPreviewSession()` and is slow to first real frame on this emulator
   in debug JIT. `--settle-ms=20000` is the floor here.

3. **State 4 self-dismisses.** Per `../ux/ux-spec.md:117-120` the invalid card
   auto-returns to State 2 after ~3s, and `_PreviewScanSurface` re-emits on a
   500ms timer, so the tool's own retry loop kept landing on State 2. The final
   `implemented-scan-invalid-*.png` was taken from a raw
   `adb exec-out screencap -p` burst, picking the correct frame by file size
   (≈79 KB = State 4 card present, ≈47 KB = State 2), then downscaled with
   `sips -Z 900` into the evidence path. Same pixels, different plumbing.

## 3. Matched, element by element

### Entry point — `design-reference-joincode-android.png` vs `implemented-joincode-two-pill-row-emulator-5554.png`

Both images were read side by side. Every element the story touched matches:
the two-pill row splits the width identically, both pills carry the same 1.5px
unfilled outline at the same height, the `content_paste` / `qr_code_scanner`
glyphs render at the same size and muted tone, the labels "Dán" and "Quét QR"
sit at the same weight, and the row occupies the same vertical band between the
code boxes and the "Ghép đôi" CTA. The CTA gradient and the
"Tôi mới là người tạo mã →" link are pixel-comparable.

Two differences are visible in the pair and neither belongs to this story:

- the design frame draws a title "Nhập mã ghép đôi" beside the back arrow; the
  build shows the back arrow alone. Pre-existing on the join-code screen,
  untouched by STORY-003, and outside its scope.
- the design draws 5 code boxes with a `–` separator and pre-filled sample
  characters; the build draws 6 empty boxes. This is §4.5, already closed by
  REQ-002/STORY-047 with no code change.

Element-by-element against the `.dc.html` source:

| Element | Result |
| --- | --- |
| Action row is `display:flex;gap:10px` with two `flex:1` children | match — `Row` of two `Expanded` with `_pillGap = 10` |
| Both pills 48px tall | match — `_pasteHeight = 48` |
| Both pills `var(--r-btn)` + 1.5px `var(--line)` border, no fill | match — `radiusButton`, `colorLine` |
| Left pill: `content_paste` 19px `var(--tx2)` + "Dán" / "Paste" | match |
| Right pill: `qr_code_scanner` 19px `var(--tx2)` + "Quét QR" / "Scan QR" | match |
| Label 14px weight-700 | match — `_pasteLabelFontSize = 14`, shared by both pills |
| Row sits 24px under the code-box row (`margin-top:24px`) | match — `SizedBox(height: CupidSpacing.lg)` = 24 |
| 14px between the row and "Ghép đôi" | match — `_actionGap = 14` |
| `qr_code_scanner` codepoint `0xf206`, read from the bundled font cmap | match — `_qrCodeScannerIcon`, verified with `fontTools`, not recalled |
| "Ghép đôi" CTA, `grad-hot`, unchanged | match — untouched by this story |
| 6-box code row, slot size/gap, unchanged | match — `_slotWidth/_slotHeight/_slotGap` untouched |
| "Tôi mới là người tạo mã →" link unchanged | match |
| No horizontal overflow at 411dp | match — see lesson 1 |

The stale `joincode_screen.dart` comment recording that REQ-002/STORY-047
deferred this pill was removed with the change, as P4 §3 required.

### State 2 — `design-reference-scanlive-android.png` vs `implemented-scan-live-emulator-5554.png`

| Element | Result |
| --- | --- |
| Full-viewport dark preview surface, no tab bar, close affordance top-left | match |
| Centered square viewfinder at ~70% width, pink 2.5px border | match — `_viewfinderFraction = 0.7`, `_viewfinderBorderWidth = 3` |
| Viewfinder corner radius `28px` | match — `platformTokens.radiusSheet` |
| Helper copy "Đưa camera vào mã QR của người ấy", muted, caption size | text and colour match; **position differs — VF-2** |
| "Nhập mã thủ công" pinned low, pink, weight-700, 13px | match — `_linkFontSize = 13` |
| Animated scan line across the viewfinder | **missing in the build — VF-1** |

### State 4 — `design-reference-scaninvalid-android.png` vs `implemented-scan-invalid-emulator-5554.png`

| Element | Result |
| --- | --- |
| Camera surface and viewfinder stay visible behind the card | match |
| Card centered, `colorSurface` fill, 1px `colorLine` border | match |
| Card corner radius `var(--r-card)` | match — `platformTokens.radiusCard`, see §4.1 |
| 40px red circular icon with white `priority_high` | match |
| Copy "Mã QR không hợp lệ hoặc đã hết hạn" | match |
| "Thử lại" primary, 48px, `r-btn`, `grad-hot` | match |
| Manual-entry secondary link under the primary | match |
| Card width — design `left:26px;right:26px` | **narrower in the build — VF-3** |
| Viewfinder dimmed to `rgba(255,127,182,.35)` behind the card | **not dimmed in the build — VF-4** |

### States 5, 6, 7 — `design-reference-scan{denied,blocked,unavailable}-android.png` vs `implemented-scan-{denied,blocked,unavailable}-emulator-5554.png`

All three share one layout in both design and build, so they are compared as one
group with per-state copy called out.

| Element | Result |
| --- | --- |
| Static message state, no camera preview | match |
| 44px `no_photography` icon in `var(--tx2)` | match — `_stateIconSize = 40`, `colorTextMuted` |
| State 5 copy "Cupid cần quyền camera để quét mã QR" + `grad-hot` "Nhập mã thủ công" | match |
| State 6 copy "Cupid cần quyền camera trong Cài đặt…", primary "Mở Cài đặt", pink secondary "Nhập mã thủ công" | match |
| State 7 copy "Không thể mở camera trên thiết bị này", single action, no Settings deep-link | match |
| Centered stack, icon → copy → primary CTA → optional link | match |
| Message typography — design `15px/700` | **lighter and smaller in the build — VF-5** |
| Primary CTA width — design `max-width:270px` | **narrower in the build — VF-6** |

Cross-cutting, true in all five states: the top-left close icon is present at a
≥44x44 hit target (spec L52-54), a manual-entry path is visibly reachable
(L157-165), and no new colour or radius is introduced — only `colorPink`,
`colorMint`, `colorTextMuted`, `colorSurface`, `colorLine`, `gradientHot`
(L169-177).

A faint bottom tab bar bleeds through in the design frames for States 5-7. That
is a canvas artifact — the design's message overlay is 97% opaque over the
shared shell, not a request for a tab bar on this route. It is not counted as a
delta; see §4.4.

States 1 and 3 are transient (≤400ms) and are not device-captured: State 1 is a
near-instant spinner that the spec itself calls skippable when permission is
already granted (L60-66), and State 3 is the ~300-400ms mint success flash
before hand-off (L87-97). Both are covered by widget tests rather than a frame
grab. No `MOBILE_VISUAL_AUDIT_STATE_MISSING` is raised — the states exist and are
reachable, they are just not photographable at this cadence.

`no_fork_guard_test.dart` pins the whole surface: no raw `Color(0x`, `Colors.`,
`Platform.is` or `defaultTargetPlatform` exists anywhere under
`mobile/lib/features/pairing`. That is a test, not a one-off grep.

## 4. Deltas

### 4.1 FLAGGED — State 4 card radius deviates from the UX spec text

`../ux/ux-spec.md:104-106` specifies the invalid-code message card with
"rounded corners matching `var(--r-btn)` radius convention used elsewhere on
this screen", and L175 lists `var(--r-btn)` as the "button/card corner radius".

`var(--r-btn)` is `999px` on both platforms
(`Cupid Screens.dc.html:24-25`), i.e. a full pill. The implementation's
`CupidPlatformTokens.radiusButton` is the faithful mapping of that at `999`.

Applied literally, this renders the State 4 card — a `_cardMaxWidth`-wide box
holding an icon, two lines of copy, a primary button and a text link — as a
stadium blob with the content pushed away from its own corners. The first
capture pass showed exactly that. `scan_code_screen.dart:388` now uses
`platformTokens.radiusCard` (26 iOS / 24 Material), whose own token doc reads
"Card/content container corner radius", and which is what `_Viewfinder` in the
same file already reaches for via `radiusSheet`.

This is a **deliberate deviation from the literal spec text**, made because
`var(--r-btn)` only reads correctly on the 48-54px-tall elements it was written
for. It is recorded here rather than absorbed silently. Reverting is a one-token
edit at `scan_code_screen.dart:388` if UI/UX or the Reviewer decides the spec
text should win. Recommended resolution: amend `ux-spec.md` L104-106 and L175 to
name a card radius for card-shaped surfaces.

**Resolved:** the Reviewer formally ruled on this exact delta in
`../review/review-report.md` §4 ("`_InvalidCard` radius deviation — CLEAN,
carried forward unchanged") and found it CLEAN, not reopened.

**Closed 2026-08-26 — the delta no longer exists.** The design update rewrote
both sides of it, and the design source now agrees with the shipped code:

- `Cupid Screens.dc.html:1701` draws the State 4 message card with
  `border-radius:var(--r-card)`, not `var(--r-btn)`.
- `Cupid Screens.dc.html:24-25` defines `--r-card` as `26px` on `[data-plat="ios"]`
  and `24px` on `[data-plat="md"]`. `CupidPlatformTokens.radiusCard` is `26` iOS /
  `24` Material, which is that token exactly.
- `../ux/ux-spec.md` State 4 was amended to name `var(--r-card)` and its token
  list now carries `var(--r-card)` for this card.

So `scan_code_screen.dart:388` was already correct and the recommended
`ux-spec.md` amendment has been made. Confirmed a second way in this pass: the
rendered `design-reference-scaninvalid-android.png` and the build's card show the
same card-shaped corner, not a stadium. This entry is retained as history only —
there is nothing left to flag and no follow-up outstanding.

### 4.2 Star particles in the backdrop are intentional

The scan captures show the shared `CupidAppBackground` particle field behind the
overlay. That is the app-wide backdrop the design system already ships, not
decoration added by this story, and it is what a user sees at runtime.

### 4.3 `Colors.black` in `main_preview.dart` is not a fork violation

The preview scaffold uses a literal `Colors.black` behind the fake scan surface.
`no_fork_guard_test.dart` scans `lib/features`, `lib/app` and `lib/core` only;
`lib/main_preview.dart` is harness code that never ships in a release build, and
the guard's scope excludes it by design. No production surface gained a raw
colour.

### 4.4 Bottom tab bar absent

The overlay is a full-screen route pushed above `AppShell`, so no tab bar exists
at runtime and none appears in the captures. Same precedent as the other pushed
canvas entries. Not a defect.

### 4.5 Code length: 6 boxes, pre-existing and out of scope

The capture shows 6 code slots. `Cupid Screens.dc.html:1621` says "8 ký tự"
while `1623-1628` draws 5 boxes — the mockup contradicts itself, and the shipped
contract is `InvitationsService.generateCode`'s 6 hex characters. REQ-002 /
STORY-047 triage item 3a closed this with no code change, and
`joincode_screen.dart:35-39` carries that reasoning at `_codeLength = 6`.
STORY-003 did not touch it; P4 §3 explicitly forbade adding an 8-character path.

### 4.6 OPEN — six deltas found by the paired-image comparison

These are the findings that set `VISUAL_FIDELITY: FAIL`. None of them existed as
a finding before this pass, because before 2026-08-26 the five scan states had no
renderable design reference to compare against — the spec-prose comparison that
the earlier revision (and the Reviewer's first pass) relied on could not surface
them. Every one is confirmed against the design source as well as the image, so
none rests on a screenshot alone.

| ID | State(s) | Delta | Design source | Implementation |
| --- | --- | --- | --- | --- |
| VF-1 | 2 | Animated scan line missing | `Cupid Screens.dc.html:1688` | `scan_code_screen.dart:287-325` |
| VF-2 | 2 | Helper copy bottom-pinned instead of under the viewfinder | `:1685-1692` | `:330-365` |
| VF-3 | 4 | Invalid card ~80dp narrower | `:1701` | `:58`, `:382` |
| VF-4 | 4 | Viewfinder not dimmed behind the card | `:1700` | `:241-283`, `:308` |
| VF-5 | 5, 6, 7 | Message typography lighter/smaller | `:1716`, `:1727`, `:1739` | `:459-462` |
| VF-6 | 5, 6, 7 | Primary CTA ~38dp narrower | `:1717`, `:1728`, `:1740` | `:58`, `:424-476` |

**VF-1 — State 2 has no scan line.** `Cupid Screens.dc.html:1688` draws a 2px
`var(--pink)` bar at `top:50%`, inset `left:6%;right:6%`, with
`box-shadow:0 0 12px var(--pink)` and a `qrScan` sweep animation. `_Viewfinder`
(`scan_code_screen.dart:287-325`) renders an `AnimatedContainer` whose
`child` is `recognized ? Center(CupidIcon(check)) : null` — the viewfinder
interior is empty while scanning. This is the one motion affordance that tells a
user the camera is live, so its absence is visible, not cosmetic.

**VF-2 — State 2 helper copy sits in the wrong band.** The design places the
helper line inside the same centered flex group as the viewfinder, 22px beneath
it (`:1685-1691`), and pins only the manual-entry link to the bottom as a
separate `flex:none` element (`:1692`). `_ScanningChrome` (`:330-365`) puts both
in one `Column(mainAxisAlignment: MainAxisAlignment.end)`, so the helper copy
lands at the bottom of the screen, directly above the link and far from the
viewfinder it is meant to caption. Both images show the gap clearly.

**VF-3 — State 4 card is narrower than the design.** The design card is
`left:26px;right:26px` (`:1701`), i.e. ≈360dp wide on the 412dp Android frame.
The implementation caps it at `_cardMaxWidth = 280` (`:58`, applied at `:382`),
≈80dp narrower. Consequence in the pair: the design's copy sets on one line, the
build's wraps.

**VF-4 — State 4 does not dim the viewfinder.** The design drops the frame to
`rgba(255,127,182,.35)` while the card is up (`:1700`), pulling focus to the
error. `_CameraStates.build` passes `_Viewfinder` only `recognized`
(`:241-283`), so `:308` keeps the full-strength `colors.colorAccentPink` border
behind the card. The build's frame competes with the card for attention.

**VF-5 — States 5/6/7 message typography.** Design specifies
`font-size:15px;font-weight:700` with `line-height:1.4` and `max-width:250px`
(260px for State 6) at `:1716`, `:1727`, `:1739`. The implementation uses
`type.caption` at its default regular weight (`:459-462`). The message reads
visibly lighter and smaller than the design, and the different metrics change
wrapping — State 7's message fits one line in the build against two in the
design. AC5 names typography explicitly, so this is in scope for the AC.

**VF-6 — States 5/6/7 primary CTA is narrower.** Design gives the CTA
`width:100%;max-width:270px;height:52px`. The implementation's `_MessageState`
constrains the whole stack to `_cardMaxWidth = 280` and then applies
`Padding(EdgeInsets.all(CupidSpacing.lg))` (`:424-476`), leaving 280 − 48 =
232dp of content width, so the button is ≈38dp narrower than the design.

None of the six is a blocker for this lane — the design coverage is real and
reachable, the comparison completed, and the fix in every case is a bounded edit
inside `scan_code_screen.dart`. They are handed to Scrum Master/Reviewer as
normal visual-fidelity findings for an accept-or-rework decision. This lane made
no product code change: its `WriteScope` is `visual-fidelity/*` only.

## 5. Verification cross-reference

Element-level and behavioural claims above are backed by the command output in
`../coding-plan/test-results.md` §`P4 — Quét QR Entry Point, Wiring, And Preview
Coverage`:

- `flutter test test/features/pairing/presentation/joincode_screen_test.dart`
  → `+22: All tests passed!` (5 new, incl. the AC2 parity assertion that typed
  and scanned paths both submit `3F9A2B` through one stubbed `acceptInvitation`)
- `flutter test test/features/pairing/` → `+217: All tests passed!`
- `flutter test test/features/pairing/presentation test/design_system/`
  → `+279 -1`, the single failure being the pre-existing, out-of-scope
  `pet_preview_card.dart:229-230` no-fork guard hit (that file is byte-identical
  to `BaseHead`)
- `flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing`
  → 8 info `prefer_initializing_formals`, the unchanged baseline
- `flutter build apk --debug` → built

Re-run in this audit pass at `BaseHead` `9dbad43`, with no product code change
between them:

- `flutter test test/features/pairing` → `+217: All tests passed!`
- `flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing`
  → the same 8 info `prefer_initializing_formals`, unchanged baseline

There is no golden pinning for this story. The scan surface renders a live
camera texture in State 2 and a timer-driven card in State 4; neither goldens
deterministically. The states are pinned by widget tests against the fake
`CameraPermissionGate` instead.

## 6. Verdict

`VISUAL_FIDELITY: FAIL`, on the strength of VF-1 through VF-6 in §4.6. AC5
requires layout, spacing, colour/token usage and typography to match the design
reference; VF-1 and VF-2 are layout-level, VF-3/VF-4/VF-6 are spacing- and
size-level, and VF-5 is typography-level. Colour and token usage match
throughout — no delta in this pass involves a wrong or invented token.

Scope of the verdict: this is a comparison finding, not a lane blocker. The
implementation is functionally complete and its tests are green (§5), the design
coverage is now real and reachable, and all six states were genuinely compared.
The decision on whether to rework `scan_code_screen.dart` or accept the deltas
belongs to Scrum Master and the Reviewer, not to this lane.
