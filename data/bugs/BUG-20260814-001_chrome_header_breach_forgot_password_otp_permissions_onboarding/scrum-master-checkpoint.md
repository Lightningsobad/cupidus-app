# Scrum Master Checkpoint: BUG-20260814-001

Bug id: BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding
Status: REPORTED

## Artifact Paths
- Bug master: `data/bugs/BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding/fix-evidence.md`
- Review: `data/bugs/BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding/review/review-report.md`

## Failure Anchors
- `chain_chrome_guard_test.dart` `_trackedHeaderBreaches`
- CupidHeader rendered on: forgot_password (STORY-007), otp (STORY-008),
  permissions (STORY-009), onboarding_profile_setup (STORY-010)

## Expected Behavior Source
`ux/uiux-spec.md` Chrome Rules (unconditional; locked spec)

Suspected impacted runtime/service/app: mobile-app (Flutter)
Runtime registry: `data/devops/system/runtime-command-registry.json`

Query keys for future bug-fixer handoff: "chain_chrome_guard_test", "CupidHeader", "_trackedHeaderBreaches"

Active Bug Fixer Agent Id: N/A
Bug Fixer Status: NOT_STARTED
