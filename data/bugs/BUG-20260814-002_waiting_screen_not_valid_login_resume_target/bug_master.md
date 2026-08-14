# Bug Master: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Status: REVIEW_REQUIRED
Severity: blocking (confirmed and elevated by REQ-002 requirement integration
review finding I-4; 2 RED tests are part of the `flutter test` suite that
must be fixed before DEFERRED_ONLY/CLEAN is possible per SKILL 12c)
— fixed, but the reported framing was contradicted by evidence: `waiting` is
structurally unreachable as a login-resume target (already documented as such
in the resolver's own dartdoc) and a runtime probe showed the seeded boot
correctly resolves to `HomeScreen`. The real cause was a lost frame in the
`widget_test.dart`/`feature_flags_test.dart` pump sequence, introduced when an
integration merge combined STORY-001's splash dwell-clear with STORY-032's
two-pump settle structure in the wrong order. Fix is test-only (2 files);
no production routing code changed.

Report correction (evidence-backed, changes the fix from "routing patch" to
"test-only pump-order fix"):
1. Tech Lead finding P1-F3 ("`waiting` is not a valid login-resume target") is
   a pre-disclosed constraint the implementation already honours and
   documents honouring (`onboarding_progress_resolver.dart` dartdoc explicitly
   excludes `waiting`/`permissions` from its outcomes). It is not an
   outstanding defect.
2. Integration review finding I-4 correctly observed 2 RED tests but
   attributed them to P1-F3 by proximity; the true cause is unrelated —
   `pump()` landed before the dwell-clearing `pump(3s)` instead of after it,
   so the assertion ran before the pushed route was built.
Source: Tech Lead pre-disclosure (P1-F3), surfaced during REQ-002 STORY-002
audit; independently confirmed RED (but misattributed) by Iris-QC's
requirement integration review (finding I-4)
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: cross-story (test harness pump ordering; not a story-owned
resolver defect)

## Report

Observed behavior:
Login-resume logic can resolve/target the `waiting` screen as a resume
destination. Confirmed at requirement integration review (I-4): the
integrated boot never reaches `home_screen_ready_signal` — 2 independent
tests (`widget_test.dart`, `app/feature_flags_test.dart`) find 0 widgets even
with a seeded signed-in + paired session. `git log -S` on the key proves no
REQ-002 commit touched it, so the routing logic itself is the cause, not a
stale/renamed key. This key is also the runtime registry's declared
`inAppFirstScreenSignal`.

Expected behavior:
Per Tech Lead finding P1-F3 (pre-disclosed during REQ-002 planning), `waiting`
is not a valid login-resume target. With a seeded signed-in + paired session,
boot must reach `home_screen_ready_signal` (the registry's
`inAppFirstScreenSignal`), and both `widget_test.dart` and
`app/feature_flags_test.dart` must find that widget.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: exercise the login-resume /
onboarding-progress resolution path (e.g. `OnboardingProgressResolver` or
equivalent) with app state that would currently resolve to `waiting`; run
`widget_test.dart` and `app/feature_flags_test.dart` with a seeded
signed-in + paired session.

Failure anchors:
- Stack trace: N/A
- Failing test:
  - `widget_test.dart` (0 widgets found for `home_screen_ready_signal`)
  - `app/feature_flags_test.dart` (same)
- Route/endpoint/component/job: login-resume / onboarding-progress resolution
  logic; `waiting` screen; `home_screen_ready_signal` /
  `inAppFirstScreenSignal` (registry-declared)
- Environment: mobile (Flutter)

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Not-In-Scope Findings (for Scrum Master triage, not fixed here)

- F-1 (diagnosis.md/fix-evidence.md): `runtime-command-registry.json`
  `mobile-app` start command targets a non-existent launcher activity
  (`com.snapsofts.cupid/com.snapsofts.cupid.MainActivity`); real launcher is
  `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`. Same defect
  independently reported by this bug and by BUG-20260814-003 — two
  independent confirmations of the same registry row. Outside bug-fixer's
  write scope; route to DevOps.
- F-2 (fix-evidence.md): the registry's `am start -W` readiness step always
  reports `Status: timeout` for this app because `CupidAppBackground`
  animates forever at the composition root, so the activity never goes idle.
  The `dumpsys activity activities` ResumedActivity poll is the reliable
  signal and passed. Route to DevOps alongside F-1 (same registry entry).

## Routing Notes

- Current owner: scrum-master
- Next role: queued for Reviewer (bugfix-review)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`
- Origin checkpoint: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/scrum-master-checkpoint.md` § Cross-Story / Infra Findings (P1-F3)

## Blockers

- N/A
