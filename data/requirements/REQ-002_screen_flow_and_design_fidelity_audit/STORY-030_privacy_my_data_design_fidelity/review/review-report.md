# STORY-030 Review Report — Design Fidelity: Privacy / My Data

Outcome: DEFERRED_ONLY

- Story: STORY-030 (`privacy_my_data_design_fidelity`), REQ-002
- Review type: `compact-story-review`, round 1
- Complexity: trivial · Implementation Lane: mobile (single-lane, confirmed)
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-030`
- BaseHead: `92930ec38ccbe1e87128a9dd2ff4681edf87fb03`
- Blocking findings: 0 · Deferred findings: 5

## Scope Gate

| Item | Value |
| --- | --- |
| Review report path | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-030_privacy_my_data_design_fidelity/review/review-report.md` |
| Source/test files in scope | `mobile/lib/features/account/presentation/screens/privacy_screen.dart`, `mobile/lib/main_preview.dart`, `mobile/test/features/account/presentation/screens/privacy_screen_test.dart` |
| Read for verification (not story-owned) | `mobile/lib/design_system/adaptive/cupid_header.dart`, `mobile/lib/features/account/presentation/screens/me_screen.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart` |
| Evidence files in scope | `visual-fidelity/visual-fidelity-report.md`, `visual-fidelity/design-reference-privacy-android.png`, `visual-fidelity/implemented-privacy-emulator-5560.png`, `visual-fidelity/implemented-privacy-full-emulator-5560.png` |
| Query keys | AC1-AC5, `Design-Screen: privacy`, `_ExportDataButton`, `_privacyGap`, `chipBackground`, `_gradient150Begin`, `CupidHeader`, `PrivacyScreen` entry point |
| Touched risk surfaces | mobile interaction, mobile navigation/discoverability (verify-only), localization |

Handoff path correction: the changed screen is
`mobile/lib/features/account/presentation/screens/privacy_screen.dart`
(`features/account/`), not `features/privacy/` as the handoff stated.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — dark + `vi` layout/spacing/colour/typography match | PASS (screen body) | 17 real deviations found and corrected in code, each cited to `Cupid Screens.dc.html:1342-1376`; confirmed against both rendered frames. One shared-chrome header delta deferred — D-01. |
| AC2 — deviations corrected in the app, not merely documented | PASS | `privacy_screen.dart` +129/-28 against BaseHead; every row of the report's §6 table is a code change, not a note. |
| AC3 — 3-tier presentation matches per tier | PASS | New `chipBackground` per tier (L1 `rgba(255,255,255,.12)` on the tinted card; L2/L3 `colorSurfaceAlt`), 150deg gradient vectors, level label 9.5px at `.14em`, card padding 18, chip padding 11x5. Visible and correct in both frames. |
| AC4 — PDPA export control copy and styling | PASS | `_ExportDataButton` (`privacy_screen.dart:175-215`): height 52, 1.5px `colorLine` border, `radiusButton`, 20px `Icons.download` in `colorMint`, 9px gap, 15px/w800 label, plus the centred 11px caption. Both `vi` strings match the design source verbatim. Asserted by the new widget test. |
| AC5 — no new entry point | PASS | Verified in code, not on trust: `me_screen.dart:121-126` pushes `PrivacyScreen` from a discoverable `_MenuRow` in the "Tôi" hub. Unchanged by this story; no router or shell file is in the diff. |

## Critical Gates

| Gate | Result |
| --- | --- |
| Static analysis | PASS — reviewer reran `flutter analyze` on all three touched files: "No issues found!" |
| Targeted widget tests | PASS — reviewer reran `flutter test test/features/account/presentation/screens/privacy_screen_test.dart`: 9/9, "All tests passed!" |
| Design fidelity (mobile lane, 12e3) | PASS with deferred delta — both images open as real captures of the `privacy` screen; the reference genuinely depicts this story's screen (title "Dữ liệu của tôi", LEVEL 1/2/3 cards, export button, PDPA caption), not a placeholder or a neighbouring canvas screen. `Design-Screen: privacy` recorded in `story_master.md` and resolved by enumerate → bind → render, not guessed. |
| Runtime startup smoke | Not required — trivial story. De-facto covered: the capture ran the app on `emulator-5560` to the privacy screen without a crash or error frame. |
| Configuration guide | Not applicable — no setup/configuration surface touched. |

DEC-5 reversal is correct, not a regression. The pre-existing test asserting
`find.textContaining('Export')` → `findsNothing` directly contradicted AC4 and
was rightly replaced. Exact AC text controls, and AC4 requires the control to
render; the ghost-mode assertions the old test also carried were preserved as
their own test rather than dropped.

## Deferred Findings

### D-01 — Undeclared header delta (shared component, not a STORY-030 defect)

The visual-fidelity report declares three deltas; a fourth is visible in the
same frames and is not recorded. Sampled from the two captures:

- back arrow: design `rgb(255,127,182)` (accent pink) vs implemented `rgb(255,251,255)` (near white)
- header band: design is a purple→magenta gradient; implemented is flat

Root cause is shared, not story-local: `mobile/lib/design_system/adaptive/cupid_header.dart:154-171`
(`_MaterialHeader`) hardcodes `backgroundColor: colors.colorSurface` and
`color: colors.colorText` on the back arrow.

Deferred rather than blocking because `CupidHeader` is consumed by every screen
with a back affordance. STORY-030 neither touched nor worsened it, and patching
it inside a trivial single-screen story would silently restyle the already-DONE
REQ-002 screens without refreshing any of their captures. It belongs in the same
bucket as the report's declared delta 2 (3-tab shell vs the design's 5 tabs,
tracked at `app_shell.dart:39-47`).

Recommended route: a dedicated REQ-002 shared-chrome story covering
`CupidHeader` + `app_shell.dart`, re-capturing the affected screens once. If
Scrum Master instead rules the header in-scope for per-screen fidelity, that
ruling should reopen the shared-chrome item, not STORY-030.

### D-02 — Export control renders inert

`_ExportDataButton` has no `onTap` and deliberately no button semantics. This
matches the design source (which binds no `onClick`) and respects the story's
Out of Scope exclusion of export/data-handling logic, and the choice not to
announce a button assistive technology cannot honour is the right one. It still
leaves a user-visible affordance that does nothing. Needs a follow-up story with
a real export endpoint and a PDPA delivery contract.

### D-03 — Export strings bypass the ARB bundle

The two export strings use a file-private `_viEn` helper
(`privacy_screen.dart:26-27`) instead of `AppL10n`. The cited precedent is real
and was verified: `gallery_empty_view.dart:24-28` defines the identical helper.
Every other string on the screen still resolves through `AppL10n`. Should fold
into `app_vi.arb` / `app_en.arb` beside the existing `privacy_*` keys when a
story owns the l10n directory.

### D-04 — Declared shared-chrome deltas (accepted as reasoned)

Delta 1 (the "TÙY CHỈNH" ghost-mode card absent from the design) is correctly
kept: it is REQ-001/STORY-021 approved scope satisfying that story's AC2, and
this story's Out of Scope forbids adding interactions, not preserving another
requirement's approved ones. Deltas 2 and 3 (3-tab shell, gallery FAB overlap)
are shared chrome already tracked at `app_shell.dart:39-47` and inherited by
every REQ-002 screen whose design reference shows the tab bar.

### D-05 — `design-fidelity-config.json` does not exist in this repository

Flagged by the implementer and confirmed unresolved. Earlier REQ-002 review
reports cite this file as the source of design-fidelity parameters and
exemptions. Those citations are stale and will mislead the next reader. Worth a
Scrum Master reconciliation pass across REQ-002 review artifacts.

## Traceability

- Requirements: `story_master.md` AC1-AC5, In/Out of Scope, `Design-Screen: privacy`, OQ5 triage (no in-scope AC blocked).
- UX: 3-tier model per §8 of UX system memory, exercised through AC3; design source `Cupid Screens.dc.html:1342-1376`.
- Architecture: trivial story, no `coding-plan/master-plan.md` required (skill rule 9).
- Evidence: `visual-fidelity/visual-fidelity-report.md` plus three PNGs; analyze and test gates independently rerun by the reviewer.

## State Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Route D-01 as a REQ-002 shared-chrome item (`CupidHeader` + `app_shell.dart`); route D-02 as a new export-capability story; fold D-03 into the next l10n-owning story; action D-05 as an artifact reconciliation.
