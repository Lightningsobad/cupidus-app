# REQ-007 Configuration Guide — Mobile App API Origin

Scope: the Flutter app in `mobile/`. This guide records the build-time values
that select which API origin a build talks to, the exact build invocations for
each flavor, and what the startup guard failure means.

## Build-Time Values

Both values are `--dart-define` keys read as compile-time constants in
`mobile/lib/core/config/cupid_api_config.dart`. Neither is readable or writable
at runtime, and neither is exposed anywhere in the app UI: selecting a flavor is
a build-time decision only.

| Key | Values | Default | Meaning |
|-----|--------|---------|---------|
| `CUPID_API_BASE_URL` | any origin | `http://localhost:3000` | Origin used by the REST client (`core/network/cupid_api_client.dart`) **and** the realtime socket (`core/di/service_locator.dart`, `SocketTransport.url`). One define moves both transports. |
| `CUPID_ENV` | `local` \| `production` | `local` | Declares which flavor this binary is. Checked against the resolved `CUPID_API_BASE_URL` at startup. |

The production origin is `https://api.cupidus.app`. In code it exists once, as
`CupidApiConfig.productionBaseUrl`; do not repeat the literal at call sites.

There are no Android `productFlavors` and no iOS scheme/xcconfig variants. The
"production flavor" is exactly the documented pair of defines below.

## Local-Dev Build (Unchanged)

Pass no defines. The compiled-in defaults (`local` + `http://localhost:3000`)
apply and the startup guard is a no-op:

```bash
flutter build apk --debug
flutter run
```

Running against the local backend from a device still needs the host-reachable
form of the loopback address and the devstack-reserved API port
(`DEVSTACK_PORT_API`, see `data/devops/system/runtime-command-registry.json`):

```bash
# Android emulator (10.0.2.2 is the emulator alias for the host loopback)
scripts/run-mobile.sh android -- --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020

# iOS simulator
scripts/run-mobile.sh ios -- --dart-define=CUPID_API_BASE_URL=http://127.0.0.1:21020
```

Those local overrides keep `CUPID_ENV` at its `local` default, so the guard
accepts any origin: it only constrains builds that declare themselves
production.

## Production Build

Pass both defines together. Omitting either one is an error, not a fallback:

```bash
flutter build apk --debug \
  --dart-define=CUPID_ENV=production \
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app
```

Substitute the release/AAB/iOS build target as needed; the two defines are
identical for every target. Release signing and store upload are out of scope
for REQ-007.

## Startup Guard Failure

`CupidApiConfig.assertValidConfig()` runs in `mobile/lib/main.dart` immediately
after `WidgetsFlutterBinding.ensureInitialized()` — before `Firebase.initializeApp`
and before `setupServiceLocator()`, so a misconfigured production build throws
before any transport exists and cannot make a single network call. It is
synchronous, allocation-light, and performs no network probe.

It throws `StateError` in exactly two cases:

- **Unknown `CUPID_ENV`.** Anything other than `local` or `production`, for
  example a typo'd `--dart-define=CUPID_ENV=prod`.
- **`CUPID_ENV=production` paired with any origin other than
  `https://api.cupidus.app`.** This is the case that matters: because
  `CUPID_API_BASE_URL` defaults to `http://localhost:3000` and that default is
  frozen (the local-dev build path must not change), a production build that
  forgets or mistypes the URL define would otherwise compile cleanly, install,
  and quietly talk to localhost. The guard turns that silent fallback into a
  loud crash on launch. A cleartext `http://api.cupidus.app` and a wrong host are
  rejected by the same check.

If a build crashes on launch with a `StateError` naming `CUPID_ENV`, the build
command is wrong, not the app: rebuild with both production defines exactly as
written above. There is no degraded mode and no retry — a build either declares
a consistent environment or does not run.
