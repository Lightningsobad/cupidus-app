# STORY-001 Test Results — Phase P0 (pairing-choice three-row rebuild)

- Role: `mobile-dev`
- Date: 2026-08-25
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign`
- Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign`
- BaseHead: `f329100d1ba5574f0ea969f8b812cad984a3ed8f`
- Working directory for every command below: `<worktree>/mobile`
- `flutter` is off the default PATH; every command was prefixed with
  `PATH="$HOME/flutter/bin:$PATH"`.

## 1. Required checks

| # | Command | Result | Notes |
|---|---------|--------|-------|
| 1 | `flutter test test/features/pairing/` | PASS | 133 tests, `All tests passed!`. Covers the P0 screen suite plus the whole pairing feature. |
| 2 | `flutter test test/design_system/no_fork_guard_test.dart` | PASS | 1 test, `All tests passed!`. Initially red on a pre-existing offender outside the pairing screen; remediated in-scope per section 3. |
| 3 | `flutter test test/design_system/icon_variant_test.dart` | PASS | 5 tests, `All tests passed!`. The four new `CupidIcons` constants inherit the audited variant axes unchanged. |
| 4 | `flutter test test/design_system/gradient_axis_test.dart` | PASS | 15 tests, `All tests passed!`. Confirms the "both maths agree on the square box" row that the badge gradient decision in section 2 relies on. |
| 5 | `flutter test test/core/navigation/chain_chrome_guard_test.dart` | PASS | 17 tests, `All tests passed!`, including `pairingChoice renders no header and no tab bar` (AC4 NO_CHROME/NO_TABS). |
| 6 | `flutter analyze` (whole package) | FAIL (environment noise, not source) | Resolves `build/ios/SourcePackages/checkouts/flutterfire/**` — gitignored third-party build output with no `analysis_options.yaml` `exclude:` rule. Every error is in that tree; none is in `lib/` or `test/`. See section 4. |
| 7 | `flutter analyze lib test` (scoped re-run of check 6) | PASS on severity | 75 issues, **all `info`**, zero `error`, zero `warning`. `flutter analyze` exits non-zero on any issue, hence exit code 1. All 75 are pre-existing repo-wide style infos (`prefer_initializing_formals`, one `use_null_aware_elements`, one `deprecated_member_use`). |

### Screen suite detail (inside check 1)

`test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`,
8 cases, all passing:

- `renders exactly the three option rows, in order, under the pairing stack key`
  — asserts exactly 3 `InkWell`s, each row's `Key`, its title text and its own
  `IconData` as a descendant, strictly ascending `getTopLeft().dy` for order,
  and that `CupidPrimaryButton`/`TextButton` are both gone (the replaced
  two-option layout, AC1).
- `the create-code row opens invite` — pushes `InviteScreen`.
- `the enter-code row opens joincode directly` — pushes `JoincodeScreen`.
- `the scan-QR row lands on the same joincode screen (AC3)`.
- `carries no header or tab chrome (AC4 NO_CHROME/NO_TABS)`.
- `does not overflow on a rotated short viewport (AC1)` — 640x360 with 48dp
  insets at `TextScaler.linear(1.3)`.
- `AC4/AC5 back edges ... invite pops back to the pairing stack`.
- `AC4/AC5 back edges ... join-code pops back to the pairing stack`.

Every navigation assertion is driven by `tester.tap()` on the row key, never by
a direct constructor call, per the phase's navigation-integration requirement.

## 2. Recorded deviation — badge gradient

`architecture/solution.md` names `CupidCssAngleGradient` for the 140deg hero
badge fill. The badge ships with a plain `LinearGradient` whose `begin`/`end`
are the precomputed 140deg alignment pair instead. Reasons:

- `CupidCssAngleGradient` is not exported by the `design_system.dart` barrel, so
  consuming it from a feature screen would mean either widening that barrel or
  reaching past it — both outside this phase's four-file write scope.
- The badge is exactly 92x92, i.e. square. `gradient_axis_test.dart`'s own
  `both maths agree on the square box, so the matrix needs the rest` case is the
  documented proof that box-normalized and CSS-angle math are identical on a
  square box, so the rendered result is bit-identical to the mandated class.
- No new colour token was introduced (AC4): both stops are derived from existing
  tokens via `.withValues(alpha:)` per architecture D2.

The alignment pair is `(-cos40, -sin40)` / `(cos40, sin40)`, written as literal
doubles with a dartdoc recording the square-box equivalence above.

## 3. Pre-existing guard violation, remediated in this story (check 2)

Tracked as `BUG-20260825-002_no_fork_guard_pet_preview_card_color_literal`
(`data/bugs/master_bugs_list.md`). Scrum Master opened it as PENDING/deferred
while this lane was mid-flight; it was in fact **fixed on this story branch**,
so it needs re-triage as fixed-by-STORY-001 rather than a separate bugfix lane.

`flutter test test/design_system/no_fork_guard_test.dart` was initially red on:

```
lib/features/pet/presentation/widgets/pet_preview_card.dart:229: forbidden pattern "Colors."
lib/features/pet/presentation/widgets/pet_preview_card.dart:230: forbidden pattern "Colors."
```

Origin — not introduced by STORY-001:

- `git diff --name-only f329100d1ba5574f0ea969f8b812cad984a3ed8f` did not list
  `pet_preview_card.dart`; the file was byte-identical to `BaseHead`, so the
  guard failed identically at `BaseHead`.
- Both lines came from `11190e8`
  (`REQ-010_home_dashboard_deferred_scope_completion/STORY-003`).
- The guard scans `lib/features`, `lib/app` and `lib/core` wholesale, so it
  reports this REQ-010 residue on any branch that touches the mobile app.

It is nonetheless inside this handoff's `mobile` WriteScope, and the guard's own
rule ("only `design_system/` may contain a raw colour literal") names exactly one
remediation: move the literal into the token layer. That was done here, and it is
mechanical rather than a design decision, because the substitution is
**pixel-identical**:

- Added `CupidColorTokens.colorGlowCore = Color(0xFFFFFFFF)` to *both* the dark
  and light constructors, plus its field, `copyWith` and `lerp` entries. The
  value equals `Colors.white` exactly, in every theme, so no rendered pixel
  moves and no `Color` equality assertion changes.
- Deliberately *not* an existing token: `colorOnAccent` and `colorText` are both
  `#F7EEFB` in dark, so reusing either would have tinted the glow and genuinely
  become a pet-surface design decision. Adding the token avoids that entirely.
- `pet_preview_card.dart:229,230` now read
  `colors.colorGlowCore.withAlpha(...)`, using the `colors` local already bound
  at line 192.

Regression evidence: `flutter test test/features/pet/` → 127 tests,
`All tests passed!`, including `pet_preview_card_design_fidelity_test.dart` and
`pet_design_fidelity_test.dart`. `flutter test test/design_system/` → 86 tests,
`All tests passed!`, including `theme_matrix_test.dart` and `contrast_test.dart`
(token surface) and `gradient_axis_test.dart`'s `a theme lerp does not silently
drop the correction` case (exercises the new `lerp` entry). No queued bug is
needed.

## 4. `flutter analyze` scoping note (checks 6 and 7)

The unscoped `flutter analyze` walks `mobile/build/`, which currently holds an
iOS `SourcePackages/checkouts/flutterfire/**` tree — vendored third-party Dart
that does not resolve outside its own package. `mobile/analysis_options.yaml`
has no `exclude:` rule, and `/build/` is gitignored, so this is machine-local
noise rather than a source defect. The scoped `flutter analyze lib test` re-run
is the meaningful gate and reports zero errors and zero warnings.

## 5. Files touched outside the phase's declared write scope

All three are inside the handoff's `mobile` WriteScope; none is STORY-002 or
STORY-003 surface.

- `mobile/lib/design_system/tokens/cupid_color_tokens.dart` — additive
  `colorGlowCore` token. The phase write scope admits this file only "if a
  140deg alignment pair must be added"; the actual reason is the guard
  remediation in section 3. Additive only: no existing token value changed.
- `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart` — the two
  guard-offending lines, per section 3.
- `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` — below.

### Out-of-phase test file that also needed updating

`mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` is outside
the phase's four-file write scope but inside the handoff's `mobile` WriteScope.
It still asserted the old two-option shape (`Pair with your partner` /
`I already have a code`) and failed until retargeted to the new row keys and
copy. It now also carries a `"Scan the QR on their phone" reaches the same
JoincodeScreen (AC3)` case. No production behaviour was changed to make it pass.

## Entry Point Reachability

Reachable: YES

Path: `PairGateShell → _AppShellView → PairGateUnpaired → PairingChoiceScreen`

`mobile/lib/core/navigation/pair_gate_shell.dart:136-143` — `_AppShellView`'s
`BlocBuilder<PairGateCubit, PairGateState>` maps the `PairGateUnpaired()` arm
directly to `PairingChoiceScreen(router:, createInviteCubit:,
createJoincodeCubit:)`. The screen is therefore the root the pair-gate shell
renders for every unpaired user: no direct-URL-only access, no hidden route, no
debug flag. Verified by reading the switch in this worktree; the sibling arm at
`:144` renders `AppShell` only for `PairGatePaired()`.

## 7. Per-story visual fidelity (review finding F1/F2)

Run in the rework pass, after the review returned `PATCH_REQUIRED`. Section 6
below is superseded for the per-story check: the per-story rendered gate applies
to the `mobile` lane and is not satisfied by the later requirement-level audit.

| Item | Value |
|---|---|
| Design-Screen (resolved) | `pairstart` |
| Design reference | `visual-fidelity/design-reference-pairstart-android.png` (406x900) |
| Implemented capture | `visual-fidelity/implemented-pairstart-emulator-5554.png` (405x900, 160352 bytes) |
| Device / route | `emulator-5554` (already running), `flutter run -t lib/main_preview.dart --dart-define=PREVIEW=pairstart` inside one `capture-mobile-screen.sh --lease-exec` window |
| States compared | dark theme + `vi` locale (the only pair AC4 names; both pinned by `main_preview.dart`) |
| Verdict | **`VISUAL_FIDELITY: FAIL`** — `visual-fidelity/visual-fidelity-report.md` |
| Golden test | Not added; `visual-fidelity.md` step 4 pins a comparison only after it passes |

The `FAIL` has a single substantive cause: the design source and
`ux/ux-spec.md:84-88` both draw the `Để sau, xem trước app đã` escape link and
the build deliberately omits it (`architecture/solution.md` D1 — its `goHome`
target is unreachable for an unpaired user without a pair-gate bypass). That is
the reviewer's own Deferred Finding D1, owned by `product-owner`, and it needs a
scope decision rather than mobile rework. Every measured geometry, token,
typography, icon and copy value matched — see the per-element table in the
report. The two other visible differences (canvas chrome header, one row-3 text
wrap) were measured and are not defects.

### Harness correction made during the capture

`mobile/lib/main_preview.dart` keyed this screen `'pairingchoice'`, which is not
a canvas id — `render-design-canvas.js --list-screens` reports `pairstart`, and
no `pairingchoice`. Captures under the old key could never filename-match a
renderable reference, which is why the stale
`design-reference-pairingchoice-android.png` its `seedNote` pointed at could not
be regenerated. The key is now `'pairstart'` and the `seedNote` names the
correct reference. Dev-only preview scaffolding; no production screen, token or
test file was touched in this rework.

### Rework verification

| # | Command (cwd `<worktree>/mobile`, `PATH="$HOME/flutter/bin:$PATH"`) | Result |
|---|---|---|
| 8 | `flutter test test/features/pairing/presentation/screens/pairing_choice_screen_test.dart` | PASS — `+8: All tests passed!` |
| 9 | `flutter test test/features/pairing/ test/design_system/ test/core/navigation/chain_chrome_guard_test.dart` | PASS — `+236: All tests passed!` (133 + 86 + 17) |
| 10 | `flutter analyze lib/main_preview.dart` | PASS — `No issues found!` |
| 11 | `flutter analyze lib test` | PASS on severity — `75 issues found`, all `info`, 0 `error`, 0 `warning`; unchanged from the pre-rework count |

## 6. Not run

- **Requirement mobile visual audit** (phase section 6): NOT RUN in P0, and
  still not run — it is the *requirement*-level cross-screen audit, a separate
  `mobile-visual-audit` mode for Scrum Master to schedule before requirement
  integration. It is an additional check, not a substitute for the per-story
  capture in section 7 above, which has now been performed.
- **Story runtime startup smoke**: was out of scope for the mobile-dev rework
  handoff (restricted to unit/component/integration/build evidence; ordinary
  mobile-dev handoffs are guard-blocked from device runtime work). Captured
  separately below, run directly by Scrum Master.

## Story Runtime Startup Smoke

Result: PASS. Owner: Scrum Master, run directly (mobile-dev handoffs in
ordinary `continue` are guard-blocked from emulator/device runtime work by
`guard-broad-handoff.sh [GENERIC]` — targeted unit/component/integration/build
evidence only for that lane; this closes reviewer pass-2 finding F4, the sole
remaining `PATCH_REQUIRED` blocker).

Device: `emulator-5554`, already running (not booted by this smoke).

Steps, using the `mobile-app` runtime registry entry
(`data/devops/system/runtime-command-registry.json`):
1. `buildCommand`: `flutter build apk --debug` in `mobile/` (worktree HEAD
   `0b5efe157394426b439c4f80e04973c50bbeb898`) — built
   `build/app/outputs/flutter-apk/app-local-debug.apk` cleanly (Gradle
   `assembleLocalDebug`, KGP plugin warning only, no errors).
2. Installed the built debug APK via
   `adb -s emulator-5554 install -r <path-to-app-local-debug.apk>` (direct adb
   install used because `flutter install -d emulator-5554` defaults to the
   release flavor, which was not built here).
3. Ran the registry's exact `readiness.command` (launch `MainActivity` with
   `am start -W`, poll `dumpsys activity activities` for
   `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
   up to 30 × 2s) — resumed/foreground within the first poll, exit 0.
4. Ran the registry's exact `readiness.shutdownCommand`
   (`am force-stop com.snapsofts.cupid`) to leave the device clean.

Result/Shutdown: PASS, app stopped cleanly, no process left running.

Scope: this smoke only exercises the app launching to its first screen on an
already-live device (`am start` / resumed-activity probe); it does not
substitute for the widget/component coverage or the per-story visual-fidelity
capture above, which use `lib/main_preview.dart` deliberately (no camera/real
device dependency).
