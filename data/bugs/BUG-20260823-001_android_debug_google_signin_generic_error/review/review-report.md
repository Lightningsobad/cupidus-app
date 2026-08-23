# Bugfix Review Report: BUG-20260823-001 Android debug Google sign-in generic error

Outcome: DEFERRED_ONLY

Review type: bugfix-review
Reviewer: Iris-QC
Date: 2026-08-23
Bug: `BUG-20260823-001_android_debug_google_signin_generic_error`
Scope gate: `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/review/scope-gate.md`
Blocking findings: 0
Deferred findings: 5

## Rationale

The reported defect is real, correctly diagnosed to a build-configuration root
cause, and fixed by the minimum correct change — four added lines across two
Android Gradle files. I re-derived the root-cause chain from source rather than
from the report, re-ran the Build gate and the registry Runtime Startup and
Shutdown probes myself, confirmed the generated `default_web_client_id`
resource from the actual build output, and opened every load-bearing capture.
Google sign-in now completes to a real authenticated Firebase user. The
deferred items are pre-existing or environmental and none of them hides a live
defect in this fix.

## Independent Verification

| Claim under review | How I verified it | Result |
|---|---|---|
| Root cause: `initialize()` passes no `serverClientId` | Read `firebase_auth_sign_in_gateway.dart:52-56` — `await GoogleSignIn.instance.initialize();`, no argument | CONFIRMED |
| Root cause: `_guard` collapses the provider error into the generic message | Read `firebase_auth_sign_in_gateway.dart:125-139` — `on GoogleSignInException { throw const UnexpectedAuthFailure(); }`, no logging on any branch | CONFIRMED — fully explains both "always fails" and the opaque copy |
| The chain is deterministic, not intermittent | Both inputs are build-time constants (missing Gradle plugin ⇒ resource never generated; no Dart argument), so every attempt fails identically | CONFIRMED — consistent with the reported "every time" |
| Fix is exactly 2 Gradle files, minimal | `git diff` — `settings.gradle.kts` +1 (`id("com.google.gms.google-services") version "4.4.4" apply false`), `app/build.gradle.kts` +3 (2 comment lines + `id("com.google.gms.google-services")`). +4/-0 total | CONFIRMED — no version churn, no unrelated plugin/dependency edits |
| No Dart changed; instrumentation fully reverted | `git diff -- mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` → empty; `git status` shows no other `mobile/lib` or `mobile/test` entry | CONFIRMED |
| The fix actually produces the missing resource | Read `mobile/build/app/generated/res/processDebugGoogleServices/values/values.xml` → `default_web_client_id = 591718769021-3qll01ehinlrk3aaddl6l0fk4ordipte.apps.googleusercontent.com` | CONFIRMED — direct negation of `serverClientId must be provided on Android`; matches the `client_type: 3` web client exactly |
| `google-services.json` change is the user's console re-download, not a bugfix edit | `git diff` is purely additive (+16/-0): two `client_type: 1` blocks only. First carries `certificate_hash: 0b1cdc7b7afc5a322e6c1b1d8e1e6498c0326629` = the debug SHA-1 in §Blocker. The `client_type: 3` web client is an unchanged context line | CONFIRMED — attribution holds, and `default_web_client_id` provably regenerates to the same value |
| Only these files were touched | `git status --porcelain` — mobile changes are exactly the 2 Gradle files + `google-services.json`; the two `mobile/ios/*` entries are pre-existing (see D-5) | CONFIRMED |
| Event ordering matches the narrative | `stat` mtimes: Gradle fix 20:54:12/20:54:16 → user's `google-services.json` 21:07:54 → rebuild `values.xml` + `app-debug.apk` both 21:09:17 → recheck logs 21:11:08 | CONFIRMED — the rebuild demonstrably consumed the new json, as claimed |
| Build gate | Re-ran `flutter build apk --debug` myself | CONFIRMED — `✓ Built build/app/outputs/flutter-apk/app-debug.apk`. Only pre-existing warnings (`sign_in_with_apple` KGP, JVM native-access); no google-services plugin error |
| Registry command fidelity | `data/devops/system/runtime-command-registry.json:170,223,226` — `buildCommand`, `readiness.command` (`expectExitCode: 0`), `shutdownCommand` match what the evidence used | CONFIRMED |
| Runtime Startup gate | Device `HT7AH1A02116` (Pixel 2, walleye) still attached; ran the registry `readiness.command` verbatim | CONFIRMED — exit 0 |
| Shutdown gate | Ran registry `shutdownCommand`; then `pidof com.snapsofts.cupid` | CONFIRMED — force-stop exit 0, `pidof` exit 1 (no process) |

## Gate Verification

| Gate | Status | Basis |
|---|---|---|
| `## Pre-Fix Reproduction Gate` present, `REPRODUCED`, same modality | PASS | Real debug build, real device, real tap; capture shows the exact reported string |
| `## Original Failure Recheck Gate` (re-run), `Same modality as original: YES` | PASS | Full real-tap flow through chooser → consent → authenticated user, rendered captures |
| Build | PASS | Re-run by this review |
| Runtime Startup | PASS | Registry probe re-run by this review, exit 0 |
| Shutdown | PASS | Registry command re-run by this review, process confirmed gone |
| Secret hygiene | PASS | The added entries are public OAuth client ids and certificate hashes; no private key or secret introduced |
| Configuration guide | NOT APPLICABLE as an artifact | `Linked Requirement: N/A`, so no `data/requirements/<REQ>/deployment/configuration-guide.md` exists to check. The real setup impact is recorded as D-4 instead |

### The recheck proves completion, not merely absence of a crash

This was the point most worth attacking, so I checked it three independent ways.

1. **Decisive log, not UI appearance.** `FirebaseAuth` logs
   `Notifying id token listeners about user ( wh4Ekn1orPUtazzUvgEi0rnxdbq1 )`
   and the matching auth-state line. An ID token listener notification with a
   real uid can only follow a successful `signInWithCredential`; no UI state can
   fake it.
2. **The intermediate stages are real system surfaces.** I opened the captures:
   `recheck-02` is the genuine Credential Manager sheet ("Choose an account to
   continue to cupid_mobile", `Peter Packer / cacon194v3@gmail.com` at ~y=1041,
   matching `input tap 540 1041`); `recheck-03` is the genuine Google consent
   dialog ("Allow Google to sign you in to cupid_mobile") with "Agree and share"
   at ~(763, 1365), matching `input tap 763 1365`. Both were unreachable before
   the fix — `prefix-01` shows the failure landing on the welcome screen within
   ~1s with no GMS activity at all in logcat.
3. **The reported symptom is gone, and I checked the strings against the
   captures rather than trusting the prose.** `prefix-01` shows exactly
   "Đã có lỗi xảy ra. Vui lòng thử lại." `recheck-04` shows
   "Không có kết nối mạng" — a different message from a different cause. The
   reported generic error appears nowhere in the recheck.

### D-3 is a genuinely separate condition, not a disguised continuation

The handoff asked for this specifically. It is separate, on five independent
grounds, and I verified the mechanism in source rather than accepting the
attribution:

- **Different subsystem.** Dio → the app's own REST backend, not Google
  Credential Manager or Firebase Auth.
- **Different, later time.** Firebase uid logged at `21:11:08.428`; the
  `POST http://localhost:3000/auth/login` at `21:11:08.523`, 95 ms *after*
  authentication had already succeeded.
- **Different user-visible message.** "Không có kết nối mạng", not the reported
  "Đã có lỗi xảy ra, hãy thử lại." Confirmed by reading both captures.
- **Different failure mode.** `Connection refused` — the backend was not running
  at all.
- **Configured behavior, not a code defect.** `mobile/lib/core/config/cupid_api_config.dart:7-10`
  defines `baseUrl` as `String.fromEnvironment('CUPID_API_BASE_URL', defaultValue: 'http://localhost:3000')`.
  The localhost value is a *build-time default that callers override*, and the
  file's own comment (line 5) documents `10.0.2.2` as the Android emulator
  alias for the host. The recheck built with a plain `flutter build apk --debug`
  and no `--dart-define`, so localhost resolving to the device itself is the
  configured outcome.

Against the bug's stated expected behavior — "should complete Google sign-in
(or surface a specific, actionable error)" — Google sign-in completes. The gate
result of `PASS` is correct. See D-2 for a correction to how D-3 is worded.

### On D-1 and why it is not blocking

D-1 (the `_guard` funnel that discards the provider exception) is arguably
in tension with the bug's "or surface a specific, actionable error" clause, so
it deserves an explicit ruling rather than silent deferral. It is correctly
non-blocking: that clause is the *alternative* branch of the expected behavior,
and the primary branch — sign-in completes — is now satisfied, which makes the
acceptance met on its own terms. The funnel is a deliberate REQ-002 STORY-001
ADR-7 decision, it predates this bug, and this fix did not make it worse
(rule 7). Correctly left un-relitigated. The follow-up D-1 proposes — keep the
ADR-7 public contract, log the underlying provider exception in debug builds —
is the right shape and is worth a story.

## Deferred Findings

**D-1 — Auth exception funnel discards all provider diagnostics.**
`_guard` (`mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart:125-139`)
maps `GoogleSignInException`, `SignInWithAppleException`, and `PlatformException`
to `UnexpectedAuthFailure` with no logging on any branch. Verified in source.
This is why a fully deterministic configuration error required patching and
reinstalling the app twice to diagnose. Pre-existing ADR-7 decision, not worsened
here. Owner: `product-owner` / `mobile-dev` — follow-up story to preserve the
ADR-7 public contract while logging the underlying provider exception in debug
builds.

**D-2 — Correction to D-3's framing, to prevent a spurious bug being filed.**
D-3 in `fix-evidence.md` reads as though the `localhost` base URL were a latent
product defect ("can never reach a developer machine … Worth a separate bug or
story"). Verified in source, it is the documented, intentional default:
`CupidApiConfig.baseUrl` is a `String.fromEnvironment` override point, its
localhost default is deliberately frozen so a production build that omits
`CUPID_API_BASE_URL` is detectable (`cupid_api_config.dart:12-14, 36-41`), and
the emulator alias `10.0.2.2` is already documented at line 5. The accurate
statement is operational: local testing against a *physical* device requires
`--dart-define=CUPID_API_BASE_URL=http://<host-lan-ip>:3000` and a running
backend. Owner: `scrum-master` — do not open a bug from D-3 as currently worded.
The genuinely questionable part is the misleading "Không có kết nối mạng" copy
for a `Connection refused`, which is pre-existing, out of scope, and minor.

**D-3 — Per-developer debug SHA-1 registration is an undocumented setup step.**
Google sign-in on an Android debug build only works once that machine's debug
signing certificate is registered as an Android OAuth client in Google Cloud
project `gen-lang-client-0644970375`. Each developer/machine has a distinct
debug keystore — the committed `google-services.json` now carries two distinct
`client_type: 1` hashes, which is itself evidence of this. Without it, the flow
fails at `[16] Account reauth failed.` after account selection, which looks
nothing like a configuration problem. This bug's artifacts document it, but
nothing in setup documentation does. No `configuration-guide.md` applies because
the bug has `Linked Requirement: N/A`. Owner: `devops` — record this in mobile
setup/onboarding documentation.

**D-4 — Live Firebase user and OAuth grant intentionally left in place.**
The recheck authenticated a real user (`wh4Ekn1orPUtazzUvgEi0rnxdbq1`,
`cacon194v3@gmail.com`) and granted the app an OAuth consent on that Google
account. This was the user-requested verification and is legitimate evidence;
recorded so it is a deliberate state, not a surprise. Owner: user — remove from
Firebase Auth if a clean state is wanted.

**D-5 — Unrelated pre-existing working-tree changes must not enter the bugfix
commit.** `git status` shows `mobile/ios/Runner.xcodeproj/project.pbxproj` and
`mobile/ios/Runner/Base.lproj/Main.storyboard` modified, plus untracked
`backend/.env.example` and `docs/production-readiness-checklist.md`. All four
predate this bugfix; Bug Fixer correctly listed them as untouched. Owner:
`scrum-master` — stage only `mobile/android/settings.gradle.kts`,
`mobile/android/app/build.gradle.kts`,
`mobile/android/app/google-services.json`, and this bug's `data/bugs/**`
artifacts. (D-2 in `fix-evidence.md`, the `validate-runtime-registry.sh`
`web-frontend` `dependsOn` gate noise, is pre-existing, devops-owned, and
already carried on BUG-20260817-001; not repeated here as a new item.)

## Traceability

| Input | Path |
|---|---|
| Bug report | `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/bug_master.md` |
| Diagnosis | `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/diagnosis.md` |
| Fix evidence | `data/bugs/BUG-20260823-001_android_debug_google_signin_generic_error/fix-evidence.md` |
| Changed by bugfix (2) | `mobile/android/settings.gradle.kts`, `mobile/android/app/build.gradle.kts` |
| Changed by user (1) | `mobile/android/app/google-services.json` (Google Cloud console re-download) |
| Read-only confirmation | `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart`, `mobile/lib/core/config/cupid_api_config.dart`, `mobile/lib/core/config/app_config.dart` |
| Generated fix proof | `mobile/build/app/generated/res/processDebugGoogleServices/values/values.xml` |
| Runtime registry | `data/devops/system/runtime-command-registry.json` (`runtimes.mobile-app`, lines 170/223/226) |
| Reproduction capture | `evidence/prefix-01-generic-error-on-tap.png` |
| Prior blocked-pass captures | `evidence/postfix-01..04-*.png` |
| Final recheck captures | `evidence/recheck-01-welcome.png`, `recheck-02-account-chooser.png`, `recheck-03-consent-screen.png`, `recheck-04-signin-ok-backend-unreachable.png` |
| Device | `HT7AH1A02116` (Pixel 2 / walleye), confirmed still attached at review time |

## Touched Risk Surfaces

| Surface | Touched | Critical gate | Verdict |
|---|---|---|---|
| Runtime/configuration (Android Gradle) | Yes — sole code change | Build gate + generated `default_web_client_id` | PASS (re-verified) |
| External integration (Google Sign-In / Credential Manager) | Behaviour restored | Same-modality on-device recheck | PASS |
| Security/auth (sign-in path) | Yes | Real authenticated Firebase user via stock `FirebaseAuth` logging | PASS |
| Package/dependency (google-services 4.4.4) | Yes | Clean build under AGP 9.0.1 / Gradle 9.1.0, no unrelated churn | PASS (re-verified) |
| App lifecycle / runtime startup | Indirect | Registry readiness + shutdown | PASS (re-verified) |
| Secret/credential hygiene | Config file changed | Public client ids and cert hashes only | PASS |
| Scope creep | Must be none | No Dart change, instrumentation reverted, +4/-0 in Gradle | PASS |

Not applicable: persistence/schema, migration, async job/workflow, data
migration/backfill, deep link/push, local storage/offline, typed/generated API
contract, operational command.

## State Recommendation

- Keep `Diagnosis (Bug Fixer)` and `Fix Evidence (Bug Fixer)` checked.
- Check `Review (Reviewer)`.
- Recommend bug status `DONE`. `BLOCKER: DEVICE_SIDE_OAUTH_CONSENT_REQUIRED` is
  closed and no longer applies.
- Carry D-1 and D-3 into the backlog as follow-up items; D-2 is a correction to
  apply when triaging, not a new work item.
- `scrum-master` owns the actual status update; this report does not apply it.
