---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-26
reviewed_by: Reviewer
---

# Review Report: REQ-012 Pairing Flow QR Code & Couple Types Screen — Requirement Integration

Outcome: PATCH_REQUIRED

## Reviewed Inputs

- Review gate: `requirement-integration-review`
- Scope Gate: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/integration-review/scope-gate.md`
- Requirements: `data/requirements/REQ-012_.../req_master.md`; the three
  `story_master.md` files (STORY-001, STORY-002, STORY-003 — all `Status: DONE`)
- Bug Report / Diagnosis / Fix Evidence: `N/A`
- UX: `N/A` at requirement level (per-story UX adjudicated at story review)
- Architecture: `N/A` at requirement level (per-story architecture adjudicated at
  story review); cross-story contract verified in code instead
- Coding Plan: `N/A` at requirement level
- Test Results: the three `coding-plan/test-results.md` files (queried sections
  only: `flutter test` / `flutter analyze` rows, `## Story Runtime Startup
  Smoke`, `## Entry Point Reachability`)
- Previous review findings: STORY-001 `Outcome: DEFERRED_ONLY`
  (`review/review-report.md:12`), STORY-002 `Outcome: DEFERRED_ONLY`
  (`review/review-report.md:3`), STORY-003 `Outcome: CLEAN`
  (`review/review-report.md:367`, §11.8 rework re-review)

## Reviewed Scope

- Story complexity: `N/A` (requirement-level gate; STORY-001/002 standard,
  STORY-003 complex)
- Bug status: `N/A`
- Integration branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`,
  BaseHead `d32f02f3` → HEAD `2e2f297f`, 40 commits, worktree clean, no pending
  merge
- Merged story landings verified as ancestors of HEAD: STORY-001 `33b0cf14`,
  STORY-002 `49896490`, STORY-003 `2e2f297f`
- Code scope reviewed (cross-story seams only; per-story internals were already
  gated at story review):
  `mobile/pubspec.yaml`, `mobile/pubspec.lock`,
  `mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart`,
  `mobile/lib/features/pairing/presentation/pairing_code_parser.dart`,
  `mobile/lib/features/pairing/presentation/scan_code_cubit.dart`,
  `mobile/lib/features/pairing/presentation/scan_code_route.dart`,
  `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`,
  `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`,
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` (QR mount
  point only), `mobile/lib/main_preview.dart`,
  `mobile/android/app/src/main/AndroidManifest.xml`,
  `mobile/ios/Runner/Info.plist`,
  `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`,
  `mobile/test/.../pairing_choice_screen_test.dart`,
  `mobile/test/.../pair_gate_cubit_test.dart`,
  plus `backend/src/modules/invitations/invitations.service.ts` (read only to
  establish the real pairing-code shape the QR contract depends on)
- Evidence reviewed: three `test-results.md`, three `review-report.md`, three
  `visual-fidelity-report.md` verdict lines, `deployment/configuration-guide.md`,
  `req_master.md`, `scrum-master-checkpoint.md`
- Risk surfaces reviewed: shared/typed contract (QR payload producer↔consumer),
  package-dependency set, permissions/device API (camera, Android + iOS),
  runtime/configuration, mobile navigation & discoverability (3-screen flow),
  app lifecycle (scan overlay), mobile interaction
- Critical gates reviewed: G1 QR contract, G2 dependency coexistence, G3
  end-to-end flow, G4 merged shared-file coherence, G5 configuration-guide
  accuracy, G6 integration build + runtime, G7 requirement mobile visual audit
- Backend targeted verification gates: `NOT_APPLICABLE` (no backend change in
  this requirement; `invitations.service.ts` was read, not modified — confirmed
  absent from the combined diff)
- Story runtime startup smoke: `PASS` at story level for all three stories
  (each `test-results.md` carries `## Story Runtime Startup Smoke`, Result PASS,
  run by Scrum Master). Requirement-level integration smoke: see IF-1.
- Frontend targeted verification gates: `NOT_APPLICABLE` (no web lane)
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE` (no frontend
  participation; all three stories are mobile/shared)
- Mobile targeted verification gates: `PATCH_REQUIRED` — green per story, never
  run on the merged tree (IF-1)
- Mobile discoverability/navigation integration: `PASS` (G3 below)
- Requirement mobile visual audit: `PATCH_REQUIRED` (IF-2)
- OQ context reviewed: OQ1 RESOLVED (STORY-003, scan mechanism — full-screen
  overlay, permission requested at tap time); OQ2 RESOLVED (STORY-002, continue
  CTA destination unchanged, "Fingerprint Vow" wiring correctly not
  implemented). No unresolved OQ remains at requirement level.

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: the three stories integrate correctly *as code* — the requirement's
  one genuine cross-story contract (STORY-002's QR producer ↔ STORY-003's QR
  consumer) holds, the end-to-end pairing flow is wired and reachable, the three
  new mobile packages coexist in `pubspec.yaml`, and the shared files each story
  touched merged coherently (STORY-002 even repaired STORY-001's tests for the
  never-settling QR animation before landing). What is missing is proof that the
  *merged* tree resolves, builds and boots: the requirement carries no
  `## Integration Build & Runtime` evidence, and I established that no such run
  has ever happened — STORY-003's green suite ran on a tree that contains
  neither STORY-001's nor STORY-002's code. The requirement-level mobile visual
  audit is also absent. Both are named, non-waivable requirement-closure gates.
  Neither is a code defect, so no story goes back to a development lane; this
  needs an integration-verification pass, not rework.
- Blocking findings: 3
- Deferred findings: 4
- Dismissed observations: 1

## Traceability Summary

- Requirements: `req_master.md` business intent items 1-4 are each delivered —
  (1) three-row pairing-method screen (STORY-001 AC1-AC4), (2) QR on the
  create-code screen (STORY-002 AC1-AC5), (3) camera QR scanning on the
  scan-code screen (STORY-003 AC1-AC5), (4) the create-code screen remains the
  existing Couple Types screen, updated in place — `invite_screen.dart` was
  modified (190 changed lines), no new screen file was added, and the
  couple-type picker still follows the code/QR block on the same screen.
- Cross-story AC pair: STORY-002 AC2 ("a scanned QR resolves to the same code as
  the displayed text code") and STORY-003 AC2 ("a scanned code produces an
  identical pairing outcome to a typed code") are the only ACs neither story
  could verify alone. Both PASS — see G1 and G3.
- Open Questions: OQ1 and OQ2 both RESOLVED and carried into ACs; no OQ was
  over-applied (STORY-003 implemented the full AC1-4 functional scope that OQ1
  explicitly did not block).
- UX / Architecture: adjudicated per story; the three per-story
  `visual-fidelity-report.md` files all record `VISUAL_FIDELITY: PASS`
  (STORY-003 with `OPEN_OBSERVATIONS: VF-7`, accepted deferred). The three
  verdicts are mutually consistent; no story's design decision contradicts
  another's.
- Testing evidence: per-story suites green (STORY-003 `flutter test
  test/features/pairing` → `+223: All tests passed!`; `flutter analyze` at the
  unchanged 8-info baseline). No merged-tree run exists — IF-1.
- Merge refs: all three landings confirmed ancestors of HEAD via
  `git merge-base --is-ancestor`.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Shared/typed contract — QR payload | STORY-002 AC2 ↔ STORY-003 AC2 | G1 producer/consumer agreement | PASS | `invite_qr_frame.dart:197` encodes `data: code` byte-for-byte (documented at `:57-65`); `pairing_code_parser.dart:18-31` extracts the tail after the last `/` or `:`, strips non-alphanumerics, uppercases, and accepts `^[A-Z0-9]{6}$`; the server issues exactly that shape — `backend/src/modules/invitations/invitations.service.ts:36`, `randomBytes(3).toString('hex').toUpperCase()` = 6 uppercase hex chars. A real inviter QR therefore decodes to precisely the code shown as text. |
| Package dependencies | `mobile/pubspec.yaml` | G2 three-package coexistence | PARTIAL → IF-1 | `pubspec.yaml:61-63` carries `qr_flutter: ^4.1.0` (STORY-002), `mobile_scanner: ^7.4.0` and `permission_handler: ^12.0.1` (STORY-003) together, and both stories' `pubspec.lock` additions merged without collision. Declaration is correct; resolution/build of the combined set has never been executed — folded into IF-1. |
| Mobile navigation / discoverability | `req_master.md` items 1-3 | G3 end-to-end flow | PASS | choice → create-code: `pairing_choice_screen.dart:227` → `_openInvite` (`:114` push of `InviteScreen`). choice → join-code: `:247` and `:268` → `_openJoincode` (`:123`). join-code → scanner: `joincode_screen.dart:343-346` "Quét QR" → `_openScanner` (`:185-193`, pushes `ScanCodeRoute`). scanner → pairing: `scan_code_route.dart:42-48` shares the join-code screen's own `JoincodeCubit` via `BlocProvider.value`, and `scan_code_cubit.dart:112-121` parses then calls `_joincodeCubit.submit(code)` — literally the same call manual entry makes, so the scanned and typed outcomes cannot diverge. |
| App lifecycle — scan overlay | STORY-003 UX spec States 1-7 | Overlay does not own the shared cubit's lifecycle | PASS | `scan_code_route.dart:38-48` uses `.value`, not `create`; `scan_code_cubit.dart:154` cancels its join-code subscription on close. The screen below stays mounted, so typed characters survive the overlay. |
| Merged shared files | Combined diff | G4 coherence across three landings | PASS | `main_preview.dart`: STORY-001 renamed the `pairingchoice` key to the real canvas id `pairstart`, STORY-003 added a separate `scan` entry — no duplicate or clobbered keys. The two doubly-edited test files are the one place a real cross-story regression appeared and it was caught before landing: STORY-002 replaced `pumpAndSettle` with bounded pumps in STORY-001's `pairing_choice_screen_test.dart:87-90,158-170` and in `pair_gate_cubit_test.dart:173-176`, because the new QR frame animates forever and no frame is ever quiet once `InviteScreen` mounts. `pet_preview_card.dart:226-233` is STORY-001's in-scope BUG-20260825-002 fix, consistent with the additive `colorGlowCore` token — not a scope leak. |
| Permissions / device API | `deployment/configuration-guide.md` | G5 guide matches shipped config | PASS (content) | `AndroidManifest.xml` adds `android.permission.CAMERA` plus `android.hardware.camera` `required="false"`; `Info.plist` adds `NSCameraUsageDescription`. The guide documents both verbatim, plus the `permission_handler` 12.x pin rationale (`permission_handler_android` 14.0.0 wants platform hash `android-37`, which the SDK does not publish), the minSdk analysis, Play Data Safety, and the iOS `PERMISSION_CAMERA` macro caveat. Every claim I could check against the diff is accurate. Requirement-level bookkeeping around it is stale — IF-3. |
| Runtime / configuration — merged tree | SKILL 12g3 | G6 integration build + runtime smoke | PATCH_REQUIRED | IF-1 |
| Mobile design fidelity — cross-screen | SKILL 12g2 | G7 requirement mobile visual audit | PATCH_REQUIRED | IF-2 |

## Blocking Findings

### IF-1 — The merged tree has never been built, resolved, analyzed, or booted

SKILL 12g3 requires `data/requirements/REQ-012_.../integration-review/` to carry
a `## Integration Build & Runtime` section with `- Build: PASS — <command +
result>` and `- Runtime/Smoke: PASS — <startup smoke command + result>` in the
same file. The `integration-review/` directory did not exist before this review
run, so neither line exists anywhere under the requirement, and `req_master.md`
records no `Integration-Verify: WAIVED — <reason>`.

This is not a paperwork gap. The merged combination has demonstrably never been
exercised:

- STORY-003's evidence run (`flutter test test/features/pairing` →
  `+223: All tests passed!`, `coding-plan/test-results.md:591`) was executed at
  `bb089dc84f`.
- `git cat-file -e bb089dc84f:mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart`
  → the file does not exist in that tree.
- `git diff --stat bb089dc84f HEAD -- mobile/` → 15 files, +1309/-167: all of
  STORY-001's redesigned `pairing_choice_screen.dart`, all of STORY-002's
  `invite_qr_frame.dart` / `qr_palette.dart` / rebuilt `invite_screen.dart`, the
  `qr_flutter` dependency, and the two repaired test files land *after* that run.

So no `flutter pub get`, `flutter analyze`, `flutter test`, or app launch has
ever run against the three-package dependency set (`qr_flutter ^4.1.0` +
`mobile_scanner ^7.4.0` + `permission_handler ^12.0.1`) or against the merged
`main_preview.dart`. Given that the guide itself documents a real Android
resolution failure in this exact dependency family (the `permission_handler` 12.x
pin), an unverified combined resolve is a concrete, not theoretical, risk.

I did not run these myself: my declared `WriteScope` is
`integration-review/*`, and `flutter pub get` / `flutter test` write
`.dart_tool/` and build output into the worktree, outside that scope. SKILL 12g3
routes this to the integration-verification pass.

### IF-2 — Requirement-level mobile visual audit is missing

SKILL 12g2 keeps `data/requirements/REQ-012_.../integration-review/mobile-visual-audit.md`
as a separate, still-blocking cross-screen check before requirement closure, and
states explicitly that the per-story captures do not substitute for it in either
direction. All three stories carry passing per-story evidence
(`VISUAL_FIDELITY: PASS` x3), which satisfies 12e2/12g2's *per-story* half only.
The cross-screen concern this requirement actually raises is real and unexamined:
three adjacent screens in one flow were restyled by three different implementers
against three different canvas blocks (`pairstart`, `invite`, `isJoinCode` +
the newly authored scan-overlay states), and no one has looked at them
side by side for shell, navigation, and visual-consistency breakage.

### IF-3 — Requirement-level state records contradict the delivered work

Three stale records under `data/requirements/REQ-012_.../`, all Scrum Master
owned, all cheap to correct, all of which would otherwise be carried into
closure:

- `req_master.md:9-13` — `## Configuration Documentation` says
  `Status: NOT_REQUIRED` with an empty `Last Updated`, while
  `deployment/configuration-guide.md` documents store-facing, build-time camera
  configuration (Android permission + feature declaration, iOS usage
  description, a deliberate dependency version pin). SKILL 12a puts
  requirement-level configuration-guide consistency in this gate's scope.
- `req_master.md:66-69` — the User Stories table lists all three stories
  `PENDING`; all three `story_master.md` files record `Status: DONE`.
- `scrum-master-checkpoint.md` on this branch is still at the UX phase
  ("Current Phase: UI/UX Design (Pink-Designer) for all 3 stories"), naming a
  Next Valid Step that completed weeks of work ago.

## Deferred Findings

- **DF-1 — `qr_flutter` absent from the configuration guide's dependency table.**
  The guide (`## New Third-Party Dependencies`) lists `mobile_scanner` and
  `permission_handler` but not STORY-002's `qr_flutter ^4.1.0`. The guide is
  camera-scoped by title and `qr_flutter` is pure Dart with no native, store, or
  permission implication, so nothing operational is missing — but the
  requirement's dependency footprint is three packages, not two. Owner: DevOps,
  one table row.
- **DF-2 — "Scan the QR" and "They already have a code" have identical
  destinations.** `pairing_choice_screen.dart:247` and `:268` both call
  `_openJoincode`, so a user who explicitly picked *scan* still has to tap
  "Quét QR" on the join-code screen to reach the scanner that now exists. This
  is exactly what STORY-001 AC3 approved ("both routes land on the existing
  join-code screen, matching current design's own routing") and was decided
  before STORY-003 made the scanner real, so it is not a defect. Worth a
  Product Owner look now that the third row leads somewhere. Owner: Product
  Owner.
- **DF-3 — STORY-002 describes the pairing code as 8 characters; it ships as 6.**
  `story_master.md` In Scope item 2 says "the existing 8-character text code"
  (inherited from the design source's mock). Reality is 6 everywhere:
  `invitations.service.ts:36` (`randomBytes(3)` hex), `joincode_screen.dart:39`
  (`_codeLength = 6`), `pairing_code_parser.dart:2` (`pairingCodeLength = 6`).
  Documentation-only; the QR encodes whatever the real code is, so behavior is
  unaffected and G1 still holds.
- **DF-4 — Story-level deferred items carried forward, not re-adjudicated here.**
  STORY-001 D-1 (escape link, resolved by Product Owner DROP decision);
  STORY-002's five deferred items (pre-existing BUG-20260825-002, pre-existing
  `gallery_cubit_test.dart:276` flake, two documented plan deviations, QR
  module-ink colour); STORY-003 DF-2/DF-4/DF-5 and UV-1. All were accepted at
  story review; none became worse through integration.

## Dismissed Observations

- The scan path *rejects* a payload that does not normalize to exactly 6
  alphanumerics, while the manual Paste path *truncates* to the first 6
  (`joincode_screen.dart:162-170`). The asymmetry is deliberate and documented
  at `pairing_code_parser.dart:14-17`: truncating would read
  `https://cupid.app/join/ABC123` as `HTTPS:` and turn a malformed scan into a
  real backend call the user cannot act on. Correct as written; not a finding.

## Implementation Action Items

- `[devops]` `data/requirements/REQ-012_.../integration-review/` — run the
  integration-verification pass on this branch and record, in ONE file, a
  `## Integration Build & Runtime` section containing both
  `- Build: PASS — <command + result>` and
  `- Runtime/Smoke: PASS — <startup smoke command + result>`. The build must
  exercise the merged dependency set (`cd mobile && flutter pub get` then
  `flutter build apk --debug`, the only gate the configuration guide says
  catches the `permission_handler` platform-hash failure), and the smoke must be
  an app launch on the provided emulator reaching its first screen without a
  crash or error screen. A merged `flutter test test/features/pairing` +
  `flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing`
  should be recorded alongside it, since no suite has yet run against all three
  stories' code together. (IF-1)
- `[mobile-dev]` `data/requirements/REQ-012_.../integration-review/mobile-visual-audit.md`
  — cross-screen audit of the three restyled screens as one flow (pairstart →
  invite → joincode → scan overlay) on the provided device/emulator, checking
  shell, navigation and visual consistency between screens rather than
  re-adjudicating any single screen. (IF-2)
- `[scrum-master]` `data/requirements/REQ-012_.../req_master.md` — set
  `## Configuration Documentation` `Status` to reflect the delivered
  `deployment/configuration-guide.md` and fill `Last Updated`; update the User
  Stories table rows to `DONE`. (IF-3)
- `[scrum-master]` `data/requirements/REQ-012_.../scrum-master-checkpoint.md` —
  refresh to the current phase (requirement integration review) instead of the
  UX phase. (IF-3)

## Workflow State Recommendation

- Story status: `N/A` — all three stories stay `DONE`. No finding in this report
  returns any story to a development lane; every blocking item is
  requirement-level evidence or requirement-level bookkeeping.
- Requirement status: `IN_PROGRESS` — do not mark REQ-012 `DONE`.
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Next step: route the integration-verification pass (IF-1) and the requirement
  mobile visual audit (IF-2), apply the IF-3 record corrections, then return for
  a re-review that verifies only those three items against this report. The
  cross-story code review (G1-G5) is complete and does not need repeating.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
