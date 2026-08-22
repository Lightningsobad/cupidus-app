# REQ-007 — Requirement-Level Mobile Visual / Runtime Audit

Result: PASS

Scope: deferred story-review finding **D1 only** — observing the actual REST and
socket destination hosts for both build flavors. Everything already recorded
CLEAN in `STORY-001/review/review-report.md` (AC1/AC2/AC5, architecture
risk-surface gates, write scope, configuration guide, OQ discipline, and the
story-level runtime startup smoke) was not re-verified here.

- Date: 2026-08-22
- Lane: Mobile
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-007_mobile_app_production_api_build_config`
- Branch: `codex/REQ-007_mobile_app_production_api_build_config-integration`
- BaseHead / HEAD at audit time: `3db285c3967784524988ca9065a411176f4bfc19`
  (worktree clean, `git status --porcelain` empty)
- Toolchain: Flutter 3.44.1 stable / Dart 3.12.1, resolved from `$HOME/flutter/bin`
- Device: `emulator-5560`, `sdk gphone64 arm64`, Android 16 (API 36)
- App source unchanged by this audit: the requirement's write scope is
  `data/requirements/REQ-007_.../verification`, and nothing under `mobile/` was
  edited, patched, or instrumented.

## D1 Outcome

**D1 is CLOSED.** Both claims it required are now backed by observed traffic:

| D1 claim | Observed |
|----------|----------|
| Production build reaches `api.cupidus.app` | REST `POST https://api.cupidus.app/auth/login` → **HTTP 401** from `172.67.141.59:443`; socket `GET https://api.cupidus.app/socket.io/?EIO=4&transport=websocket` → **HTTP 101 Switching Protocols** |
| Local-dev build still reaches local dev | REST `POST http://localhost:3000/auth/login` → **HTTP 200** from `127.0.0.1:3000`; socket → **HTTP 101** plus a completed Engine.IO v4 + `joinRoom` exchange |
| No `localhost` / `10.0.2.2` attempt from REST **or** socket in the production build | Zero. Whole-process capture recorded exactly 2 HTTP requests and 2 TCP sockets, all to `api.cupidus.app` / `172.67.141.59:443` |

## 1. Method, And Why This One

The story-level smoke could not close D1 because both flavors sit on the pre-auth
Welcome screen, which issues no API call. Getting past it through the UI requires
a real Firebase credential (`AuthRepository.signInWithEmail` completes the
Firebase leg *before* `POST /auth/login` is ever issued), and no usable
credential for this project's Firebase tenant is available in this session.
Creating one would mean writing a real user into a live Firebase project — an
external side effect well outside this audit's scope.

So the transports were fired directly against **the app's own runtime
singletons**, over the Dart VM Service of the installed debug build, with no
source modification:

- `getIt<CupidApi>().dio` — the one shared `Dio` built by `CupidApiClient.create()`
  from `CupidApiConfig.baseUrl`, carrying the real interceptor pipeline.
- `getIt<RealtimeCoordinator>()` — the real coordinator holding the real
  `SocketTransport`, constructed in `service_locator.dart` with
  `url: CupidApiConfig.baseUrl`.

Destinations were then read from `dart:io`'s own profilers via the VM Service
(`ext.dart.io.getHttpProfile`, `ext.dart.io.getSocketProfile`), which record the
request URI, the resolved peer address/port, and the response status.

Driver script (scratch, not committed):
`/private/tmp/claude-503/-Users-alantravala-workspace-snapsofts-cupid-apps/6fb21090-c2d6-466c-aef0-bfe5353e0a71/scratchpad/probe.dart`

**Honest scope of this method.** The network calls, the client objects, the
compiled-in config, and the destinations are all genuinely the app's. What is
*not* covered is the UI journey that would normally reach them: no screen was
tapped past Welcome, and no authenticated session existed. This audit proves
*where the transports go*, which is what D1 asks; it does not prove that a real
end-user login flow succeeds against production. See §5.

## 2. Production Build (`CUPID_ENV=production`, `CUPID_API_BASE_URL=https://api.cupidus.app`)

Built and installed from the integration worktree with the same dart-defines as
`STORY-001/coding-plan/test-results.md` §B, onto a freshly uninstalled package:

```bash
adb -s emulator-5560 uninstall com.snapsofts.cupid
flutter run -d emulator-5560 --debug --start-paused \
  --dart-define=CUPID_ENV=production \
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app
```

`--start-paused` matters: the profilers were armed **221 ms after resume**, before
the app ran meaningful Dart code and long before any network I/O, so the capture
window below is the whole process lifetime rather than a post-startup slice.
That is what makes the "never attempts localhost" claim a real negative rather
than a gap in the recording.

Compiled-in config read live from the running isolate:

| Expression | Value |
|------------|-------|
| `CupidApiConfig.environment` | `production` |
| `CupidApiConfig.baseUrl` | `https://api.cupidus.app` |
| `getIt<CupidApi>().dio.options.baseUrl` | `https://api.cupidus.app` |

### 2a. REST transport

`getIt<CupidApi>().dio.post<Object?>('/auth/login')` →

```json
{
  "method": "POST",
  "uri": "https://api.cupidus.app/auth/login",
  "request.connectionInfo": {
    "localPort": 57130,
    "remoteAddress": "172.67.141.59",
    "remotePort": 443
  },
  "request.error": null,
  "response.statusCode": 401,
  "response.reasonPhrase": "Unauthorized"
}
```

A real TLS round trip to the live production origin: `401` is the server's own
answer to an unauthenticated login, not a client-side failure. It also shows the
error pipeline working end to end — `CupidErrorInterceptor` mapped it to
`UnauthorizedFailure` (visible in logcat, see §4).

### 2b. Socket transport

Seeded the room key and started the real coordinator:

```
getIt<BackendUserIdStore>().updateFromLoginResponse(<String, Object?>{'id': 'req007-audit-probe'})
getIt<RealtimeCoordinator>().start()
```

```json
{
  "method": "GET",
  "uri": "https://api.cupidus.app:0/socket.io/?EIO=4&transport=websocket",
  "response.statusCode": 101,
  "request.error": null
}
```

The websocket handshake **succeeded** (101 Switching Protocols) against
production. The `:0` in the URI is `socket_io_client`'s own URI normalization
artifact, not a port the app dialed — the socket profile below shows the actual
peer was port 443.

### 2c. Whole-lifetime socket profile — the negative evidence

```json
[
  {"id":"2","socketType":"tcp","address":"172.67.141.59","port":443,
   "readBytes":3920,"writeBytes":14792},
  {"id":"3","socketType":"tcp","address":"172.67.141.59","port":443,
   "readBytes":4180,"writeBytes":23630,"endTime":null}
]
```

Two TCP sockets for the whole run: one for REST, one held open by the live
websocket. `172.67.141.59` is one of the two A records for `api.cupidus.app`
(the other is `104.21.62.250`; Cloudflare).

Mechanical scan of the full production capture for forbidden destinations:

| Needle | Occurrences |
|--------|-------------|
| `localhost` | **0** |
| `10.0.2.2` | **0** |
| `127.0.0.1` | **0** |
| `:3000` | **0** |
| `api.cupidus.app` | 5 |

Identical result in an earlier, independent production run of the same build
(`probe-prod.out`): 0 / 0 / 0 / 0 and 5. Neither transport ever attempted a
local origin.

## 3. Local-Dev Build (No Defines)

Same worktree, freshly uninstalled, `flutter run -d emulator-5560 --debug` with
no dart-defines.

| Expression | Value |
|------------|-------|
| `CupidApiConfig.environment` | `local` |
| `CupidApiConfig.baseUrl` | `http://localhost:3000` |
| `getIt<CupidApi>().dio.options.baseUrl` | `http://localhost:3000` |

### 3a. Phase 1 — destination with nothing listening

No forwarder (`adb reverse --list` empty) and nothing on host port 3000:

```json
{"method":"POST","uri":"http://localhost:3000/auth/login",
 "request.error":"SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 36984"}
{"method":"GET","uri":"http://localhost:3000/socket.io/?EIO=4&transport=websocket",
 "request.error":"SocketException: Connection refused (OS Error: Connection refused, errno = 111), ..."}
```

(plus four further socket retries, all to the same origin). Both transports
target local dev and nothing else — no production host appears anywhere in this
capture.

### 3b. Phase 2 — real round trip against a listener on port 3000

The project's real backend was not running in this session and standing it up
needs a `devstack` tenant (Postgres/Redis/etc.), which is outside this audit's
scope. To still prove the local-dev path *completes* rather than merely *aims*
correctly, a minimal listener was bound to host `127.0.0.1:3000` and exposed to
the emulator with `adb reverse tcp:3000 tcp:3000` — the standard way an emulator
reaches a host dev server. It answers `POST /auth/login` with
`200 {"id":"local-dev-stub-user"}` and speaks enough Engine.IO v4 to complete the
socket handshake.

REST:

```json
{"method":"POST","uri":"http://localhost:3000/auth/login",
 "request.connectionInfo":{"localPort":32974,"remoteAddress":"127.0.0.1","remotePort":3000},
 "response.statusCode":200,"response.reasonPhrase":"OK","request.error":null}
```

Socket:

```json
{"method":"GET","uri":"http://localhost:3000/socket.io/?EIO=4&transport=websocket",
 "response.statusCode":101,"request.error":null}
```

```json
[
  {"id":"10","socketType":"tcp","address":"127.0.0.1","port":3000,
   "readBytes":228,"writeBytes":212},
  {"id":"11","socketType":"tcp","address":"127.0.0.1","port":3000,
   "readBytes":479,"writeBytes":421,"endTime":null}
]
```

Server-side log, confirming the app's own `Host` header and the full Socket.IO
handshake including the mandatory `joinRoom` subscription (ADR-012b):

```
GET /socket.io/?EIO=4&transport=websocket host=localhost:3000 from=127.0.0.1
  ws<- 40{"token":null}
  ws<- 420["joinRoom","req007-audit-probe"]
POST /auth/login host=localhost:3000 from=127.0.0.1
```

`token:null` is expected — no Firebase session exists, and ADR-012c has the
backend ignore the token today.

**Stated plainly:** this listener is a stub, not the real Nest backend. It proves
the local-dev build still resolves, connects to, and successfully exchanges data
with a server on the local dev origin for both transports. It does not
re-validate real backend behaviour, which is not what D1 asked for.

## 4. Emulator / Device Findings

- Welcome screen renders correctly under production defines (screenshot taken at
  both production runs): "Cupid", "Yêu nghiêm túc. / Chia tay đàng hoàng.",
  "Tiếp tục với Google", "Dùng email", debug banner. No crash, no red error
  screen.
- `FATAL EXCEPTION`: **0** lines in both flavors' logcat.
- `E/flutter` lines are present but are **this audit's own doing**: the probe
  calls `dio.post(...)` without awaiting it, so the mapped failure surfaces as an
  unhandled future. Production: `Unhandled Exception: DioException [bad response]
  ... status code of 401 ... Error: Instance of 'UnauthorizedFailure'`.
  Local-dev phase 1: `DioException [connection error] ... Connection refused ...
  Error: Instance of 'NetworkUnavailableFailure'`. Both are the *correct* mapped
  failures for the observed responses — not app defects, and not reachable this
  way through normal UI use.

### Out-of-scope observation (not a REQ-007 blocker)

Both flavors log an identical, pre-existing native plugin registration failure at
activity start:

```
E/GeneratedPluginRegistrant: Error registering plugin flutter_facebook_auth,
  app.meedu.flutter_facebook_auth.FlutterFacebookAuthPlugin
The SDK has not been initialized, make sure to call FacebookSdk.sdkInitialize() first.
```

It is flavor-independent (present with and without the dart-defines), unrelated
to the API base URL, and does not affect either transport's destination. Raised
here only so it is on the record; it is not this requirement's scope and was not
investigated further.

### Note for whoever owns `CupidApiConfig`

`CupidApiConfig.baseUrl`'s local default is `http://localhost:3000`, while the
file's own doc comment mentions `10.0.2.2` as the Android emulator's host alias.
On an Android emulator, `localhost` is the *device's* loopback, so a local-dev
build reaches a host-side dev server only via `adb reverse` (as used in §3b).
This is pre-existing behaviour frozen by AC2 and cleared in the story review —
recorded as an observation, not a finding, and deliberately not changed here.

## 5. What This Audit Does Not Claim

- No authenticated end-user journey was exercised: no Firebase credential was
  available, so login/pairing/chat were never driven through the UI.
- The production `401` and the production `101` prove reachability and correct
  destination, not that an authenticated production session behaves correctly.
- The local-dev round trip used a stub server, not the real backend.

## 6. Build / Test Gate (this session, this branch)

```bash
flutter test test/core/config/cupid_api_config_test.dart --reporter compact
```

Exit status: `0` — `00:03 +13: All tests passed!` (13/13).

Both flavors also compiled and installed successfully in this session as part of
the `flutter run` cycles above (production with defines, local-dev without).

## Emulator State Left Behind

`adb reverse --remove-all` executed (forward list empty), stub server stopped
(host port 3000 free again), app force-stopped. The production-flavor build
remains installed on `emulator-5560`, matching the state the story left.

Result: PASS
