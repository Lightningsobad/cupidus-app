# Story Review Report — REQ-012 / STORY-001 Pairing-Method Choice Screen Redesign

- Reviewer: `reviewer` (Iris-QC)
- Mode: `compact-story-review`
- Pass: 3 (final — F4 closure verification)
- Date: 2026-08-26
- Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign`
- Pass-3 BaseHead / HEAD: `3438f7413dbd8a03efba29d32067532c3a78cc06`
- Pass-3 diff reviewed: `0b5efe157394426b439c4f80e04973c50bbeb898..3438f7413dbd8a03efba29d32067532c3a78cc06`
- Scope gate: `review/scope-gate.md`

Outcome: DEFERRED_ONLY

All four blocking findings (F1, F2, F3, F4) are closed. Two non-blocking deferred
items remain and are routed to their owners below. No blocking finding remains, so
this story is approved for `DONE` and for merge into the requirement integration
branch.

## Pass 3 — F4 closure verification

F4 was the sole pass-2 blocker: `coding-plan/test-results.md` carried no
`## Story Runtime Startup Smoke` section, and the only rendered evidence had come
from `lib/main_preview.dart` — a dev-only entrypoint, which is exactly the failure
mode rule 12g exists to catch.

**F4 is now CLOSED.** Verified independently:

- `git diff --stat 0b5efe15..3438f741` touches **four `.md` files only** — zero
  production bytes. `test-results.md` (+42), `story_master.md`, and my own
  `review-report.md` / `scope-gate.md` being committed. Nothing in the implementation
  changed, so no pass-2 conclusion can have been invalidated by this commit.
- The new `## Story Runtime Startup Smoke` section records `Result: PASS`, owner
  Scrum Master (run directly — `guard-broad-handoff.sh` blocks device runtime work
  through `mobile-dev` in ordinary continue), device `emulator-5554`.
- The four recorded steps are **registry-backed**. I checked each against
  `data/devops/system/runtime-command-registry.json`, entry `mobile-app`:
  - Step 1 build = registry `buildCommand` `flutter build apk --debug` (:171),
    producing `build/app/outputs/flutter-apk/app-local-debug.apk`.
  - Step 2 `adb -s emulator-5554 install -r <apk>` — direct `adb` rather than
    `flutter install`, because the latter defaults to the release flavor.
  - Step 3 = registry `readiness.command` verbatim (:224): `am start -W -n
    com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`, then up to 30 × 2s
    polls of `dumpsys activity activities` for
    `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`.
    Resumed on the first poll, exit 0 = registry `expectExitCode`.
  - Step 4 = registry `readiness.shutdownCommand` verbatim (:227):
    `am force-stop com.snapsofts.cupid`. `Result/Shutdown: PASS`, no process left.
- **This is the real entrypoint, not the preview one.** The probe launches
  `MainActivity` from an installed APK, i.e. the shipped `lib/main.dart` graph. That
  answers my pass-2 objection directly. The registry's own readiness note (:239) is
  explicit that the in-app widget-key signal is *not* the readiness probe because a
  widget test passes while no app process exists — the evidence recorded here uses the
  launch-based probe, which is the correct one.
- **Staleness check:** the smoke ran at worktree HEAD `0b5efe15`, one commit behind
  the pass-3 BaseHead. Not stale — `3438f741` changed only `.md` artifacts, so the
  APK built at `0b5efe15` is byte-identical to one built at `3438f741`.

`story_master.md` Implementation note is updated to match, and the escape hatch I
proposed in pass 2 (run the smoke outside `mobile-dev`, or record
`Runtime-Smoke: WAIVED`) was taken via the first branch — a real run, not a waiver.

Per the pass-3 handoff, F1/F2/F3 and the D-1 DEFERRED verdict are **settled from
pass 2 and not reopened**. The pass-2 record below is retained unchanged.

## Residual deferred items (non-blocking, carried forward)

| # | Item | Owner | Why it does not block |
|---|---|---|---|
| D1 | Design source's "later, look around first" escape link is absent from the implementation; sole substantive cause of the recorded `VISUAL_FIDELITY: FAIL` | `product-owner` | Non-regressive — `git show d32f02f3:...pairing_choice_screen.dart` proves the link did not exist at BaseHead, so nothing was removed. Tech Lead's `DECISION_REQUIRED` (no reachable destination) is a product decision, not a defect `mobile-dev` can fix. AC4's literal text names layout, spacing, colour/token usage and typography — all four match. |
| D2 | BUG-20260825-002 was fixed in-flight inside this story rather than through the bug queue | `scrum-master` | The fix is pixel-identical and verified (`colorGlowCore = 0xFFFFFFFF` in both themes, equal to the `Colors.white` literal it replaced, constant across `Color.lerp`). Re-triage is bookkeeping, not a code risk. |

## Pass-2 record (superseded by Pass 3, retained for audit)

Pass-2 outcome was `PATCH_REQUIRED` with F4 as the single blocker.

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

## Action Items (Pass 3 — final)

1. ~~F4 runtime startup smoke~~ — **CLOSED** in `3438f741`, registry-backed, real
   `MainActivity` entrypoint, `PASS`.
2. `product-owner` — D1 (deferred, non-blocking): decide the "later, look around
   first" escape link. This is what flips `VISUAL_FIDELITY` to `PASS`; no mobile
   rework is implied either way, and it does not gate this story.
3. `scrum-master` — D2 (deferred, non-blocking): re-triage `BUG-20260825-002` as
   fixed-by-STORY-001.

## State Recommendation (Pass 3 — final)

- Check `Implementation (Development)` and `Review (Reviewer)` in `story_master.md`
- Story status: `DONE`
- Approved for merge into
  `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`
- Do **not** re-run the `mobile-dev` lane — nothing outstanding belongs to it
- Carry D1 and D2 forward as requirement-level deferred items; D1 in particular
  should be revisited at requirement integration review since it is the only reason
  `VISUAL_FIDELITY` still reads `FAIL`

---

## Pass 1 record (2026-08-26, BaseHead `d32f02f3`) — superseded

Pass-1 verdict (superseded, not the current `Outcome:` — see line 12): `PATCH_REQUIRED`
with four blocking findings (F1 missing visual-fidelity evidence, F2
`Design-Screen: TBD`, F3 missing entry-point section, F4 missing runtime smoke) and
two deferred (D1 escape link → `product-owner`, D2 BUG-20260825-002 re-triage →
`scrum-master`).

AC1-AC3 were verified PASS in that pass against the code and a reviewer-run
`flutter test test/features/pairing/ test/design_system/` → `+219: All tests passed!`,
matching the implementer's reported counts exactly. The BUG-20260825-002 remediation
was verified pixel-identical (`colorGlowCore = Color(0xFFFFFFFF)` in both the dark and
light constructors, equal to `Colors.white`; constant across theme lerp; no test
expectation changed). None of that was re-derived in pass 2 and none of it changed.
