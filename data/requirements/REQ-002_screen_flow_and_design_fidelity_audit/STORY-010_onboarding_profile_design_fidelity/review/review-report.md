# Review Report: STORY-010 — Design Fidelity, Onboarding Profile Setup

Outcome: PATCH_REQUIRED

Review type: compact-story-review (first review)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-010 | Complexity: trivial | Lane: mobile (single lane, correctly classified)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd` | Commit: `1e60af5`
Recommended story status: IN_PROGRESS — return to Mobile Developer.

## Scope Gate

Source/test files in scope (2 changed, well inside the compact budget):
- `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` (+165/-50)
- `mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart` (+132)

Evidence files in scope:
- `.../STORY-010_onboarding_profile_design_fidelity/story_master.md`
- `.../STORY-010_onboarding_profile_design_fidelity/visual-fidelity/visual-fidelity-report.md`
- `data/runtime/parallel-runs/RUN-...-STORY-010-mobile-dev.json`
- `data/devops/system/design-fidelity-config.json`
- `cupid-app-design-system/project/Cupid Screens.dc.html:93-119` (the `isProfile` block)

Query keys: AC1-AC4, `Design-Screen`/`VISUAL_FIDELITY`, canvas `profile`, `ProfileEditScreen`, `_AvatarSlot`, OQ5.

Touched risk surfaces: mobile interaction; mobile navigation/discoverability.
Critical gates: rendered design-fidelity comparison (12e2/12e3) — **FAILED, missing**;
entry-point reachability (12e1) — PASS; mobile static analysis + widget tests (12e0) — PASS
(independently rerun). Runtime startup smoke (12g) not required: story is `trivial`.

## Blocking Findings

### F1 — No rendered design-fidelity evidence; a static code audit was substituted (BLOCKING)

`data/devops/system/design-fidelity-config.json` has `design_source.type: claude-design`,
`locked: true`, `ui_surface: true`, so the per-story rendered check is mandatory and
non-waivable. The story's `visual-fidelity/` directory contains **only**
`visual-fidelity-report.md`. Missing:

- `implemented-profile-<device>.png` — absent
- `design-reference-profile-<device>.png` — absent
- a top-level `VISUAL_FIDELITY: PASS|FAIL` verdict line — absent from the report entirely
- a resolved `Design-Screen: <id>` line in the visual-fidelity report (`story_master.md`
  records `Screen: profile`, but the report never states the resolved canvas id it compared)

The report's §2 "Method" states the comparison was a *"Static audit of the rendered widget
tree against the design source's `isProfile` markup"*. Reviewing markup against widget code
is exactly the substitute rule 12e3 refuses; "verified by source/code inspection" is a named
non-excuse. Without images nobody — including this review — can confirm the built screen
actually looks like canvas `profile`.

This is not an infeasible ask in this repository:
- Sibling stories on the integration branch carry real captures:
  `STORY-003/visual-fidelity/implemented-splash-emulator-5554.png` +
  `design-reference-splash-android.png`, and the same pair for STORY-020 (`vibe`) and
  STORY-024 (`pet`). The emulator path works.
- The capture entrypoint for this exact canvas already exists:
  `mobile/lib/main_preview.dart:185-188` maps canvas `'profile'` -> `_buildProfile`, and
  `main_preview.dart:370-384` builds `ProfileEditScreen`.

One real obstacle to hand forward: `_buildProfile` awaits
`AccountRepository.fetchProfile()` (`GET /users/me`) inside a `FutureBuilder`, so the capture
needs that profile faked or seeded or the frame renders a `CircularProgressIndicator`. Fake
the state per `mobile-dev/references/visual-fidelity.md`. If it genuinely cannot be forced,
record the concrete blocker — do not substitute a static audit a second time.

Required to clear F1: capture both images, compare them, and record
`VISUAL_FIDELITY: PASS` (or `FAIL` with concrete deltas) plus `Design-Screen: profile`.
Owner: `mobile-dev`.

### F2 — The "Ngôn ngữ" card was deferred on OQ5, but the story's own OQ triage declares AC1 unblocked (BLOCKING)

`Cupid Screens.dc.html:112-115` defines a third field card in the `profile` canvas —
`Ngôn ngữ` label, `{{ langLabel }}` value, `›` chevron — styled identically to the two cards
that were implemented. Omitting a whole card is a visible AC1 deviation ("layout, spacing,
color/token usage, and typography match exactly with no visible deviation").

The visual-fidelity report §6 defers it citing OQ5. But `story_master.md`
`## Open Question Impact` triages explicitly: *"All acceptance criteria (1-4) are
unblocked."* OQ5's recorded reach is light-theme / `en`-locale **visual QA**, not the
presence of a card in the dark+`vi` layout. Per reviewer rule 12, omitting an unblocked
acceptance criterion because an OQ was over-applied is `PATCH_REQUIRED`.

The story also already establishes the correct pattern for this exact tension: D3 renders
the camera badge **inert** and `ExcludeSemantics`-wrapped so styling lands without adding
interaction. The Language card can be rendered the same way — it is a static
label/value/chevron; nothing requires wiring a locale switcher.

Clear F2 by either (a) rendering the card inert to match the design, or (b) obtaining a
Product Owner amendment to `story_master.md` Out of Scope / OQ triage that puts the card out
of AC1's reach. Owner: `mobile-dev`, escalate to `product-owner` if (b).

## Deferred Findings

| # | Finding | Disposition |
|---|---|---|
| D-1 | Report D3 claims the camera badge matches "all six values" incl. glyph `#fff` (`:98`), but the code uses `colors.colorText` (`#F7EEFB`). The **code is right** — `no_fork_guard_test` forbids raw color literals — the **report claim** is imprecise. Move it to §5 Accepted Non-Deviations instead of asserting exactness. | DEFERRED — report wording only |
| D-2 | `story_master.md` frames the target as the "onboarding profile-setup screen", but the app has no such step (`register_screen.dart:62-64` pushReplacement straight to `HomeScreen`). Independently confirmed: `ProfileEditScreen` is referenced only from `me_screen.dart:59` and `main_preview.dart`. The retarget onto the canvas->screen registry is defensible and authoritative, but it currently lives only in the implementer's report §1.5. Scrum Master / PO should ratify it so the story premise is not silently false. | DEFERRED — needs ratification, not rework |
| D-3 | Missing onboarding entry point (`permissions -> profile -> invite`, `:1853` `BACK_TO`). Genuinely Scope A per Out of Scope. | DEFERRED — route to STORY-001/STORY-002 |
| D-4 | Bottom CTA "Tiếp tục → Love Contract" (`:117`, `onClick="{{ goContract }}"`) omitted. Legitimately navigation, explicitly Scope A, and would be actively wrong on a Me->Edit screen. | DEFERRED — legitimate |
| D-5 | 26px zodiac sign artwork (`:109`, `<dc-import name="Zodiac Icon">`) omitted; no asset exists and `design_system/` is outside write scope. Also leaves the chip's asymmetric `5px 12px 5px 5px` padding unmatched, since that padding exists to hug the icon. | DEFERRED — needs an asset follow-up |
| D-6 | Header title "Hồ sơ của bạn" (`:1764`) vs app's "Chỉnh sửa hồ sơ"; `l10n/` outside write scope, and the current title is correct for the Me->Edit path. Coupled to D-2. | DEFERRED — legitimate |
| D-7 | Same app-shell `skyGradient` background gap tracked in STORY-032, if present here. | DEFERRED — see STORY-032 |

Deferral audit: of the five deferrals the implementer claimed, four (D-3 to D-6) hold up
against `story_master.md`'s own Out of Scope text. The fifth — the Language card — does not,
and is raised as F2.

## Verified Good

- **Entry point (12e1), independently confirmed in code, not taken on trust:** `me_screen.dart:59`
  pushes `ProfileEditScreen` from the Me hub — a real discoverable nav path, no direct-URL-only
  access. AC4's "no new entry point" is satisfied; no navigation code was touched.
- **Evidence is real, not asserted.** Rerun in the story worktree:
  `flutter analyze lib/features/account test/features/account` -> `No issues found! (ran in 9.3s)`;
  `flutter test test/.../profile_edit_screen_test.dart` -> `+8: All tests passed!`, with all five
  new STORY-010 fidelity tests present and the three pre-existing behavior tests still green.
  Matches the run file's claims.
- **Token discipline.** D1/D2/D6/D7/D8 are correct against `Cupid Screens.dc.html:96-110`, and
  D5 correctly removes `Icons.person` (Flutter's separate `MaterialIcons` family, forbidden by
  ADR-004d) in favour of `CupidIcon` on the bundled Material Symbols font.
- **Inline `isVi` crop caption is idiomatic here,** not a l10n violation: the same
  `Localizations.localeOf(context).languageCode == 'vi'` pattern appears in ~20 sites across
  `mobile/lib`, and the design source itself carries dual `data-vi`/`data-en` spans at `:100`.
- Worktree clean, scope disjoint from STORY-029 (`me_screen.dart` untouched), no Package.resolved drift.

## Action Items

1. `mobile-dev` — F1: capture `implemented-profile-<device>.png` and
   `design-reference-profile-<device>.png` via the `main_preview.dart` canvas `profile`
   entrypoint with a faked `fetchProfile()`; record `VISUAL_FIDELITY:` and `Design-Screen: profile`.
2. `mobile-dev` — F2: render the "Ngôn ngữ" card inert to match `:112-115`, or escalate to
   `product-owner` for an Out of Scope / OQ triage amendment.
3. `mobile-dev` — D-1: correct the D3 row's `#fff` exactness claim in the visual-fidelity report.
4. `scrum-master` — D-2: ratify the canvas-`profile` -> `ProfileEditScreen` retarget in
   `story_master.md`; D-3 route the onboarding entry point to Scope A.
