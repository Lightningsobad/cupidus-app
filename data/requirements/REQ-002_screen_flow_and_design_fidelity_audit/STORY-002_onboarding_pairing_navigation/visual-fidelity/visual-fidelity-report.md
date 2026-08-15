VISUAL_FIDELITY: PASS

# Visual Fidelity: STORY-002 Onboarding & Pairing Flow Navigation Correction

- Date: 2026-08-14
- Owner: mobile-dev (Alex-Mobile-Dev)
- Story: STORY-002 (REQ-002), Scope A — screen flow / navigation correction
- Phase: post-P5 completion evidence (DONE-gate artifact)
- Design source: `cupid-app-design-system` / `Cupid App.dc.html`
- Design-Screen: NONE for `pairing_choice`. Step C rendered and rejected
  `invite`, `joincode`, `profile`. Those three renders are kept as
  neighbouring-node references and as the Step C audit trail — they are **not**
  a baseline for `pairing_choice`. Gap code:
  `MOBILE_VISUAL_AUDIT_STATE_MISSING` (see "Design reference" below)

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

| Capture | Role | AC | Device / frame | Size | Bytes |
|---|---|---|---|---|---|
| `implemented-pairingchoice-emulator-5560.png` | implementation under test | AC4 | `emulator-5560` (Android) | 405x900 | 61620 |
| `design-reference-invite-android.png` | Step C candidate, rejected | — | canvas Android frame | 406x900 | 172545 |
| `design-reference-joincode-android.png` | Step C candidate, rejected | — | canvas Android frame | 406x900 | 157791 |
| `design-reference-profile-android.png` | Step C candidate, rejected | — | canvas Android frame | 406x900 | 146697 |

**Read the "Role" column before using any of these.** The three
`design-reference-*` files are the Step C audit trail: they are the canvas
screens that could plausibly have *been* the pairing-choice step, rendered and
then rejected by looking at them. None of them is a design baseline for
`implemented-pairingchoice-emulator-5560.png`, and nobody should diff them
against it. They are kept rather than deleted because they are genuine
references for three other nodes this story touches (`invite`, `join_code`,
`onboarding_profile_setup`) and because they carry the two findings below.

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

There is no `pairingchoice` (or equivalent) id among them.

**Step B — shortlist by meaning.** Canvas ids are abbreviations that do not
track story names, so a missing string is a hypothesis, not an answer. Three
ids could plausibly *contain* the invite-vs-join-code choice: `invite` (if the
canvas put both choices on the create-code screen), `joincode` (if it put them
on the enter-code screen), and `profile` (if the choice was appended to the
onboarding setup step it follows).

**Step C — confirm by looking.** All three were rendered at the Android frame,
dark/vi, and read:

| Id | What the render actually shows | Verdict |
|---|---|---|
| `invite` | Header "Ghép đôi", the generated code `CPD-8F2K` with expiry and share/copy actions, a "Tụi mình thuộc kiểu nào?" relationship-type picker, CTA "Tiếp tục → Fingerprint Vow" | Rejected — this is the create-code screen, not a choice |
| `joincode` | Header "Nhập mã ghép đôi", 8-cell code entry, Paste / Scan-QR, CTA "Ghép đôi", and a trailing link "Tôi mới là người tạo mã →" | Rejected — enter-code screen; it reaches the other branch by a cross-link, not by a preceding choice |
| `profile` | Header "Hồ sơ của bạn", avatar picker, name / DOB / language fields, CTA "Tiếp tục → Love Contract" | Rejected — onboarding setup step, no pairing choice anywhere on it |

So the canvas genuinely holds no screen for this node, and the reason is
visible in the `joincode` render: **the design solves the invite-vs-join branch
with a cross-link between the two screens, not with a dedicated choice node.**
`pairing_choice` exists because `ux/uiux-spec.md`'s corrected navigation graph
made it a distinct chain step. The design was never re-exported to match.

Per the mobile-dev visual-fidelity reference, that is the exact condition for
`MOBILE_VISUAL_AUDIT_STATE_MISSING`: "the canvas genuinely holds no screen for
this story — the design never covered it. That is a real requirement gap worth
surfacing." It is raised here after Step C, with the ids rendered and rejected
named above, not as a shortcut around the comparison.

Consequence: **`pairing_choice` is judged against the AC4 chrome rule as
written in the UX spec, not against a design image.** No
`design-reference-pairingchoice-*.png` is produced, because fabricating one
would be inventing a baseline rather than reading one.

This is also why `'pairingchoice'` is the only key in
`mobile/lib/main_preview.dart` that is *not* a design canvas id; the harness's
file header states the keys are canvas ids, and the new entry carries an
inline note recording the exception so the next reader does not assume a
missing export.

## Two findings the Step C renders surfaced

Neither is a defect in this story's implementation, and neither reopens R1-R4.
Both are conflicts between the design canvas and the UX spec that this story
was told to implement, so they are raised for whoever owns that
reconciliation.

### F-A: the canvas puts a header on chain screens that AC4 forbids

All three rendered canvas screens carry a back-arrow + title app bar:
"Ghép đôi", "Nhập mã ghép đôi", "Hồ sơ của bạn". `ux/uiux-spec.md` §"Chrome
Rules" says the opposite, for every node in this chain: "No header/app-bar
chrome on any screen in this list."

`invite` and `join_code` are implemented without a header and pass the guard
suite; `onboarding_profile_setup` is one of the four nodes
`chain_chrome_guard_test.dart` records in `_trackedHeaderBreaches` — the set
that "records the disagreement instead of resolving it".

This report does not resolve it either. It adds the missing half of the
evidence: the disagreement is not merely between screens and a spec sentence,
it is between the **design canvas** and the spec. Whoever settles R3 now has a
rendered design showing headers were intended on these screens, which is a
materially different question from "four screens drifted".

### F-B: the canvas encodes a different chain order than the corrected graph

Two CTAs in the renders contradict the corrected navigation graph:

| Canvas CTA | Canvas implies | `ux/uiux-spec.md` graph says |
|---|---|---|
| `profile`: "Tiếp tục → Love Contract" | `profile_setup` → `love_contract` | `profile_setup` → `pairing_choice` |
| `invite`: "Tiếp tục → Fingerprint Vow" | `invite` → `vow` | `invite` → `waiting` → `paired` → `love_contract` → `vow` |

The implementation follows the spec graph, which is authoritative for
STORY-002. But it means the canvas is not merely *missing* the
`pairing_choice` screen — it describes a shorter chain that never had one.
A design export for `pairing_choice` therefore cannot be a small patch to the
bundle; it implies re-exporting the pairing leg against the corrected graph.
That scoping belongs to UX/product, not to this story.

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
- Canvas enumeration (Step A): `.ai-team-bundle/runtime/tools/render-design-canvas.js
  --list-screens --location=cupid-app-design-system --entry="Cupid App.dc.html"`.
- Step C candidate renders: the same tool with
  `--screen=<invite|joincode|profile> --platform=android --theme=dark --lang=vi`.
  Theme, locale, `hide_selectors` and the platform frame all come from the
  locked `design-fidelity-config.json`, so these renders are byte-identical to
  what ui-ux-designer would have produced for the same ids.
- Display size was changed only for the duration of the capture and restored by
  the script on exit.
