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
