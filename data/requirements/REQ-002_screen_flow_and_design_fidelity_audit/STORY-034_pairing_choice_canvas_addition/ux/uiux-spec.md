# UX Spec: STORY-034 Pairing Choice Canvas Addition

Screen id added to the design canvas: **`pairingchoice`** (no underscore).

## Why `pairingchoice`, not `pairing_choice`

The story text and the acceptance criteria use `pairing_choice`, but every
existing screen id in the canvas (`Cupid App.dc.html` nav buttons, the
`Cupid Screens.dc.html` state machine — `joincode`, `themedetail`, `jarnew`,
`shareapprove`, `antighost`, etc.) is a single concatenated lowercase token
with no separator. `pairing_choice` would be the only underscored id in the
canvas. The app's own preview harness already resolved this same question the
same way: `mobile/lib/main_preview.dart`'s route key is `'pairingchoice'`
(no underscore), reached by `cupidpreview://screen/pairingchoice`, even though
the production enum member is the camelCase `OnboardingNode.pairingChoice`.
`pairingchoice` is the id that is consistent with both the canvas's own naming
convention and the app's already-established preview key for this exact
screen.

**Scrum Master should render with `--screen=pairingchoice`.**

## What was added

### 1. Design-system source changes

File: `cupid-app-design-system/project/Cupid App.dc.html`
- Added `<span data-screen-btn="pairingchoice">Pairing choice</span>` to the
  top demo nav bar, immediately after the `profile` button. This is what makes
  the node enumerable by `render-design-canvas.js --list-screens` (it scans
  `[data-screen-btn]` elements) and clickable by `--screen=pairingchoice`.

File: `cupid-app-design-system/project/Cupid Screens.dc.html`
- New `isPairingChoice` screen body (`sc-if value="{{ isPairingChoice }}"`),
  inserted immediately after the `isProfile` block and before the `isContract`
  block — content and reasoning below.
- `INDEX` design-doc sidebar: added `{ id: 'pairingchoice', ... }` as the first
  item of the "Ghép đôi" (Pairing) category, ahead of `invite`.
- `BACK_TO`: added `pairingchoice: 'profile'`; changed `invite: 'profile'` →
  `invite: 'pairingchoice'` and `joincode: 'invite'` → `joincode:
  'pairingchoice'` (both screens are now reached from the choice node, not
  from each other).
- `NO_CHROME` and `NO_TABS`: added `pairingchoice: 1` to both — see "F-B
  resolution" below for why.
- New navigation handlers next to the existing `goContract`/`goInvite`/
  `goVow` cluster: `goPairingChoice`, `goJoinCode`, `goWaiting`. `goJoinCode`
  and `goWaiting` did not exist before this story — nothing in the canvas
  previously navigated to `joincode` or `waiting` by CTA, only by the top demo
  nav bar.
- New flag `isPairingChoice: sc === 'pairingchoice'` next to the existing
  `isWelcome`/`isProfile`/`isContract`/`isInvite`/`isVow` flags.

### 2. Content and layout of the new node

Based directly on
`STORY-002_onboarding_pairing_navigation/visual-fidelity/implemented-pairingchoice-emulator-5560.png`
(the running app's actual `pairingchoice` screen), not invented:

- Full-bleed dark surface, no header, no back arrow, no bottom tab bar.
- Title, centered, ~1/3 down the screen: "Ghép đôi để mở khoá Cupid" /
  "Pair up to unlock Cupid".
- Primary pill CTA below it: "Ghép đôi với người ấy" / "Pair up with them" →
  `goInvite` (routes to the `invite`/create-code screen).
- Secondary text link below that: "Tôi đã có mã" / "I already have a code" →
  `goJoinCode` (routes to the `joincode`/enter-code screen).
- Empty surface for the remainder of the screen, matching the capture.

Layout is `min-height:100%` flex column, `padding:150px 28px 0` — an
approximation of the ~28% top offset observed in the 405×900 capture, not a
pixel-exact transcription (this is a design source; the pixel-level fidelity
check runs as the paired render/compare artifact this story hands to
Scrum Master, not as an obligation on this spec).

## F-B resolution: chain order/count reconciled

**Before this story**, the canvas had two independent, disconnected CTA
shortcuts that did not match the app's real chain:

| Screen | Old CTA target | Old canvas implied |
|---|---|---|
| `profile` (profile_setup) | `goContract` | `profile_setup` → `love_contract` |
| `invite` | `goVow` | `invite` → `vow` |

Neither `joincode` nor `waiting` had any CTA route to them at all — they were
only reachable via the top demo nav bar, not via any in-canvas click-through.

**The app's real chain** (per STORY-002's corrected `ux/uiux-spec.md`
navigation graph and its `chain_chrome_guard_test.dart`/AC4 verification):
`profile_setup → pairing_choice → {invite → waiting → paired | join_code →
paired} → love_contract → vow → home`.

**After this story**, the canvas CTA graph now reads:

```
permissions → profile → pairingchoice ─┬→ invite → waiting ─┐
                                        └→ joincode ─────────┴→ paired → contract → vow → home
```

Concretely:
1. `profile`'s CTA now targets `goPairingChoice` (was `goContract`), text
   changed to "Tiếp tục → Ghép đôi" / "Continue → Pair up".
2. New `pairingchoice` node's two actions target `goInvite` and `goJoinCode`
   (both previously-orphaned or newly-added handlers).
3. `invite`'s CTA now targets `goWaiting` (was `goVow`), text changed to
   "Tiếp tục → Đợi ghép" / "Continue → Waiting" — this closes the previously
   orphaned `waiting` node into the click-through chain.
4. `joincode`'s existing "Ghép đôi" CTA (`goPaired`) was already correct and
   is unchanged — the code-joiner completes pairing immediately, they do not
   wait.
5. `waiting`'s existing "Giả lập: Linh vào" CTA (`goPaired`) was already
   correct and is unchanged.
6. `paired`'s existing "Ký Love Contract →" CTA (`goContract`) was already
   correct and is unchanged.
7. `contract`'s "both signed" CTA now targets `goVow` (was `goInvite`), text
   changed to "Cả hai đã ký → Fingerprint Vow" / "Both signed → Fingerprint
   Vow" — this was the second half of F-B: the canvas previously routed
   *backward* from contract-signing into invite/pairing, which is not a
   shorter chain so much as a differently-ordered one. It is now `paired →
   contract → vow`, matching the graph.

This closes F-B by rewiring navigation edges only. It does not physically
reorder the `contract`/`invite`/`vow` HTML blocks in the file (they stay where
they were, `profile` → `pairingchoice` → `contract` → `invite` → `vow` in file
order, with `joincode`/`waiting`/`paired` further down near the other
early-onboarding screens) — AC2 asks for the chain's node order/count as
walked by navigation to be reconciled, not for the source file's physical
block order, and reordering unrelated, already-correct screen bodies would
have expanded this trivial story's diff for no behavioral gain.

## Why `pairingchoice` is chromeless (NO_CHROME + NO_TABS)

AC4 in STORY-002 requires no header and no tab bar on every chain node, and
the implemented capture shows exactly that: no app bar, no back chrome, no
bottom tabs. Without adding `pairingchoice` to `NO_CHROME`/`NO_TABS`, the
canvas's default header (back arrow + title) would render on top of it, which
would not match the implementation and would produce a false MISMATCH under
the retro-audit's design-fidelity pairing rule instead of the intended MATCH.

## Confirmed render command for Scrum Master

```
render-design-canvas.js --screen=pairingchoice --platform=android --theme=dark --lang=vi
```
(Same device/theme/lang convention already used for
`implemented-pairingchoice-emulator-5560.png` and STORY-002's other
`design-reference-*` captures.)

## Out of scope, not touched

- F-A (canvas headers on `invite`/`joincode`/`profile` contradicting AC4) —
  a separate finding, separate RWB item, not this story's scope.
- Any STORY-002 app code, test, or navigation file.
- The physical HTML ordering of pre-existing, already-correctly-wired screen
  blocks.
- The `login` screen's unrelated fingerprint/biometric-login shortcut
  (`goVow` at a different call site) — a pre-existing quick-demo affordance
  on the login screen, not part of the F-B chain-order finding.
