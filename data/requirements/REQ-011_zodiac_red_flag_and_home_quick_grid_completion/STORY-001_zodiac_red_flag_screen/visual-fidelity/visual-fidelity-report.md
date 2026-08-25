VISUAL_FIDELITY: PASS

# Visual Fidelity — STORY-001 Zodiac Red Flag Screen (P3)

Design-Screen: `zodiac`
Platform: android
Theme/locale compared: dark theme + `vi` (the enabled configuration; light/`en`
is out of scope per `story_master.md` "Out of Scope")

## 1. Artifacts

| Role | File | Size |
| --- | --- | --- |
| Design reference | `design-reference-zodiac-android.png` | 406x900 |
| Implemented capture | `implemented-zodiac-emulator-5554.png` | 405x900 |
| Golden (ready) | `mobile/test/features/zodiac/presentation/goldens/zodiac_red_flag_ready.png` | 412x915 |
| Golden (incomplete profile) | `mobile/test/features/zodiac/presentation/goldens/zodiac_red_flag_incomplete.png` | 412x915 |

## 2. How the capture was produced

State was FAKED, never navigated to. `main_preview.dart` registers a `zodiac`
canvas entry backed by `_PreviewZodiacRepository`, so the capture depends on no
login, no pairing and no live `GET /zodiac/red-flag/today`.

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=zodiac --target-platform android-arm64
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am start -a android.intent.action.VIEW \
  -d "cupidpreview://screen/zodiac" com.snapsofts.cupid
capture-mobile-screen.sh --out=<story>/visual-fidelity --label=zodiac \
  --device=emulator-5554 --width=540 --density=210 --settle-ms=3000
```

`--width=540 --density=210` puts the device at 411dp logical width, i.e. the
design canvas' own 412dp Android viewport, so the two images describe the same
layout rather than the same pixel count at a different text scale. The whole
install/launch/capture window ran under one `--lease-exec` device lease and the
display size was restored on exit.

Two earlier attempts were discarded rather than reported:
- a capture taken 8s after launch photographed the Flutter splash (debug JIT
  start-up on this emulator is slower than that);
- a capture at `--width=540` without `--density` rendered at ~270dp, which
  inflated every glyph and would have produced a meaningless comparison.

## 3. Matched, element by element

| Element | Result |
| --- | --- |
| Screen chrome: back arrow + "Zodiac Red Flag" title | match |
| Header card: 155deg purple→pink gradient fill, purple border, card radius | match |
| Header card decorative `auto_awesome` glyph, top-right, clipped, low opacity | match |
| Eyebrow: amber warning glyph + mono `RED FLAG · 29/07` with wide tracking | match |
| Header headline: display face, bold, `colorText` | match |
| Header body: 13px muted body copy | match |
| Card 2 label "Chỉ số xung đột hôm nay" at 12px muted | match |
| Card 2 score `7` peach display + `/10` suffix at 17px muted | match |
| Card 2 partner discs: two `CupidZodiacIcon` at 46px with `bolt` between | match |
| Partner names `Minh` / `Linh` at 10px muted under each disc | match |
| Conflict bar: 10px tall, 6px radius, mint→butter@55%→peach, filled to 70% | match |
| Bar captions `êm` / `drama` in mono 10px muted | match |
| Card 3: three rows, 36px tinted tiles (mint / pink / amber), bold lead phrase | match |
| Card 3 dividers: 1px `colorLine` between rows, none after the last | match |
| Disclaimer: centered 11px muted, copy identical to design source L633 | match |
| Card gaps and screen padding | match |
| Zodiac icon element colouring (water = pink for both `cancer` and `pisces`) | match |

No raw hex and no Unicode zodiac glyph exist anywhere under
`mobile/lib/features/zodiac` — pinned by two source-guard tests in
`mobile/test/features/zodiac/presentation/zodiac_route_test.dart`, not just by a
one-off grep.

## 4. Deltas, all intentional and recorded

1. **Bottom tab bar.** The design reference draws the app tab bar with "Nhà"
   active; the implementation does not. The screen is pushed above `AppShell`
   with `Navigator.pushNamed`, so no tab bar exists at runtime — the same
   precedent as the `ghostset` and `expense` canvas entries. Faking a tab bar in
   the preview harness would have made the capture agree with the reference
   about something the product does not do. Not a defect; no action.

2. **Content prose.** The design canvas ships hand-written sample copy
   ("Song Ngư đang ở pha nhạy cảm…", "Gọi video trước 21:00…"). The capture
   shows the shipped backend content for the same couple, read verbatim from
   `backend/src/modules/zodiac/content/conflict-index.content.ts` and
   `daily-tips.content.ts`. Replaying the canvas prose would have put strings in
   the capture that the product can never render. The numeric half of the
   comparison is still exact: the real `cancer`×`pisces` water/water score is
   `7` of `10`, which is the score and the 70% bar fill the reference draws.

3. **No design reference for state 2c.** The canvas has no separate screen id
   for the incomplete-profile state, so there is nothing to compare a device
   capture against. It is verified by widget test
   (`zodiac_red_flag_screen_test.dart`, "mounts none of Card 1/2/3 and names no
   partner") and pinned by `goldens/zodiac_red_flag_incomplete.png`. No
   `MOBILE_VISUAL_AUDIT_STATE_MISSING` blocker is raised: the state exists and is
   reachable, only its reference does not exist.

4. **Emoji rasterization.** The reference renders the disclaimer's trailing 🔮
   with Playwright's emoji font, the device with Android's. The code point is
   identical to `Cupid Screens.dc.html` L633. Font-stack difference, not layout.

5. **Follow-up, not a delta.** `bolt`, `videocam`, `block`, `local_cafe`,
   `nightlight`, `chat_bubble`, `self_improvement`, `auto_awesome`, `warning` and
   `info` are declared as file-private `IconData` inside the zodiac widgets
   because `design_system/icons/cupid_icons.dart` is outside this phase's write
   scope. Promoting them into `CupidIcons` is a mechanical follow-up with no
   behaviour change.

## 5. Golden pinning

`mobile/test/features/zodiac/presentation/zodiac_red_flag_screen_golden_test.dart`
renders the same fixture the preview entrypoint serves, at the 412x915 reference
viewport, with the four bundled variable fonts loaded off disk (widget tests ship
no asset bundle, so without that every glyph rasterizes as a box). It goldens
`CupidAppBackground` rather than the screen subtree, because the backdrop is
mounted above the navigator and the scaffold under it is transparent — goldening
the subtree alone pinned a white background the device never shows.

Goldens were written once with `--update-goldens` after this PASS verdict and
then re-verified without it. Refresh them only after a new capture/compare pass,
never to turn a red test green.
