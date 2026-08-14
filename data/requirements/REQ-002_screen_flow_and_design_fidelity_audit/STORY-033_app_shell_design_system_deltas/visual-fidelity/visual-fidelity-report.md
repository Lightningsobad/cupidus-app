VISUAL_FIDELITY: PASS

# Visual Fidelity Report — STORY-033 App Shell Design System Deltas

Lane: mobile-dev
Scope verified: AC2, AC3, AC4, AC5
Scope explicitly NOT verified here: AC1 (see "AC1 exclusion" below)
Date: 2026-08-14

## Design source

- Source: `cupid-app-design-system` (locked, `data/devops/system/design-fidelity-config.json`,
  `type: claude-design`, `screens_from: canvas`, `locked: true`).
- Entry: `Cupid App.dc.html`. The bundle contains 16 `.dc.html` files, so
  `--entry` had to be passed explicitly; the value comes from the `entry` field
  of `design-fidelity-config.json`, not from guessing.
- Screens are `<sc-if>` states of that one entry. Ids confirmed by
  `render-design-canvas.js --list-screens --location=cupid-app-design-system
  --entry="Cupid App.dc.html"`, which returned 37 ids including `notifs`,
  `alarm` and `welcome`.
- Toggles used: `dark,vi`, `--platform=android`. This matches the preview
  entrypoint defaults (`PREVIEW_BRIGHTNESS` defaults to `dark`, locale pinned
  to `vi`), so brightness/locale are not a source of false deltas.

## Design-Screen selection and what confirmed it

This story changes three shared design-system pieces, not one screen. Screens
were therefore selected by "which canvas state actually renders all three
changed pieces", not by story title.

| Canvas id | Why this screen | Confirmed by |
|---|---|---|
| `notifs` (primary) | Renders all three deltas at once: `CupidHeader` with `onBack`, seven `caption` sub-labels, and `gradientHot` on every enabled toggle | `notification_settings_screen.dart` uses `CupidHeader(... onBack: ...)`, `type.caption`, and `gradientHot` at `:343` |
| `alarm` (supporting) | Second independent `CupidHeader` + four `caption` sites; also acts as the negative control for `gradientDream` | `reminder_schedule_screen.dart:139` header, captions at `:242/:327/:453/:477`, `gradientDream` at `:233` |
| `welcome` (supporting) | Only surface that paints `gradientHot` full-bleed, so the gradient AXIS is unambiguous at 405x900 | `welcome_screen.dart:73-75` `DecoratedBox(decoration: BoxDecoration(gradient: colors.gradientHot))` |

`profile` was the first choice for AC3 (its zodiac helper text is the AC's
named case) and was rejected on evidence, not convenience: the `profile`
preview entry wraps `AccountRepository.fetchProfile()` in a `FutureBuilder`,
and that call needs an authenticated Firebase session supplied through
`--dart-define=PREVIEW_EMAIL` / `PREVIEW_PASSWORD`. No such credential exists
in the repository and none was available to this lane, so the screen never
left its `CircularProgressIndicator`. Rather than file a spinner as evidence
or write a caveat into a passing report, the AC3 surface was moved to two
screens that reach real content with no backend session. The `profile`
capture attempt was discarded, not kept.

## How the implemented captures were produced

State was faked through the preview entrypoint, never driven through the app.

1. `flutter build apk --debug --target-platform=android-arm64 -t lib/main_preview.dart --dart-define=PREVIEW=welcome`
   (built outside the device lease so the exclusive window stays short).
2. Inside one `capture-mobile-screen.sh --lease-exec` window on
   `emulator-5554`: install, `am force-stop`, cold launch, then
   `capture-mobile-screen.sh --route="cupidpreview://screen/<id>"` to switch
   states on the already-running app.
3. All captures 405x900, `--max-edge=900` default. No display resize was used,
   so the device was returned unmodified.

Note for anyone repeating this: at COLD start the app renders the
compile-time `--dart-define=PREVIEW` value, not the `cupidpreview://` id in
the launch intent — `didPushRouteInformation` only fires for a warm delivery.
The first capture pass silently produced `welcome` under the labels `notifs`
and `profile` because of this; it was caught by looking at the images and the
pass was redone with cold-launch-then-route ordering.

## Per-delta verdicts

### AC2 — `CupidHeader` Material back arrow in pink ink — PASS

- Change: `cupid_header.dart:168`, `color: colors.colorText` → `colors.colorAccentPink`.
- `design-reference-notifs-android.png` renders the back chevron in pink;
  `implemented-notifs-emulator-5554.png` renders it in the same pink.
- Independently reconfirmed on `alarm`, a second screen with its own
  `CupidHeader`, in both the reference and the capture.
- No other header element changed: title ink, weight and position are
  unchanged between the reference and the capture on both screens.

### AC3 — `caption` renders at the design source's size — PASS

- Change: `cupid_typography_tokens.dart:49`, `fontSize: 13` → `11.5`.
- On `notifs` the seven caption sub-labels ("Nhắc trên cả hai máy", "Khi bị
  bắn storm", "Mỗi ngày 21:00", "Khi pet bắt đầu đói", "Chỉ rung, không
  tiếng", "Mỗi khi vượt 25%", "Nhắc kỷ niệm \"ngày này năm xưa\"") and the
  three uppercase section labels (CRITICAL / ENGAGEMENT / INFO) match the
  reference in size and in line count. The longest of them, the quoted Love
  Timeline sub-label, stays on one line in both — that is the line-count half
  of AC3.
- `alarm` shows the same result on four further caption sites.

Call-site sweep backing the "no layout was keyed to 13px" claim. 29 files and
75 `type.caption` call sites exist. Every one was checked for a fixed height,
a `maxLines`, or a size derived from `caption.fontSize`:

- `cupid_tab_bar.dart:141-146` is the only site that reads
  `type.caption.fontSize`, and only as the Material fallback next to the fixed
  `_iosTabLabelSize = 10`. It sits inside a `ConstrainedBox(minWidth/minHeight:
  tapTarget)` and a `Column(mainAxisSize: min)`, so the effect is that Material
  tab labels move closer to the iOS value. Benign.
- `expense_list_item.dart:102-109` is the only site with `maxLines: 1` +
  `TextOverflow.ellipsis`, inside a `ConstrainedBox(minHeight: tapTarget)`.
  Smaller text strictly improves fit there; it cannot newly truncate.
- `reminder_weekday_chips.dart`, `pet_stats_row.dart`, `ghost_state_row.dart`,
  `message_bubble.dart` and `profile_edit_screen.dart` all size
  intrinsically — `Container`/`Padding` with `CupidSpacing` values, `Column`/
  `Row` with `mainAxisSize: min`, tap targets expressed as `minHeight` rather
  than fixed `height`.
- `profile_edit_screen.dart:223-226` (the AC's named zodiac helper) is a plain
  `Text` in a `Column` with no `maxLines` and no fixed height, and
  `:272-278` (`_FieldCard`'s uppercase label) sits in
  `Container(padding: EdgeInsets.all(CupidSpacing.md))` + `Column`. Neither is
  keyed to 13px, so both return to the design's line count. This is a static
  read of the widget tree, not a capture — see the `profile` note above.

### AC4 — CTA gradient axis is 95deg, not 120deg — PASS

- Change: `cupid_color_tokens.dart` gained a dedicated `_gradient95Begin` /
  `_gradient95End` pair, and both the `.dark()` (`:100`) and `.light()`
  (`:165`) `gradientHot` blocks now use it.
- On `notifs`, every enabled toggle in the reference runs pink at the left
  edge to purple at the right on a near-horizontal axis; the capture matches.
- `welcome` makes the axis unmistakable at full-bleed: the capture's wash runs
  left-to-right with only a slight downward tilt, which is 95deg. A 120deg
  wash would visibly climb across the frame.
- Regression control: `gradientDream` was deliberately NOT repointed. It still
  uses `_gradient120Begin` in both the dark (`:89-90`) and light (`:154-155`)
  constructors, and the `alarm` capture confirms it visually — the alarm hero
  card (`reminder_schedule_screen.dart:233`, `gradientDream`) still renders on
  the steeper 120deg diagonal. The two tokens were separated rather than
  sharing one mutated constant precisely so this could not regress.

### AC5 — existing tests unchanged and still passing — PASS

`solution.md` section 5 predicted that all four governing tests would need no
edit. That prediction held; nothing was silently adjusted.

- `flutter test` → `EXIT_CODE=0`, `+920: All tests passed!`
- `flutter analyze lib/design_system` → `No issues found!`
- Repo-wide `flutter analyze --no-fatal-infos` reports 94 pre-existing
  infos/warnings, none in a file this story touched
  (`prefer_initializing_formals`, one `deprecated_member_use` in
  `reminder_firing_overlay.dart`, and `unused_import` across the generated
  `openapi/cupid_api/` package).
- `git status --short` shows exactly three modified source files and no
  modified test file. There is no assertion edit to disclose.

## AC1 exclusion — deliberate, not an omission

AC1 (the `skyGradient` app-shell backdrop: aurora wash plus sparkle dots) is
intentionally NOT implemented and NOT verified by this story. Per the ratified
scope decision carried in this story's handoff and `solution.md` section 1, AC1
was transferred to STORY-032, which owns both the gradient wash and the three
twinkle-star particles. `cupid_theme.dart`, `cupid_app.dart`, and any
sky/backdrop/star widget were left untouched here, because they are inside
STORY-032's active write scope on the shared integration branch and editing
them would collide. AC1 is verified at REQ-002 requirement integration review,
not at this story's review gate.

This is directly visible in the evidence and should not be read as a STORY-033
failure: in `design-reference-notifs-android.png` the area behind the header
carries a purple/pink sky wash, while `implemented-notifs-emulator-5554.png`
shows flat dark navy. That single difference is AC1 and belongs to STORY-032.

## Out-of-scope deltas observed (not this story's, recorded for integration review)

These are real differences between reference and capture that no STORY-033
acceptance criterion covers and no STORY-033 file could fix. They are listed
so the requirement integration review can route them, not as deferred items
against this story.

| # | Screen | Delta | Owner |
|---|---|---|---|
| 1 | notifs, alarm | App-shell backdrop is flat dark navy instead of the aurora sky wash | STORY-032 (AC1) |
| 2 | notifs | Bottom tab bar shows 3 tabs (Trang chủ / Trò chuyện / Thư viện ảnh) with no active pill; design shows 5 (Nhà / Trò chuyện / Pet / Ví chung / Tôi) with the active tab in a pill | App shell / navigation story |
| 3 | notifs | A pink circular FAB appears bottom-right in the app; absent from the design canvas | App shell story |
| 4 | notifs | Info banner copy is truncated to "Tối đa 15 thông báo/ngày."; design also carries the Do Not Disturb sentence | Content/localisation |
| 5 | alarm | Weekday chips stack vertically instead of a single horizontal row. Caused by `ConstrainedBox(minWidth: tapTarget)` per chip exceeding the card's inner width, not by the caption size change — a smaller caption can only improve horizontal fit | Reminder screen story |
| 6 | alarm | Hero card renders the bright `gradientDream` wash where the design shows a dark translucent card; row content is in a backend-error state ("Không tải được nhắc nhở đồng bộ.") because no authenticated session was available | Reminder screen story |
| 7 | welcome | Composition differs broadly (centred vs left-aligned title, CTA stack position, filled vs outlined Google button, missing sub-copy). `welcome` is included here only as the full-bleed axis demonstration for AC4 | Auth/onboarding story |

## Artifacts

- `visual-fidelity/design-reference-notifs-android.png` (406x900)
- `visual-fidelity/implemented-notifs-emulator-5554.png` (405x900)
- `visual-fidelity/design-reference-alarm-android.png` (406x900)
- `visual-fidelity/implemented-alarm-emulator-5554.png` (405x900)
- `visual-fidelity/design-reference-welcome-android.png` (406x900)
- `visual-fidelity/implemented-welcome-emulator-5554.png` (405x900)
