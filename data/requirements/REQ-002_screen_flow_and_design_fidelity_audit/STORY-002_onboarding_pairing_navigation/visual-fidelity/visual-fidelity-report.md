VISUAL_FIDELITY: PASS

# Visual Fidelity: STORY-002 Onboarding & Pairing Flow Navigation Correction

- Date: 2026-08-14
- Owner: mobile-dev (Alex-Mobile-Dev)
- Story: STORY-002 (REQ-002), Scope A — screen flow / navigation correction
- Phase: post-P5 completion evidence (DONE-gate artifact)
- Design source: `cupid-app-design-system` / `Cupid App.dc.html`
- Design-Screen: NONE — the canvas exports no pairing-choice screen (see
  "Design reference" below)

## Read this before reading the verdict

This story's `ux/uiux-spec.md` is explicit that it is a **navigation-correction
spec only**: "no new screens, no new entry points. All nodes below already
exist in the app; only the edges (transitions) and chrome rules are being
corrected."

So this report is **not** a pixel-diff against a redesign. There is no redesign.
The only *visual* claim STORY-002 makes on its own account is AC4, the chrome
rule, quoted verbatim from `ux/uiux-spec.md` §"Chrome Rules (NO_CHROME +
NO_TABS)":

- No header/app-bar chrome on any screen in this list.
- No bottom 5-tab bar on any screen in this list.
- `home` is the first point in the entire flow where the 5-tab bar appears.

The screen captured here is `pairing_choice`. It is the one node this story
promoted into a named screen of its own (`PairingChoiceScreen`; it was an
inline `_PairingStack` branch before Phase P4), so it is the node where
STORY-002's own chrome claim is most load-bearing and least covered by any
earlier story's evidence.

### What this report does NOT cover

| Not covered | Why | Owner |
|---|---|---|
| The 4 chain screens that still render a `CupidHeader` (`forgot_password`, `otp`, `permissions`, `profile_setup`) | Already raised and dispositioned as R3 in `review/review-report.md`; each file belongs to another already-DONE story and sits outside this story's write scope | R3 disposition, not this artifact |
| Caption-typography drift on already-audited screens | Accepted baseline; closed review findings | prior stories |
| Any screen body outside `mobile/lib/main_preview.dart` | Out of this run's WriteScope | — |

## What was captured

| Capture | AC | Device | Size | Bytes |
|---|---|---|---|---|
| `implemented-pairingchoice-emulator-5560.png` | AC4 | `emulator-5560` (Android) | 405x900 | 61620 |

Device note: `emulator-5554` was also running and was tried first. Its install
failed with `INSTALL_FAILED_INSUFFICIENT_STORAGE` (`/data/user/0` at 90%). No
device was created, booted, wiped, or repaired to work around this — the
capture simply moved to the other already-running emulator, which is why the
device suffix reads `emulator-5560`.

## Design reference

None exists, and this is a finding rather than an omission.

`render-design-canvas.js --list-screens --location=cupid-app-design-system
--entry="Cupid App.dc.html"` returns 37 screen ids:

`splash, welcome, login, register, otp, forgot, permissions, profile, contract,
invite, joincode, waiting, paired, vow, home, chat, ghostset, vibe, alarm,
antighost, zodiac, pet, timeline, gallery, jar, jarlist, jarnew, expense, me,
privacy, notifs, themes, themedetail, sharepick, shareedit, shareapprove,
shareok`

There is no `pairingchoice` (or equivalent) id among them. The canvas walks
`profile` straight into `invite` / `joincode`; the intermediate
"invite vs. join-code selection step" that `ux/uiux-spec.md` names
`pairing_choice` was introduced by this story's corrected navigation graph and
the canvas was never re-exported for it.

Consequence: **`pairing_choice` is judged against the AC4 chrome rule as
written in the UX spec, not against a design image.** No
`design-reference-pairingchoice-*.png` is produced, because fabricating one
would be inventing a baseline rather than reading one.

This is also why `'pairingchoice'` is the only key in
`mobile/lib/main_preview.dart` that is *not* a design canvas id; the harness's
file header states the keys are canvas ids, and the new entry carries an
inline note recording the exception so the next reader does not assume a
missing export.

## How the state was manufactured

Faked, never driven — no live backend, no real pairing state, no navigation
through the chain:

1. `mobile/lib/main_preview.dart` gained a `'pairingchoice'` entry whose
   builder is `onboardingRouteBuilders()[OnboardingNode.pairingChoice]!`.
   It resolves through the **shipped production registry** (the same map
   `service_locator.dart` hands to `OnboardingRouter`) instead of constructing
   `PairingChoiceScreen()` by hand, so the capture photographs the widget
   production actually mounts at this node. A hand-built copy could drift from
   the registry and still look correct in a screenshot.
2. `wrapInShell` is deliberately left `false`. Chain nodes carry no shell
   chrome, so wrapping would have manufactured exactly the chrome AC4 forbids.
3. Built and installed as a preview APK, then opened by deep link:
   `cupidpreview://screen/pairingchoice`.

## Per-screen verdict

### `pairing_choice` — `implemented-pairingchoice-emulator-5560.png`

VISUAL_FIDELITY: PASS

Rendered tree, top to bottom: OS status bar, then a full-bleed dark surface
carrying the title "Ghép đôi để mở khoá Cupid", the primary pill action
"Ghép đôi với người ấy" (→ `invite`), the secondary text action
"Tôi đã có mã" (→ `join_code`), then empty surface down to the OS gesture bar.

| ID | Delta | Owner |
|---|---|---|
| AC4 no header | None — no app bar, no `CupidHeader`, no back chrome above the title | — |
| AC4 no 5-tab bar | None — nothing is mounted at the bottom edge; the only bottom-edge pixels are the OS gesture indicator | — |
| AC4 `home` is first tab-bar appearance | Not observable from this single capture; carried by test, see below | — |
| Graph edges out of this node | Both spec edges are present and are the only two actions on the screen: "create code" → `invite`, "enter code" → `join_code` | — |

### Honest limitation of this capture

A preview entrypoint mounts the screen as the `MaterialApp` root. Absence of an
*app-level* tab bar in that harness is therefore partly a property of the
harness, not proof about production composition. The capture proves the screen
does not grow chrome **of its own**; it cannot by itself prove nothing wraps it
in production.

The production-composition half of AC4 is carried by
`mobile/test/core/navigation/chain_chrome_guard_test.dart`, which pumps the real
screen behind **every** chromeless node and asserts no `CupidHeader`, no
`AppBar`, no `BottomNavigationBar`, no `NavigationBar`, no `CupidTabBar` — and
then asserts the shell behind `home` *does* mount `CupidTabBar`, so the
first-appearance rule is proved rather than a blanket absence. Two structural
tests in that file stop the guard rotting: one fails if a chain node has no
screen under guard, another fails if a tracked header breach names a node the
chain no longer walks.

That suite passes 18/18 at this head (command and exit code below). The
screenshot and the suite are complementary: the suite proves the composition
rule across all nodes, the screenshot proves the rule survives real rendering
on a device for the node this story introduced.

## Not captured, and why

The other 14 nodes in the chain are not captured here. Per the mobile-dev
visual-fidelity reference, a per-story capture set is scoped to what the story
changes; STORY-002 changed edges and the chrome table, and promoted exactly one
node into its own screen. Capturing 14 unchanged screens would produce evidence
about other stories' screens under this story's name, which is precisely the
conflation `review/review-report.md` warns against for R3.

## Golden tests

Not added.

A golden for `pairing_choice` would baseline pixels against a screen that has
**no approved design export**. That baseline would encode today's rendering as
correct, and would then have to be broken by whoever finally exports the canvas
screen and reconciles it. The AC4 property this story actually owns is already
asserted structurally, and structurally is the right level for a chrome rule —
`chain_chrome_guard_test.dart` catches a regression by widget type, without
being sensitive to a font metric or a 1px inset.

Observation, non-blocking: at the reduced 540px capture width the primary
button's label wraps to two lines and reads left-aligned inside its pill. With
no design reference for this node there is no baseline that makes this a delta,
and it is not an AC4 chrome concern. It is recorded here so a future canvas
export for `pairing_choice` has something to reconcile against, not raised as a
finding on this story.

## Verification run at this head

| Command | Result |
|---|---|
| `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=pairingchoice` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, exit 0 |
| `flutter analyze lib test --no-fatal-infos` | 80 issues, all severity `info`, exit 0 — identical to the documented baseline, no new issues from the preview-harness edit |
| `flutter test test/core/navigation/chain_chrome_guard_test.dart` | `+18: All tests passed!`, exit 0 |

## Tooling

- Capture: `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh`
  `--device=emulator-5560 --label=pairingchoice --width=540 --settle-ms=20000
  --route="cupidpreview://screen/pairingchoice"`, run inside `--lease-exec` so
  the install, launch and screenshot held the device exclusively and no
  concurrent story could photograph its own foreground.
- Canvas enumeration: `.ai-team-bundle/runtime/tools/render-design-canvas.js
  --list-screens --location=cupid-app-design-system --entry="Cupid App.dc.html"`.
- Display size was changed only for the duration of the capture and restored by
  the script on exit.
