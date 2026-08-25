VISUAL_FIDELITY: PASS

# Visual Fidelity — REQ-012 / STORY-002 Create-Code (Couple Types) Screen QR Display

Design-Screen: `invite`
Design-Surface: `cupid-app` (`cupid-app-design-system`, entry `Cupid App.dc.html`,
`locked: true` per `data/devops/system/design-fidelity-config.json`)
Design source block: `cupid-app-design-system/Cupid Screens.dc.html` lines
170-224 (`isInvite`)
Platform: android
Theme/locale compared: **dark theme + `vi`** — the AC5 configuration. Both
images were produced in that one configuration; light/`en` is not compared.
Date: 2026-08-26
Closes reviewer finding B1 (and resolves B4) from `../review/review-report.md`.

## 1. Artifacts

| Role | File | Size |
| --- | --- | --- |
| Design reference | `design-reference-invite-android.png` | 406x900 |
| Implemented capture | `implemented-invite-emulator-5554.png` | 405x900 |

Both are the full device frame at the Android canvas' own 412dp viewport, so
they are directly comparable in layout units rather than only in pixel count.

## 2. How each image was produced

Design reference (Playwright render of the locked canvas, `invite` state
selected before the shutter fires):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=cupid-app --screen=invite --platform=android \
  --theme=dark --lang=vi --label=invite --out=<story>/visual-fidelity
→ DESIGN_CANVAS: OK design-reference-invite-android.png 406x900
```

Implemented capture. State was FAKED, never navigated to: `main_preview.dart`
registers an `invite` entry whose `_buildInvite` seeds the design canvas' own
sample invitation (`CPD-8F2K`, the frozen 24h TTL, `coupleType: SAME_CITY`), so
the capture depends on no login, no pairing and no live backend.

```
flutter build apk --debug -t lib/main_preview.dart --target-platform android-arm64
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am start -a android.intent.action.VIEW \
  -d "cupidpreview://screen/invite" com.snapsofts.cupid
capture-mobile-screen.sh --out=<story>/visual-fidelity --label=invite \
  --device=emulator-5554 --width=540 --density=210 --settle-ms=3000
→ MOBILE_CAPTURE: OK implemented-invite-emulator-5554.png 405x900 177996
```

`--width=540 --density=210` puts the device at 411dp logical width, i.e. the
design canvas' own 412dp Android viewport. Install, launch and capture ran
inside one `--lease-exec` device lease, and the display size was restored on
exit. The emulator was already booted and provided; no device was created,
booted or repaired.

One earlier capture was discarded rather than reported: the deep link sent in
the same breath as a cold `am start` landed on the preview *index* screen, not
on `invite`. Re-sending `cupidpreview://screen/invite` to the already-running
instance (`intent has been delivered to currently running top-most instance`)
switched to the screen. The discarded frame is not in this folder.

## 3. Machine checks, not eyeballing

**The rendered QR decodes.** Running Core Image's `CIDetectorTypeQRCode` over
the delivered `implemented-invite-emulator-5554.png` — the downscaled 405x900
screenshot, with the heart badge occluding the centre modules — returns:

```
DECODED: CPD-8F2K
```

which is byte-identical to the text code the same frame prints below the art.
That is AC1 and AC2 confirmed at render level, on device, through the badge
occlusion, and not merely at widget level. The same detector over
`design-reference-invite-android.png` returns `NO_QR_FOUND` — see §5 delta 1.

**Frame geometry, measured off both PNGs.** The white QR paper's bounding box
was extracted from each image by scanning for its contiguous near-white run:

| Metric | Design reference | Implemented | Verdict |
| --- | --- | --- | --- |
| Paper height | 182 px (rows 145-326) | 182 px (rows 112-293) | exact match |
| Paper width at its widest row | 177 px | 177 px | exact match |
| Paper horizontal centre | x = 203.5 of 406 | x = 202.5 of 405 | centred in both, within 1 px |
| Centre badge bounding height | 39 px | 40 px | match (`_badgeSize 40`, within antialias) |
| Badge vertical centre vs paper centre | 235 vs 235.5 | 201.5 vs 202.5 | centred in both, within 1 px |

182 px is the design's `width:186px;height:186px` frame at this capture's
0.985 device scale, reproduced to the pixel by `_frameSize = 186`. The 33 px
vertical offset between the two paper boxes is fully accounted for by delta 2
below (the design draws a screen header the app deliberately does not).

## 4. Matched, element by element

States compared: both images show the **loaded `InviteReady` state with a
persisted couple-type selection** — code present, countdown running, "Cùng
thành phố" card selected. No other state is claimed here (see §5 delta 6).

| Element | Result |
| --- | --- |
| Card: `--surf` fill, `--r-card` radius, `overflow:hidden` clip at card radius | match — the 290px glow stops at the card edge in both |
| QR paper: 186dp box, 28dp radius, `#FFFDFE` fill | match (measured §3) |
| QR paper pink drop shadow (`0 12px 34px rgba(255,107,168,.26)`) | match |
| Ambient breathing glow behind the frame, pink→purple radial, blurred, clipped by the card | match |
| Centre heart badge: 40dp gradient-hot rounded square, white heart glyph | match (measured §3) |
| Badge white ring cutout (`0 0 0 5px #FFFDFE`) separating badge from art | match |
| Scan band: pink gradient with a 1.5px pink leading edge, overhanging the art on both sides | match — present in both frames, at different sweep phases (it is an animation, not a fixed position) |
| QR art horizontally centred in the card | match |
| Pairing code `CPD-8F2K`: Roboto Mono, wide tracking, pink→purple gradient text | match |
| Share CTA: full-width gradient-hot pill, share glyph + "Gửi link mời", with glow | match |
| Copy button: 48dp square, 1.5px `--line` border, muted `content_copy` glyph | match |
| Share/copy row: CTA flexes, copy is fixed square, one gutter between them | match |
| Section heading "Tụi mình thuộc kiểu nào?" (16px, weight 700) | match |
| Section subtitle "Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn." (12.5px, `--tx2`) | match |
| Couple-type grid: 2 columns, equal width, one gutter, 4 cards | match |
| Selected card treatment: pink→purple 140deg wash, 1.5px pink border, glow, gradient-hot icon tile | match — "Cùng thành phố" selected in both |
| Unselected card treatment: `--surf` fill, transparent border, `--surf2` icon tile, muted glyph | match |
| Card icon tile: 38dp box, 13dp radius | match |
| Card label 14.5px / hint 11.5px `--tx2` | match |
| Screen background: shared sky-gradient wash, no solid Scaffold fill | match |

## 5. Deltas, each intentional and recorded

1. **QR module pattern, dot shape and eye colour.** The design's `{{ qrArt }}`
   is not a QR code. `Cupid Screens.dc.html:1999-2025` builds `QR_ART`
   procedurally from a fixed PRNG seed (`seed = 58291`), drawing round dots of
   `#2A1E4A` and three rounded-square eyes with `#FF6BA8` pupils. It encodes
   nothing — the detector in §3 finds no QR in it at all. The implementation
   necessarily draws the real encoding of `CPD-8F2K` in square modules, which is
   what makes it scannable. The module pattern therefore *cannot* match by
   construction, and the placeholder's decorative dot/eye styling is not a
   payload-bearing spec.
   Within that, one genuine colour difference remains: `QrPalette.moduleInk` is
   `#000000` where the placeholder art draws `#2A1E4A`. It is documented in
   `qr_palette.dart:21-24` as a deliberate maximum-contrast choice. Recorded
   here explicitly rather than waived silently: `#2A1E4A` on `#FFFDFE` also
   clears scan contrast comfortably, so tightening the ink to the canvas' own
   hex is an available follow-up. It changes no layout, no spacing and no
   token in `CupidColorTokens`, and it is not a rendering defect — so it was
   not taken inside this rework's write scope, which the handoff limits to
   evidence gaps.

2. **Screen header "Ghép đôi".** The design draws a header row above the card;
   the app renders only the in-body back arrow. This is pre-existing and
   deliberate: `NO_CHROME` (AC4/ADR-7) removes the header for in-chain
   onboarding nodes while keeping the back edge, implemented by
   `_InChainBackButton` (`invite_screen.dart:324-326`) and pinned by the test
   `carries no header or tab chrome (AC4 NO_CHROME/NO_TABS)`. It predates
   STORY-002 and accounts for the entire 33 px vertical offset in §3.

3. **"Đang đợi Linh quét…" pill vs "Mã ghép đôi của bạn" label.** The design
   places an animated three-dot waiting pill between the QR and the code; the
   app places its existing code label there. This is the order
   `ux/ux-spec.md` "Screen Structure" mandates for this story (QR → label →
   code → caption → expiry → Share/Copy), and the label is pre-existing REQ-009
   content that story_master.md "In Scope 2" keeps unchanged. Not introduced by
   this story.

4. **Caption and expiry wording.** Design: one line, "Đọc mã này cho Bae, hoặc
   để họ quét QR · hết hạn sau 14:52". App: "Mã 6 ký tự" plus "Hết hạn sau 23h
   59p". The countdown format follows the frozen backend 24h TTL rather than
   the mockup's 15-minute sample; both are pre-existing REQ-009 strings.

5. **"Giả lập: Linh vừa vào" dashed link absent.** Per
   `architecture/solution.md` Key Discovery 2, this dev-only simulate-join
   affordance does not exist in the app and was deliberately not added, so no
   production-gating code was introduced.

6. **Couple-type card labels.** Design renders "Mới yêu" / "Yêu lâu rồi"; the
   app renders "Mới hẹn hò" / "Gắn bó lâu dài" with their hints. Card content is
   REQ-009-authored and explicitly listed under story_master.md "Out of Scope";
   the grid's structure, order, and selected/unselected treatment do match.

7. **Continue CTA copy.** The design's CTA reads "Tiếp tục → Fingerprint Vow".
   OQ2 is RESOLVED as NO — that wiring is stale and must not be implemented
   (AC4). The app's CTA reads "Tiếp tục" and lands on Waiting-for-partner. The
   CTA is below the fold in both frames, so this delta is not visible in either
   image; it is asserted by test instead (`AC4: Continue advances to waiting on
   a successful save`, and `AC1/AC2: the post-code action lands on waiting and
   no vow surface`).

## 6. AC5 verdict

AC5 asks that layout, spacing, colour/token usage and typography match the
canvas in dark + `vi`, **including the new QR element**. Every metric the design
source actually specifies for the QR frame (`Cupid Screens.dc.html:173-179`) is
reproduced — frame box, radius, paper, shadow, ambient glow, badge box, badge
ring, scan band and its leading edge — and the two independently measured
geometries agree to the pixel. The card, code, actions, section and grid around
it match. The remaining differences are the seven above: one is a colour
follow-up on decorative placeholder art, and six are pre-existing or
ACs-mandated departures owned by other requirements.

VISUAL_FIDELITY: PASS
