# Fix Evidence: BUG-20260823-001 Android debug Google sign-in generic error

Bug: `BUG-20260823-001_android_debug_google_signin_generic_error`
Author: Justin-BugFixer (`bug-fixer`)
Date: 2026-08-23

## Outcome

`BUG_FIX_COMPLETE: NO`

The proven root cause from `diagnosis.md` is fixed and the fix is verified on
device: the Google sign-in flow no longer fails instantly, and the Credential
Manager account chooser now launches. However, the **user-visible symptom still
occurs** at a later step in the same flow, for a second, different reason that
is outside what can be resolved from this repository. Reported as a blocker
rather than closed, per the handoff's stop rule.

## Changed Files (2)

- `mobile/android/settings.gradle.kts` — declare
  `id("com.google.gms.google-services") version "4.4.4" apply false`
- `mobile/android/app/build.gradle.kts` — apply
  `id("com.google.gms.google-services")`

No Dart source changed. `git diff` on
`mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` is empty —
all temporary diagnostic instrumentation was reverted.

Pre-existing unrelated working-tree files, not touched by this bugfix:
`backend/.env.example`, `docs/production-readiness-checklist.md`,
`mobile/ios/Runner.xcodeproj/project.pbxproj`,
`mobile/ios/Runner/Base.lproj/Main.storyboard`.

## Fix Verification (configuration output)

The Gradle plugin now processes `google-services.json` and emits the resource
the `google_sign_in` Android plugin reads:

```
mobile/build/app/generated/res/processDebugGoogleServices/values/values.xml:3:
<string name="default_web_client_id" translatable="false">591718769021-3qll01ehinlrk3aaddl6l0fk4ordipte.apps.googleusercontent.com</string>
```

This is the direct negation of the diagnosed cause
(`serverClientId must be provided on Android`).

## Build Gate

Result: `PASS`

Command: `flutter build apk --debug`
Working dir: `/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`
Output tail: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

Run on the final tree with instrumentation removed. The newly applied
`com.google.gms.google-services` 4.4.4 plugin builds cleanly under AGP 9.0.1 /
Gradle 9.1.0. Pre-existing unrelated warnings (`sign_in_with_apple` applies KGP;
deprecated API notes) are unchanged by this fix.

Dart test suite not re-run: this change touches only Android Gradle build
configuration, so no Dart/test-visible code is in its blast radius.

## Runtime Startup Gate

Result: `PASS`
Shutdown: `PASS`

Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`)

- Build: `flutter build apk --debug` — PASS (above)
- Install: `adb -s HT7AH1A02116 install -r build/app/outputs/flutter-apk/app-debug.apk` → `Success`
- Start: `adb -s HT7AH1A02116 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
- Readiness poll (`dumpsys activity activities` / `ResumedActivity`), poll 1:
  ```
  ResumedActivity: ActivityRecord{4f780e1 u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t194}
  ```
- Rendered app: `evidence/postfix-04-runtime-startup.png`
- Shutdown: `adb -s HT7AH1A02116 shell am force-stop com.snapsofts.cupid`, then
  `pidof com.snapsofts.cupid` returned empty → `SHUTDOWN: PASS`

## Original Failure Recheck Gate

Result: `PARTIAL — original root cause cleared, reported symptom still occurs`
Same modality as original: `YES` (real Android debug build on device
`HT7AH1A02116`, real tap on "Tiếp tục với Google", rendered captures)

Steps: force-stop → `logcat -c` → `am start` → `input tap 540 1423` (Google
CTA) → capture → `input tap 540 1041` (account row) → capture.

| Step | Before fix | After fix |
| --- | --- | --- |
| Tap "Tiếp tục với Google" | Generic error snackbar within ~1s; **no** GMS activity in logcat | Credential Manager account chooser opens ("Choose an account to continue to cupid_mobile"); logcat shows `HiddenActivity`, `SignInCredentialChooserActivity`, `GoogleSignInActivity` |
| Select account | never reached | Generic error snackbar "Đã có lỗi xảy ra. Vui lòng thử lại." |

Captures:
- `evidence/prefix-01-generic-error-on-tap.png` (before)
- `evidence/postfix-01-welcome.png`
- `evidence/postfix-02-credential-manager-account-chooser.png` (after — the
  native flow now launches; this state was unreachable before the fix)
- `evidence/postfix-03-still-generic-error-after-account-pick.png` (after —
  residual failure)

The diagnosed `clientConfigurationError` is gone and does not recur. Temporary
instrumentation re-applied once to identify the *second* failure, then reverted,
produced:

```
08-23 21:00:09.657  7908  7908 I flutter : BUGPROBE2 GoogleSignInException code=GoogleSignInExceptionCode.canceled desc=[16] Account reauth failed. details=null
```

This is a different exception, from a later stage, on a code path that the
original defect prevented the app from ever reaching.

## Blocker

`BLOCKER: DEVICE_SIDE_OAUTH_CONSENT_REQUIRED`

Residual failure: Google Play Services returns `[16] Account reauth failed.`
for the on-device account `cacon194v3@gmail.com` after it is selected in the
Credential Manager chooser. Resolving this needs one or both of the following,
neither of which is available to `bug-fixer` in this session:

1. **Interactive device-side re-authentication** of that Google account
   (Android Settings → Accounts → re-enter the account password / device
   credential). This is an interactive consent step that cannot be automated
   with `adb input`, and it requires the account owner's credentials.
2. **Debug SHA-1 registration in the Google Cloud / Firebase project.**
   `mobile/android/app/google-services.json` still has **no** `client_type: 1`
   (Android) OAuth client and therefore no registered `certificate_hash`; its
   `oauth_client` array holds only the web client. Registering the debug signing
   certificate requires console access to project
   `gen-lang-client-0644970375` (project number `591718769021`), which this
   session does not have. The value to register, read from the local debug
   keystore, is:
   - package name: `com.snapsofts.cupid`
   - SHA-1: `0B:1C:DC:7B:7A:FC:5A:32:2E:6C:1B:1D:8E:1E:64:98:C0:32:66:29`
   - SHA-256: `C4:C1:07:48:A0:3D:94:82:A9:AC:DA:F9:82:0F:EC:CC:05:2D:6F:AA:F8:16:76:2C:10:72:6B:AA:F5:B3:79:5C`
   After registering, `google-services.json` must be re-downloaded and replaced,
   which will then also emit an Android `client_type: 1` entry.

Per the handoff's explicit instruction — *"If this needs credentials, a real
Google test account, a debug SHA-1 you cannot obtain, or device-side OAuth
consent that cannot be automated, stop and report the precise blocker rather
than guessing or faking a gate result"* — no gate result was fabricated and the
recheck is recorded as PARTIAL.

Recommended routing: DevOps (or the user directly) for the Google Cloud console
registration in (2), then re-run this same on-device recheck. Item (1) can be
tested first at no cost since it needs no console access.

## Residual Notes For Reviewer

- D-1 (non-blocking, out of scope): `_guard` in
  `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` collapses
  `GoogleSignInException`, `SignInWithAppleException`, and `PlatformException`
  into `UnexpectedAuthFailure` and logs nothing. The reported bug's expected
  behavior explicitly includes *"or surface a specific, actionable error"*, and
  this funnel is why a deterministic configuration error was indistinguishable
  from every other auth failure — diagnosing it required patching and
  reinstalling the app twice. The funnel is a deliberate REQ-002 STORY-001 ADR-7
  decision, so it was left intact rather than re-litigated here. Suggest a
  follow-up story to keep the ADR-7 public contract while logging the underlying
  provider exception in debug builds.
- D-2 (non-blocking, pre-existing, unrelated): the `validate-runtime-registry.sh`
  `PostToolUse` gate fires on every `Write` in this repo because `web-frontend`
  has an empty `dependsOn` and no `dependsOnRationale` field (the rationale is
  in `notes`, which the gate does not read). Not caused by this bugfix;
  devops-owned. Already recorded on BUG-20260817-001.
- The fix is a strict improvement and safe to keep even while the blocker is
  open: without it, Google sign-in cannot start at all on Android; with it, the
  native flow runs and any remaining failure is a real account/project condition.

---

# Recheck After Blocker Resolution

Date: 2026-08-23 (same day, after user action)
Session-Recovery: `YES`

## Outcome (supersedes the §Outcome section above)

`BUG_FIX_COMPLETE: YES`

The user resolved both external blocker items. Google sign-in now completes
end-to-end on the Android debug build. The reported symptom — the generic error
"Đã có lỗi xảy ra, hãy thử lại" on every attempt — no longer occurs.
`BLOCKER: DEVICE_SIDE_OAUTH_CONSENT_REQUIRED` is closed.

## Precondition Verification

`mobile/android/settings.gradle.kts` and `mobile/android/app/build.gradle.kts`
still carry this bugfix exactly as left; not re-applied. `git diff` on
`mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` is still
empty (no Dart change, no leftover instrumentation).

`mobile/android/app/google-services.json` changed (user-supplied) and now
contains two `client_type: 1` Android OAuth clients, the first with
`certificate_hash: 0b1cdc7b7afc5a322e6c1b1d8e1e6498c0326629` — matching the
debug SHA-1 reported in §Blocker. The `client_type: 3` web client is unchanged.

## Build Gate (re-run)

Result: `PASS`

Command: `flutter build apk --debug`
Output tail: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

The `processDebugGoogleServices` task re-ran against the new
`google-services.json` (generated `values.xml` mtime 21:09 vs. json mtime
21:07). `default_web_client_id` is unchanged, as expected — the Android OAuth
client is validated server-side by Google from package name + signing
certificate and is not emitted as an app resource.

## Runtime Startup Gate (re-run)

Result: `PASS`
Shutdown: `PASS`

Runtime id: `mobile-app`

- Install: `adb -s HT7AH1A02116 install -r build/app/outputs/flutter-apk/app-debug.apk` → `Success`
- Start: `adb shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
- Readiness poll 1:
  ```
  ResumedActivity: ActivityRecord{7a1935d u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t195}
  ```
- Rendered welcome screen: `evidence/recheck-01-welcome.png`
- Shutdown: `adb shell am force-stop com.snapsofts.cupid`, then
  `pidof com.snapsofts.cupid` empty → `SHUTDOWN: PASS`

## Original Failure Recheck Gate (re-run)

Result: `PASS`
Same modality as original: `YES` (real Android debug build, device
`HT7AH1A02116`, real taps through the full flow, rendered captures)

Steps: `am start` → `input tap 540 1423` ("Tiếp tục với Google") →
`input tap 540 1041` (account row) → `input tap 763 1365` ("Agree and share").

| Stage | Original report / prior recheck | This recheck |
| --- | --- | --- |
| Tap "Tiếp tục với Google" | Generic error in ~1s, no GMS activity | Credential Manager chooser opens (`evidence/recheck-02-account-chooser.png`) |
| Select account | never reached / `[16] Account reauth failed.` → generic error | OAuth consent screen "Allow Google to sign you in to cupid_mobile" (`evidence/recheck-03-consent-screen.png`) |
| Accept consent | never reached | **Firebase sign-in succeeds** |

Decisive log evidence — Firebase Auth authenticated a real user:

```
08-23 21:11:08.428  9571  9823 D FirebaseAuth: Notifying id token listeners about user ( wh4Ekn1orPUtazzUvgEi0rnxdbq1 ).
08-23 21:11:08.428  9571  9823 D FirebaseAuth: Notifying auth state listeners about user ( wh4Ekn1orPUtazzUvgEi0rnxdbq1 ).
```

The full chain now works: Credential Manager → Google ID token →
`signInWithCredential` → authenticated Firebase user. No
`GoogleSignInException` occurs at any stage, and the generic
`UnexpectedAuthFailure` message does not appear anywhere in the flow.

This gate required no instrumentation — unlike every prior attempt, the flow
succeeds and is observable from stock `FirebaseAuth` logging.

### Post-sign-in message is a different subsystem, not this bug

`evidence/recheck-04-signin-ok-backend-unreachable.png` shows a snackbar
"Không có kết nối mạng" a moment after sign-in succeeds. This is **not** the
reported generic error and **not** a Google sign-in failure. Logcat shows it
originates from the app's own backend call, made after Firebase auth had already
succeeded:

```
08-23 21:11:08.523 I flutter : uri: http://localhost:3000/auth/login  method: POST
08-23 21:11:08.677 I flutter : DioException [connection error]: The connection errored: Connection refused
08-23 21:11:08.677 I flutter : Error: SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 48880
```

The device's own network is healthy, so the "no network" copy is misleading but
accurate in kind (a connection error): `dumpsys connectivity` reports the active
WiFi network as `VALIDATED` with `INTERNET`, and
`ping -c 3 firebaseinstallations.googleapis.com` from the device returned
`3 packets transmitted, 3 received, 0% packet loss`. The backend at
`localhost:3000` simply is not running, and `localhost` on a physical device
resolves to the device itself, never the developer machine.

Against the bug's stated expected behavior — *"should complete Google sign-in
(or surface a specific, actionable error) instead of always failing with the
generic fallback error message"* — Google sign-in completes. Gate PASS.

## Final Gate Summary

| Gate | Result |
| --- | --- |
| Pre-Fix Reproduction | `REPRODUCED` (same modality) |
| Build | `PASS` |
| Runtime Startup | `PASS` |
| Shutdown | `PASS` |
| Original Failure Recheck | `PASS` (same modality) |

Changed files remain exactly 2, both Android Gradle configuration:
`mobile/android/settings.gradle.kts`, `mobile/android/app/build.gradle.kts`.
(`mobile/android/app/google-services.json` also changed, but that is the user's
console re-download, not an edit by this bugfix.)

## Additional Residual Notes For Reviewer

- D-3 (non-blocking, out of scope, newly observed): the mobile app calls its
  backend at `http://localhost:3000/auth/login`. On a physical device
  `localhost` is the device itself, so this base URL can never reach a developer
  machine — sign-in succeeds but the session hand-off to the backend always
  fails there. Possibly related to REQ-007 (mobile production API build config).
  Worth a separate bug or story; deliberately not changed under this bug's scope.
- D-4 (informational): the recheck authenticated a real Firebase user
  (`wh4Ekn1orPUtazzUvgEi0rnxdbq1`, `cacon194v3@gmail.com`) in project
  `gen-lang-client-0644970375`, and granted the app an OAuth consent on that
  Google account. This was the user-requested verification and is intentionally
  left in place as evidence; remove it from Firebase Auth if a clean state is
  wanted.
- D-1 (from the original pass) still stands and is reinforced: `_guard` logs
  nothing, which is why each stage of this bug needed instrumentation to
  diagnose. Once the flow worked, stock `FirebaseAuth` logging was sufficient —
  the app's own auth layer contributed no diagnostics at any point.
