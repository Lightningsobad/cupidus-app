# REQ-010 — Requirement-Level Cross-Screen Mobile Visual Audit

Scope: `REQ-010_home_dashboard_deferred_scope_completion`, all 7 stories merged.
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`
HEAD: `8ed5c777d60fcf477c0797e2892353849595ce4c` (working tree clean)
Device: `emulator-5554`, Android 16, 1080x2400 @ 420dpi (411dp logical)
Date: 2026-08-25
Closes integration-review gate **B-2** (no requirement-level cross-screen visual audit).

**Result: PASS — no blocking breakage.** Two new deferred findings (F-6, F-7),
one correction to a STORY-007 review claim (F-2), one coverage gap (`en`).

---

## Method

The six Home-scoped stories and STORY-007's app-wide backdrop rollout had never
been seen together in one running app. Per-story evidence only covers each
story's own narrow diff, so this pass drives the merged build directly.

Screens were reached through the project's own preview entrypoint
(`mobile/lib/main_preview.dart`) rather than by navigating a live app, which is
what that entrypoint exists for: 35 of the design's screens sit behind auth,
pairing and live backend data. Screens were switched at runtime with the
registered `cupidpreview://screen/<id>` deep link, and captured with the
sanctioned `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh`.

Builds run in this session (all green, real `flutter build apk --debug --flavor local`):

| Build | Defines | Result |
| --- | --- | --- |
| dark #1 | `PREVIEW_BRIGHTNESS=dark`, home/pet/timeline/profile fixtures | `✓ Built app-local-debug.apk` |
| dark #2 | + `PREVIEW_CHAT_GHOST=on` | `✓ Built app-local-debug.apk` |
| light | `PREVIEW_BRIGHTNESS=light`, same fixtures | `✓ Built app-local-debug.apk` |
| dark #3 | same as dark #2 | `✓ Built app-local-debug.apk` |

Runtime hygiene: DevOps's `app-local-debug.apk` was backed up before the first
preview build and **restored and reinstalled afterwards** (sha1
`fc78bbb287db1aa583450737f8f68ec125806ef3`); the restored app was relaunched and
confirmed to boot to its normal unpaired pair-gate route. Device display size was
returned to 1080x2400 @ 420dpi. No device was created, booted, wiped, or repaired.

Contrast figures below are measured from the captured pixels (WCAG 2.1 relative
luminance). "Background under glyphs" is the modal non-glyph colour inside the
text run's bounding box, which is the colour a reader actually sees behind the
text — not the brightest decorative pixel that happens to fall in the same box.

---

## Screens covered

| Screen | Theme | Capture |
| --- | --- | --- |
| home (cumulative, all 6 stories) | dark | `implemented-home-dark-vi-emulator-5554.png` |
| home, scrolled to lower cards | dark | `implemented-home-dark-vi-scrolled-emulator-5554.png` |
| home @ 390dp (D2 check) | dark | `implemented-home-dark-vi-390dp-emulator-5554.png` |
| home @ 320dp | dark | `implemented-home-dark-vi-320dp-emulator-5554.png` |
| home @ 260dp (header bound) | dark | `implemented-home-dark-vi-260dp-header-bound-emulator-5554.png` |
| home | light | `implemented-home-light-vi-emulator-5554.png` |
| home, scrolled | light | `implemented-home-light-vi-scrolled-emulator-5554.png` |
| chat (D1 status banner) | dark / light | `implemented-chat-{dark,light}-vi-emulator-5554.png` |
| timeline (core nav, scrollable) | dark / light | `implemented-timeline-{dark,light}-vi-emulator-5554.png` |
| welcome (onboarding, AD-3 allowlisted) | dark / light | `implemented-welcome-{dark,light}-vi-emulator-5554.png` |
| paired (pair-gate, nested shells) | dark / light | `implemented-paired-{dark,light}-vi-emulator-5554.png` |
| me (account/detail) | dark | `implemented-me-dark-vi-emulator-5554.png` |

Region crops: `crop-chat-dark-vi-status-banner.png`,
`crop-home-dark-vi-hero-d1-region.png`,
`crop-home-light-vi-hero-secondary-text.png`,
`crop-home-dark-vi-mood-card.png`,
`crop-home-dark-vi-antighost-chevron-on-wash.png`.

---

## F-1 — Cumulative Home screen: PASS

All six Home-scoped stories render together correctly, in both themes, at the
device's native 411dp and at 390/320/260dp.

Present and correct in one frame: paired avatar cluster, partner name, couple-type
subtitle ("Cùng thành phố"), share action, bell with unread badge, the 247-day
counter, the encouragement line, the milestone chip ("Còn 53 ngày nữa tới mốc 300"),
Anti-Ghosting entry, daily-mood card with both halves, synced reminders, Dream Jar,
Pet card, shared expenses, and photo gallery. The shared sky wash reaches the whole
screen behind them; the hero glow stays inside its `ClipRect`.

No `RenderFlex` overflow stripes, no clipped or overlapping content, no wrong-density
artwork, no safe-area intrusion at either the status bar or the gesture bar, and the
bottom tab bar renders complete with the Home tab selected.

## F-2 — STORY-007 D1, chat status banner: claim NOT reproduced

STORY-007's review report (lines 163-170) corrected the story's own test-results,
stating that in `ad6-chat-dark-vi.png` "the status banner row immediately under the
chat app bar does extend low-contrast secondary text into the upper-right region
where the magenta lobe is brightest", and asked UX to size D1 as "reachable in a
real screen today" rather than "theoretical worst-case pixel only".

Measured, both on a fresh runtime capture and on the reviewer's own reference file:

| Source | Background under the status-text glyphs | `--tx2` contrast |
| --- | --- | --- |
| runtime `implemented-chat-dark-vi` | `#241B42` | **7.09:1** (passes AA) |
| STORY-007 `ad6-chat-dark-vi.png` | `#241B42` | **7.09:1** (passes AA) |

The "đang online" text does sit in the upper-right where the magenta lobe is
brightest, but it sits on the presence chip's own opaque dark pill, not on the wash.
Across the entire chat top third, **0%** of `--tx2`-class glyph pixels fall below AA
4.5:1, and the worst local contrast is 5.99:1.

The ~2.7:1 pixels inside that region are the presence avatar's own teal/blue gradient
disc, which is decorative and sits inside the chip — not the background of any text.
See `crop-chat-dark-vi-status-banner.png`.

**Recommendation:** revert D1's severity to the original test-results wording. The
deferral itself still stands (pre-existing, out of scope, UX-owned), but the
"reachable in a real screen today" escalation is not supported by the pixels.

## F-3 — STORY-007 D1, where it IS reachable: Home, and it is non-text

D1's sub-3:1 case does reproduce, but on Home rather than chat. Worst `--tx2`-class
local contrast in Home's dark top third is **2.95:1** at (145,332) — inside the large
gradient "247" numeral, on the pink-to-lavender transition of its strokes. That is
within rounding of STORY-007's own measured 2.94:1.

Two things keep this non-blocking:

- It is very large bold display text, so the applicable threshold is AA-large 3.0:1,
  which it misses by 0.05.
- It is a decorative gradient numeral, not informational secondary text.

The actual secondary body text on the same wash — "Chịu đựng nhau được 247 ngày rồi,
giỏi quá" — measures **7.02:1** against `#2C1748`, comfortably above AA. Primary text
`--tx` is 12-14:1 throughout.

D1 therefore remains correctly DEFERRED and UX-owned, and does not block this
requirement. See `crop-home-dark-vi-hero-d1-region.png`.

## F-4 — STORY-006 x STORY-004/005 `Expanded` wrap (`b0c79fc`): visually correct

`b0c79fc` wraps `_PresenceRow` in `Expanded` (`home_screen.dart:391-392`) so it
receives bounded width from the merged header row. A short fixture name does not
exercise that path, so the header was driven to its bound by narrowing the display.

| Width | Header behaviour |
| --- | --- |
| 411dp (native) | name + couple type + share + bell all fit, actions right-aligned |
| 390dp | unchanged, clean |
| 320dp | clean; mood-card values ellipsize ("Chưa …") |
| 260dp | couple-type subtitle wraps **within its bound** to three lines; share and bell stay right-aligned; no overflow |

At 260dp the header is under genuine width pressure and still resolves cleanly —
which is exactly the state an unbounded `_PresenceRow` would fail. No `RenderFlex`
overflow stripe appears at any width. The fix reads as correct in the running app.

Minor, non-blocking observation: at 260dp the couple-type subtitle wraps to three
lines and grows the header's height rather than ellipsizing. Nothing clips, and
260dp is below any shipping device class, so this is recorded only for completeness.

## F-5 — STORY-007 D2 (`_DaysCounter` 14px overflow at 390dp): does NOT reproduce

D2 recorded `RenderFlex overflowed by 14 pixels on the right` at 390dp logical width,
and STORY-007 widened its capture frame to 430x932 to work around it.

On-device at exactly 390dp (1024px @ 420dpi), the merged build renders the days
counter row cleanly, with no overflow stripe: see
`implemented-home-dark-vi-390dp-emulator-5554.png`.

This does not prove D2 was wrong — the preview harness pins
`MediaQuery.withNoTextScaling`, and this fixture uses a short name ("Minh") and a
3-digit day count. D2 may still reproduce with a longer combined name, a 4-digit
count, or with a system font-size override. It does mean D2 is **not** reproducible
in the default configuration, which should inform how it is sized when queued.

## F-6 — NEW (deferred): light-theme secondary text on the wash falls below AA

STORY-007's AD-6 contrast work measured the **dark** theme only. In light theme the
same class of secondary body text sits below WCAG AA:

| Element | Contrast | AA body (4.5:1) | AA large (3.0:1) |
| --- | --- | --- | --- |
| Home hero subtitle, on the wash | **3.97:1** | FAIL | PASS |
| Home header couple-type subtitle, on the wash | **3.69:1** | FAIL | PASS |
| Same token on a white card | **4.45:1** | FAIL (marginal) | PASS |
| Home milestone chip text (on white chip) | 13.39:1 | PASS | PASS |
| Home header partner name (primary) | 10.79:1 | PASS | PASS |

The token is already borderline by design at 4.45:1 on white; the sky wash then
pushes it clearly below. This is the light-theme analogue of D1 and no per-story
capture could have found it, since STORY-007 never rendered light theme.

**Severity qualifier:** `CupidFeatureFlags.enableLightTheme` defaults to `false`
(`mobile/lib/core/config/cupid_feature_flags.dart:7-10`), and `cupid_app.dart:49-51`
therefore pins `ThemeMode.dark`. The shipped app is dark-only, so this is **not
user-reachable today**. It is a pre-exposure finding that must be resolved before
that flag is ever flipped. Route to UI/UX Designer with D1, same token/backdrop
decision. See `crop-home-light-vi-hero-secondary-text.png`.

## F-7 — NEW (minor, deferred): `welcome` art is theme-invariant, its text is not

`welcome` is one of AD-3's three ratified allowlisted occluders — a full-bleed art
treatment that paints its own opaque fill and deliberately does not receive the
shared wash. That fill is the same saturated purple-to-pink gradient in both themes,
but the screen's foreground text follows the active theme.

Result: in dark theme the screen is white text on saturated art and reads well; in
light theme it becomes dark text on the same saturated art, and the body line and
the footnote are visibly low-contrast. The Google button also inverts to a dark fill
that does not match light-theme surfaces elsewhere.

Pre-existing (STORY-007 changed zero files under `mobile/lib/`), non-blocking, and
carries the same `enableLightTheme=false` qualifier as F-6. Recorded because it is
precisely the class of app-wide theme interaction this requirement-level pass exists
to surface. Compare `implemented-welcome-dark-vi-*` against `implemented-welcome-light-vi-*`.

## F-8 — Not a defect: backend-dependent screens in this session

`me` renders its "Không thể tải hồ sơ" error state, and un-fixtured `chat` throws a
null-check error, because the local backend is not running — logcat shows repeated
`DioException [connection error] ... SocketException: Connection refused ...
address = localhost` throughout the session. DevOps's gate covered build and boot,
not a running backend, and standing up backend infrastructure is outside this lane.

Neither is a merge regression. `me` still paints the shared wash correctly behind its
error state, which is the property this audit is checking. `chat` was captured
successfully via its backend-free `PREVIEW_CHAT_GHOST=on` fixture (F-2).

## F-9 — Not a defect: preview re-route scroll/state artifact

Sending `cupidpreview://screen/home` while Home is already the top-most screen
preserves the previous scroll offset and can leave the Pet card blank for a beat as
its fixture cubit re-initialises without a backend. A clean launch followed by a real
scroll gesture renders every Home card correctly in both themes
(`implemented-home-{dark,light}-vi-scrolled-*`). Harness behaviour, not app behaviour.

---

## Coverage gap: `en` locale not captured

The handoff asked for Home in "light theme + `en`". Light theme was captured; `en`
was not, for two independent reasons:

1. The preview harness pins `locale: const Locale('vi')`
   (`mobile/lib/main_preview.dart:1578`) with no dart-define override. Changing it is
   a source edit outside this run's `WriteScope`
   (`data/requirements/REQ-010_home_dashboard_deferred_scope_completion/integration-review/`).
2. `CupidFeatureFlags.enableEnLocale` defaults to `false`
   (`cupid_feature_flags.dart:12-15`), so `en` is not user-selectable in the shipped
   app either. `app_en.arb` exists and is fully built — per that file's own comment,
   the flags "gate exposure only" — but no user can reach it today.

All captures in this audit are therefore `vi`. Given (2), a `vi`-only audit matches
what ships. If Iris-QC-4 wants `en` coverage regardless, it needs either a
harness-level locale define (a `mobile/lib` change, a separate story) or a build with
`--dart-define=CUPID_ENABLE_EN_LOCALE=true`.

---

## Verdict

No blocking visual breakage was found across the merged requirement. The cumulative
Home screen is correct, `b0c79fc` is visually verified, STORY-007's D1 escalation is
corrected downward, and D2 does not reproduce in the default configuration.

Two new findings (F-6, F-7) are genuine but sit behind `enableLightTheme=false` and
belong with D1 in the UI/UX Designer's token/backdrop decision, not in this
requirement's completion path.

`MOBILE_VISUAL_AUDIT_COMPLETE: YES`
