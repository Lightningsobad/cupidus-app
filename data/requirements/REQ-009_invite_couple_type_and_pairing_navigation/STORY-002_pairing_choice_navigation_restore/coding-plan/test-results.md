# STORY-002 Test Results — Pairing Choice Navigation Restore

Lane: mobile-dev · Phases: P1 (design source) + P2 (post-code navigation guards)
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-002_pairing_choice_navigation_restore`
BaseHead: `4339ff0cb17f7e201e1c88ed87e6672f17e9845e`
Date: 2026-08-24

## Summary

| Gate | Result |
| --- | --- |
| P1 structural evidence (7 edits) | PASS |
| P1 AC6 visual fidelity | PARTIAL — design reference rendered; implemented capture still `DEVICE_CAPTURE_BLOCKED` |
| Entry point reachability (rule 12e1) | PASS — `Reachable: YES` |
| P2 targeted tests (4 files) | PASS — `+38: All tests passed!` |
| P2 regression suites | PASS — `+172: All tests passed!` |
| `flutter analyze` on touched files | PASS — `No issues found!` |
| AC7 repo-wide vow grep | PASS |
| `mobile/lib/` exclusion | PASS — no `mobile/lib/` path in diff |

## P1 — Design source restore (structural evidence)

Command: `git grep -n -E "data-screen-btn=\"pairingchoice\"|isPairingChoice|goVow|goWaiting|goJoinCode|pairingchoice" -- cupid-app-design-system`

Edit (§1) — screen button makes the node enumerable:

```
cupid-app-design-system/Cupid App.dc.html:192:<span data-screen-btn="pairingchoice" ...>Pairing choice</span>
```

Edit (a) — `isPairingChoice` screen block inserted between `isProfile` and `isContract`:

```
cupid-app-design-system/Cupid Screens.dc.html:121:<sc-if value="{{ isPairingChoice }}" hint-placeholder-val="{{ true }}">
cupid-app-design-system/Cupid Screens.dc.html:125:<div onClick="{{ goJoinCode }}" ...><span data-vi>Tôi đã có mã</span><span data-en>I already have a code</span></div>
```

Block spans lines 121-127: title (`Ghép đôi để mở khoá Cupid`), primary CTA
`onClick="{{ goInvite }}"` (`Ghép đôi với người ấy`), secondary CTA
`onClick="{{ goJoinCode }}"`, wrapper `padding:150px 28px 0`.

Edit (b) — invite CTA no longer targets vow (INV-1):

```
cupid-app-design-system/Cupid Screens.dc.html:209:<div onClick="{{ goWaiting }}" ...><span data-vi>Tiếp tục → Đợi ghép</span><span data-en>Continue → Waiting</span></div>
```

Edit (c) — INDEX first item of the "Ghép đôi" group:

```
cupid-app-design-system/Cupid Screens.dc.html:1874:    { id: 'pairingchoice', icon: 'favorite_border', vi: 'Chọn cách ghép đôi', en: 'Pairing choice' },
```

Edit (d) — BACK_TO edges (`invite`/`joincode` → pairing-choice, pairing-choice → profile):

```
cupid-app-design-system/Cupid Screens.dc.html:1861:const BACK_TO = { ... joincode: 'pairingchoice', profile: 'permissions', contract: 'paired', invite: 'pairingchoice', pairingchoice: 'profile' };
```

Edit (e) — chrome suppression:

```
cupid-app-design-system/Cupid Screens.dc.html:1960:const NO_CHROME = { welcome: 1, vow: 1, home: 1, splash: 1, pairingchoice: 1, waiting: 1, paired: 1, shareok: 1 };
cupid-app-design-system/Cupid Screens.dc.html:1961:const NO_TABS  = { ... permissions: 1, pairingchoice: 1, joincode: 1, waiting: 1, paired: 1, ... };
```

Edits (f)/(g) — handlers and screen predicate:

```
cupid-app-design-system/Cupid Screens.dc.html:2140:      goJoinCode: () => a.go('joincode'), goWaiting: () => a.go('waiting'),
cupid-app-design-system/Cupid Screens.dc.html:2144:      isPairingChoice: sc === 'pairingchoice',
```

Residual `goVow` occurrences — both permitted by the AC, neither on a post-code edge:

```
cupid-app-design-system/Cupid Screens.dc.html:1454: contract (love-contract) CTA — post-pairing tail usage
cupid-app-design-system/Cupid Screens.dc.html:2139: handler definition `goVow: () => a.go('vow')`
```

### AC6 — visual fidelity: PARTIAL (design half now present)

Full detail: `visual-fidelity/visual-fidelity-report.md`.

**Design reference — RESOLVED this pass.** The render exists at
`visual-fidelity/design-reference-pairingchoice-android.png` (406×900, android /
dark / vi):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location="<worktree>/cupid-app-design-system" \
  --entry="Cupid App.dc.html" \
  --screen=pairingchoice --platform=android --theme=dark --lang=vi \
  --out="<story>/visual-fidelity"
DESIGN_CANVAS: OK .../design-reference-pairingchoice-android.png 406x900
```

This supersedes the earlier `DESIGN_RENDER_TOOL_UNRESOLVED` finding. That finding
was accurate about the worktree — `.ai-team-bundle/` is gitignored, so the tool
genuinely is not there — but the tool exists in the CONTROL checkout at
`.ai-team-bundle/runtime/tools/render-design-canvas.js`. Two flags beyond the
`ux/ux-spec.md:172` invocation are required: `--surface=mobile`/`--entry=` (the
project declares two design sources) and `--location=<worktree>/cupid-app-design-system`
(`--entry` is basename-resolved against the project root, so without it the tool
renders the control checkout's design source, which lacks this story's P1
restore — 37 screens, no `pairingchoice`, vs 38 with it).

The render confirms the P1 restore end-to-end: `pairingchoice` is enumerable,
and the rendered frame shows the title, gradient primary CTA, secondary text
link, and suppressed chrome in the expected order. The comparison table in the
fidelity report keeps the two `mobile/lib/` deviations (title `fontSize: 27` vs
canvas `24px`; EN **primary** CTA wording — the prior pass attributed that
deviation to the secondary CTA, which actually matches).

**Implemented capture — still blocked, not retried this pass.**

1. `DEVICE_CAPTURE_BLOCKED` — the documented fallback (preview capture) got as
   far as a successful build and then failed at install:
   - Build: `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=pairingchoice` → exit 0
     (artifact `build/app/outputs/flutter-apk/app-local-debug.apk`, `local` flavor from REQ-008).
   - Device: `emulator-5554` already booted (reused, not provisioned).
   - Install: `adb install -r -t build/app/outputs/flutter-apk/app-local-debug.apk` →
     `java.io.IOException: Requested internal only, but not enough space`
   - `adb shell df /data` → `429848` KB available, 93% used.
   Freeing space means uninstalling apps or wiping a shared emulator, which is
   outside the mobile-dev lane's scope (no emulator provisioning/repair).

Fallback fidelity evidence is therefore source-vs-canvas comparison only, against
`mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
(read-only; not modified by this story):

| Aspect | Canvas (restored) | Flutter screen | Verdict |
| --- | --- | --- | --- |
| Layout padding | `150px 28px 0` | `EdgeInsets.fromLTRB(28, 150, 28, 0)` | match |
| Title (vi) | `Ghép đôi để mở khoá Cupid` | same string | match |
| Primary CTA (vi) | `Ghép đôi với người ấy` | same string | match |
| Secondary CTA (vi) | `Tôi đã có mã` | same string | match |
| CTA height / radius / gradient | `52px`, `var(--r-btn)`, pink→purple | 52, token radius, same gradient | match |
| Chrome | `NO_CHROME` + `NO_TABS` | no AppBar/CupidHeader/tab bar (asserted by test) | match |
| Title size | `24px`, line-height 1.3 | `fontSize: 27`, `height: 1.3` | deviation (pre-existing) |
| Primary CTA (en) | `Pair up with them` | `Pair with your partner` | deviation, `en` not user-enabled (OQ5: dark + `vi` only) |

Both deviations sit in `mobile/lib/`, which this story is forbidden to touch, and
neither affects the only enabled configuration (dark + `vi`). Recorded as
findings for the review gate, not fixed here.

## Entry Point Reachability

UI-facing story: YES (`story_master.md`). Rule 12e1.

**Reachable: YES** — proven by an existing test, no new test required.

Entry point: `PairGateShell` → `PairGateUnpaired` renders the pairing stack.
`PairingChoiceScreen` is not reached by direct construction in the app; it is
what the unpaired branch of the pair gate renders, and that is the branch a real
unpaired user lands on.

Evidence — `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`:

| Item | Location |
| --- | --- |
| Harness mounts the **real** `PairGateShell` (not `PairingChoiceScreen` directly), with `PairGateCubit` resolving `PartnerLink(partnerId: null)` — i.e. the unpaired state | `_gateHarness()`, `:155-178` |
| Reachability assertion: the gate renders `Key('pairing_stack')` with no manual navigation | `:118` — `expect(find.byKey(const Key('pairing_stack')), findsOneWidget);` |
| Same assertion in the join-code path | `:142` |
| Both CTAs are live from that rendered stack | `:120` taps `Ghép đôi với người ấy` → `InviteScreen` (`:122`); `:135` taps `Tôi đã có mã` → `JoincodeScreen` (`:137`) |
| Back edges return to the entry point | `:127`, `:142` — `pairing_stack` `findsOneWidget` after `maybePop()` |

The harness comment at `:148-152` states the intent explicitly: it mounts the
real shell "so the entry point is proved (`PairGateUnpaired` really does render
the pairing stack)".

These assertions are inside the `+38: All tests passed!` targeted run recorded
below. Re-confirmed standalone when this section was written, so the claim is
backed by a green run rather than by reading alone:

```
flutter test --no-pub --reporter failures-only \
  test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
+7: All tests passed!
TEST_EXIT=0

flutter analyze --no-pub \
  test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
No issues found! (ran in 1.8s)
ANALYZE_EXIT=0
```

Design-side reachability is separately confirmed: the P1
`data-screen-btn="pairingchoice"` edit makes the node enumerable in the canvas
(`--list-screens` returns `pairingchoice`; see the AC6 section above).

## P2 — Post-code navigation guards

Files (all under `mobile/test/`, none under `mobile/lib/`):

- `mobile/test/core/navigation/post_code_navigation_guard_test.dart` (new)
- `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart` (extended)
- `mobile/test/features/pairing/presentation/invite_screen_test.dart` (extended)
- `mobile/test/features/pairing/presentation/joincode_screen_test.dart` (extended)

`chain_tail_edges_test.dart` was deliberately not touched: it owns the correct
post-pairing `vow` tail and this story must not duplicate or weaken it.

### Targeted run

```
flutter test --no-pub --reporter failures-only \
  test/core/navigation/post_code_navigation_guard_test.dart \
  test/features/pairing/presentation/invite_screen_test.dart \
  test/features/pairing/presentation/joincode_screen_test.dart \
  test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
+38: All tests passed!
TEST_EXIT=0
```

Coverage mapping:

| AC | Assertion | Location |
| --- | --- | --- |
| AC1/AC2 | `OnboardingChain.next(invite) == waiting`, `isNot(vow)` | `post_code_navigation_guard_test.dart` |
| AC1/AC2 | copy action lands on `WaitingScreen`, `VowScreen` findsNothing | `invite_screen_test.dart` |
| AC3 | `OnboardingChain.next(joinCode) == paired`, `isNot(vow)` | `post_code_navigation_guard_test.dart` |
| AC3 | submit resolves `pairedRouteKey`, `vowRouteKey` findsNothing (vow builder registered so absence is an assertion, not a missing route) | `joincode_screen_test.dart` |
| AC4/AC5 | real `PairGateShell` → `PairGateUnpaired` renders `Key('pairing_stack')`; invite and join-code both pop back to it | `pairing_choice_screen_test.dart` |
| — | `pairingChoice` is a branching node with no forward successor | `post_code_navigation_guard_test.dart` |
| AC7 | source scan of invite/join-code screens for `VowScreen`, `OnboardingNode.vow`, `features/vow/` | `post_code_navigation_guard_test.dart` |

### Regression run

```
flutter test --no-pub --reporter failures-only test/core/navigation test/features/pairing
+172: All tests passed!
TEST_EXIT=0
```

(The `*** Request ***` / `*** Response ***` blocks in that run are Dio logging
from passing `pairing_repository_test.dart` cases, not failures.)

### Static analysis

```
flutter analyze --no-pub \
  test/core/navigation/post_code_navigation_guard_test.dart \
  test/features/pairing/presentation/invite_screen_test.dart \
  test/features/pairing/presentation/joincode_screen_test.dart \
  test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
Analyzing 4 items... No issues found! (ran in 1.7s)
ANALYZE_EXIT=0
```

Wider baseline for context: `flutter analyze --no-pub lib test` reports
`80 issues found.` — all `info` severity, all inside `mobile/lib/`
(78 × `prefer_initializing_formals`, 1 × `use_null_aware_elements`,
1 × `deprecated_member_use` on `SemanticsService.announce`). Zero issues in
`test/`. Pre-existing baseline, untouched by this story.

### AC7 — repo-wide vow grep

```
git grep -n -E "vow|Vow" -- mobile/test
```

Inside the pairing test tree, the only `vow` references are the negative
assertions added by this story:

```
mobile/test/features/pairing/presentation/invite_screen_test.dart:412: expect(find.byType(VowScreen), findsNothing);
mobile/test/features/pairing/presentation/joincode_screen_test.dart:496: expect(find.byKey(vowRouteKey), findsNothing);
```

Every other hit belongs to the legitimate post-pairing tail
(`chain_tail_edges_test.dart`, `onboarding_chain_test.dart`,
`love_contract_entry_mode_test.dart`, `vow_screen_test.dart`) or to the
`vowTaken` profile flag. No test anywhere expects vow as the immediate
post-code destination.

### `mobile/lib/` exclusion proof

```
git diff --name-only 4339ff0cb17f7e201e1c88ed87e6672f17e9845e
cupid-app-design-system/Cupid App.dc.html
cupid-app-design-system/Cupid Screens.dc.html
mobile/test/features/pairing/presentation/invite_screen_test.dart
mobile/test/features/pairing/presentation/joincode_screen_test.dart
mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart

git status --porcelain (untracked)
?? mobile/test/core/navigation/post_code_navigation_guard_test.dart
```

No `mobile/lib/` path appears. All six paths are inside the declared WriteScope.

## Open items for the review gate

1. AC6 has the design-reference render but no implemented-side capture, so there
   is still no pixel diff. The renderer blocker is resolved
   (`visual-fidelity/design-reference-pairingchoice-android.png`); only
   `DEVICE_CAPTURE_BLOCKED` remains, and a reviewer who needs pixel evidence
   must free emulator storage first. That is emulator provisioning/repair,
   outside the mobile-dev lane.
2. `mobile/lib/main_preview.dart` line ~219 still carries the seed note
   "No canvas counterpart; compared against AC4 chrome rules, not a design
   reference." for `pairingchoice`. P1 restored that counterpart, so the note is
   now stale — but the file is under `mobile/lib/` and out of write scope.
3. Title size (24px canvas vs `fontSize: 27`) and the EN **primary** CTA label
   differ between canvas and Flutter. Both are `mobile/lib/` changes, out of
   scope here.
