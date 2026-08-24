# Story Master: STORY-001 Android Studio Build Variants For Local/Prod Backend
Status: DONE
Complexity: standard
Implementation Lane: shared
Story-Class: standard
UX-Spec: WAIVED — developer/internal build-tooling story (native Android Studio Build Variants selector for local/prod backend); requirements.md "Out of Scope" explicitly excludes any new user-facing feature or end-user-facing UI, no operator-facing UI surface exists
Visual-Fidelity-Evidence: NOT_APPLICABLE - this story renders no product UI; it configures native Android Gradle build flavors and a build-time API base-URL default, surfaced only in Android Studio's own Build Variants panel (IDE tooling, not app UI). No screen, route, or component was added or changed. Reviewer's own login-screen renders during F-001 startup smoke were pre-existing app UI used only to prove assertValidConfig() does not throw at launch, not new/changed UI owed a design comparison.

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:no-ui-surface (developer/internal Android Studio Build Variants tooling only; no end-user-facing UI per requirements.md Out of Scope)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — F-001 resolved: `## Story Runtime Startup Smoke` recorded in coding-plan/test-results.md (Pixel 2 `HT7AH1A02116`, `prod` then `local`, both reached the first screen with no crash and no `assertValidConfig()` throw). AC1-6, §4 deviation, OQ triage, and configuration guide were left untouched as they passed review.
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY (pass 2). AC1-6 PASS, §4 deviation CLEAN-justified, F-001 resolved via real per-flavor startup smoke, expired-session snackbar confirmed benign. D-001/D-002 are non-blocking documentation follow-ups for Tech Lead.
