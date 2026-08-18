# Test Results

## P0 — `GET /users/me` partner display name (Backend Developer)

- Date: 2026-08-18
- Files changed: `backend/src/modules/users/users.service.ts`,
  `backend/src/modules/users/users.controller.ts`,
  `backend/src/modules/users/users.service.spec.ts`

### Command: `npm test -- users.service`

```
PASS src/modules/users/users.service.spec.ts
  UsersService
    ✓ should be defined (5 ms)
    updateProfile
      ✓ should update user profile (2 ms)
    updateAvatar
      ✓ should update avatar url (1 ms)
    getProfileWithPartner
      ✓ resolves partnerDisplayName for a paired caller and keeps the caller identity keys unchanged (1 ms)
      ✓ returns null partnerDisplayName for an unpaired caller (1 ms)
      ✓ returns null partnerDisplayName when partnerId points at a deleted row (1 ms)
      ✓ returns null partnerDisplayName when the partner has a null displayName (1 ms)

Test Suites: 1 passed, 1 total
Tests:       7 passed, 7 total
```

Result: PASS (7/7, including the 3 pre-existing `updateProfile`/`updateAvatar`
cases unmodified).

### Required assertion evidence

- Unchanged-self-keys assertion (paired case):
  `expect(result.id).toEqual(caller.id)`,
  `expect(result.displayName).toEqual(caller.displayName)`,
  `expect(result.partnerId).toEqual(caller.partnerId)`,
  `expect(result.isGhostModeEnabled).toEqual(caller.isGhostModeEnabled)`.
- Null-case assertions:
  - Unpaired caller (`partnerId: null`): `expect(result.partnerDisplayName).toBeNull()`.
  - Dangling `partnerId` (partner row lookup resolves `undefined`):
    `expect(result.partnerDisplayName).toBeNull()`.
  - Partner row exists with `displayName: null`:
    `expect(result.partnerDisplayName).toBeNull()`.

### Command: `npm run build`

```
> nest build
```

Result: PASS (no type errors, no build output).

## P1 — `ChatPartnerStore` identity split (Mobile Developer)

- Date: 2026-08-18
- Files changed: `mobile/lib/features/chat/data/chat_partner_store.dart`,
  `mobile/lib/features/chat/presentation/screens/chat_screen.dart`,
  `mobile/lib/main_preview.dart`,
  `mobile/test/features/chat/data/chat_repository_test.dart`
- Not changed: `mobile/lib/core/di/service_locator.dart` — see phase-P1 §7.
- Flutter SDK is not on this machine's PATH; commands below were run through
  `/Users/alantravala/flutter/bin/flutter` per the runtime registry's
  `mobile-app.sdk.resolutionOrder`.

### Command: `flutter analyze --no-fatal-infos lib test`

```
Analyzing 2 items...
80 issues found. (ran in 2.8s)
```

Result: PASS — 0 errors, 0 warnings. All 80 are pre-existing `info` lints
(`prefer_initializing_formals`, one `use_null_aware_elements`, one
`deprecated_member_use`), identical in count and kind to the STORY-051 baseline.
The split's own line, `chat_partner_store.dart:12:42
prefer_initializing_formals`, is the same pre-existing constructor lint, shifted
one line by the widened dartdoc.

This run is also the AC "no `displayName` getter remains" gate at the call-site
level: with no compatibility alias left, any surviving reader would be a
compile error, and `lib` analyzes clean.

### Command: `flutter test test/features/chat/data/chat_repository_test.dart --plain-name "ChatPartnerStore" --reporter expanded`

```
00:00 +0: ChatPartnerStore refreshFromServer maps the two identity keys onto two distinct getters
00:00 +1: ChatPartnerStore a missing partnerDisplayName key reads as null, not an error
00:00 +2: ChatPartnerStore a null partnerDisplayName (unpaired, dangling, or nameless partner) reads as null
00:00 +3: ChatPartnerStore clearOnSignOut clears both names alongside partnerId and the ghost flag
00:00 +4: ChatPartnerStore no compatibility displayName getter survives the split
00:00 +5: All tests passed!
```

Result: PASS (5/5).

### Command: `flutter test test/features/chat`

```
00:01 +68: All tests passed!
```

Result: PASS (68/68) — the whole chat suite, i.e. the existing widget/cubit
coverage still passes after the rename.

### Command: `flutter test`

```
00:28 +1290 ~2: All tests passed!
```

Result: PASS (1290 passed, 2 skipped). Baseline before this phase was
`+1287 ~2`; the delta is exactly this phase's net +3 store cases (5 added, 2
mislabelled ones replaced).

### Command: `flutter build apk --debug`

```
Running Gradle task 'assembleDebug'...                              8.6s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

Result: PASS.

### Required assertion evidence

The distinct-values assertion (`chat_repository_test.dart`, "maps the two
identity keys onto two distinct getters"), run against a payload where the two
keys deliberately hold different names (`displayName: 'Minh'`,
`partnerDisplayName: 'Linh'`):

```dart
expect(store.selfDisplayName, 'Minh');
expect(store.partnerDisplayName, 'Linh');
expect(store.partnerDisplayName, isNot(store.selfDisplayName));
```

Sign-out teardown:

```dart
expect(store.partnerId, isNull);
expect(store.selfDisplayName, isNull);
expect(store.partnerDisplayName, isNull);
expect(store.isGhostModeEnabled, isNull);
```

No-alias guard (`contract-summary.md` §6 — a re-added alias would compile
silently, so the source text is asserted directly):

```dart
expect(source, contains('get selfDisplayName'));
expect(source, contains('get partnerDisplayName'));
expect(source, isNot(contains('get displayName')));
```

### The distinct-values assertion is not a tautology

Phase §4 requires that a test which would still pass if both getters read the
same key does not satisfy the AC. Verified by temporarily pointing
`_partnerDisplayName` at `body['displayName']` and re-running the group:

```
Expected: 'Linh'
  Actual: 'Minh'
   Which: is different.
...
00:00 +2 -3: Some tests failed.
```

Three of the five cases fail under that mutation (distinct-values, missing-key,
and null-value). The correct key was restored before the full-suite and build
runs above.

## Phase P2 — header trailing slot and partner presence chip

Date: 2026-08-18. Flutter SDK invoked as `/Users/alantravala/flutter/bin/flutter`
(not on PATH). All commands run from
`/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`.

### Gate commands

Lint / type-check:

```
$ flutter analyze --no-fatal-infos lib test
Analyzing 2 items...

80 issues found. (ran in 2.4s)
```

All 80 are pre-existing `info`-level lints (`prefer_initializing_formals`,
`use_null_aware_elements`, one `deprecated_member_use`). 0 errors, 0 warnings,
and the count is identical to the P1 baseline — this phase added no new
diagnostics. Result: PASS.

Full test suite:

```
$ flutter test
00:33 +1305 ~2: All tests passed!
```

Baseline was 1290 passing; this phase adds 15 (7 header + 8 chat). The 2
skipped are pre-existing. Result: PASS.

Build (runtime registry `mobile-app` `buildCommand`):

```
$ flutter build apk --debug
Running Gradle task 'assembleDebug'...                              8.1s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

Result: PASS.

Targeted suites (phase §6 verification strategy):

```
$ flutter test test/design_system/adaptive_widgets_test.dart --reporter expanded
00:00 +22: All tests passed!

$ flutter test test/features/chat/presentation/chat_design_fidelity_test.dart --reporter expanded
00:01 +19: All tests passed!

$ flutter test test/design_system/no_fork_guard_test.dart --reporter expanded
00:00 +1: All tests passed!
```

`adaptive_widgets_test.dart` was 15, now 22 (+7).
`chat_design_fidelity_test.dart` was 11, now 19 (+8).
`no_fork_guard_test.dart` is the ADR-004 gate: no `Color(0x`, `Colors.`,
`Platform.is`, or `defaultTargetPlatform` under `lib/features`, `lib/app`, or
`lib/core`. The new gradient lives in `design_system/tokens/`, so the guard
stays green.

Format:

```
$ dart format <7 touched files>
Formatted 7 files (5 changed) in 0.04 seconds.
```

Runtime startup smoke: NOT_APPLICABLE per
`data/devops/system/runtime-command-registry.json` (`mobile-app`).

Lint, full suite, and build were all re-run against the exact delivered source
after the D-1 revert described in `visual-fidelity/visual-fidelity-report.md`,
so the passing gates cover what is actually handed off, not a superseded tree.

### Required assertion evidence 1 — the unset-`trailing` tree-identity assertion

Phase §6 names this specifically. `CupidHeader` has 17 `lib/` consumers and 16
of them pass no `trailing`; AC5/AC6 require those 16 to build the tree they
built before. The Material branch's `trailing == null` arm hands back the
caller's *own* `actions` list instance rather than rebuilding an equal one, so
the assertion is a literal identity check:

```dart
expect(tester.widget<AppBar>(find.byType(AppBar)).actions, same(actions));
```

`same()` rather than `equals()` is the point — a structural-equality assertion
would also pass against a defensively rebuilt list, which is exactly the
regression this test exists to catch.

The iOS branch is guarded by the matching negative:

```dart
expect(
  headerRow(tester).children.whereType<SizedBox>(),
  isEmpty,
);
```

No gap widget, not merely a zero-width one. Phase §2 requires "no reserved
space, no gap" for the unset state.

Both branches are covered because a single-branch wiring silently ships a
platform-only feature. The width test loops the enum so neither branch can
regress alone:

```dart
for (final CupidPlatform platform in CupidPlatform.values) {
  testWidgets('${platform.name}: the title yields width only when the slot '
      'is populated', (WidgetTester tester) async {
    ...
    expect(populatedWidth, lessThan(unsetWidth));
  });
}
```

And `titleSemanticLabel` (deviation D-3) defaults to unset on both branches:

```dart
expect(tester.widget<Text>(find.text(longTitle)).semanticsLabel, isNull);
```

### Required assertion evidence 2 — the `VISUAL_FIDELITY` verdict

From
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-052_chat_header_partner_presence_hardening/visual-fidelity/visual-fidelity-report.md`,
line 3:

```
VISUAL_FIDELITY: PASS
```

Evidence pair, rendered/captured fresh for this story (STORY-040's pair was
not reused):

- `visual-fidelity/design-reference-chat-android.png` — 406x900, rendered from
  the locked canvas bundle
- `visual-fidelity/implemented-chat-emulator-5560.png` — 405x900, 135575 bytes,
  captured from the delivered source on `emulator-5560` through
  `mobile/lib/main_preview.dart` with P1's populated fixture
  (`selfDisplayName: 'Minh'`, `partnerDisplayName: 'Linh'`)

Captured at `--density=160` so 1dp = 1px. Key measurements corroborating the
widget assertions: pill 106x33 at x approximately 299-404 (expected 5+24+5 = 34 tall,
one row lost to antialiasing); width arithmetic 6+24+7+58+10 = 105 against a
measured 106, confirming `EdgeInsets.fromLTRB(6, 5, 10, 5)` and the 7dp gap;
right-cap inset 6px at 8px above centre against the radius-999 prediction of
16.5 − sqrt(16.5² − 13²) = 6.35; avatar gradient bbox 23x23; gradient ramp
(310,66) = (7,192,168) ≈ `#00C9A7` -> (326,76) = (101,75,186) toward `#7B2FBE`;
green dot peak (325,85) = (120,224,204) ≈ `#79E2CD`.

A cross-image per-pixel diff is not valid here — the reference renders inside a
bezel device frame at a different scale than the device-native capture — so the
report measures geometry against the design source's declared metrics instead.
Rationale is in §2 of that report.

### Mutation check A — the unset-slot guard is non-vacuous

A test that passes whether or not the gap is conditional would not satisfy
AC5/AC6. Verified by making the 10dp gap unconditional in **both** branches and
re-running the group. Exactly the two unset-state tests failed:

```
iOS:
Expected: empty
  Actual: WhereTypeIterable<SizedBox>:[SizedBox:SizedBox(width: 10.0)]
(line 338)

Material:
Expected: same instance as [Icon:Icon-[<'action'>](IconData(U+0E402))]
  Actual: [SizedBox:SizedBox(width: 10.0), Icon:Icon-[<'action'>](IconData(U+0E402))]
(line 368)

00:00 +5 -2: Some tests failed.
```

The conditional wiring was restored before the gate runs above.

### Mutation check B — the chip's partner identity is non-vacuous

`ux/uiux-spec.md` lines 17-37 warn that the chip is about the partner, not the
self, and that the reference PNG's self-looking "M" is a demo-toggle artifact.
A test that passes when the chip is fed the wrong half would miss exactly that
bug. Verified by pointing the chip at `widget.selfDisplayName ?? partnerName`
and re-running the chat header group. Three of the eight failed:

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "L": []>

Bad state: No element
  (WidgetController.getSize)

Expected: 'Linh đang online'
  Actual: 'Minh đang online'
   Which: is different. ... Differ at offset 0

00:00 +5 -3: Some tests failed.
```

The correct wiring was restored before the gate runs above.

The supporting fixture supplies the two identity halves independently, so a
header wired to the wrong getter cannot pass in the first place:

```dart
class _NamedPartnerStore extends ChatPartnerStore {
  _NamedPartnerStore({
    required super.dio,
    required this.self,
    required this.partner,
  });

  final String? self;
  final String? partner;

  @override
  String? get selfDisplayName => self;

  @override
  String? get partnerDisplayName => partner;
}
```

`chat_design_fidelity_test.dart` deliberately does **not** import
`ChatStrings`; it spells the expected title literal out (`'Minh ↔ Linh'`) so
the assertion cannot become a tautology against the production constant.
