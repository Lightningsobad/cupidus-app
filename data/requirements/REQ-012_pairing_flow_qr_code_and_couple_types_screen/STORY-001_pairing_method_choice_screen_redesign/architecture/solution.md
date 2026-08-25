# 001_pairing_method_choice_screen_redesign-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1/AC4 design parity against the locked design source
  block `isPairStart`; AC2/AC3 must reuse the two existing push edges without
  introducing a route or destination.
- Architectural invariants / non-goals:
  - `PairingChoiceScreen` stays a `StatelessWidget` with no cubit, no
    repository, and no backend call. This screen has no server state.
  - The two navigation edges stay direct `Navigator.push` calls carrying the
    `createInviteCubit` / `createJoincodeCubit` seams. They must not become
    `OnboardingRouter` edges — a registry `WidgetBuilder` cannot supply those
    seams (documented at `pairing_choice_screen.dart:18-21`).
  - Row 3 shares row 2's handler exactly. Two rows, one destination, one
    method — no `qrMode` flag, no argument, no branch that STORY-003 would
    then have to unpick.
  - No new tokens (AC4). Every tint is derived from an existing
    `CupidColorTokens` field.
- Proposed technical direction: rebuild the body of the single existing screen
  file as header block + three token-driven option rows + privacy note, with
  one private row widget applied three times. Add the four missing Material
  Symbols codepoints to `CupidIcons`. One mobile lane, one phase.
- Why this fits the current system: the screen is already mounted, already
  routed, and already has a preview entry; this story changes only what that
  widget paints and adds glyph constants to the design system that owns them.

### Key Discovery

Four facts from the code contradict what the story and UX spec assume:

1. **This is a rebuild, not an insertion.** The current screen
   (`pairing_choice_screen.dart:83-111`) is a centred title +
   `CupidPrimaryButton` + `TextButton` under `EdgeInsets.fromLTRB(28, 150, 28,
   0)`. It has no icon badge, no subtitle, no card rows, and its title copy
   (`Ghép đôi để mở khoá Cupid`) is not the design's (`Ghép đôi kiểu nào?`).
   Every element in UX spec section 2 is new construction.

2. **The privacy note and the "later" link do not exist today.** Story In
   Scope #2 and UX spec sections 5-6 say to "preserve exactly" — there is
   nothing to preserve. `Để sau` appears in `mobile/lib` only in
   `onboarding/presentation/screens/permissions_screen.dart:166`, a different
   screen.

3. **The "later" link has no reachable destination.**
   `pair_gate_shell.dart:136-151` renders `PairingChoiceScreen` for
   `PairGateUnpaired` and `AppShell` only for `PairGatePaired`; there is no
   skip/browse path in `pair_gate_cubit.dart`. Wiring `goHome` would mean a new
   pair-gate bypass — a new capability, not a redesign. See D1 below.

4. **The existing design-reference capture is stale.**
   `main_preview.dart:224` points at `design-reference-pairingchoice-android.png`
   captured from a block named `isPairingChoice`. That id does not exist in
   `cupid-app-design-system/Cupid Screens.dc.html`; the only block is
   `isPairStart` (line 1571, `sc === 'pairstart'` at line 2509). AC4 must be
   judged against a freshly captured `isPairStart` frame, not that PNG.

## 3. Scope And Assumptions

- In Scope: the body of `PairingChoiceScreen`, its widget test, and the four
  new `CupidIcons` glyph constants the rows need.
- Out Of Scope: `InviteScreen`, `JoincodeScreen`, `PairGateShell`,
  `OnboardingChain`, the service-locator route entry, and any camera capability.
- Assumptions affecting design:
  - `story_master.md` declares `Implementation Lane: shared`, but the whole
    technical surface is under `mobile/`. Treated as a single Mobile lane.
  - Design `--mint` is `rgb(126,231,201)`; the app's `colorMint` is
    `0xFF79E2CD`. The token wins (AC4 forbids new tokens); the ~2/255 delta is
    an accepted pre-existing token deviation, not a fidelity defect.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/pairing/presentation/screens/`.
- New or changed boundaries: none. No route, node, DI entry, or cubit changes.
- Shared patterns reused: `PairingStrings.viEn` for `vi`/`en` copy (the feature's
  own convention, `pairing_strings.dart:11`); `CupidIcon` +
  `CupidIconVariant` for glyphs; `context.cupidColors` / `context.cupidType`
  bound to locals before use.

### Affected Modules

- Mobile: `features/pairing/presentation` and `design_system/icons`.

### Contracts And Integrations

- No loading, empty, or error state exists on this screen — the three options
  are static content, never fetched. A phase that adds a spinner or an error
  branch here is out of scope.
- Compatibility posture: the two destinations keep their current constructors
  and seams, so STORY-002 and STORY-003 remain free to change those screens'
  interiors without touching this one.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Missing glyph codepoints | `cupid_icons.dart:10-14` (cmap workflow) | Add `joinLeft`, `qrCode2`, `dialpad`, `qrCodeScanner` to `CupidIcons`, each verified against the bundled `MaterialSymbolsRounded-Variable.ttf` cmap and dartdoc'd like the existing entries | `flutter test test/design_system/icon_variant_test.dart` plus a widget-test assertion that each row renders its expected `IconData` | Unverified codepoint renders tofu; stop and report the glyph name rather than guessing a nearby codepoint |
| No-fork colour guard | `test/design_system/no_fork_guard_test.dart:18-23` | Derive every tint with `.withValues(alpha:)` from `colorAccentPink` / `colorAccentPurple` / `colorMint` / `colorText`; never write `Color(0x` or `Colors.` under `lib/features` | `flutter test test/design_system/no_fork_guard_test.dart` | Guard names the exact file:line; fix in place, do not add the path to `_guardedDirs` exemptions |
| Header badge gradient axis | `cupid_css_angle_gradient.dart:6-35` | The 140deg badge gradient must use `CupidCssAngleGradient`, with begin/end derived the same way as the existing `_gradient120*` / `_gradient95*` constants in `cupid_color_tokens.dart` | `flutter test test/design_system/gradient_axis_test.dart` | If a 140deg constant pair cannot be derived, use `gradientHot` at the specified alphas and record the deviation in test-results |
| Existing screen tests assert the old two-option shape | `test/features/pairing/presentation/screens/pairing_choice_screen_test.dart:49-81` | Rewrite those three cases against the three-row shape; keep the AC4/AC5 back-edge group and the rotated-viewport case intact | `flutter test test/features/pairing/` | A green run that still asserts "both entry actions" means the rebuild did not land |
| Chrome / stack-root guards | `test/core/navigation/chain_chrome_guard_test.dart` | Keep the `Scaffold` with `key: const Key('pairing_stack')` and no `AppBar`; keep `SingleChildScrollView` so the taller three-row column still survives rotation | `flutter test test/core/navigation/chain_chrome_guard_test.dart` and the rotated-viewport case | Adding an `AppBar` or dropping the scroll wrapper breaks NO_TABS/NO_CHROME |
| Stale design reference for AC4 | `main_preview.dart:221-225` | Capture the AC4 comparison frame from the `isPairStart` block (`Cupid Screens.dc.html` lines 1571-1615); treat `design-reference-pairingchoice-android.png` as stale | Requirement mobile visual audit against the freshly captured `isPairStart` frame | If a fresh capture is unavailable, report AC4 as unverified rather than passing against the stale PNG |

### Lane Handoff

#### Mobile Lane

- Responsibilities: rebuild the screen body, add the four glyph constants,
  update the screen's widget test.
- Authoritative inputs: `ux/ux-spec.md` sections 2-4 and 8; `story_master.md`
  acceptance criteria.
- Guardrails:
  - Do not add a route, an `OnboardingNode`, a DI entry, or a cubit.
  - Do not give row 3 its own handler, flag, or argument — it calls the same
    `_openJoincode` as row 2.
  - Do not change `InviteScreen` or `JoincodeScreen`.
  - Do not implement the "later" link (D1); do not invent a home destination.
  - Do not introduce a new colour token or a raw colour literal.

## 5. Non-Functional Impact

- The column grows from ~350dp to roughly double. The existing
  `SingleChildScrollView` must stay, and the top inset of `150` should follow
  the design's own header offset for this block rather than being carried over
  unexamined — the old value was tuned for a two-button layout.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| D1: omit the "later" escape link this story, escalate to Product Owner | The design source wires it to `goHome`, which no unpaired user can reach | ACCEPTED | Delivering it needs a pair-gate bypass — new capability, outside a redesign story. ACs 1-4 do not reference it. Flagged as DECISION_REQUIRED; the privacy note ships because it is static and has no such dependency. |
| D2: derive row tints via `.withValues(alpha:)` instead of a new palette file | `partner_chip_palette.dart` is the precedent for screen-specific colour sets | ACCEPTED | `colorAccentPink` (`0xFFFF7FB6`) and `colorAccentPurple` (`0xFFB78CF5`) are already exactly the design's `--pink` / `--purple`, so alpha derivation reproduces the spec without adding a token AC4 forbids. |
