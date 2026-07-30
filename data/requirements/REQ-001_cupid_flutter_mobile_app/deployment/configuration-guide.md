# REQ-001 Configuration Guide — Cupid Flutter Mobile App

Owning story: STORY-001 design_system (`architecture/solution.md` ADR-004a,
section 2 DevOps/environment contract). Later stories append to this file;
they do not create a second configuration guide.

## Build-Time Enablement Flags

Two `--dart-define` keys gate **exposure** of the light theme and the `en`
locale. Both default to `false`. Neither gates existence: light `ThemeData`
and `AppL10n` under `Locale('en')` are always built and always directly
constructible in tests, regardless of these flags (OQ5).

| Key | Default | Effect when `true` |
|---|---|---|
| `CUPID_ENABLE_LIGHT_THEME` | `false` | `MaterialApp.themeMode` follows the device (`ThemeMode.system`) instead of pinning `ThemeMode.dark`. |
| `CUPID_ENABLE_EN_LOCALE` | `false` | `MaterialApp.locale` follows the device locale (falling back to `vi` if unsupported) instead of pinning `Locale('vi')`. |

**Release/store builds must pass neither flag.** Passing neither key
reproduces the v1-launch default: dark theme, `vi` locale.

## QA Command — Exercising The Three Non-Default Combinations

Run each of the following from `mobile/` to manually exercise a
non-default combination on a connected device/simulator (there is no
in-app settings picker at v1 — this is a developer/QA override only):

```bash
# Light theme, vi locale
flutter run --dart-define=CUPID_ENABLE_LIGHT_THEME=true

# Dark theme, en locale (falls back to device locale, or vi if unsupported)
flutter run --dart-define=CUPID_ENABLE_EN_LOCALE=true

# Light theme, en locale
flutter run --dart-define=CUPID_ENABLE_LIGHT_THEME=true --dart-define=CUPID_ENABLE_EN_LOCALE=true
```

The default `flutter run` (no `--dart-define`) exercises the fourth,
default combination: dark theme, `vi` locale.

## Icon Asset Tree-Shaking Fallback

The bundled Material Symbols Rounded variable font is materially larger on
disk (~15MB) than the architecture estimate (~1-2MB) — see P1/P2 findings
in `coding-plan/phase-P1-theme-assembly.md` and `phase-P2-icons.md`. If a
release build fails or is rejected for size because Flutter's default icon
tree-shaking cannot analyze the variable-font glyph set, add
`--no-tree-shake-icons` to the build command:

```bash
flutter build apk --release --no-tree-shake-icons
```

Prefer the default (tree-shaking enabled) build first; only add this flag
if the build step reports a tree-shaking failure against
`MaterialSymbolsRounded`.

## API Client Generation (STORY-002)

- **Dart SDK floor normalization.** `mobile/tool/generate_api_client.sh`
  regenerates `mobile/openapi/cupid_api/` from the vendored OpenAPI spec on
  every run (whole-directory replace). The `openapi-generator-cli` `dart-dio`
  template hardcodes `environment: sdk: '>=3.5.0 <4.0.0'` in the generated
  package's `pubspec.yaml`, which is too low for the `json_serializable`
  version pub resolves today (its emitted `.g.dart` uses the "null-aware
  elements" syntax, which requires a higher Dart language version). The
  script patches the generated `sdk:` line to match `mobile/pubspec.yaml`'s
  own constraint (`^3.12.1` today) immediately after
  `openapi-generator-cli generate` and before `dart pub get`. This step is
  idempotent (re-running the generator never drifts the value) and exits
  non-zero with a clear error if the expected `sdk:` line is missing from
  either `pubspec.yaml`, so a future generator-template change cannot
  silently skip the patch. The patch lives only in the script — no file
  under `mobile/openapi/cupid_api/` is ever hand-edited.
- **Preconditions:** Node (tested with v20.x) and a JDK (tested with
  OpenJDK 17) are required to run `npx @openapitools/openapi-generator-cli`.
  The generator-cli version is pinned exactly (no `^`) in
  `mobile/openapitools.json` (currently `7.24.0`).
- **Regenerate the client:** `bash mobile/tool/generate_api_client.sh` from
  `mobile/` (see `mobile/openapi/README.md` for the two-step
  fetch/generate flow).

- **`CUPID_API_BASE_URL` dart-define.** The generated API client's base URL
  (`mobile/lib/core/config/cupid_api_config.dart`) is a build-time
  `String.fromEnvironment('CUPID_API_BASE_URL', defaultValue:
  'http://localhost:3000')`. Override it per run/build target, for example:

  ```bash
  # Android emulator: 10.0.2.2 is the emulator's loopback alias for the host machine
  flutter run --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000

  # Physical device or non-default backend host/port
  flutter run --dart-define=CUPID_API_BASE_URL=http://192.168.1.50:3000
  ```

## Firebase Project Setup (STORY-003)

Auth (`firebase_auth`) requires the mobile app's Firebase project to be the
**same** Firebase project the backend's `firebase-admin` SDK verifies tokens
against (`backend/src/main.ts` loads `backend/service-account.json`, which is
never committed — it is provisioned per environment). Mismatched projects
make every backend call 401 (`firebase-auth.strategy.ts` -> `verifyIdToken`
rejects tokens issued by a different project) — see `architecture/solution.md`
§4 Risk Surfaces ("Firebase project match") and §7 Risks.

**Setup procedure (run by whoever holds Firebase console/CLI access):**

1. Confirm the target Firebase project id: read the `project_id` field out of
   the environment's `backend/service-account.json` (not committed to this
   repo — obtain it from whoever provisions backend secrets).
2. Install the Firebase CLI and FlutterFire CLI if not already present:
   `npm install -g firebase-tools && dart pub global activate flutterfire_cli`.
3. From `mobile/`, run `flutterfire configure --project=<project_id>` and
   select the Android and iOS app entries (create them in the Firebase
   console first if they do not yet exist). This generates:
   - `mobile/android/app/google-services.json`
   - `mobile/ios/Runner/GoogleService-Info.plist`
   - `mobile/lib/firebase_options.dart`
4. Verify `project_id` in the generated files matches
   `backend/service-account.json`'s `project_id` exactly. Treat any mismatch
   as a hard blocker — do not proceed with a mismatched pair.
5. Run `flutter build apk --debug` from `mobile/` and confirm it compiles with
   Firebase initialized.

**Non-secret-but-environment-specific status:** `google-services.json`,
`GoogleService-Info.plist`, and `firebase_options.dart` are not bearer
secrets by themselves (they identify a Firebase project, not credentials),
but they are environment-specific (dev/staging/prod Firebase projects
differ) and must not be hand-edited — always regenerate via
`flutterfire configure` when the target project changes.

**Resolved 2026-07-30:** the environment blocker recorded above is closed.
`google-services.json` and `GoogleService-Info.plist` were supplied directly
(Firebase console/CLI access was unavailable in this sandbox, so
`flutterfire configure` was not run). Their `project_id`
(`gen-lang-client-0644970375`) was confirmed to match
`backend/service-account.json` exactly.

That check surfaced a second, unrelated mismatch: the supplied files
registered the app under package/bundle id `com.snapsofts.cupid`, while the
Flutter project's Android `applicationId` was `com.snapsofts.cupid_mobile`
and iOS `PRODUCT_BUNDLE_IDENTIFIER` was `com.snapsofts.cupidMobile`. Per
user decision, the app identifiers were changed to match the Firebase
registration (not the other way around):
- Android `applicationId` in `mobile/android/app/build.gradle.kts` ->
  `com.snapsofts.cupid`.
- iOS `PRODUCT_BUNDLE_IDENTIFIER` in
  `mobile/ios/Runner.xcodeproj/project.pbxproj` (all Debug/Release/Profile
  entries, Runner and RunnerTests) -> `com.snapsofts.cupid` /
  `com.snapsofts.cupid.RunnerTests`.

`mobile/lib/firebase_options.dart` was hand-derived from the two config
files (the `flutterfire`/`firebase` CLI remained unavailable). The Google
Services Gradle plugin (`com.google.gms.google-services`) was deliberately
**not** wired into `mobile/android/settings.gradle.kts` /
`mobile/android/build.gradle.kts` — those files are outside this story's
DevOps write scope, and per FlutterFire guidance the Dart-only
`Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
path does not require it for `firebase_core`/`firebase_auth`.
`google-services.json` is still present in `mobile/android/app/` for any
future native integration that needs it. `flutter build apk --debug`
succeeds without the plugin (verified below).

**Caveat for mobile-dev / whoever owns `mobile/lib/core/auth/**`:** this
project also depends on `google_sign_in: ^7.2.0`. That plugin's Android side
normally auto-resolves its OAuth web client id from a `default_web_client_id`
string resource that the Google Services Gradle plugin generates by
processing `google-services.json`. Since that plugin is not wired here,
Google Sign-In on Android may need an explicit `serverClientId` (the
`591718769021-3qll01ehinlrk3aaddl6l0fk4ordipte.apps.googleusercontent.com`
OAuth client from `mobile/android/app/google-services.json`) passed at
`GoogleSignIn` initialization in Dart, rather than relying on
auto-detection. This is outside DevOps write scope
(`mobile/lib/core/auth/**`) and is flagged here for the owning role to
verify at runtime, not fixed in this pass.

## FCM / APNs Setup And Test-Push Injection (STORY-004)

Background push delivery (Socket.IO fallback via FCM, ADR-012e/012f) needs one
manually supplied secret plus two native declarations already committed by
this story. **No new environment variable or `--dart-define` key is
introduced anywhere in this section** — the entire setup is Firebase-console
configuration plus a one-off injection call using files that already exist in
this repo.

### 1. APNs auth key (manual, never generated by an agent)

The APNs auth key authorizes Firebase to deliver pushes to iOS devices. This
step must be performed by a human with access to the Apple Developer account
and the Firebase console — it is a bearer credential and is never generated,
stored, or committed by an agent.

1. In the Apple Developer portal (`Certificates, Identifiers & Profiles` ->
   `Keys`), create a new key with the **Apple Push Notifications service
   (APNs)** capability enabled. Download the resulting `.p8` file once (Apple
   only allows one download) and record its Key ID and your Team ID.
2. In the Firebase console, open the project that matches
   `backend/service-account.json`'s `project_id`
   (`gen-lang-client-0644970375` — see "Firebase Project Setup" above) ->
   **Project settings** -> **Cloud Messaging** -> **Apple app configuration**
   -> **APNs Authentication Key** -> **Upload**. Supply the `.p8` file, Key
   ID, and Team ID.
3. Do not commit the `.p8` file or its Key ID/Team ID to this repository.
   Store them the same way `backend/service-account.json` is provisioned
   (per-environment secret, outside version control).

### 2. Native declarations already committed by this story

- **iOS** (`mobile/ios/Runner/Info.plist`): `UIBackgroundModes` contains
  `remote-notification`, which lets iOS wake the app to run the
  `firebase_messaging` background handler for silent (`content-available`)
  pushes. Per D1/ADR-002 the **Critical Alerts entitlement is deliberately
  absent** — reminders are ordinary notifications, never alarms that bypass
  Do Not Disturb.
- **Android** (`mobile/android/app/src/main/AndroidManifest.xml`): a
  `com.google.firebase.messaging.default_notification_channel_id` meta-data
  entry declares the default notification channel id
  **`cupid_realtime_default`**. This is the channel FCM uses for any message
  that does not specify its own `android.notification.channel_id`, and it
  covers both chat and alarm background pushes (ADR-012a: one shared
  socket/room registry, so both event families use the same background
  delivery path). A later mobile phase (P3, `fcm_transport.dart`) must use
  this exact literal string — do not introduce a second channel id.

### 3. FCM HTTP v1 test-push injection procedure

Because the backend has **no FCM dispatch** (R9 — `alarms.service.ts`,
`vibes.service.ts`, and `ghost-config.service.ts` all stub push delivery with
`console.log`; see `architecture/solution.md` ADR-012e), the background leg
of this story's coordinator cannot be exercised by triggering a real backend
event. It is instead exercised by injecting a message directly through the
**FCM HTTP v1 API**, authenticated with the existing
`backend/service-account.json` credential (zero backend change, A1-safe).

**This injection path is a temporary operator/QA procedure for this spike
only.** It exists solely because R9 leaves the backend with no dispatch path.
It must be replaced by server-side `admin.messaging()` calls (with real
device-token registration and storage) before background reminders can ship
to production — see R9 in `architecture/solution.md` §7.

Steps:

1. Obtain a target device's FCM registration token (logged locally by the
   mobile app during manual testing; never committed).
2. Mint an OAuth2 access token for `backend/service-account.json` scoped to
   `https://www.googleapis.com/auth/firebase.messaging` (for example via
   `google-auth-library`'s `GoogleAuth.getAccessToken()` in a throwaway
   Node/Python script, or `gcloud auth print-access-token
   --impersonate-service-account` if your tooling supports it).
3. POST the payload below to
   `https://fcm.googleapis.com/v1/projects/<project_id>/messages:send` with
   `Authorization: Bearer <access token>`, where `<project_id>` is the same
   Firebase project id used everywhere else in this guide.

Sample payload, shaped exactly per ADR-012f (`data` always present so the
coordinator's single parser handles both transports; Android `priority:
high`; iOS `content-available: 1` + `apns-priority: 5`; no Critical Alerts):

```json
{
  "message": {
    "token": "<device FCM registration token>",
    "data": {
      "cupid_event": "message",
      "cupid_event_id": "<server uuid, e.g. the Message.id under test>",
      "cupid_payload": "{\"senderId\":\"<uuid>\",\"content\":\"test push\"}"
    },
    "notification": {
      "title": "Cupid",
      "body": "You have a new message"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "cupid_realtime_default"
      }
    },
    "apns": {
      "headers": {
        "apns-priority": "5"
      },
      "payload": {
        "aps": {
          "content-available": 1
        }
      }
    }
  }
}
```

Omit `notification` entirely to send a silent data-only push (used for
ephemeral/dedup gate testing); keep it for reminder/alarm-style pushes where
the user must see something (D1).

### 4. Environment variables / `--dart-define` keys

None. This entire section — the APNs key upload, both native manifest
entries, and the injection procedure — uses only Firebase-console
configuration and the pre-existing `backend/service-account.json` credential.
No new `--dart-define` key or environment variable is introduced by this
story.

## i18n / ARB Notes

- `app_vi.arb` is the template locale (`mobile/l10n.yaml`
  `template-arb-file`). A key present in `app_vi.arb` but missing from
  `app_en.arb` is reported as a gap in `mobile/l10n-untranslated.json`
  (checked by `mobile/test/l10n/arb_parity_test.dart`), never silently
  falls back.
- `flutter gen-l10n` runs automatically as part of `flutter pub get`
  (`generate: true` in `pubspec.yaml`) — no manual codegen step is needed
  after a clean checkout.
- New string keys are added to both `app_vi.arb` and `app_en.arb` in the
  same change; screen stories own their own copy (STORY-001 ships only a
  smoke key set).
