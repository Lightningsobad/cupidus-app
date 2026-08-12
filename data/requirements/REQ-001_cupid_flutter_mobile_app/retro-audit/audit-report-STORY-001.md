# Retro Audit Report — STORY-001 Design System

Story: STORY-001 design_system (platform x theme tokens + i18n ARB infra)
Story-Class: shared-foundation, Implementation Lane: mobile
Run Key: 2026-08-12:REQ-001:STORY-001:retro-audit

## Scope Confirmed

`story_master.md` Out of Scope explicitly excludes "Any actual screen
implementation (epic stories build screens on top of this)." Confirmed by
source layout: this story owns exactly `mobile/lib/design_system/**` and
`mobile/lib/l10n/**` (tokens, theme assembly, icons, 4 adaptive widgets,
ARB files + generated `AppL10n`), consumed by `mobile/lib/app/cupid_app.dart`
and `mobile/lib/core/config/cupid_feature_flags.dart`. It builds and exports
no screen widget.

## Substantive Findings - STORY-001

Run Key: 2026-08-12:REQ-001:STORY-001:retro-audit
Story: STORY-001

### AC-by-AC Traceability

| AC | Status | Evidence |
| --- | --- | --- |
| AC 1 — token set buildable for all 4 platform x theme combinations | PASS | `mobile/lib/design_system/theme/cupid_theme.dart:14-51` `buildCupidTheme` takes `platform`/`brightness`, selects `CupidPlatformTokens.ios()`/`.material()` and `CupidColorTokens.dark()`/`.light()` independently (orthogonal axes), attaches all 3 `ThemeExtension`s. `mobile/test/design_system/theme_matrix_test.dart` exists and asserts the 4-combination matrix resolves all 3 extensions with platform/color values differing correctly per axis (read directly; not taken on `test-results.md`'s word alone). |
| AC 2 — i18n ARB files exist for `vi`/`en`; app resolves strings via ARB pipeline | PASS | `mobile/lib/l10n/arb/app_vi.arb` and `app_en.arb` exist; `mobile/lib/l10n/generated/app_l10n.dart` generated. `mobile/test/l10n/arb_parity_test.dart` (read directly) asserts identical key sets between the two ARB files, an empty `l10n-untranslated.json`, and that `AppL10n` resolves distinct, non-empty smoke-key values under both `Locale('vi')` and `Locale('en')` — a real ARB-pipeline resolution check, not a file-existence check. |
| AC 3 — v1 defaults to dark + `vi` only; light/`en` present but flag-gated | PASS | `mobile/lib/core/config/cupid_feature_flags.dart` — `enableLightTheme`/`enableEnLocale` both `bool.fromEnvironment(..., defaultValue: false)`. `mobile/lib/app/cupid_app.dart:35-41` — `themeMode` is `ThemeMode.dark` and `locale` is forced to `Locale('vi')` whenever the flags are off; `en` only follows device locale (falling back to `vi`) when `enableEnLocale` is true. `mobile/test/app/feature_flags_test.dart` (read directly) confirms both flags default false, that the booted `CupidApp` resolves `ThemeMode.dark`/`Locale('vi')` with flags off, and that light `ThemeData` and `en`-locale `AppL10n` remain directly constructible with flags off (existence preserved, only exposure gated — matches OQ5's resolution). |
| AC 4 — no screen-specific forking; platform variance stays inside the named adaptive widgets | PASS | `mobile/lib/design_system/design_system.dart` is a single barrel export (tokens/theme/icons/4 adaptive widgets only). `cupid_primary_button.dart` (read directly) is the only widget observed to branch on `CupidPlatform.of(context)`, and does so to select layout constants, not colors (colors/typography always come from `context.cupidColors`/`context.cupidType`). `mobile/test/design_system/no_fork_guard_test.dart` (read directly) is a real source-scan guard: it recursively scans `lib/features/`, `lib/app/`, `lib/core/` for `Color(0x`, `Colors.`, `Platform.is`, `defaultTargetPlatform` literals and fails the test if any are found — a mechanical enforcement, not a one-time manual check, so the guard continues to protect this AC against regressions from later screen stories. |

Independent verification note: `flutter` is not installed in this
environment, so these test files could not be re-executed to reconfirm the
42/42 pass count in `coding-plan/test-results.md`. Verification here is based
on directly reading `cupid_theme.dart`, `cupid_theme_context.dart`,
`cupid_platform.dart`, `cupid_feature_flags.dart`, `cupid_app.dart`,
`design_system.dart`, `cupid_primary_button.dart`, and the 3 test files named
above, and confirming their assertions structurally match each AC's exact
wording — not from re-trusting `test-results.md` or `review-report.md`
prose.

### Design Fidelity

Applies: `data/devops/system/design-fidelity-config.json` names a locked
`design_source` and this story's lane is `mobile` with `ui_surface: true`.

This story delivers no screen — its entire owned surface is
`design_system/`/`l10n/` infrastructure consumed by later screen stories.
There is no `visual-fidelity/design-reference-*.png` /
`implemented-*.png` pair for this story (confirmed: no `visual-fidelity`
directory exists under `STORY-001_design_system/`), and the reused
`integration-review/mobile-visual-audit.md` only captured/reviewed full
*screens* (`alarm`, `home`, plus 8 uncompared pairs), never a rendered view
of the token/theme surface itself in isolation.

| Screen | Design Reference | Implemented Capture | Result | Deviation |
| --- | --- | --- | --- | --- |
| (none — story owns no screen) | n/a | n/a | UNVERIFIED | No rendered comparison exists for this story's owned token/theme/component surface. Token *values* were cross-checked against `cupid-mobile-design/` only as prose during the UX phase (`ux/uiux-spec.md`, "Token names/values confirmed against `cupid-mobile-design/`") and re-derived numerically by Reviewer during contrast-ratio recomputation (`review/review-report-slice-p0-p1.md`), but never pixel-rendered and diffed against the design source per this audit's evidence bar ("compare RENDERED evidence, not prose... a missing render is not a PASS"). |

Per rule: an `UNVERIFIED` design row blocks `GREEN`/`AMBER` even though every
AC above is `PASS`.

Context (not attributed to this story): `integration-review/mobile-visual-audit.md`
records `alarm` FAIL (gradient-fill background vs. design's dark translucent
card, vertical vs. horizontal day-chip layout, missing partner-confirmation
cards/CTA) and `home` FAIL (still the literal STORY-001 placeholder string,
"never built to the design at all"). Both are screen-building work, which
`story_master.md`'s Out of Scope section explicitly excludes from this story
("Any actual screen implementation (epic stories build screens on top of
this)"). Neither screen's owning story could be identified in this audit's
scope (`alarm` is plausibly STORY-009 nhac_nho_dong_bo; `home` aggregates
tiles from multiple epics — pairing, vibes, pet, alarm — and no single
`STORY-0xx` in `req_master.md`'s User Stories table is named "home" or
"dashboard"), so ownership of the `home` gap specifically should be confirmed
by Scrum Master/Product Owner rather than assumed here. Recommend: capture at
least one rendered view exercising the 4 platform x theme token/adaptive-widget
combinations (e.g., via the existing `lib/main_preview.dart` harness) and diff
it against the corresponding token/component regions of the locked design
source, so this story's own surface gets a real `MATCH`/`DEVIATION` verdict
instead of running the requirement's overall FAIL forward as an assumption.

### Open Question Relevance

| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ5 — Light theme & EN locale in v1? | Yes — this story's core scope | Light theme / `en` locale end-user exposure | Resolved explicitly in `story_master.md` "Open Questions Resolved Here" and `data/intake/bootstrap/conflicts_open_questions.md` (assumption carried into story breakdown, build all 4 combos, enable only dark+`vi`); confirmed at code level by `CupidFeatureFlags` defaults + `CupidApp` wiring | None — correctly implemented, no cut |
| R8 — Socket.IO auth gap | No | Backend chat gateway auth | n/a | Out of this story's scope (network/chat, not tokens/theme/i18n) |
| D1/Critical-Alerts copy conflict | No | Epic-3 notification copy | n/a | Out of this story's scope |
| Other open items in `conflicts_open_questions.md` (Nginx VPS target, backend git-folding, Firebase key rotation, bundle id placeholder) | No | Deployment/infra | n/a | Out of this story's scope |

### OQ Discipline Findings

- No undisclosed scope cuts found. OQ5 is the only OQ material to this
  story's scope, and it was resolved through an explicit, dated, sourced
  triage path (brainstorm → `req_master.md` → central OQ registry →
  `story_master.md`), not silently assumed.
- No other central OQ registry item names this story, its files, or its ACs
  as blocked/affected scope.

### Implementation Defects Or Unverified Behavior

- None found in the token/theme/i18n/adaptive-widget code read for this
  audit. The one prior review finding (ADR-004d stock-`Icons` leakage in
  `cupid_header.dart`/`cupid_add_action.dart`) was independently re-verified
  fixed by a fresh reviewer instance (`review/review-report.md`, direct cmap
  extraction from the bundled font, not taken on the implementer's word) —
  treated here as corroborating context only, not relied on as this audit's
  sole evidence for AC4.
- The only substantive gap is the Design Fidelity `UNVERIFIED` row above:
  this story's design-bearing surface was never rendered and diffed against
  the locked design source, only value-checked in prose/derivation during
  UX and review phases.

Story-level Substantive Verdict: NEEDS_WORK
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
