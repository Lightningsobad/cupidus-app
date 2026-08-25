# Architecture Solution: STORY-007 `--sky` Global Screen Backdrop Rollout

Status: ARCHITECTURE COMPLETE — **coding plan still pending** (a separate
`Mode: coding-plan` Tech Lead pass must run before implementation starts; the
`Architecture (Tech Lead)` checkbox in `story_master.md` stays unchecked until
then, per the handoff instruction).

Lane: mobile (single lane). Complexity: complex (blast radius, not build size).

## 1. Executive Summary

The story's framing — "implement the `--sky` primitive, replacing the flat
`scaffoldBackgroundColor: colorBackground` paint, and apply it across every
screen" — is **stale**. The UX spec (Section 2) flagged this, and a direct
source audit of this worktree confirms it independently:

- The primitive exists (`CupidAppBackground` + `CupidSkyPalette`).
- It is already mounted **once** above the `Navigator`, so it sits behind every
  route by construction.
- `scaffoldBackgroundColor` is already `Colors.transparent`, not
  `colorBackground`.

So AC1 is already satisfied by existing code, and AC2 is satisfied for every
screen **except** those that paint their own opaque full-bleed layer over the
shared one. The remaining engineering work is therefore an **exhaustive
occlusion audit plus a durable anti-regression guard**, not a rollout.

I ran that audit as part of this architecture pass (method and results in
Section 3). Result: **exactly two** production screens occlude the shared wash,
and **both are intentional**, one design-source-backed and one product-backed.
There is no defect to fix.

That changes the shape of the story from "implement + apply" to "prove +
lock". The deliverable value moves almost entirely into verification and the
regression guard, which is where the coding plan should spend its budget.

## 2. Current State (verified in this worktree)

| Concern | Location | State |
|---|---|---|
| Sky primitive | `mobile/lib/design_system/theme/cupid_app_background.dart` | `ColoredBox(colorBackground)` + `CustomPaint(CupidSkyPainter)` + child + `_CupidSkyStars` |
| Token values | `mobile/lib/design_system/tokens/cupid_sky_palette.dart` | `darkLayers` / `lightLayers` / `stars` |
| Global mount | `mobile/lib/app/cupid_app.dart:59` | `MaterialApp.builder` → `CupidAppBackground(child: child)` |
| Scaffold transparency | `mobile/lib/design_system/theme/cupid_theme.dart:45` | `scaffoldBackgroundColor: Colors.transparent` |
| Design contract | `cupid-app-design-system/Cupid Screens.dc.html:26,44` | `--sky` three radials on the root frame |
| Existing probe test | `mobile/test/design_system/shared_backdrop_occlusion_test.dart` | 6 screens (REQ-002 STORY-046) |
| Existing unit test | `mobile/test/design_system/cupid_app_background_test.dart` | wash + non-hit-testable stars |

Composition-root ordering note (load-bearing for every decision below):
`CupidAppBackground` places the painter **below** `widget.child` (the whole
`Navigator`) and the stars **above** it, inside one `Stack`. Consequences:

- Route push/pop transitions never move or re-mount the wash — it is app-shell
  chrome, not per-route content. No per-screen wiring is possible or wanted.
- Any screen-level opaque full-bleed paint occludes the wash **for that route
  only**, silently. This is the entire failure mode this story must close.

## 3. Occlusion Audit (exhaustive, whole-app)

### 3.1 Method

The audit had to be exhaustive rather than sampled, because the failure mode is
silent and per-screen. Two complementary sweeps over `mobile/lib`:

1. Every `backgroundColor:` assignment in `mobile/lib` (14 hits total, all
   inspected).
2. Every `Scaffold(`-bearing file (42 files: 38 production, 4 preview-harness),
   cross-checked against full-bleed opaque root paints — `colorBackground`,
   `colorSurface`, `Colors.black`/`white`, literal `0xFF171129`, and
   `DecoratedBox`/`Container`/`ColoredBox` used as the outermost body layer.

### 3.2 Result — the only three occluders

| Screen | Evidence | Verdict |
|---|---|---|
| `mobile/lib/features/auth/presentation/screens/splash_screen.dart:141-143` | `Scaffold(body: DecoratedBox(BoxDecoration(gradient: SplashPalette.background)) + SizedBox.expand)` | **Intentional — design-source-backed.** `Cupid Screens.dc.html:1418` gives the splash block its own full-bleed `linear-gradient(168deg,#7B4FBE,#C2508F 55%,#4E8A87)` over the root frame. The design overrides `--sky` here on purpose. Ratified by OQ-1. |
| `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart:128` | `Scaffold(backgroundColor: CupidColorTokens.dark().colorBackground)` | **Intentional — product-backed.** Full-screen photo viewer; hardcodes `dark()` deliberately so letterbox area stays neutral in both themes. No corresponding block exists in the design source. Ratified by OQ-1. |
| `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:147` | `Scaffold(body: DecoratedBox(BoxDecoration(gradient: colors.gradientBrandBackdrop)))` — `0xFF7B2FBE` / `0xFFFF4B8C` / `0xFFFF3366`, fully opaque. Runtime-proven by a temporary, fully-reverted probe: the negative control failed with `occluded.g = 0.19215686274509805` (`0x2F`, the green channel of `#7B2FBE`), confirming the welcome gradient paints over a forced sentinel. | **Intentional — design-source-backed.** `cupid-app-design-system/Cupid Screens.dc.html:69` (`isWelcome` block) specifies `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)` over the root frame; the Dart fill is a value-for-value transcription of it, the same basis already accepted for splash. Ratified by OQ-3. |

Section 3.2 originally reported two occluders; `welcome_screen.dart` was found
by mobile-dev's Phase P1 Task 1 re-sweep, escalated per the AD-3 rule rather
than self-allowlisted, and ratified by Product Owner as OQ-3.

### 3.3 Result — everything else is clean

- All other `backgroundColor:` hits are component-level, not root: avatar/chip
  fills (`me_screen:346`, `profile_edit_screen:136`,
  `contribution_history_screen:256`, `pet_preview_card:229`), sheet surfaces
  (`adopt_sheet:34`, `add_clause_sheet:27`), a selection tint
  (`reminder_schedule_screen:561`), explicit transparents
  (`cupid_header:233`, `cupid_add_action:65`, `cupid_primary_button:85`,
  `reminder_schedule_screen:455`), and a button style
  (`welcome_screen:403` — an `ElevatedButton.styleFrom`, **not** a Scaffold;
  easy to misread from a grep hit alone). Note that `welcome_screen` *is* a
  root occluder, but at `:147` via its body `DecoratedBox`, not via `:403`;
  see §3.2.
- `home_screen.dart:136` — `Scaffold` with no `backgroundColor`. Clean. Its
  `_heroGlow` `Container` (line 310) is an `IgnorePointer` decorative accent,
  not a base layer.
- `app_shell.dart` and `pair_gate_shell.dart` nest a `Scaffold` around tab
  content; neither sets a fill, so nesting is transparent-over-transparent.
- The 9 screens named by the UX spec as already fixed remain fixed.
- The 4 preview-harness files (`mobile/lib/preview/**`, `main_preview.dart`)
  are a developer harness, not app routes, and are out of AC scope.

### 3.4 Architectural reading

The shared backdrop is already correct and already global. The system's actual
weakness is not a missing rollout — it is that **nothing prevents the next
screen from silently re-introducing an opaque root fill**. STORY-046 fixed six
instances of exactly that defect; the existing probe test pins only those six.
The durable fix is a whole-inventory guard, which is what this story should
ship.

## 4. Architecture Decisions

### AD-1 — Build no new theming primitive; AC1 is satisfied by existing code

`CupidAppBackground` + `CupidSkyPalette` already are the reusable primitive.
Introducing a second one (a `SkyBackdrop` mixin, a per-screen wrapper widget,
a `ThemeExtension` variant) would re-create the exact defect
`BUG-20260815-002_waiting_sky_backdrop_orphaned` diagnosed: a duplicated local
wash competing with the shared one. **Explicitly forbidden.**

AC1 evidence is documentary: cite `cupid_app_background.dart`,
`cupid_app.dart:59`, `cupid_theme.dart:45`, plus the existing passing
`cupid_app_background_test.dart`. No production code change for AC1.

### AD-2 — Keep the wash at the composition root; no per-screen application

No screen gets a wash widget, wash parameter, or wash mixin. "Applying the
backdrop to a screen" means, operationally, **removing anything that blocks
it** — nothing more. This keeps the paint cost at one `CustomPaint` for the
whole app and keeps the token single-sourced.

### AD-3 — All three occluders stay; record them as a first-class exception allowlist

Splash, the gallery viewer, and welcome keep their opaque fills:

- Splash matches the locked design source (`Cupid Screens.dc.html:1418`).
  Removing it would be a design regression, not a fix.
- The gallery viewer is a media surface where a purple/magenta wash behind
  letterboxed photos degrades the viewing experience and shifts perceived
  photo color. Its hardcoded `dark()` is deliberate.
- Welcome matches the locked design source's `isWelcome` block
  (`cupid-app-design-system/Cupid Screens.dc.html:69`,
  `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)`); the Dart
  `gradientBrandBackdrop` fill at `welcome_screen.dart:147` is a
  value-for-value transcription of it. Same basis as splash, ratified as OQ-3.

These must become a **named, commented allowlist** consumed by the guard in
AD-4, not an undocumented silence. Each entry carries a one-line rationale and,
for the two design-source-backed entries, the design-source line reference.
This converts "three unexplained exceptions" into "three ratified exceptions",
which is what makes a whole-app guard maintainable.

`AC2` therefore reads as: *every screen except the ratified allowlist paints
the shared wash.* That reading is accepted (OQ-1, OQ-3).

The allowlist is closed at these three. AD-3's escalation rule stands unchanged
for any future find: a fourth occluder is stopped and escalated, never
self-allowlisted by implementation.

### AD-4 — Ship a whole-inventory static occlusion guard (the story's real deliverable)

Add a source-scanning guard test that walks every `Scaffold`-bearing file under
`mobile/lib` and fails when a screen paints an opaque root fill unless that
file is on the AD-3 allowlist. Precedent for source-scanning tests already
exists in this repo (`mobile/test/design_system/no_fork_guard_test.dart`,
`mobile/test/l10n/arb_parity_test.dart`,
`mobile/test/features/reminders/reminder_copy_guard_test.dart`) — this is an
established convention here, not a new mechanism.

Why static and whole-inventory rather than 30 more runtime probes: the runtime
probe is expensive (two full renders per screen, plus real DI/cubit/HTTP
scaffolding per screen — see the `LoveContractRepository` adapter the existing
test needs), and it can only ever cover screens someone remembered to add. The
static guard is O(1) to maintain, covers new screens **automatically on the day
they are written**, and fails with a precise file:line. That combination is
what actually prevents STORY-046 from happening a third time.

Its known limit: a static scan cannot judge computed colors or deeply nested
full-bleed containers. AD-5 covers that gap.

Placement: `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart`
(sibling to the existing per-screen probe test, which keeps its name and role).

### AD-5 — Runtime pixel probes: extend by representative sample, not full 37

This is the explicit decision the story's Rollout Note asks Tech Lead to make.

**Decision: representative sample.** Extend
`shared_backdrop_occlusion_test.dart` by a small set of screens chosen for
*structurally distinct root patterns*, not for coverage count — each new probe
must buy a pattern the existing six do not already prove:

| Probe target | Pattern it proves |
|---|---|
| `home_screen` | tab content inside `app_shell`'s nested `Scaffold`, plus a screen-local hero glow stacked on the shared purple layer (UX risk area 3) |
| a `pair_gate_shell` route | double-nested shell `Scaffold` |
| a scroll/list screen (e.g. `timeline_screen` or `dream_jar_list_screen`) | long scrollable body over a fixed wash |
| `chat_screen` | persistent bottom input chrome + `SafeArea` interaction |

Rationale for capping here: the static guard (AD-4) already provides
whole-inventory coverage of the failure mode; runtime probes exist to prove the
*classes of composition* the static scan cannot reason about. Four well-chosen
probes do that; thirty near-identical ones only multiply DI setup and CI time
for no additional signal. The sample is upgraded to a full pass only if the
static guard or the AD-6 visual pass surfaces a screen whose occlusion is
non-static (computed color, conditional branch).

Blocking constraint for the coding plan — the existing shared helper
`_expectSharedBackdropShowsThrough` asserts
`everyElement(isNull)` over **all** `Scaffold.backgroundColor` in the tree.
Any probe added for a screen inside a nested shell must keep that assertion
true, and the helper must **not** be pointed at an AD-3 allowlisted screen (it
would fail by design). If the helper is reused for new targets it should be
lifted into a shared test-support file rather than copy-pasted.

### AD-6 — AC3 (no visual regression) is a targeted manual pass, not a 37-screen sweep

AC3's risk is bounded by physics: the wash only adds brightness where its
layers are bright. From the token table, that is the **top third** (purple
120%×70% at 15%,-8%, alpha .55; magenta 90%×55% at 95%,6%, alpha .32) and,
faintly, the bottom edge (teal, alpha .16).

So the AC3 pass targets exactly two intersections, both already enumerable:

1. **Contrast in the top third** — screens with `--tx2` (`#B4A6CE`) secondary
   text, thin dividers, or low-contrast icons in the top third.
2. **Double-stacked radial accents** — the only screens with their own
   `RadialGradient` are `home_screen`, `vow_screen`, `vibe_screen`,
   `paired_screen`, `reminder_firing_overlay`, plus the `splash` and
   `dream_jar` palettes. Of these, `splash` is allowlisted and the dream-jar
   palette is card-level. **`home_screen`'s top-right hero glow directly
   overlaps the shared magenta layer** and is the single highest-value
   double-stack check in the app.

Everything outside those two intersections inherits the same wash it has been
rendering against since REQ-002 and needs no new evidence. This is a
correctness argument, not a shortcut: no code in this story changes what those
screens paint.

### AD-7 — No token, theme, locale, or platform changes

`CupidSkyPalette` is a verified value-for-value transcription of the design
source (per `BUG-20260815-002` diagnosis). Light theme and `en` locale stay
infra-only per the story's Out of Scope and prior `OQ5`. Geometry is
fraction-based, so no responsive/breakpoint work exists. Twinkle reduce-motion
behavior is already implemented and already tested — do not touch it.

## 5. Blast Radius And Risk

| Risk | Severity | Handling |
|---|---|---|
| Someone "implements" the story literally and adds a second wash per screen | High — reintroduces `BUG-20260815-002` | AD-1/AD-2 forbid it explicitly; the coding plan must restate this as its first constraint |
| Guard test written too broadly and flags legitimate component fills | Medium — CI noise, forced allowlist inflation | Guard scans **root-level** fills only (`Scaffold.backgroundColor` and the outermost body layer), never nested component colors |
| Guard test written too narrowly and misses a computed opaque fill | Medium — silent regression returns | Accepted and mitigated by the AD-5 runtime sample; documented as the guard's known limit in its own header comment |
| Allowlist becomes a dumping ground | Medium — erodes the guarantee over time | Each entry requires an inline rationale; adding an entry is a reviewable design decision, not a mechanical unblock |
| New probe fails on `everyElement(isNull)` inside nested shells | Low — test authoring friction | Called out as a blocking constraint in AD-5 |
| Scope disagreement: AC2 says "every screen", allowlist says "every screen except three" | Medium — could fail the review gate | Resolved: OQ-1 and OQ-3 both ratified, and `story_master.md` AC2 now names all three allowlisted files |

Production code change expected from this story: **none** — OQ-1 and OQ-3 both
resolved in favor of AD-3. That is an unusual but legitimate outcome for a verification
story, and the review gate should be told so up front.

## 6. Open Questions

**OQ-1 — RESOLVED (ratified by Product Owner): the AC2 exception allowlist is
accepted.**
AC2 reads as "every screen except ratified design/product exceptions". Splash
is backed by the design source directly (`Cupid Screens.dc.html:1418`); the
gallery viewer is an accepted product judgement.

**OQ-3 — RESOLVED (ratified by Product Owner): `welcome_screen.dart:147` is a
third allowlist entry.**
Found by mobile-dev's Phase P1 Task 1 re-sweep, escalated per AD-3 rather than
self-allowlisted, and runtime-proven by a temporary, fully-reverted probe. Its
basis is design-source transcription (`Cupid Screens.dc.html:69`), the same
basis as splash — not a product-judgment call. `story_master.md` AC2 is patched
accordingly. No `mobile/lib` change is required; the only follow-on work is
that the AD-4 guard, AD-5 probes, and AD-6 visual pass must enumerate three
allowlisted files instead of two.

**OQ-2 (non-blocking, informational): story framing correction.**
`story_master.md` In Scope items 1-2 describe building and applying a primitive
that already exists and is already applied. Recommend Scrum Master/PO record
the corrected framing (audit + guard, not rollout) so the review gate judges
the delivered work against reality rather than against the stale text. This
does not block implementation — the ACs remain achievable as written under
OQ-1's disposition.

## 7. Acceptance Criteria → Evidence Mapping

| AC | How it is satisfied | Evidence type |
|---|---|---|
| AC1 — reusable primitive, not per-screen duplication | Already true (AD-1) | Documentary: cited source lines + existing `cupid_app_background_test.dart` |
| AC2 — every screen paints `--sky`, replacing flat fill | Whole-inventory audit (Section 3) + static guard (AD-4) + runtime sample (AD-5), modulo the AD-3 allowlist | New guard test, extended probe test, audit table |
| AC3 — no visual regression from the backdrop layer | Targeted contrast + double-stack pass (AD-6) | Rendered/visual evidence for the enumerated intersections only |

## 8. Expected Change Surface (for the coding-plan pass to size against)

Test/verification only, under the story worktree:

- `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart` (new)
- `mobile/test/design_system/shared_backdrop_occlusion_test.dart` (extend;
  possibly lift its helper into a shared test-support file)
- Story artifacts: `test-results.md`, visual evidence for AD-6

Production `mobile/lib/**`: **no change expected** (see Section 5).

This fits comfortably inside one specialist lifecycle — the coding plan should
be a single mobile-dev phase, not a multi-phase split.

## 9. Sources

- `mobile/lib/design_system/theme/cupid_app_background.dart`
- `mobile/lib/design_system/theme/cupid_theme.dart:45`
- `mobile/lib/app/cupid_app.dart:59`
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart:141-143`
- `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart:128`
- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:147`
- `mobile/test/design_system/shared_backdrop_occlusion_test.dart`
- `cupid-app-design-system/Cupid Screens.dc.html:26,44,69,1418`
- `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/ux/uiux-spec.md`
