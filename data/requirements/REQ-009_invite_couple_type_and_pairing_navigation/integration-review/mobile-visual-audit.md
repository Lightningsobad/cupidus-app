# Mobile Cross-Screen Visual Audit — REQ-009 (integration finding B2)

MOBILE_VISUAL_AUDIT: PASS

Lane: mobile-dev · Scope: STORY-INTEGRATION-VISUAL · Platform: android
(`emulator-5554`, 1080x2400) · Theme: dark · Lang: vi · Date: 2026-08-24
Branch: `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`
BaseHead: `c2f5c2e63b5c8523c55a04d469b6bcdf99d216c6`

## What this audit is, and is not

Integration review finding B2 established that STORY-001 and STORY-002 each
photographed **its own screen against its own design reference in isolation**,
so nothing had checked the restored screens **against each other**. This pass
closes exactly that gap. It compares adjacent screenshots to each other along
the two restored sequences.

It does **not** re-litigate single-screen design fidelity. Both per-story
reports already carry `VISUAL_FIDELITY: PASS` and are treated here as settled
design-intent context, not as findings under review.

No new captures were taken and no runtime was booted, built, installed, or
reset by this lane, per the handoff restriction.

## Evidence

All five captures are the DevOps `main_preview.dart` device captures committed
at BaseHead under `integration-review/mobile-screenshots/`:

| Node | Artifact | Chain role (`onboarding_chain.dart`) |
| --- | --- | --- |
| `pairingChoice` | `pairingchoice-android.png` | branch node, no successor edge (`:28-31`) |
| `invite` | `invite-android.png` | `invite -> waiting` (`:38`) |
| `waiting` | `waiting-android.png` | `waiting -> paired` (`:39`) |
| `joinCode` | `joincode-android.png` | `joinCode -> paired`, no `waiting` step per ADR-4 (`:40-42`) |
| `paired` | `paired-android.png` | `paired -> loveContract` (`:43`) |

Design-intent context (read-only, already PASS):
`STORY-001_invite_couple_type_picker/visual-fidelity/visual-fidelity-report.md`,
`STORY-002_pairing_choice_navigation_restore/visual-fidelity/visual-fidelity-report.md`.

Measurements below are normalised to the 1080x2400 frame and quoted as a
percentage of frame height/width, so they are comparable between screens.

## Sequence 1 — `pairingchoice -> invite -> waiting`

### Edge A: `pairingchoice -> invite` (the restored edge)

| Aspect | `pairingchoice` | `invite` | Verdict |
| --- | --- | --- | --- |
| AppBar / header surface | none | none | consistent |
| Bottom nav / tab bar | none | none | consistent |
| Back affordance | absent | present, in-body pink `arrow_back` at ~5.2% top / ~5.8% left | consistent-by-rule (see § Back affordance) |
| Status bar / safe area | system bar over gradient, content clears it | same, content clears it | consistent |
| Background ramp | radial purple -> near-black, magenta bias upper-right | identical ramp and bias | consistent |
| Ambient particle layer | 3 dots at (7.3%, 14.4%), (69.6%, 9.2%), (76.9%, 26.2%) | same 3 dots, same 3 coordinates | consistent |
| Primary CTA treatment | pink->purple horizontal gradient pill, full-width, soft pink outer glow | identical gradient, radius and glow on `Tiếp tục` | consistent |
| Headline face | bold rounded sans, white | same face/weight/colour on the section heading | consistent |
| Accent/link colour | pink `Tôi đã có mã` | same pink family on back glyph and selected card border | consistent |

The gradient ramp and the ambient dot layer are pixel-stable across this edge —
the three decorative dots land on the same three coordinates on **all five**
screens. That is the strongest available evidence that the restored transition
introduces no shell seam: the background layer is continuous through the edge
rather than being re-composed per screen.

Note the dot layer paints **above** foreground surfaces on both sides of the
edge (over the `pairingchoice` CTA pill's top-right, and over the `invite` code
card). This is consistent on both screens and is design-intended, not a
regression: STORY-002's design-reference table already records the reference
render itself as having "2 ... + 1 at CTA top-right" and grades it `match`.

### Edge B: `invite -> waiting`

| Aspect | `invite` | `waiting` | Verdict |
| --- | --- | --- | --- |
| AppBar / tab bar | none | none | consistent |
| Back affordance | present | absent | consistent-by-rule |
| Background ramp + particles | as above | identical | consistent |
| Pairing-code rendering | `CPD-8F2K`, letterspaced, pink->purple gradient glyphs | `CPD-8F2K`, letterspaced, same gradient glyph treatment | consistent |
| Code container | rounded card, full content width | rounded chip, narrower, same surface fill family | intentional de-emphasis, consistent palette |
| Primary CTA | full-width gradient pill + glow | half-width gradient pill + glow, paired with an outlined secondary | consistent treatment |

Code-value continuity across the edge is exact: the same `CPD-8F2K` string in
the same glyph treatment carries from `invite` to `waiting`, so the user's
anchor object survives the transition unchanged.

## Sequence 2 — `pairingchoice -> joincode -> paired`

### Edge C: `pairingchoice -> joincode`

| Aspect | `pairingchoice` | `joincode` | Verdict |
| --- | --- | --- | --- |
| AppBar / tab bar | none | none | consistent |
| Back affordance | absent | present, **same glyph, colour, size and position as `invite`** | consistent |
| Background ramp + particles | as above | identical | consistent |
| Headline | bold rounded sans white, centered | same face/weight/colour, centered | consistent |
| Primary CTA | gradient pill + glow | `Ghép đôi`, identical gradient pill + glow | consistent |
| Secondary affordance | pink text link `Tôi đã có mã` | pink text link `Tôi mới là người tạo mã →` | consistent |

The two branches of `pairingChoice` are symmetric: `invite` and `joincode`
place an identical back glyph at an identical coordinate, so whichever branch
the user takes, the chrome reads the same. That symmetry is the specific
property a per-screen audit could not have observed.

### Edge D: `joincode -> paired`

| Aspect | `joincode` | `paired` | Verdict |
| --- | --- | --- | --- |
| AppBar / tab bar | none | none | consistent |
| Back affordance | present | absent | consistent-by-rule (post-commit terminal) |
| Background ramp + particles | identical | identical | consistent |
| Headline | bold rounded sans white, centered | same, centered | consistent |
| Primary CTA | gradient pill + glow | `Ký Love Contract →`, same gradient + glow | consistent |

`waiting` and `paired` — the two convergence points of the two sequences — use
the same background, the same headline face and the same CTA treatment, so both
branches land on a visually identical destination style.

## Back affordance: the rule is coherent, and B2-adjacent

Observed distribution: back present on `invite` and `joincode`; absent on
`pairingChoice`, `waiting`, `paired`.

That is not an inconsistency, it is a rule with three independent
confirmations:

1. `pairingChoice`'s absent back is **design-confirmed**. STORY-002's
   design-vs-device table grades `Chrome | no AppBar, no tab bar | no AppBar,
   no tab bar, no back affordance | match`.
2. `waiting` and `paired` are post-commit states; backing out of a claimed or
   consumed pairing code is not an affordance the chain offers.
3. The back control is **in-body product code, not a navigation shell**:
   `invite_screen.dart:250` and `joincode_screen.dart:200` each render an
   `_InChainBackButton` calling `Navigator.of(context).maybePop()`. A repo-wide
   grep across `mobile/lib/features/pairing/presentation/screens/` finds no
   `AppBar`, no `appBar:` and no `CupidHeader` on any of the five screens.

This **resolves** the out-of-scope observation STORY-001 deferred to "whoever
owns the invite chrome" (that report, § "Out-of-scope observations from the
capture": the capture has no `Ghép đôi` app-bar title where the canvas shows
one, and it was unclear whether `main_preview.dart` simply fails to mount a
navigation shell). It does not. There is no shell to mount for these nodes:
`OnboardingChain.isChromeless(node)` is `true` for every node except `home`
(`onboarding_chain.dart:52-54`), so an app-bar title on `invite` would violate
the AC4 NO_CHROME contract. The canvas's app-bar title is the item outside the
locked graph's contract, not the implementation. The capture is faithful.

Guard coverage confirms this at test level rather than by screenshot alone:
`test/core/navigation/chain_chrome_guard_test.dart` asserts "renders no header
and no tab bar" and passes (see § Verification).

## The couple-type block under the restored navigation (B2's named item)

This is the one item B2 calls out by name. Measured on `invite-android.png`:

| Element | Top | Bottom | Clearance to neighbour |
| --- | --- | --- | --- |
| Back glyph | 4.4% | 6.0% | — |
| `_InviteCodeCard` | 10.0% | 34.5% | 4.0% below the back glyph |
| Heading `Tụi mình thuộc kiểu nào?` | 37.5% | 39.5% | 3.0% below the code card |
| Subtext | 40.4% | 42.0% | — |
| 2x2 couple-type grid | 43.6% | 75.6% | — |
| CTA `Tiếp tục` | 79.0% | 83.7% | 3.4% below the grid |
| Gesture bar | 97.5% | — | 13.8% below the CTA |

Findings:

- **No collision with the restored back affordance.** The back glyph occupies
  4.4%-6.0%; the couple-type section begins at 37.5%. The restored navigation
  edge and STORY-001's new section are separated by the entire code card and
  never contend for space.
- **Not orphaned.** The heading, subtext, all four cards and the `Tiếp tục` CTA
  are fully rendered in one viewport with 13.8% of frame height still clear
  below the CTA. Nothing is pushed below the fold by the restored chrome, and
  no scroll is required at this geometry.
- **No clipping or overlap.** All four cards render complete: icon tile, title
  and two-line hint each fully inside their card bounds. The two right-column
  hints ("Tụi mình ở cùng một thành phố", "Tụi mình đã gắn bó với nhau lâu
  rồi") wrap to two lines inside the card rather than truncating.
- **Selection state reads correctly against the shared palette.** The selected
  card (`Cùng thành phố`) carries a pink border plus a pink->purple gradient
  icon tile; the three unselected cards carry flat `colorSurfaceAlt` tiles with
  no border. The selected treatment uses the same pink->purple gradient as the
  primary CTA on all five screens, so the couple-type block reads as the same
  design system as the screens on either side of it.
- **Grid geometry is regular.** Both columns share equal width and equal
  gutter; both rows align on their top edges. Row 2 cards are shorter than row
  1 cards because their hints are shorter — no stretched or ragged cell.

Verdict on B2's named item: the couple-type block fits correctly under the
restored `pairingChoice -> invite` edge.

## Raw-capture regression sweep

Each of the five captures examined on its own merits for clipping, overlap or
layout regression:

| Node | Result |
| --- | --- |
| `pairingchoice` | clean. Lower ~60% intentionally empty — STORY-002 grades `Lower two-thirds \| empty background \| match`. |
| `invite` | clean. No truncation, no overflow banner, no overlap. |
| `waiting` | clean. Hourglass badge, headline, two-line subtext, code chip and the `Gửi lại` / `Làm mới` pair all fully rendered; the button pair is centered as a group. |
| `joincode` | clean. All six OTP cells equal width and evenly gutterred, caret in cell 1, no cell clipped at either margin. |
| `paired` | clean. Avatar pair, headline, subtext, the 3 stat tiles and the CTA all fully rendered and horizontally centered. |

No clipping, no overlap, no text truncation, and no Flutter overflow indicator
on any of the five captures.

## Non-blocking observations

Recorded for follow-up. Neither is a REQ-009 regression and neither blocks the
integration gate.

1. **Horizontal page gutter is not tokenized and differs across the restored
   edge.** `pairing_choice_screen.dart:82` uses a hardcoded `28`,
   `invite_screen.dart:29` a hardcoded `20`, and `joincode_screen.dart:207-212`
   `CupidSpacing.lg` (`= 24`, `cupid_spacing.dart:11`). Only `joinCode` uses
   the spacing token. The visible effect is that the primary CTA's side edges
   shift outward by ~8dp when crossing `pairingchoice -> invite`. Both
   per-story passes measured their own screen against its own design reference
   and graded the inset a match, so this tracks the design source rather than
   being introduced by this requirement. Recommend a tokenization follow-up
   (spacing-token adoption across the pairing feature), not a REQ-009 blocker.
2. **One device geometry only.** All five captures are 1080x2400. `invite`
   carries by far the tallest content of the five and clears the fold with
   13.8% to spare here; that margin is not evidence for shorter or
   larger-text-scale devices. `joincode_screen.dart:206` wraps its body in a
   `SingleChildScrollView`, so the shorter-device path has a scroll escape
   there — worth confirming the same holds for `invite` on a short device in a
   later pass.

## Verification

Run in the declared worktree at BaseHead. No product code was modified by this
lane; the only write is this report.

```
cd <worktree>/mobile
flutter analyze lib/core/navigation/onboarding_chain.dart \
                lib/features/pairing/presentation/screens/
-> 4 issues found (ran in 1.8s) — all severity `info`, all
   `prefer_initializing_formals`, all pre-existing at BaseHead in files this
   lane did not touch. No error, no warning.

flutter test test/core/navigation/
-> 00:01 +62: All tests passed!
   includes chain_chrome_guard_test.dart ("renders no header and no tab bar"),
   onboarding_router_test.dart, chain_tail_edges_test.dart, app_shell_test.dart
```

## Verdict

MOBILE_VISUAL_AUDIT: PASS

Both restored sequences were compared edge by edge. Shell/chrome is consistent
across every adjacent pair (no AppBar and no tab bar anywhere, confirmed by
capture, by source grep and by a green chrome guard test); the back affordance
follows a coherent rule that is design-confirmed on `pairingChoice` and
symmetric across the two `pairingChoice` branches; background, gradient and the
ambient particle layer are pixel-stable through all five screens; typography,
palette and CTA treatment read as one design system throughout; and the
couple-type block fits correctly under the restored navigation edge with no
collision, orphaning or clipping. No cross-screen defect found. Two non-blocking
observations are recorded above for follow-up.
