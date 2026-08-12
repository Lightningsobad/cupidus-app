VISUAL_FIDELITY: PASS

No visible deviation. Base `contract` layout matches the design reference
below; the two new sign-status states are additive-only changes to that same
layout (see "Structural fidelity check" and "Implementation smoke check"
below) with no overflow, clipping, or broken layout in either implemented
capture. The design canvas has one composed `contract` state, so the two new
states have no separate mockup to pixel-diff against (team-lead-accepted
waiver, recorded below) — verification for them is the implementation
screenshot smoke check plus the widget-test literal-copy assertions.

## Screen

Design canvas screen id: `contract` (`cupid-app-design-system/project/Cupid App.dc.html`,
per `data-devops/system/design-fidelity-config.json`). Confirmed present via
`render-design-canvas.js --list-screens` and successfully rendered:
`design-reference-contract-android.png` (406x900).

## What was captured

- `design-reference-contract-android.png` — the canvas's single composed
  `contract` state (requester viewer, editable clauses, unsigned). Confirms the
  existing sign caption ("Press and hold to sign — commitment should take
  effort") renders as small pink/purple text directly above the
  `Hold to sign` button — the same token pattern
  (`type.caption.copyWith(color: colors.colorAccentPink)`) this phase reused
  for the new acknowledgment line in `_SignPromptSection`.

## Why the two new P3 states were not captured as implemented screenshots

P3 adds copy/CTA for `ContractSignStatus.partnerAlreadySigned` (partner
viewer) and `.bothSigned` (either viewer) — data-derived states, not new
screens or components (`ux/uiux-spec.md` §1, §3; `architecture/solution.md`
Assumption A-1). The design canvas itself has exactly one composed `contract`
state (confirmed above) — there is no distinct canvas mockup for these two
sign-status permutations to diff a screenshot against.

The implemented side is also unreachable through the existing preview
entrypoint without an out-of-scope code change:
`mobile/lib/main_preview.dart`'s `contract` registry entry
(`_buildContract`, line ~245) wires `LoveContractScreen` to the live
`getIt<LoveContractRepository>()` with no fixture/state-selection support for
`viewerRole` + `signStatus`, and no fake/preview repository for love
contracts exists in the tree. Adding that dev-only state trigger is outside
P3's declared Write Scope (`love_contract_screen.dart`,
`love_contract_entry_tile.dart`, the ARB files, generated l10n, and
`love_contract_screen_test.dart` only) — `main_preview.dart` is not in it, and
this phase's Do-Not list forbids adding a new screen/component/token, which a
speculative preview-only widget would risk drifting toward.

Resolved: team-lead authorized a narrow, one-time write-scope extension to
`lib/main_preview.dart` to add the missing state trigger (a preview-only
fixture repository behind `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS`, no
new screen/component/token). See "Implementation smoke check" below for the
resulting captures.

## Structural fidelity check performed instead

P3's diff to `love_contract_screen.dart` is additive/conditional only, reusing
existing tokens and components, so the base captured design reference above
is still the correct fidelity check for what changed:

- `_SignPromptSection` gained one optional line
  (`acknowledgmentLine`), rendered only when non-null, in the exact style
  already used for the sign caption in the captured design reference. When
  `null` (the state the design reference shows), rendering is byte-identical
  to pre-P3.
- `_SignedConfirmationCard` now takes a precomputed `statusLine` string
  instead of deriving it inline — no layout/token change, verified in the
  full post-edit read of the file.
- Clause rows for a non-editing viewer are wrapped in
  `IgnorePointer` (no visual change) and the add-clause row is conditionally
  absent (hide-not-disable, matching the existing AC4 pattern already proven
  in the design for the unpaired-gate case).

No new spacing, sizing, colour, or typography token was introduced.

## Widgets tests standing in for per-state pixel proof

`love_contract_screen_test.dart` asserts the exact literal copy from
`ux/uiux-spec.md` §2/§3 for every new state (`flutter test
test/features/love_contracts` — 69/69 passing, see
`coding-plan/test-results.md`), including the Named/Neutral acknowledgment
line text, the enabled `HoldToSignButton` for the partner CTA, the hidden
add-clause row, and the inert clause taps.

## Implementation smoke check (P3 addendum)

Structural/overflow verification only, not a pixel-diff against a mockup (the
design canvas has no per-sign-status `contract` state — see above). Captured
per team-lead direction after the initial `SCREEN_UNREACHABLE` block: added a
narrow, preview-only fixture trigger to `main_preview.dart`
(`--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=<state>`, selecting a fixed
`LoveContract` instead of the live repository; `analyze` clean, no new
screen/component/token) and ran both new states on `emulator-5554`, the same
device used for the design reference above. Partner display name fixture set
to `"Minh Anh"` to force the Named-variant copy (the longer of the two
variants) into both captures.

- `implemented-contract-partnerAlreadySigned-emulator-5554.png` (405x900) —
  partner viewer, `ContractSignStatus.partnerAlreadySigned`. Acknowledgment
  line ("Minh Anh đã ký, đến lượt bạn") and the reused sign caption both
  render on their own lines above the `HoldToSignButton` with no clipping or
  overflow; the two-line caption wraps cleanly at the same width as the
  design reference.
- `implemented-contract-bothSigned-emulator-5554.png` (405x900) — requester
  viewer, `ContractSignStatus.bothSigned`. `_SignedConfirmationCard`'s
  `statusLine` ("Bạn và Minh Anh đều đã ký") renders fully inside the card
  with no truncation or overflow; card sizing and spacing match the
  existing confirmation-card token usage.

No defect found in either capture. No code change was needed as a result of
this check.
