# Review Scope Gate: REQ-012 Pairing flow QR code & Couple Types screen redesign

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `requirement-integration-review`
- Review report path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/integration-review/review-report.md`
- Scope gate path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/integration-review/scope-gate.md`
- Integration branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-012_pairing_flow_qr_code_and_couple_types_screen`
- BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b` → HEAD `2e2f297fd39f222871e55654e22189e7994d6933`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget: the combined diff is 84 paths, but only 13
  of them are cross-story integration surfaces (shared contract, shared
  dependency set, shared preview registry, shared design-system exports,
  runtime permission config). Every other path is a per-story artifact or a
  per-story-owned source/test file already covered by a passing story review
  (STORY-001 DEFERRED_ONLY, STORY-002 DEFERRED_ONLY, STORY-003 CLEAN). This
  review verifies the seams between the three landings, not the stories again.
- Current requirement status: `IN_PROGRESS` (`req_master.md:2`)
- Merged story ids (landing order): STORY-001 `33b0cf14`, STORY-002 `49896490`,
  STORY-003 `2e2f297f`. All three `story_master.md` files record `Status: DONE`.

## Governing Inputs

- Primary artifacts:
  - `data/requirements/REQ-012_.../req_master.md`
  - `.../STORY-001_.../story_master.md`, `.../STORY-002_.../story_master.md`, `.../STORY-003_.../story_master.md`
  - `.../deployment/configuration-guide.md`
  - `.../scrum-master-checkpoint.md`
- Existing review findings: the three story `review/review-report.md` files
  (STORY-001 DEFERRED_ONLY, STORY-002 DEFERRED_ONLY, STORY-003 CLEAN §11.8)
- Test evidence: the three `coding-plan/test-results.md` files (targeted
  sections only: test command/result rows, `## Story Runtime Startup Smoke`,
  `## Entry Point Reachability`)
- Extra artifacts required beyond the default minimum: none

## Source/Test Files In Scope

Cross-story integration surfaces only (per-story-internal files are out of
scope, already covered by story review):

1. `mobile/pubspec.yaml` — shared dependency set added by two stories
   (`qr_flutter` from STORY-002; `mobile_scanner`, `permission_handler` from
   STORY-003) must coexist on the merged tree
2. `mobile/pubspec.lock` — merged resolution of the same
3. `mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart` —
   QR payload PRODUCER (STORY-002)
4. `mobile/lib/features/pairing/presentation/pairing_code_parser.dart` — QR
   payload CONSUMER (STORY-003). This pair is the requirement's single most
   important cross-story contract and neither story could verify it alone.
5. `mobile/lib/features/pairing/presentation/scan_code_cubit.dart` — the scan
   outcome must equal the manual-entry pairing outcome
6. `mobile/lib/features/pairing/presentation/scan_code_route.dart` — scan entry
   wiring
7. `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
   — flow step 1, routes into steps 2 and 3
8. `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` —
   flow step 3, hosts the scan entry point
9. `mobile/lib/main_preview.dart` — edited by BOTH STORY-001 (+10) and
   STORY-003 (+89); merged registry must be coherent
10. `mobile/lib/design_system/design_system.dart` +
    `mobile/lib/design_system/tokens/qr_palette.dart` +
    `mobile/lib/design_system/tokens/cupid_color_tokens.dart` +
    `mobile/lib/design_system/icons/cupid_icons.dart` — shared design-system
    surface touched by STORY-001 and STORY-002
11. `mobile/android/app/src/main/AndroidManifest.xml` and
    `mobile/ios/Runner/Info.plist` — runtime/configuration surface that the
    requirement-level configuration guide must describe accurately
12. `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
    and `.../pair_gate_cubit_test.dart` — both edited by two stories each;
    checked for merged-state contradiction only
13. `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart` —
    only non-pairing source file in the combined diff; checked for scope leak

## Evidence Files In Scope

- `.../STORY-001_.../coding-plan/test-results.md` (query keys below)
- `.../STORY-002_.../coding-plan/test-results.md` (query keys below)
- `.../STORY-003_.../coding-plan/test-results.md` (query keys below)
- `.../STORY-00{1,2,3}_.../review/review-report.md` (`Outcome:` line, deferred
  finding lists, STORY-003 §11.8)
- `.../deployment/configuration-guide.md` (camera permission entries)
- `.../STORY-00{1,2,3}_.../visual-fidelity/visual-fidelity-report.md`
  (`VISUAL_FIDELITY:` verdict line only — per-story fidelity was already
  adjudicated at story review; this gate only checks the three verdicts are not
  mutually contradictory at requirement level)

## Risk Surfaces And Critical Gates

- Touched risk surfaces: typed/shared contract (QR payload format between
  producer and consumer); package-dependency set (3 new mobile packages);
  permissions/device API (camera, Android + iOS); runtime/configuration
  (manifest/plist + configuration guide); mobile interaction; mobile
  navigation/discoverability (3-screen end-to-end flow); app lifecycle
  (camera controller start/stop on the scan screen).
- Source-of-truth artifacts or contracts: `req_master.md` business intent
  items 1-4; STORY-002 AC2 (scanned QR resolves to the same code as the
  displayed text code) paired with STORY-003 AC2 (scanned code produces an
  identical pairing outcome to a typed code) — the only AC pair that spans two
  stories; `deployment/configuration-guide.md`.
- Critical gates to verify:
  - G1 QR producer/consumer payload agreement (STORY-002 AC2 ↔ STORY-003 AC2)
  - G2 shared dependency coexistence on the merged tree (`pubspec.yaml`/`.lock`)
  - G3 end-to-end flow reachability: choice → create-code QR / choice → join →
    scan
  - G4 merged shared-file coherence (`main_preview.dart`, design-system
    exports, the two doubly-edited test files)
  - G5 configuration-guide accuracy vs the actual manifest/plist entries
  - G6 requirement-level integration build + runtime smoke (SKILL 12g3)
  - G7 requirement-level mobile visual audit (SKILL 12g2)
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` (no frontend/web lane in
  this requirement; all three stories are mobile/shared)
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED` — this requirement has
  mobile participation in all three stories (SKILL 12g2)
- Missing gate evidence or blocker: G6 and G7 are pre-identified as at risk —
  the `integration-review/` directory did not exist before this run, so no
  `## Integration Build & Runtime` section and no `mobile-visual-audit.md` are
  present anywhere under the requirement, and `req_master.md` carries no
  `Integration-Verify: WAIVED` line. Confirmed in Phase 2.

## Query Keys

- `invite_qr_frame.dart`: the QR `data`/payload expression passed to
  `QrImageView`; any prefix/scheme constant
- `pairing_code_parser.dart`: the accepted payload shapes, prefix/scheme
  constants, normalization and length rules
- `scan_code_cubit.dart`: the accept-invitation/pair call reached after a
  successful decode; comparison against the manual-entry call in
  `joincode_screen.dart`
- `pairing_choice_screen.dart`: the three row destinations (create-code route,
  join-code route x2)
- `joincode_screen.dart`: the "Quét QR" action handler and the manual submit
  handler
- `main_preview.dart`: the preview route/registry map entries added by
  STORY-001 vs STORY-003
- `pubspec.yaml`: `qr_flutter`, `mobile_scanner`, `permission_handler`
- `AndroidManifest.xml` / `Info.plist`: `android.permission.CAMERA`,
  `NSCameraUsageDescription`
- `configuration-guide.md`: `CAMERA`, `NSCameraUsageDescription`,
  `mobile_scanner`, `permission_handler`, `qr_flutter`
- `test-results.md` (x3): `## Story Runtime Startup Smoke`,
  `## Entry Point Reachability`, `flutter test`, `flutter analyze`
- `review-report.md` (x3): `Outcome:`
- `visual-fidelity-report.md` (x3): `VISUAL_FIDELITY:`
- `req_master.md`: `Integration-Verify`

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A
- If `NO`, exact blocker or re-scope instruction: N/A
