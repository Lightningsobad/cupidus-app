# STORY-017 Review Report — Home Dashboard Design Fidelity

Outcome: DEFERRED_ONLY

Round 3 is the current verdict. Rounds 1-2 are retained below as history.

- Review type: `compact-story-review` (round 3)
- Story: `STORY-017_home_dashboard_design_fidelity`
- Requirement: `REQ-002_screen_flow_and_design_fidelity_audit`
- Lane: mobile
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-017` @ `fa737be`
- Baseline: `git -C <Worktree> diff 36aa258..HEAD`
- Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-017_home_dashboard_design_fidelity/review/scope-gate.md`
- Blocking findings: 0 · Deferred findings: 3

## Scope Gate (round 3)

The round-3 diff is evidence-only — 4 paths, no source or test file:

| Path | Δ |
|------|---|
| `visual-fidelity/visual-fidelity-report.md` | +249 / −19 |
| `visual-fidelity/implemented-home-android-emulator-5560.png` | new |
| `visual-fidelity/implemented-home-ios-emulator-5560.png` | new |
| `visual-fidelity/implemented-home-emulator-5554.png` | deleted (round-2 B1 splash frame) |
| `review/review-report.md`, `story_master.md` | workflow docs |

Because no `mobile/` file changed since `36aa258`, round-1's code verification
(token mapping, the 17 deviation rows, 930/930 suite, static analysis) is not
re-derived. Evidence in scope: `visual-fidelity-report.md` §0, §1-§1.2, §5,
§6.4, §7, §8, `## Story Runtime Startup Smoke`; all four `visual-fidelity/*.png`
(opened and inspected); `mobile/lib/core/navigation/app_shell.dart` lines
128-207 for the entry-point gate.

Touched risk surfaces: mobile design-fidelity evidence, app lifecycle / runtime
startup, mobile navigation discoverability. Query keys: `B1`-`B5`, `DF1`,
`VISUAL_FIDELITY`, `Design-Screen`, `Story Runtime Startup Smoke`, §0 region.

## Round-2 Findings Closure

| # | Verdict | How verified |
|---|---------|--------------|
| B1 — capture was a splash frame | **CLOSED** | I opened both new PNGs. Each shows this story's screen in the built app: overlapping gradient presence discs with `Minh` / `Cùng thành phố`, `247` under the Dream Gradient with `ngày bên nhau` on its baseline, the caption line, the `Còn 53 ngày nữa tới mốc 300` pill, the entry-card column, and the tab bar. No launch frame, no spinner, no error screen. The invalid `5554` capture is deleted. |
| B2 — no verdict token, no `Design-Screen` | **CLOSED** | `VISUAL_FIDELITY: PASS` (line 1) and `Design-Screen: home` (line 2). §1 records harness, device (`emulator-5560`, API 36, 1080x2400, real layout — no display resize), the `vi`/dark state, and why round 2's shutter fired early; §1.1 lists the four artifacts; §1.2 gives a per-region result with three named deltas. Not a bare token. |
| B3 — no iOS implemented capture | **CLOSED** | Both variants exist and visibly differ exactly where AC4 requires: the Material capture paints the pink pill behind the active icon; the iOS capture paints no pill, a smaller label, and a bar that reads as the background rather than an opaque surface. |
| B4 — no runtime startup smoke | **CLOSED** | `## Story Runtime Startup Smoke` records the real entrypoint (`lib/main.dart`, no preview defines) on `emulator-5560`: `LaunchState: COLD`, `Displayed`/`Fully drawn +6s931ms`, live pid + `ResumedActivity`, `logcat -b crash` empty across three checks, no Flutter error screen. PASS. The one non-fatal log (`GeneratedPluginRegistrant` / `flutter_facebook_auth`) is missing emulator-image configuration unrelated to this story's files and did not stop the engine reaching a drawn frame. |
| B5 — AC1 "no visible deviation" vs. write scope | **CLOSED by `scrum-master`** | §0 records the comparison region verbatim (R1-R7 in region; tab *set*, feature cards, Seen banner, header actions out of region). F10 (`--sky` backdrop, theme-owned) and F11 (`app_shell.dart:199` FAB) are confirmed out of scope in this handoff and are not re-raised. |
| DF1 — `main_preview.dart` undeclared | **CLOSED** | §7 now lists it (+60/−21) with the dev-only `fromEnvironment` rationale and its write-scope status. |

## Independent Verification

- **Entry point (12e1) — PASS.** Verified in code, not on trust:
  `mobile/lib/core/navigation/app_shell.dart:140-141` builds
  `body = const HomeScreen()` at tab index 0, mounted under the `CupidTabBar`
  at `:194`. Discoverable tab item, not URL-only. AC5's "no new entry point"
  holds — the destination set is unchanged.
- **Diff scope.** `git diff 36aa258..HEAD` touches no `mobile/` path, so the
  round-3 build/analyze/test claims describe unchanged code; not re-run
  (rule 18).
- **Images.** All four PNGs opened. The two references depict the home
  dashboard of the design source — the same screen this story is about — so
  `Design-Screen: home` is confirmed by the image, not just by the label.

## Rendered Comparison — What I See Against the `PASS`

In-region residual differences, all three named by the implementer in §1.2 and
none of them an uncorrected layout/spacing/token defect:

| Δ | Difference | Disposition |
|---|-----------|-------------|
| Δ1 | Days counter renders visibly smaller than the prototype's `66px` | Not a defect. AC3 names Nunito 900 · 34pt and exact AC text controls (rule 14); the prototype loses the authority conflict. Asserted in widget test. |
| Δ2 | Couple title reads `Minh`, not `Minh & Linh`; partner disc has no initial | F4 — `GET /users/me` exposes no partner profile. Closing it is a backend change outside this story. Degrades honestly rather than inventing a name. |
| Δ3 | Milestone pill has no leading moon glyph | F2 — no verified `CupidIcons` codepoint; the file's sourcing rule forbids inventing one. |

The reference also shows small pink hearts and floating particles around the
counter that the build does not paint. These are the `riseHeart` / `float`
decorations already deferred as F1 in round 1 and accepted in round 2, so they
are not re-raised. Everything else visible in the reference but absent from the
build (5-tab set, Vibe Check, Bún card, Synced Alarm / Zodiac grid, Seen banner,
header actions, `--sky` backdrop) falls in §0's excluded region or the F10/F11
pre-triage; the FAB present in the build but absent from the design is F11.

`VISUAL_FIDELITY: PASS` is region-scoped and the report states that on its own
face. I record `DEFERRED_ONLY` rather than `CLEAN` because the rendered screen
does visibly differ from its reference in three in-region places. Each is
governed and attributed, but none should be certified as "matches exactly".

## Deferred Findings

| # | Finding | Note |
|---|---------|------|
| DF1 | `couple_presence_palette.dart` (new) and `design_system.dart` (additive export) fall outside the mobile-dev runs' declared `write_scope` | Carried from rounds 1-2 unchanged. Declared transparently in §4 with an ADR-004 / `no_fork_guard_test.dart` reason and matching precedent; additive only. `scrum-master` should record that it accepts the exception. |
| DF2 | The `## Story Runtime Startup Smoke` section lives in `visual-fidelity/visual-fidelity-report.md` | This story has no `coding-plan/` directory, so there is no `test-results.md` to host it. The evidence itself is complete and passing; `scrum-master` should confirm the DONE gate resolves the section at that path before closing. |
| DF3 | In-region deltas Δ1-Δ3 above, plus F1, F3, F5-F11 | Each is attributed to an owning story (STORY-001 navigation/shell, per-feature REQ-002 stories, theme/design-system, icon-set, backend partner profile). Worth preserving so the requirement-level mobile visual audit can reconcile them. |

## Traceability

| AC | Verdict | Basis |
|----|---------|-------|
| AC1 — dark + `vi` layout/spacing/token/typography match within §0's region | PASS (region-scoped) | Rendered comparison §1.2 R1-R7 against `design-reference-home-android.png`, confirmed by my own inspection of the images. Residual Δ1-Δ3 deferred. |
| AC2 — deviations corrected in the app, not merely documented | PASS | The 17 corrections are real code changes (verified round 1 in diff); the "re-verified against the design source" half now has a valid rendered frame. |
| AC3 — days counter Nunito 900 / 34pt + Dream Gradient | PASS | Widget test asserts `fontFamily`, `w900`, `34`, `BlendMode.srcIn` over `gradientDream`; the gradient sweep is visible across the `247` glyphs in both captures. |
| AC4 — platform-adaptive tab bar per §3 | PASS | Four unit tests assert the iOS and Material treatments separately, and the two implemented captures render them differently as specified. |
| AC5 — no new entry point | PASS | `app_shell.dart:140-141`, re-verified this round. |

Critical gates: rendered design fidelity (12e2/12e3) — **PASS**, region-scoped
per §0. Mobile runtime startup smoke (12g) — **PASS**. Entry point (12e1) —
**PASS**. Mobile static analysis + full suite (930/930) — **PASS** (round 1,
re-run round 3 by the implementer; code unchanged since). Configuration guide —
not applicable, no setup/configuration surface touched.

Requirement-level `integration-review/mobile-visual-audit.md` (12g2) remains a
separate, still-blocking cross-screen check before REQ-002 closure; this
story-level PASS does not substitute for it.

## State Recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status: `DONE`
- Return to: `scrum-master` for closure and for the DF1/DF2 confirmations

---

# Superseded History — Round 2 (outcome was PATCH_REQUIRED)

- Review type: `compact-story-review` (round 2 — superseded round 1)
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-017` @ `36aa258`
- Baseline: `git diff 8396273 HEAD` (round-1 DF1 resolved — handoff supplied the correct baseline)
- Blocking findings: 5 · Deferred findings: 2

## Scope Gate

Source/test files in scope (7 changed — within the 8-file compact budget):

| File | Δ |
|------|---|
| `mobile/lib/features/home/presentation/home_screen.dart` | +552 |
| `mobile/lib/design_system/adaptive/cupid_tab_bar.dart` | +134 / -68 |
| `mobile/lib/main_preview.dart` | +60 / -21 (**new this round**) |
| `mobile/lib/design_system/tokens/couple_presence_palette.dart` | +43 (new) |
| `mobile/lib/design_system/design_system.dart` | +1 |
| `mobile/test/features/home/home_screen_test.dart` | +179 |
| `mobile/test/design_system/adaptive_widgets_test.dart` | +145 |

Evidence in scope: `visual-fidelity/visual-fidelity-report.md`, the three
`visual-fidelity/*.png` files (opened and inspected), `story_master.md`,
`git ls-files` over the story directory.

Round-2 focus per handoff: whether genuine rendered visual-fidelity evidence now
exists. Round-1's already-verified token-mapping, deviation tables, shared-chrome
regression (930/930), and entry-point verification were not re-derived.

Touched risk surfaces: mobile interaction, mobile navigation/discoverability
(shared chrome), design-system token surface, preview/capture entrypoint.

## Resolved Since Round 1

| Round-1 item | Status |
|--------------|--------|
| B2 — `Complexity`/`Story-Class` recorded as `trivial` | **RESOLVED**. `36aa258` reconciles both to `standard`. |
| B1 sub-gap 1 — no images at all | **PARTIAL**. Three PNGs are now committed; the two design references are correct (see B1). |
| DF1 — wrong `BaseHead` | **RESOLVED**. This round baselined on `8396273`. |

## Blocking Findings

### B1 — The implemented capture is a Flutter splash screen, not the home dashboard

`visual-fidelity/implemented-home-emulator-5554.png` (23 KB) does **not** show
this story's screen. Opened and inspected directly: it is the black Flutter
launch frame — the white circular Flutter logo centred on `#000`, Android status
bar reading `5:02`, and nothing else. No presence header, no days counter, no
milestone pill, no entry cards, no tab bar. Every element this story delivered is
absent from the frame that is supposed to prove it.

Reviewer rule 12e3 names this exact case: a capture showing "a loading spinner or
the wrong screen is `PATCH_REQUIRED` no matter what the report says." The capture
was taken before the preview app painted its first frame (or the app never
reached it). It certifies nothing about AC1, AC2, AC3, or AC4.

The two design references are, by contrast, correct and usable — I opened both:

- `design-reference-home-android.png` — the home dashboard, Material variant:
  Minh & Linh presence row over "Cùng thành phố", `247` in the pink/violet
  gradient display with "ngày bên nhau" trailing, the "Còn **53** ngày nữa tới
  mốc 300" pill, and the pill-indicator 5-tab bar.
- `design-reference-home-ios.png` — the same screen, iOS variant with the
  translucent icon+label tab bar.

So the reference half of the comparison is right; the implemented half is
invalid. Re-capture is required, with the fixture actually rendered.

Supplyable, not blocked: the capture infrastructure now exists and is sound —
`main_preview.dart` adds `--dart-define=PREVIEW_HOME_FIXTURE=true`, which hands
`HomeScreen` an authored `CupidProfile` (day 247, `SAME_CITY`, paired) instead of
`GET /users/me`. That is the correct "fake the state" approach. It just needs to
be on screen when the shutter fires.

Owner: `mobile-dev`.

### B2 — Still no `VISUAL_FIDELITY:` verdict and no `Design-Screen: <id>`

Round-1 B1 sub-gaps 2 and 3 are untouched. `visual-fidelity-report.md` is
byte-identical in these respects to round 1:

- Its top-level token is still `Verdict: **CORRECTED**`. There is no
  `VISUAL_FIDELITY: PASS` or `VISUAL_FIDELITY: FAIL` line anywhere in the file.
  The story review gate and the DONE gate both read that exact line.
- No `Design-Screen: <id>` is recorded. The config sets `"screens_from":
  "canvas"`, so screens are canvas states resolved by id; with no id recorded,
  nobody can re-check which canvas state was compared.
- The report contains no section describing the capture at all — no device, no
  states covered, no deltas. §1 "Method" still describes CSS transcription from
  `Cupid Screens.dc.html`, which is the source-inspection substitute rule 12e3
  refuses.

A comparison that is asserted rather than performed is exactly what this gate
exists to catch. Owner: `mobile-dev`.

### B3 — No iOS implemented capture, though AC4 is a per-platform claim

An iOS design reference was committed and `main_preview.dart` added
`--dart-define=PREVIEW_PLATFORM=ios|material` specifically "so AC4's two tab-bar
variants can both be photographed without a second simulator" — but only one
implemented PNG exists. AC4 asserts two distinct renderings (iOS translucent
icon 26 + label 10; Material pill indicator). One image cannot evidence both, and
the one present is B1's splash. Owner: `mobile-dev`.

### B4 — No `## Story Runtime Startup Smoke` evidence (rule 12g)

`story_master.md` is now `Complexity: standard` / `Implementation Lane: mobile`
and carries no `Runtime-Smoke: WAIVED` line, so the mobile runtime startup smoke
is mandatory: the app launches on the provided emulator and reaches its first
screen without a crash or an error screen.

`git ls-files` over the story directory returns only `story_brief.md`,
`story_master.md`, `review/review-report.md` and the four `visual-fidelity/`
files. There is no `coding-plan/` directory and no `test-results.md`, so the
evidence does not exist in any form. Round-1 action item 2 was not completed.

This is not bookkeeping in this particular story: B1's splash capture is the only
launch artefact on record, and it shows the app *not yet* at its first screen —
precisely the state a runtime smoke is meant to rule out. The smoke and the
re-capture are the same emulator session. Owner: `mobile-dev`.

### B5 — AC1's "no visible deviation" contradicts this story's own write scope

This blocks round 3 from succeeding even with a perfect capture, so it must be
resolved before `mobile-dev` re-runs.

AC1 requires the rendered screen to match the design source "exactly with no
visible deviation", and rule 12e2 makes any visible discrepancy a `FAIL`. But the
design references I opened contain substantial content the story's own Out of
Scope section and deferrals F6/F7 explicitly exclude:

| Visible in reference | Status in this story |
|----------------------|----------------------|
| 5-tab bar (Nhà / Trò chuyện / Pet / Ví chung / Tôi) | App has 3 tabs. F7 — owned by STORY-001's `app_shell.dart`, out of write scope; adding tabs would violate AC5. |
| Vibe Check card, Bún pet card, Synced Alarm / Zodiac Red Flag grid | F6 — each in its own feature widget file, several with their own REQ-002 stories. |
| "Seen 5 phút rồi đấy" banner, share/notification header actions | F3 — target routes do not exist; adding them would violate AC5. |

An honest full-screen capture must therefore read `VISUAL_FIDELITY: FAIL`, which
rule 12e2 makes `PATCH_REQUIRED` — against deltas this story is forbidden to fix.
The alternative failure mode is worse: a `PASS` typed over a screen that visibly
differs from its reference.

`scrum-master` must resolve this before the re-capture, by one of:

1. Defining the fidelity comparison region for STORY-017 (presence header, days
   counter + Dream Gradient, milestone pill, hero caption, entry-card rhythm, and
   tab-bar *styling*), with the out-of-scope regions named as excluded in
   `visual-fidelity-report.md`, so `VISUAL_FIDELITY: PASS` means "matches within
   the declared region"; or
2. Widening the story to cover the missing surfaces; or
3. Recording `VISUAL_FIDELITY: FAIL` with the deltas attributed to the owning
   stories and accepting the story as `DEFERRED_ONLY` only if `scrum-master`
   judges those deltas out of scope — which the current gate wording does not
   permit without an explicit decision.

If `scrum-master` cannot resolve this, the correct outcome for round 3 is
`BLOCKED`, not another `PATCH_REQUIRED` loop. Owner: `scrum-master`.

## Deferred Findings

| # | Finding | Note |
|---|---------|------|
| DF1 | `mobile/lib/main_preview.dart` (+60/−21) is undeclared in `visual-fidelity-report.md` §7 "Changed files" and in the report body | The change itself is sound and well-commented (fixture + platform override, both dev-only `bool.fromEnvironment`/`String.fromEnvironment` behind omitted defines, so live behaviour is unchanged). It should be listed in §7 and its write-scope status confirmed by `scrum-master`. |
| DF2 | `couple_presence_palette.dart` (new) and `design_system.dart` (additive export) fall outside the declared `write_scope` of the mobile-dev runs | Carried unchanged from round 1. Declared transparently in report §4 with a valid ADR-004 / `no_fork_guard_test.dart` reason and matching precedent. Additive only. `scrum-master` should confirm it accepts the exception. |

F1–F9 in the implementer's report remain legitimate out-of-scope deferrals and
are not re-raised, except where B5 makes F6/F7/F3 gate-relevant.

## Traceability

| AC | Verdict | Basis |
|----|---------|-------|
| AC1 — dark + `vi` layout/spacing/token/typography match exactly | UNVERIFIED | Capture shows the splash screen (B1). No valid rendered comparison exists. See also B5. |
| AC2 — deviations corrected in the app, not merely documented | PARTIAL | The 17 corrections are real code changes (verified round 1 in diff). The "re-verified against the design source" half still has no valid rendered evidence (B1). |
| AC3 — days counter Nunito 900 / 34pt + Dream Gradient | PASS (unit) / UNVERIFIED (rendered) | Widget test asserts `fontFamily`, `w900`, `34`, `BlendMode.srcIn` over `gradientDream`. Rendered check invalid (B1). |
| AC4 — platform-adaptive tab bar per §3 | PASS (unit) / UNVERIFIED (rendered) | Four tests assert the iOS and Material treatments separately. No valid capture on either platform (B1, B3). |
| AC5 — no new entry point | PASS | Verified round 1 in `app_shell.dart:141` (`const HomeScreen()` at tab index 0, shell untouched). Not re-derived. |

Critical gates: mobile static analysis and targeted/full test suites — PASS
(round 1, 930/930, independently re-run then; not re-run this round as no source
behaviour changed beyond the preview entrypoint). Rendered design-fidelity gate
(12e2/12e3) — **FAILED** (B1, B2, B3). Mobile runtime startup smoke (12g) —
**MISSING** (B4). Entry point (12e1) — PASS.

Configuration guide: not applicable — no setup/configuration surface touched.

## Action Items

1. **`scrum-master`** — resolve B5 first. `mobile-dev` cannot produce a passing
   verdict until the comparison region or the FAIL-acceptance policy is defined.
2. **`mobile-dev`** — re-capture on the emulator with
   `--dart-define=PREVIEW_HOME_FIXTURE=true`, waiting for the home screen to
   actually paint before the screenshot. The committed image must show the
   presence header, the `247` days counter and the milestone pill. (B1)
3. **`mobile-dev`** — capture the second platform variant with
   `--dart-define=PREVIEW_PLATFORM=ios` (and `material`), so both AC4 tab-bar
   treatments have an implemented image. (B3)
4. **`mobile-dev`** — add to `visual-fidelity-report.md`: a top-level
   `VISUAL_FIDELITY: PASS|FAIL` line, the resolved `Design-Screen: <id>`, and a
   concrete comparison section naming screen, device, states covered, and any
   deltas. (B2)
5. **`mobile-dev`** — record `## Story Runtime Startup Smoke` from the same
   emulator session: app launches and reaches its first screen, no crash, no
   error screen. (B4)
6. **`mobile-dev`** — list `main_preview.dart` in the report's §7 changed files.
   (DF1)

## State Recommendation

- Uncheck `Implementation (Development)` (still `[x]` in `story_master.md`)
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS` (`story_master.md` currently records `PENDING`)
- Return to: `scrum-master` for B5, then `mobile-dev` for B1–B4
