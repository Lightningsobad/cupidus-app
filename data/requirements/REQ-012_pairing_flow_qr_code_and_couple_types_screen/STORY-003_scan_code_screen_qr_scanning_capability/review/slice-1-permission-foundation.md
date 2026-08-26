# STORY-003 Scoped-Slice Review — Slice 1: Permission Foundation + Platform Config (P1)

Reviewer: Iris-QC
Mode: scoped-slice (1 of 3)
RunId: RUN-REQ-012-STORY-003-reviewer-slice1
Worktree: `story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability`
BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`
Worktree HEAD at review: `a4ddbe1301014adbb4c706f81d59de06050a4204` (one commit past
BaseHead, adding only `review/review-report.md`; no `mobile/` source in it, excluded
per handoff)

This is a bounded slice, not a story gate. It records PASS / FAIL / UNVERIFIED for
AC1, the permission-denied half of AC3, and the `permission_handler` pin
consistency check only. No story Outcome, no DONE recommendation, no runtime-smoke
or `_InvalidCard` radius opinion — those belong to Slice 3 and Final Synthesis.

## Slice Scope Confirmation

`git -C <Worktree> diff --name-only <BaseHead> -- mobile/` returns 16 files. The 6
in this slice were confirmed present in that list and reviewed in full:

1. `mobile/lib/features/pairing/presentation/camera_permission_gate.dart`
2. `mobile/test/features/pairing/presentation/camera_permission_gate_test.dart`
3. `mobile/android/app/src/main/AndroidManifest.xml`
4. `mobile/ios/Runner/Info.plist`
5. `mobile/pubspec.yaml`
6. `mobile/pubspec.lock`

The other 10 files were not opened.

## AC1 — Permission requested at scan initiation; proceeding only after granted

Verdict: **PASS** (at the foundation seam this slice owns)

- Timing matches OQ1's resolution (request at tap, no earlier soft-ask). The gate
  exposes a single `status()` call rather than a `check`/`request` pair, and the
  reason is recorded at
  `mobile/lib/features/pairing/presentation/camera_permission_gate.dart:22-29`.
- `PermissionHandlerCameraGate.status()` prompts only while the OS status is
  undecided, so a second scan on an already-granted permission is promptless
  (`camera_permission_gate.dart:35-44`).
- The mapping switch is **exhaustive with no permissive default** —
  `camera_permission_gate.dart:45-59` enumerates all six upstream
  `PermissionStatus` values, so a future `permission_handler` enum addition is a
  compile error rather than a silent fall-through to `granted`. This is the single
  most important property for AC1 and it holds.
- `permission_handler` types do not leak past the seam: the public surface is
  `CameraPermissionState` + `CameraPermissionGate`
  (`camera_permission_gate.dart:8-33`), so the scan cubit, widgets and the preview
  harness stay platform-channel-free.
- Android runtime permission is declared:
  `mobile/android/app/src/main/AndroidManifest.xml:14`
  (`<uses-permission android:name="android.permission.CAMERA" />`). Without it the
  runtime request is auto-denied.
- iOS usage description is present:
  `mobile/ios/Runner/Info.plist:29-30`, and the string is scan-specific
  ("scan your partner's pairing QR code") rather than a generic purpose string.
- Test evidence **independently reproduced** by this review, not merely read:
  `flutter test test/features/pairing/presentation/camera_permission_gate_test.dart`
  → `00:00 +11: All tests passed!`, 11/11, matching
  `coding-plan/test-results.md:47-60` line for line.

Scope boundary (not a defect of this slice): AC1's "proceeding is possible only
after permission is granted" is *enforced* by the consumer of this gate in
`scan_code_cubit.dart`, which is Slice 2's file. This slice verifies only that the
gate supplies a correct, non-permissive, non-collapsing signal for that consumer to
branch on. Slice 2 must confirm the cubit actually refuses to open the camera on
every non-`granted` state.

## AC3 — Permission-denied half (denied / unavailable → clear message, no dead end)

Verdict: **PASS** (permission-signal half only)

- `denied` and `permanentlyDenied` are modeled as **distinct** states and are never
  collapsed (`camera_permission_gate.dart:11-17` for the intent,
  `:53-55` for the mapping). This is what allows a re-askable denial and a
  settings-only block to show different copy instead of one dead-end message.
- The State-6 escape hatch exists and is real, not a stub: `openSettings()` →
  `openAppSettings()` at `camera_permission_gate.dart:62-63`, asserted to actually
  reach the platform at
  `mobile/test/features/pairing/presentation/camera_permission_gate_test.dart:103-107`.
- `limited`/`provisional` map to `granted`, explicitly so they cannot become an
  accidental dead end (`camera_permission_gate.dart:50-52`, asserted at
  `camera_permission_gate_test.dart:91-100`).
- iOS parental-control `restricted` maps to `unavailable` rather than to a denial
  the user is invited to "retry" — correct, since the user cannot grant it
  (`camera_permission_gate.dart:56-58`).
- Cameraless devices can still install and fall back to manual entry:
  `AndroidManifest.xml:15-17` declares `android.hardware.camera` with
  `android:required="false"`.

Scope boundary: the UI half of AC3 — that the denied/unavailable message renders
clearly and that manual code entry remains usable on the same screen — is Slice 3's
job and was not assessed here.

## `permission_handler` pin consistency across the three documents

Verdict: **FAIL (documentation only; no code or lock defect)**

Ground truth in the shipped tree:

| Source | Declared | Resolved |
|---|---|---|
| `mobile/pubspec.yaml:60` | `permission_handler: ^12.0.1` | — |
| `mobile/pubspec.lock:943-950` | — | `12.0.3` |
| `mobile/pubspec.lock:951-958` | — | `permission_handler_android` `13.0.1` |
| `mobile/pubspec.lock:959-966` | — | `permission_handler_apple` `9.6.1` |

- `mobile/pubspec.yaml:60` — **consistent**. `^12.0.1` is the intended pin, and
  `12.0.3` is inside that range.
- `deployment/configuration-guide.md:21` and `:28-32` — **consistent**. Records
  `^12.0.1` → `12.0.3` → `permission_handler_android 13.0.1`, exactly matching the
  lock, plus a "Why `permission_handler` is held at 12.x" section at `:34-59` with
  the lift condition.
- `coding-plan/test-results.md:20-26` — **INCONSISTENT**. The P1 "A1 closure —
  dependency resolution" table is introduced at `:16` as *"Resolved versions, quoted
  from `mobile/pubspec.lock`"* and then states:
  - `:21` `| `permission_handler` | `"13.0.1"` |`
  - `:22` `| `permission_handler_android` | `"14.0.0"` |`
  - `:23` `| `permission_handler_apple` | `"9.6.1"` |`

  Lines `:21` and `:22` are **not** what the shipped `pubspec.lock` contains
  (`12.0.3` and `13.0.1`). The table is a pre-downgrade snapshot that was never
  corrected after the P4 build gate forced the pin back.

The rationale itself is properly recorded — `coding-plan/test-results.md:394-412`
documents the `compileSdk = 37` / `android-37` platform-not-found Gradle failure,
the fact that raising the app's own `compileSdk` cannot help because the plugin pins
its own, and that this is a version pin on the same package rather than a package
substitution. `coding-plan/master-plan.md` §6 note A1 is referenced as the origin.

So the *decision* is sound and well-evidenced; only the P1 evidence table is stale.
This matters because P1 is precisely the section a reviewer or a future engineer
reads to learn which `permission_handler` shipped, and it currently states a version
that was rejected by the build gate.

Required correction (documentation, one edit): update
`coding-plan/test-results.md:20-26` to the shipped `12.0.3` / `13.0.1` values, or
annotate the table in place as superseded with a pointer to `:394-412`.

## Platform configuration (Android + iOS)

Verdict: **PASS**

- `AndroidManifest.xml:8-17` — `CAMERA` permission plus optional camera feature,
  with a comment recording why `required="false"`. The pre-existing
  `READ_MEDIA_IMAGES` declaration (`:2-7`) and the FCM channel meta-data (`:49-56`)
  are untouched, so no regression to STORY-013 or ADR-012f config.
- `Info.plist:29-30` — `NSCameraUsageDescription` added; the pre-existing
  `NSPhotoLibraryUsageDescription` (`:31-32`) and all scene/orientation keys are
  untouched.
- iOS `PERMISSION_*` compile-time macros: **verified, no action needed**.
  `deployment/configuration-guide.md:116-123` claims this repository checks in no
  `mobile/ios/Podfile`, so the `PERMISSION_CAMERA=1` allowlist entry has nothing to
  apply to today. Independently confirmed: `find mobile/ios -maxdepth 1 -name
  'Podfile*'` returns no match. The guide correctly leaves a forward-looking
  instruction for whoever later commits a Podfile. This was worth checking because a
  missing `PERMISSION_CAMERA=1` in a trimmed Podfile silently resolves the camera
  request to denied on iOS only — an invisible, device-only failure.
- `mobile/pubspec.yaml` edit is append-only, exactly two lines added
  (`git diff` confirms `+2 -0`), which keeps the STORY-002 integration merge on the
  same file free of whitespace noise.

## Static analysis evidence

Verdict: **PASS (as recorded)**

`coding-plan/test-results.md:70-90` records
`flutter analyze lib/features/pairing test/features/pairing` → 6 issues, all
pre-existing `prefer_initializing_formals` infos in files this phase did not touch
(`joincode_cubit.dart:40:8`, `pair_gate_cubit.dart:45:7`,
`joincode_screen.dart:66:8`, `pairing_choice_screen.dart:28:8` and `:29:8`,
`waiting_screen.dart:28:8`). Zero issues attributable to
`camera_permission_gate.dart` or its test. Not re-run by this slice; the targeted
test re-run above was the higher-value independent check.

## Required input not found

- **UNVERIFIED**: the handoff's `Checkpoint:`
  `data/requirements/REQ-012_.../STORY-003_.../scrum-master-checkpoint.md` does not
  exist — not in the worktree and not in the control checkout at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/...` (confirmed by `find`).
  This did not block any slice-1 conclusion, since every verdict above rests on
  source, lock, and test evidence rather than on checkpoint state. Flagged for Scrum
  Master because the other two slices carry the same `Checkpoint:` value and will
  hit the same absence.

## Residual risks (non-blocking, for Final Synthesis)

1. **`CameraPermissionState.unavailable` may have no real producer on Android.**
   Within this slice, `unavailable` is only ever reached from
   `PermissionStatus.restricted` (`camera_permission_gate.dart:56-58`), which is an
   iOS parental-controls value. A cameraless Android device does not report
   `restricted`. If UX State 7 ("no usable camera") is meant to be reachable on
   Android, its producer must be `mobile_scanner`'s start failure inside
   `scan_code_cubit.dart` — Slice 2 should confirm that path exists, otherwise
   State 7 is iOS-only in practice.
2. **Test-only dependency on a transitive package.**
   `camera_permission_gate_test.dart:5-9` imports
   `permission_handler_platform_interface` with
   `// ignore: depend_on_referenced_packages` because `permission_handler` does not
   re-export `PermissionHandlerPlatform`. The reason is documented in-file and the
   version is locked (`4.4.0`), so this is accepted, but a future
   `permission_handler` major bump that changes the platform interface can break the
   test's build rather than its assertions.
3. **Manifest/plist assertions are substring checks.**
   `camera_permission_gate_test.dart:135-141` and `:149-155` use
   `contains('android.permission.CAMERA')` / `contains('NSCameraUsageDescription')`.
   These would still pass if the declaration were commented out rather than removed.
   Low severity — verified that no comment in the current manifest contains the
   literal `android.permission.CAMERA` string, so there is no false positive today.

## Slice Result

| Item | Verdict |
|---|---|
| AC1 — permission requested at scan initiation, non-permissive mapping | PASS |
| AC3 — permission-denied half (denied / permanently-denied / unavailable signal) | PASS |
| `permission_handler` `^12.0.1` pin consistency (3 documents) | FAIL — `coding-plan/test-results.md:20-26` stale |
| Android + iOS platform configuration | PASS |
| Targeted test evidence (`camera_permission_gate_test.dart`) | PASS — independently re-run, 11/11 |
| Static analysis evidence | PASS (as recorded) |
| Story checkpoint input | UNVERIFIED — file absent in both checkouts |

One documentation FAIL, no code defect found in this slice's 6 files.

REVIEW_SLICE_COMPLETE: YES
