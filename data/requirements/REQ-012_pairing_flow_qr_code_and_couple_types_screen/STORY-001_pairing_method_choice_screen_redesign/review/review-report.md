# Story Review Report — REQ-012 / STORY-001 Pairing-Method Choice Screen Redesign

- Reviewer: `reviewer` (Iris-QC)
- Mode: `compact-story-review`
- Pass: 2 (re-review after mobile-dev rework)
- Date: 2026-08-26
- Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign`
- Pass-2 BaseHead / HEAD: `0b5efe157394426b439c4f80e04973c50bbeb898`
- Rework diff reviewed: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b..0b5efe157394426b439c4f80e04973c50bbeb898`
- Scope gate: `review/scope-gate.md`

Outcome: PATCH_REQUIRED

Single remaining open item: **F4 (story runtime startup smoke)**. F1, F2 and F3 are
cleared, and the recorded `VISUAL_FIDELITY: FAIL` is accepted as **deferred, not
blocking** — see "AC4 verdict" below. This is a one-item gap, not a re-run of pass 1.

## Pass-1 finding disposition

| # | Pass-1 finding | Pass-2 status |
|---|---|---|
| F1 | Missing per-story rendered visual-fidelity evidence | **CLEARED as a deliverable.** Report, both PNGs, dark+vi, 14-row per-element table, concrete deltas. Verified by reading the images, not by counting files. |
| F2 | `Design-Screen: TBD` | **CLEARED.** `story_master.md` now records `Design-Screen: pairstart`, with the enumerate → shortlist → confirm procedure documented. |
| F3 | Missing `## Entry Point Reachability` | **CLEARED.** `coding-plan/test-results.md:145-157` — `Reachable: YES`, path `PairGateShell → _AppShellView → PairGateUnpaired → PairingChoiceScreen`, matching the code I verified in pass 1 (`pair_gate_shell.dart:136-143`, unchanged in this diff). |
| F4 | Missing `## Story Runtime Startup Smoke` | **STILL OPEN.** Deliberately excluded from the rework handoff. Remains blocking — see below. |
| D1 | "later, look around first" escape link | Still deferred, `product-owner`. Now also the sole substantive cause of the `FAIL` token. |
| D2 | BUG-20260825-002 re-triage | Still open, `scrum-master`. |

## Visual-fidelity evidence — independently verified

I opened both images rather than trusting the verdict token.

- `design-reference-pairstart-android.png` genuinely depicts **this story's screen**:
  hero badge, `Ghép đôi kiểu nào?`, subtitle, and exactly the three option rows with
  the AC1 copy, plus the privacy note. Not a placeholder, not a different canvas
  screen, not the `cupid-web` surface.
- `implemented-pairstart-emulator-5554.png` is a **settled frame of the built app** —
  full three-row screen, Vietnamese copy, dark theme. Not a splash frame, not a
  spinner, not a red error screen.
- The three recorded deltas are exactly what I see, and nothing the report calls a
  MATCH looks like a mismatch to me. The badge, title, subtitle wrap point (after
  `nhập`), all three row treatments (pink border + glow + hot-gradient tile + pink
  chevron on row 1; purple tile row 2; mint tile row 3), row order, and the privacy
  note all read as the same screen at the same proportions.
- The report's scale note is legitimate and not a hedge: the canvas render draws a
  device bezel inside its 406x900 frame while the device capture is the raw screen,
  so the measurements are correctly normalised to logical px before comparison.

The implementer recorded `FAIL` where a `PASS` would have been easier and largely
unverifiable. That is the correct behaviour for this gate.

## AC4 verdict — why the `FAIL` token is deferred rather than patched

AC4 reads: "*layout, spacing, color/token usage, and typography match*". Every one of
those four named dimensions matches, per the per-element table and my own reading of
the two images. The `FAIL` is driven by a missing **element**, not by a layout,
spacing, colour or typography deviation.

That element — the `Để sau, xem trước app đã` escape link — is:

- **not a regression.** Verified in pass 1 against `BaseHead`: the link never existed
  in the shipped screen. Nothing was removed.
- **architecturally adjudicated.** Its `goHome` target has no reachable destination
  for an unpaired user (`pair_gate_shell.dart:144` renders `AppShell` only for
  `PairGatePaired()`). Shipping it means shipping a dead link, or adding a pair-gate
  bypass — a new capability explicitly outside this story.
- **not fixable in the implementation lane.** Returning this to `mobile-dev` as
  `PATCH_REQUIRED` would route work to a lane that cannot perform it. The open item
  is a Product Owner scope decision (drop §2.6 from this story's design scope, or
  open the pair-gate-bypass story), already recorded as Deferred Finding D1.

I also independently accept the two non-defect deltas:

- **D-2 (canvas chrome header)** — the back arrow and `Ghép đôi` title bar are
  prototype canvas navigation, the same class as the screen-index FAB that
  `hide_selectors` already strips. The story's `NO_CHROME`/`NO_TABS` contract is
  pinned by `chain_chrome_guard_test.dart` (`pairingChoice renders no header and no
  tab bar`, PASS). Its absence is the specified behaviour, and it accounts for the
  uniform ~80px vertical offset.
- **D-3 (row-3 copy wraps to 1 line instead of 2)** — a consequence of correct
  geometry, not a deviation from it. Font size and text-column origin match; the
  canvas' own flex row reserves more trailing space and breaks earlier.

So AC4 is **PASS on its stated criteria, with the element-inventory question deferred
to `product-owner`**. Were F4 not outstanding, this pass would read `DEFERRED_ONLY`.

## F4 — why this still blocks, despite the handoff's instruction

The handoff asked me not to re-flag F4. I am flagging it, and this is the reason
rather than a procedural reflex:

Registry-backed runtime startup smoke is a mandatory story-level gate for a
non-trivial `mobile`/`shared` story unless `story_master.md` records
`Runtime-Smoke: WAIVED — <reason>`. It does not; the rework changed the
`Design-Screen` line and the Artifacts checkboxes only. `validate-done-gate.sh`
enforces this **independently of my verdict**, so a `DEFERRED_ONLY` here would not
let the story close — Scrum Master would run `git-story-boundary.sh complete` and be
rejected. Naming it now is cheaper than discovering it at the DONE gate.

The visual capture does **not** substitute for it, and this is the substantive point
rather than a technicality. The capture launched
`flutter run -t lib/main_preview.dart --dart-define=PREVIEW=pairstart` — the **preview
entrypoint**, not the app's real `main()`. The smoke gate exists precisely because an
app whose `main()` fails to initialise can red-screen on every real launch while a
preview harness renders every screen perfectly. A green preview frame is evidence
about the widget tree, not about app startup.

Note also that the rework demonstrably had a working emulator (`emulator-5554`, driven
under a `--lease-exec` device lease), so the gate is **satisfiable** — it was a
routing constraint, not an environment one. `guard-broad-handoff.sh` blocks emulator
and runtime work through `mobile-dev` in ordinary continue; it does not block that
work through `devops`.

Two supported ways to close F4, neither requiring another `mobile-dev` cycle:

1. Route the smoke to `devops`: launch the real app entrypoint on the available
   emulator, confirm it reaches its first screen without a crash or error screen, and
   record `## Story Runtime Startup Smoke` in `coding-plan/test-results.md`.
2. If Scrum Master judges the smoke genuinely unwarranted for this story, record
   `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`. That is the audited
   escape hatch the DONE gate honours; prose in a review report is not.

## Rework verification

| Check | Result |
|---|---|
| `flutter test test/features/pairing/ test/design_system/ test/core/navigation/chain_chrome_guard_test.dart` | PASS — `+236` (133 + 86 + 17). Consistent with the `+219` I ran myself in pass 1 plus the 17 chrome-guard cases. |
| `flutter analyze lib test` | PASS on severity — 75 issues, all `info`, 0 error / 0 warning, unchanged count |
| Production-code blast radius | **Zero.** The only non-artifact edit is `mobile/lib/main_preview.dart` (+7/-3): a `previewScreens` map key renamed `'pairingchoice'` → `'pairstart'` plus its `seedNote`. Separate dev-only entrypoint; `lib/main.dart` and all screen/token/test files untouched in this rework. |

The harness key correction is a genuine fix, not incidental churn: the old
`'pairingchoice'` key named an id the canvas does not expose, so captures under it
could never filename-match a renderable reference — which is why this story's visual
gate had no reference to compare against in the first place.

## Traceability

- ACs: `story_master.md` AC1-AC4 (AC1-AC3 verified in pass 1 against code and a
  reviewer-run test suite; unchanged by this diff)
- Design: `Design-Screen: pairstart`, `Design-Surface: cupid-app`,
  `data/devops/system/design-fidelity-config.json` (`ui_surface: true`, locked source)
- Visual evidence: `visual-fidelity/visual-fidelity-report.md` + both PNGs
- Implementation evidence: `coding-plan/test-results.md` sections 5-7
- Architecture: `architecture/solution.md` D1 (escape-link omission)

## Action Items

1. `devops` (or `scrum-master` via waiver) — F4: real-entrypoint runtime startup smoke,
   recorded as `## Story Runtime Startup Smoke`; or `Runtime-Smoke: WAIVED — <reason>`
   in `story_master.md`.
2. `product-owner` — D1: decide the escape link. This is what flips
   `VISUAL_FIDELITY` to `PASS`; no mobile rework is implied either way.
3. `scrum-master` — D2: re-triage `BUG-20260825-002` as fixed-by-STORY-001.

## State Recommendation

- Leave `Implementation (Development)` unchecked and `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Do **not** re-run the `mobile-dev` lane — nothing outstanding belongs to it
- On F4 closure (evidence or recorded waiver), this story is otherwise ready: a
  3rd pass need only confirm the smoke section or the waiver line, then the outcome
  is `DEFERRED_ONLY` carrying D1 and D2

---

## Pass 1 record (2026-08-26, BaseHead `d32f02f3`) — superseded

`Outcome: PATCH_REQUIRED` with four blocking findings (F1 missing visual-fidelity
evidence, F2 `Design-Screen: TBD`, F3 missing entry-point section, F4 missing runtime
smoke) and two deferred (D1 escape link → `product-owner`, D2 BUG-20260825-002
re-triage → `scrum-master`).

AC1-AC3 were verified PASS in that pass against the code and a reviewer-run
`flutter test test/features/pairing/ test/design_system/` → `+219: All tests passed!`,
matching the implementer's reported counts exactly. The BUG-20260825-002 remediation
was verified pixel-identical (`colorGlowCore = Color(0xFFFFFFFF)` in both the dark and
light constructors, equal to `Colors.white`; constant across theme lerp; no test
expectation changed). None of that was re-derived in pass 2 and none of it changed.
