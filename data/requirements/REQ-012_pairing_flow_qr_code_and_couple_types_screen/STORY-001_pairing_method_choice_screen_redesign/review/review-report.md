# Story Review Report — REQ-012 / STORY-001 Pairing-Method Choice Screen Redesign

- Reviewer: `reviewer` (Iris-QC)
- Mode: `compact-story-review`
- Date: 2026-08-26
- Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign`
- BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`
- Worktree HEAD: `9afe9be08aec7e36f4ed6ee027f8433fe8ab7435`
- Implementation commit: `8c203dba543bae1b678338bfbab896df4203a9d2`

Outcome: PATCH_REQUIRED

## Scope Gate

- Scope gate path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/review/scope-gate.md`
- Review type: `compact-story-review`, standard story, Implementation Lane `shared` (delivered by mobile-dev against the Flutter app).
- Review report path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001_pairing_method_choice_screen_redesign/review/review-report.md`
- Source/test files in scope (6, from `git diff --name-only <BaseHead>`):
  - `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart`
  - `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
  - `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  - `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`
- Additional file read for independent entry-point verification (not a changed file): `mobile/lib/core/navigation/pair_gate_shell.dart`
- Evidence files in scope: `coding-plan/test-results.md`, `story_master.md`, `data/devops/system/design-fidelity-config.json`
- Query keys: AC1-AC4, `pairstart` three-row layout, `_openInvite`/`_openJoincode` routing, `colorGlowCore`, Entry Point Reachability, Story Runtime Startup Smoke, `VISUAL_FIDELITY`, `Design-Screen`.
- Retro gate: `data/retro-audit/rework-backlog.md` has 0 `Status: PENDING` and 0 `Status: IN_PROGRESS` items. Review may proceed.
- Phase 2 verdict: proceed; outcome is `PATCH_REQUIRED` on missing mandatory story-level gates.

## Acceptance Criteria

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — exactly three option rows (create / enter code / scan QR), matching copy and icons, replacing the two-option layout | PASS (structure) | `pairing_choice_screen.dart:215-269` builds exactly three `_PairingOptionRow`s with keys `createCodeRowKey`/`enterCodeRowKey`/`scanQrRowKey` and the four new `CupidIcons` glyphs. `git show <BaseHead>:...pairing_choice_screen.dart` confirms the prior layout was a single `CupidPrimaryButton` + `TextButton`; both are gone. Test `renders exactly the three option rows, in order, ...` asserts 3 `InkWell`s, per-row key/title/`IconData`, ascending `dy`, and absence of the two replaced widgets. Visual conformance is AC4 and is NOT verified — see F1. |
| AC2 — "I'll create the code" lands on the create-code (Couple Types) screen | PASS | `pairing_choice_screen.dart:227` → `_openInvite` → `InviteScreen` (`:113-120`). Test `the create-code row opens invite` drives it via `tester.tap()` on the row key. |
| AC3 — "They already have a code" and "Scan the QR" both land on the existing join-code screen | PASS | `:247` and `:268` both call `_openJoincode` → `JoincodeScreen` (`:122-131`). No `qrMode` flag or divergent edge was introduced, so STORY-003 has nothing to unpick. Tests `the enter-code row opens joincode directly` and `the scan-QR row lands on the same joincode screen (AC3)`. |
| AC4 — dark theme + `vi` locale layout/spacing/token/typography match the design source | **UNVERIFIED** | No rendered visual-fidelity evidence of any kind exists. See F1. |

## Findings

### F1 — BLOCKING: per-story rendered visual-fidelity evidence is entirely absent (AC4)

The story directory has no `visual-fidelity/` at all: no `visual-fidelity-report.md`, no
`VISUAL_FIDELITY:` verdict line, and neither an `implemented-<screen>-<device>.png`
nor a `design-reference-<screen>-<device>.png` capture. `coding-plan/test-results.md`
section 6 ("Not run") states this explicitly and reclassifies the check as a
*requirement*-level `mobile-visual-audit` to be scheduled before requirement
integration.

That deferral is precisely what the mobile per-story gate forbids. The per-story
rendered check now applies to the `mobile` lane exactly as it does to frontend; the
requirement-level `mobile-visual-audit.md` is an additional cross-screen check and
does **not** substitute for the per-story capture in either direction.

No exemption applies:
- `data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a
  locked `design_source` (`id: cupid-app`, `surface: mobile`, `entry: Cupid App.dc.html`).
- `story_master.md` records `Design-Surface: cupid-app`, so the surface is decided
  and the two-canvas ambiguity (`cupid-app` vs `cupid-web`) is resolved.
- `story_master.md` line 79 records `UI-facing story: YES`.

AC4 is the story's own acceptance criterion, and the design-fidelity capture is its
only proof. It cannot be recorded as deferred. Note also that the screen carries a
large amount of hand-transcribed geometry (`pairing_choice_screen.dart:17-76`: 30+
literal spacing/size/alpha constants plus a precomputed 140deg alignment pair) —
that is exactly the class of change a rendered comparison exists to validate, and
no unit test in the suite asserts any of those values against the design source.

Owner: `mobile-dev`. Capture and compare per the mobile visual-fidelity reference,
then write `visual-fidelity/visual-fidelity-report.md` with a per-device verdict and
a top-level `VISUAL_FIDELITY:` line.

### F2 — BLOCKING: `Design-Screen` never resolved

`story_master.md:13-14` still reads `Design-Screen: TBD (implementer resolves and
records after rendering candidates)`. The commit on top of the implementation
(`9afe9be`) updated the Artifacts checkboxes only and left this `TBD`. Because the
canvas exposes named screens whose ids are abbreviations that do not track story
titles, an unrecorded id means no one can re-check which design screen the
implementation was validated against. Bundled with F1: the resolved id must be
recorded and must be the screen the `design-reference-*.png` actually depicts.

Owner: `mobile-dev` (resolve during the F1 capture); `scrum-master` owns the
`story_master.md` write.

### F3 — BLOCKING: `## Entry Point Reachability` evidence section missing

`coding-plan/test-results.md` has sections 1-6 and none of them is
`## Entry Point Reachability` with a `Reachable: YES` line and a concrete path. The
section is mandatory and non-waivable for a UI-facing story.

Mitigating (verified independently, so this is an evidence-recording gap and not a
functional defect): the entry point is real and discoverable. `pair_gate_shell.dart:136-143`
maps `PairGateUnpaired()` to `PairingChoiceScreen(...)` inside `_AppShellView`'s
`BlocBuilder<PairGateCubit, PairGateState>`, so an unpaired user lands on this screen
as the root of the pair-gate shell — no direct-URL-only access and no hidden route.

Owner: `mobile-dev`. Documentation-only fix; record the concrete path above.

### F4 — BLOCKING: `## Story Runtime Startup Smoke` evidence missing

The story is `Complexity: standard` (non-trivial) with `Implementation Lane: shared`
delivered against the mobile app, and `story_master.md` carries no
`Runtime-Smoke: WAIVED — <reason>` line. `coding-plan/test-results.md` records no
`## Story Runtime Startup Smoke` section. Widget tests, `flutter analyze`, and the
design-system suites are not a substitute: the smoke is the proof that the app
launches on the provided device/emulator and reaches its first screen without a
crash or an error screen. The DONE gate enforces this independently.

Owner: `mobile-dev` (or `devops` if Scrum Master routes it). If no device/emulator is
available in this environment, that is a `BLOCKED` condition to report back rather
than a section to omit silently.

## Deferred Findings

### D1 — "later, look around first" link omitted (PO decision pending)

`story_master.md` In Scope item 2 says to preserve the privacy note and the
"later, look around first" escape link "exactly as already present in the flow".
Verified against `BaseHead`: **neither was present**. `git show d32f02f3:...pairing_choice_screen.dart`
shows the prior screen contained only a title, a `CupidPrimaryButton` and a
`TextButton` — no privacy note, no escape link. So there is no regression here: the
privacy note was *added* to match the design source (`pairing_choice_screen.dart:271-311`),
and the escape link never existed to preserve.

The implementation deliberately omits the link (`pairing_choice_screen.dart:95-99`,
Tech Lead `architecture/solution.md` D1) because its `goHome` target has no reachable
destination for an unpaired user — `pair_gate_shell.dart:144` renders `AppShell` only
for `PairGatePaired()`, so shipping the link would require adding a pair-gate bypass.
That reasoning checks out against the code. The Tech Lead `DECISION_REQUIRED` for
Product Owner is still open; per handoff it is out of this review's scope and is
recorded here rather than blocked on.

Owner: `product-owner`.

### D2 — BUG-20260825-002 needs re-triage as fixed-by-STORY-001

`data/bugs/master_bugs_list.md` carries `BUG-20260825-002_no_fork_guard_pet_preview_card_color_literal`
as a separate queued bug. It was fixed on this story branch and needs re-triage
rather than a separate bugfix lane. Owner: `scrum-master`.

## Verification of the in-scope BUG-20260825-002 fix

Independently verified rather than taken on trust:

- Pixel-identity confirmed. `cupid_color_tokens.dart` adds `colorGlowCore = const Color(0xFFFFFFFF)`
  to **both** the dark constructor (`:100`) and the light constructor (`:177`).
  `Colors.white` is `Color(0xFFFFFFFF)`, so the substituted value is exact in every
  theme — and because both themes carry the identical value, the new
  `Color.lerp(colorGlowCore, other.colorGlowCore, t)` entry is constant across a
  theme transition too, so no pixel moves mid-lerp either.
- The change is additive only: field, `copyWith` and `lerp` entries added; no
  existing token value altered.
- Consumption at `pet_preview_card.dart:229-230` swaps `Colors.white.withAlpha(_readyGlowAlpha)`
  / `Colors.white.withAlpha(0)` for `colors.colorGlowCore.withAlpha(...)` with
  identical alpha arguments and identical `stops`. Nothing else in that file changed
  (`+2 -2`).
- No visual regression test expectation changed. The diff against `BaseHead` touches
  exactly two test files, both under `test/features/pairing/`; no file under
  `test/features/pet/` or `test/design_system/` was modified, so
  `pet_preview_card_design_fidelity_test.dart` and `pet_design_fidelity_test.dart`
  pass against unchanged expected output.
- Choosing a new token over `colorOnAccent`/`colorText` is correct: both are `#F7EEFB`
  in dark theme and would have tinted the glow.

## Test Evidence

Reviewer-run, not taken on trust:

| Command (cwd `<worktree>/mobile`, `PATH="$HOME/flutter/bin:$PATH"`) | Result |
|---|---|
| `flutter test test/features/pairing/ test/design_system/` | PASS — `00:05 +219: All tests passed!` |

219 = 133 (pairing) + 86 (design_system), matching the implementer's reported counts
exactly. The design_system total includes `no_fork_guard`, `icon_variant`,
`gradient_axis`, `theme_matrix` and `contrast`, so the token addition and the
BUG-20260825-002 remediation are both covered. The implementer's remaining reported
figures (`test/features/pet/` 127 PASS, `flutter analyze lib test` 75 info / 0 error
/ 0 warning) are internally consistent and were not contradicted by anything
observed; they were not re-run because the outcome does not turn on them.

The recorded architecture deviation (badge ships a plain `LinearGradient` with the
precomputed 140deg alignment pair instead of `CupidCssAngleGradient`) is sound and is
not a finding: the badge is `92x92`, and `gradient_axis_test.dart` (15 tests, PASS)
pins the square-box case where box-normalized and CSS-angle math agree exactly.

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Status |
|---|---|---|
| Mobile interaction (three-row screen rebuild) | Targeted widget tests | PASS (reviewer-run, 219) |
| Mobile navigation / discoverability | Entry point verified in router code + recorded evidence section | Code PASS (`pair_gate_shell.dart:139`); evidence section MISSING → F3 |
| Mobile UI design fidelity | Per-story rendered capture + `VISUAL_FIDELITY` verdict | MISSING → F1/F2 |
| App lifecycle / startup | `## Story Runtime Startup Smoke` | MISSING → F4 |
| Shared design-token contract (`CupidColorTokens`) | Theme matrix / contrast / no-fork-guard suites + sibling call-site check | PASS; additive only, single call site swapped |
| Static analysis | `flutter analyze lib test` | PASS on severity (0 error, 0 warning) per implementer evidence |

Configuration-guide verification: not applicable. The change adds no env var, no
external integration, no runtime command and no manual setup step, so
`data/requirements/REQ-012.../deployment/configuration-guide.md` is not in scope for
this story.

Open Question discipline: `story_master.md` "Open Question Impact" records `NONE`,
and confirms OQ1/OQ2 bind STORY-003 and STORY-002 respectively. No OQ was
over-applied and no unblocked AC was omitted on OQ grounds.

## Action Items

1. `mobile-dev` — F1: capture and compare the `pairstart` screen per the mobile
   visual-fidelity reference; write `visual-fidelity/visual-fidelity-report.md` with a
   per-device verdict, the named states from AC4 (dark theme + `vi` locale), and a
   top-level `VISUAL_FIDELITY:` line.
2. `mobile-dev` — F2: resolve and record the concrete `Design-Screen: <id>`; confirm
   the rendered `design-reference-*.png` depicts that screen. (`scrum-master` applies
   the `story_master.md` edit.)
3. `mobile-dev` — F3: add `## Entry Point Reachability` to `coding-plan/test-results.md`
   with `Reachable: YES` and the path `PairGateShell → _AppShellView → PairGateUnpaired → PairingChoiceScreen`
   (`mobile/lib/core/navigation/pair_gate_shell.dart:136-143`).
4. `mobile-dev` — F4: run the mobile runtime startup smoke and record
   `## Story Runtime Startup Smoke` in `coding-plan/test-results.md`; if no
   device/emulator is available, report `BLOCKED` with the exact missing
   environment rather than omitting the section.
5. `product-owner` — D1: decide the "later, look around first" link (drop from scope,
   or open a story for the pair-gate bypass it would require).
6. `scrum-master` — D2: re-triage `BUG-20260825-002` as fixed-by-STORY-001.

## Traceability

- Requirements / ACs: `story_master.md` AC1-AC4, In Scope 1-3, Out of Scope, Open Question Impact
- UX: `ux/ux-spec.md` (three-row layout, `NO_TABS`/`NO_CHROME` chrome contract, verified through `chain_chrome_guard_test.dart`)
- Architecture: `architecture/solution.md` D1 (escape-link omission), D2 (badge gradient derived from existing tokens)
- Coding plan: `coding-plan/master-plan.md`, `coding-plan/phase-P0-pairing-choice-three-row-rebuild.md`
- Implementation evidence: `coding-plan/test-results.md` sections 1-6
- Design source: `cupid-app-design-system/Cupid Screens.dc.html` lines 1571-1615 (`isPairStart`); config `data/devops/system/design-fidelity-config.json`

## State Recommendation

- Uncheck `Implementation (Development)` in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Return to the `mobile-dev` lane with F1, F2, F3, F4
- Do not merge the story branch into `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration` until re-review records `CLEAN` or `DEFERRED_ONLY`
