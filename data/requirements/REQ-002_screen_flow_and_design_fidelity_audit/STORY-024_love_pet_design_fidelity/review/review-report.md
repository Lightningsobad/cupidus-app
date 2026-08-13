# Review Report — STORY-024 Love Pet ("Bún") Design Fidelity

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-024_love_pet_design_fidelity
- Reviewer role: reviewer (compact-story-review)
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-024`
- BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
- Worktree HEAD reviewed: `64a2defcd8e6983bade20f8907d028b6124f9e7d`

## Verdict

**Outcome: PATCH_REQUIRED**

The code changes are real, well-targeted, and I independently confirmed the
implementer's design-source citations are accurate line-for-line. Analyze is
clean and the full suite passes — I re-ran both myself. Two things block CLEAN:

1. **No rendered/visual evidence exists for a story whose central acceptance
   criterion is "no visible deviation" in the rendered screen.** Verification
   is 100% widget-tree assertion. The one rendered capture of this screen in
   the repo (`implemented-pet-emulator-5554.png`, REQ-001/STORY-018) shows a
   network-error state, not the Love Pet screen — so no baseline render of this
   screen has ever been produced. AC1 and AC2 are unevidenced, not disproven.
2. **An undocumented structural deviation**: the design places the Feed/Play
   action row *inside* the surface card; the app renders it *outside*, on the
   page background. This is neither listed among the 32 fixes nor among the 7
   deferrals.

Both are correctable inside this story's existing scope.

## Evidence Basis (independently verified, not taken from the report)

| Check | Method | Result |
| --- | --- | --- |
| Design source is the locked one | `data/devops/system/design-fidelity-config.json` locks `entry: "Cupid App.dc.html"`. That entry imports the audited file at lines 238/250 (`<dc-import name="Cupid Screens" …>`). | Chain valid — auditing `Cupid Screens.dc.html` **is** auditing the locked source |
| Cited design block | Read `Cupid Screens.dc.html` lines 620–700 directly | `<sc-if value="{{ isPet }}">` is at line 629, closes at 689 — citation exact |
| Design reference render | Read `design-reference-pet-android.png` (REQ-001/STORY-018) | Exists, renders the pet screen correctly |
| Implemented render | Read `implemented-pet-emulator-5554.png` (REQ-001/STORY-018) | **Shows "Không có kết nối mạng" error card — not the pet screen** |
| Golden-image infra | `git ls-files` for `golden` | None in repo |

## Per-Deviation Findings

I spot-verified 15 of the report's 32 claimed deviations against the design
source text. All 15 matched exactly. Representative confirmations:

| # | Design source (verified) | Verdict |
| --- | --- | --- |
| 3 | L632 `linear-gradient(178deg,#7B4FBE,#B0518C 52%,#5E7E96)` | Correct. The Alignment derivation is also mathematically right: CSS θ maps to end direction `(sin θ, −cos θ)` in screen coords; θ=178° → `(0.0349, 0.9994)`, matching `pet_hero_gradient.dart` including the `stops: [0.0, 0.52, 1.0]` mid stop |
| 1, 2 | L632 `border:1px solid var(--line)`, `box-shadow:var(--shadow)` | Correct — both were genuinely absent before |
| 4–7 | L645 `padding:6px 16px`, `background:rgba(255,255,255,.2)`, `border:1px solid rgba(255,255,255,.28)`, `font-weight:800` | Correct |
| 9 | L646 `font-family:Nunito;font-weight:900;font-size:34px;letter-spacing:-.02em` | Correct |
| 10 | L647 `font-size:13.5px;color:rgba(255,255,255,.82)` | Correct |
| 13 | L665 `font-family:'Roboto Mono';font-size:12px;color:var(--pink)` on a `justify-content:space-between;align-items:baseline` row | Correct |
| 14, 15 | L666 `height:12px;border-radius:7px;background:var(--surf2)` with `background:var(--grad)` fill | Correct |
| 18, 19 | L674–676 `font-family:Nunito;font-weight:900;font-size:19px`, `padding:14px 10px` | Correct |
| 22 | L680 `font-size:12px;font-weight:700;letter-spacing:.05em;text-transform:uppercase;color:var(--tx2)` | Correct |
| 23, 24 | L682–684 `rgba(121,226,205,.14)` / `rgba(255,201,126,.14)` / `rgba(255,171,147,.14)`, `padding:12px 6px`, caption `11px;700` in role color | Correct |
| 26, 27, 28 | L667 `gap:9px`; L668 `box-shadow:var(--glow)`; L669 `color:var(--pink)` on the secondary glyph | Correct |
| 31 | Hero sits in its own container (L631 `padding:var(--safe-top) 16px 8px`), so the hero→XP gap is that container's 8px bottom padding, not the 13px inter-card gap | Correct reasoning |

The single design-system file touched (`pet_hero_gradient.dart`) is genuinely
single-consumer — I re-ran the grep and it resolves to its own declaration plus
`pet_hero_card.dart` only. Its prior stored value was factually wrong against
the design source, so fixing it in place was the right call, not a scope breach.

### F1 — BLOCKING — Action row container deviation is undocumented

Design source `Cupid Screens.dc.html`: the card opens at **L653**
(`padding:17px;border-radius:var(--r-card);background:var(--surf);box-shadow:var(--shadow)`)
and closes at **L671**. The Feed/Play row at **L667–670** (`margin-top:15px`) is
*inside* that card, sitting on `var(--surf)`.

App `mobile/lib/features/pet/presentation/pet_screen.dart:96-109`:

```dart
PetHeroCard(status: status),
SizedBox(height: CupidSpacing.sm),
PetXpCard(status: status),
SizedBox(height: CupidSpacing.md),
PetActionRow(cooldownRemaining: cooldownRemaining),
```

`PetActionRow` is a sibling of `PetXpCard`, separated by 16pt, rendered directly
on `colorBackground`. This changes the perceived contrast of the secondary
button in particular: the design places a `--surf2` pill on a `--surf` card,
whereas the app places a `colorSurfaceAlt` pill on `colorBackground`.

This is exactly the class of layout/spacing deviation AC1 names, and it is
absent from both §2 (fixes) and §5 (deferrals). It must be either corrected or
explicitly deferred with a stated rationale.

### F2 — BLOCKING — AC1/AC2 have no rendered verification

AC1: "layout, spacing, color/token usage, and typography match exactly with **no
visible deviation**." AC2: "the deviation is corrected **in the rendered app**
(not merely documented) **and re-verified** against the design source."

The report's §7 verification table contains only `flutter analyze`, `flutter
test`, and a `git grep`. Widget-tree assertions confirm that a token was
*assigned*; they cannot confirm the composed result is visually free of
deviation. The implementer's own §2.1 finding #4 illustrates the gap — "dark
plum, reads as a hole" is a rendered-appearance judgement that no widget test
would have surfaced.

This is not a hypothetical bar. The repo already carries the necessary baseline
and tooling from REQ-001/STORY-018: `design-reference-pet-android.png` is
present and correct, and the design bundle ships `render-design-canvas.js` with
a locked `hide_selectors` config for exactly this comparison. Sibling REQ-002
stories in this wave are producing design-reference renders plus emulator
captures.

Required to clear: a rendered capture of the implemented Love Pet screen in the
audited configuration (dark theme + `vi`) placed under the story's
`visual-fidelity/`, compared against `design-reference-pet-android.png`, with
the delta narrated. A Flutter golden of `PetScreen` in the `_ReadyState` branch
is an acceptable equivalent if emulator capture is unavailable — but a written
claim of visual match with no image is not.

### F3 — NON-BLOCKING — D3's cited authority does not say what is claimed

Deferral D3 states the species picker omission is "per `ux/uiux-spec.md` §2.1 —
a documented REQ-001 information-architecture decision."

I read that spec. §2.1's structure list (items 1–5: hero → XP → action row →
stats → reactions) simply **omits** the "Đổi bạn nhỏ" grid; it contains no
decision about it. §2.2 covers the *adopt* sheet's species picker, which is a
one-time adopt-flow control, not the pet tab's "switch companion" affordance.

The deferral is still correct, but on a stronger ground the report did not
state: **the backend has no species-change contract.** Per §1 of the same spec,
`POST /pets/adopt` is one-pet-per-couple (409 on duplicate) and there is no
species mutation endpoint — so the design's switch grid is contract-unbacked,
which the spec elsewhere explicitly says not to fake. Please restate D3 with the
accurate citation.

Note this is the single largest visible difference between the design reference
render and the app — in the reference PNG the picker grid occupies roughly a
third of the viewport. Deferring it is defensible; leaving it justified by a
citation that does not support it is not.

### F4 — NON-BLOCKING — Fidelity tests assert the `en` string, story audits `vi`

`pet_design_fidelity_test.dart:146` asserts `find.text('HOW BUN REACTS')`. The
story's audited configuration is dark theme + `vi` locale. The token assertions
around it are locale-independent so nothing is wrong, but the one string-coupled
assertion pins the locale the story does *not* audit.

### F5 — NON-BLOCKING — Residual near-token roundings not listed as deferred

D6 covers type sizes only. These spacing roundings are also unlisted: design
inter-card `gap:13px` → `CupidSpacing.md` (16); design card `padding:17px` →
`CupidSpacing.md` (16); design outer `padding-bottom:40px` → `CupidSpacing.xl`
(32); design stats `gap:11px` → `CupidSpacing.sm` (8). Each is defensible as
nearest-token, and I agree with keeping them on tokens rather than forking raw
sizes — they just belong in the deferral table so the next audit does not
re-litigate them.

### F6 — OBSERVATION ONLY — Reaction tile 1 sprite state

Design L682 binds the first reaction tile to `state="inlove"`; the app uses
`BunSpriteState.happy`. This is pre-existing REQ-001 state-mapping behaviour
(`ux/uiux-spec.md` §3), not styling, and sits outside this story's named audit
dimensions. Flagging for requirement-integration awareness only; no action here.

## Acceptance Criteria

| AC | Statement | Status | Basis |
| --- | --- | --- | --- |
| AC1 | Rendered dark+`vi` screen matches the design source with no visible deviation | **NOT MET** | No rendered artifact exists (F2). F1 is a concrete unaddressed layout deviation |
| AC2 | Deviations corrected in the rendered app and re-verified | **PARTIAL** | 32 corrections are real and correctly derived, confirmed against source text. "Re-verified against the design source" is unevidenced at the rendered level (F2) |
| AC3 | Pet vector placeholder + growth-state indicators match statically; no animation added | **MET** | `BunSprite` untouched; hero 206 and reaction 46 sizes match design L640/L682–684. No animation code introduced — confirmed in the diff |
| AC4 | No new entry point; existing navigation path unchanged | **MET** | Diff touches only presentation widgets and one single-consumer token. No route, tab, or navigation change present |

## Verification (re-run by reviewer, not copied from the report)

| Command | Reviewer result | Report claim | Match |
| --- | --- | --- | --- |
| `flutter analyze lib/features/pet lib/design_system/tokens/pet_hero_gradient.dart test/features/pet` | `Analyzing 3 items... No issues found! (ran in 2.1s)` | 0 errors, 0 warnings | Yes |
| `flutter test test/features/pet test/design_system` | `+137: All tests passed!` | 137 passed | Yes |
| `flutter test --reporter failures-only` (full suite) | `+929: All tests passed!` (exit 0) | 929 passed | Yes |
| `git -C <worktree> diff <BaseHead>` | 11 files, +642/−69; no stray edits, working tree clean | 7 impl + 2 test files | Yes |
| `git grep -n "PetHeroGradient" -- mobile` | 2 files only | single-consumer | Yes |

All commands run inside
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-024/mobile`
with `PATH="/Users/alantravala/flutter/bin:$PATH"`. No shared design-system
component and no `design_system/adaptive/` file was modified; the no-fork guard
test is green within the 137.

## Required To Clear PATCH_REQUIRED

1. **F1** — Move the Feed/Play row inside the XP card to match design L653–671,
   or add it to §5 with an explicit rationale.
2. **F2** — Produce rendered evidence for the audited configuration
   (dark + `vi`) under the story's `visual-fidelity/`, compared against
   `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-pet-android.png`.
   A `PetScreen` golden is an acceptable substitute if no emulator is available.
   Narrate any remaining delta.
3. **F3** — Restate D3's justification against the missing species-change
   backend contract rather than `ux/uiux-spec.md` §2.1.

## Deferred Findings (accepted as-is, no action required this story)

| ID | Item | Reviewer position |
| --- | --- | --- |
| D1 | Hero radius 34px vs `radiusCard` (26/24) | Accept. No 34 token exists; adding a shape token is shared design-system work outside this story's write scope |
| D2 | Hero decorative/motion layer (breathe glows, ✧/✦ drift, `popIn`, blurred ground shadow) | Accept. Explicitly Out of Scope per the story's own text. Verified present in design at L633–637, L641, L644 |
| D3 | "Đổi bạn nhỏ" species picker grid | Accept the deferral; **reject the stated rationale** — see F3 |
| D4 | 3-up stats grid with per-tile icons | Accept. `ux/uiux-spec.md` §2.1 item 4 and §5 Open Item 2 do explicitly mandate the 2-tile replacement — citation verified accurate. Icon deferral also sound (`CupidIcons` ships no `favorite`/`military_tech`) |
| D5 | Hero copy `#fff` vs `colorText` alpha ramps | Accept for dark theme. Correctly flagged as a light-theme contrast risk for the token owner; light theme is OQ5 and not user-enabled |
| D6 | Exact px type sizes mapped to token roles | Accept. Keeping typography on `CupidTypographyTokens` is the right trade; the two verbatim exceptions (stat 19, XP percent 12) are design-source data and justified |
| D7 | `PetLockedCard` / `PetAdoptPromptCard` unchanged | Accept. These states are absent from the design's `isPet` block — verified; they come from the shared pairing-gate pattern and restyling here would fork it |
| F5 | Near-token spacing roundings | Accept the values; ask only that they be recorded in the deferral table |
| F6 | Reaction tile 1 `happy` vs design `inlove` | Accept. Pre-existing REQ-001 state mapping, outside this story's audit dimensions |

## Residual Risks

- Until F2 is satisfied, no one has seen this screen render. Thirty-two
  simultaneous visual edits landing without a single look at the result is the
  main risk carried into requirement integration.
- D1 (hero radius) and D5 (hero copy color in light theme) are real token-owner
  debts. D5 in particular becomes a contrast defect the moment light theme is
  enabled, since `colorText` is `#3E2645` over a purple hero. Recommend these be
  raised at requirement-integration review rather than lost at story close.
- The cumulative effect of D3 + D4 is that the app's Love Pet screen is
  substantially shorter than the design reference. Both deferrals are
  individually correct, but a reviewer at integration should confirm the
  resulting screen still reads as intentional rather than truncated.
