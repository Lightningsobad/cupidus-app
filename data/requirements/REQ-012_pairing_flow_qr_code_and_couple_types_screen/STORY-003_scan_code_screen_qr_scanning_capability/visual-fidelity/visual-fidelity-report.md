VISUAL_FIDELITY: PASS

# Visual Fidelity — STORY-003 Scan-Code Screen QR Scanning (P4)

Design-Screen: `joincode` (entry point) + scan overlay States 2, 4, 5, 6, 7
Platform: android (`emulator-5554`)
Theme/locale compared: dark theme + `vi` — the enabled configuration; light and
`en` are out of scope per `../story_master.md` "Out of Scope".

## 1. Artifacts

| Role | File | Size | Bytes |
| --- | --- | --- | --- |
| Entry point (AC5) | `implemented-joincode-two-pill-row-emulator-5554.png` | 405x900 | 134742 |
| State 2 — live scanning | `implemented-scan-live-emulator-5554.png` | 405x900 | 25142 |
| State 4 — invalid/expired | `implemented-scan-invalid-emulator-5554.png` | 405x900 | 44449 |
| State 5 — permission denied | `implemented-scan-denied-emulator-5554.png` | 405x900 | 115159 |
| State 6 — permission blocked | `implemented-scan-blocked-emulator-5554.png` | 405x900 | 119685 |
| State 7 — camera unavailable | `implemented-scan-unavailable-emulator-5554.png` | 405x900 | 114464 |

No `design-reference-*.png` exists for the scan overlay. `Cupid Screens.dc.html`
draws the entry pill (line 1632) but has no `sc-if` block for the scan surface at
all — States 1-7 are authored only in `../ux/ux-spec.md`. The overlay is
therefore compared against the UX spec prose and against the tokens the spec
names, not against a rendered canvas. Only the entry-point capture has a
line-addressable design source (`Cupid Screens.dc.html:1630-1633`).

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

### Entry point — `Cupid Screens.dc.html:1630-1633`

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

### Scan overlay — against `../ux/ux-spec.md`

| Spec | Element | Result |
| --- | --- | --- |
| L68-85 State 2 | Full-viewport preview surface, centered rounded viewfinder in `var(--pink)` at ~70% of the shorter edge | match |
| L78-80 | Helper copy "Đưa camera vào mã QR của người ấy" at caption size, `colorTextMuted` | match |
| L81-84 | "Nhập mã thủ công" pinned low, pink weight-700 13px, reads as secondary action | match |
| L52-54 | Top-left close icon present, ≥44x44 hit target | match, in all five captured states |
| L99-116 State 4 | Card centered, `colorSurface` fill, `colorLine` border, error icon, copy "Mã QR không hợp lệ hoặc đã hết hạn", "Thử lại" primary + manual-entry secondary | match on every element **except the corner radius — see §4.1** |
| L102-103 | Camera surface keeps running behind the card | match — the viewfinder is visible around the card |
| L122-135 State 5 | Static message state, no preview, muted icon, "Cupid cần quyền camera để quét mã QR", `grad-hot` primary "Nhập mã thủ công" | match |
| L137-147 State 6 | Same layout, "Cupid cần quyền camera trong Cài đặt để quét mã QR", primary "Mở Cài đặt", pink secondary "Nhập mã thủ công" | match |
| L149-155 State 7 | Same layout, "Không thể mở camera trên thiết bị này", single action "Nhập mã thủ công", no Settings deep-link | match |
| L157-165 Fallback | A manual-entry path is visibly present in all five captured states | match |
| L169-177 Tokens | No new colour or radius introduced; only `colorPink`, `colorMint`, `colorTextMuted`, `colorSurface`, `colorLine`, `gradientHot` | match |

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
carried forward unchanged") and found it CLEAN, not reopened. It is therefore
no longer an open flag; the recommended `ux-spec.md` amendment above stands as
documentation follow-up, not as a blocker on this story.

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

There is no golden pinning for this story. The scan surface renders a live
camera texture in State 2 and a timer-driven card in State 4; neither goldens
deterministically. The states are pinned by widget tests against the fake
`CameraPermissionGate` instead.
