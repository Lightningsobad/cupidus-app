# STORY-017 Review Report — Home Dashboard Design Fidelity

Outcome: PATCH_REQUIRED

- Review type: `compact-story-review` (round 2 — supersedes round 1)
- Story: `STORY-017_home_dashboard_design_fidelity`
- Requirement: `REQ-002_screen_flow_and_design_fidelity_audit`
- Lane: mobile
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
