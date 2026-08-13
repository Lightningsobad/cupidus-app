# Review Report: STORY-019 — Typing Ghost Consent/Settings Design Fidelity

Outcome: PATCH_REQUIRED

Review type: `compact-story-review` (first review)
Story: STORY-019 (REQ-002, Scope B) — lane `mobile`, UI-facing YES
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-019`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
Implementation commit: `b8129de3673b5248ebc12f096454000c57deb8ac`
Recommended story status: `IN_PROGRESS` — return to `mobile-dev`

## Scope Gate

Source/test files in scope (4 changed vs BaseHead, within the 8-file compact budget):

- `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart` (+460/-149)
- `mobile/test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart` (new, +378)
- `.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `.../STORY-019_typing_ghost_settings_design_fidelity/story_master.md` (+2/-1)

Evidence files in scope:

- `.../STORY-019_typing_ghost_settings_design_fidelity/story_master.md`
- `.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/visual-fidelity-report.md`
- `data/runtime/parallel-runs/RUN-...-STORY-019-mobile-dev.json`
- `data/devops/system/design-fidelity-config.json` (exemption check for rules 12e2/12e3)

Query keys: AC1-AC5; `IntrinsicHeight`; `GhostSettingsScreen` call sites;
`design_source` / `ui_surface`; `VISUAL_FIDELITY`; `Story Runtime Startup Smoke`.

Touched risk surfaces: mobile interaction, mobile navigation/discoverability,
app lifecycle (layout crash path).

## Verdict Rationale

The code change itself is genuine, well-scoped and well-tested — the ten
recorded deviations are really implemented, the crash fix is real, and the
entry point verifies in code. It fails the gate on **evidence**, not on
implementation: the one artifact that proves "matches the design with no
visible deviation" was never produced, and the two exemptions that would
excuse it do not apply to this project.

## Critical Gates

| Gate | Required | Result |
| --- | --- | --- |
| Static analysis (`flutter analyze`, 2 files) | yes | PASS — `No issues found!` |
| Targeted widget tests (6 cases) | yes | PASS — `+6: All tests passed!` |
| Chat suite regression (`flutter test test/features/chat`) | yes | PASS — `+54: All tests passed!` |
| Entry point reachability (12e1) | yes | PASS — verified in code, see below |
| Rendered design-fidelity evidence (12e2/12e3) | yes | **FAIL — F1, F2** |
| Story runtime startup smoke (12g) | yes | **FAIL — F3** |
| Configuration guide | no | not applicable — no setup/config surface touched |

## Blocking Findings

### F1 — Mandatory rendered design-fidelity evidence is absent, and no exemption applies

`data/devops/system/design-fidelity-config.json` records `"ui_surface": true`
and a `design_source` that is `"locked": true`
(`cupid-app-design-system`, `type: claude-design`, detected by
ui-ux-designer 2026-08-11). Both audited scope-outs in rule 12e3 are therefore
closed for this story, and `story_master.md:10` states the same lock.

What is missing under
`.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/`:

- no `implemented-ghostset-<device>.png`
- no `design-reference-ghostset-<device>.png`
- no `VISUAL_FIDELITY:` verdict line anywhere in `visual-fidelity-report.md`
  (not `PASS`, not `FAIL` — the token is simply absent)

The report is candid about this and substitutes a declaration-level comparison
plus widget-tree assertions. That substitution is the specific thing rule 12e3
refuses: "verified by source/code inspection" is named there as an excuse the
gate does not accept, and there is no prose waiver path when a design source is
configured. AC1's "no visible deviation" is a pixel claim; a widget test can
prove a `TextStyle` resolves to 25px, but it cannot see the screen. The honesty
of the disclosure is why this is `PATCH_REQUIRED` and not a trust problem —
but the gap is not waivable.

**This is `PATCH_REQUIRED`, not `BLOCKED`** — I verified the capture path is
available right now, so no environment/dependency actually prevents the gate:

- `capture-mobile-screen.sh` and `render-design-canvas.js` are present at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/`.
  `.ai-team-bundle/` is gitignored, which is why it is not inside the story
  worktree — that is a per-worktree provisioning gap, not the install defect
  `VISUAL_RUNTIME_MISSING`. Invoke via the control-checkout absolute path or
  provision with `.ai-team-bundle/runtime/ensure-runtime.sh`.
- `adb devices` reports `emulator-5554  device` — attached and usable.
- A preview entrypoint for exactly this screen already exists:
  `mobile/lib/main_preview.dart:325` `_buildGhostset`. The hard part of a
  mobile capture is already built.

Emulator contention across the parallel wave is a scheduling constraint, not an
impossibility; serialize the capture.

### F2 — Which design was compared is unverified, and no `Design-Screen: <id>` is recorded

The config declares `entry: "Cupid App.dc.html"` with `screens_from: "canvas"`,
and instructs rendering per screen via `render-design-canvas.js --screen=<id>`.
The implementation compared instead against
`cupid-app-design-system/project/Cupid Screens.dc.html` lines 391-431, a
different canvas file selected by hand-reading HTML. The renderer's own screen
resolution was never exercised, and the story records no resolved
`Design-Screen: <id>`.

This is the failure mode rule 12e2 calls out by name: a story compared against
the wrong screen yields a confident PASS that certifies nothing and is
indistinguishable from a correct one in prose. I cannot close this by reading,
because the only thing that settles it is the rendered reference image. The
re-render must record the resolved screen id and produce the reference from the
configured entry.

### F3 — No `## Story Runtime Startup Smoke` evidence (rule 12g)

Lane is `mobile`; `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>`.
No startup-smoke section exists in any story artifact.

This gate is unusually load-bearing here rather than ceremonial: this very story
fixed a layout exception that crashed this screen at runtime (see V1). A widget
test proves the tree lays out in a test harness; the smoke proves the built app
launches on `emulator-5554` and reaches its first screen without a crash or an
error screen. Both the reviewer gate and the DONE gate enforce it independently.
The emulator is attached, so this is supplyable now.

Note: `story_master.md` records `Complexity: trivial` / `Story-Class: trivial`
while the handoff and run state both declare `standard`. Under either reading
this story is not a safe trivial single-lane change — it is a 460-line screen
rewrite that fixed a crash — so 12g applies. Scrum Master should reconcile the
classification; it does not change the verdict.

## Verified (non-blocking, recorded because the handoff asked)

### V1 — The `IntrinsicHeight` crash fix is real, and the test does exercise the path

Confirmed in the diff: the consent-tile `Row` (`CrossAxisAlignment.stretch`)
now sits inside `IntrinsicHeight` in `_ToggleCard`. Inside the screen's
unbounded-height `ListView` column, `stretch` propagated `h=Infinity` and threw
`BoxConstraints forces an infinite height`. The new test mounts the real
`GhostSettingsScreen` (test file line 126) at 412x1600 and lays out the actual
`ListView`, so the crash path is genuinely executed — not asserted around.
`IntrinsicHeight` is also the correct model for the design source's equal-height
2-column flex row, so this is a fix rather than a suppression. Real defect,
correctly found and correctly fixed; static analysis would not have caught it.

### V2 — Entry point independently verified in code (12e1)

Not taken on trust: `mobile/lib/core/navigation/app_shell.dart:94` mounts
`GhostSettingsScreen`, and `mobile/test/core/navigation/app_shell_test.dart:185`
asserts "the ghostset action opens GhostSettingsScreen from Chat". Reachable
through a real in-app action, not URL-only. AC5 (no new entry point) holds —
the constructor and `onBack` contract are unchanged.

### V3 — The four carried-forward items are genuinely write-scope blocked

Confirmed, not author preference. All four require editing
`mobile/lib/features/chat/presentation/chat_strings.dart`, which does not appear
in the run's `write_scope`
(`ghost_settings_screen.dart`, `ghost_cubit.dart`, `mobile/test/features/chat`,
and two story-artifact paths), and the file is shared with STORY-018. The
implementer also declined a `.toLowerCase()` half-fix that would have corrected
`vi` while breaking `en` — the right call.

## Deferred Findings

| ID | Finding | Disposition |
| --- | --- | --- |
| DEF-1 | `ChatStrings.ghostSetLegendDeleted` / `ghostSetLegendLive` casing/wording vs design source lines 421-422 | Route to a follow-up story owning `chat_strings.dart`; both entries are referenced only from `ghost_settings_screen.dart` |
| DEF-2 | `ghostSetHeroBody` / `ghostSetMutualConsentFooter` wording differs from design source lines 397/412 (semantically equivalent) | Same follow-up |
| DEF-3 | Hero headline forced `<br>` at design source line 396 not pinned in app | Same follow-up; breaks at the same point at 412pt today |
| DEF-4 | `ChatStrings.privacyChip` lacks the `Level 1 · ` prefix; STORY-018 owns the shared string (already DONE/merged) | Needs a new follow-up story — STORY-018 has closed |
| DEF-5 | Partner consent tile renders `Chưa rõ` in `--tx2` instead of the design source's mint `consentBColor` | Accept. Backend exposes no partner-consent flag (ADR-013e); tinting would assert a state the app cannot know. Pre-existing and correctly reasoned |
| DEF-6 | STORY-032 app-shell `skyGradient` background gap | Not observed in this diff — this screen's changes are inside the scroll region and do not touch the shell background |

## Action Items

1. `[mobile-dev]` Render the design reference for this screen from the
   configured entry using the control-checkout renderer
   (`/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/render-design-canvas.js --screen=<id>`),
   capture the implemented screen on `emulator-5554` via
   `capture-mobile-screen.sh` using the existing `main_preview.dart`
   `_buildGhostset` entrypoint, and write both PNGs to
   `.../STORY-019_typing_ghost_settings_design_fidelity/visual-fidelity/`
   as `design-reference-ghostset-<device>.png` and
   `implemented-ghostset-<device>.png`. (F1)
2. `[mobile-dev]` Record the resolved `Design-Screen: <id>` in the story and
   confirm the rendered reference depicts the Typing Ghost consent/settings
   screen — not a neighbouring canvas screen. (F2)
3. `[mobile-dev]` Add a top-level `VISUAL_FIDELITY: PASS|FAIL` line to
   `visual-fidelity-report.md`, backed by the image comparison and naming the
   AC3 states actually captured (off / pending / on) and the AC4 lock chip.
   Any visible delta is `FAIL` with the concrete delta recorded. (F1)
4. `[mobile-dev]` Add a `## Story Runtime Startup Smoke` section proving the
   built app launches on the emulator and reaches its first screen without a
   crash or error screen — or have Scrum Master record
   `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`. (F3)
5. `[scrum-master]` Reconcile `Complexity`/`Story-Class` between
   `story_master.md` (`trivial`) and the handoff/run state (`standard`).
6. `[scrum-master]` Open a follow-up story for the four `chat_strings.dart`
   carry-forwards (DEF-1 to DEF-4); STORY-018, the previous owner, is closed.

## Traceability

| AC | Reviewer status | Basis |
| --- | --- | --- |
| AC1 — dark + `vi` layout/spacing/tokens/typography match with no visible deviation | UNVERIFIED | Declaration-level comparison only; the pixel claim has no rendered evidence (F1, F2) |
| AC2 — deviations corrected in the app, not merely documented | MET | D1-D10 are present in the +460/-149 diff; re-verification against the design source still pending (F1) |
| AC3 — three toggle states match | UNVERIFIED | `_ConsentSwitch` (54x32 track, 26px knob, `gradientHot`/`colorLine`, alignment-based `switchJustify`) is implemented and asserted by tests 1-3, but the state styling is not visually compared (F1) |
| AC4 — Level-1 lock affordance visible | UNVERIFIED | `_PrivacyChip` is implemented and asserted by test 4; placement/styling not visually compared (F1) |
| AC5 — no new entry point | MET | V2 |

- Requirements: `story_master.md` (trivial story — UX and architecture recorded
  `SKIPPED:trivial`, so `coding-plan/` is not required per rule 9)
- UX: `data/ux/system/ui_ux_system_memory.md` §5/§8 cited for the mandatory
  Level-1 lock affordance; implemented as `_PrivacyChip`, rendered
  unconditionally in all three consent states
- OQ discipline: OQ5 (light theme / `en` locale) correctly triaged as
  not-blocking; fixes are expressed in shared `ThemeExtension` tokens, so no
  in-scope AC was withheld and no blocked scope was implemented
- Git boundary: reviewed via `git -C <Worktree> diff bf80848` only

## Workflow Recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status `IN_PROGRESS`; return to `mobile-dev` with action items 1-4
- Do not merge the story branch to
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` until the
  rendered evidence and startup smoke are present
