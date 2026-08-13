# Review Report: STORY-020 Design Fidelity — Vibe Check

Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-020_vibe_check_design_fidelity
Reviewer mode: compact-story-review
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-020`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Worktree HEAD at review: `1c4eace9b6fcecbf054b9f0dbb8d5cda373bdf01`

## Verdict

**Outcome: PATCH_REQUIRED**

The spacing/typography/token half of this audit is genuinely good work: every
numeric value in the implementer's deviation tables was independently
re-derived from `cupid-app-design-system/project/Cupid Screens.dc.html`
(the `isVibe` block, lines 433-486) and from the token files, and all of it
checks out. Analyze and the full test slice reproduce exactly as reported.

It fails on the screen's single most visually dominant element. The design
source renders every mood face through the bespoke `Mood Face` SVG component;
the app renders platform emoji glyphs. AC3 requires that treatment to match
the design source exactly, and the visual-fidelity report asserts AC3 is MET
on a factually incorrect premise. A second, smaller rendering defect (the hero
halo) was also introduced by this story and is not visible to the widget-tree
assertions that were used as evidence.

Both findings are of a kind that a rendered screenshot compared against
`design-reference-vibe-android.png` — which already exists in this repository —
would have surfaced immediately. That comparison was required by the handoff
and was not performed.

## Findings

### F-1 (BLOCKING, AC3 + AC1) — mood faces are platform emoji, not the design source's `Mood Face` component

The design source imports a dedicated vector component for every mood glyph on
this screen:

- mood grid cell: `<dc-import name="Mood Face" mood="{{ m.id }}" style="width:52px;height:52px">` (lines 445, 451)
- partner avatar: same import at `42px` (line 460)
- history strip: same import at `26px`, twice per column (lines 477, 479)

`cupid-app-design-system/project/Mood Face.dc.html` defines that component as a
`viewBox="0 0 100 100"` SVG per mood: a `r=38` circle filled with a
mood-specific vertical `linearGradient`, plus drawn brows, eyes, blush ellipses
and mouth paths, plus an animated accent glyph. Concretely:

| Mood | Design source fill | Accent |
|---|---|---|
| happy | `#FFE9A8` → `#FFC46B` | drifting sparkle |
| soft | `#FFC2DC` → `#FF7FB6` | drifting heart |
| sad | `#DCC9FF` → `#AE8CE8` | falling tear `#8FD8F0` |
| angry | `#FFB39B` → `#F4735F` | steam strokes `#FFE0D6` |
| tired | `#C9D6F5` → `#94A6D8` | rising `z` glyphs, Nunito 900 |
| spicy | `#FFD3C4` → `#FF9FAE` | drifting `#FFF0EA` stroke |
| none | no fill; `#B4A6CE` `stroke-dasharray="7 7"` outline | — |

`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-020/mobile/lib/features/vibes/presentation/widgets/vibe_mood_face.dart:21-32`
renders none of that:

```dart
  static const Map<VibeMood, String> _emoji = <VibeMood, String>{
    VibeMood.happy: '😊',
    VibeMood.sad: '🥺',
    VibeMood.angry: '😤',
    VibeMood.horny: '😳',
    VibeMood.tired: '😴',
  };

  static const String _noneEmoji = '😶';
```

`design-reference-vibe-android.png`
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/`)
shows the intended result: six distinctly-colored drawn faces. The shipped app
shows Noto Color Emoji. These are not the same artwork, not the same palette,
and not the same shape language.

The visual-fidelity report states:

> Mood sticker treatment (AC3) was already correct: `VibeMoodFace` renders the
> same emoji glyphs as the source's `moodList` faces, and this story only
> resized them. No substitute icon set is used.

That is incorrect on its central claim — the design source's `moodList` faces
are not emoji glyphs. AC3's parenthetical permits mood stickers as the one
sanctioned emoji/sticker use *category*; it does not waive the operative
requirement that "its icon/sticker treatment matches the design source
exactly". REQ-002 Scope B also names iconography explicitly
(`requirements/requirements.md:51-56`).

`vibe_mood_face.dart` sits in the same directory as the three widget files this
story did edit, so it is in-lane. If it was excluded from the declared
WriteScope, that is itself a scoping error to escalate to Scrum Master, not a
basis for reporting AC3 as MET.

Required: port the seven `Mood Face` states to a Flutter painter/vector
implementation (`CustomPainter` or bundled SVG asset) reproducing the
documented gradients, features and the `none` dashed-outline state. Resting
frame only is acceptable — the animation deferral in F-4 already covers motion.

### F-2 (BLOCKING, AC1) — the new hero halo is mispositioned and clipped

Design source (line 436): the halo is `position:absolute;top:0;left:50%`
inside the hero block, which carries `padding:14px 0 22px` (line 435). An
absolutely-positioned child resolves `top:0` against the ancestor's *padding
box*, so the halo's top edge is 14px above the title.

`mobile/lib/features/vibes/presentation/vibe_screen.dart:127-179` builds
`Padding(top: 14, bottom: 22) → Stack(alignment: topCenter) → [Positioned(top: 0, glow), Column]`.
The `Stack` is inside the `Padding`, so `top: 0` is the top of the title, not
the top of the hero block. Two consequences:

1. The halo sits ~14 logical px lower than designed, shifting the glow off the
   title it is meant to sit behind.
2. `Stack` sizes to its only non-positioned child (the `Column`, roughly 58 px
   tall for a 27px/1.25 title + 7px gap + 13px subtitle) while the glow is 90 px
   tall. `Stack`'s default `clipBehavior` is `Clip.hardEdge`, so the lower third
   of the halo is clipped. The gradient is still ~20% opaque at that boundary
   across a ~134 px span, which lands as a hard horizontal cut edge on the
   `#171129` background rather than a soft fade.

The radial-gradient math itself is correct and worth keeping: CSS sizes the
`circle` to the farthest corner, `sqrt(90² + 45²) = 100.62`, and Flutter's
`RadialGradient.radius` is a fraction of the shortest side (90), giving
`1.118034`. Only the placement and clipping are wrong.

Required: give the halo the full 180x90 box in unclipped space — e.g. put the
`Stack` outside the `Padding` (or use `Stack(clipBehavior: Clip.none)` with the
offset measured from the padded box top) — and re-verify against a rendered
capture, not a widget-tree assertion.

### F-3 (BLOCKING, process) — no rendered visual evidence for a UI-lane story with a configured design source

`visual-fidelity/visual-fidelity-report.md` contains no screenshot, no golden,
and no rendered capture. Its entire verification section is `flutter analyze`
plus widget-tree `expect`s on `BoxDecoration` fields.

This repository already carries the rendered baseline for this exact screen —
`design-reference-vibe-android.png` and `implemented-vibe-emulator-5554.png`
under REQ-001 STORY-018 — so the comparison was available at zero setup cost.
Both F-1 and F-2 are invisible to widget-tree assertions and immediately
visible in a rendered comparison, which is the concrete demonstration that the
evidence standard matters here rather than being a formality.

Required with the patch: a post-fix rendered capture of the Vibe Check screen
(dark theme, `vi` locale) placed under
`STORY-020_vibe_check_design_fidelity/visual-fidelity/`, compared side by side
against `design-reference-vibe-android.png`, with any residual delta named.

### F-4 (NON-BLOCKING, evidence accuracy) — several "Was" baselines in the deviation table are wrong

Checked against `git diff 8396273 -- mobile/lib/features/vibes/`:

| Report row | Claimed "Was" | Actual value at BaseHead |
|---|---|---|
| 10 (grid face size) | 48 | already `VibeMoodFace(mood: mood, size: 52)` — no change |
| 12 (avatar box) | "48 box, card radius, no inset" | already `52x52`; inset was `CupidSpacing.xs` (4), not absent. Only radius 26→18 and inset 4→5 actually changed |
| 22 (connector) | "square 2px `Divider`-style box" | already `Container(height: 3, color: colorLine)` — only the 2px radius was added |
| 24 (history face size) | 24 | already `size: 26` — no change |

The report's headline "24 deviations fixed in code" therefore over-counts by at
least three no-op rows. Non-blocking on its own — no wrong code resulted — but
it inflates the audit's apparent coverage, and in a story whose deliverable
*is* an evidence artifact that matters. Correct these rows in the patch.

## Independently Verified As Correct

Re-derived from the design source and the token files; no action needed:

- Screen padding `8px 16px 40px` → `fromLTRB(CupidSpacing.md=16, 8, 16, 40)`.
- Hero title 27px/1.25 Nunito w900 → `cupidType.display` (Nunito w900) at
  `fontSize: 27, height: 1.25`; subtitle 13px `--tx2` → `caption`
  (`fontSize: 13`) with `colorTextMuted`; 7px gap.
- Chrome title: `t_vibe: 'Vibe Check'` is identical in both locale maps
  (`Cupid Screens.dc.html:1765` and `:1777`), so the locale-invariant literal
  is faithful to the source.
- Selected cell gradient: `linear-gradient(140deg, rgba(255,127,182,.3),
  rgba(183,140,245,.26))`. The `Alignment(±0.6427876, ±0.766044)` pair is
  `(sin 140°, -cos 140°)`, the same CSS-angle mapping as the existing
  `_gradient120Begin/End` in `cupid_color_tokens.dart:7-8`. Not `gradientDream`
  (opaque, 3-stop, 120deg) — correctly rejected.
- Off-cell border: CSS `border:1.5px solid transparent` over
  `background:var(--surf)` paints the surface colour under the border
  (`background-clip: border-box`), so using `colorSurface` as the border colour
  is exactly equivalent, and it fixes the select/deselect resize jump.
- Cell metrics `17px 8px`, grid `gap:11px` with no outer inset, label
  `12.5px` at a `10px` gap, w800 selected / w600 `--tx2` off.
- Partner card `padding:17px`, row `gap:13px`, avatar `52 / radius 18 /
  inset 5 / face 42` on `--surf2` (`colorSurfaceAlt = #2E2456`), mood label
  `15.5px` w800.
- Nudge banner: `rgba(255,201,126,.14)` → `colorAmber (#FFC97E)` at `alpha
  0.14`; `--r-sm:16px` → `radiusSmall = 16`; `tips_and_updates` at 19px in
  `--butter (#FFD79E)`; text `12.5px/1.45`; geometry `14 / 13x15 / 11`.
- CTA pill: `--grad-hot` → `gradientHot` (120deg `#FF7FB6`→`#B78CF5`),
  `border-radius:999px` → `radiusButton = 999` on both platforms, `7x13`,
  `11.5px` w800, `softWrap: false`. Stays decorative — no `GestureDetector`,
  no button semantics — consistent with UX §5 option (a) and D-010-4.
- History strip: `margin-top:13`, `padding:17`, uppercase `12px` w700 header
  at `letterSpacing: 0.6` (= `.05em` at 12px) in `--tx2`, `margin-bottom:14`,
  column gap 5, stack gap 7, connector `3px`/`2px` radius on `colorLine`
  (`rgba(247,238,251,.11)`), day label `9.5px` mono.
- `_tipsAndUpdates = 0xe79a` is a real cmap entry in the bundled
  `MaterialSymbolsRounded-Variable.ttf`, and the no-fork guard test passes, so
  no raw colour literal or platform fork was introduced.

## Acceptance Criteria

| AC | Requirement | Status | Basis |
|---|---|---|---|
| AC1 | Layout, spacing, colour/token usage and typography match the design source exactly in dark + `vi` | **NOT MET** | Spacing/typography/token work verified correct throughout, but F-1 (mood face artwork) and F-2 (clipped, offset hero halo) are visible deviations |
| AC2 | Deviations corrected in the app, not merely documented | **PARTIAL** | ~20 real fixes landed in code; F-1 was documented as a non-deviation instead of corrected, and F-4 shows ≥3 table rows describe no code change at all |
| AC3 | Each mood-state option's icon/sticker treatment matches the design source exactly | **NOT MET** | F-1 — platform emoji substituted for the `Mood Face` SVG set across grid (52px), avatar (42px) and history (26px) |
| AC4 | No change to how the screen is reached | **MET** | Navigation untouched in the diff; the `HomeScreen` entry-point test (D-010-5) passes unchanged |

## Verification (re-run by reviewer inside the worktree)

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-020/mobile`
with `/Users/alantravala/flutter/bin/flutter`.

| Command | Reviewer result | Matches implementer's claim |
|---|---|---|
| `flutter gen-l10n` | OK | YES |
| `flutter analyze lib/features/vibes test/features/vibes` | 1 issue: `info • prefer_initializing_formals • lib/features/vibes/presentation/vibe_screen.dart:27`. Pre-existing — the diff's first hunk starts at line 37, so line 27 is untouched by this story | YES |
| `flutter test test/features/vibes test/design_system` | 75 passed, 0 failed ("All tests passed!"), including `no_fork_guard_test.dart` | YES |

The four added tests are well-formed and assert real properties (gradient
alpha stops, equal selected/unselected cell heights, amber tint, `gradientHot`
on the pill). Their limitation is scope, not correctness: none of them can
observe glyph artwork or overflow clipping, which is exactly where this story
fails. Note the harness asserts `en` strings ("How are you today?",
"LAST 7 DAYS") while the story targets `vi` — pre-existing harness convention,
carried forward unchanged, not a finding against this story.

## Deferred Findings (accepted, carry forward)

| Item | Rationale | Accepted |
|---|---|---|
| Partner **name** line above the mood label (`11.5px` `--tx2`, design line 461; UX §5 names it) | `CouplePairingStore` resolves only `partnerId` from `GET /users/me`; no partner-name field exists on the frozen backend contract. Needs backend + `lib/core` work, outside this story's lane | YES — route as a follow-up story, not a patch item |
| Two decorative white radial highlights (`rgba(255,255,255,.28)`, design lines 444 and the avatar) | No theme-invariant white token; the no-fork guard bans a raw literal, and `cupid_color_tokens.dart` is out of lane. Purely decorative, no layout impact | YES |
| `popIn` / `bob` / `breathe` / `mfBob` / `mfTear` / `mfZ` animations | Unbounded repeating animations make `pumpAndSettle` time out and would break the existing suite. Resting-state rendering is the right call for now | YES — but the F-1 patch must still match the *resting* frame of each `Mood Face` |
| `CupidHeader` chrome typography (source Nunito 800 21px `-.01em` vs `cardTitle` 22px w600) | `CupidHeader` is shared by every screen; changing it here is a cross-screen edit, not a Vibe Check fix | YES — belongs in a design-system-scoped story |

## Out Of Scope (confirmed, no action)

- **5-cell 3+2 centred grid instead of the source's 3x2 six-cell grid.** The
  source's `soft` mood has no backend enum value; STORY-010 `ux/uiux-spec.md`
  §3 resolves this explicitly and A1 freezes the backend. Approved divergence.
- **History header right-hand "tự xoá sau 30 ngày" label omitted.** STORY-010
  UX §6 / Open Item 3: the backend implements no deletion job, so shipping the
  copy would overstate a retention guarantee. Approved divergence. (The report
  cites this as "§6 A-2"; the spec labels it §6 / Open Item 3 — same decision,
  cosmetic citation mismatch.)
- **No 5-tab bottom bar on this screen** though `design-reference-vibe-android.png`
  shows one. REQ-002 `requirements/requirements.md:65-69` places the main 5-tab
  bottom-navigation structure out of scope for this requirement. Noted for
  Scrum Master's awareness only; not chargeable to STORY-020.

## Required To Clear

1. F-1 — implement the `Mood Face` artwork (7 states, resting frame) and drop
   the emoji substitution.
2. F-2 — un-clip and re-anchor the hero halo to the design's `top:0` of the
   padded hero block.
3. F-3 — attach a post-fix rendered capture compared against
   `design-reference-vibe-android.png`.
4. F-4 — correct the four inaccurate "Was" rows and the deviation count in
   `visual-fidelity-report.md`.

Re-review scope on resubmission: F-1 through F-4 plus a re-run of
`flutter analyze` and `flutter test test/features/vibes test/design_system`.
Everything in "Independently Verified As Correct" is settled and does not need
to be re-argued.

REVIEW_COMPLETE: YES
Outcome: PATCH_REQUIRED
