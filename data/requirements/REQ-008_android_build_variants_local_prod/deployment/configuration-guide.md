# REQ-008 Configuration Guide — Selecting A Backend Target

Scope: the Android host project in `mobile/android/` and the build-time config
in `mobile/lib/core/config/cupid_api_config.dart`.

REQ-008 does not change REQ-007's value contract. `CUPID_API_BASE_URL` and
`CUPID_ENV` are still the only base-URL config keys, and the values are still
`http://localhost:3000` and `https://api.cupidus.app`. What changes is *how a
developer supplies them*: an Android product flavor now provides the defaults,
so the common cases need no CLI flag at all.

Read this together with
`data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md`,
which remains authoritative for the key/value contract itself.

## How To Select A Backend Target

### Primary path — Android Studio Build Variants panel

`mobile/android/app/build.gradle.kts` declares one flavor dimension, `backend`,
with two flavors:

| Flavor | Variant (debug) | Resolves `CUPID_ENV` to | Resolves `CUPID_API_BASE_URL` to |
|--------|-----------------|-------------------------|----------------------------------|
| `local` | `localDebug` | `local` | `http://localhost:3000` |
| `prod` | `prodDebug` | `production` | `https://api.cupidus.app` |

Open **Build > Select Build Variant…** (or the Build Variants tool window),
pick `localDebug` or `prodDebug` for the `app` module, and run. No
`--dart-define` flag is needed, and no run-configuration edit is needed to
switch. A Gradle sync is required the first time after pulling this change.

The equivalent CLI form is:

```bash
flutter run --flavor prod
flutter build apk --debug --flavor prod
```

### How the flavor reaches Dart

No custom Gradle glue is involved. The Flutter Gradle plugin reads
`variant.flavorName` and passes it to `flutter assemble`, which injects
`FLUTTER_APP_FLAVOR` as a dart-define; the framework exposes it as the
compile-time const `appFlavor`. `CupidApiConfig` uses `appFlavor` only to pick
the **`defaultValue`** of the two existing `String.fromEnvironment` calls, so
the flavor drives REQ-007's mechanism rather than competing with it.

Because it is the same dart-define channel, the resolved values stay
compile-time `const`: they are not readable or writable at runtime and are not
exposed anywhere in the app UI.

### Explicit `--dart-define` override

An explicitly passed define still wins over the flavor-derived default.
Precedence is:

```text
explicit --dart-define  >  flavor-derived default  >  no-flavor local default
```

This is the escape hatch for origins no flavor covers, for example running
against the local backend from a device (`DEVSTACK_PORT_API`, see
`data/devops/system/runtime-command-registry.json`):

```bash
# Android emulator (10.0.2.2 is the emulator alias for the host loopback)
scripts/run-mobile.sh android -- --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020
```

REQ-007's documented production build still works exactly as written, with no
`--flavor` flag:

```bash
flutter build apk --debug \
  --dart-define=CUPID_ENV=production \
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app
```

Prefer `--flavor prod` for new work: it is shorter, IDE-visible, and cannot be
half-applied.

## The `default-flavor` Entry

`mobile/pubspec.yaml` carries:

```yaml
flutter:
  default-flavor: local
```

This is not cosmetic. Once `android/app` declares product flavors, Gradle stops
producing the unflavored `app-debug.apk`, while a `flutter run` / `flutter
build` that resolved no flavor still expects that exact filename and fails.
`default-flavor: local` makes every pre-existing invocation — bare
`flutter run`, `flutter build apk --debug`, existing scripts and IDE run
configs — resolve `local` and keep working unchanged. Removing this entry
breaks the local build path.

`--flavor` on the command line overrides it. `default-flavor` also applies to
the `flutter test` host, so `flutter test` sees `appFlavor == 'local'`.

## Startup Guard Failures

`CupidApiConfig.assertValidConfig()` still runs in `mobile/lib/main.dart`
immediately after `WidgetsFlutterBinding.ensureInitialized()`. It is
synchronous and performs no network probe. It throws `StateError` in these
cases:

- **Unknown `CUPID_ENV`** — anything other than `local` or `production`.
- **`CUPID_ENV=production` paired with any origin other than
  `https://api.cupidus.app`** — the REQ-007 check, unchanged.
- **The `prod` flavor resolving to a non-production environment** — for example
  `--flavor prod --dart-define=CUPID_ENV=local`. A build selected as production
  must not quietly talk to localhost.
- **A build declaring `CUPID_ENV=local` while pointing at
  `https://api.cupidus.app`** — the reverse failure: a local-labelled build must
  not quietly talk to production.

Note the deliberate asymmetry: the `prod` flavor constrains the environment, but
the `local` flavor does not. `local` is also the `default-flavor`, so it is what
an unflavored invocation resolves to and cannot be read as a deliberate "this is
a local build" assertion — REQ-007's define-only production command above
carries it. The reverse direction is instead covered by the fourth rule, which
is flavor-independent.

## Deliberate Limitation

Neither flavor sets `applicationIdSuffix` or `versionNameSuffix`, so
`applicationId` stays `com.snapsofts.cupid` for every variant.
`mobile/android/app/google-services.json` registers only that package name, and
suffixing it would break the Google Sign-In wiring fixed in BUG-20260823-001.

The cost: `local` and `prod` cannot be installed side by side on one device.
Switching Build Variant reinstalls over the other. This is accepted.
