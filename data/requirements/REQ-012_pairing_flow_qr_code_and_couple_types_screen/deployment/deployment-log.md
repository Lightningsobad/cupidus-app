# Deployment Log: REQ-012 Pairing flow QR code & Couple Types screen redesign

## Entry 1 — 2026-08-26 — Ad hoc pre-DONE local inspection run (NOT the post-DONE gate)

- Type: **Ad hoc `development-local` manual inspection run**, requested directly
  by the user to visually inspect STORY-003's live scan-code / QR-scanning flow
  on an already-open AVD emulator. This is **not** the automatic
  post-requirement-DONE deployment trigger (skill rule 7) — REQ-012 is still
  `IN_PROGRESS` (STORY-001/STORY-002 DONE+merged; STORY-003 Reviewer CLEAN +
  visual-fidelity PASS, but paused at its `story_master.md` DONE-gate write
  pending a Scrum-Master-owned decision on `guard-story-done-evidence.sh
  [DONE_WITHOUT_VISUAL_EVIDENCE]`, unrelated to this deploy request).
  `req_master.md` "Deployment Status" is deliberately **not** updated to a
  completed-requirement deployment by this entry.

### backend-api

- Runtime id: `backend-api` (per `data/devops/system/runtime-command-registry.json`).
- Found **already running** from a prior session: `node` PID `68346`, started
  Mon 24 Aug 17:30:20 2026, listening on `127.0.0.1:21020`. Reused rather than
  restarted (no port conflict, already healthy) — did not spawn a duplicate
  `npm run start:dev` process.
- Live readiness re-verified this run: `GET http://127.0.0.1:21020/api-docs-json`
  -> `200`.
- Port resolution re-verified live (not assumed from a stale doc): `devstack
  port claim --role api --project cupid-apps` -> `21020`; `devstack info
  cupid-apps` `DEVSTACK_PORT_API` -> `21020`. Matches the registry's recorded
  value — no drift.
- Run from the control checkout (repo root `backend/`), not the STORY-003
  worktree — STORY-003 is a mobile-only lane story, backend/ was not touched by
  it there.
- Required secret `backend/service-account.json`: present (pre-existing local
  file per §7 of `devops_system_memory.md`; not generated or touched by this
  run).

### mobile-app

- Runtime id: `mobile-app`, launched interactively via `flutter run` (not
  `flutter test`), from the STORY-003 story worktree so the emulator shows
  STORY-003's actual implementation, not the control checkout or the
  `main_preview.dart` fake-state harness.
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability`
  (`mobile/`), HEAD `89193341bd7884f4c44ec386d8c8eac2500ad912` — matches the
  handoff's declared `BaseHead`.
- Device: reused the already-open `emulator-5554` (`sdk_gphone64_arm64`,
  confirmed via `adb devices -l` before launch); no new AVD was booted.
- Commands run:
  - `PATH="$HOME/flutter/bin:$PATH" flutter pub get` (from
    `<worktree>/mobile`) — dependencies resolved clean.
  - `PATH="$HOME/flutter/bin:$PATH" flutter run -d emulator-5554
    --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020` (from
    `<worktree>/mobile`), run in the background as an interactive foreground
    Flutter session (per `mobile-app.launch` in the runtime registry: this is a
    human developer path, not a headless/CI path).
  - `CUPID_API_BASE_URL` set to `http://10.0.2.2:21020` per the registry's
    `mobile-app.dependsOnRationale` (Android emulator loopback alias to the
    host's shared-devstack `api` port `21020`; the app's compile-time default
    `http://localhost:3000` is stale and was overridden here, not edited in
    source — updating the Dart-side default is mobile-dev scope, out of this
    DevOps run).
- Result: build succeeded (`app-local-debug.apk`, Gradle `assembleLocalDebug`
  25.5s), installed on `emulator-5554`, launched, and reached the interactive
  `flutter run` prompt ("Flutter run key commands") with the Dart VM Service
  live at `http://127.0.0.1:56726/...`. App log shows an existing Firebase Auth
  session already resolved ("Notifying id token listeners about user
  1cLumP900oSHP6w6ItRdU8XVZ2k2"), so the user can navigate the real pairing
  flow directly to the scan-code screen rather than needing a fresh
  login/signup.

### Shutdown (when the user is finished)

- Mobile: press `q` in the `flutter run` foreground session (terminates the
  app on the device cleanly), or send SIGINT to the backgrounded process.
- Backend: leave running (it predates this session and may be in use by other
  work) unless the user explicitly asks to stop it; if so, `kill 68346` (verify
  the PID is still the same process first: `ps -p 68346`).
- No AVD was booted by this run, so there is nothing new to shut down there
  either — it was already open before this request.

### Notes

- This entry intentionally does not touch `req_master.md`'s "Deployment
  Status" table (still correctly `NOT_DEPLOYED` pending the real
  post-requirement-DONE automatic trigger once REQ-012 reaches `DONE`).

## Entry 2 — 2026-08-26 — Automatic post-DONE `development-local` deployment

- Type: automatic post-requirement-DONE local deployment (skill rule 7).
  REQ-012 is `DONE`, landed on `main` at merge commit
  `2b04abd0200349c275b28543cbe9844a44c71473` — re-verified live before
  deploying (`git log --oneline -1 main` -> `2b04abd`; `git branch --contains
  2b04abd...` includes `main`).
- Change surface: `mobile-app` only (pairing-method-choice, create-code/invite
  QR display, scan-code QR-scanning screens under `mobile/lib/features/pairing/**`).
  No `backend-api` change in this requirement.

### backend-api

- Re-verified already running and unaffected: `node` PID `68346`, listening
  `127.0.0.1:21020`. `GET http://127.0.0.1:21020/api-docs-json` -> `200`
  (re-checked live this pass). No restart needed — this requirement did not
  touch `backend/`.

### mobile-app

- Ran from the control checkout (repo root `mobile/`, on `main` post-merge),
  not a story/integration worktree — the requirement is already merged and
  landed.
- Device-state note handled: `emulator-5554` held a debug preview APK
  (`main_preview.dart`, `PREVIEW=pairstart`) installed during requirement
  integration review's mobile visual audit. This deployment reinstalled the
  real product entrypoint over it (same `applicationId
  com.snapsofts.cupid` / `MainActivity`, so `adb install -r` cleanly replaced
  the preview build) rather than leaving the preview harness as the readiness
  target.
- Commands run:
  - `PATH="$HOME/flutter/bin:$PATH" flutter pub get` (mobile/) — clean.
  - `PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug` (mobile/) —
    PASS: `Running Gradle task 'assembleLocalDebug'... 19.6s` then `✓ Built
    build/app/outputs/flutter-apk/app-local-debug.apk`. Only expected
    non-blocking Gradle/KGP warnings (native-access restricted method,
    KGP-applied-by-plugin notice for `mobile_scanner`/`sign_in_with_apple`).
  - `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk`
    -> `Success` (replaced the preview APK).
  - Readiness per the registry's `mobile-app.readiness` command: `adb -s
    emulator-5554 shell am start -W -n
    com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` ->
    `Status: ok`, `LaunchState: COLD`; polled `dumpsys activity activities`
    for the resumed foreground activity, matched on the first poll
    (`READINESS_EXIT=0`).
  - Shutdown per the registry's `shutdownCommand`: `adb -s emulator-5554 shell
    am force-stop com.snapsofts.cupid`, confirmed `visible=false` /
    `isExiting` in a follow-up `dumpsys activity activities`. The emulator
    itself was left running (pre-existing, not started by this deployment).
- `deployment/configuration-guide.md` under this requirement is already
  `Status: DELIVERED` (camera-permission manifest/Info.plist facts previously
  verified in place) — no new config/secret work required or performed this
  pass.

### Result

- `req_master.md` "Deployment Status" -> `Development Environment: DEPLOYED
  (2026-08-26, ...)`. Staging/Production remain `NOT_REQUESTED`, untouched.

## Entry 3 — 2026-08-26 — Ad hoc dual-device (AVD + real ADB device) manual run

- Type: ad hoc `development-local` manual run requested directly by the user
  (not the automatic post-DONE trigger). Control checkout on `main`, clean,
  HEAD `e4a9f34`. Does not touch `req_master.md` Deployment Status.

### backend-api

- Reused already-running process, unaffected: `node` PID `68346`, listening
  `127.0.0.1:21020` (`lsof -nP -iTCP:21020 -sTCP:LISTEN` confirmed the PID;
  `devstack port claim --role api --project cupid-apps` re-confirmed the
  reserved port as `21020`). `GET http://127.0.0.1:21020/api-docs-json` ->
  `200` (re-checked before and after both mobile launches). Not started or
  stopped by this run.

### mobile-app — two simultaneous devices

- Real device: `HT7AH1A02116` (Pixel 2, `walleye`), already attached via USB
  ADB. Reachability: a real USB device cannot use the emulator's
  `10.0.2.2` loopback alias, so set up `adb -s HT7AH1A02116 reverse
  tcp:21020 tcp:21020` and launched with
  `--dart-define=CUPID_API_BASE_URL=http://127.0.0.1:21020` (the device's own
  `127.0.0.1:21020` now forwards to the host's `21020` over the reverse
  tunnel).
- AVD emulator: no emulator was already booted (only the real device showed
  in `adb devices -l`), so booted `cupid-story001-avd` via
  `nohup emulator -avd cupid-story001-avd &`, polled
  `getprop sys.boot_completed` until `1`, came online as `emulator-5554`.
  Launched with the standard alias
  `--dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020`.
- Both launched via the registry's `scripts/run-mobile.sh android --udid
  <serial> -- --dart-define=...` launch path, each as its own backgrounded
  foreground `flutter run` session (not a single combined smoke): one for
  `HT7AH1A02116`, one for `emulator-5554`. Both reached the "Flutter run key
  commands" prompt with a live Dart VM Service URL — first Gradle build per
  device (`assembleLocalDebug`), only expected non-blocking Gradle/KGP
  warnings (native-access restricted method, KGP-applied-by-plugin notice for
  `mobile_scanner`/`sign_in_with_apple`).
- Readiness per the registry's `mobile-app.readiness` command, run against
  both serials: `adb -s <serial> shell am start -W -n
  com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` then polled
  `dumpsys activity activities` for the resumed foreground activity.
  `HT7AH1A02116` -> `Status: ok`, `LaunchState: HOT`, resumed match on first
  poll. `emulator-5554` -> `Status: ok`, `LaunchState: WARM`, resumed match on
  first poll. (Immediately after each `flutter run` reached the key-commands
  prompt but before this explicit `am start`, `dumpsys` briefly showed an
  unrelated foreground activity on each device — Twitter on the real device,
  a Google Sign-In `MinuteMaidActivity` on the emulator — normal for a
  human-developer device that is not headless; the explicit readiness
  `am start` brought Cupid back to resumed foreground on both.)

### Shutdown (when the user is finished)

- Real device: press `q` in its `flutter run` foreground session, or
  `adb -s HT7AH1A02116 shell am force-stop com.snapsofts.cupid`. Also remove
  the reverse tunnel when done: `adb -s HT7AH1A02116 reverse --remove
  tcp:21020`.
- Emulator: press `q` in its `flutter run` foreground session, or
  `adb -s emulator-5554 shell am force-stop com.snapsofts.cupid`. The AVD
  itself was newly booted by this run (`cupid-story001-avd`, log at
  `/private/tmp/claude-503/-Users-alantravala-workspace-snapsofts-cupid-apps/212fb0d6-3735-4ddc-9734-2fdb112de502/scratchpad/emulator-cupid-story001.log`)
  and may be shut down with `adb -s emulator-5554 emu kill` if no longer
  needed.
- Backend: leave running (predates this session); `kill 68346` only if the
  user explicitly asks to stop it (re-verify the PID is still that process
  first: `ps -p 68346`).

### Notes

- This entry intentionally does not touch `req_master.md`'s "Deployment
  Status" table.

## Entry 4 — 2026-08-26 — Second AVD added alongside real device + first AVD

- Type: ad hoc `development-local` manual multi-device run (user wants a
  second, independent AVD instance running the app at the same time as the
  already-running real device `HT7AH1A02116` and the first AVD
  `cupid-story001-avd`/`emulator-5554`). Neither of those two was touched:
  no `adb ... force-stop`, no `reverse --remove`, no `flutter run` session
  interrupted for either. `req_master.md` "Deployment Status" not touched.
- Ran from the control checkout (`mobile/` on `main`, HEAD `e4a9f34`), same as
  Entry 3.
- AVD selection: `emulator -list-avds` showed two AVDs already existed —
  `cupid-story001-avd` (already running as `emulator-5554`) and
  `Medium_Phone_API_36.0` (not yet booted). Used the existing
  `Medium_Phone_API_36.0` rather than creating a new one, since it already
  satisfied "a second, different AVD".
- Booted `Medium_Phone_API_36.0`: `emulator -avd Medium_Phone_API_36.0
  -no-snapshot-load` (backgrounded, log at
  `/private/tmp/claude-503/-Users-alantravala-workspace-snapsofts-cupid-apps/d84d86ac-3ea6-4e63-8650-a25c231538a9/scratchpad/emulator2.log`).
  Polled `adb -s emulator-5556 shell getprop sys.boot_completed` until `1`.
  New serial confirmed via `adb devices -l`: `emulator-5556` (as expected,
  distinct from `emulator-5554`), also visible in `flutter devices` as a
  separate `sdk gphone64 arm64` entry alongside the first AVD, the real
  Pixel 2, macOS, Chrome, and a wirelessly-connected iOS device.
- Backend re-verified untouched throughout: `node` PID `68346` still listening
  on `127.0.0.1:21020`.
- Commands run (mobile/):
  - `flutter pub get` — clean (dependencies already resolved from Entry 3).
  - `flutter run -d emulator-5556
    --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020` (same
    emulator-loopback dart-define as the first AVD; backgrounded interactive
    session).
  - Result: `assembleLocalDebug` 4.4s, `app-local-debug.apk` built and
    installed (6.5s), app launched, reached the interactive "Flutter run key
    commands" prompt with Dart VM Service live at
    `http://127.0.0.1:60952/lVPEWr5QR_A=/`. One non-blocking, pre-existing
    upstream warning (`GeneratedPluginRegistrant` / `flutter_facebook_auth`:
    "The SDK has not been initialized") — same class of Facebook SDK
    lazy-init warning as on other devices, not caused by this run and not a
    launch failure. Firebase Auth resolved an existing session (user
    `1cLumP900oSHP6w6ItRdU8XVZ2k2`).
- Readiness confirmed independently via the registry's probe: `adb -s
  emulator-5556 shell dumpsys activity activities` showed
  `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` as
  `visible=true`/`topResumedActivity` (matches `flutter run`'s own launch
  success).
- Untouched-device verification performed after the new AVD came up:
  - `emulator-5554` (first AVD): `dumpsys activity activities` still shows
    `com.snapsofts.cupid` as `topResumedActivity`/`visible=true` — session
    intact.
  - `HT7AH1A02116` (real device): `pidof com.snapsofts.cupid` -> `31495`
    (app process still alive, session intact — not force-stopped by this
    run). Its foreground activity had moved to a different app
    (`com.twitter.android`) by the time this was checked, which just means
    the user had backgrounded the app on that device themselves; the
    `flutter run` session and app process were not touched by this task.
    Its `adb reverse --list` returned empty at check time — pre-existing
    state on that device, not modified by this run (no `reverse` command was
    issued against `HT7AH1A02116` in this entry).

### Shutdown (this AVD only, when the user is finished)

- Mobile: `q` in this `flutter run` session, or `adb -s emulator-5556 shell
  am force-stop com.snapsofts.cupid`.
- AVD: `adb -s emulator-5556 emu kill` (this AVD was newly booted by this
  entry; the other two devices are unaffected by killing it).
- Backend, real device, and `emulator-5554` are unaffected either way — leave
  them exactly as they are.

### Notes

- This entry intentionally does not touch `req_master.md`'s "Deployment
  Status" table.
