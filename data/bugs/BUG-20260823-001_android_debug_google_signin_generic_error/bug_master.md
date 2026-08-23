# Bug Master: BUG-20260823-001 Android debug Google sign-in generic error
Status: DONE
Severity: unknown
Source: user
Created: 2026-08-23
Linked Requirement: N/A
Linked Story: N/A

## Report

Observed behavior:
On an Android debug build, tapping the "Tiếp tục với Google" ("Continue with Google") button always fails with the generic error toast/message "Đã có lỗi xảy ra, hãy thử lại" ("An error occurred, please try again").

Expected behavior:
Tapping "Tiếp tục với Google" on an Android debug build should complete Google sign-in (or surface a specific, actionable error) instead of always failing with the generic fallback error message.

Reproduction steps or command:
1. Build and run the mobile app in Android debug configuration.
2. On the welcome/login screen, tap "Tiếp tục với Google".
3. Observe the generic error "Đã có lỗi xảy ra, hãy thử lại" every time.

Failure anchors:
- Stack trace: none provided by user
- Failing test: none provided by user
- Route/endpoint/component/job: Google sign-in CTA ("Tiếp tục với Google"), welcome/login screen, mobile app
- Environment: Android, debug build

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [x] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: none — closed
- Reviewer outcome: `Outcome: DEFERRED_ONLY` (Iris-QC). 0 blocking findings, 5
  deferred (D-1 auth-exception-logging follow-up story, D-2 correction — do
  not open a new bug from fix-evidence.md's D-3 wording, D-3 devops
  onboarding-doc gap for per-developer debug SHA-1 registration, D-4
  informational test-account cleanup, D-5 scrum-master-owned commit-staging
  discipline, applied at closure). Independent re-derivation confirmed the
  root-cause chain, all gates, and that the post-sign-in backend-unreachable
  observation is a genuinely separate condition, not a disguised continuation.
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`

## Blockers

- No blocker currently applies. 2026-08-23: the user completed both external
  steps (device-side account re-authentication, and debug SHA-1 registration +
  `google-services.json` re-download), and the recheck on device
  `HT7AH1A02116` no longer hits the blocker — Google sign-in runs to completion
  and `FirebaseAuth` authenticated user `wh4Ekn1orPUtazzUvgEi0rnxdbq1`. Bug
  Fixer reported `BUG_FIX_COMPLETE: YES` with Build, Runtime Startup,
  Shutdown, and Original Failure Recheck gates all PASS. Awaiting reviewer;
  status remains scrum-master's to set. See `fix-evidence.md` §Recheck After
  Blocker Resolution. Historical blocker record below, kept for review
  traceability:
- `BLOCKER: DEVICE_SIDE_OAUTH_CONSENT_REQUIRED` (no longer applies) — was
  reported with `BUG_FIX_COMPLETE: NO` on the first pass.
  Diagnosed root cause (`com.google.gms.google-services` Gradle plugin never
  applied, so `default_web_client_id`/`serverClientId` was absent) is fixed and
  verified on device: the Credential Manager account chooser now launches where
  the flow previously failed instantly. A second, distinct failure remains after
  account selection — GMS returns `[16] Account reauth failed.` — needing
  interactive device-side re-authentication of the Google account and/or debug
  SHA-1 registration in Google Cloud project `gen-lang-client-0644970375`
  (`google-services.json` still has no `client_type: 1` Android OAuth client).
  Neither is available to bug-fixer. Details, SHA-1/SHA-256 values, and
  recommended DevOps routing are in `fix-evidence.md` §Blocker.
