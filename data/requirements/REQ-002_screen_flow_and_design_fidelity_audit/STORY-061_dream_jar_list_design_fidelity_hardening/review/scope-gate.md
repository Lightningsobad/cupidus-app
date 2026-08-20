# Scope Gate: STORY-061 Dream Jar List (`jarlist`) Design Fidelity Hardening

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `full-story-review`
- Review report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-061_dream_jar_list_design_fidelity_hardening/review/review-report.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps` (branch `main`)
- BaseHead: `970784cad0f33dde24e561d2036e2896995ec593`

## Source/test files in scope (12, from `git diff --name-only <BaseHead> -- mobile/`)

| File | Lane |
|---|---|
| `mobile/lib/features/dream_jar/presentation/dream_jar_list_cubit.dart` | P1 AC1/AC5 |
| `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart` | P1 AC1-AC7 |
| `mobile/lib/l10n/arb/app_vi.arb` | P1 AC6/AC7 |
| `mobile/lib/l10n/arb/app_en.arb` | P1 (flagged deviation) |
| `mobile/lib/core/navigation/app_shell.dart` | P2 AC8 |
| `mobile/lib/preview/preview_app_shell_chrome.dart` | P2 AC8/AC9 |
| `mobile/lib/main_preview.dart` | P2 AC9 fixture |
| `mobile/lib/features/home/presentation/home_screen.dart` | P2 PO Decision 1 |
| `mobile/test/features/dream_jar/presentation/dream_jar_list_cubit_test.dart` | P1 |
| `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart` | P1 |
| `mobile/test/core/navigation/app_shell_test.dart` | P2 |
| `mobile/test/features/home/home_screen_test.dart` | P2 |

## Evidence files in scope

- `coding-plan/test-results.md` (18 KB, full read; P1 + P2 record, `MOBILE_COMPLETE: YES`)
- `visual-fidelity/implemented-jarlist-ready-emulator-5560.png`
- `visual-fidelity/design-reference-jarlist-ready-emulator-5560.png`
- `visual-fidelity/visual-fidelity-report.md` — **ABSENT** (see gates below)
- `data/devops/system/design-fidelity-config.json` (`ui_surface: true`, `design_source` configured and locked)

## Governing artifacts in scope

- `requirements/requirements.md` — AC1-AC10 (small, full read)
- `story_master.md` — `## Gap`, `## Product Owner Scope Decisions (2026-08-20)` (small, full read)
- `architecture/solution.md` (13 KB) — query keys only: `Design-Screen`, `list-screens`, `§3`
- `coding-plan/phase-P2-five-tab-shell.md` — ranged read, AC9 capture task
- `ux/uiux-spec.md` (21 KB) — query keys only, not full-read

## Touched risk surfaces

- mobile interaction (jar list rendering, per-card state)
- mobile navigation/discoverability (5-tab shell replacement, Gallery entry-point relocation, `jarlist` becoming a shell-tab body)
- localization/copy contract (`app_vi.arb`, `app_en.arb`)
- design fidelity (UI-bearing story with a configured design source)

## Critical gates to verify

| Gate | Rule | Status at gate time |
|---|---|---|
| Mobile build gate | 12e0 | PASS (`flutter build apk --debug`, both phases) |
| Mobile static analysis | 12e0 | PASS (zero issues in touched files) |
| Targeted + full widget/unit regression | 12e0 | PASS (1335 passed / 2 skipped / 0 failed) |
| Entry-point reachability section + code verification | 12e1 | **MISSING evidence section** — verify in code |
| Rendered design fidelity report (mobile lane: verify, do not re-capture) | 12e2 / 12e3 | **`visual-fidelity-report.md` ABSENT** |
| Resolved `Design-Screen: <id>` recorded | 12e3 | **NOT RECORDED** in any story artifact |
| Runtime startup smoke | 12g | recorded `NOT_APPLICABLE` in both phases — assess against 12g |

## Query keys for Phase 2

`_GalleryEntryCard`, `home_gallery_entry_card`, `GalleryScreen`, `_ShellDestination`,
`DreamJarListScreen`, `Ví chung`, `DreamJarEntryCard`, `DreamJarListReady`,
`completed`, `dream_jar_summary`, `dream_jar_currently_viewing`, `onBack`,
`enableEnLocale`.

## Phase 2 decision

Proceed to focused verification. The two missing design-fidelity/entry-point
evidence artifacts are already gate failures under rules 12e1/12e2/12e3; Phase 2
confirms the implementation itself so the rework pass is a single, complete pass
rather than a second round trip.

## Round 2 scope update (2026-08-20)

Round 2 is an artifact-only re-verification of Round 1 findings B1-B4.
`git diff --stat <BaseHead> -- mobile/` is byte-identical to Round 1 (12 files,
1106 insertions / 280 deletions), so no code verdict is re-opened and no source
file is re-read.

Files in scope for Round 2:

| File | Closes |
|---|---|
| `visual-fidelity/visual-fidelity-report.md` (new) | B1 |
| `coding-plan/test-results.md` `## Entry Point Reachability` (:459-491) | B2 |
| `coding-plan/test-results.md` `## Story Runtime Startup Smoke` (:407-457) | B3 |
| `coding-plan/test-results.md` `### AC10 disposition` (:287-302) | B4a |
| `story_master.md` Amendment (:109-120) | B4a |
| `architecture/solution.md` `### Decision B4b` (:126-165) | B4b |
| `data/devops/system/design-fidelity-config.json` (re-checked, Round 1 read) | B6 |

Deferred findings D1-D5 stay as Round 1 disposed them and are not re-litigated.

## Round 3 scope update (2026-08-20)

Round 3 is the two-line verification Round 2 scoped: the `VISUAL_FIDELITY:`
value and the design-source paragraph. `git diff --stat <BaseHead> -- mobile/`
is again byte-identical (12 files, 1106 insertions / 280 deletions).

| File | Range read | Closes |
|---|---|---|
| `visual-fidelity/visual-fidelity-report.md` | `:1-75` only | B5, B6 |
| `story_master.md` | `:138-151` only | B5 token propagation (Scrum Master-owned) |

Nothing else re-opened. `## Recorded deltas`, `## Per-AC verdict`,
`## Evidence pair`, and `## States compared` were not re-read.
