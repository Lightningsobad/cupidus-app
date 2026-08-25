# Phase P1 – Backdrop Occlusion Guard, Runtime Probes, And Targeted Visual Pass

## 1. Objective

Lock the already-correct shared `--sky` wash against silent regression: ship a
whole-inventory static occlusion guard carrying the ratified two-screen
exception allowlist, extend the runtime pixel probes by four
structurally-distinct screens, and run the targeted AC3 visual pass. No
production code changes.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-backdrop-occlusion-guard-and-probes.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart` (new)
  - `mobile/test/design_system/shared_backdrop_occlusion_test.dart` (extend)
  - `coding-plan/test-results.md` (new)
  - `visual-evidence/` under the story directory (AD-6 captures)
  - **Not writable: `mobile/lib/**`, `mobile/pubspec.yaml`, `backend/`.**
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
    (`flutter build apk --debug`)
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced: none
- Shared Interfaces Consumed:
  - `CupidAppBackground` / `buildCupidTheme` / `CupidColorTokens`
    (`mobile/lib/design_system/design_system.dart`), unchanged
  - the existing `_host` / `_probePixel` / `_renderAndProbe` /
    `_expectSharedBackdropShowsThrough` helpers already in
    `shared_backdrop_occlusion_test.dart`, unchanged in intent
- Risk Surfaces: all six rows of `master-plan.md` `## 3A`
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 3, AD-3,
    AD-4, AD-5, AD-6
  - ratified scope: `../story_master.md` AC2 + `## Open Question Impact`
  - repo convention for source-scanning guards:
    `mobile/test/design_system/no_fork_guard_test.dart`
- Primary Inputs Summary:
  - requirements: `../story_master.md` `## Acceptance Criteria` and
    `## Open Question Impact` (both OQs are RESOLVED — do not reopen)
  - architecture: `../architecture/solution.md` section 3 (the audit table —
    this is the allowlist's evidence), AD-3, AD-4, AD-5, AD-6
  - UX constraints: `../ux/uiux-spec.md` §5 (visual regression risk areas 1-3),
    §3 (token/layer geometry, for choosing the AD-6 inspection regions)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one behavior cluster — "prove the shared wash is not
    occluded and keep it that way". Static guard, runtime probes, and the
    targeted visual pass are three evidence types for the same single claim.
  - Source/Test File Count: 2 (1 new, 1 extended) + evidence artifacts
  - Split Required: NO
  - Split Rationale: fits one specialist lifecycle. Splitting AD-4/AD-5/AD-6
    into separate phases would cost three implementation dispatches and three
    verification passes for one small verification cluster, and each fragment
    would be individually meaningless as a review unit.

## 2. Required Reads

- `../story_master.md` `## Acceptance Criteria`, `## Open Question Impact`
- `../architecture/solution.md` sections 3, AD-3, AD-4, AD-5, AD-6
- `../ux/uiux-spec.md` §3, §5
- `mobile/test/design_system/no_fork_guard_test.dart` (guard convention)
- `mobile/test/design_system/shared_backdrop_occlusion_test.dart` (the file you
  are extending — read it fully before touching it)

## 3. Tasks

### Task 1 — Re-verify the allowlist before writing the guard (ordered prerequisite)

Re-run the audit's two sweeps over `mobile/lib` and confirm the occluder set is
still exactly the two ratified files:

- `mobile/lib/features/auth/presentation/screens/splash_screen.dart:141-143`
- `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart:128`

Record the sweep commands and their raw hit counts in `test-results.md`. If the
set has changed (a third occluder, or one of the two no longer occluding),
**stop and escalate** — do not add the new file to the allowlist yourself and do
not edit `mobile/lib/` to remove it. A new allowlist entry is a reviewable
design decision, not a mechanical unblock (AD-3).

### Task 2 — Write the static occlusion guard

New file `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart`.
Follow the `no_fork_guard_test.dart` convention: `dart:io` + `flutter_test`,
paths relative to the `mobile/` package root (`flutter test` runs with `mobile/`
as cwd), collect violations into a list and assert `isEmpty` with a reason
string that lists every violation as `file:line`.

**Header comment must state, in this order:** what the guard protects (the
single composition-root wash at `cupid_app.dart:59`), why (STORY-046 fixed six
instances of this exact defect and nothing prevented a seventh), what it
detects, and its known limit (a source scan cannot judge a computed color or a
deeply-nested full-bleed container — that gap is covered by the runtime probes
in `shared_backdrop_occlusion_test.dart`).

Detector requirements:

1. **Inventory.** Walk `lib/` recursively for `.dart` files whose text contains
   `Scaffold(`. Skip `lib/preview/` and `lib/main_preview.dart` — the developer
   preview harness is not an app route and is out of AC scope. Assert the
   inventory is non-empty, so a broken path silently passing is impossible.
2. **Root-level only.** For each `Scaffold(` occurrence, walk characters forward
   tracking parenthesis/bracket/brace depth (and skipping string literals and
   `//` comments) to collect the argument names at **depth 1 of that
   `Scaffold(` call only**. Nested component colors deeper in the tree must
   never be inspected — that is what keeps the guard from flagging avatar
   fills, chip fills, and sheet surfaces (`../architecture/solution.md` §3.3).
   Do not add the `analyzer` package; hand-roll this scanner in the test file.
3. **Violation A — opaque scaffold fill.** A depth-1 `backgroundColor:`
   argument whose value expression is anything other than `Colors.transparent`
   or `null`.
4. **Violation B — opaque root body layer.** A depth-1 `body:` argument whose
   value expression *begins with* `DecoratedBox(`, `ColoredBox(`, or
   `Container(` **and** carries a `color:`, `decoration:`, or `gradient:`
   argument at depth 1 of that widget. A `Container(` with only layout
   arguments is not a violation.
5. **Allowlist.** A `const Map<String, String>` of the two ratified relative
   paths to a one-line rationale each, mirroring AD-3:
   - `splash_screen.dart` → design-source-backed, cite
     `Cupid Screens.dc.html:1418` (its own full-bleed linear gradient overrides
     `--sky` on purpose).
   - `gallery_viewer_screen.dart` → product judgment, media legibility: the
     purple/magenta wash behind letterboxed photos degrades viewing and shifts
     perceived photo color; the hardcoded `dark()` keeps the letterbox neutral
     in both themes.
     Ratified by OQ-1 in `../story_master.md` `## Open Question Impact`.
   Skip allowlisted files when collecting violations.
6. **Allowlist is itself asserted.** Add a second `test()` that fails if an
   allowlist entry no longer exists on disk or no longer actually occludes.
   Without this, the allowlist silently rots into permanent dead exemptions.

### Task 3 — Extend the runtime probes (AD-5)

Extend `mobile/test/design_system/shared_backdrop_occlusion_test.dart` with
exactly these four probes, each named for the composition pattern it proves —
not for coverage count:

| Probe target | Pattern it proves | Construction note |
|---|---|---|
| `HomeScreen` | tab content inside `AppShell`'s nested `Scaffold`, plus a screen-local hero glow stacked on the shared wash (UX §5 risk area 3) | all three ctor params are optional factories; `mobile/test/features/home/home_screen_test.dart` already shows the `getIt` registrations and `_NoOp*Repository` fakes needed — reuse that setup, do not invent new fakes |
| a `PairGateShell` route | double-nested shell `Scaffold` | inject `createPairGateCubit` (and the other optional seams) so no live network/DI is required |
| `TimelineScreen` | long scrollable body over a fixed wash | `createCubit` is required; build a `TimelineCubit` over a fake repository as `mobile/test/features/timeline/presentation/timeline_screen_test.dart` already does. Prefer this over `DreamJarListScreen`, which pulls `getIt<BackendUserIdStore>()` at build time |
| `ChatScreen` | persistent bottom input chrome + `SafeArea` interaction | reuse `_FakeChatRepository` / `_NamedPartnerStore` / `_FakeRealtimeCoordinator` from `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` |

Constraints:

- Reuse `_expectSharedBackdropShowsThrough` as-is. It asserts
  `everyElement(isNull)` over **every** `Scaffold.backgroundColor` in the tree,
  so a nested-shell probe only passes if neither the shell nor the leaf sets a
  fill. That assertion is the point — do not weaken it to make a probe pass. If
  a probe fails on it, you have found a real occluder: stop and escalate.
- If the helper needs to be shared across files, lift it into a test-support
  file rather than copy-pasting. Copy-pasting the probe assertions is the one
  thing that guarantees they drift apart.
- Never point the helper at `splash_screen` or `gallery_viewer_screen` — they
  are allowlisted and would fail by design.
- Use `settles: false` for any target running a perpetual animation (the `vow`
  probe is the existing precedent).
- Do not add a fifth probe. The static guard already gives whole-inventory
  coverage; more near-identical probes only multiply DI setup and CI time.

### Task 4 — Targeted visual pass (AD-6, satisfies AC3)

Two intersections only, both enumerated by AD-6. A 37-screen sweep is
explicitly out of scope — no code in this story changes what any screen paints,
so screens outside these two intersections need no new evidence.

1. **Top-third contrast.** For at least the four Task 3 probe targets, capture
   the rendered frame and confirm `--tx` (`#F7EEFB`) primary text, `--tx2`
   (`#B4A6CE`) secondary text, thin dividers, and low-contrast icons in the top
   third remain legible over the brightest wash region (purple layer alpha .55
   at 15%,-8%; magenta alpha .32 at 95%,6% — `../ux/uiux-spec.md` §3).
2. **Home hero-glow double-stack.** `home_screen.dart:310`'s `_heroGlow`
   `Container` sits directly over the shared magenta layer. This is the single
   highest-value double-stack check in the app. Confirm no banding, no
   over-brightness, no clipped/blown-out region where the two overlap.

Record each check as pass/fail with the captured evidence path in
`test-results.md`. Note in the evidence that these are dark theme + `vi` locale
only, per the story's Out of Scope.

### Task 5 — Record evidence

Write `coding-plan/test-results.md` with the exact commands run, pass/fail
counts, the Task 1 sweep output, and the AD-6 capture paths. State explicitly
that `mobile/lib/**` was not modified and why (OQ-1 ratified both exceptions),
so the review gate is not left to infer it.

## 4. Acceptance Criteria

- AC1 (story AC1): `test-results.md` cites `cupid_app.dart:59` and
  `cupid_theme.dart:45` as documentary evidence that the reusable primitive
  already exists and is mounted once — no new primitive is built.
- AC2 (guard precision): the guard flags zero files on the current tree, and a
  deliberate temporary edit adding `backgroundColor: colors.colorBackground` to
  any non-allowlisted screen makes it fail with that screen's `file:line`.
  Record both runs. Revert the temporary edit.
- AC3 (allowlist integrity): both allowlist entries carry an inline rationale,
  and the allowlist-freshness test fails if an entry stops existing or stops
  occluding.
- AC4 (runtime probes): all four new probes pass with
  `_expectSharedBackdropShowsThrough` unweakened, and the six pre-existing
  probes still pass unmodified.
- AC5 (no double wash): `git diff` shows zero changes under `mobile/lib/`.
  `CupidAppBackground` appears in exactly one production mount point.
- AC6 (story AC3): both AD-6 checks recorded pass with evidence paths.
- `flutter analyze` is clean and `flutter build apk --debug` succeeds.

## 5. Planned Outputs

- Code: none under `mobile/lib/`. Tests: the two paths in `## 1B. Write Scope`.
- Contracts: none.
- Notes or evidence: `coding-plan/test-results.md` plus the AD-6 captures.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, whole-app backdrop layer (dark theme,
  `vi` locale)
- Required levels:
  - unit / source-scan: `shared_backdrop_occlusion_guard_test.dart` — clean
    tree passes; injected violation fails with `file:line`; allowlist freshness.
  - widget / render: `shared_backdrop_occlusion_test.dart` — four new probes
    plus the six existing ones.
  - integration: N/A — no wiring, DI, or network path changes.
  - mobile build/type-check/static-analysis: `flutter analyze` clean and
    `flutter build apk --debug` succeeding.
  - visual inspection: the two AD-6 intersections only.
- Required checks: the negative-control half of each probe must still show the
  green sentinel. If it does not, the probe pixel is no longer a pixel that
  screen's `Scaffold` paints, and the probe proves nothing — fix the probe
  target, do not lower the threshold.
- Mobile discoverability / navigation integration: no entry point is added or
  changed. Every probe target is an existing, already-reachable screen, and the
  probes mount the real screen widget rather than an extracted sub-widget.
- Minimum gates by risk surface: see `master-plan.md` `## 3A`; every row's gate
  is one of the checks above.
- Required regression or contract coverage: the six existing REQ-002 STORY-046
  probes and `cupid_app_background_test.dart` (wash + non-hit-testable stars)
  must pass unmodified in intent.
- Evidence format: exact commands and pass/fail counts in
  `coding-plan/test-results.md`, plus the Task 1 sweep output and the AD-6
  capture paths.
- Verification strategy:
  - Targeted tests: `flutter test test/design_system/`
  - Full suite: `flutter test` (this story touches a whole-inventory guard, so
    the full suite is the only way to prove the guard does not flag an
    unrelated existing screen)
  - Build/static-analysis command: `flutter analyze` then
    `flutter build apk --debug` (resolve the SDK via `FLUTTER_SDK_PATH`,
    default `$HOME/flutter`; it is not on PATH on this machine)
  - Required assertion evidence: the guard's injected-violation run reporting
    the exact `file:line` it was seeded with, and a clean `git diff --stat`
    over `mobile/lib/`.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
- Evidence: pending — `coding-plan/test-results.md`
