# Scope Gate: BUG-20260823-001 Android debug Google sign-in generic error

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: bugfix-review
Reviewer: Iris-QC
Date: 2026-08-23
Bug: `BUG-20260823-001_android_debug_google_signin_generic_error`
Review report path: `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/review/review-report.md`

## Governing Artifacts (already read, do not re-read)

- `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/bug_master.md`
- `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/diagnosis.md` (8.1 KB)
- `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/fix-evidence.md` (15.4 KB)

Both are under 20 KB; one full read each was taken. The authoritative conclusion
is the appended `## Recheck After Blocker Resolution` / `## Final Gate Summary`
sections; the earlier `## Outcome` (`BUG_FIX_COMPLETE: NO`) and `## Blocker`
sections are historical and explicitly superseded within the same files.

## Source/Test Files In Scope (Phase 2)

1. `mobile/android/settings.gradle.kts` — changed. Verify only the
   `com.google.gms.google-services` plugin declaration was added.
2. `mobile/android/app/build.gradle.kts` — changed. Verify only the plugin
   application was added.
3. `mobile/android/app/google-services.json` — changed, but attributed to the
   user's Google Cloud console re-download, not a bugfix edit. Verify the
   attribution holds: `client_type: 1` entries with the reported
   `certificate_hash`, and an unchanged `client_type: 3` web client.
4. `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` —
   read-only. Verify `git diff` is empty (all diagnostic instrumentation
   reverted) and confirm the `_guard` funnel described by D-1.

Changed-file count: 2 bugfix-authored + 1 user-supplied config (budget: 12).
Within `bugfix-review` budget.

## Evidence Files In Scope

Pre-fix and prior (blocked) pass:
- `evidence/prefix-01-generic-error-on-tap.png`
- `evidence/postfix-02-credential-manager-account-chooser.png`
- `evidence/postfix-03-still-generic-error-after-account-pick.png`

Final recheck (authoritative):
- `evidence/recheck-01-welcome.png`
- `evidence/recheck-02-account-chooser.png`
- `evidence/recheck-03-consent-screen.png`
- `evidence/recheck-04-signin-ok-backend-unreachable.png`

Supporting (not load-bearing, read only if a gap appears):
- `evidence/postfix-01-welcome.png`, `evidence/postfix-04-runtime-startup.png`

Generated build output cited as fix proof:
- `mobile/build/app/generated/res/processDebugGoogleServices/values/values.xml`
  (`default_web_client_id`) — verify it exists and holds the claimed value.

## Touched Risk Surfaces And Critical Gates

| Risk surface | Touched? | Critical gate | Where verified |
|---|---|---|---|
| Runtime/configuration (Android Gradle build config) | Yes — sole code change | Build gate + generated `default_web_client_id` resource | `## Build Gate (re-run)`, `## Fix Verification` |
| External integration (Google Sign-In / Credential Manager / Firebase Auth) | Behaviour restored | Same-modality on-device recheck with decisive auth log | `## Original Failure Recheck Gate (re-run)` |
| Security/auth (sign-in path) | Yes | Real authenticated Firebase user, not UI appearance | `FirebaseAuth` uid log lines + consent capture |
| App lifecycle / runtime startup | Indirect | Registry readiness probe + shutdown | `## Runtime Startup Gate (re-run)` |
| Package/dependency (new Gradle plugin 4.4.4) | Yes | Clean build under AGP 9.0.1 / Gradle 9.1.0, no unrelated plugin churn | Build gate + diff inspection |
| Secret/credential hygiene | Config file changed | Confirm no private key/secret introduced by the changed files | Diff inspection of `google-services.json` |
| Scope creep | Must be none | No Dart change; instrumentation fully reverted | Independent `git diff` |

Not applicable: persistence/schema, migration, async job/workflow, data
migration/backfill, deep link/push, local storage/offline, frontend
interaction, typed/generated API contract.

Configuration-guide check: IN SCOPE to assess. The change is build/runtime
configuration and depends on an external Google Cloud registration step, so
whether setup guidance must record the debug SHA-1 requirement is a question
this review must answer rather than assume.

## Focused Query Keys For Phase 2

- `com.google.gms.google-services`, `apply false`, `plugins {`, `id(` — the two
  Gradle files
- `default_web_client_id`, `processDebugGoogleServices` — generated resource
- `client_type`, `certificate_hash`, `oauth_client`, `package_name` —
  `google-services.json`
- `serverClientId`, `initialize(`, `_guard`, `UnexpectedAuthFailure` — gateway
  (read-only, D-1)
- `localhost:3000`, `baseUrl`, `AUTH`/`API` base URL symbol — D-3 attribution
- `FirebaseAuth`, `wh4Ekn1orPUtazzUvgEi0rnxdbq1` — decisive recheck log claim

## Handoff Verification Directives (must be answered, not assumed)

1. Does the Pre-Fix Reproduction Gate (`REPRODUCED`, same modality) plus the
   two-cause root-cause chain actually explain "always fails with the generic
   error"?
2. Does the Original Failure Recheck Gate prove sign-in *completes* (real
   authenticated user), not merely "no crash"?
3. Are Build and Runtime Startup gates (incl. `Shutdown: PASS`) real commands
   with real results?
4. Are the 2 Gradle changes minimal, safe, and free of unrelated plugin/version
   churn?
5. Are D-1..D-4 correctly non-blocking? Specifically D-3: is the
   `http://localhost:3000/auth/login` failure a genuinely separate
   subsystem/condition, or a disguised continuation of the reported failure?

## Explicitly Out Of Scope

- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/**` (separate closed
  bug, already reviewed — not this scope).
- REQ-002 STORY-001 ADR-7 re-litigation, REQ-007 artifacts, broad requirement or
  story rereads, whole implementation directories.
- Editing `bug_master.md`, implementation code, config, or workflow checklists.

## Phase 2 Decision

Phase 2 may proceed. All three governing artifacts exist, the final
`BUG_FIX_COMPLETE: YES` supersedes the earlier blocker record inside the same
files, and both `## Pre-Fix Reproduction Gate` and a passing
`## Original Failure Recheck Gate` with `Same modality as original: YES` are
present. No scope-stage `BLOCKED` / `PATCH_REQUIRED` stop is warranted; the
outcome depends on Phase 2 verification.
