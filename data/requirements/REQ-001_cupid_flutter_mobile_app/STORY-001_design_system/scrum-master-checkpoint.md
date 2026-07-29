# Scrum Master Checkpoint — STORY-001 design_system

Scope: REQ-001 / STORY-001_design_system
Requirement Master: `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`
Story Master: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/story_master.md`
Status: IN_PROGRESS

## Git Boundary
- Git-Boundary: REQUIRED
- Story-Class: shared-foundation
- Depends-On: NONE
- Worktree: /Users/alantravala/workspace/snapsofts/cupid-apps
- Branch: main
- MergeTarget: main
- BaseHead: 9b8b91da56f3df06d8001e93ee1c58b8d1a21975
- BoundaryState: /Users/alantravala/workspace/snapsofts/cupid-apps/.git/ai-team-story-boundaries/REQ-001_cupid_flutter_mobile_app/STORY-001.json

## Done This Pass
- Product Owner `requirement-breakdown` complete for REQ-001 (16 stories
  created, `master_requirements_list.md` REQ-001 -> IN_PROGRESS).
- Story Git Boundary established for STORY-001 (fields above).
- UI/UX Designer `story-ux` complete: `ux/uiux-spec.md` written, 4
  platform x theme combinations covered, 2 non-blocking items flagged
  (`colorAccentPurpleDark` light override, icon family).
- Tech Lead `architecture-solution` complete: `architecture/solution.md`
  written. ADR-004a (ThemeExtension: `CupidPlatformTokens`,
  `CupidColorTokens`, `CupidTypographyTokens.forPlatform`, plain-const
  `CupidSpacing`; adaptive widgets `CupidTabBar`/`CupidHeader`/
  `CupidPrimaryButton`/`CupidAddAction` in `design_system/adaptive/` only),
  ADR-004a flag mechanism (`CupidFeatureFlags` via `bool.fromEnvironment`,
  build-time, gates exposure not existence), ADR-004b (contrast rule +
  tripwire test), ADR-004c (`colorAccentPurpleDark` carries dark value
  unchanged, non-text-safe), ADR-004d (Material Symbols Rounded both
  platforms, `--no-tree-shake-icons` build note), ADR-004e (i18n: `intl` +
  `flutter_localizations`, `app_vi.arb` template locale, `AppL10n`,
  `untranslated-messages-file` drift gate). Verification contract: 5 gates
  (4-combo build test, contrast tripwire, ARB key-parity, flag-behavior
  widget test, AC4 source-scan guard for `lib/design_system/`).
  `story_master.md` `Architecture (Tech Lead)` correctly left UNCHECKED
  (coding-plan bundle still outstanding). Requirement configuration-guide
  update flagged REQUIRED (2 `--dart-define` keys + icon tree-shake
  fallback) — owning phase to be assigned by coding-plan.
  Runtime registry `mobile-app` entry still absent per system architecture
  memory §8 (non-blocking for `flutter test` gates, note for DevOps later).

## Done This Pass (cont.)
- Mobile Developer Phase P0 (tokens) complete: 6 Write Scope files created
  (3 ThemeExtension classes, CupidSpacing, CupidPlatform/Override, contrast
  tripwire test) + `coding-plan/test-results.md` created. Verified on disk
  by Scrum Master. `flutter analyze` clean; `flutter test
  test/design_system/contrast_test.dart` 10/10 passed (all 4 ADR-004b
  ratio assertions). `phase-P0-tokens.md` §7 -> DONE and `master-plan.md`
  Phase Overview P0 row -> DONE, both verified. Notable non-invented-value
  decisions: iOS `uiFontFamily` null (host SF Pro), Material `'Roboto'`;
  `skyGradient` kept as verbatim CSS radial-gradient string (no lossless
  Flutter object, deferred to first paint phase); `labelMono` fontSize left
  unset (UX spec has no size, only family/weight).

## Done This Pass (cont. 2)
- Mobile Developer Phase P1 (theme assembly) complete: `cupid_theme.dart`
  (`buildCupidTheme`), `cupid_theme_context.dart` (context accessors),
  `design_system.dart` barrel, `pubspec.yaml` fonts decl, 4 font assets
  in `mobile/assets/fonts/`, `theme_matrix_test.dart` (9/9 passed, all 4
  combinations). `flutter analyze` clean. `phase-P1-theme-assembly.md` §7
  and `master-plan.md` P1 row both -> DONE, verified. Finding for P5:
  Material Symbols Rounded variable font is ~15MB on disk (larger than
  solution.md's ~1-2MB estimate) — raises likelihood
  `--no-tree-shake-icons` will be required; P5 to address in
  configuration-guide.md.

## Done This Pass (cont. 3)
- Mobile Developer Phase P2 (icons) complete: `cupid_icons.dart` (`CupidIcons`
  façade, zero invented icon constants by design — no screen inventory to
  source codepoints from yet, sanctioned extension pattern documented),
  `cupid_icon.dart` (`CupidIconVariant` enum + `CupidIcon` widget using
  Flutter's native `Icon(fill:,weight:,grade:,opticalSize:)`, default color
  from `context.cupidColors.colorText`), `design_system.dart` icon exports,
  `icon_variant_test.dart` (5/5 passed). `flutter analyze` clean.
  `phase-P2-icons.md` §7 and `master-plan.md` P2 row both -> DONE, verified.
  No `--no-tree-shake-icons` build attempted this phase (deferred to P6);
  the ~15MB font-size finding from P1 remains the risk signal to watch.

## Done This Pass (cont. 4)
- Mobile Developer Phase P3 (adaptive widgets) complete: `CupidTabBar`,
  `CupidHeader`, `CupidPrimaryButton`, `CupidAddAction`, adaptive barrel
  exports, `adaptive_widgets_test.dart` (8/8 passed, both-platform +
  hit-target assertions each). `flutter analyze` clean. `phase-P3-...md`
  §7 and `master-plan.md` P3 row both -> DONE, verified. Two non-blocking
  notes for Reviewer/Tech Lead awareness (not re-litigated now): (1)
  structural platform branching uses `CupidPlatform.of(context)` (the
  override-aware resolver) while `context.cupidPlatform` is used only for
  P1 token values — neither reads `Platform.is*`/`defaultTargetPlatform`
  directly, but the phase-file wording could be read as asking for a
  single accessor name; (2) two sanctioned literals transcribed verbatim
  from UX section 6 with no token field (iOS tab icon 26pt/label 10pt;
  Material CTA corner radius 20dp, distinct from the `radiusButton` pill
  token), each a documented private const per the ADR-004c precedent.

## Done This Pass (cont. 5)
- Mobile Developer Phase P4 (i18n/ARB) complete: `l10n.yaml`, `app_vi.arb`
  (template) + `app_en.arb` smoke keys (`app_root_title`,
  `home_screen_greeting`, `common_actions_continue`), pubspec.yaml l10n
  deps + `generate: true`, `.gitignore` entries, `arb_parity_test.dart`
  (4/4 passed). `flutter pub get` (codegen) + `flutter analyze` clean.
  Full regression `flutter test` (P0-P4, 37/37) passed, no regressions.
  `phase-P4-i18n-arb.md` §7 and `master-plan.md` P4 row both -> DONE,
  verified. Non-blocking note: `synthetic-package: false` omitted from
  `l10n.yaml` — installed Flutter SDK reports it as a deprecated no-op;
  recorded in phase file evidence for Reviewer.

## Done This Pass (cont. 6)
- Mobile Developer Phase P5 (flags + app wiring) complete:
  `cupid_feature_flags.dart` (`enableLightTheme`/`enableEnLocale`, both
  `bool.fromEnvironment` default false), `lib/app/cupid_app.dart`
  (relocated), `main.dart` now only `runApp(const CupidApp())`,
  `app_theme.dart` deleted via `git rm` in the same change,
  `feature_flags_test.dart` (4/4 passed), `deployment/configuration-guide.md`
  created (both flag keys, 3-combo QA commands, tree-shake fallback citing
  the P1/P2 ~15MB font finding). Flags-off pins dark+`vi`; flags-on follows
  device with `vi` fallback (not first `supportedLocales` entry); both
  locales always registered. `Key('home_screen_ready_signal')` preserved
  and verified resolving. `flutter analyze` clean (zero dangling
  `AppTheme` refs). Full regression P0-P5: 41/41 passed. Collateral fix
  noted: `test/widget_test.dart` import updated from `main.dart` to
  `app/cupid_app.dart` (one line, confirmed passing in the 41/41 run).
  `phase-P5-...md` §7 and `master-plan.md` P5 row both -> DONE, verified.

## Done This Pass (cont. 7)
- Mobile Developer Phase P6 (final verification, last implementation phase)
  complete: `mobile/test/design_system/no_fork_guard_test.dart` (AC4
  source-scan guard over `lib/features/`, `lib/app/`, `lib/core/` for
  `Color(0x`/`Colors.`/`Platform.is`/`defaultTargetPlatform`, 1/1 passed
  vacuously by design) + full rewrite of `coding-plan/test-results.md`
  (evidence rows for all 7 phases P0-P6, 6-row risk-surface gate summary
  all PASS, AC1-4 traceability table, story-level runtime startup smoke
  confirmation via `Key('home_screen_ready_signal')`, Handoff-To-Reviewer
  section). Full `flutter test` 42/42 passed, `flutter analyze` clean,
  registry `flutter build apk --debug` built successfully (no
  `--no-tree-shake-icons` needed for debug; documented as release fallback).
  `phase-P6-verification.md` §5 and `master-plan.md` P6 row both -> DONE,
  verified on disk by Scrum Master. All 7 phases (P0-P6) now DONE.
  STORY-001 mobile implementation is complete. Two non-blocking notes
  carried forward for Reviewer (already in `test-results.md`): (1) P3
  `CupidPlatform.of(context)` vs `context.cupidPlatform` accessor-naming
  interpretation; (2) P4 `synthetic-package: false` deprecated-no-op
  omission.

## Done This Pass (cont. 8)
- Reviewer (`Iris-QC`) Tier 3 Slice 1 (P0+P1 contract layer) complete:
  `review/slice-p0-p1.md` verified on disk. AC1, ADR-004b, ADR-004c all
  PASS with independently recomputed WCAG contrast ratios (not just cited
  test-results.md), independent test-block counts matching 10/10 and 9/9,
  and font-asset existence spot-check. No FAIL/UNVERIFIED items, no
  blockers. `REVIEW_SLICE_COMPLETE: YES`.

## Done This Pass (cont. 9)
- Tooling gap found and resolved: `validate-reviewer-handoff.sh` (SubagentStop
  guard) blocked `Iris-QC` on Slice 1 completion (`NO_REVIEW_CONTEXT`) because
  `review/slice-p0-p1.md` does not match its accepted `*/review/review-report*.md`
  pattern and has no `Outcome:` line. Resolved from `.claude/hooks/guard-codes.md`
  (not hook source): the wildcard suffix after `review-report` plus the
  PHASE2_MISSING entry's explicit endorsement of "scoped-slice passes plus a
  final-synthesis" confirm the sanctioned naming is `review/review-report-slice-<id>.md`,
  each ending in its own slice-scoped `Outcome:` line (CLEAN/PATCH_REQUIRED/
  BLOCKED per that slice's findings only). Sent `Iris-QC` a continuation to
  rename `slice-p0-p1.md` -> `review-report-slice-p0-p1.md` + append
  `Outcome: CLEAN`, and to use the same convention from the start for Slices 2
  and 3. The canonical `review/review-report.md` (exact name, no suffix, single
  story-level Outcome line) is still produced only by the later fresh
  final-synthesis reviewer and is the only file the DONE gate reads.
  Outcome: a crossed-in-flight `Iris-QC` report (processed before my "don't
  bother renaming" follow-up) confirmed it DID also complete the rename per
  the original instruction: `review/review-report-slice-p0-p1.md` (full
  Slice 1 content + `Outcome: CLEAN`, verified on disk) and
  `review/review-report-slice-p2-p3.md` (full Slice 2 content + `Outcome:
  PATCH_REQUIRED`, verified on disk) both now exist with exactly one
  slice-scoped Outcome line each. Old `review/slice-p0-p1.md` and
  `review/slice-p2-p3.md` remain in place too (inert duplicates — `rm` was
  self-blocked by bash-safety-guard as a destructive delete needing user
  confirmation; not pursued). Final-synthesis should read the
  `review-report-slice-*.md` files (canonical), not the old `slice-*.md`
  duplicates. The one hard remaining requirement is unchanged: final-synthesis
  must still produce the exact canonical `review/review-report.md` with one
  story-level `Outcome:` line before DONE (DONE GATE `NO_REVIEW_ARTIFACTS`/
  `AMBIGUOUS_VERDICT`).

## Done This Pass (cont. 10)
- Reviewer (`Iris-QC`) Tier 3 Slice 2 (P2+P3 icons + adaptive widgets)
  complete: `review/slice-p2-p3.md` verified on disk. AC4 PASS (1 minor
  non-blocking doc gap: undocumented alpha literals in `cupid_tab_bar.dart`).
  ADR-004d split: variant-axis mapping PASS; **single-icon-family principle
  FAIL** — `cupid_header.dart:110,166` and `cupid_add_action.dart:35,48`
  hardcode Flutter's stock `Icons.chevron_left`/`Icons.arrow_back`/`Icons.add`
  instead of `CupidIcon`/`CupidIcons.fontFamily` (Material Symbols Rounded),
  contradicting ADR-004d's explicit "no second icon set" decision in
  `architecture/solution.md`. Not caught by any existing test (AC4 source-scan
  guard excludes `lib/design_system/`; P2/P3 test-results.md never checked
  icon-family consistency). Also clarified (non-blocking) the carried-forward
  P3 note: `CupidPlatform.of(context)` correctly queries
  `CupidPlatformOverride`; `context.cupidPlatform` does not itself query the
  override (fixed at `buildCupidTheme` build time) but is kept in sync today
  by consistent call-site convention — no current break, dartdoc-clarity note
  only. `REVIEW_SLICE_COMPLETE: YES`. Test counts independently reconfirmed
  (5/5, 8/8, matching test-results.md).

## Done This Pass (cont. 11)
- Reviewer (`Iris-QC`) Tier 3 Slice 3 (P4+P5+P6, i18n/ARB + flags/app-wiring +
  final verification) complete: `review/review-report-slice-p4-p6.md`
  verified on disk, `Outcome: CLEAN`. AC2, AC3, AC4 source-scan guard, and
  story-level runtime smoke (`home_screen_ready_signal` boot-chain trace) all
  PASS. Independent full-suite cross-check: 41 recounted phase blocks (P0-P6)
  + `widget_test.dart`'s 1 = 42, matches "42/42" claim exactly. One
  non-blocking note: `widget_test.dart`/`feature_flags_test.dart` duplicate
  the same boot assertion (tidiness only). All 3 canonical slice files now
  confirmed on disk: `review-report-slice-p0-p1.md` (CLEAN),
  `review-report-slice-p2-p3.md` (PATCH_REQUIRED — ADR-004d FAIL),
  `review-report-slice-p4-p6.md` (CLEAN).

## Done This Pass (cont. 12)
- Spawned fresh reviewer instance `Iris-QC-2` (agent_id
  `Iris-QC-2@session-07269157`, NOT a continuation of `Iris-QC`, per Tier 3
  rule) for `Mode: final-synthesis`, reading only the 3 canonical
  `review-report-slice-*.md` files, told to produce
  `review/review-report.md` with one `Outcome:` line, expected
  `PATCH_REQUIRED` given the Slice 2 ADR-004d FAIL.

## Done This Pass (cont. 13)
- `Iris-QC-2` final-synthesis complete: `review/review-report.md` verified on
  disk, exactly one `Outcome: PATCH_REQUIRED` line. AC1-3, ADR-004b/004c,
  ADR-004d axis-mapping, AC4 source-scan guard, runtime smoke all CLEAN; one
  real blocking finding (ADR-004d single-icon-family, same 4 call sites as
  Slice 2). Routed rework via `SendMessage` to `Alex-Mobile-Dev-2` (continuing
  the same mobile-dev instance that implemented P0-P6): swap
  `cupid_header.dart:110,166` and `cupid_add_action.dart:35,48` from stock
  `Icons.*` to `CupidIcon`/`CupidIcons.fontFamily`, preserve existing sizing/
  color/variant behavior, `flutter analyze` clean + full `flutter test`
  passing, addendum to `test-results.md`. Awaiting result.

## Done This Pass (cont. 14)
- `Alex-Mobile-Dev-2` ADR-004d rework verified on disk by Scrum Master
  (all 5 claimed files read directly, not trusted from report alone):
  `mobile/lib/design_system/icons/cupid_icons.dart` — 3 new named constants
  `CupidIcons.chevronLeft` (0xe5cb), `.arrowBack` (0xe5c4), `.add` (0xe145),
  dartdoc cites bundled `MaterialSymbolsRounded-Variable.ttf` cmap via
  `fontTools`, matches ADR-004d single-family rule. `cupid_header.dart:111`
  now `Icon(CupidIcons.chevronLeft, ...)`, `:167` now
  `Icon(CupidIcons.arrowBack)` (confirmed, same tinting/structure preserved).
  `cupid_add_action.dart:36` now `Icon(CupidIcons.add, ...)`, `:49` now
  `Icon(CupidIcons.add)` (confirmed). `adaptive_widgets_test.dart` — 3
  `find.byIcon` assertions now target `CupidIcons.chevronLeft`/`.arrowBack`/
  `.add` (confirmed at lines 66/68/81/82/143); `CupidTabBar`'s
  `Icons.home`/`Icons.favorite` fixture data correctly left untouched (caller-
  supplied test data, not a production call site, per Slice 2's own
  observation). `coding-plan/test-results.md` — new
  "Review-Rework: ADR-004d Single-Icon-Family Fix" section appended (prior
  P0-P6 content untouched), states `flutter analyze` clean and full
  `flutter test` 42/42 passed (no regressions), lists all 4 changed files.
  All 4 required-before-DONE items from `review/review-report.md` are
  resolved.

## Done This Pass (cont. 15)
- `Iris-QC-2` re-review of the rework complete: verified on disk by Scrum
  Master. `review/review-report.md` updated in place — ADR-004d finding
  section now "RESOLVED" (re-verified all 5 files directly, independently
  re-extracted the font cmap), summary table row changed to PASS, "Required
  before DONE" cleared to None, trailing line now exactly `Outcome: CLEAN`.
  The 3 pre-existing non-blocking notes carried unchanged. `story_master.md`
  updated: `Status: DONE`, new `[DONE — Reviewer]` inline bullet added
  (matching the PO/UX/Tech-Lead/Mobile-Dev convention).

## Not Yet Started
- Run `.claude/hooks/git-story-boundary.sh complete --req
  REQ-001_cupid_flutter_mobile_app --story STORY-001`, commit STORY-001's
  working-tree changes, then update `req_master.md` /
  `master_requirements_list.md` STORY-001 tracking (REQ-001 itself stays
  IN_PROGRESS — 15 more stories remain), then select STORY-002 (`api_client`)
  as the next active story in a fresh wave.

## Coding Plan Summary (Tech Lead, coding-plan mode complete)
- Bundle: `coding-plan/master-plan.md`, `coding-agent-guide.md`,
  `phase-P0-tokens.md` .. `phase-P6-verification.md` (P6 = final
  verification phase, all files confirmed on disk).
- Phase order: P0 tokens -> P1 theme assembly -> P2 icons -> P3 adaptive
  widgets -> P4 i18n/ARB (independent, Depends On: None) -> P5 flags + app
  wiring + config guide -> P6 verification (AC4 source-scan guard).
- Runtime registry `mobile-app` entry already EXISTS (system architecture
  memory §8 claiming it's absent is stale — no action needed).
- Flutter SDK not on PATH on this machine; every command uses
  `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.
- story_master.md has no formal per-role checkbox; both PO... UX and Tech
  Lead items are marked `[DONE — <role>]` inline in "Open Items For
  Downstream Roles" (existing file convention, not a template change).

## Do Not Re-read
- Do not re-read `req_master.md`, `requirements/requirements.md`,
  `ux/uiux-spec.md` (except query anchors named in a phase file), or
  `architecture/solution.md` in full for implementation handoffs.
- Do not re-run Product Owner requirement-breakdown, UI/UX Designer
  story-ux, or Tech Lead architecture-solution/coding-plan; all three
  done.
- Do not re-litigate bootstrap (closed).
- Do not re-read all phase files per mobile-dev handoff — pass only the
  single current phase file each time.

## Next Step
Implementation is DONE (all 7 phases + `story_master.md` Implementation
bullet recorded `[DONE — Mobile Developer]`, matching the existing
PO/UX/Tech-Lead inline-bullet convention). STORY-001 touches ~32 distinct
source/test/config files across P0-P6 (well over the Tier 2 full-story-review
12-file cap), so route **Reviewer Tier 3: scoped-slice + fresh final
synthesis** (`references/handoffs/reviewer.md` Tier 3 / `Mode: scoped-slice`
x3, then `Mode: final-synthesis`). Report path for all slices and the final
synthesis: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/review/`
(`review-report-slice-p0-p1.md`, `review-report-slice-p2-p3.md`,
`review-report-slice-p4-p6.md`, then canonical `review-report.md`). Each slice
file ends in its own slice-scoped `Outcome:` line (required so the file
matches the SubagentStop guard's `*/review/review-report*.md` pattern); only
the final `review-report.md` carries the story-level Outcome the DONE gate
reads.
Diff baseline for all slices: `git -C /Users/alantravala/workspace/snapsofts/cupid-apps diff 9b8b91da56f3df06d8001e93ee1c58b8d1a21975` (BaseHead above).

Slice 1 (P0+P1, contract layer — AC1, ADR-004b/004c):
- `mobile/lib/design_system/tokens/cupid_platform_tokens.dart`
- `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
- `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
- `mobile/lib/design_system/tokens/cupid_spacing.dart`
- `mobile/lib/design_system/theme/cupid_platform.dart`
- `mobile/test/design_system/contrast_test.dart`
- `mobile/lib/design_system/theme/cupid_theme.dart`
- `mobile/lib/design_system/theme/cupid_theme_context.dart`
- `mobile/lib/design_system/design_system.dart`
- `mobile/test/design_system/theme_matrix_test.dart`

Slice 2 (P2+P3, icons + adaptive widgets — AC4 widget layer, ADR-004d):
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/lib/design_system/icons/cupid_icon.dart`
- `mobile/test/design_system/icon_variant_test.dart`
- `mobile/lib/design_system/adaptive/cupid_tab_bar.dart`
- `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
- `mobile/lib/design_system/adaptive/cupid_add_action.dart`
- `mobile/test/design_system/adaptive_widgets_test.dart`
- Carry forward non-blocking note: `CupidPlatform.of(context)` vs
  `context.cupidPlatform` accessor-naming interpretation (P3).

Slice 3 (P4+P5+P6, i18n + flags/app-wiring + verification — AC2, AC3, AC4
source-scan guard, runtime smoke):
- `mobile/l10n.yaml`
- `mobile/lib/l10n/arb/app_vi.arb`
- `mobile/lib/l10n/arb/app_en.arb`
- `mobile/test/l10n/arb_parity_test.dart`
- `mobile/lib/core/config/cupid_feature_flags.dart`
- `mobile/lib/app/cupid_app.dart`
- `mobile/lib/main.dart`
- `mobile/test/app/feature_flags_test.dart`
- `mobile/test/widget_test.dart` (collateral 1-line import fix)
- `mobile/test/design_system/no_fork_guard_test.dart`
- `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`
- Carry forward non-blocking note: `synthetic-package: false`
  deprecated-no-op omission from `l10n.yaml` (P4).

All test evidence for all slices: `coding-plan/test-results.md` (full P0-P6
rows, 6-row risk-surface gate summary, AC1-4 traceability table already
written by P6 — reviewer may cite directly instead of re-running commands).

After all 3 slice reports exist, delegate a **fresh** Reviewer (`Mode:
final-synthesis`, not a continuation of any slice agent) with only the 3
slice report paths plus this story's `review-report.md` output path, to
produce the single literal `Outcome:` line. Scrum Master marks
`story_master.md` `Review (Reviewer)` and the story `DONE` only after that
literal `Outcome: CLEAN` or `Outcome: DEFERRED_ONLY`. Then run
`.claude/hooks/git-story-boundary.sh complete --req
REQ-001_cupid_flutter_mobile_app --story STORY-001` before the DONE gate,
and select STORY-002 (`api_client`, next in F0->F1->F2 foundation order) as
the next active story.
