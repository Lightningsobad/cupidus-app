# UX Spec: STORY-007 `--sky` Global Screen Backdrop Rollout

## 1. Scope Confirmation (from story_master.md)

- Implement the `--sky` backdrop (three-layer radial wash, design source
  `Cupid Screens.dc.html` line 26/44) as a shared theming primitive applied to
  the root screen frame, replacing any flat/opaque background paint, across
  every screen (~37) for the enabled dark theme + `vi` locale.
- No change to per-screen foreground content, layout, or component design.
- Light theme / `en` locale: token must stay correct; no dedicated visual QA
  pass required.
- Open Question Impact: NONE.

## 2. Critical Finding — Primitive Already Exists (read before scoping build work)

The story's own framing ("replacing the current flat
`scaffoldBackgroundColor: colorBackground` paint in `cupid_theme.dart`") is
**stale**. Direct source read of this worktree shows the shared `--sky`
primitive was already built and globally mounted by REQ-002:

- `mobile/lib/design_system/theme/cupid_app_background.dart` —
  `CupidAppBackground` widget, paints `context.cupidColors.colorBackground`
  fill + `CupidSkyPalette`'s three radial layers + 3 twinkle-star particles.
- `mobile/lib/app/cupid_app.dart:59` — `CupidAppBackground` is mounted once
  via `MaterialApp.builder`, above the `Navigator`, so it sits behind
  **every** route by construction, not per-screen.
- `mobile/lib/design_system/theme/cupid_theme.dart:45` —
  `scaffoldBackgroundColor: Colors.transparent` (with a comment recording
  exactly this rationale: an opaque scaffold here would occlude the wash).
- `mobile/lib/design_system/tokens/cupid_sky_palette.dart` — `darkLayers`/
  `lightLayers`/`stars` are a value-for-value transcription of the design
  source's `--sky` CSS (verified line-by-line in
  `data/bugs/BUG-20260815-002_waiting_sky_backdrop_orphaned/diagnosis.md`).
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening/` —
  already swept 6 screens (`otp`, `love_contract`, `onboarding_profile_setup`,
  `permissions`, `joincode`, `vow`) that had opaque `backgroundColor:`
  overrides occluding this same shared layer; `forgot_screen.dart` and
  `invite_screen.dart` and `dream_jar_detail_screen.dart` carry the same
  fix-precedent comment already.

**Implication for Tech Lead's coding plan:** AC1 (shared primitive exists) is
already true — no new theming primitive needs to be built. The real remaining
work is an **occlusion audit**: find any of the ~37 screens (beyond the 9
already confirmed clean above) that still paint an opaque fill over the root
frame — an explicit `Scaffold(backgroundColor: ...)`, or a full-bleed
`Container`/`ColoredBox`/`DecoratedBox` using `colorBackground`/`colorSurface`
at full opacity as its outermost layer — and remove it, following the
`forgot_screen.dart:103-106` / `STORY-046` precedent exactly. This is
materially smaller than "implement + apply a new primitive to 37 screens,"
and Tech Lead's own verification-breadth decision (representative sample vs.
full pass) should be made with this corrected premise, not the story's
original framing. Recommend Tech Lead/Scrum Master re-confirm story framing
before implementation, since it changes effort sizing.

## 3. Token / Layer Spec (authoritative — unchanged by the finding above)

Design source: `cupid-app-design-system/Cupid Screens.dc.html` line 26
(`body[data-theme="dark"] [data-plat]{--sky:...}`), applied to the root frame
at line 44 (`background:var(--sky),var(--bg)`). This is the same contract
`CupidSkyPalette.darkLayers` already encodes; restated here as the locked
visual spec against which the occlusion audit and any regression check must
be judged.

Paint order (bottom to top): `colorBackground` flat fill, then 3 radial
layers, each an ellipse defined as `radius% at center%` fading to transparent
at `endStop`:

| Layer | Radius (x, y) | Center (x, y) | Color (RGBA) | Fade-out stop |
|---|---|---|---|---|
| 1 — purple (top-left, dominant) | 120%, 70% | 15%, -8% | `rgba(123,47,190,.55)` | 62% |
| 2 — magenta (top-right) | 90%, 55% | 95%, 6% | `rgba(255,75,140,.32)` | 60% |
| 3 — teal (bottom-center, faint) | 80%, 50% | 50%, 108% | `rgba(0,201,167,.16)` | 62% |

Base fill: `colorBackground` = `#171129` (dark theme).

3 twinkle-star particles (theme/platform-independent, decorative,
non-interactive — must never intercept taps):

| Star | Position | Size | Color | Period | Delay |
|---|---|---|---|---|---|
| 1 | left 8%, top 14% | 6px | `#FFFFFF` | 3400ms | 0ms |
| 2 | right 16%, top 9% | 4px | `#FFD9EA` | 4600ms | 800ms |
| 3 | right 7%, top 26% | 5px | `#CEB4FF` | 5200ms | 1600ms |

Twinkle curve: opacity 0.25 → 1.0, scale 0.85 → 1.15, `Curves.easeInOut`,
held at rest state (min opacity/scale, no animation) when
`disableAnimations`/reduce-motion is active.

Light theme (`lightLayers`, token-correctness only, no dedicated QA pass):
same geometry, `rgba(255,182,214,.72)` / `rgba(206,180,255,.60)` /
`rgba(178,240,226,.50)`, base fill `#FFF6FB`.

## 4. Application Rule

- The wash is a **root-frame, app-shell layer** — one instance mounted above
  the `Navigator`, not a per-screen widget. No screen should re-declare or
  duplicate the wash locally (that is the exact defect
  `BUG-20260815-002_waiting_sky_backdrop_orphaned` diagnosed and removed).
- A screen's own `Scaffold`/root container must stay transparent
  (`backgroundColor: null`/unset, or explicit `Colors.transparent`) so the
  shared layer shows through. Screen-local decorative glows (several screens
  already layer their own small radial accents — e.g. hero-card glows) are
  **not** the `--sky` wash and are unaffected by this story; they are
  additive foreground decoration, not a substitute base layer, and must not
  be treated as satisfying AC2 on their own.

## 5. Visual Regression Risk Areas (for Tech Lead / mobile-dev verification)

1. **Occlusion (primary risk).** Any screen with an opaque
   `Scaffold(backgroundColor: ...)`, or a full-bleed opaque
   `Container`/`ColoredBox` as the outermost body layer, silently hides the
   wash on that screen only — exactly the STORY-046 defect pattern. This is
   the main thing a 37-screen sweep needs to check for.
2. **Contrast/readability over the wash's brighter regions.** The purple
   layer (top-left, 55% alpha, largest ellipse) and magenta layer (top-right,
   32% alpha) are the two brightest overlap zones. Any screen with light-on-
   dark text, icons, or thin dividers positioned in the top third of the
   frame should be checked against `--tx` (`#F7EEFB`, primary text) and
   `--tx2` (`#B4A6CE`, secondary text) contrast, since those tokens were
   tuned against the flat `--bg` fill, not necessarily against the brightest
   point of the wash.
3. **Double-stacking with existing screen-local radial accents.** Several
   screens already paint their own local `radial-gradient` glows on top of
   `--bg` (hero highlights, card sheens, success/celebration overlays). Where
   a screen's local glow sits in the same region as one of the three shared
   wash layers (e.g., a top-left hero glow over the shared purple layer), the
   combined brightness/saturation should be checked for banding or
   over-brightness, not assumed additive-safe by default.
4. **Non-interactive twinkle stars.** Confirm stars remain
   `IgnorePointer`/non-hit-testable on every screen (already asserted for the
   existing mount by `cupid_app_background_test.dart`) — no new risk expected
   here, listed for completeness since it's part of the same shared layer.

## 6. Responsive Behavior

Ellipse geometry is fraction-of-surface (`radiusXFactor`/`radiusYFactor`/
`centerXFactor`/`centerYFactor`), not fixed pixels — the wash scales with
frame size the same way on every device/orientation already covered by the
existing `CupidAppBackground` mount. No new responsive behavior is introduced
by this story; the occlusion audit does not change layout at any breakpoint.

## 7. Accessibility Requirements

- Twinkle-star animation must respect `disableAnimations` (reduce-motion) —
  already implemented (rest state: opacity 0.25, scale 0.85, no cycling).
- No screen may rely on the wash's decorative color/brightness to convey
  information — it is atmosphere only, never a status or state signal.
- See risk area 2 above for the contrast check downstream verification must
  run per audited screen.

## 8. Open Items For Downstream Roles

- **Tech Lead:** re-scope the coding plan against Section 2's finding —
  confirm whether any screen beyond the 9 already-fixed ones still has an
  opaque override, and decide representative-sample vs. full 37-screen audit
  breadth per the story's own Rollout Note.
- **mobile-dev:** verification should be evidence-based per audited screen
  (grep for `backgroundColor:`/opaque container on `Scaffold` root plus a
  rendered check), not a blanket re-implementation.

## 9. Sources

- `cupid-app-design-system/Cupid Screens.dc.html` lines 26, 44.
- `mobile/lib/design_system/theme/cupid_app_background.dart`
- `mobile/lib/design_system/theme/cupid_theme.dart`
- `mobile/lib/design_system/tokens/cupid_sky_palette.dart`
- `mobile/lib/app/cupid_app.dart`
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening/story_master.md`
- `data/bugs/BUG-20260815-002_waiting_sky_backdrop_orphaned/diagnosis.md`
- `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/story_master.md`
