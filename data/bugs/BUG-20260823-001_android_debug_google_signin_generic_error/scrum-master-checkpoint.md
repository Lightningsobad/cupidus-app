# Scrum Master Checkpoint

Scope:
- Bug: BUG-20260823-001_android_debug_google_signin_generic_error
- Status: DONE
- Workflow: fix-bugs (recheck PASS, BUG_FIX_COMPLETE: YES; Reviewer outcome
  `DEFERRED_ONLY` verified by scrum-master; bug closed and committed)

Canonical artifact paths:
- Registry: `data/bugs/master_bugs_list.md`
- Bug master: `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/bug_master.md`
- Diagnosis (not yet written): `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/diagnosis.md`
- Fix evidence (not yet written): `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/fix-evidence.md`
- Review report (not yet written): `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/review/review-report.md`

Failure anchors:
- Component: Google sign-in CTA ("Tiếp tục với Google"), welcome/login screen,
  mobile app.
- No stack trace provided by user.
- No existing failing test named by user.
- Observed: on Android debug build, tapping "Tiếp tục với Google" always shows
  the generic fallback error "Đã có lỗi xảy ra, hãy thử lại".

Expected-behavior source: inferred — Google sign-in should either complete
successfully or surface a specific, actionable error instead of the generic
fallback on every attempt.

Suspected impacted app: `mobile` (Flutter), Android debug build. Possible
config surfaces to investigate during diagnosis: Google Sign-In OAuth
client/SHA-1 configuration, backend auth endpoint, and any recent build-config
changes (REQ-007 mobile production API build config touched build flavors).
Not confirmed — for bug-fixer diagnosis only, not asserted here.

Runtime registry path: `data/devops/system/runtime-command-registry.json`

Query keys for future `bug-fixer` handoff:
- Google sign-in CTA implementation and error handling on welcome/login screen
- Android debug build config (google-services.json, OAuth client id, SHA-1
  fingerprint registration)
- Auth backend endpoint used by Google sign-in flow
- Recent REQ-007 mobile production API build config changes (possible
  regression surface, not confirmed)

Active Bug Fixer Agent Id: Justin-BugFixer
Bug Fixer Status: COMPLETE (BUG_FIX_COMPLETE: NO — blocked, not a failure of
diligence; independently verified by scrum-master reading diagnosis.md and
fix-evidence.md in full)

Verified outcome:
- Root cause 1 (proven, fixed): `com.google.gms.google-services` Gradle
  plugin was never applied in `mobile/android/`, so `serverClientId` /
  `default_web_client_id` was never generated from the already-correct,
  already-committed `google-services.json`. Google Sign-In therefore failed
  before any native call. Fixed by applying the plugin in
  `mobile/android/settings.gradle.kts` and `mobile/android/app/build.gradle.kts`
  (no Dart changed). Verified: generated resource now present, Credential
  Manager account chooser now launches (previously unreachable).
- Gates: Pre-Fix Reproduction Gate `REPRODUCED` (same modality), Build Gate
  `PASS`, Runtime Startup Gate `PASS`/Shutdown `PASS`, Original Failure
  Recheck Gate `PARTIAL — original root cause cleared, reported symptom still
  occurs` (same modality). No gate was fabricated; PARTIAL was reported
  honestly per the handoff's stop rule.
- Residual blocker (root cause 2, distinct): after account selection, GMS
  returns `GoogleSignInException code=canceled desc=[16] Account reauth
  failed.` Needs one or both, neither available in-session:
  1. Interactive device-side re-authentication of the on-device Google
     account (`cacon194v3@gmail.com`) — no console access needed, but needs
     the account owner.
  2. Debug SHA-1/SHA-256 registration as an Android OAuth client in Google
     Cloud project `gen-lang-client-0644970375` (`google-services.json` has
     only a web client, no `client_type: 1` entry) — needs Cloud console
     access. Values: SHA-1 `0B:1C:DC:7B:7A:FC:5A:32:2E:6C:1B:1D:8E:1E:64:98:C0:32:66:29`,
     SHA-256 `C4:C1:07:48:A0:3D:94:82:A9:AC:DA:F9:82:0F:EC:CC:05:2D:6F:AA:F8:16:76:2C:10:72:6B:AA:F5:B3:79:5C`,
     package `com.snapsofts.cupid`. Requires re-downloading
     `google-services.json` afterward.
- Working tree: `mobile/android/settings.gradle.kts` and
  `mobile/android/app/build.gradle.kts` are uncommitted (not committed by
  scrum-master — no review has run yet; bug is BLOCKED, not REVIEW_REQUIRED).
  The fix is a genuine improvement and safe to keep meanwhile.
- Two non-blocking residual notes for a future Reviewer pass (in
  `fix-evidence.md`): D-1 `_guard` swallows all provider exceptions with no
  logging (ADR-7, out of scope, suggest follow-up story); D-2 pre-existing
  unrelated `validate-runtime-registry.sh` gate gap (devops-owned, already
  noted on BUG-20260817-001).

User decision (2026-08-23): "Do both, then recheck" — user completed both
external steps (device re-auth + debug SHA-1 registered in Google Cloud +
`google-services.json` re-downloaded) and said "recheck BUG-20260823".

Recheck dispatched: `SendMessage` to `Justin-BugFixer` (`Mode: fix-bug`,
`Session-Recovery: YES`), asking it to re-run Build Gate (if
`google-services.json` changed), Runtime Startup Gate, and the Original
Failure Recheck Gate through account selection, appending results to the
existing `diagnosis.md`/`fix-evidence.md` rather than rewriting them.

Active Bug Fixer Agent Id: Justin-BugFixer
Bug Fixer Status: COMPLETE — `BUG_FIX_COMPLETE: YES`, independently verified
by scrum-master reading both appended sections in full (`diagnosis.md`
§Recheck After Blocker Resolution, `fix-evidence.md` §Recheck After Blocker
Resolution + §Final Gate Summary). All gates PASS: Build, Runtime Startup,
Shutdown, Original Failure Recheck (same modality, decisive `FirebaseAuth`
log evidence of a real authenticated user). Blocker
`DEVICE_SIDE_OAUTH_CONSENT_REQUIRED` is closed. Changed files remain exactly
2 (`mobile/android/settings.gradle.kts`,
`mobile/android/app/build.gradle.kts`); `google-services.json` also changed
but is the user's own console re-download, not a bugfix edit.

New non-blocking finding for Reviewer: D-3 — post-sign-in the app calls its
backend at `http://localhost:3000/auth/login`, unreachable from a physical
device; out of scope for this bug (Google sign-in itself completes, which is
what the report asked for), flagged as a possible REQ-007 follow-up.
D-4 (informational): recheck created a real authenticated Firebase user +
granted OAuth consent on the test Google account — intentionally left as
evidence.

Active Reviewer Agent Id: Iris-QC
Reviewer Status: COMPLETE — `review/review-report.md` written, one literal
`Outcome: DEFERRED_ONLY` line, 0 blocking findings, 5 deferred (D-1 through
D-5, see `bug_master.md` Routing Notes and `review/review-report.md` for full
detail and owners). Independently re-verified by scrum-master (full read of
review-report.md).

Closure:
- `bug_master.md`: Artifacts all checked, Status set to `DONE`, Routing Notes
  updated with Reviewer outcome summary.
- `data/bugs/master_bugs_list.md`: row updated to `Status: DONE`.
- Git: staged and committed exactly the reviewed scope per D-5 (mobile Android
  Gradle config files, `google-services.json`, `data/bugs/master_bugs_list.md`,
  and this bug's full `data/bugs/BUG-20260823-001_.../` directory), excluding
  4 unrelated pre-existing working-tree files
  (`mobile/ios/Runner.xcodeproj/project.pbxproj`,
  `mobile/ios/Runner/Base.lproj/Main.storyboard`, `backend/.env.example`,
  `docs/production-readiness-checklist.md`).
- Commit sha: `8757810` — "fix(BUG-20260823-001): apply google-services
  Gradle plugin for Android sign-in" (19 files changed).

Next step: none — bug closed. Deferred findings D-1 (auth-exception-logging
follow-up story, owner product-owner/mobile-dev) and D-3 (devops onboarding
doc for per-developer debug SHA-1 registration, owner devops) are candidates
for future backlog/documentation follow-up, not blockers on this bug.
