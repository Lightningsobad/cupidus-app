# STORY-051: Chat Inverse-Text / colorOnAccent Token Disposition

Status: RETRO_PENDING
Retro-Type: RED-PATCH
Fixes: STORY-018_chat_typing_ghost_design_fidelity
Complexity: trivial
Story-Class: standard
Implementation Lane: shared (ui-ux-designer token spec, then mobile
consumption)

## Artifacts

- [x] Requirements (Product Owner) — this file, `## Product Owner Triage
  (2026-08-18)` and `## Acceptance Criteria` below. Disposition: implement
  now (standalone token add), not blocked on OQ5.
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`. Token `colorOnAccent`:
  dark value verbatim copy of `colorText` dark (`#F7EEFB`, AC3-safe); light
  value `#FFFFFF` per design source's literal `#fff` intent, contrast-checked
  against `gradientHot`'s light-theme stops and shown >= the already-shipped
  dark-theme contrast on the same (theme-identical) gradient (AC4).
- [x] Architecture (Tech Lead) — SKIPPED:trivial (Tech Lead confirmed:
  single new token field in existing token file, no new architecture
  surface). Verified: `CupidColorTokens(...)` is constructed only inside
  `cupid_color_tokens.dart` itself (`copyWith` and `lerp`), with no
  subclass, external construction site, or test mock — so the new
  `required` constructor param has no blast radius beyond that one file.
  No new contract, no cross-lane coordination, UX spec already fixes both
  theme values. One implementation invariant for Mobile Dev: the class is
  a `ThemeExtension`, so `colorOnAccent` must be added to **both**
  `copyWith` and `lerp`; omitting it from `lerp` would silently drop the
  token during theme transitions. The UX spec's "mirror every place
  `colorText` appears" instruction already covers all six touch points.
- [x] Implementation (Development) — Mobile Developer. `colorOnAccent` added
  to `CupidColorTokens` across all six `colorText` touch points (constructor,
  `.dark()` `#F7EEFB`, `.light()` `#FFFFFF`, field decl, `copyWith`, `lerp`);
  `message_bubble.dart` own-bubble text and `chat_composer.dart` enabled send
  glyph now consume it. Evidence:
  `visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`) —
  AC3 proven by pixel equality against STORY-040's captures (send-button
  region byte-identical, all bubble rows delta 0), AC4 by value inspection.
  Gates: `flutter analyze --no-fatal-infos lib test` 0 errors/0 warnings,
  `flutter test` 1285 passed / 2 skipped / 0 failed, debug APK build PASS.
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-016, split out of
`STORY-040_chat_typing_ghost_design_fidelity_hardening`'s Product Owner
scoping (finding D1, carried forward from STORY-018's own
`review/review-report.md`).

The design source sets `color:#fff` on the own-message bubble text and send
glyph; `message_bubble.dart:99` and `chat_composer.dart:310` use
`colors.colorText` instead, because `CupidColorTokens` carries no on-accent /
inverse-text token and ADR-004 forbids raw colour literals under
`lib/features/**`. In the audited dark theme `colorText` is `#F7EEFB` —
imperceptible against the pink→purple gradient, so STORY-040's own AC1 held.
The gap is real in light theme, where `colorText` is `#3E2645` on the same
gradient — a genuine contrast regression there. Not blocking for STORY-040:
light theme is OQ5 and was explicitly out of scope for that hardening pass,
and adding the token is a `design_system/` change outside a chat-screen
story's natural WriteScope.

Exact remediation suggested by the surfacing reviewer: UI/UX Designer +
design-system owner to add a `colorOnAccent` (or equivalently named
inverse-text) token to `CupidColorTokens`, then update
`message_bubble.dart:99` and `chat_composer.dart:310` to consume it, scoped
together with whichever future story delivers light-theme / `en` locale
(OQ5) user-facing support.

Product Owner must confirm this disposition against the current status of
OQ5 (central Open Question registry) before scoping: if OQ5 (light theme /
`en` locale support) is not yet approved product scope, Product Owner should
consider whether this token gap can be closed standalone (token addition +
2-file consumption, without shipping a full light-theme toggle), rather than
leaving it blocked indefinitely on unscoped future work. Record whichever
disposition is chosen — implement now, or keep-and-exclude pending OQ5 — with
reasoning, per this campaign's established triage pattern (see
`STORY-050.../story_master.md` `## Product Owner Triage`).

## Product Owner Triage (2026-08-18)

**OQ5 status:** confirmed still unresolved. `data/intake/bootstrap/conflicts_open_questions.md`
lists it under `## Open Questions (unresolved, blocking-relevant scope only)`
with the working assumption "build token + ARB infrastructure for all 4
[theme/locale] combinations now, but only *enable* dark + `vi` at v1
launch." `req_master.md` still marks light theme "(OQ5, out of scope)" next
to this exact finding. No shared-foundation `design_system` story in this
requirement has re-opened or overridden that working assumption.

**Decision: implement now (disposition (a)), not blocked on OQ5.** OQ5 gates
*enabling* light theme / `en` locale as a user-facing surface, not building
token *infrastructure* for it. The working assumption already commits to
building full 4-combination token infrastructure now — and this is already
the established practice in this campaign: STORY-019's own `## Out of
Scope` states "token-level fixes should stay correct for all 4 combinations
since tokens are shared, but no dedicated light/`en` visual pass is
required." Adding `colorOnAccent` (or an equivalently named inverse-text
token) to `CupidColorTokens` with both a dark-theme and a light-theme value
is exactly that class of token-level fix: it follows the same
already-established multi-theme token pattern other `CupidColorTokens`
entries (e.g. `colorText`, referenced in this story's Background) already
use, requires no light-theme toggle, no `en` locale enablement, and no new
user-facing surface. Leaving a real (if currently invisible) light-theme
contrast defect unfixed indefinitely, purely because the unrelated
light-theme *enablement* question (OQ5) is still open, is disproportionate
to the size of the actual fix.

**Scope boundary:** this story adds one token and updates its two known
consumers. It does not touch light-theme enablement, `en` locale
enablement, or any other OQ5-scoped decision. Resolving OQ5 itself remains
out of scope here and unaffected by this story either way.

## In Scope
1. UI/UX Designer defines a new inverse-text/on-accent color token (e.g.
   `colorOnAccent`) in `CupidColorTokens`, with an explicit value for both
   the dark theme and the light theme, following the same
   per-theme-value pattern already used by existing `CupidColorTokens`
   entries such as `colorText`.
2. Mobile Developer updates `mobile/lib/features/chat/presentation/widgets/message_bubble.dart:99`
   and `chat_composer.dart:310` to consume the new token in place of
   `colors.colorText`.

## Out of Scope
- Enabling light theme or `en` locale as a user-facing toggle/surface (OQ5)
  — unaffected, still open, tracked separately.
- Any other token, screen, or call site beyond the two named above.
- A dark-theme visual-fidelity re-render: the new token's dark-theme value
  must resolve to the same rendered result as the current `colorText`
  dark-theme value, so the `chat` screen's dark-theme render is expected to
  be visually unchanged.

## Acceptance Criteria
1. Given `CupidColorTokens`, when this story is delivered, then it defines a
   new inverse-text/on-accent token (e.g. `colorOnAccent`) with an explicit
   dark-theme value and an explicit light-theme value, added the same way
   existing per-theme tokens (e.g. `colorText`) are defined — not a raw
   color literal, consistent with ADR-004.
2. Given `message_bubble.dart:99` (own-message bubble text) and
   `chat_composer.dart:310` (send glyph), when this story is delivered, then
   both consume the new token instead of `colors.colorText`.
3. Given the `chat` screen rendered in the enabled dark theme + `vi`
   locale configuration (the only user-facing configuration at v1), when
   compared to its state before this story, then the rendered output is
   visually unchanged — the new token's dark-theme value matches what
   `colorText`'s dark-theme value already rendered.
4. Given the new token's light-theme value, when reviewed against the
   design source's `color:#fff` intent for the own-message bubble text and
   send glyph on the gradient background, then it provides adequate
   contrast in light theme — even though light theme is not yet a
   user-facing v1 surface (OQ5), so this cannot be verified with a rendered
   light-theme screenshot; verify by value inspection against the design
   source and the light-theme gradient background color.

## Open Question Impact
OQ5 (light theme / `en` locale enablement) does not block any acceptance
criterion above — this story adds token infrastructure only, consistent
with OQ5's own working assumption, and does not enable light theme or `en`
locale as a user-facing surface.
