# Test Results: STORY-020 — Anti-Ghosting Chat Mount

## Phase P1 (mobile-dev)

`FLUTTER_SDK_PATH=$HOME/flutter`. Phase tasks 1-4 only; task 5's emulator
visual-audit capture is a separate follow-up and is **not** covered here.

### `flutter analyze` (scoped to P1-touched files)

Command: `cd mobile && flutter analyze
lib/features/chat/presentation/screens/chat_screen.dart
test/features/chat/presentation/chat_screen_ghost_state_row_mount_test.dart`

```
Analyzing 2 items...
No issues found! (ran in 1.8s)
```

Result: PASS. Scoped rather than repo-wide for the same reason recorded in
STORY-019 P3: the repo-wide run carries pre-existing, git-ignored
`mobile/build/ios/SourcePackages/checkouts/flutterfire/...` noise unrelated to
any file this phase touched.

### New mount test

Command: `cd mobile && flutter test --timeout 60s
test/features/chat/presentation/chat_screen_ghost_state_row_mount_test.dart`

```
00:00 +0: AC1: for a paired user with an eligible storm status the row renders below the Typing-Ghost bubble and above the composer
00:00 +1: AC2: a non-eligible storm status renders no copy and costs no layout against the unmounted baseline
00:00 +2: AC2: an unregistered GhostConfigRepository renders no copy and costs no layout
00:00 +3: AC3: a null partnerId keeps GhostStateRow out of the tree entirely
00:00 +4: AC4: chat contributes no second GhostStormCubit provider, so the row drives exactly one storm poll
00:00 +5: All tests passed!
```

Result: PASS (5/5).

Assertion summary, against `phase-P1-mobile-chat-ghost-state-mount.md` §4:

- **AC1 (seam ordering).** With `{eligible: true, penalty: emoji_storm}` and a
  `ghostTyping` event driving `GhostBubble` on screen, the test asserts
  `GhostStateRow`'s rect has non-zero height, its top edge is at or below
  `GhostBubble`'s bottom edge, and its bottom edge is at or above
  `ChatComposer`'s top edge. The "Seen, no reply yet" line and the
  "Fire Emoji Storm" CTA both render. The height assertion keeps the ordering
  check from passing vacuously against a collapsed row.
- **AC2 (idle zero-cost).** Two harnesses are compared in one test. The
  baseline is an unpaired user (row never mounted), whose `ChatComposer` rect
  is captured; the mounted harness is a paired user with
  `{eligible: false, penalty: emoji_storm}`. The mounted case asserts
  `GhostStateRow` is in the tree, its height is exactly `0`, the seen/no-reply
  and CTA copy are both absent, and `ChatComposer`'s rect equals the baseline
  rect. Since the composer sits below the row and the `Expanded` message
  region above it absorbs all remaining space, an unchanged composer rect plus
  a zero-height row proves no sibling shifted or resized.
- **AC2 (unregistered locator).** With `GhostConfigRepository` absent from
  `get_it` and an otherwise-eligible storm body, the row still mounts, renders
  zero height and no copy, issues no `storm-status` request at all, and raises
  no exception — the compatibility posture in `architecture/solution.md` §4.
- **AC3 (unpaired leak).** With `partnerStore.partnerId` null,
  `GhostStateRow` is absent from the tree entirely (`findsNothing`, not merely
  collapsed) and no `storm-status` request is issued.
- **AC4 (duplicate storm poll).** Exactly one `BlocProvider<GhostStormCubit>`
  is in the tree and exactly one `GET /ghost-config/storm-status/partner-1`
  request is issued, which is the observable consequence of leaving
  `ChatScreen`'s `MultiBlocProvider` unextended. The provider count is the
  runtime counterpart to the Reviewer's diff check that `MultiBlocProvider`
  is unchanged.

Two harness notes worth carrying forward, since neither is obvious from the
existing chat/anti-ghosting suites:

- `ChatPartnerStore.partnerId` is driven the way the phase file specifies —
  stub `Dio.httpClientAdapter`, answer `GET /users/me`, then
  `refreshFromServer()`. That await only completes on the real event loop, so
  harness construction runs inside `tester.runAsync`; awaiting it directly in
  the `testWidgets` body deadlocks against the fake-async zone (observed as a
  10-minute test timeout before the fix).
- `GhostBubble` runs a repeating cursor `AnimationController`, so
  `pumpAndSettle` never converges once the bubble is on screen. The tests pump
  a bounded number of short frames instead, which stays well short of the
  row's 60s poll tick.

### Existing suites (regression)

Command: `cd mobile && flutter test --timeout 60s test/features/chat
test/features/anti_ghosting`

```
00:02 +110: All tests passed!
```

Result: PASS (110/110). Covers
`test/features/anti_ghosting/presentation/ghost_state_row_test.dart` and the
full chat suite, confirming the widget itself and the surrounding chat
behavior are untouched.

No mobile e2e and no runtime startup smoke — both out of scope for this phase
per `phase-P1-mobile-chat-ghost-state-mount.md` §6 and the story's
`Startup Smoke: NOT_APPLICABLE`.

### Visual fidelity

PASS — full report at `../visual-fidelity/visual-fidelity-report.md`.

Both AC1 states captured live on `emulator-5554` (405x900):

- `../visual-fidelity/implemented-chat-eligibleStorm-emulator-5554.png` —
  amber timer icon + "Đã xem, chưa trả lời" caption and the "Bắn Emoji Storm"
  pill, between the Typing-Ghost bubble area and the composer.
- `../visual-fidelity/implemented-chat-noEligibleState-emulator-5554.png` —
  row collapsed, no caption, pill, spacing, or divider.

Pixel diff of the two: the only body difference is rows 717-766 (the row's own
50px band). Rows 40-716 (message list, privacy chip, bubbles) and rows 767-899
(composer, bottom nav) are identical, so placement is confirmed by position
and the idle state costs zero height. `../ux/uiux-spec.md` §4 satisfied.

An earlier pass reported this section BLOCKED: `ChatScreen` crashed under the
preview harness on `backendUserIdStore.backendUserId!`
(`chat_cubit.dart:77`), and `ChatPartnerStore` was never refreshed because the
preview bypasses `ChatEntryGate`. Both were fixed under the authorized
write-scope grant in `../architecture/solution.md` §7, which permits editing
`mobile/lib/preview/preview_session_bootstrap.dart` only. That file now runs
`POST /auth/login` and `ChatPartnerStore.refreshFromServer()` after the
existing Firebase sign-in, inside the existing credential guard and wrapped
catch-and-continue.

Grant verification: `flutter analyze lib/preview/preview_session_bootstrap.dart`
→ "No issues found!" (full `flutter analyze lib` shows 77 pre-existing `info`
lints, none in any file this story touched); both captures produced; and the
`login` preview still renders fully with `PREVIEW_EMAIL`/`PREVIEW_PASSWORD`
unset, so the unauthenticated no-op path is intact.

#### Dev-backend state mutation (authorized, traceable)

Executed against the dev backend on port 3005 per `../architecture/solution.md`
§7 "Backend state authorization", using only the pre-seeded preview accounts
`preview.dev.a@cupid.test` (A = `c0dd4c26-8196-4b4f-90e5-18fab08e21f4`) and
`preview.dev.b@cupid.test` (B = `14833d65-6ae0-45ee-befd-db2a9fb0ce58`). Public
HTTP API only; no backend code, schema, or seed-script change.

| # | Call | Result |
|---|---|---|
| 1 | `POST /ghost-config` as A, `{timeoutMinutes: 1, penalty: emoji_storm}` | config `a995b5ba-812a-4c2b-b0ea-98923455636b`, `pending_approval` |
| 2 | `PATCH /ghost-config/a995b5ba-.../approve` as B | same config, now `active` |
| 3 | `POST /messages` as A → B, `status: seen`, `readAt` backdated 10 min | message `9beea11a-59c5-42cc-8929-352daef0e14b`, `readAt=2026-08-12T12:05:45.330Z` |
| 4 | `GET /ghost-config/storm-status/{B}` as A | `{"eligible": true, "penalty": "emoji_storm"}` |

Left in place after capture, not reverted. Pre-mutation state was no active
config, no pending config, `{"eligible": false, "penalty": null}`, and four
seeded messages all `status=sent`; a later story needing the idle state again
can restore it by superseding or rejecting config `a995b5ba-...`.
