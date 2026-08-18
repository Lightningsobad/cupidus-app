VISUAL_FIDELITY: PASS

All 6 screens compared as rendered `implemented-<screen>-emulator-5560.png` vs
`design-reference-<screen>-android.png` pairs, dark theme + `vi` locale, Android
`emulator-5560` at 540x1200/240dpi (both sides 405x900 / 406x900): `otp`
(code-entry state, 3 of 6 digits, resend `00:42`), `contract`
(`partnerAlreadySigned` — 4 clauses, 2 ticked, "Giữ để ký" CTA), `profile`
(onboarding profile-setup, fixture `Linh` / 03/03/2001), `permissions`
(notifications + fingerprint granted, photos not-yet-decided), `joincode` (empty
code field, idle), `vow` (idle `myNotVowed`, both partners "đang đợi"). On every
pair the shared `CupidAppBackground` sky wash now renders behind the screen, as
the reference draws it, and no content, layout, spacing, or typography moved.
Details, including the `vow` hero-gradient compositing check, in
`## Rendered design-fidelity comparison` below.

# Visual Fidelity Report: STORY-046 Shared Screen Backdrop Occlusion Fix

Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening`
Lane: mobile
Date: 2026-08-18
Configuration audited: dark theme + `vi` locale (the only user-enabled
combination; OQ5 RESOLVED, light/`en` excluded per this requirement's standing
precedent).

## Method

Scope item 3 permits "at minimum a screen-backdrop probe (sampled pixel
color(s) confirming the shared `--sky` wash renders through where the solid
override previously painted)". Each of the 6 screens is probed independently by
`mobile/test/design_system/shared_backdrop_occlusion_test.dart`.

Each screen is mounted under the production composition root shape — the
shared `CupidAppBackground` supplied once via `MaterialApp.builder`, exactly as
`mobile/lib/app/cupid_app.dart:58-59` does — and rasterized through a
`RepaintBoundary`. One pixel is sampled at logical `(120, 10)` on the default
800x600 test surface. That point sits under the first dark sky layer's ellipse
(center 15%, -8%), where the wash reads distinctly purple against the flat
`colorBackground` fill; it is the same probe point and rationale already used by
`mobile/test/design_system/cupid_app_background_test.dart`'s own wash assertion.

Each screen gets **two** renders of that same pixel:

1. **Negative control.** The theme's `scaffoldBackgroundColor` is forced to an
   opaque sentinel (pure green, `0xFF00FF00`). Seeing the sentinel at the probe
   pixel proves two things at once: the probe pixel is genuinely a pixel the
   screen's own `Scaffold` backdrop paints (so the probe is not measuring some
   unrelated area), and the screen no longer overrides the theme's scaffold fill
   itself. A screen that still set `backgroundColor: colors.colorBackground`
   would win over the theme and the sentinel would *not* appear.
2. **Production theme.** The same pixel must read as the sky wash: green
   channel low, colour not equal to the flat fill, and both the red and blue
   channels strictly greater than the flat fill's.

A static assertion also confirms every mounted `Scaffold` has
`backgroundColor == null`.

### Mutation check (probe is not vacuous)

`backgroundColor: colors.colorBackground` was temporarily reintroduced on
`vow_screen.dart` — the hardest screen, since it paints its own semi-transparent
hero radial gradient over the Scaffold — and the AC7 probe failed as designed:

```
Expected: a value greater than <0.5>
  Actual: <0.09411764705882353>
the probe pixel must be one the screen Scaffold paints, otherwise it proves
nothing about the removed override
```

The mutation was reverted immediately. The measured `0.094` green channel is the
flat fill's own green blended with the vow hero wash, which independently
confirms the probe pixel is exactly where the removed override used to paint.

## Per-screen results

Each screen was verified independently; no screen's result is used as evidence
for any other (business rule: "Each of the 6 screens must be independently
verified").

| AC | Design-Screen | Screen file | Line removed | `colors` local | Probe |
|----|---------------|-------------|--------------|----------------|-------|
| AC2 | `otp` | `mobile/lib/features/auth/presentation/screens/otp_screen.dart` | 79 | kept (still used for badge/text tokens) | PASS |
| AC3 | `contract` | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart` | 109 | **removed** (became fully unused) | PASS |
| AC4 | `profile` | `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` | 85 | kept (still used) | PASS |
| AC5 | `permissions` | `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart` | 107 | kept (still used for accent/text tokens) | PASS |
| AC6 | `joincode` | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` | 125 | kept (still used) | PASS |
| AC7 | `vow` | `mobile/lib/features/vow/presentation/screens/vow_screen.dart` | 169 | kept (still used) | PASS |

On every screen the removed property was replaced by the
`forgot_screen.dart:103-106` precedent comment (STORY-032 AC1), matching the
wording STORY-037 already applied to `invite_screen.dart:172-175`. No other
`Scaffold` property was touched on any screen.

The `colors` local was removed on exactly one screen —
`love_contract_screen.dart`, where `_LoveContractView.build` used it for nothing
else. `flutter analyze` reported that as `unused_local_variable` and reports it
no longer. On the other 5 screens `colors` remains in use for text, icon,
border, or accent tokens and was correctly left in place (AC8, and the story's
"per screen, not as a blanket rule" edge case).

## Rendered design-fidelity comparison

The probe above proves the backdrop-unoccluded half of AC2-AC7 but is silent on
the content/layout half, and removing an opaque `Scaffold` fill changes what
every translucent surface on these screens composites against. This section is
the rendered gate: one `implemented-*` / `design-reference-*` pair per screen,
compared side by side.

### How the pairs were produced

Design references — all 6 rendered fresh from the locked design source rather
than copied from an earlier story, so no pair can inherit a stale or mis-scaled
render (the failure mode STORY-045 hit, flagged in this story's `story_master.md`
carry-forward note):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<story>/visual-fidelity --screen=<id> \
  --platform=android --theme=dark --lang=vi
```

`--location`/`--entry` are `design-fidelity-config.json`'s own
`design_source.location` and `design_source.entry`
(`content_fingerprint: sha256:44c8b209…`, `locked: true`). All 6 rendered
`406x900`.

Implementation captures — state faked through the preview entrypoint, never
navigated to:

```
mobile: flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW_PROFILE=fixture \
  --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=partnerAlreadySigned
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk

.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --out=<story>/visual-fidelity --label=<id> --device=emulator-5560 \
  --width=540 --density=240 --max-edge=900 \
  --route="cupidpreview://screen/<id>"
```

All 6 captured `405x900` on `emulator-5560`, matching the references frame for
frame. The device was already running and was only temporarily resized; the
script restores the display size on exit. Two `--dart-define`s were needed
because those two screens read live backend state a preview session does not
have: without them `profile` renders a spinner and `contract` renders
"Không có kết nối mạng".

### Per-screen comparison

| AC | Screen | State compared | Backdrop | Content / layout / typography |
|----|--------|----------------|----------|-------------------------------|
| AC2 | `otp` | 3 of 6 digits entered, caret on cell 4, resend `00:42` | Sky wash renders through — purple upper-left, magenta upper-right, teal lower band, matching the reference | MATCH — badge, headline, subtitle, 6 code cells, resend line, CTA all in the reference's positions |
| AC3 | `contract` | `partnerAlreadySigned` — 4 clauses (§1/§2 ticked), "Minh Anh đã ký, đến lượt bạn", "Giữ để ký" | Sky wash renders through behind the translucent contract card | MATCH — header band, clause rows, divider, caption, CTA, encryption footer unmoved |
| AC4 | `profile` | Fixture profile `Linh` / 03/03/2001 / Tiếng Việt | Sky wash renders through | MATCH — avatar block, 3 field cards, zodiac pill, CTA unmoved |
| AC5 | `permissions` | Notifications + fingerprint granted, photos not-yet-decided | Sky wash renders through | MATCH — headline, 3 permission cards with correct per-card toggle states, CTA, "Để sau" unmoved |
| AC6 | `joincode` | Empty code field, idle | Sky wash renders through | MATCH — icon badge, headline, subtitle, code field, CTA unmoved |
| AC7 | `vow` | Idle `myNotVowed`, both partners "đang đợi" | Sky wash renders through **and composites with the screen's own hero wash** — see below | MATCH — eyebrow, two-line headline, subtitle, fingerprint disc, both initial avatars and their labels unmoved |

### AC7 `vow` — hero gradient compositing (the compositing-risk screen)

`vow_screen.dart` wraps its body in a `DecoratedBox` whose `RadialGradient`
(`VowPalette.heroWash`, alpha 0.5 → 0, centre `Alignment(0, -0.4)`, radius 1.01)
is semi-transparent, so removing the opaque `Scaffold` fill changed what that
gradient blends against — from the flat `colorBackground` to the sky wash. This
is the one screen where the change could plausibly alter more than the backdrop,
so it was checked twice:

1. **Against the design reference.** The reference draws exactly this
   composite — a purple radial field around the fingerprint disc sitting on a
   darker sky, brighter at centre than at the corners. The implementation now
   renders the same relationship. Before the fix the hero wash blended into a
   flat fill, so the fix moves this screen toward the reference, not away.
2. **Against the pre-change capture.** `STORY-016_fingerprint_vow_design_fidelity/
   visual-fidelity/implemented-vow-emulator-5560.png` is the same screen, same
   idle state, same device, captured before this change. Every element is in the
   same place at the same size; the only difference is the corner falloff, which
   is cooler and deeper now that the sky wash shows through beneath the hero
   gradient. No text reflowed, no element shifted, no contrast regression on the
   headline, subtitle, disc, avatars, or "đang đợi" labels.

The same before/after A/B is available for `contract`
(`STORY-039_love_contract_design_fidelity_hardening/visual-fidelity/
implemented-contract-emulator-5560.png`, identical chrome and identical
composition, flat dark backdrop before vs. sky wash now), which independently
confirms the change is backdrop-only on a second, card-heavy screen.

### Pre-existing deltas explicitly NOT introduced by this story

These are visible in the pairs but predate this change and belong to each
screen's own story, not to STORY-046. They are recorded here so the comparison
is honest, not silently expanded (business rule: record, do not silently
expand):

- No app-bar chrome on `otp`, `profile`, `permissions`, or `joincode`, where the
  references draw a titled header. This is the `ux/uiux-spec.md` Chrome Rules
  decision applied across the onboarding chain, the same rule
  `forgot_screen.dart`'s own precedent comment cites.
- `profile`: avatar placeholder is a filled person glyph rather than the
  reference's dashed "Ảnh đại diện" ring; CTA reads "Tiếp tục → Love Contract"
  rather than "Tiếp tục → Ghép đôi" (STORY-002 flow ordering).
- `permissions`: notification card body reads "Nhắc nhớ đồng bộ và Emoji Storm"
  rather than the canvas' "Synced Alarm và Emoji Storm" (localization).
- `joincode`: single free-text code field rather than the reference's segmented
  `CPD-8…` cells, and no "Dán" / "Quét QR" / "Tôi mới là người tạo mã" row.

None of these moved in this story's diff, which deletes one `Scaffold` property
per screen and one now-unused local.

## Second-defect findings

None. No screen surfaced a second, different defect during verification, so no
new finding was recorded and this story's scope was not expanded (business
rule: record, do not silently expand).

## Static analysis and automated tests (AC9)

SDK resolved per `data/devops/system/runtime-command-registry.json`
(`mobile-app.sdk`): `/Users/alantravala/flutter/bin/flutter` — Flutter is not on
this machine's shell `PATH`.

- `flutter analyze lib test` — 80 issues, all `info` severity, byte-identical to
  the pre-change baseline. Zero errors, zero warnings. No new issue in any of the
  6 edited files or in the new probe test. The single `info` inside the edited
  set (`joincode_screen.dart:27 prefer_initializing_formals`) is pre-existing and
  untouched, confirmed by `git diff` against BaseHead
  `524434ca9a3e78b3f512f6a15c7eedc9f575165c`, which shows only line 125 changed
  in that file.
- `flutter test` — `+1276 ~2: All other tests passed!` (0 failures; the 2 skips
  are pre-existing). The baseline before this story was 1270 passing; the 6 new
  passing tests are this story's 6 per-screen probes.

Repo-wide bare `flutter analyze` additionally walks
`mobile/build/ios/SourcePackages/checkouts/flutterfire/**`, vendored
third-party build output that is unrelated to this story and already failing
before it; `lib test` is the project-source gate.

## Acceptance criteria coverage

| AC | Status | Evidence |
|----|--------|----------|
| AC1 | PASS | All 6 probes assert the shared `CupidAppBackground` `--sky` wash renders through unoccluded, and all 6 rendered pairs show it |
| AC2 | PASS | `otp` probe + source edit + rendered pair |
| AC3 | PASS | `contract` probe + source edit + rendered pair (plus STORY-039 before/after A/B) |
| AC4 | PASS | `profile` probe + source edit + rendered pair |
| AC5 | PASS | `permissions` probe + source edit + rendered pair |
| AC6 | PASS | `joincode` probe + source edit + rendered pair |
| AC7 | PASS | `vow` probe + source edit + rendered pair; mutation check confirms the probe is live; hero-gradient compositing checked against both the reference and the STORY-016 pre-change capture |
| AC8 | PASS | `colors` removed only on `love_contract_screen.dart`; analyze reports no `unused_local_variable` |
| AC9 | PASS | `flutter analyze lib test` clean vs. baseline; `flutter test` 1276 passing, 0 failing |
| AC10 | PASS | No navigation, route, or entry-point code touched; the diff is 6 `Scaffold` property deletions plus 1 unused local |

## Files changed

- `mobile/lib/features/auth/presentation/screens/otp_screen.dart`
- `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
- `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`
- `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart`
- `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`
- `mobile/lib/features/vow/presentation/screens/vow_screen.dart`
- `mobile/test/design_system/shared_backdrop_occlusion_test.dart` (new — the 6
  per-screen probes)

No production source changed for the rendered-evidence patch; the 12 PNGs below
are added evidence only.

## Evidence artifacts

In `visual-fidelity/`, one pair per screen:

- `implemented-otp-emulator-5560.png` / `design-reference-otp-android.png`
- `implemented-contract-emulator-5560.png` / `design-reference-contract-android.png`
- `implemented-profile-emulator-5560.png` / `design-reference-profile-android.png`
- `implemented-permissions-emulator-5560.png` / `design-reference-permissions-android.png`
- `implemented-joincode-emulator-5560.png` / `design-reference-joincode-android.png`
- `implemented-vow-emulator-5560.png` / `design-reference-vow-android.png`

Build gate for the capture: `flutter build apk --debug -t lib/main_preview.dart`
succeeded (`✓ Built build/app/outputs/flutter-apk/app-debug.apk`) on both
`--dart-define` sets used above.
