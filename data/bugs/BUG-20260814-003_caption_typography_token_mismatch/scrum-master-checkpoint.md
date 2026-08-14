# Scrum Master Checkpoint: BUG-20260814-003

Bug id: BUG-20260814-003_caption_typography_token_mismatch
Status: REPORTED

## Artifact Paths
- Bug master: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/fix-evidence.md`
- Review: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/review/review-report.md`

## Failure Anchors
- `login_screen_test.dart:91`
- `waiting_screen_design_fidelity_test.dart:238`
- `joincode_screen_design_test.dart:107`
- All 3: Expected caption size `13`, Actual `11.5`

## Expected Behavior Source
Design-fidelity test assertions (caption typography token spec)

Suspected impacted runtime/service/app: mobile-app (Flutter)
Runtime registry: `data/devops/system/runtime-command-registry.json`

Query keys for future bug-fixer handoff: "caption", "typography token", "11.5"

Active Bug Fixer Agent Id: N/A
Bug Fixer Status: NOT_STARTED

Note: accepted as pre-existing baseline during REQ-002 review gates (not a
regression); low urgency follow-up.
