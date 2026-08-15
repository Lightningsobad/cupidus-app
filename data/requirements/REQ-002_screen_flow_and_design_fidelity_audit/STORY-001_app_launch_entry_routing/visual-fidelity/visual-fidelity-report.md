VISUAL_FIDELITY: FAIL

# STORY-001 — Per-story visual fidelity (app launch / entry routing)

Date: 2026-08-13
Owner: Mobile Developer
Story: STORY-001 App Launch / Session-Based Entry Routing Correction
Phase: P3 (`coding-plan/phase-P3-visual-fidelity-evidence.md`)
Design source: `data/devops/system/design-fidelity-config.json` —
`claude-design`, location `cupid-app-design-system`, entry `Cupid App.dc.html`,
locked, fingerprint `sha256:44c8b209…c1cf2c58`.

Design-Screen: splash, welcome, login

## Read this before reading the verdict

The overall token is `FAIL` because three captured screens each show visible
deviation from their design reference, and the gate's rule is that any visible
difference is `FAIL` with the delta written down.

**No delta below is attributable to STORY-001's change surface.** This story is
Scope A (flow/navigation correction). `ux/uiux-spec.md` states the splash
"visuals untouched", and the only visual edit this story made is ADR-6's removal
of the tap-to-continue affordance, which is deliberate and recorded in D1 below.
Every other delta is pre-existing screen-level drift that REQ-002 exists to
close, and each one is owned by a named sibling story:

| Screen | Owning sibling story |
|---|---|
| `splash` | STORY-003_splash_design_fidelity |
| `welcome` | STORY-004_welcome_design_fidelity |
| `login` | STORY-005_login_design_fidelity |
| `home` | STORY-017_home_dashboard_design_fidelity |

Recording `PASS` here would have required either ignoring what the captures show
or not capturing at all. The round-1 review explicitly forbade recording `PASS`
for an unobserved outcome, so the verdict is the honest one and the deltas are
routed rather than swallowed.

## What was captured

Real cold starts of the production entry point (`lib/main.dart`) on a running
Android emulator, per P3 task 1. The preview harness was deliberately not used:
it mounts screens directly and therefore proves nothing about entry routing.

| Capture | AC | Device | Size | Bytes |
|---|---|---|---|---|
| `implemented-splash-emulator-5554.png` | AC4 dwell | emulator-5554 | 1080x2400 | 243261 |
| `implemented-splash-emulator-5560.png` | AC4 dwell | emulator-5560 | 1080x2400 | 241288 |
| `implemented-launch-welcome-emulator-5554.png` | AC3 | emulator-5554 | 1080x2400 | 203040 |
| `implemented-launch-welcome-emulator-5560.png` | AC3 | emulator-5560 | 1080x2400 | 201104 |
| `implemented-launch-login-emulator-5560.png` | AC2 | emulator-5560 | 1080x2400 | 91312 |

Design references rendered from the locked canvas at the Android viewport
(406x900 after the default longest-edge bound), `--theme=dark --lang=vi`, which
matches the app's resolved theme and locale:

| Reference | Screen id | Size | Bytes |
|---|---|---|---|
| `design-reference-splash-emulator-5554.png` / `-5560.png` | `splash` | 406x900 | 154701 |
| `design-reference-launch-welcome-emulator-5554.png` / `-5560.png` | `welcome` | 406x900 | 171621 |
| `design-reference-launch-login-emulator-5560.png` | `login` | 406x900 | 152221 |

Screen ids were taken from the canvas inventory
(`render-design-canvas.js --list-screens`), which lists `splash`, `welcome`,
`login` and `home` as distinct ids. No id was invented.

## How each session state was manufactured

Per P3 task 2, each state is a real device state, not a fixture.

- **AC3 / welcome** — Firebase signed out and no device history marker
  (`flutter.auth.has_previous_session_v1` absent from
  `shared_prefs/FlutterSharedPreferences.xml`). This is the natural state of both
  emulators; the Firebase auth store
  (`com.google.firebase.auth.api.Store.*.xml`) is `<map />`, i.e. no persisted
  user. Cold start lands on `welcome`.
- **AC4 / splash** — captured during the 2 s dwell of the same cold start,
  before the gate resolves.
- **AC2 / login** — Firebase still signed out, but the ADR-3 device history
  marker seeded to `true` with a `last_email` hint, written directly into the
  app's own `shared_prefs` via
  `adb shell run-as com.snapsofts.cupid` while the app was force-stopped:

  ```xml
  <boolean name="flutter.auth.has_previous_session_v1" value="true" />
  <string name="flutter.auth.last_email_v1">seed.user@cupid.test</string>
  ```

  This is exactly the `SessionGateCubit._resolveSignedOut` second row
  (`session_gate_cubit.dart:87-95`) — signed out *and* previously authenticated —
  which is the AC2 branch the story exists to create. The capture confirms it end
  to end: the app lands on the **session-expired login variant**, headed
  "Đăng nhập lại để tiếp tục", with the email field prefilled
  `seed.user@cupid.test`. The prefill proves the `prefillEmail` value travelled
  from the store through `SessionGateSessionExpired` into the screen, not merely
  that some login screen appeared.

  The device was restored to its pre-seed `shared_prefs` content afterwards, so
  no sibling story inherits a manufactured state.

## Per-screen verdicts

### `splash` — VISUAL_FIDELITY: FAIL

Design-Screen: `splash`. Compared
`implemented-splash-emulator-5554.png` against
`design-reference-splash-emulator-5554.png`.

Matching: the "Cupid" wordmark, weight and centring; the three bobbing dots
directly beneath it; the Vietnamese caption text
"Đang mở khoá kỷ niệm của hai bạn…"; the full-bleed vertical gradient with no
app bar and no status-bar tint.

| ID | Delta | Owner |
|----|-------|-------|
| D1 | Tap-to-continue pill ("Chạm để tiếp tục") present in the design, absent in the build. **Intentional — ADR-6.** See the note below. | STORY-001 (closed) |
| D2 | Caption vertical position: design places it low, just above the tap-to-continue pill; the build places it immediately under the dots, near the vertical centre. | STORY-003 |
| D3 | Gradient hue ramp: design runs violet → magenta → teal with the top third clearly purple; the build runs pink → lavender → mint with a pink top third. | STORY-003 |
| D4 | Design carries a soft radial glow in the upper-left quadrant; the build's gradient is flat with no glow. | STORY-003 |

### `welcome` — VISUAL_FIDELITY: FAIL

Design-Screen: `welcome`. Compared
`implemented-launch-welcome-emulator-5554.png` against
`design-reference-launch-welcome-emulator-5554.png`.

Matching: the "Cupid" wordmark, the tagline copy "Yêu nghiêm túc. / Chia tay
đàng hoàng.", the presence and order of the Google and email actions, and the
gradient background treatment.

| ID | Delta | Owner |
|----|-------|-------|
| D5 | Alignment: design left-aligns the wordmark, tagline and body copy against a left margin; the build centres all of them. | STORY-004 |
| D6 | Body copy "App cho hai người. Không có newsfeed, không có người thứ ba." is present in the design and absent from the build. | STORY-004 |
| D7 | Google button: design is a white filled pill with the multicolour "G" mark; the build is a translucent pink pill with no logo. | STORY-004 |
| D8 | "Dùng email": design is an outlined pill button; the build is bare text with no border. | STORY-004 |
| D9 | Footer: design shows the legal line "Đăng ký nghĩa là bạn chấp nhận bị dỗi khi seen không trả lời."; the build shows a low-contrast "Chưa có tài khoản? Đăng ký" instead. | STORY-004 |
| D10 | Design has small sparkle/star accents over the gradient; the build has none. | STORY-004 |

### `login` (session-expired variant) — VISUAL_FIDELITY: FAIL

Design-Screen: `login`. Compared
`implemented-launch-login-emulator-5560.png` against
`design-reference-launch-login-emulator-5560.png`.

Matching: the dark surface, the "Đăng nhập" primary action, the "Quên mật khẩu?"
link, the "hoặc" divider, the presence of Google and Facebook providers, and the
"Chưa có tài khoản? Đăng ký" footer.

| ID | Delta | Owner |
|----|-------|-------|
| D11 | Design has a back arrow + "Đăng nhập" app bar; the build has no app bar. | STORY-005 |
| D12 | Heading: design reads "Mừng bạn quay lại 🎀" with the sub-line "Bae đang đợi ở trong đấy"; the build reads "Đăng nhập lại để tiếp tục" with no sub-line. **Expected divergence** — this is the AC2 session-expired variant defined by `ux/uiux-spec.md` section 4b, which the canvas does not model as a separate state. Recorded so STORY-005 does not overwrite the variant copy with the default heading. | STORY-005 (with the section-4b constraint) |
| D13 | Input fields: design uses filled rounded containers with floating uppercase labels and a password reveal eye; the build uses bare underline fields with sentence-case labels and no reveal control. | STORY-005 |
| D14 | Primary button: design is a pink→violet gradient pill; the build is a flat pink pill. | STORY-005 |
| D15 | Design offers a "Đăng nhập bằng vân tay" (fingerprint) action; the build has none. | STORY-005 |
| D16 | Provider buttons: design places Google and Facebook side by side with brand marks; the build stacks them full-width, outlined, text-only, Facebook first. | STORY-005 |
| D17 | Design tints the top of the screen with a violet gradient wash; the build is a flat near-black surface. | STORY-005 |

### `home` — NOT CAPTURED (P3 stop rule invoked)

Design-Screen: `home`. **No capture was taken and no verdict is recorded.**

AC1 requires a cold start holding a *valid, refreshable Firebase session*. That
state cannot be manufactured on either available emulator:

- Neither device holds a persisted Firebase user. On emulator-5560 the auth
  store `com.google.firebase.auth.api.Store.*.xml` is `<map />`; on
  emulator-5554 the file does not exist at all.
- Creating one requires signing in against the real Firebase project. No seed or
  test account credentials are provisioned for this environment, and creating an
  account on the live project is an external side effect outside this story's
  scope and write scope.
- Forging the auth store bytes is not a substitute: an invalid refresh token
  makes `idToken()` throw, which `SessionGateCubit._resolveSignedIn`
  (`session_gate_cubit.dart:115-117`) correctly resolves to
  `SessionGateSessionExpired` → login. It would produce a believable but false
  artifact, and would exercise AC2 rather than AC1.

Per P3 section 7, this is reported rather than fabricated. AC1 remains covered by
the widget-level evidence the round-1 review already accepted as PASS:
`splash_screen_test.dart` (asserts `PairGateShell` present, `HomeScreen` absent)
and `cupid_app_entry_routing_test.dart:79`.

`MOBILE_VISUAL_AUDIT_STATE_MISSING` is deliberately **not** raised as a story
blocker: the missing state is an environment credential gap, not a design gap,
and STORY-017 owns the `home` screen's fidelity comparison. Whichever story first
has an authenticated device should capture `implemented-launch-home-<device>.png`
against `design-reference-home-android.png`.

## ADR-6 note for STORY-003 — do not reinstate the tap-to-continue line

This is the cross-story note P3 task 5 exists to produce, and the reason B1 was
raised as blocking rather than clerical.

`design-reference-splash-emulator-5554.png` shows a "Chạm để tiếp tục" pill at
the bottom of the splash screen. **The build's omission of it is correct and
intentional.** ADR-6 removed the tap-to-continue affordance because it was the
one path that could bypass the AC4 gate — a user could tap through before the
session check resolved and before the minimum dwell elapsed, which is exactly the
premature-navigation defect this story was opened to fix. `splash_screen.dart`
now navigates only through the single guard at lines 106-109, and the removal is
regression-tested.

STORY-003 must therefore treat this specific difference as **approved, not a
fidelity defect**. Reinstating the pill to match the canvas would reintroduce the
AC4 bypass and regress STORY-001. If the canvas is ever re-exported, the pill
should be removed from the design rather than added back to the build.

Deltas D2, D3 and D4 on the same screen are ordinary fidelity work and remain
STORY-003's to close.

## Golden tests

Not added. Step 4 of the visual-fidelity reference baselines a golden *after the
visual comparison passes*; baselining now would freeze the known-drifted current
appearance of `splash`, `welcome` and `login` as the expected result and would
actively fight STORY-003/004/005 when they correct these screens. The correct
place for the golden is the story that makes the screen match its design.

## Tooling

- Captures: `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh`
  (`--max-edge=0`, `adb exec-out` streaming, device lease held across launch and
  capture). The P3 section 6 fallback to raw `adb exec-out screencap -p` was not
  needed — the bundle helper resolved from the installed runtime tree.
- References: `.ai-team-bundle/runtime/tools/render-design-canvas.js`
  `--platform=android --theme=dark --lang=vi`, `hide_selectors` applied from the
  locked config.
- Display size was not overridden; both devices were left as found, and the
  emulator-5560 `shared_prefs` file was restored to its pre-seed content.
