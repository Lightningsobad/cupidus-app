# STORY-032 Review — Slice 3 of 4 (phase2-screens-b)

Reviewer: Iris-QC
Tier: 3 (Scoped Slice)
Scope: AC1 only, 9 files
Diff baseline: `079d4801831037e2540a813f66efe5e4258eaae4`
Worktree HEAD at review: `3adbb6c3cf45f965e1093b1adf952dfa2611d718`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`

## Slice Verdict

PASS. All 9 in-scope screens dropped their per-screen flat
`Scaffold(backgroundColor: colors.colorBackground)` fill and now inherit the
shared sky wash. No legitimate non-shell `backgroundColor:` use was collaterally
removed, no intermediate wrapper on any of these screens' navigation paths
reintroduces an opaque fill, and all tests covering these screens pass.

## Files In Scope

Three handoff paths did not match the real file locations. Corrected paths were
located by filename under `mobile/lib/features/` and reviewed; no file was
skipped.

| # | File (worktree-relative) | Diff | Result |
|---|---|---|---|
| 1 | `mobile/lib/features/dream_jar/presentation/screens/contribution_history_screen.dart` | -2 | PASS |
| 2 | `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart` | -2 | PASS |
| 3 | `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart` | -2 | PASS |
| 4 | `mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart` (handoff said `features/pairing/presentation/screens/`) | -1 | PASS |
| 5 | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart` (handoff said `love_contract/`, actual dir is `love_contracts/`) | -2 | PASS |
| 6 | `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart` (handoff said `love_contract/`) | -2 | PASS |
| 7 | `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` | -6 | PASS |
| 8 | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` | -1 | PASS |
| 9 | `mobile/lib/features/pairing/presentation/screens/paired_screen.dart` | -1 | PASS |

Total: 9 files changed, 19 deletions, 0 insertions. The slice is purely
subtractive, which matches the AC1 phase-2 intent in `story_master.md`
("removed the 21 per-screen `Scaffold` `backgroundColor` overrides plus 8
locals they left unused").

## AC Traceability

**AC1** — "any screen that should inherit the shared background ... shows
`CupidColorTokens.skyGradient`'s purple/magenta radial wash and star particles,
not a flat `colorBackground` fill."

Verification 1 — no flat-fill override remains. Every `Scaffold(` construction
in the 9 files was enumerated and none carries a `backgroundColor:` argument:

- `contribution_history_screen.dart:81`
- `dream_jar_detail_screen.dart:46`
- `dream_jar_list_screen.dart:51`
- `pairing_required_gate.dart:28`
- `love_contract_screen.dart:64`
- `love_contract_entry_tile.dart:194` (`_GateCheckShell`, key `love_contract_gate_check`)
- `invite_screen.dart:166`
- `joincode_screen.dart:93`
- `paired_screen.dart:41`

Inheritance mechanism (foundation from slice 1, confirmed only to the depth
needed to score this slice): `cupid_theme.dart:45` sets
`scaffoldBackgroundColor: Colors.transparent`, and `cupid_app.dart:44` mounts
`CupidAppBackground` in `MaterialApp.builder`, i.e. one layer above the
Navigator and therefore above every route these 9 screens are pushed onto. A
transparent Scaffold consequently composites over the sky wash.

Verification 2 — no collateral removal of a legitimate non-shell
`backgroundColor:`. Exactly one `backgroundColor:` survives across the 9 files,
and it is correctly retained:

- `contribution_history_screen.dart:256` — `CircleAvatar(backgroundColor: colors.colorSurfaceAlt, ...)`, a contributor avatar, not a shell fill.

Related non-shell fills also correctly untouched: the contribution row's
`Container(color: colors.colorSurface)` at `contribution_history_screen.dart:250`
(list-tile surface), and `paired_screen.dart:43-59`'s `DecoratedBox`
`RadialGradient` (`colorAccentPink` at alpha 0.3 fading to alpha 0). The
`paired_screen` gradient is translucent at every stop, so it tints the sky wash
rather than occluding it — this is the intended design-source
`radial-gradient(circle at 50% 38%, rgba(255,127,182,.3), transparent 62%)`
treatment, not a reintroduced opaque base.

Verification 3 — no intermediate wrapper reintroduces an opaque fill. Call
sites of all 9 screens were enumerated and each wrapper on the path checked:

- `mobile/lib/core/navigation/pair_gate_shell.dart` hosts the Invite / Joincode / Paired pushes (`:171`, `:179`, `:187`). Its own Scaffolds at `:148` and `:202` carry no `backgroundColor`; the only `color:` at `:215` is text ink.
- `mobile/lib/features/expenses/expenses_route.dart` returns `PairingRequiredGate` at `:74` and `:85`; its Scaffold at `:80` carries no `backgroundColor`.
- `mobile/lib/features/home/presentation/home_screen.dart:123` pushes `DreamJarListScreen` on the root navigator via `MaterialPageRoute`, which paints no background of its own.
- `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart:51` pushes `LoveContractGateRoute` via `MaterialPageRoute`; the gate then builds `LoveContractScreen` at `:175`.
- `mobile/lib/core/navigation/app_shell.dart:192` (post-pairing tab shell, on the Dream Jar entry path) carries no Scaffold `backgroundColor`. Its `backgroundColor: colors.colorAccentPink` at `:201` is a `FloatingActionButton` tint, correctly left alone.

Verification 4 — no unused-local or unused-import fallout. Six files dropped a
now-unused `final CupidColorTokens colors` local; three retained theirs because
they are still consumed: `pairing_required_gate.dart:27` (used at `:39`, `:46`),
`joincode_screen.dart:78` (used at `:118`), `paired_screen.dart:38` (used in the
`RadialGradient`). Every file that dropped a local retains at least one other
`context.cupidColors` binding elsewhere in the file, so no import became dead.
Analyzer confirms (see Test Evidence).

AC1 result for this slice: SATISFIED for all 9 files.

## Test Evidence

All runs executed in the story worktree against worktree HEAD
`3adbb6c3cf45f965e1093b1adf952dfa2611d718`, not read from
`coding-plan/test-results.md`.

No test file in the story diff belongs to these 9 screens — the touched tests
(`test/app/feature_flags_test.dart`,
`test/design_system/adaptive_widgets_test.dart`,
`test/design_system/cupid_app_background_test.dart`,
`test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`,
`test/widget_test.dart`) all fall in slice 1 / slice 4 scope. The existing
untouched tests covering this slice's screens were therefore run as regression
evidence.

| Run | Tests | Result |
|---|---|---|
| `dream_jar_detail_screen_test.dart`, `dream_jar_list_screen_test.dart`, `contribution_history_cubit_test.dart`, `expenses/pairing_gate_test.dart`, `expenses/expenses_entry_point_test.dart` | 29 | All tests passed |
| `love_contracts/.../love_contract_screen_test.dart`, `.../screens/love_contract_screen_fidelity_test.dart`, `.../love_contract_entry_tile_test.dart` | 25 | All tests passed |
| `pairing/.../invite_screen_test.dart`, `.../joincode_screen_test.dart`, `.../paired_screen_test.dart`, `dream_jar/.../contribution_history_cubit_test.dart` | 33 | All tests passed |
| `design_system/no_fork_guard_test.dart` | 1 | All tests passed |

The no-fork guard was run explicitly because `invite_screen.dart` deleted the
comment block explaining why the token access was bound to a local rather than
chained off `context`; the guard's forbidden-literal-color substring scan still
passes, so the deletion is safe.

`flutter analyze` over the 9 in-scope files: 4 issues, all `info`-level
`prefer_initializing_formals` at `invite_screen.dart:73,74,94` and
`joincode_screen.dart:25`. All four sit in constructor code well outside the
touched hunks (`invite_screen.dart` ~158-170, `joincode_screen.dart` ~91-99) and
are pre-existing. No error or warning introduced by this slice.

## Findings

None blocking. No PATCH_REQUIRED or DEFERRED finding is raised for these 9
files.

## Out Of Slice

Recorded for the Final Synthesis reviewer; not scored here and not acted on.

**O-1 (observation, likely shared root cause with slice 2's F1).** The preview
harness at `mobile/lib/main_preview.dart` was **not** touched by this story
(`git diff --name-only <BaseHead>` over `main_preview.dart`, `cupid_app.dart`,
`app_shell.dart` returns only `cupid_app.dart`). Its `MaterialApp.builder` at
`main_preview.dart:532-533` wraps only `MediaQuery.withNoTextScaling(...)` and
never mounts `CupidAppBackground`, whereas the real app at `cupid_app.dart:43-44`
does. Because `cupid_theme.dart:45` now makes every Scaffold transparent, any
screen rendered through the preview harness composites over nothing rather than
over the sky wash. The preview harness is the capture path for
`visual-fidelity/` evidence, and it registers seven of this slice's nine screens
directly (`main_preview.dart:140`, `:258`, `:333`, `:336`, `:348`, `:361`, plus
the jarlist/contract entries). This does not affect runtime correctness of the 9
in-scope files — AC1 is satisfied in the shipped app — but it means visual
evidence captured via `main_preview` would not show the shared background for
any screen, which plausibly explains slice 2's F1 AC4 evidence gap as a harness
wiring gap rather than a per-screen defect. Ownership sits with the AC4 evidence
finding already assigned to mobile-dev, not with this slice.

**O-2 (path corrections, no defect).** Three of the nine handoff paths were
wrong: `pairing_required_gate.dart` lives under `features/expenses/presentation/widgets/`
not `features/pairing/presentation/screens/`, and both love-contract files live
under `features/love_contracts/` (plural) not `features/love_contract/`. Worth
propagating to slice 4 and Final Synthesis so the same paths are not re-derived.

Not evaluated in this slice, by handoff instruction: AC2, AC3, AC4, AC5, slice 1
foundation files beyond the minimum inheritance check above, and slice 2's file
set.

SLICE_VERDICT: PASS
