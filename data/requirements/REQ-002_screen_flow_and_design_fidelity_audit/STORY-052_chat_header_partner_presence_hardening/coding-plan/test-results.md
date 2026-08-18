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
