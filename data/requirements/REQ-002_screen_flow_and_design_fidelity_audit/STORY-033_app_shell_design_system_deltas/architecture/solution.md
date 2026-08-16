# Architecture: STORY-033 App Shell Design System Deltas

Story: STORY-033 (REQ-002) — Complexity `standard`, lane: mobile only.
Inputs: `../story_master.md`, `../ux/ux-spec.md`.
Baseline inspected: worktree
`story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-033` at
`BaseHead 007310dd672eb30796f31ea6863ec4f5b52d70d3`.

## 0. Mode Decision — Compact Story Solution, No `coding-plan/master-plan.md`

This story is `standard` by risk classification (shared design-system layer,
cross-screen blast radius), but its execution shape is single-lane and narrow:
mobile only, no backend/frontend/devops contract, no new API, no data model, no
cross-role sequencing to coordinate. After the Delta 1 decision in section 1,
the remaining work is **three single-property edits in three files that no other
active story touches**.

A shared `coding-plan/master-plan.md` exists to synchronize multiple
implementation lanes against one contract. There is no second lane here, so a
master plan would carry zero coordinating information. This document is the
sufficient and complete implementation input for `mobile-dev`.

## 1. Delta 1 (skyGradient backdrop) — DECISION: Do Not Implement Here; Transfer To STORY-032

### The decision

**STORY-033 must not implement Delta 1 / AC1.** Delta 1 is transferred to
STORY-032, which is already building exactly this widget. STORY-033 delivers
Deltas 2, 3 and 4 (AC2, AC3, AC4) and inherits AC1 from STORY-032's landing.

This requires Scrum Master / Product Owner ratification because it moves a
declared acceptance criterion out of the story. It is not a Tech Lead
descope — the work still ships in REQ-002, under a named owner, before
requirement integration review. Section 1.4 gives the fallback design in full
if that ratification is refused.

### 1.1 Why — this is not a judgment call about style, it is a file-collision fact

The `skyGradient` token is a **CSS gradient string**, not a Flutter gradient
(`cupid_color_tokens.dart:66-70` dark, `:130-134` light — the field type is
`String`). Nothing in the codebase can consume it directly. Painting it
therefore requires a *translation layer* plus a *widget* plus a *composition
point*, which is a minimum of four files:

| Need | File | Status at this BaseHead |
|---|---|---|
| CSS string → Flutter `RadialGradient` values | `design_system/tokens/cupid_sky_palette.dart` | does not exist; STORY-032 creates it |
| Backdrop widget (wash + sparkles) | `design_system/theme/cupid_app_background.dart` | does not exist; STORY-032 creates it |
| Scaffold must stop painting an opaque fill over it | `design_system/theme/cupid_theme.dart:43` | exists; STORY-032 write scope |
| Composition point at app root | `app/cupid_app.dart:25-45` | exists; STORY-032 write scope |

All four are STORY-032's declared active write scope, and the last two are
**pre-existing files**, so a concurrent STORY-033 edit is a guaranteed merge
conflict on the integration branch, not a hypothetical one.

The third row is the load-bearing constraint that makes independent delivery
impossible. `buildCupidTheme` sets
`scaffoldBackgroundColor: colorTokens.colorBackground`
(`cupid_theme.dart:43`), so **every** `Scaffold` in the app paints an opaque
flat fill. A backdrop composed anywhere above the `Scaffold` is painted over
and invisible; a backdrop composed below it is per-screen, not app-shell.
Satisfying AC1 *necessarily* means editing `cupid_theme.dart` — a file this
handoff forbids STORY-033 from touching, and correctly so.

### 1.2 Why not "new file to dodge the collision"

The handoff asks whether Delta 1's widget should live in a NEW file to avoid
colliding with STORY-032. It can be written into a new file, but that does not
avoid the collision — it relocates it and adds a duplicate:

- The two unavoidable edits (`cupid_theme.dart`, `cupid_app.dart`) still
  collide regardless of where the new widget lives.
- The result is two independent aurora backdrop widgets in
  `design_system/`, both painting the same three-blob wash from the same
  token, that must be de-duplicated during requirement integration review.

That is pure rework, and it directly contradicts the story's own stated
intent: `story_master.md` "Relationship To STORY-032" already records
*"Recommended sequencing: land STORY-032 first (or coordinate jointly) …
rather than both stories independently editing the same files."* The UX spec
concurs (`ux-spec.md` "Placement / integration guidance": ownership of the
actual widget file is a Tech Lead call). This decision executes the sequencing
the PO and Designer both already asked for.

### 1.3 Sequencing dependency finding (per handoff instruction)

STORY-032 has not merged. At this worktree's HEAD, neither
`cupid_sky_palette.dart` nor `cupid_app_background.dart` exists, and
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-032*/`
is **entirely absent** — STORY-032's own artifacts are not in this worktree.
STORY-033 therefore cannot "build on whatever shared-layer state STORY-032
leaves behind", which was the story's stated precondition for a joint pass.

Consequences to record:

- STORY-033's Deltas 2/3/4 are **not** blocked by this and may proceed now.
- AC1 must be verified against STORY-032's landed backdrop at requirement
  integration review, not inside STORY-033's story review.
- STORY-032's scope must be confirmed to actually cover the **sparkle dots**,
  not just the aurora wash. `ux-spec.md` Delta 1 requires both layers
  ("always both present together"). If STORY-032 ships wash-only, the dots
  become a residual delta needing an owner. Scrum Master should confirm this
  against STORY-032's UX spec before closing AC1.

### 1.4 Fallback design, if AC1 must stay in STORY-033

Only if ratification is refused (e.g. STORY-032 slips or is descoped). This is
a complete design, but note it converts a 3-file story into a 6-file story and
takes over STORY-032's write scope, so the two stories must then be serialized
by Scrum Master, never run concurrently.

- **Composition point**: `MaterialApp.builder` in `app/cupid_app.dart`, wrapping
  `child` in a `Stack` with the backdrop at index 0. This is the only point that
  is (a) once per screen, (b) full-bleed under status bar / header / tab bar /
  safe areas, (c) outside the `Navigator`, so it does not rebuild or re-animate
  on route transitions — matching the design source's outermost-container
  placement.
- **Required companion edit**: `cupid_theme.dart:43`
  `scaffoldBackgroundColor` → transparent, with the base `colorBackground` fill
  moved into the backdrop widget itself (the backdrop paints base fill → wash →
  dots, bottom to top). Without this the backdrop is invisible.
- **Widget location is forced, not preferred**: the sparkle dot colors
  (`#FFFFFF`, `#FFD9EA`, `#CEB4FF`) are raw literals, and
  `test/design_system/no_fork_guard_test.dart:10-23` fails any `Color(0x` or
  `Colors.` occurrence in `lib/app`, `lib/features`, `lib/core`. The widget and
  its color constants **must** live under `lib/design_system/` (unguarded).
  `cupid_app.dart` may reference the widget by name only, never a literal.
- **Non-interactive**: wrap in `IgnorePointer`; wash and dots are decorative
  per `ux-spec.md`.
- **Animation containment — the material risk.** The three sparkle dots twinkle
  on infinite staggered loops. A permanently-scheduled animation makes
  `WidgetTester.pumpAndSettle()` never settle and time out. The repo has **210
  `pumpAndSettle` calls across 39 test files**. Composition at
  `MaterialApp.builder` bounds the blast radius to the 6 files that boot
  `CupidApp` / `PairGateShell` / `AppShell` (`test/widget_test.dart`,
  `test/app/feature_flags_test.dart`, `test/core/navigation/app_shell_test.dart`,
  `test/features/reminders/reminder_entry_point_test.dart`,
  `test/features/pairing/presentation/pair_gate_cubit_test.dart`,
  `test/features/gallery/gallery_cubit_test.dart`) — the other 33 pump screens
  directly and are unaffected. Mitigation: hold the twinkle behind
  `MediaQuery.maybeDisableAnimationsOf(context)`, rendering dots at their static
  base opacity when animations are disabled. This is required behavior anyway
  (reduce-motion accessibility) and lets the 6 tests opt out deterministically.
  Do not solve this by deleting `pumpAndSettle` calls.

## 2. Delta 2 — `CupidHeader` Material Back-Arrow Ink (AC2)

Confirmed at `mobile/lib/design_system/adaptive/cupid_header.dart:168`:
`_MaterialHeader`'s `IconButton` uses `color: colors.colorText`.

Change that single argument to `colors.colorAccentPink`. Nothing else in
`_MaterialHeader` changes — not `backgroundColor`, `foregroundColor`,
`titleTextStyle`, `elevation`, or the `ConstrainedBox` tap-target wrapper.

`_IosHeader` is already correct (`:111` renders the chevron in
`colors.colorAccentPink`) — **do not touch it**. After this change both
platform variants read from the same token, which is the intended end state.

Contrast: no new exception. `colorAccentPink` for an **icon** is an explicitly
approved use under ADR-004b (dartdoc at `cupid_color_tokens.dart:88-97`:
"icons, borders, focus rings, gradients and decorative accents"), and is
already what iOS does.

## 3. Delta 3 — `caption` Declared Size (AC3)

Confirmed at `mobile/lib/design_system/tokens/cupid_typography_tokens.dart:49`:
`fontSize: 13` inside the `caption` style.

Change to `fontSize: 11.5`. Font family, weight, and all other styles in the
factory are unchanged.

Implementation notes:

- Do **not** split `caption` into role-specific tokens. The 11px field-label vs
  11.5px helper-text micro-delta is flagged informational-only by `ux-spec.md`
  Delta 3 and is out of scope; raise it as a follow-up if it proves visible.
- AC3's second clause is a real verification obligation, not a formality:
  `type.caption` has ~50 call sites. The confirmed regression case is the
  zodiac helper text at
  `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart:224-225`
  (must return to one line). The uppercase field-label row at `:271-277` shares
  the same base style and must be re-checked for the opposite failure —
  text becoming too small or mis-aligned. Sweep the remaining call sites for
  any layout whose line count or fixed height was keyed to 13px.
- Shrinking text cannot cause new overflow, so the sweep is looking for
  under-filled/mis-centred layouts and hardcoded heights, not clipping.

## 4. Delta 4 — `gradientHot` Axis 120deg → 95deg (AC4)

### Implementation trap — read before editing

`_gradient120Begin` / `_gradient120End` (`cupid_color_tokens.dart:7-8`) are
**shared by both** `gradientDream` (`:71-73`, and the light block at `:136-138`)
and `gradientHot` (`:81-83`, plus the light block). Mutating those two constants
in place silently rotates `gradientDream` too — which `ux-spec.md` Delta 4
explicitly forbids (`gradientDream` stays 120deg per the design source).

**Add a new constant pair; do not edit the existing one.** Point only
`gradientHot` (both dark and light blocks) at the new pair. Leave
`gradientDream` on `_gradient120Begin` / `_gradient120End` in both blocks.

### Exact values

Following the convention already documented at `cupid_color_tokens.dart:3-6`
(CSS `0deg` points to top, angles rotate clockwise; Flutter direction vector is
`(sin θ, -cos θ)`, `begin` is its negation):

```
sin(95°) =  0.9961946980917455
cos(95°) = -0.08715574274765817

_gradient95Begin = Alignment(-0.9961946980917455, -0.08715574274765817)
_gradient95End   = Alignment( 0.9961946980917455,  0.08715574274765817)
```

Colors and stops are unchanged (`#FF7FB6` → `#B78CF5`). Carry a short dartdoc
on the new pair mirroring the existing one, noting that 95deg is the design
source's real CTA angle and that the `--grad-hot` 120deg base variable in the
design source is stale/dead (per `ux-spec.md` Delta 4).

Blast radius: the 17 files consuming `gradientHot` pick this up automatically.
`CupidPrimaryButton` does not consume `gradientHot` today (flat
`colorAccentPink` fill) and is untouched — its restyle is STORY-032's.

## 5. AC5 Test Impact — Verified: No Test-Behavior Changes Required

Each named contract test was read against the three edits above. **All four
continue to pass unmodified. No test needs an intentional update, so AC5's
"called out explicitly" clause has nothing to declare** for Deltas 2/3/4.

| Test | Asserts | Impact |
|---|---|---|
| `test/design_system/no_fork_guard_test.dart` | no `Color(0x` / `Colors.` / `Platform.is` / `defaultTargetPlatform` in `lib/features`, `lib/app`, `lib/core` (`:10-23`) | none — all three edits are inside `lib/design_system/`, which is not a guarded dir, and none introduces a literal |
| `test/design_system/adaptive_widgets_test.dart` (`CupidHeader` group `:55-86`) | icon *identity* (`arrowBack` on Material, `chevronLeft` on iOS), label presence, `AppBar` presence | none — asserts no colors |
| `test/design_system/contrast_test.dart` | `gradientHot.colors, isNotEmpty` (`:97`, `:104`); `type.caption, isNotNull` (`:117`); text-on-background pairs (`:61-71`) | none — Delta 4 changes alignment not colors; Delta 3 changes size not nullability; no text/background color pairing changes |
| `test/design_system/icon_variant_test.dart:67` | bare `CupidIcon` default color is `dark.colorText` | none — renders a standalone `CupidIcon` in a `Scaffold` (`:61`), not a `CupidHeader`; Delta 2 changes only `_MaterialHeader`'s `IconButton` |

The only AC5 risk in the original story scope was Delta 1's animation-vs-
`pumpAndSettle` interaction (section 1.4), which leaves STORY-033 along with
Delta 1.

## 6. Implementation Summary For `mobile-dev`

Three files, three edits, plus one verification sweep:

1. `mobile/lib/design_system/adaptive/cupid_header.dart:168` —
   `colors.colorText` → `colors.colorAccentPink`.
2. `mobile/lib/design_system/tokens/cupid_typography_tokens.dart:49` —
   `fontSize: 13` → `fontSize: 11.5`.
3. `mobile/lib/design_system/tokens/cupid_color_tokens.dart` — add
   `_gradient95Begin` / `_gradient95End`; repoint `gradientHot` in **both** the
   dark and light blocks; leave `gradientDream` and the 120deg pair alone.
4. Sweep `type.caption` call sites for line-count/fixed-height assumptions keyed
   to 13px; confirm `profile_edit_screen.dart:224-225` renders one line.

None of these three files is in STORY-032's write scope, so this story can run
concurrently with STORY-032 with zero merge risk once Delta 1 is transferred.

Gate: `flutter analyze` clean, `flutter test` green with no test edits. Any test
edit that does become necessary must be called out explicitly per AC5.

## 7. Open Decisions For Scrum Master

1. **Ratify the Delta 1 / AC1 transfer to STORY-032** (section 1). Blocks AC1
   only; Deltas 2/3/4 proceed regardless.
2. **Confirm STORY-032 covers sparkle dots, not just the aurora wash**
   (section 1.3), so AC1 does not close with a residual unowned delta.
3. If (1) is refused, **serialize STORY-032 and STORY-033** and re-scope this
   story to six files per section 1.4.
