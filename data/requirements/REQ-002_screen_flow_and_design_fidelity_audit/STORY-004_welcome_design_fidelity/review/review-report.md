# STORY-004 — Welcome Design Fidelity — Review Report

Outcome: DEFERRED_ONLY

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-004_welcome_design_fidelity
- Reviewer mode: compact-story-review (UI lane, rendered fidelity comparison)
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-004`
- Diff baseline: `8396273e6a5e6a2798557aa68864f0ef24cd939b..f0df32a`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-004`

## Scope of review

Reviewed the sealed story diff (4 files, +669/−80), the design source block
itself (`cupid-app-design-system/project/Cupid Screens.dc.html`, lines 68–91),
the corrected screen, the new widget suite, and the mobile-dev fidelity report.
The design source was read independently rather than taken on trust from the
fidelity report.

## Design source cross-check

Every CSS declaration the fidelity report quotes was verified against the
`isWelcome` block at lines 69–88 of the design source. All 13 transcriptions
(gradient, hero padding, wordmark metrics, accent rule, tagline, sub-copy, CTA
geometry/fills, footnote) are accurate. No fabricated or drifted values found.

Corrected in code, verified present in the diff:

| ID | Deviation | Verified |
| --- | --- | --- |
| D1 | Gradient direction — `165deg` sweep, purple top → pink bottom | Yes, `_gradient165Begin/End` derived correctly as `(-sinθ, cosθ)/(sinθ, -cosθ)`; matches CSS 165deg (down-and-slightly-right) |
| D2 | Left-aligned hero (source declares no `align-items`) | Yes, `CrossAxisAlignment.start`, no `textAlign` on hero text |
| D3 | Two-sibling composition — `flex:1` hero + bottom-pinned CTA block | Yes, `Expanded(_WelcomeHero)` + `_WelcomeCtaBlock` |
| D4 | Padding 28px hero / `0 20px …20px` CTA | Yes, carried as named off-grid constants with rationale |
| D5 | Wordmark 60/0.95/−.03em | Yes, `letterSpacing: -1.8` correctly resolves −.03em at 60pt |
| D6 | Missing 52×4 r2 accent rule at 55% alpha | Yes, added with `18/16` margins |
| D7 | Tagline Nunito w700 / 23 / 1.3, `max-width:280` | Yes |
| D8 | Missing sub-copy paragraph 14 / 1.55 / 78% alpha, `max-width:270` | Yes |
| D9 | Three 52pt rows, 10pt gap, per-provider treatment, `--r-btn` pill | Yes, radius from `CupidPlatformTokens.radiusButton`, Apple gated on `CupidPlatform.ios` |
| D10 | Missing legal footnote 11.5 / 1.5 / 65% alpha, centered | Yes |
| D11 | Extra register CTA not present in the design source | Yes, removed with its import and helper |

## Verification evidence

Independently re-run by the reviewer inside the story worktree
(`/Users/alantravala/flutter/bin/flutter`, Flutter 3.44.1):

- `flutter gen-l10n` → OK (required; generated l10n is gitignored)
- `flutter test test/features/auth/presentation/screens/welcome_screen_test.dart test/design_system/no_fork_guard_test.dart`
  → `+7: All tests passed!`

The no-fork guard passing confirms the rework consumes the design system
through tokens only, with no raw color literals or platform forks in
`lib/features`. Mobile-dev's broader evidence (analyze clean, 61 tests) is
consistent with this and is accepted.

The 6 new widget tests are substantive, not placeholders: they pin alignment
(D2), the exact gradient stops and both `165deg` alignments (D1), CTA height,
gap and resolved pill radius (D9/AC3), the iOS-only Apple CTA, and the absence
of the removed register CTA (D11).

## Acceptance criteria

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — dark + `vi` matches design source in layout, spacing, tokens, typography | Met except deferred D13 | Layout, spacing and typography match exactly; color values are token approximations of the source's literal brand hexes |
| AC2 — deviations corrected in the app, not merely documented | Met | All 11 fixes land in `welcome_screen.dart`; the report documents rather than substitutes |
| AC3 — CTA styling matches exactly | Met except deferred D12 | Geometry, gap, fills, foregrounds, label typography and pill radius match; brand glyphs absent |
| AC4 — no change to how the screen is reached | Met | No route, gate or entry-point code touched; `RegisterScreen` remains reachable from `login_screen.dart` (import at :103, CTA label at :234), so D11 orphans nothing |

## Deferred items — accepted, not silently skipped

Both deferrals were checked against the mobile-dev run's declared WriteScope
(`data/runtime/parallel-runs/RUN-…-STORY-004-mobile-dev.json`), which lists only
`welcome_screen.dart`, the auth screen test directory, and the story's own
artifacts. `mobile/assets/**`, `mobile/pubspec.yaml` and
`mobile/lib/design_system/` are genuinely outside it.

- **D12 — Apple/Google brand glyphs.** Source leads each provider row with a
  glyph (Apple mark; inline 4-colour Google "G", 20×20, `gap:9px`). Requires
  asset registration. CTAs currently render label-only; all other CTA
  properties match.
- **D13 — literal brand hexes.** Source hardcodes `#7B2FBE / #FF4B8C / #FF3366`
  (gradient), `#000` (Apple fill), `#fff`, `#1A1A2E` (Google label). Mapped to
  `gradientHot` reversed, `colorBackground` and `colorText`. The rendered
  gradient is therefore `#B78CF5 → #FF7FB6` (2 stops) rather than the source's
  3-stop `#7B2FBE → #FF4B8C 58% → #FF3366`. This is a genuine, visible hue and
  saturation difference — the correct sweep direction on the wrong palette.

Verdict: DEFERRED_ONLY rather than CLEAN, because AC1 and AC3 are not fully
satisfied in the rendered result; and rather than PATCH_REQUIRED, because the
remaining work is outside this story's write scope by design and is shared with
the other REQ-002 auth screens. Expanding scope here is a Scrum Master
decision, not a defect in this story's execution.

## Residual risks and follow-ups

1. **Requirement-level (important).** D12/D13 are recurring across REQ-002's
   auth screens. If each screen defers them individually, REQ-002 closes without
   the audit's stated goal — exact colour fidelity — being met anywhere.
   Recommend a single shared follow-up story adding brand-colour fields to
   `CupidColorTokens` plus the provider-glyph asset pipeline, and treating it as
   a gate input for the REQ-002 integration review.
2. **Light-theme inversion.** D13 maps `#fff`→`colorText` and
   `#000`/`#1A1A2E`→`colorBackground`. Those two tokens swap polarity in the
   light theme, so the Google CTA would render inverted (dark fill, light label)
   once light theme is user-enabled. Out of scope today per OQ5, but this must
   be revisited by the brand-token story before light theme ships.
3. **No scroll wrapper.** The design source's welcome block sits inside an
   `overflow-y:auto` container with `min-height:100%`, and the sibling
   `login_screen.dart:134` uses `SingleChildScrollView`. This screen's hero is a
   fixed `Expanded` column and the story added ~4 new content blocks, so a short
   viewport combined with a large text-scale setting can overflow. Not an AC
   breach and not a regression introduced by this diff alone, but worth a
   robustness follow-up.
4. **Raw buttons in a feature screen.** The CTAs now use bare
   `ElevatedButton`/`OutlinedButton` instead of `CupidPrimaryButton`. Justified
   — the source demands per-provider fills the shared component does not offer,
   and `design_system/` was out of scope — but a `CupidProviderButton` component
   belongs in the same follow-up as D12/D13.

## Observations for Scrum Master / Product Owner

- **AC3 wording vs. locked design source.** The story text describes the CTAs as
  "Dream Gradient CTA per §2 / §3". The locked design source defines black,
  white and outlined CTAs on `welcome` — no gradient CTA. Mobile-dev correctly
  followed the design source, which `story_master.md` names as the locked
  reference. Recommend the AC wording be corrected so the next screen story does
  not resolve this ambiguity the other way.
- **Story class inconsistency.** `story_master.md` records
  `Complexity: trivial` / `Story-Class: trivial` with UX and Tech Lead
  `SKIPPED:trivial`, while the review handoff declared `Story-Class: standard`.
  No harm done — the stricter compact Reviewer gate was applied — but the
  artifact and the scheduler disagree.

## Blocking defects

None.
