# STORY-017 Review Report — Home Dashboard Design Fidelity

Outcome: PATCH_REQUIRED

- Review type: `compact-story-review` (first review)
- Story: `STORY-017_home_dashboard_design_fidelity`
- Requirement: `REQ-002_screen_flow_and_design_fidelity_audit`
- Lane: mobile
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-017` @ `cf73601`
- Blocking findings: 2 · Deferred findings: 2

## Scope Gate

Diff baseline correction: the handoff supplied `BaseHead 93165e4`, but that sha
is itself a STORY-017 implementation commit
(`feat(REQ-002/STORY-017): home dashboard design fidelity fixes + visual-fidelity report`).
Diffing from it exposes only 3 of the story's 8 changed files. This review used
`git diff 8396273 HEAD` — the last pre-story commit — as the true story baseline.

Source/test files in scope (8, within compact budget):

| File | Δ |
|------|---|
| `mobile/lib/features/home/presentation/home_screen.dart` | +552 |
| `mobile/lib/design_system/adaptive/cupid_tab_bar.dart` | +134 / -68 |
| `mobile/lib/design_system/tokens/couple_presence_palette.dart` | +43 (new) |
| `mobile/lib/design_system/design_system.dart` | +1 |
| `mobile/test/features/home/home_screen_test.dart` | +179 |
| `mobile/test/design_system/adaptive_widgets_test.dart` | +145 |
| `mobile/lib/core/navigation/app_shell.dart` | unchanged — read to verify F7/F8/F9 + entry point |
| `data/devops/system/design-fidelity-config.json` | unchanged — read to test the 12e2 exemption |

Evidence in scope: `visual-fidelity/visual-fidelity-report.md`,
`RUN-...-STORY-017-mobile-dev.json`, `story_master.md`.

Touched risk surfaces: mobile interaction, mobile navigation/discoverability
(shared chrome), design-system token surface.

## Blocking Findings

### B1 — No rendered visual-fidelity evidence exists (reviewer rule 12e2/12e3)

`visual-fidelity/` contains **only** `visual-fidelity-report.md`. There is no
`implemented-home-<device>.png` and no `design-reference-home-<device>.png` —
verified tracked, untracked and ignored (`git ls-files`,
`git status --porcelain --ignored` both empty of images).

Neither audited scope-out applies. `data/devops/system/design-fidelity-config.json`
records `ui_surface: true` and a locked `design_source`
(`claude-design` / `cupid-app-design-system`, `locked: true`), so the rendered
check is mandatory, not waivable.

Three sub-gaps:

1. **No images.** The comparison the mobile lane owns was never captured.
2. **No `VISUAL_FIDELITY:` verdict.** The report's top-level token is
   `Verdict: **CORRECTED**`, which is not the required
   `VISUAL_FIDELITY: PASS`/`FAIL` line the story gate and the DONE gate read.
3. **No `Design-Screen: <id>`.** The config records
   `"screens_from": "canvas"` — screens are canvas states resolved by id, so an
   unrecorded id means nobody can re-check which screen was compared.

The report's §1 "Method" states measurements were *transcribed from the `isHome`
CSS*. That is a source-code-inspection substitute for a rendered comparison,
which rule 12e3 explicitly refuses. This is not a documentation nit: AC1, AC2,
AC3 and AC4 are all claims about how the screen **renders**, so the screenshot is
the primary proof of the changed behaviour. Per rule 12c it cannot be recorded
as deferred.

Supplyable, not blocked: REQ-001 already committed
`STORY-018_design_fidelity_capture/visual-fidelity/design-reference-home-android.png`,
and STORY-019/020/021 show the `emulator-5554` capture path working. Hence
`PATCH_REQUIRED`, not `BLOCKED`.

Owner: `mobile-dev`.

### B2 — Story classification conflict, and the mobile runtime smoke it gates

`story_master.md` records `Complexity: trivial` / `Story-Class: trivial`, while
the handoff and both run files declare `Story-Class: standard`. The delivered
scope — a 552-line rewrite of `home_screen.dart`, a new design-system token
file, plus changes to shared app-wide tab chrome — is not consistent with
`trivial`.

This is not bookkeeping: reviewer rule 12g makes registry-backed runtime startup
smoke mandatory for every **non-trivial** `mobile` story, and no
`## Story Runtime Startup Smoke` evidence exists anywhere in this story. Under
the `trivial` label the gate silently does not fire; under `standard` it does.
The emulator must be booted for B1's capture regardless, so the smoke (app
launches and reaches its first screen without a crash or error screen) is
near-free once B1 is addressed.

Owner: `scrum-master` to reconcile the class in `story_master.md`; `mobile-dev`
to record the smoke if `standard` stands.

## Verified — Handoff-Flagged Concerns

**Shared-chrome regression (`cupid_tab_bar.dart`): PASS — independently re-run.**
Evidence exists in both the report §6.2 and the mobile-dev run file
(`flutter test --reporter=failures-only` → `+930`). I did not take it on trust
and re-ran the full suite in the worktree:

```
flutter test --reporter=failures-only
→ +930: All tests passed!
```

930 passed, 0 failed, including `test/core/navigation/app_shell_test.dart`. The
88 KB of output is Dio request/response logging from the timeline tests, not
failure blocks. No shared-chrome regression. `CupidTabBar` / `CupidTabBarItem`
public API (`items`, `currentIndex`, `onTap`, `icon`, `label`) is unchanged in
the diff, so no consumer required an edit.

**F7/F8/F9 deferral attribution: ACCURATE — verified against `app_shell.dart`,
not accepted on assertion.**

| Item | Claim | Verified |
|------|-------|----------|
| F7 | Tab *set* lives in `app_shell.dart` | Confirmed: built at `app_shell.dart:119-133` (Home, conditional Chat, Gallery = 3 tabs vs the design's 5) |
| F8 | `CupidTabBarItem` carries one `IconData`, so a filled/outline pair changes every call site | Confirmed: single `icon` field; call sites at `app_shell.dart:120-132` |
| F9 | Blur needs `Scaffold.extendBody: true`, which lives in `app_shell.dart` | Confirmed: `Scaffold` at `app_shell.dart:192` sets no `extendBody` |

`app_shell.dart` and `pair_gate_shell.dart` are absent from the full story diff
(8 files, neither shell among them) — the "not touched" claim holds.

**Entry point (rule 12e1): PASS.** Independently verified in code, not from a
`Reachable: YES` line: `app_shell.dart:141` mounts `const HomeScreen()` at tab
index 0, which is unconditionally present in the tab list. AC5 holds — the
destination set is byte-for-byte unchanged because the shell was never edited.

**Code correctness spot-checks: PASS.** The transcribed constants are
mathematically right where they could have quietly been wrong — CSS
`blur(26px)` → Gaussian sigma 13; `saturate(1.3)` colour matrix matches the
filter-spec luminance weights (1.2361 / -0.2145 / -0.0216 …);
`rgba(...,.22)` → alpha 56; `.01em` at 10 pt → `letterSpacing` 0.1. The
`SafeArea(top: false)` nested inside the container padding correctly reproduces
`calc(var(--safe-bot) + Npx)`.

## Deferred Findings

| # | Finding | Note |
|---|---------|------|
| DF1 | Handoff `BaseHead` pointed at a STORY-017 implementation commit, hiding 5 of 8 changed files from the review diff | Process issue for `scrum-master`. Any re-review of this story must baseline on `8396273`, not `93165e4`. |
| DF2 | `couple_presence_palette.dart` (new) and `design_system.dart` (additive export) fall outside the declared `write_scope` of both mobile-dev runs | Declared transparently in report §4 with a valid reason (ADR-004 / `no_fork_guard_test.dart` forbids `Color(0x` under `lib/features/**`) and matching precedent (`pet_hero_gradient.dart`, `bun_sprite_palette.dart`). Additive only, no existing symbol changed, guard test passes. `scrum-master` should confirm it accepts the exception. |

F1-F6 in the implementer's report are legitimate out-of-scope deferrals and are
not re-raised here.

## Traceability

| AC | Verdict | Basis |
|----|---------|-------|
| AC1 — dark + `vi` layout/spacing/token/typography match exactly | UNVERIFIED | Code changes present and coherent, but the match is asserted from CSS transcription. No rendered comparison exists (B1). |
| AC2 — deviations corrected in the app, not merely documented | PARTIAL | The 17 corrections are real code changes (verified in diff). The re-verification half of the AC ("re-verified against the design source") has no rendered evidence (B1). |
| AC3 — days counter Nunito 900 / 34pt + Dream Gradient | PASS (unit) / UNVERIFIED (rendered) | Widget test asserts `fontFamily`, `w900`, `34`, `BlendMode.srcIn` over `gradientDream`. Rendered check missing (B1). |
| AC4 — platform-adaptive tab bar per §3 | PASS (unit) / UNVERIFIED (rendered) | Four new tests assert the iOS translucent/26/10 treatment and the Material pill separately. Rendered check missing (B1). |
| AC5 — no new entry point | PASS | Verified in `app_shell.dart`; shell untouched. |

Static analysis: `flutter analyze` clean on all changed files (0 errors,
0 warnings, 0 infos), per report §6.1/§6.2. Test evidence: 930/930 passing,
re-run independently by this review.

Configuration guide: not applicable — no setup/configuration surface touched.

## Action Items

1. **`mobile-dev`** — capture `implemented-home-<device>.png` on the provided
   emulator and the matching `design-reference-home-<device>.png` from the
   locked canvas, compare them, and record the resolved `Design-Screen: <id>`
   plus a top-level `VISUAL_FIDELITY: PASS|FAIL` (with concrete per-state deltas
   if FAIL) in `visual-fidelity/visual-fidelity-report.md`. Cover the states the
   ACs name: the presence header, the days counter, and both tab-bar platform
   variants. (B1)
2. **`mobile-dev`** — while the emulator is up, record
   `## Story Runtime Startup Smoke`: the app launches and reaches its first
   screen with no crash and no error screen. (B2)
3. **`scrum-master`** — reconcile `Complexity` / `Story-Class` in
   `story_master.md` against the delivered scope and the run files. (B2)
4. **`scrum-master`** — re-review must diff from `8396273`. (DF1)

## State Recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Return to: `mobile-dev`
