# STORY-031 — Visual Fidelity: Notifications

VISUAL_FIDELITY: PASS

## Scope of this comparison

| Field | Value |
| --- | --- |
| Screen | Notifications settings (`NotificationSettingsScreen`, Epic 6) |
| Design source | `cupid-app-design-system`, entry `Cupid App.dc.html` (locked) |
| Design-Screen id | `notifs` |
| Device / form factor | `emulator-5560`, Android phone, 405x900 capture |
| Theme / locale | dark, `vi` (AC1 scope; light + `en` are out of scope per OQ5) |
| Design reference | `design-reference-notifs-android.png` (406x900) |
| Implemented capture | `implemented-notifs-android-emulator-5560.png` (405x900) |

## How the screen id was resolved

No `Design-Screen:` line was handed to this story, so the id was resolved here.
`render-design-canvas.js --list-screens` on the locked entry returns 37 ids, of
which `notifs` is the only notification-settings candidate. Two things confirmed
it: the screen's own source doc comment already cites the `notifs` screen, and a
render of `--screen=notifs` produced the Vietnamese notification settings
surface with the CRITICAL / ENGAGEMENT / INFO groups and the 7 rows this screen
implements. `Design-Screen: notifs` is now recorded in `story_master.md`.

## Deltas found and fixed

Every value below came from `Cupid Screens.dc.html` (screen column at `:1381`,
group/row/toggle rules at `:2400-2408`) and was corrected directly in
`notification_settings_screen.dart` — fixed, not reported.

| # | Element | Was | Now (design) |
| --- | --- | --- | --- |
| 1 | Screen column padding | `EdgeInsets.all(24)` | `8px 16px 40px` |
| 2 | Gap between banner and groups | `16` | `13` |
| 3 | Cap banner padding | `16` uniform | `16px 18px` |
| 4 | Cap banner gradient axis | `135deg` | `150deg` (CSS 0deg = up, clockwise) |
| 5 | Cap banner icon size | default | `22` |
| 6 | Cap banner icon/text gap | `8` | `12` |
| 7 | Cap banner text | `caption` (13px, default height) | `12.5px`, `line-height 1.5` |
| 8 | Group card padding | `0` vertical / `16` horizontal | `4px 17px` |
| 9 | Group header padding | uniform | `top 15`, `bottom 9` |
| 10 | Group header dot/label gap | `4` | `9` |
| 11 | Group label (mono) | unsized `labelMono` | `9.5px`, `letter-spacing .14em` → `1.33` |
| 12 | Row vertical padding | `8` | `12` |
| 13 | Row icon/text gap | `8` | `12` |
| 14 | Row title | `body` 17px w400 | `14px` w700 |
| 15 | Row subtitle | `caption` 13px | `11px` |
| 16 | Row icon size | default | `20` |
| 17 | Toggle OFF track | `colorSurfaceAlt` | `colorLine` (matches `--line`) |
| 18 | Toggle knob | `colorText` | `#FFFFFF` (also fixes a dark knob in light theme) |

Values already correct and left alone: card radius (`radiusCard` 24 on material
== `--r-card`), `colorLine` (exact `--line` match), surface colour, group dot
colours (peach / pink / ghost), toggle geometry `50x30` / `padding 3` / knob
`24`, ON-state `gradientHot`, row separator `1px` top border, and the 7-row
order with its default on/off states.

## Intentional deviations from the design source (AC-mandated)

These two are *required* differences, not misses. The design source is wrong for
the shipped product and must not be copied back:

- **AC3 — DND-bypass claim removed.** The design banner reads "Tối đa 15 thông
  báo/ngày. Chỉ Synced Alarm được phép phá Do Not Disturb." The app ships the
  numeric cap only. v1 implements no DND override, so the clause would be a
  false capability claim. Dropped permanently, not deferred. Pinned by
  `notification_settings_screen_test.dart` → "shows only the numeric cap copy,
  no DND-bypass clause (DEC-6)".
- **AC4 — "nhắc nhở đồng bộ" wording.** The design labels the first critical row
  "Synced Alarm"; the app uses "Nhắc nhở đồng bộ" (`en`: "Synced Reminder"). The
  epic-3 rule forbids alarm framing. Pinned by the same test file → "names the
  first critical row a reminder, never an alarm", which asserts the vi label and
  rejects `báo thức` / `alarm` in any rendered text.

Both strings were already correct in `app_vi.arb` / `app_en.arb`, so no ARB
change was needed (and none was permitted — the ARB files are outside this
story's WriteScope). The screen's doc comment now records *why* the deviation
exists so a future reader does not "restore" it from the design source.

## Remaining deltas, deferred with named owners

Every residual difference in the two images is shared chrome already owned by
another story, or is blocked by this story's WriteScope. None is screen-local.

- **Bottom tab bar: design shows 5 tabs with "Tôi" active; app shows 3 tabs plus
  an account-hub FAB.** Already logged as STORY-017 finding **F7, owner
  STORY-001 `core/navigation/app_shell.dart`**. Changing it here would fork the
  shell.
- **Header back arrow tint and title treatment** (design: pink `←` at 26px).
  Already logged as **STORY-009 review item 2**, "Owner: a design-system story.
  Affects: every screen with a back affordance."
- **Sky-gradient backdrop and twinkle dots behind the content.** Already logged
  as **STORY-009 items 1 and 3** — an app-wide background, not a Notifications
  concern.
- **Inline `<strong>` emphasis on "15 thông báo/ngày" inside the banner.** The
  design renders that fragment in `--tx` against `--tx2` body text. Splitting it
  requires new ARB entries in `mobile/lib/l10n/arb/*.arb`, which is outside this
  story's WriteScope. Deferred to the story that owns the l10n surface.
- **Golden baseline not added.** `matchesGoldenFile` would write
  `test/features/account/presentation/screens/goldens/*.png`, a path outside this
  story's WriteScope. The two copy assertions above are the regression guard
  that could be added in scope; the golden should be baselined by whichever
  story owns the goldens directory.

## Verification

- `flutter analyze lib/features/account lib/design_system lib/preview lib/main_preview.dart` — No issues found.
- `flutter test test/features/account` — 86 passed, including the two new copy
  guards and the existing "renders 7 rows across the 3 groups" and "tapping a
  toggle flips and persists its state".
- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=notifs` — Built.
- Capture taken from that build under a device lease; the pre-fix capture was
  discarded and regenerated so the image above certifies the shipped code.
