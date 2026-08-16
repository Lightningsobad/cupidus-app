# REQ-002 Integration Build & Runtime Verification (Round 2)

- Scope: `REQ-002_screen_flow_and_design_fidelity_audit`, all 33 stories merged
- Worktree: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
- HEAD verified: `db4e796f0205552b1f959afad4c33858a45daafe`
- Device: `emulator-5560` (pre-existing, not booted/reset by this pass)

## Integration Build & Runtime

Toolchain resolved from `data/devops/system/runtime-command-registry.json`
(`mobile-app`). The Flutter SDK is not on PATH on this machine and was
invoked from `/Users/alantravala/flutter/bin` (`FLUTTER_SDK_PATH`) as the
registry records.

| Step | Command | Result |
|---|---|---|
| Deps | `flutter pub get` | PASS (exit 0) |
| Build | `flutter build apk --debug` | PASS (exit 0) |
| Install | `flutter install -d emulator-5560 --debug` | PASS (exit 0) |
| Readiness | registry readiness command on `emulator-5560` | PASS (exit 0) |
| Shutdown | `adb -s emulator-5560 shell am force-stop com.snapsofts.cupid` | PASS (exit 0) |

Build: PASS — `flutter build apk --debug` produced
`mobile/build/app/outputs/flutter-apk/app-debug.apk`, exit 0, from a fresh
build at this exact worktree HEAD (no prior APK reused).

Install: PASS — `flutter install -d emulator-5560 --debug` uninstalled the
prior version and installed `build/app/outputs/flutter-apk/app-debug.apk`
onto `emulator-5560`.

Runtime: PASS — ran the registry's compound readiness command
(`am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
followed by polling `dumpsys activity activities` for the resumed activity,
per `data/devops/system/runtime-command-registry.json` `mobile-app.readiness`)
end-to-end as a single shell command; overall exit code `0`, matching the
registry's `expectExitCode: 0`. Note: the individual `am start -W` line
reported `Status: timeout` / `LaunchState: UNKNOWN (-1)` (`WaitTime: 15562`)
this run, unlike Round 1's `Status: ok`/`LaunchState: COLD` — this reflects
`am start -W`'s own "reached idle" wait timing out, not a launch failure; the
subsequent `dumpsys activity activities` poll found
`ResumedActivity: ActivityRecord{... com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity ...}`
on the very first poll iteration, and the compound command's exit code was
`0` per the registry's own pass criterion. `adb logcat -d -t 500` over the
launch window showed no `FATAL`, no `AndroidRuntime` crash, and no
`E/flutter` lines.

Shutdown: PASS — `am force-stop com.snapsofts.cupid` per the registry
`shutdownCommand`, exit 0. This stops the app process only; the emulator
itself was left running (not powered off, not reset) and the debug APK
remains installed (`pm list packages` confirms `com.snapsofts.cupid` still
present), per the handoff's requirement to hand off a live emulator with
this build installed to the following Mobile Developer visual-audit
dispatch.

Smoke: PASS (process-level launch/readiness only; `flutter analyze` and
`flutter test` are explicitly out of scope for this DevOps pass and remain
Reviewer's read-only gates for the Round 2 requirement integration review).
