# Scope Gate — STORY-027 Design Fidelity: Dream Jar

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: full-story-review
Story: STORY-027 (Complexity: trivial, Story-Class: trivial, Implementation Lane: mobile)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Review report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-027_dream_jar_design_fidelity/review/review-report.md`
Diff baseline: `git -C <Worktree> diff 23fbaf4b8c0107e1374e8fbe2516f61ef2f5641e`
Branch commit under review: `73c6414 feat(STORY-027): match Dream Jar screen to the locked design source`

## Mode budget decision

`full-story-review` caps at 12 touched source/test/config files. This handoff
names 17 (13 lib + 4 test), i.e. 5 over cap. Proceeding as a single pass rather
than a `scoped-slice` split, on these grounds:

- Real diff volume is 1525 added / 253 removed lines across `mobile/` only —
  inside a single-pass budget despite the file count.
- 6 of the 13 lib files are ≤ 23 changed lines (`design_system.dart` +1,
  `cupid_header.dart` +13/-4, `cupid_icons.dart` +23, `dream_jar_strings.dart`
  +23, `dream_jar_amount_format.dart` +15/-2, `dream_jar_detail_cubit.dart`
  +34/-1). The file count is inflated by a widget-per-file extraction of ONE
  screen, not by breadth of behavior.
- The ACs are screen-wide (AC1) and cross-widget (AC4 spans quick-add +
  partner-split). Slicing would force each slice to re-read the same palette,
  strings, and detail-screen context and would fragment AC1 across slices —
  higher total cost, weaker verification.

Recorded per Core Rule 1c as an explicit, justified over-cap decision, not a
silent widening.

## Source/test files in scope (17)

lib:
- `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/design_system/design_system.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/lib/design_system/tokens/dream_jar_palette.dart`
- `mobile/lib/features/dream_jar/data/dream_jar_amount_format.dart`
- `mobile/lib/features/dream_jar/presentation/dream_jar_detail_cubit.dart`
- `mobile/lib/features/dream_jar/presentation/dream_jar_strings.dart`
- `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart`
- `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_hero_card.dart`
- `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_illustration.dart`
- `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_quick_add_section.dart`
- `mobile/lib/features/dream_jar/presentation/widgets/partner_split_card.dart`
- `mobile/lib/main_preview.dart`

test:
- `mobile/test/features/dream_jar/presentation/dream_jar_design_fidelity_test.dart`
- `mobile/test/features/dream_jar/presentation/dream_jar_detail_cubit_test.dart`
- `mobile/test/features/dream_jar/presentation/dream_jar_detail_screen_test.dart`
- `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart`

Out of scope for reads: unchanged `mobile/lib/l10n/arb/**`, app-shell/tab-bar/FAB
owned by other REQ-002 stories, and every non-`dream_jar` feature directory.

## Evidence files in scope

- `.../STORY-027_dream_jar_design_fidelity/story_master.md` (AC 1-5, Out of Scope, Open Question Impact, `Design-Screen: jar`)
- `.../visual-fidelity/visual-fidelity-report.md`
- `.../visual-fidelity/design-reference-jar-android.png`
- `.../visual-fidelity/implemented-jar-emulator-5554.png`

No `coding-plan/master-plan.md` required (Core Rule 9, trivial story).

## Touched risk surfaces and critical gates

| # | Risk surface | Critical gate | Required? |
|---|---|---|---|
| RS1 | Mobile interaction (quick-add presets, contribution entry) | Targeted widget/unit tests exercising the changed states | YES |
| RS2 | Mobile rendering / design-token usage | `flutter analyze` clean over changed scope | YES |
| RS3 | Mobile navigation / discoverability (AC5) | Entry-point reachability independently verified in code (Rule 12e1) | YES — non-waivable |
| RS4 | Design fidelity, mobile lane | Rendered reference + implemented images exist, BOTH opened and read, `Design-Screen: jar` confirmed to be the depicted screen, `VISUAL_FIDELITY` verdict consistent with what the images show (Rules 12e2 / 12e3) | YES |
| RS5 | Runtime startup smoke (Rule 12g) | App launches to first screen | NO — gate applies to non-trivial stories; this story is `Complexity: trivial` |
| RS6 | Setup/configuration (Rule 12a) | `deployment/configuration-guide.md` accuracy | NO — no env, dependency, runtime-config, or manual-setup surface in the diff |

Not touched, therefore not gated: persistence/schema/migration, security/auth,
external integration, async job/workflow, payment provider, deep link/push,
permissions/device API, local storage/offline, operational command,
generated/typed contract, local Docker/Compose/registry.

## Query keys for Phase 2

- AC1 — `DreamJarDetailScreen` build/scaffold structure; `DreamJarPalette` token
  definitions and their call sites; `CupidHeader` changed parameters.
- AC2 — `visual-fidelity-report.md` deviations table rows #1-13 vs. the actual
  corrected code; specifically the "Deltas NOT corrected" section, to confirm
  nothing blocking was documented-but-unfixed.
- AC3 — `DreamJarIllustration` fill-level geometry, container styling, and
  clamping of the fill ratio at 0 / >1 / negative inputs.
- AC4 — `DreamJarQuickAddSection` preset button states; `PartnerSplitCard`
  comparative per-partner display, including equal-split and zero-total inputs.
- AC5 — navigation wiring that mounts `DreamJarDetailScreen`: route table plus
  the list-screen tap/CTA path; confirm no entry point was changed or removed.
- OQ — `OQ5` (light theme / `en` locale): confirm no in-scope AC was skipped by
  over-applying the OQ, and no out-of-scope light/`en` work was pulled in.
- Cubit — `DreamJarDetailCubit` changed state fields and their test coverage.
- Format — `dream_jar_amount_format` rounding/locale behavior and its tests.
- Preview — `main_preview.dart` additions: confirm preview-only, not shipped
  behavior on the real app entrypoint.
- Deferred candidates named by the handoff: 3 ARB copy-string mismatches
  (`mobile/lib/l10n/arb/`, outside this story's write scope) and out-of-scope
  app-shell elements (tab bar / FAB) visible in the capture.

## Gate decision

Phase 2 may proceed. No missing input blocks the review at scope-gate time:
`story_master.md`, the bounded diff, the visual-fidelity report, and both
rendered images are all present. Retro check passed — no
`data/retro-audit/rework-backlog.md` exists, so no pending `RWB-*` item blocks
this ordinary story review.
